-- MEGAZERO PC54 | RESET 40 DA ZERO | GPS HOME obbligatorio
-- Nessuno scavo/avvio. Preflight 40/40 prima di qualsiasi reset.
-- MEGAZERO | Flotta 40: verifica, OTA, avvia | PC54 | v2.3.16.
-- La dashboard NON deve essere in esecuzione contemporaneamente.
-- Agenti 1.10 NON possono aggiornare Turtle con checkpoint/errore:
-- installer locale universale necessario una volta su quelle Turtle.
assert(not turtle and os.getComputerID()==54,"Serve la centrale PC54")
local args={...}
local mode=args[1] or "verifica"
assert(mode=="verifica" or mode=="azzera","Uso: verifica | azzera")
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

print("MEGAZERO PC54 | RESET COMPLETO 40 | "..mode)
local status,err=exchange("STATUS",units,"DONE",30000)
outErrors(err)
assert(count(status)==40,"Fermato: STATUS incompleto")
for _,t in ipairs(units) do
 local p=status[t.unit]
 local v=p.miner and p.miner.version or ""
 if p.agent_version~="1.15" or
  type(v)~="string" or
  not v:find("^%-%- MEGAZERO MINER v2%.3%.16") or
  p.miner_autostart~=false or
  p.current_status=="SCAVO" or p.current_status=="RIENTRO" then
  printError("STOP "..t.unit..": versione/stato/autostart non sicuri")
  return
 end
end
local audit,e1=exchange("RESET_AUDIT",units,"DONE",45000)
outErrors(e1)
if count(audit)~=40 then
 printError("STOP: audit GPS incompleto "..count(audit).."/40")
 return
end
local readyHome=0
for _,t in ipairs(units) do
 local p=audit[t.unit]
 if p and p.reset_audit and p.reset_audit.ready_home==true then
  readyHome=readyHome+1
 else printError("NON HOME: "..t.unit) end
end
print("GPS HOME + checkpoint: "..readyHome.."/40")
if readyHome~=40 then
 printError("RESET BLOCCATO: servono 40 HOME verificate")
 return
end
local checks,e2=exchange("RESET_CHECK",units,"DONE",45000)
outErrors(e2)
local ready=collect(checks,function(_,p)
 return p.reset_allowed==true end)
for _,t in ipairs(units) do
 local p=checks[t.unit]
 if not p or p.reset_allowed~=true then
  printError(t.unit.." non resettabile: "..
   tostring(p and p.reset_reason or "nessun ACK"))
 end
end
print("Preflight RESET: "..#ready.."/40")
if #ready~=40 then
 printError("NESSUN RESET: controllo preliminare incompleto")
 return
end
if mode=="verifica" then
 print("SOLO LETTURA. Per azzerare: parametro 'azzera'.")
 return
end
-- Un reset effettivo salva vecchio checkpoint, latch e configurazione
-- sul computer Turtle PRIMA di ricreare checkpoint livello 1 dist 0.
local completed={}
local errors={}
for k=1,40,8 do
 local batch={}
 for i=k,math.min(40,k+7) do batch[#batch+1]=ready[i] end
 print("AZZERAMENTO lotto "..k.."-"..math.min(40,k+7))
 local result,e=exchange("RESET_ZERO",batch,"DONE",45000,
  {reset_token="MEGAZERO_40_RESET_DA_ZERO"})
 for _,x in ipairs(e) do errors[#errors+1]=x end
 for _,t in ipairs(batch) do
  if result[t.unit] then completed[t.unit]=true end
 end
 print("Confermati "..count(completed).."/40")
end
outErrors(errors)
print("Reset con ACK: "..count(completed).."/40")
local final,ef=exchange("RESET_AUDIT",units,"DONE",45000)
outErrors(ef)
local zero=0
for _,t in ipairs(units) do
 local p=final[t.unit]
 local a=p and p.reset_audit
 if a and a.ready_home==true and a.level==1 and
  a.distance==0 and a.error_latched==false and
  a.path_count==0 and a.pending==nil then
  zero=zero+1
 else
  printError("RESET NON VERIFICATO "..t.unit)
 end
end
print("Checkpoint livello 1, distanza 0: "..zero.."/40")
if zero==40 then
 print("RESET 40/40 CONFERMATO. AUTOSTART OFF. Pronte per CHECK_START.")
else
 printError("NON AVVIARE: reset incompleto.")
end
