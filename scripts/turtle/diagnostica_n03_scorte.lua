-- MEGAZERO N03 | Diagnostica SCORTE solo lettura
-- NON scava, non muove, non aggiorna, non riavvia e non cancella errori.
assert(turtle and os.getComputerID()==15,
 "Questa diagnostica e' SOLO per N03 (PC15)")
local function read(p)
 if not fs.exists(p) then return nil end
 local f=assert(fs.open(p,"r"));local s=f.readAll();f.close();return s
end
local cfg=assert(textutils.unserialize(read("/megazero_config") or ""),
 "Config non valida")
assert(cfg.site=="MINIERA-01" and cfg.unit=="N03",
 "Identificativo diverso da N03")
print("=== N03 | SCORTE | SOLO LETTURA ===")
print("AUTOSTART: "..tostring(cfg.miner_autostart))
print("FUEL: "..tostring(turtle.getFuelLevel()).."/"..
 tostring(turtle.getFuelLimit()))
local er=read("/.megazero_miner_error")
print("ERRORE SALVATO: "..tostring(er or "ASSENTE"))
local cp="/.megazero_miner_v23_N03_LAVORO"
local raw=read(cp)
if not raw then
 print("CHECKPOINT: ASSENTE")
else
 local ok,s=pcall(textutils.unserialize,raw)
 if not ok or type(s)~="table" then print("CHECKPOINT: NON LEGGIBILE")
 else
  print("CHECKPOINT: lvl "..tostring(s.level).." dist "..
   tostring(s.distance).." pending "..tostring(s.pending))
  print("POS: "..tostring(s.x)..","..tostring(s.y)..","..tostring(s.z))
  print("TRACCIA: "..tostring(type(s.path)=="table" and #s.path or "?")..
   " | FINITO: "..tostring(s.finished))
  local incomplete=0
  if type(s.incomplete)=="table" then
   for _ in pairs(s.incomplete) do incomplete=incomplete+1 end
  end
  print("GALLERIE SOSPESE: "..incomplete)
 end
end
local ok,x,y,z=pcall(gps.locate,2,false)
if ok and type(x)=="number" then
 print("GPS: "..x..","..y..","..z)
else print("GPS: NON DISPONIBILE") end
local filled,empties,buckets,lava=0,0,0,0
local listing={}
for i=1,16 do
 local v=turtle.getItemDetail(i)
 if v then
  filled=filled+1
  if v.name=="minecraft:bucket" then buckets=buckets+v.count end
  if v.name=="minecraft:lava_bucket" then lava=lava+v.count end
  listing[#listing+1]=i..":"..v.count.."x"..v.name
 else empties=empties+1 end
end
print("TURTLE SLOT USATI: "..filled.."/16; LIBERI: "..empties)
print("TURTLE SECCHI VUOTI: "..buckets.."; LAVA: "..lava)
for _,v in ipairs(listing) do print(v) end
local top=peripheral.wrap("top")
if top and type(top.list)=="function" then
 local b,l,other=0,0,0
 local t=top.list()
 for _,v in pairs(t) do
  if v.name=="minecraft:bucket" then b=b+v.count
  elseif v.name=="minecraft:lava_bucket" then l=l+v.count
  else other=other+v.count end
 end
 print("CASSA SOPRA: secchi vuoti "..b..", lava "..l..", altri "..other)
else print("CASSA SOPRA: NON LEGGIBILE") end
local bottom=peripheral.wrap("bottom")
if bottom and type(bottom.list)=="function" then
 local t=bottom.list();local occupied=0
 for _ in pairs(t) do occupied=occupied+1 end
 print("CASSA SOTTO: slot occupati "..occupied)
else print("CASSA SOTTO: NON LEGGIBILE") end
print("=== FINE | N03 NON MOSSA ===")