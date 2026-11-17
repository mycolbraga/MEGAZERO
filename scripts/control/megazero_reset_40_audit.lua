-- MEGAZERO | RESET 40 | DIAGNOSI GPS read-only su PC54
-- NESSUN MOVIMENTO, NESSUN COMANDO DI SCAVO O AZZERAMENTO.
-- MEGAZERO | Flotta 40: verifica, OTA, avvia | PC54 | v2.3.16.
-- La dashboard NON deve essere in esecuzione contemporaneamente.
-- Agenti 1.10 NON possono aggiornare Turtle con checkpoint/errore:
-- installer locale universale necessario una volta su quelle Turtle.
assert(not turtle and os.getComputerID()==54,"Serve la centrale PC54")
local args={...}
local mode=args[1] or "verifica"
assert(mode=="verifica" or mode=="aggiorna" or mode=="avvia" or
 mode=="riavvia","Uso: verifica | aggiorna | avvia | riavvia")
local extra=nil
if mode=="aggiorna" and args[2] then
 assert(#args==5,"Uso: aggiorna SHA40 VERSIONE_MINER VERSIONE_FLUIDI VERSIONE_AGENTE")
 assert(type(args[2])=="string" and #args[2]==40 and
  args[2]:match("^[0-9a-f]+$"),"SHA release errato")
 for i=3,5 do
  assert(type(args[i])=="string" and
   args[i]:match("^%d+%.%d+%.?%d*$"),"Versione errata")
 end
 extra={release=args[2],package_version=args[3],
  fluid_version=args[4],agent_target_version=args[5]}
end
local SITE="MINIERA-01"
local PROTO="megazero.admin.v1"
local path="/.megazero_control_db"
local f=assert(fs.open(path,"r"),"Database centrale non presente")
local db=assert(textutils.unserialize(f.readAll()),"Registro centrale corrotto")
f.close()
assert(type(db.units)=="table","Registro centrale privo di unit")
local units,seen={},{}
for _,side in ipairs({"N","O","S","E"}) do
 for n=1,10 do
  local unit=side..string.format("%02d",n)
  local rec=db.units[SITE.."|"..unit]
  assert(type(rec)=="table" and type(rec.sender)=="number",
   "ID mancante in centrale per "..unit)
  assert(not seen[rec.sender],"ID duplicato "..rec.sender)
  seen[rec.sender]=true
  units[#units+1]={unit=unit,id=rec.sender}
 end
end
local modem=peripheral.find("modem",function(_,m)
 return m.isWireless and m.isWireless()
end)
assert(modem,"Nessun modem wireless")
rednet.open(peripheral.getName(modem))
local function now() return os.epoch("utc") end
local seq=0
local function exchange(command,targets,phase,waitMs,extras)
 local jobs,results,errors={},{},{}
 for _,t in ipairs(targets) do
  seq=seq+1
  local id="F54-"..now().."-"..seq
  local p={kind="admin_request",version=1,site=SITE,
   target_unit=t.unit,target_computer_id=t.id,
   request_id=id,command=command}
  if extras then
   for k,v in pairs(extras) do p[k]=v end
  end
  local job={id=t.id,unit=t.unit,packet=p,tries=1,last=now()}
  jobs[id]=job
  rednet.send(t.id,p,PROTO)
 end
 local remaining=#targets
 local deadline=now()+(waitMs or 15000)
 while remaining>0 and now()<deadline do
  local sender,p=rednet.receive(PROTO,0.2)
  if sender and type(p)=="table" and p.kind=="admin_reply" and
   p.site==SITE and p.version==1 and p.command==command then
   local job=jobs[p.request_id]
   if job and not job.done and job.id==sender and
    p.computer_id==sender and p.unit==job.unit then
    job.done=true;remaining=remaining-1
    if p.accepted==true and p.phase==phase then
     results[job.unit]=p
    else
     errors[#errors+1]=job.unit..": "..tostring(p.reason or p.phase)
    end
   end
  end
  if command~="START" then
   for _,job in pairs(jobs) do
    if not job.done and job.tries<3 and now()-job.last>2300 then
     job.tries=job.tries+1;job.last=now()
     rednet.send(job.id,job.packet,PROTO)
    end
   end
  end
 end
 for _,job in pairs(jobs) do
  if not job.done then errors[#errors+1]=job.unit..": nessun ACK PC"..job.id end
 end
 table.sort(errors)
 return results,errors
end
local function collect(map,condition)
 local result={}
 for _,t in ipairs(units) do
  local data=map[t.unit]
  if data and condition(t,data) then result[#result+1]=t end
 end
 return result
end
local function count(map)
 local n=0;for _ in pairs(map) do n=n+1 end;return n
end
local function outErrors(errors)
 for _,e in ipairs(errors) do printError(e) end
end

print("MEGAZERO RESET DA ZERO | AUDIT GPS 40 | SOLO LETTURA")
local status,errors=exchange("RESET_AUDIT",units,"DONE",26000)
print("Risposte GPS: "..count(status).."/40")
outErrors(errors)
local home,off,pending,unknown=0,0,0,0
for _,t in ipairs(units) do
 local p=status[t.unit]
 if p then
  local a=p.reset_audit
  if type(a)~="table" then
   unknown=unknown+1
   printError(t.unit.." PC"..t.id.." | agente senza RESET_AUDIT")
  else
   local location=a.gps_ok and
    (tostring(a.gps_x)..","..tostring(a.gps_y)..","..tostring(a.gps_z))
    or "GPS NON DISPONIBILE"
   local saved=tostring(a.saved_x)..","..tostring(a.saved_y)..","..tostring(a.saved_z)
   local flag=a.pending and tostring(a.pending) or "NO"
   local state
   if not a.gps_ok or not a.cp_ok then
    unknown=unknown+1;state="INCERTA"
   elseif a.ready_home==true then
    home=home+1;state="HOME VERIFICATA"
   else
    off=off+1;state=a.gps_home and "GPS HOME MA CP DA VERIFICARE" or "FUORI HOME"
   end
   if a.pending then pending=pending+1 end
   print(t.unit.." PC"..t.id.." | "..state.." | GPS "..location)
   if state~="HOME VERIFICATA" then
    print("    CP "..saved.." d="..tostring(a.saved_d)..
      " pend="..flag.." path="..tostring(a.path_count)..
      " LIV "..tostring(a.level).." dist "..tostring(a.distance))
   end
  end
 else
  unknown=unknown+1
 end
end
print("HOME verificate: "..home.."/40")
print("Non pronte: "..off.." | senza prova: "..unknown..
 " | checkpoint pending: "..pending)
print("NON ESEGUITI: movimenti, reset, cancellazione errori, avvio")
if home==40 then
 print("Tutte fisicamente HOME: prossimo passo reset 0% con backup.")
else
 print("Reset totale BLOCCATO: prima risolvere Turtle fuori HOME.")
end
