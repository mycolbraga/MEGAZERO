-- MEGAZERO | Test non invasivo: i GPS possono ascoltare telemetria Turtle?
-- Avvio su G1 con host GPS temporaneamente fermo; fine automatica.
-- Non trasmette nulla, non muove Turtle, non altera startup o canale GPS.
assert(not turtle,"Eseguire sul computer GPS, non sulla Turtle")
local modem=assert(peripheral.find("modem",function(_,m)
 return m.isWireless and m.isWireless()
end),"Ender/Wireless modem non trovato")
modem.open(54)
print("MEGAZERO GPS | PROVA PASSIVA")
print("Ascolto canale centrale 54, max 18 secondi.")
print("Nessun comando inviato alle Turtle.")
local seen={}
local n=0
local timer=os.startTimer(18)
while n<8 do
 local ev,side,channel,reply,p,distance=os.pullEvent()
 if ev=="timer" and side==timer then break end
 if ev=="modem_message" and channel==54 and
    type(p)=="table" and p.nRecipient==54 and
    p.sProtocol=="megazero.control.v1" and
    type(p.message)=="table" and
    p.message.kind=="status" and p.message.site=="MINIERA-01" and
    type(p.message.unit)=="string" and
    p.message.unit:match("^[NOSE]%d%d$") and not seen[p.message.unit] then
  seen[p.message.unit]=true;n=n+1
  print(p.message.unit.." | distanza: "..tostring(distance)..
   " | stato: "..tostring(p.message.status))
 end
end
modem.close(54)
print("RICEVUTE "..n.." TELEMETRIE.")
if n>0 then
 print("Se le distanze sono numeriche, e' possibile il GPS PASSIVO.")
else print("Nessuna telemetria rilevata: verificare portata/canale/host.") end
print("Esegui REBOOT su G1 per ripristinare il servizio gps host.")
