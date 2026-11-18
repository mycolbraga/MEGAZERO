-- MEGAZERO | N01 / N02 | DIAGNOSI SIGILLI SALVATI | SOLO LETTURA
-- Non avvia miner, non scava, non muove, non modifica checkpoint.
assert(turtle,"Solo Turtle, non PC54")
local f=assert(fs.open("/megazero_config","r"),"Configurazione assente")
local cfg=assert(textutils.unserialize(f.readAll()),"Configurazione illeggibile")
f.close()
assert(cfg.site=="MINIERA-01" and
 (cfg.unit=="N01" or cfg.unit=="N02"),"Solo N01 e N02")
local id=os.getComputerID()
assert(id==(cfg.unit=="N01" and 12 or 14),"ID Turtle inatteso")
local path="/.megazero_miner_v23_"..cfg.unit.."_LAVORO"
local h=assert(fs.open(path,"r"),"Checkpoint assente")
local raw=h.readAll();h.close()
local cp=assert(textutils.unserialize(raw),"Checkpoint non valido")
assert(type(cp.seals)=="table" or cp.seals==nil,"Seals non leggibili")
local seals=cp.seals or {}
local water=cp.waterSeals or {}
local n,known,unknown=0,0,0
for key in pairs(seals) do
 n=n+1
 if water[key]==true then known=known+1 else unknown=unknown+1 end
end
local first={}
for key in pairs(seals) do first[#first+1]=key end
table.sort(first)
print("MEGAZERO "..cfg.unit.." PC"..id.." | SOLA LETTURA")
print("Quota/level: "..tostring(cp.level).." | distanza: "..tostring(cp.distance))
print("HOME path: "..tostring(type(cp.path)=="table" and #cp.path or "?"))
print("SIGILLI: "..n.." | ACQUA confermata: "..known.." | NON TIPIZZATI: "..unknown)
if cfg.unit=="N01" then
 local key="2118:-1:2964"
 print("TAPPO N01 "..key..": "..tostring(seals[key])..
  " | acqua="..tostring(water[key]==true))
end
print("SIGILLI (primi 8):")
for i=1,math.min(8,#first) do
 local k=first[i]
 print(k.." = "..tostring(seals[k]).." | acqua="..tostring(water[k]==true))
end
local susp=cp.incomplete or {}
local levels={}
for k in pairs(susp) do levels[#levels+1]=k end
table.sort(levels)
print("GALLERIE SOSPESE: "..#levels)
for i=1,math.min(3,#levels) do
 local e=susp[levels[i]]
 print("Liv "..levels[i].." | "..tostring(e and e.lastError or "?"):sub(1,130))
end
print("FINE. Checkpoint e mondo NON modificati.")
