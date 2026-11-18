-- MEGAZERO PC54 | N02 PC14 | DIAGNOSI POSIZIONE INCERTA | SOLO LETTURA
-- Interroga soltanto STATUS + RESET_AUDIT via Rednet. Non muove nulla.
assert(not turtle and os.getComputerID()==54,"Eseguire SOLO su PC54")
local f=assert(fs.open("/.megazero_control_db","r"),"Registro centrale mancante")
local db=assert(textutils.unserialize(f.readAll()),"Registro centrale illeggibile")
f.close()
local rec=assert(db.units["MINIERA-01|N02"],"N02 assente dal registro")
assert(rec.sender==14,"N02 non risulta PC14: nessun comando")
local modem=peripheral.find("modem",function(_,m)
 return m.isWireless and m.isWireless()
end)
assert(modem,"Modem wireless assente")
rednet.open(peripheral.getName(modem))
local proto="megazero.admin.v1"
local function ask(cmd)
 local rid="N02-DIAG-"..os.epoch("utc").."-"..cmd
 local packet={kind="admin_request",version=1,site="MINIERA-01",
  target_unit="N02",target_computer_id=14,
  request_id=rid,command=cmd}
 rednet.send(14,packet,proto)
 local limit=os.epoch("utc")+14000
 while os.epoch("utc")<limit do
  local sender,p=rednet.receive(proto,0.3)
  if sender==14 and type(p)=="table" and p.kind=="admin_reply"
   and p.version==1 and p.site=="MINIERA-01" and p.unit=="N02"
   and p.computer_id==14 and p.request_id==rid and p.command==cmd then
   return p
  end
 end
end
local function xyz(x,y,z)
 return tostring(x)..","..tostring(y)..","..tostring(z)
end
print("MEGAZERO PC54 | SOLO N02 PC14 | DIAGNOSI READ-ONLY")
local stat=ask("STATUS")
local aud=ask("RESET_AUDIT")
if not stat then printError("N02 non risponde a STATUS");return end
print("STATUS N02: "..tostring(stat.current_status))
print("AGENTE: "..tostring(stat.agent_version))
print("MINER: "..tostring(stat.miner and stat.miner.version or "?"))
print("AUTOSTART: "..tostring(stat.miner_autostart))
print("LATCH: "..tostring(stat.error_latch or "ASSENTE"))
print("FUEL: "..tostring(stat.fuel))
if not aud or not aud.reset_audit then
 printError("N02 non risponde all'audit GPS/checkpoint")
 return
end
local a=aud.reset_audit
print("GPS OK: "..tostring(a.gps_ok).." | GPS HOME: "..tostring(a.gps_home))
print("GPS REALE: "..xyz(a.gps_x,a.gps_y,a.gps_z))
print("CHECKPOINT OK: "..tostring(a.cp_ok))
print("CP POS: "..xyz(a.saved_x,a.saved_y,a.saved_z))
print("CP DIREZIONE: "..tostring(a.saved_d))
print("CP PENDING: "..tostring(a.pending))
print("CP PATH: "..tostring(a.path_count))
print("CP LIV: "..tostring(a.level).." | DIST: "..tostring(a.distance))
print("READY HOME: "..tostring(a.ready_home))
print("FINE | NO START, STOP, RESET O SCRITTURE")
