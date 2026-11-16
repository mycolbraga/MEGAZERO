-- MEGAZERO | N01 verifica posizione REALE via GPS, sola lettura
-- NON ruota, NON avanza, NON scava e NON modifica il checkpoint.
assert(turtle,"Comando solo su Turtle")
local f=assert(fs.open("/megazero_config","r"),"Config assente")
local cfg=assert(textutils.unserialize(f.readAll()),"Config illeggibile");f.close()
assert(cfg.unit=="N01" and cfg.site=="MINIERA-01","Solo N01")
print("N01: controllo GPS, nessun movimento")
if not gps or type(gps.locate)~="function" then
 print("GPS: API non disponibile")
 return
end
local x,y,z=gps.locate(3,false)
if not x then
 print("GPS: nessun satellite GPS raggiungibile")
 print("Non posso certificare coordinate o direzione reale.")
 return
end
print("GPS REALE: "..x..","..y..","..z)
local checkpoint="/.megazero_miner_v23_N01_LAVORO"
if fs.exists(checkpoint) then
 local fp=assert(fs.open(checkpoint,"r"))
 local raw=fp.readAll();fp.close()
 local s=textutils.unserialize(raw)
 if type(s)=="table" then
  print("CHECKPOINT: "..tostring(s.x)..","..tostring(s.y)..","..tostring(s.z))
  print("PENDING: "..tostring(s.pending))
  print("COINCIDE: "..tostring(s.x==x and s.y==y and s.z==z))
 end
end
