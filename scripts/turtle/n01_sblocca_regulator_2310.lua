-- MEGAZERO N01: riavvio protetto dopo errore Regulator senza secchi vuoti
-- Questo script non muove la Turtle. Controlla GPS + checkpoint + 3 secchi.
-- Solo N01 PC12. Cancella latch SOLO se e' l'errore Regulator previsto.
assert(turtle and os.getComputerID()==12,"Eseguire soltanto su N01 PC12")
local function read(p)
 local f=assert(fs.open(p,"r"),"Impossibile leggere "..p)
 local s=f.readAll(); f.close(); return s
end
local cfg=assert(textutils.unserialize(read("/megazero_config")),
 "Configurazione N01 illeggibile")
assert(cfg.site=="MINIERA-01" and cfg.unit=="N01",
 "Configurazione non corrispondente a N01")
assert(cfg.miner_autostart==true,
 "Avvio automatico disabilitato: STOP. Serve verifica configurazione")
local miner=fs.exists("/megazero_miner") and "/megazero_miner"
 or "/megazero_miner.lua"
assert(read(miner):find("^%-%- MEGAZERO MINER v2%.3%.10"),
 "Miner non v2.3.10: STOP")
local cpPath="/.megazero_miner_v23_N01_LAVORO"
local cp=assert(textutils.unserialize(read(cpPath)),
 "Checkpoint N01 non leggibile")
assert(type(cp)=="table" and cp.x==2119 and cp.y==-51 and cp.z==2995 and
 cp.pending==nil and type(cp.path)=="table" and #cp.path==0 and
 cp.finished~=true,"Checkpoint non alla HOME, pending o lavoro completato: STOP")
local x,y,z=gps.locate(4,false)
assert(type(x)=="number" and type(y)=="number" and type(z)=="number",
 "GPS N01 non disponibile: STOP, non cancello errori")
assert(math.abs(x-2119)<0.25 and math.abs(y+51)<0.25 and
 math.abs(z-2995)<0.25,
 "GPS N01 diverso dalla HOME: STOP")
local chest=assert(peripheral.wrap("top"),"Cassa superiore non disponibile")
assert(type(chest.list)=="function","Cassa sopra non leggibile")
local contents=assert(chest.list(),"Cassa superiore illeggibile")
local empty=0
for _,item in pairs(contents) do
 if item.name=="minecraft:bucket" then empty=empty+item.count end
end
local inTurtle=0
for i=1,16 do
 local it=turtle.getItemDetail(i)
 if it and it.name=="minecraft:bucket" then
  inTurtle=inTurtle+it.count
 end
end
assert(empty+inTurtle>=3,
 "Regulator non ancora pronto: "..empty.." secchi vuoti nella cassa e "..
 inTurtle.." nella Turtle. Ne servono 3 totali.")
local latch="/.megazero_miner_error"
local hasLatch=fs.exists(latch)
local errorText=hasLatch and read(latch) or nil
if hasLatch then
 assert(errorText:find("Regulator: mancano",1,true) or
        errorText:find("Scorta secchi insufficiente",1,true),
  "Errore diverso dal Regulator, NON cancello: "..errorText:sub(1,130))
 local bak="/.megazero_N01_regulator_latch_2310_backup"
 assert(not fs.exists(bak),"Backup errore gia' presente: STOP")
 fs.copy(latch,bak)
 assert(read(bak)==errorText,"Backup dell'errore non valido")
end
print("N01 GPS HOME: "..x..","..y..","..z)
print("Checkpoint: HOME, percorso 0, pending=nil.")
print("Secchi vuoti: "..empty.." in cassa + "..inTurtle.." nella Turtle.")
if hasLatch then
 fs.delete(latch)
 print("Blocco errore Regulator archiviato e cancellato.")
else
 print("Nessun blocco errore sul disco.")
end
print("Riavvio soltanto N01 per riprendere lo scavo.")
os.reboot()
