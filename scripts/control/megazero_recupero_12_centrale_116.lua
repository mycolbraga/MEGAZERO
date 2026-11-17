-- MEGAZERO PC54 | RECUPERO SICURO 12 | v1.1 | autorizzazione tetto base
-- Solo "tutte" sposta Turtle; "verifica" legge audit.
-- Checkpoint e vecchi errori non vengono cancellati.
-- MEGAZERO | Flotta 40: verifica, OTA, avvia | PC54 | v2.3.16.
-- La dashboard NON deve essere in esecuzione contemporaneamente.
-- Agenti 1.10 NON possono aggiornare Turtle con checkpoint/errore:
-- installer locale universale necessario una volta su quelle Turtle.
assert(not turtle and os.getComputerID()==54,"Serve la centrale PC54")
local args={...}
local mode=args[1] or "verifica"
assert(mode=="verifica" or mode=="tutte","Uso: verifica | tutte")
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

print("MEGAZERO PC54 | RECUPERO 12 | "..mode)
print("Controllo 40 agenti...")
local status,e1=exchange("STATUS",units,"DONE",30000)
outErrors(e1)
if count(status)~=40 then
 printError("STOP: rispondono "..count(status).."/40.")
 return
end
for _,t in ipairs(units) do
 local p=status[t.unit]
 local version=p.miner and p.miner.version or ""
 if p.agent_version~="1.16" or
  type(version)~="string" or
  not version:find("^%-%- MEGAZERO MINER v2%.3%.16") or
  p.miner_autostart~=false or
  p.current_status=="SCAVO" or p.current_status=="RIENTRO" then
  printError("STOP: "..t.unit.." non pronta: agente="..
   tostring(p.agent_version).." stato="..tostring(p.current_status))
  return
 end
end
print("40/40 agenti 1.16, miner 2.3.16, autostart OFF.")
print("Controllo posizione GPS e checkpoint...")
local audits,e2=exchange("RESET_AUDIT",units,"DONE",45000)
outErrors(e2)
if count(audits)~=40 then
 printError("STOP: audit "..count(audits).."/40.")
 return
end
local targetNames={
 "O02","O07","S04", -- BACK: rotazione gia registrata
 "N07","N06","O09","S03","S05","S07","S08","S09","E07" -- TURN
}
local targets={}
local missing,home=0,0
local included={}
for _,name in ipairs(targetNames) do included[name]=true end
for _,t in ipairs(units) do
 local p=audits[t.unit]
 local a=p and p.reset_audit
 if type(a)~="table" or not a.gps_ok or not a.cp_ok then
  printError("STOP: audit mancante/errato per "..t.unit)
  return
 end
 if a.ready_home==true then
  home=home+1
 else
  if not included[t.unit] then
   printError("STOP: nuova Turtle non HOME: "..t.unit)
   return
  end
  local gx,gy,gz=a.gps_x,a.gps_y,a.gps_z
  if math.abs(gx-a.saved_x)>0.25 or math.abs(gy-a.saved_y)>0.25
    or math.abs(gz-a.saved_z)>0.25 or
    type(a.path_count)~="number" or a.path_count<=0 or
    (a.pending~=nil and a.pending~="TURN" and a.pending~="BACK") then
   printError("STOP: "..t.unit.." GPS/traccia non riconciliabili")
   return
  end
  targets[t.unit]=t
 end
end
print("HOME: "..home.." | rientri richiesti: "..(40-home))
if mode=="verifica" then
 for _,name in ipairs(targetNames) do
  local t=targets[name]
  if t then
   local a=audits[name].reset_audit
   print(name.." PC"..t.id.." | pend "..tostring(a.pending)..
    " | path "..a.path_count.." | GPS=checkpoint")
  end
 end
 print("SOLO LETTURA. Per rientrare: parametro 'tutte'.")
 return
end
if home==40 then
 print("Tutte HOME. Nessun movimento necessario.")
 return
end
if 40-home>12 then
 printError("STOP: oltre 12 Turtle richiedono rientro")
 return
end
local started,done=0,0
local function recover(t)
 seq=seq+1
 local reqid="REC54-"..now().."-"..seq
 local p={kind="admin_request",version=1,site=SITE,
  target_unit=t.unit,target_computer_id=t.id,
  request_id=reqid,command="RECOVER_HOME",
  recovery_token="MEGAZERO_RIENTRO_12_CHECKPOINT"}
 rednet.send(t.id,p,PROTO) -- UNA sola trasmissione: MAI retry di movimenti
 print("Rientro "..t.unit.." PC"..t.id.." | richiesta inviata")
 local ack=false
 local deadline=now()+18000
 while now()<deadline do
  local sender,r=rednet.receive(PROTO,0.4)
  if sender==t.id and type(r)=="table" and
    r.kind=="admin_reply" and r.request_id==reqid and
    r.unit==t.unit and r.command=="RECOVER_HOME" then
   if r.phase=="RECOVERING" and r.accepted then
    ack=true;started=started+1;break
   end
   return false,tostring(r.reason or "Rientro negato")
  end
 end
 if not ack then
  return false,"ACK non ricevuto: NON ritentare, verificare la Turtle"
 end
 local untilTime=now()+1200000
 while now()<untilTime do
  local sender,r=rednet.receive(PROTO,1)
  if sender==t.id and type(r)=="table" and
    r.kind=="admin_reply" and r.request_id==reqid and
    r.unit==t.unit and r.command=="RECOVER_HOME" then
   if r.phase=="DONE" and r.accepted then
    return true,tostring(r.reason or "HOME confermata")
   elseif r.phase=="FAILED" then
    return false,tostring(r.reason or "Rientro interrotto")
   end
  end
 end
 return false,"Senza conferma finale; consultare GPS/checkpoint prima di ripetere"
end
for _,name in ipairs(targetNames) do
 local t=targets[name]
 if t then
  print("====================================")
  local ok,detail=recover(t)
  if ok then
   done=done+1
   print("HOME "..name.." | "..detail)
  else
   printError("FERMO "..name.." | "..detail)
   printError("Interrompo la sequenza. Nessun reset/avvio eseguito.")
   return
  end
 end
end
print("Rientri confermati: "..done.."/"..(40-home))
print("Verifico GPS finali delle 40 Turtle...")
local fin,e3=exchange("RESET_AUDIT",units,"DONE",45000)
outErrors(e3)
local allHome=0
for _,t in ipairs(units) do
 local p=fin[t.unit]
 if p and p.reset_audit and p.reset_audit.ready_home==true then
  allHome=allHome+1
 else
  printError("Non confermata HOME: "..t.unit)
 end
end
print("HOME GPS + checkpoint: "..allHome.."/40")
print("NESSUN RESET O AVVIO. Backup dei rientri su ciascuna Turtle.")
