-- MEGAZERO | PC54 | INSTALLA AGENTE 1.16 E CONTROLLA GPS DELLE 40
-- La dashboard NON deve essere in esecuzione contemporaneamente.
-- Agenti 1.10 NON possono aggiornare Turtle con checkpoint/errore:
-- installer locale universale necessario una volta su quelle Turtle.
assert(not turtle and os.getComputerID()==54,"Serve la centrale PC54")
local args={...}
local mode=args[1] or "verifica"
assert(mode=="verifica","Questo programma non accetta modalita di avvio")
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

local RELEASE="b43027cbcfe6c1e04d591cda47cc6ec315c069d5"
local extra={
 release=RELEASE,package_version="2.3.17",
 fluid_version="1.2",agent_target_version="1.16"
}
print("MEGAZERO PC54 | OTA MINER 2.3.17 + FLUIDI 1.2")
print("Autostart e miner non saranno attivati; nessun reset dei checkpoint.")
print("Controllo tutte le 40 Turtle...")
local before,e1=exchange("STATUS",units,"DONE",25000)
outErrors(e1)
if count(before)~=40 then
 printError("Mancano risposte: "..count(before).."/40. NON AGGIORNO.")
 return
end
local targets={}
for _,t in ipairs(units) do
 local p=before[t.unit]
 if p.current_status=="SCAVO" or p.current_status=="RIENTRO" or
  p.miner_autostart==true then
  printError(t.unit.." in movimento/autostart attivo; STOP GENERALE")
  return
 end
 if p.agent_version~="1.16" then
  printError(t.unit.." agente inatteso: "..tostring(p.agent_version))
  return
 end
 local header=p.miner and p.miner.version or ""
 if type(header)~="string" then header="" end
 if header:find("^%-%- MEGAZERO MINER v2%.3%.16") then
  targets[#targets+1]=t
 elseif not header:find("^%-%- MEGAZERO MINER v2%.3%.17") then
  printError(t.unit.." miner inatteso: "..tostring(header))
  return
 end
end
print("Miner 2.3.16 da aggiornare: "..#targets.."/40")
local succeeded={}
if #targets>0 then
 local checks,errors=exchange("CHECK_UPDATE",targets,"DONE",30000,extra)
 outErrors(errors)
 local ready=collect(checks,function(_,p) return p.update_allowed==true end)
 if #ready~=#targets then
  printError("Preflight update non 40/40; nessun aggiornamento avviato.")
  for _,t in ipairs(targets) do
   local p=checks[t.unit]
   if not p or p.update_allowed~=true then
    printError(t.unit..": "..tostring(p and p.block_reason or "nessun ACK"))
   end
  end
  return
 end
 print("Preflight update OK: "..#ready.."/"..#targets)
 -- Lotti piccoli per non scaricare contemporaneamente 160 moduli.
 for k=1,#ready,8 do
  local batch={}
  for i=k,math.min(#ready,k+7) do batch[#batch+1]=ready[i] end
  print("PREPARE_UPDATE lotto "..k.."-"..math.min(#ready,k+7))
  local staged,se=exchange("PREPARE_UPDATE",batch,"STAGED",90000,extra)
  outErrors(se)
  local prepared=collect(staged,function(_,p) return p.accepted==true end)
  if #prepared>0 then
   local installed,ie=exchange("COMMIT_UPDATE",prepared,"DONE",85000)
   outErrors(ie)
   for _,t in ipairs(prepared) do
    if installed[t.unit] then succeeded[t.unit]=true end
   end
   print("Installazioni confermate cumulative: "..count(succeeded))
  end
 end
end
-- Per l'agente installato il file su disco e' 1.16, ma ancora
-- gira il codice 1.15 in memoria. Reboot solo con autostart OFF.

-- L'agente resta 1.16: non occorre reboot.
print("Verifico il miner senza avviare le Turtle...")
local loaded,le=exchange("STATUS",units,"DONE",45000)
outErrors(le)
local current=0
for _,t in ipairs(units) do
 local p=loaded[t.unit]
 local header=p and p.miner and p.miner.version or ""
 if type(header)=="string" and
  header:find("^%-%- MEGAZERO MINER v2%.3%.17") and
  p.agent_version=="1.16" and p.miner_autostart==false then
  current=current+1
 else printError(t.unit.." da verificare: "..tostring(header)) end
end
print("Miner 2.3.17, agente 1.16, autostart OFF: "..current.."/40")
if current~=40 then printError("NON AVVIARE: aggiornamento incompleto") end
print("Nessun movimento, scavo o reset richiesto.")
