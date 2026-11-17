-- MEGAZERO PC54 | CONTROLLA 40 TURTLE DOPO FERMA TUTTO | SOLA LETTURA
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
print("MEGAZERO PC54 | DIAGNOSI PRE-RIPARTENZA 40")
print("SOLO STATUS + GPS, NESSUN COMANDO DI SCAVO/STOP/RESET")
local status=query("STATUS")
local audit=query("RESET_AUDIT")
local total,safe,stuck,home,latched,active=0,0,0,0,0,0
local errors={}
for _,t in ipairs(units) do
 local p=status[t.unit]
 local a=audit[t.unit] and audit[t.unit].reset_audit
 if p then total=total+1 end
 if a and a.ready_home then home=home+1 end
 if p and p.error_latch and p.error_latch~="" then latched=latched+1 end
 if p and (p.current_status=="SCAVO" or p.current_status=="RIENTRO")
  then active=active+1 end
 if p and p.miner_autostart==false and a and a.ready_home and
   not (p.error_latch and p.error_latch~="") then safe=safe+1 end
 if not p or p.miner_autostart~=false or not a or not a.ready_home or
  (p.error_latch and p.error_latch~="") then
  stuck=stuck+1
  errors[#errors+1]=t.unit.." PC"..t.id..
   " | "..tostring(p and p.current_status or "NESSUN ACK")..
   " | auto="..tostring(p and p.miner_autostart)..
   " | HOME="..tostring(a and a.ready_home)..
   " | latch="..tostring(p and p.error_latch or "-"):sub(1,45)
 end
end
print("Risposte: "..total.."/40 | HOME GPS: "..home.."/40")
print("Autostart OFF + HOME + senza errore: "..safe.."/40")
print("LATCH: "..latched.." | SCAVO/RIENTRO: "..active)
print("Da risolvere: "..stuck)
for _,line in ipairs(errors) do print(line) end
print("FINE: nessuna Turtle modificata.")
