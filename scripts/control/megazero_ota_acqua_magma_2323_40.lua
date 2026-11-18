-- MEGAZERO | PC54 | OTA MAGMA + BOLLE: MINER 2.3.23 + AGENTE 1.22
-- La dashboard NON deve essere in esecuzione contemporaneamente.
-- Preflight 40/40 STATUS e GPS HOME; non invia START e non azzera checkpoint.
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

local RELEASE="b7af665d49f57a06e93ec8b8a8966b25d9ee8cf4"
local extra={
 release=RELEASE,package_version="2.3.23",
 fluid_version="1.4",agent_target_version="1.22"
}
print("MEGAZERO PC54 | OTA MAGMA+BOLLE 2.3.23 / FLUIDI 1.4 / AGENTE 1.22")
print("Autostart e miner non saranno attivati; nessun reset dei checkpoint.")
print("Controllo tutte le 40 Turtle...")
local before,e1=exchange("STATUS",units,"DONE",25000)
outErrors(e1)
if count(before)~=40 then
 printError("Mancano risposte: "..count(before).."/40. NON AGGIORNO.")
 return
end
local targets,needRestart={},{}
for _,t in ipairs(units) do
 local p=before[t.unit]
 local v=p.miner and p.miner.version or ""
 if type(v)~="string" then
  printError(t.unit.." miner assente");return
 end
 local old=v:find("^%-%- MEGAZERO MINER v2%.3%.21")
 local newer=v:find("^%-%- MEGAZERO MINER v2%.3%.23")
 if not old and not newer then
  printError(t.unit.." miner versione inattesa: "..v);return
 end
 if p.current_status=="SCAVO" or p.current_status=="RIENTRO" or
  p.miner_autostart==true then
  printError(t.unit.." in movimento/autostart attivo");return
 end
 if old and p.agent_version=="1.20" then
  targets[#targets+1]=t
 elseif newer and p.agent_version=="1.20" then
  needRestart[#needRestart+1]=t
 elseif newer and p.agent_version=="1.22" then
  -- Gia' aggiornata.
 else
  printError(t.unit.." versione miner/agente incoerente: "..
   v.."/"..tostring(p.agent_version))
  return
 end
end
-- Controllo GPS/checkpoint PRIMA di installare, senza scrivere nulla.
local homeAudit,homeErrors=exchange("RESET_AUDIT",units,"DONE",50000)
outErrors(homeErrors)
if count(homeAudit)~=40 then
 printError("AUDIT GPS incompleto: nessuna OTA installata.");return
end
local homeOK=0
for _,t in ipairs(units) do
 local a=homeAudit[t.unit] and homeAudit[t.unit].reset_audit
 if a and a.ready_home==true and a.path_count==0 and
  a.pending==nil and a.error_latched==false then
  homeOK=homeOK+1
 else
  printError("PRE-OTA "..t.unit..": non sicura alla HOME")
 end
end
print("GPS HOME + checkpoint preservati PRE-OTA: "..homeOK.."/40")
if homeOK~=40 then
 printError("PRE-OTA BLOCCATO: nessuna installazione.")
 return
end
print("Da aggiornare: "..#targets.." | da riavviare: "..#needRestart)
local succeeded={}
if #targets>0 then
 local checks,errors=exchange("CHECK_UPDATE",targets,"DONE",30000,extra)
 outErrors(errors)
 local ready=collect(checks,function(_,p) return p.update_allowed==true end)
 if #ready~=#targets then
  printError("Preflight OTA incompleto; nessuna installazione avviata.")
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
-- Riavvio SOLO le Turtle che hanno gia' la nuova versione.
local reboot={}
for _,t in ipairs(needRestart) do reboot[#reboot+1]=t end
for _,t in ipairs(targets) do
 if succeeded[t.unit] then reboot[#reboot+1]=t end
end
if #reboot>0 then
 print("RESTART_IDLE per "..#reboot.." agenti installati (NON miner)")
 local restarted,re=exchange("RESTART_IDLE",reboot,"RESTARTING",45000)
 outErrors(re)
 print("ACK reboot: "..count(restarted).."/"..#reboot)
end
if #reboot>0 then sleep(5) end
print("Verifico agenti caricati dalla nuova versione...")
local loaded,le=exchange("STATUS",units,"DONE",45000)
outErrors(le)
local newVersion=0
for _,t in ipairs(units) do
 local p=loaded[t.unit]
 if p and p.agent_version=="1.22" and
   p.miner and type(p.miner.version)=="string" and
   p.miner.version:find("^%-%- MEGAZERO MINER v2%.3%.23") then
   newVersion=newVersion+1
 else
  printError(t.unit.." non ancora 1.22/2.3.23: "..
   tostring(p and p.agent_version or "senza risposta"))
 end
end
print("MINER 2.3.23 / AGENTE 1.22: "..newVersion.."/40")
if newVersion~=40 then
 printError("AUDIT GPS RIMANDATO: aggiorna gli agenti mancanti.")
 print("NESSUNA TURTLE AVVIATA; CHECKPOINT INVARIATI.")
 return
end

print("Controllo GPS e checkpoint delle 40 Turtle...")
local audits,ae=exchange("RESET_AUDIT",units,"DONE",50000)
outErrors(ae)
local zero=0
for _,t in ipairs(units) do
 local p=audits[t.unit];local a=p and p.reset_audit
 if a and a.ready_home==true and a.path_count==0
  and a.pending==nil and a.error_latched==false then
  zero=zero+1
 else printError("STOP "..t.unit..": GPS HOME/checkpoint non confermati") end
end
print("GPS HOME + checkpoint preservati: "..zero.."/40")
if zero~=40 then printError("NON AVVIARE: checkpoint o HOME non confermati");return end
print("OTA 40/40 COMPLETATA. NESSUNO START O RESET ESEGUITO.")
print("OTA NON AVVIA SCAVI: controllare i blocchi dopo la ripartenza.")
print("Miner 2.3.23 gestisce magma_block e bubble_column.")
print("Versioni allineate: l'avvio resta un comando separato.")
