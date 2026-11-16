-- MEGAZERO | GPS host + rilevamento passivo Turtle v1.0
-- Quattro host GPS restano attivi; inoltra solo misure di telemetria al PC54.
-- NON invia comandi alle Turtle. Nessun impatto sul miner.
local args={...}
local unit=args[1]
local COORDS={
 G1={2097,108,2713},G2={2100,108,2713},
 G3={2100,108,2716},G4={2100,111,2716}
}
local here=assert(COORDS[unit],"Specificare G1, G2, G3 oppure G4")
assert(not turtle,"Solo computer GPS")
local modem=assert(peripheral.find("modem",function(_,m)
 return m.isWireless and m.isWireless()
end),"Ender Modem non disponibile")
local modemName=peripheral.getName(modem)
rednet.open(modemName)
modem.open(54)  -- Canale della telemetria indirizzata alla centrale.
local total=0
local function monitor()
 print("MEGAZERO GPS PASSIVO | "..unit.." | ascolto Turtle PC54")
 while true do
  local ev,side,chan,reply,frame,distance=os.pullEvent("modem_message")
  if side==modemName and chan==54 and
    type(distance)=="number" and distance==distance and distance>=0 and
    type(frame)=="table" and frame.nRecipient==54 and
    type(frame.nSender)=="number" and
    type(frame.nMessageID)=="number" and
    frame.sProtocol=="megazero.control.v1" and
    type(frame.message)=="table" then
    local m=frame.message
    if m.kind=="status" and m.version==1 and
      m.site=="MINIERA-01" and type(m.unit)=="string" and
      m.unit:match("^[NOSE]%d%d$") then
      local report={
       kind="gps_range",version=1,anchor=unit,unit=m.unit,
       turtle_id=frame.nSender,frame_id=frame.nMessageID,
       distance=distance,x=here[1],y=here[2],z=here[3]
      }
      if type(m.x)=="number" and type(m.y)=="number" and
        type(m.z)=="number" then
       report.miner_x=m.x;report.miner_y=m.y;report.miner_z=m.z
      end
      rednet.send(54,report,"megazero.gps.passive.v1")
      total=total+1
      if total%40==0 then
        print(unit..": "..total.." misure inoltrate alla centrale 54")
      end
    end
  end
 end
end
local function host()
 print("Host GPS "..unit.." = "..table.concat(here,","))
 -- ROM CC:Tweaked standard: mantiene l'host gps sulle sue porte.
 assert(shell.run("gps","host",here[1],here[2],here[3]),
  "gps host terminato senza successo")
 error("gps host terminato inaspettatamente")
end
parallel.waitForAny(host,monitor)
