-- MEGAZERO N03 PC15 - DIAGNOSTICA CASSA, sola lettura
-- NON sposta oggetti, NON modifica file, NON avvia miner e NON muove la Turtle
assert(turtle and os.getComputerID()==15,"Solo N03, PC 15")
local f=assert(fs.open("/megazero_config","r"))
local raw=f.readAll();f.close()
local cfg=assert(textutils.unserialize(raw),"Config illeggibile")
assert(cfg.site=="MINIERA-01" and cfg.unit=="N03","Non e' N03")
print("=== N03 PC15 | DIAGNOSTICA SLOT (SOLO LETTURA) ===")
local chest=assert(peripheral.wrap("top"),"Cassa sopra assente")
assert(type(chest.list)=="function" and type(chest.size)=="function",
 "Cassa sopra non ispezionabile")
local items=assert(chest.list(),"Cassa sopra illeggibile")
local used,free,buckets,lava=0,0,0,0
print("CASSA SOPRA: "..chest.size().." slot")
for i=1,chest.size() do
 local it=items[i]
 if it then
  used=used+1
  if it.name=="minecraft:bucket" then buckets=buckets+it.count end
  if it.name=="minecraft:lava_bucket" then lava=lava+it.count end
  print("SOPRA "..i..": "..it.count.." x "..it.name)
 else free=free+1 end
end
print("SOPRA slot pieni "..used.." liberi "..free..
 " | secchi vuoti "..buckets.." | lava "..lava)
local tb,tl,tf=0,0,0
for i=1,16 do
 local it=turtle.getItemDetail(i)
 if it then
  if it.name=="minecraft:bucket" then tb=tb+it.count end
  if it.name=="minecraft:lava_bucket" then tl=tl+it.count end
  print("TURTLE "..i..": "..it.count.." x "..it.name)
 else tf=tf+1 end
end
print("TURTLE liberi "..tf.." | secchi vuoti "..tb.." | lava "..tl)
local cp="/.megazero_miner_v23_N03_LAVORO"
if fs.exists(cp) then
 local h=fs.open(cp,"r");local data=h.readAll();h.close()
 local ok,state=pcall(textutils.unserialize,data)
 if ok and type(state)=="table" then
  print("CP: lvl="..tostring(state.level).." dist="..
   tostring(state.distance).." pending="..tostring(state.pending)..
   " passi="..tostring(type(state.path)=="table" and #state.path or "?"))
  print("CP POS: "..tostring(state.x)..","..tostring(state.y)..","..tostring(state.z))
 else print("CHECKPOINT NON LEGGIBILE") end
else print("CHECKPOINT ASSENTE") end
local x,y,z=gps.locate(3,false)
print("GPS: "..tostring(x)..","..tostring(y)..","..tostring(z))
local lat="/.megazero_miner_error"
if fs.exists(lat) then
 local h=fs.open(lat,"r");local s=h.readAll();h.close()
 print("ERRORE SALVATO: "..tostring(s))
else print("ERRORE LATCH: assente") end
print("AUTOSTART: "..tostring(cfg.miner_autostart))
print("=== FINE: NON HO MODIFICATO NULLA ===")
