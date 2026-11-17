-- MEGAZERO PC54 | AVVIO 40/40 SOLO DOPO GPS HOME + CHECK_START | miner 2.3.18, agente 1.18
-- La dashboard NON deve essere in esecuzione contemporaneamente.
-- Agenti 1.10 NON possono aggiornare Turtle con checkpoint/errore:
-- installer locale universale necessario una volta su quelle Turtle.
assert(not turtle and os.getComputerID()==54,"Serve la centrale PC54")
local mode="avvia"
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
print("MEGAZERO PC54 | "..mode.." | "..#units.." Turtle")
print("Interrogo gli agenti via Rednet, senza muovere Turtle...")
local status,errors=exchange("STATUS",units,"DONE",15500)
print("Risposte: "..count(status).."/40")
if count(status)~=40 then printError("STOP: risposte parziali, nessun avvio");return end
outErrors(errors)
local candidates={}
for _,t in ipairs(units) do
 local p=status[t.unit]
 local v=p.miner and p.miner.version or ""
 local ok=p.agent_version=="1.18" and type(v)=="string" and
  v:find("^%-%- MEGAZERO MINER v2%.3%.18") and
  p.miner_autostart==false and
  (p.current_status=="BASE" or p.current_status=="PREPARAZIONE") and
  not (p.error_latch and p.error_latch~="")
 if ok then
  candidates[#candidates+1]=t
 else
  printError("NON PRONTA "..t.unit.." | agente "..tostring(p.agent_version)..
   " | miner "..tostring(v):sub(1,43).." | stato "..tostring(p.current_status)..
   " | autostart "..tostring(p.miner_autostart))
 end
end
print("Miner 2.3.18, agente 1.18, ferme e disarmate: "..#candidates.."/40")
if #candidates~=40 then
 printError("STOP: nessun comando di avvio inviato")
 return
end
-- Verifica indipendente GPS HOME e checkpoint ancora azzerato.
local audit,ae=exchange("RESET_AUDIT",units,"DONE",42000)
outErrors(ae)
local zero=0
for _,t in ipairs(units) do
 local p=audit[t.unit]
 local a=p and p.reset_audit
 if a and a.ready_home==true and a.level==1 and a.distance==0
  and a.path_count==0 and a.pending==nil and a.error_latched==false then
  zero=zero+1
 else
  printError(t.unit..": GPS/zero checkpoint non confermati")
 end
end
print("GPS HOME e checkpoint liv1 dist0: "..zero.."/40")
if zero~=40 then printError("STOP: non invio ARM_START o START");return end
local checks,ce=exchange("CHECK_START",candidates,"DONE",14000)
outErrors(ce)
local eligible=collect(checks,function(t,p)
 if p.start_allowed~=true then
  printError(t.unit..": "..tostring(p.start_reason or "Avvio negato"))
  return false
 end
 return true
end)
if #eligible~=40 then
 printError("STOP: CHECK_START superato "..#eligible.."/40; nessun avvio.")
 return
end
local armed,ae=exchange("ARM_START",eligible,"ARMED",7500)
outErrors(ae)
local ready=collect(armed,function(_,p) return type(p.arm_id)=="string" end)
if #ready~=#eligible then
 printError("Armamento incompleto, NON invio START a nessuno.")
 return
end
-- Ogni ARM scade dopo 20 secondi. Invio START non ritentato.
local startupJobs={}
for _,t in ipairs(ready) do
 seq=seq+1
 local id="F54-"..now().."-"..seq
 local p={kind="admin_request",version=1,site=SITE,
  target_unit=t.unit,target_computer_id=t.id,
  request_id=id,command="START",arm_id=armed[t.unit].arm_id}
 startupJobs[#startupJobs+1]={unit=t.unit,id=t.id,packet=p,done=false}
 rednet.send(t.id,p,PROTO)
end
local deadline=now()+14000
local started={}
while now()<deadline do
 local sender,p=rednet.receive(PROTO,0.2)
 if sender and type(p)=="table" and p.kind=="admin_reply" and
  p.site==SITE and p.version==1 and p.command=="START" then
  for _,job in ipairs(startupJobs) do
   if not job.done and job.id==sender and
    p.computer_id==sender and p.unit==job.unit and
    p.request_id==job.packet.request_id then
    job.done=true
    if p.accepted and p.phase=="STARTING" then started[job.unit]=true
    else printError(job.unit.." START negato: "..tostring(p.reason)) end
    break
   end
  end
 end
end
print("STARTING confermati: "..count(started).."/"..#ready)
print("STARTING conferma il comando/reboot, NON lo scavo effettivo.")
for _,job in ipairs(startupJobs) do
 if not job.done then
  printError(job.unit..": ACK mancante, possibile reboot gia iniziato.")
 end
end
print("Controllare SCAVO dalla dashboard. Non ripetere avvia alla cieca.")
