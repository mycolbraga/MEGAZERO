-- MEGAZERO PC54 | AVVIA SOLO N02 PC14 | MINER 2.3.21 | NO RESET
-- Non invia comandi alle altre Turtle. Stato, GPS, checkpoint, scorte verificati.
assert(not turtle and os.getComputerID()==54,"Eseguire SOLO su PC54")
local h=assert(fs.open("/.megazero_control_db","r"),"Registro PC54 mancante")
local db=assert(textutils.unserialize(h.readAll()),"Registro illeggibile");h.close()
local r=assert(db.units["MINIERA-01|N02"],"N02 non registrata")
assert(r.sender==14,"N02 non corrisponde al PC14: STOP")
local modem=peripheral.find("modem",function(_,m)
 return m.isWireless and m.isWireless()
end)
assert(modem,"Modem wireless non disponibile")
rednet.open(peripheral.getName(modem))
local proto="megazero.admin.v1"
local seq=0
local function request(cmd,expected,timeout,extras,retries)
 seq=seq+1
 local rid="N02-SOLO-"..os.epoch("utc").."-"..seq
 local p={kind="admin_request",version=1,site="MINIERA-01",
  target_unit="N02",target_computer_id=14,
  request_id=rid,command=cmd}
 for k,v in pairs(extras or {}) do p[k]=v end
 local sent=0
 local last=0
 local deadline=os.epoch("utc")+(timeout or 12000)
 while os.epoch("utc")<deadline do
  if sent< (retries or 1) and os.epoch("utc")-last>=2500 then
   rednet.send(14,p,proto)
   sent=sent+1;last=os.epoch("utc")
  end
  local sender,resp=rednet.receive(proto,0.25)
  if sender==14 and type(resp)=="table"
   and resp.kind=="admin_reply" and resp.version==1
   and resp.site=="MINIERA-01" and resp.unit=="N02"
   and resp.computer_id==14 and resp.request_id==rid
   and resp.command==cmd then
   assert(resp.accepted==true and resp.phase==expected,
    cmd.." respinto: "..tostring(resp.reason or resp.phase))
   return resp
  end
 end
 error(cmd.." senza ACK: nessun altro comando inviato automaticamente")
end
print("MEGAZERO PC54 | RIAVVIO SOLO N02 PC14")
print("Nessun reset, nessun comando alle altre 39.")
local st=request("STATUS","DONE",15000,nil,3)
local header=st.miner and st.miner.version or ""
assert(st.agent_version=="1.20" and type(header)=="string" and
 header:find("^%-%- MEGAZERO MINER v2%.3%.21"),
 "N02 versioni inattese: STOP")
assert(st.miner_autostart==false and
 (st.current_status=="PREPARAZIONE" or st.current_status=="BASE")
 and (not st.error_latch or st.error_latch==""),
 "N02 gia' attiva o in errore: STOP")
local aa=request("RESET_AUDIT","DONE",16000,nil,3).reset_audit
assert(aa and aa.ready_home==true and aa.gps_home==true and
 aa.cp_ok==true and aa.path_count==0 and aa.pending==nil and
 aa.error_latched==false and aa.level==1 and aa.distance==0,
 "N02 GPS / checkpoint HOME 0% non verificati: STOP")
local check=request("CHECK_START","DONE",16000,nil,3)
assert(check.start_allowed==true,
 "N02 non pronta: "..tostring(check.start_reason))
print("CHECK_START N02 OK | GPS HOME | checkpoint liv 1 dist 0")
local arm=request("ARM_START","ARMED",10000,nil,2)
assert(type(arm.arm_id)=="string","ARM ID mancante")
local started=request("START","STARTING",12000,
 {arm_id=arm.arm_id},1)
print("N02 PC14 STARTING confermato.")
print("Comando di avvio accettato; verificare SCAVO dalla dashboard.")
print("Altre 39 Turtle non toccate.")
