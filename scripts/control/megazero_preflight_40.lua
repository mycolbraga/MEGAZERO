-- MEGAZERO / PC54 | PRE-FLIGHT 40 TURTLE | SOLA LETTURA
-- Interroga CHECK_START senza inviare ARM_START, START, reboot o OTA.
assert(not turtle and os.getComputerID()==54,"Avvia solo sulla centrale PC54")
local SITE="MINIERA-01"
local PROTO="megazero.admin.v1"
local f=assert(fs.open("/.megazero_control_db","r"),"Registro PC54 mancante")
local db=assert(textutils.unserialize(f.readAll()),"Registro PC54 illeggibile")
f.close()
assert(type(db.units)=="table","Unita non registrate")
local targets={}
for _,side in ipairs({"N","O","S","E"}) do
 for n=1,10 do
  local unit=side..string.format("%02d",n)
  local rec=db.units[SITE.."|"..unit]
  assert(type(rec)=="table" and type(rec.sender)=="number",
   "ID centrale assente per "..unit)
  targets[#targets+1]={unit=unit,pc=rec.sender}
 end
end
local modem=peripheral.find("modem",function(_,m)
 return m.isWireless and m.isWireless()
end)
assert(modem,"Modem wireless non trovato")
rednet.open(peripheral.getName(modem))
local now=os.epoch("utc")
local jobs,received={},{}
for i,t in ipairs(targets) do
 local id="SAFE54-"..now.."-"..i
 local packet={kind="admin_request",version=1,site=SITE,
  target_unit=t.unit,target_computer_id=t.pc,
  request_id=id,command="CHECK_START"}
 jobs[id]={unit=t.unit,pc=t.pc,packet=packet,attempt=1,last=os.epoch("utc")}
 rednet.send(t.pc,packet,PROTO)
end
local count=0
local deadline=os.epoch("utc")+20000
while count<40 and os.epoch("utc")<deadline do
 local sender,p=rednet.receive(PROTO,0.2)
 if sender and type(p)=="table" and p.kind=="admin_reply" and
    p.site==SITE and p.version==1 and p.command=="CHECK_START" then
  local j=jobs[p.request_id]
  if j and j.pc==sender and p.computer_id==sender and
     p.unit==j.unit and not received[j.unit] then
    received[j.unit]=p
    count=count+1
  end
 end
 local tick=os.epoch("utc")
 for _,j in pairs(jobs) do
  if not received[j.unit] and j.attempt<3 and tick-j.last>2800 then
   j.last=tick;j.attempt=j.attempt+1
   rednet.send(j.pc,j.packet,PROTO)
  end
 end
end
local lines={}
local function log(line) lines[#lines+1]=line or "" end
local function compact(s)
 return tostring(s or "?"):gsub("[%c]+"," "):gsub("%s+"," ")
end
local ready,denied,missing=0,0,0
local reasons,order={},{ }
for _,t in ipairs(targets) do
 local p=received[t.unit]
 local reason
 if not p then
  reason="Nessuna risposta CHECK_START"
  missing=missing+1
 elseif not p.accepted then
  reason="Richiesta rifiutata: "..compact(p.reason or p.phase)
  denied=denied+1
 elseif p.start_allowed==true then
  ready=ready+1
 else
  reason=compact(p.start_reason or "Blocco senza causa")
  denied=denied+1
 end
 if reason then
  if not reasons[reason] then reasons[reason]={};order[#order+1]=reason end
  reasons[reason][#reasons[reason]+1]=t.unit
 end
end
log("MEGAZERO PRE-FLIGHT | SOLO VERIFICA")
log("Risposte: "..count.."/40")
log("Idonee ai controlli: "..ready.." (NON avviate)")
log("Bloccate: "..denied.." | Senza risposta: "..missing)
log("ATTENZIONE: CHECK_START NON verifica il GPS fisico.")
log("Nessun ARM_START, START, REBOOT o OTA inviato.")
log("")
log("CAUSE DI BLOCCO:")
table.sort(order)
if #order==0 then log("Nessun blocco segnalato") end
for _,reason in ipairs(order) do
 log(reason.." ("..#reasons[reason]..")")
 log("  "..table.concat(reasons[reason],", "))
end
log("")
log("DETTAGLIO 40 TURTLE:")
for _,t in ipairs(targets) do
 local p=received[t.unit]
 if not p then
  log(t.unit.." PC"..t.pc.." | NO ACK")
 else
  local cp=p.miner or {}
  local status=compact(p.current_status)
  local result
  if not p.accepted then
   result="ERRORE DI RISPOSTA"
  elseif p.start_allowed then
   result="TECNICAMENTE IDONEA (GPS NON CONFERMATO)"
  else
   result="BLOCCATA: "..compact(p.start_reason)
  end
  log(t.unit.." PC"..t.pc.." | "..status.." | "..result)
  log("  L"..tostring(cp.level or "?")..
   " dist="..tostring(cp.distance or "?")..
   " passi="..tostring(cp.path_count or "?")..
   " pending="..tostring(cp.pending))
 end
end
local report="/megazero_preflight_40.txt"
local of=fs.open(report,"w")
if of then of.write(table.concat(lines,"\n"));of.close() end
local w,h=term.getSize()
local wrapped={}
for _,line in ipairs(lines) do
 if line=="" then wrapped[#wrapped+1]=""
 else
  while #line>w do
   wrapped[#wrapped+1]=line:sub(1,w)
   line=line:sub(w+1)
  end
  wrapped[#wrapped+1]=line
 end
end
local step=math.max(1,h-3)
local pages=math.max(1,math.ceil(#wrapped/step))
local page=1
while true do
 term.clear();term.setCursorPos(1,1)
 print(("PRE-FLIGHT 40 | %d/%d"):format(page,pages))
 for i=(page-1)*step+1,math.min(page*step,#wrapped) do
  print(wrapped[i])
 end
 term.setCursorPos(1,h);term.clearLine()
 term.write("Invio=avanti P=indietro Q=esci")
 local cmd=read()
 if cmd=="q" or cmd=="Q" then break end
 if cmd=="p" or cmd=="P" then page=math.max(1,page-1)
 else page=math.min(pages,page+1) end
end
print("Report: "..report)
