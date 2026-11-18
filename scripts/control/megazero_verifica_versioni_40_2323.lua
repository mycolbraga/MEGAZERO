-- MEGAZERO PC54 | AUDIT VERSIONI 40 MINER 2.3.23 AGENTE 1.22 | SOLA LETTURA
-- Diagnostica remoto via STATUS + RESET_AUDIT, non scrive sulle Turtle.
assert(not turtle and os.getComputerID()==54,"Solo centrale PC54")
local f=assert(fs.open("/.megazero_control_db","r"),"Registro centrale assente")
local db=assert(textutils.unserialize(f.readAll()),"Registro corrotto");f.close()
local units,seen={},{}
for _,side in ipairs({"N","O","S","E"}) do
 for i=1,10 do
  local name=side..string.format("%02d",i)
  local row=assert(db.units["MINIERA-01|"..name],"Manca "..name)
  local id=assert(row.sender,"PC sconosciuto "..name)
  assert(not seen[id],"ID duplicato PC"..id);seen[id]=true
  units[#units+1]={unit=name,id=id}
 end
end
local modem=peripheral.find("modem",function(_,m)
 return m.isWireless and m.isWireless()
end)
assert(modem,"Modem wireless non trovato")
rednet.open(peripheral.getName(modem))
local proto="megazero.admin.v1"
local seq=0
local function query(cmd)
 local pending,result={},{}
 for _,item in ipairs(units) do
  seq=seq+1
  local rid="CHK54-"..os.epoch("utc").."-"..seq
  local p={kind="admin_request",version=1,site="MINIERA-01",
   target_unit=item.unit,target_computer_id=item.id,
   request_id=rid,command=cmd}
  pending[rid]={unit=item.unit,id=item.id,p=p,tries=1,last=os.epoch("utc")}
  rednet.send(item.id,p,proto)
 end
 local deadline=os.epoch("utc")+35000
 while os.epoch("utc")<deadline do
  local id,p=rednet.receive(proto,0.3)
  if type(p)=="table" and p.kind=="admin_reply" and
   p.command==cmd and p.site=="MINIERA-01" then
   local j=pending[p.request_id]
   if j and j.id==id and p.unit==j.unit and
    p.computer_id==id then
    result[j.unit]=p;pending[p.request_id]=nil
   end
  end
  if not next(pending) then break end
  for _,j in pairs(pending) do
   if j.tries<3 and os.epoch("utc")-j.last>3000 then
    rednet.send(j.id,j.p,proto)
    j.last=os.epoch("utc");j.tries=j.tries+1
   end
  end
 end
 return result
end
print("MEGAZERO PC54 | VERIFICA HOME FISICA E CHECKPOINT 40")
print("SOLO STATUS + GPS, NESSUN COMANDO DI SCAVO/STOP/RESET")
local status=query("STATUS")
local audit=query("RESET_AUDIT")
local total,gpsHome,cpHome,stopped,latched,active=0,0,0,0,0,0
local versionsOK=0
local versionProblems={}
local problems={}
for _,t in ipairs(units) do
 local p=status[t.unit]
 local a=audit[t.unit] and audit[t.unit].reset_audit
 if p then total=total+1 end
 local miner=p and p.miner and p.miner.version
 local minerOK=type(miner)=="string" and
  miner:find("^%-%- MEGAZERO MINER v2%.3%.23")~=nil
 local agentOK=p and p.agent_version=="1.22"
 if minerOK and agentOK then
  versionsOK=versionsOK+1
 else
  versionProblems[#versionProblems+1]=t.unit.." PC"..t.id..
    " | miner="..tostring(miner or "NO STATUS")..
    " | agente="..tostring(p and p.agent_version or "NO STATUS")
 end
 if a and a.gps_home then gpsHome=gpsHome+1 end
 local cpOK=a and a.cp_ok and a.path_count==0 and
  a.pending==nil and a.saved_x==a.home_x and
  a.saved_y==a.home_y and a.saved_z==a.home_z and
  a.saved_d==a.home_d
 if cpOK then cpHome=cpHome+1 end
 if p and p.miner_autostart==false then stopped=stopped+1 end
 if p and p.error_latch and p.error_latch~="" then latched=latched+1 end
 if p and (p.current_status=="SCAVO" or p.current_status=="RIENTRO")
 then active=active+1 end
 if not p or not a or not a.gps_home or not cpOK or
  p.miner_autostart~=false or
  (p.error_latch and p.error_latch~="") then
  problems[#problems+1]=t.unit.." PC"..t.id..
   " | GPS="..tostring(a and a.gps_home)..
   " | CP="..tostring(cpOK==true)..
   " | PATH="..tostring(a and a.path_count)..
   " | AUTO="..tostring(p and p.miner_autostart)..
   " | LATCH="..tostring(p and p.error_latch and p.error_latch~="" or false)
 end
end
print("")
print("RIEPILOGO FISICO / CHECKPOINT:")
print("Risposte STATUS: "..total.."/40")
print("GPS HOME REALE: "..gpsHome.."/40")
print("CHECKPOINT HOME (percorso vuoto): "..cpHome.."/40")
print("AUTOSTART OFF: "..stopped.."/40")
print("ERRORI MEMORIZZATI: "..latched)
print("SCAVO/RIENTRO ATTIVI: "..active)
print("MINER 2.3.23 + AGENTE 1.22: "..versionsOK.."/40")
for _,v in ipairs(versionProblems) do printError(v) end
print("NON PRONTE: "..#problems)
for _,msg in ipairs(problems) do print(msg) end
print("FINE: SOLO LETTURA. Nessuna Turtle modificata.")
print("NOTA: fluidi 1.4 non verificabile via STATUS remoto.")
