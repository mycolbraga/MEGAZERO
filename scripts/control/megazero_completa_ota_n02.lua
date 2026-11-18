-- MEGAZERO PC54 | COMPLETA OTA ESISTENTE SOLO N02 PC14 | NO START / RESET
-- Preflight: agente 1.19, miner 2.3.19, staged 2.3.21, autostart OFF, GPS HOME.
assert(not turtle and os.getComputerID()==54,"Usare SOLO PC54")
local f=assert(fs.open("/.megazero_control_db","r"),"Database centrale assente")
local db=assert(textutils.unserialize(f.readAll()),"Database illeggibile")
f.close()
local rec=assert(db.units["MINIERA-01|N02"],"N02 non registrata")
assert(rec.sender==14,"ID N02 diverso da PC14: STOP")
local wireless=peripheral.find("modem",function(_,m)
 return m.isWireless and m.isWireless()
end)
assert(wireless,"Modem wireless mancante")
rednet.open(peripheral.getName(wireless))
local PROTO="megazero.admin.v1"
local seq=0
local function request(cmd,timeout,extra)
 seq=seq+1
 local rid="N02OTA-"..os.epoch("utc").."-"..seq
 local packet={kind="admin_request",version=1,site="MINIERA-01",
  target_unit="N02",target_computer_id=14,
  request_id=rid,command=cmd}
 if extra then for k,v in pairs(extra) do packet[k]=v end end
 rednet.send(14,packet,PROTO)
 local deadline=os.epoch("utc")+(timeout or 12000)
 while os.epoch("utc")<deadline do
  local sender,p=rednet.receive(PROTO,0.3)
  if sender==14 and type(p)=="table" and
   p.kind=="admin_reply" and p.version==1 and
   p.site=="MINIERA-01" and p.unit=="N02" and
   p.computer_id==14 and p.request_id==rid and p.command==cmd then
   return p
  end
 end
 return nil
end
local function needed(cmd,timeout,extra)
 local p=request(cmd,timeout,extra)
 assert(p,cmd.." senza risposta: nessuna altra azione automatica")
 assert(p.accepted==true and p.phase=="DONE",
  cmd.." negato: "..tostring(p.reason or p.phase))
 return p
end
print("N02 PC14 | RIPRESA OTA GIA' SCARICATA | NO SCAVO")
local status=needed("STATUS",14000)
local version=status.miner and status.miner.version or ""
assert(status.agent_version=="1.19" and
 type(version)=="string" and
 version:find("^%-%- MEGAZERO MINER v2%.3%.19"),
 "Versioni N02 inattese: "..tostring(status.agent_version).."/"..tostring(version))
assert(status.miner_autostart==false and
 status.current_status~="SCAVO" and status.current_status~="RIENTRO" and
 (not status.error_latch or status.error_latch==""),
 "N02 ancora attiva o in errore: STOP")
local a=needed("RESET_AUDIT",14000).reset_audit
assert(a and a.ready_home==true and a.path_count==0 and
 a.pending==nil and a.error_latched==false,
 "GPS/checkpoint non pronti: STOP")
local check=needed("CHECK_UPDATE",14000)
assert(check.update_allowed==true and check.staged==true,
 "OTA staged assente o aggiornamento vietato: "..tostring(check.block_reason))
print("GPS HOME, checkpoint, versioni e staging: OK")
print("COMMIT_UPDATE N02 senza nuovi download...")
local commit=request("COMMIT_UPDATE",90000)
assert(commit,"COMMIT inviato ma nessun ACK. NON RIPETERE: verifica lo stato.")
assert(commit.accepted==true and commit.phase=="DONE",
 "COMMIT fallito: "..tostring(commit.reason or commit.phase))
print("COMMIT N02 ACK. Moduli installati: "..tostring(commit.installed))
local restart=request("RESTART_IDLE",25000)
assert(restart,"COMMIT OK, ma nessun ACK di riavvio: verifica N02.")
assert(restart.accepted==true and restart.phase=="RESTARTING",
 "COMMIT OK, reboot negato: "..tostring(restart.reason or restart.phase))
print("Riavvio agente N02 confermato.")
sleep(5)
local newstatus=request("STATUS",40000)
if not newstatus or not newstatus.accepted then
 printError("N02 riavviata ma STATUS non disponibile: verificare piu' tardi.")
 return
end
local v=newstatus.miner and newstatus.miner.version or ""
local ok=newstatus.agent_version=="1.20" and type(v)=="string" and
 v:find("^%-%- MEGAZERO MINER v2%.3%.21")
print("N02 aggiornata 1.20 / miner 2.3.21: "..(ok and "SI" or "NO"))
print("Nessuna Turtle avviata. Checkpoint mai modificato da questo script.")
