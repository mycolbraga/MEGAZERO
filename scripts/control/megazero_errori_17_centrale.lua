-- MEGAZERO PC54 | Report dei blocchi attuali: sola lettura, Rednet STATUS.
-- NON invia START, reboot, OTA; NON modifica checkpoint o config.
assert(not turtle and os.getComputerID()==54,
 "Esegui SOLO sulla centrale PC54")
local SITE="MINIERA-01"
local PROTO="megazero.admin.v1"
local file=assert(fs.open("/.megazero_control_db","r"),
 "Registro centrale non disponibile")
local db=assert(textutils.unserialize(file.readAll()),
 "Registro centrale corrotto")
file.close()
assert(type(db.units)=="table","Tabella Turtle assente")
local all={}
for _,side in ipairs({"N","O","S","E"}) do
 for i=1,10 do
  local name=side..string.format("%02d",i)
  local rec=db.units[SITE.."|"..name]
  assert(type(rec)=="table" and type(rec.sender)=="number",
   "ID centrale mancante: "..name)
  all[#all+1]={name=name,id=rec.sender}
 end
end
local modem=peripheral.find("modem",function(_,m)
 return m.isWireless and m.isWireless()
end)
assert(modem,"Modem wireless mancante")
rednet.open(peripheral.getName(modem))
local start=os.epoch("utc")
local jobs,results={},{}
for i,t in ipairs(all) do
 local rid="ERR54-"..start.."-"..i
 local pkt={kind="admin_request",version=1,site=SITE,
  target_unit=t.name,target_computer_id=t.id,
  request_id=rid,command="STATUS"}
 jobs[rid]={name=t.name,id=t.id,pkt=pkt,last=start,tries=1}
 rednet.send(t.id,pkt,PROTO)
end
local received=0
local deadline=os.epoch("utc")+20000
while received<40 and os.epoch("utc")<deadline do
 local sender,p=rednet.receive(PROTO,0.2)
 if sender and type(p)=="table" and p.kind=="admin_reply" and
  p.version==1 and p.site==SITE and p.command=="STATUS" then
  local job=jobs[p.request_id]
  if job and job.id==sender and job.name==p.unit and
   p.computer_id==sender and not results[job.name] then
   results[job.name]=p
   received=received+1
  end
 end
 local now=os.epoch("utc")
 for _,job in pairs(jobs) do
  if not results[job.name] and job.tries<3 and
   now-job.last>2600 then
   job.last=now;job.tries=job.tries+1
   rednet.send(job.id,job.pkt,PROTO)
  end
 end
end
local function short(v)
 return tostring(v or ""):gsub("[%c]+"," "):gsub("%s+"," ")
end
local function home(unit)
 local side,n=unit:match("^([NOSE])(%d%d)$")
 n=tonumber(n)-1
 if side=="N" then return 2119-2*n,-51,2995
 elseif side=="O" then return 2099,-51,2995+2*n
 elseif side=="S" then return 2099+2*n,-51,3015
 else return 2119,-51,3015-2*n end
end
local groups={
 {title="POSIZIONE INCERTA: pending/checkpoint",items={}},
 {title="TRACCIA APERTA: rientro da verificare",items={}},
 {title="CHECKPOINT HOME, MA ERRORE PRESENTE",items={}},
 {title="CHECKPOINT/GPS DA VERIFICARE",items={}}
}
local nonresponding={}
local withoutLatch=0
for _,t in ipairs(all) do
 local p=results[t.name]
 if not p or not p.accepted then
  nonresponding[#nonresponding+1]=t.name
 elseif type(p.error_latch)=="string" and p.error_latch~="" then
  local cp=p.miner or {}
  local hx,hy,hz=home(t.name)
  local g
  if cp.pending then g=groups[1]
  elseif type(cp.path_count)=="number" and cp.path_count>0 then g=groups[2]
  elseif cp.saved_x==hx and cp.saved_y==hy and
   cp.saved_z==hz and cp.path_count==0 and cp.saved then
   g=groups[3]
  else g=groups[4] end
  g.items[#g.items+1]={unit=t.name,id=t.id,
   cp=cp,error=short(p.error_latch)}
 else
  withoutLatch=withoutLatch+1
 end
end
local total=0
for _,g in ipairs(groups) do total=total+#g.items end
local lines={}
local function add(line) lines[#lines+1]=line or "" end
add("MEGAZERO PC54 - ERRORI ATTUALI (SOLA LETTURA)")
add("Risposte STATUS: "..received.."/40")
add("Errori ancora registrati: "..total)
add("Senza errore registrato: "..withoutLatch)
add("Risposte assenti/rifiutate: "..#nonresponding)
add("La HOME qui e' solo salvata: GPS reale NON verificato.")
add("")
for _,g in ipairs(groups) do
 if #g.items>0 then
  local names={}
  for _,item in ipairs(g.items) do names[#names+1]=item.unit end
  add(g.title.." ("..#g.items..")")
  add(table.concat(names,", "))
  add("")
 end
end
if #nonresponding>0 then
 add("SENZA RISPOSTA: "..table.concat(nonresponding,", "))
 add("")
end
add("ERRORI INDIVIDUALI:")
for _,g in ipairs(groups) do
 for _,item in ipairs(g.items) do
  local cp=item.cp
  add(item.unit.." PC"..item.id.." L"..tostring(cp.level or "?")..
   " dist="..tostring(cp.distance or "?")..
   " passi="..tostring(cp.path_count or "?")..
   " pending="..tostring(cp.pending))
  add("  "..item.error)
  add("")
 end
end
add("NESSUN COMANDO DI AVVIO / MOVIMENTO INVIATO.")
local path="/megazero_errori_correnti_40.txt"
local out=fs.open(path,"w")
if out then out.write(table.concat(lines,"\n"));out.close() end
local w,h=term.getSize()
local view={}
for _,line in ipairs(lines) do
 if line=="" then view[#view+1]=""
 else
  while #line>w do
   view[#view+1]=line:sub(1,w)
   line=line:sub(w+1)
  end
  view[#view+1]=line
 end
end
local size=math.max(1,h-3)
local pages=math.max(1,math.ceil(#view/size))
local page=1
while true do
 term.clear();term.setCursorPos(1,1)
 print(("ERRORI ATTUALI | %d/%d"):format(page,pages))
 for i=(page-1)*size+1,math.min(page*size,#view) do print(view[i]) end
 term.setCursorPos(1,h);term.clearLine()
 term.write("Invio=avanti  P=indietro  Q=esci")
 local key=read()
 if key=="q" or key=="Q" then break
 elseif key=="p" or key=="P" then page=math.max(1,page-1)
 else page=math.min(pages,page+1) end
end
print("Rapporto: "..path)
