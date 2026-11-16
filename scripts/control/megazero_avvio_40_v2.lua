-- MEGAZERO | Avvio coordinato 40 Turtle da PC54 | v2.0 | BOOT 1.2 / MINER 2.3.6 / AGENTE 1.4
-- Eseguire con dashboard FERMA:
-- wget run <URL> verifica  => solo CHECK_START, NON MUOVE
-- wget run <URL> avvia     => CHECK_START, ARM_START, START delle 40
-- Non aggiorna software, non modifica posizioni, non altera il DB.
assert(not turtle and os.getComputerID()==54,"Questo comando richiede la CENTRALE PC 54")
local a={...}
local mode=a[1] or "verifica"
assert(mode=="verifica" or mode=="avvia","Uso: verifica oppure avvia")
local PROTOCOL="megazero.admin.v1"
local SITE="MINIERA-01"
local DB="/.megazero_control_db"
local function now() return os.epoch("utc") end
local function readFile(p)
 local f=assert(fs.open(p,"r"),"File mancante: "..p)
 local data=f.readAll();f.close();return data
end
local db=assert(textutils.unserialize(readFile(DB)),"Registro centrale non valido")
assert(type(db.units)=="table","Registro senza Turtle")
local units,seenID={},{}
for _,side in ipairs({"N","O","S","E"}) do
 for i=1,10 do
  local unit=side..string.format("%02d",i)
  local rec=db.units[SITE.."|"..unit]
  assert(type(rec)=="table","Manca nel registro: "..unit)
  assert(type(rec.sender)=="number","ID computer sconosciuto: "..unit)
  assert(not seenID[rec.sender],"ID duplicato: "..rec.sender)
  seenID[rec.sender]=true
  units[#units+1]={unit=unit,id=rec.sender,rec=rec}
 end
end
assert(#units==40,"Numero Turtle non valido")
local modem=peripheral.find("modem",function(_,m)
 return m.isWireless and m.isWireless()
end)
assert(modem,"Modem wireless centrale non presente")
rednet.open(peripheral.getName(modem))
print("MEGAZERO | CONTROLLO "..#units.." TURTLE")
print("Modalita': "..(mode=="verifica" and "VERIFICA (NON MUOVE)" or
 "AVVIO COORDINATO"))
local seq=0
local function request(t,command,extras)
 seq=seq+1
 local id="B54-"..tostring(now()).."-"..tostring(seq)
 assert(#id<=64,"ID richiesta troppo lungo")
 local msg={
  kind="admin_request",version=1,site=SITE,
  target_unit=t.unit,target_computer_id=t.id,
  request_id=id,command=command
 }
 if extras then for k,v in pairs(extras) do msg[k]=v end end
 return {req=msg,unit=t.unit,id=t.id, sentAt=0,tries=0}
end
local function issue(job)
 job.sentAt=now()
 job.tries=job.tries+1
 return rednet.send(job.id,job.req,PROTOCOL)
end
local function exchange(command,entries,timeoutMs,phase,extraFn,verifyFn)
 local jobs={}
 for _,t in ipairs(entries) do
  local extras=extraFn and extraFn(t) or nil
  local job=request(t,command,extras)
  jobs[job.req.request_id]=job
 end
 local initial=now()
 for _,job in pairs(jobs) do issue(job) end
 local remaining=#entries
 local results,errors={},{}
 while remaining>0 and now()-initial<timeoutMs do
  local sender,p=rednet.receive(PROTOCOL,0.15)
  if sender and type(p)=="table" and p.kind=="admin_reply" and
    p.site==SITE and p.version==1 and p.command==command then
   local job=jobs[p.request_id]
   if job and not job.done and job.id==sender and p.computer_id==sender
     and p.unit==job.unit then
    job.done=true
    remaining=remaining-1
    if p.accepted==true and p.phase==phase then
     local ok,reason=true,nil
     if verifyFn then ok,reason=verifyFn(p,job) end
     if ok then
      results[job.unit]=p
     else
      errors[#errors+1]=job.unit..": "..tostring(reason or "controllo risposta negato")
     end
    else
     errors[#errors+1]=job.unit..": "..tostring(p.reason or p.phase or "risposta negativa")
    end
   end
  end
  for _,job in pairs(jobs) do
   if not job.done and job.tries<3 and now()-job.sentAt>=2100 then
    issue(job)
   end
  end
 end
 for _,job in pairs(jobs) do
  if not job.done then
   errors[#errors+1]=job.unit..": nessuna conferma da PC "..job.id
  end
 end
 table.sort(errors)
 return results,errors,now()-initial
end
local function printErrors(errors)
 for _,e in ipairs(errors) do printError(e) end
end
local function checkResponse(p,job)
 if p.start_allowed~=true then
  return false,p.start_reason or "requisiti NON OK"
 end
 if p.agent_version~="1.4" then return false,"agente diverso da 1.4" end
 if type(p.boot_version)~="string" or
  not p.boot_version:find("^%-%- MEGAZERO BOOT 1%.2") then
  return false,"boot non v1.1"
 end
 if type(p.miner)~="table" or
  type(p.miner.version)~="string" or
  not p.miner.version:find("^%-%- MEGAZERO MINER v2%.3%.6") then
  return false,"miner non v2.3.5"
 end
 -- N01 ha gia' un checkpoint creato durante il collaudo Ctrl+T, con
 -- ritorno GPS HOME confermato. NON eliminarlo o iniziare da zero.
 -- Le altre 39 devono invece essere senza checkpoint per questa ripartenza.
 if p.miner.saved then
  if job.unit~="N01" then
   return false,"checkpoint inatteso su "..tostring(p.unit)..": non avvio"
  end
  if p.miner.checkpoint_invalid or p.miner.pending or p.miner.finished or
     p.miner.path_count~=0 or
     p.miner.saved_x~=2119 or p.miner.saved_y~=-51 or
     p.miner.saved_z~=2995 then
   return false,"N01: checkpoint non sicuro per riavvio dalla HOME"
  end
 end
 if p.error_latch and p.error_latch~="" then
  return false,"errore miner presente"
 end
 if p.miner_autostart~=false then
  return false,"avvio automatico gia' attivo"
 end
 if p.current_status~="PREPARAZIONE" and p.current_status~="BASE" then
  return false,"stato non fermo: "..tostring(p.current_status)
 end
 return true
end
print("Controllo requisiti IN DIRETTA su tutte le Turtle...")
local verified,errors=exchange("CHECK_START",units,13500,"DONE",nil,checkResponse)
if #errors>0 then
 printError("CONTROLLO NON SUPERATO: "..#errors.." problemi. ZERO avvii inviati.")
 printErrors(errors)
 return
end
print("REQUISITI OK: 40/40, miner v2.3.6, agente v1.4.")
print("N01: eventuale checkpoint HOME controllato; altre 39: nessun checkpoint.")
if mode=="verifica" then
 print("VERIFICA COMPLETATA. NESSUNA TURTLE AVVIATA.")
 print("Per avviarle, usa lo stesso comando con argomento: avvia")
 return
end
-- La conferma esplicita e' il comando "avvia" digitato dall'operatore.
-- Il protocollo delle Turtle da' 20s per confermare ARM_START.
-- Se gli ARM non si completano abbastanza velocemente, NON inviare alcun START.
print("ARM_START sulle 40 Turtle (senza movimento)...")
local armed,armErrors,armTime=exchange("ARM_START",units,8000,"ARMED",nil,
 function(p)
  if type(p.arm_id)~="string" or p.arm_id=="" then
   return false,"token armamento mancante"
  end
  return true
 end)
if #armErrors>0 then
 printError("ARMAMENTO INCOMPLETO: "..#armErrors.." problemi. NESSUNO START inviato.")
 printErrors(armErrors)
 return
end
if armTime>12000 then
 printError("ARM troppo lento: NESSUNO START inviato.")
 return
end
print("ARM 40/40 OK. Invio START coordinato.")
-- START: non ritentare automaticamente se manca l'ACK.
-- Un ACK perso non equivale a mancato avvio.
local sent,sendErrors={},{}
local pending={}
for _,t in ipairs(units) do
 local token=armed[t.unit].arm_id
 local job=request(t,"START",{arm_id=token})
 pending[job.req.request_id]=job
 local ok=issue(job)
 if ok then sent[#sent+1]=t.unit
 else sendErrors[#sendErrors+1]=t.unit..": Rednet invio fallito" end
end
local ack,negatives={},{}
local untilAt=now()+14000
while now()<untilAt do
 local sender,p=rednet.receive(PROTOCOL,0.15)
 if sender and type(p)=="table" and p.kind=="admin_reply" and
   p.site==SITE and p.version==1 and p.command=="START" then
  local job=pending[p.request_id]
  if job and not job.done and job.id==sender and
    p.unit==job.unit and p.computer_id==sender then
   job.done=true
   if p.accepted==true and p.phase=="STARTING" then
    ack[job.unit]=true
   else
    negatives[#negatives+1]=job.unit..": "..tostring(p.reason or p.phase)
   end
  end
 end
end
local n=0
for _ in pairs(ack) do n=n+1 end
print("RISPOSTE STARTING: "..n.."/40")
print("STARTING indica autorizzazione e reboot, NON scavo gia' confermato.")
if #sendErrors>0 then printErrors(sendErrors) end
if #negatives>0 then printErrors(negatives) end
if n<40 then
 printError("AVVIO PARZIALE/INCERTO: alcune Turtle potrebbero gia' scavare.")
 printError("NON rilanciare il comando 'avvia'. Controlla lo stato dalla dashboard.")
else
 print("40 STARTING ricevuti: riapri la dashboard e verifica SCAVO.")
end
