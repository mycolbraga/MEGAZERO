-- MEGAZERO | N03 PC15 | Sblocco Regulator senza perdere checkpoint
-- Solo alla HOME: verifica identita', GPS, percorso, secchi e latch.
-- NON muove, non scava e non modifica il checkpoint.
assert(turtle and os.getComputerID()==15,"SOLO N03, PC 15")
local function read(p)
 local f=assert(fs.open(p,"r"),"Non posso leggere "..p)
 local data=f.readAll();f.close();return data
end
local cfg=assert(textutils.unserialize(read("/megazero_config")),
 "Configurazione non leggibile")
assert(cfg.site=="MINIERA-01" and cfg.unit=="N03",
 "Configurazione diversa da N03")
local minerPath=fs.exists("/megazero_miner") and "/megazero_miner"
 or "/megazero_miner.lua"
local miner=read(minerPath)
assert(miner:find("^%-%- MEGAZERO MINER v2%.3%.11") or
 miner:find("^%-%- MEGAZERO MINER v2%.3%.10"),
 "Miner non e' v2.3.10/2.3.11: STOP")
local cpPath="/.megazero_miner_v23_N03_LAVORO"
local cp=assert(textutils.unserialize(read(cpPath)),"Checkpoint non leggibile")
assert(type(cp)=="table" and cp.x==2115 and cp.y==-51 and cp.z==2995
 and cp.pending==nil and type(cp.path)=="table" and #cp.path==0
 and cp.finished~=true,
 "Checkpoint non HOME o movimento pendente: STOP")
local x,y,z=gps.locate(4,false)
assert(type(x)=="number" and type(y)=="number" and type(z)=="number",
 "GPS non disponibile: STOP")
local function near(a,b) return math.abs(a-b)<0.25 end
assert(near(x,2115) and near(y,-51) and near(z,2995),
 "N03 non alla HOME GPS: "..x..","..y..","..z)
local chest=assert(peripheral.wrap("top"),"Cassa superiore non disponibile")
assert(type(chest.list)=="function","Impossibile leggere cassa superiore")
local supply=assert(chest.list(),"Contenuto cassa non leggibile")
local topBuckets=0
for _,it in pairs(supply) do
 if it.name=="minecraft:bucket" then topBuckets=topBuckets+it.count end
end
local turtleBuckets=0
for i=1,16 do
 local item=turtle.getItemDetail(i)
 if item and item.name=="minecraft:bucket" then
  turtleBuckets=turtleBuckets+item.count
 end
end
assert(topBuckets+turtleBuckets>=3,
 "Regulator non pronto: "..topBuckets.." secchi in cassa + "..
 turtleBuckets.." nella Turtle (servono almeno 3)")
local latch="/.megazero_miner_error"
assert(fs.exists(latch),
 "Errore latch assente: non cancello niente e NON riavvio")
local err=read(latch)
assert(err:find("Regulator: mancano",1,true) or
 err:find("Scorta secchi insufficiente",1,true),
 "Latch differente: NON modifico. "..err:sub(1,140))
local base="/.megazero_N03_regulator_2311_latch_backup_"
local counter=1
while fs.exists(base..counter) and counter<100 do
 counter=counter+1
end
local backup=base..counter
assert(not fs.exists(backup),"Troppi backup, STOP")
fs.copy(latch,backup)
assert(read(backup)==err,"Backup errore non verificato: STOP")
print("N03 PC15: GPS "..x..","..y..","..z.." | CP HOME, 0 passi")
print("Secchi vuoti: cassa "..topBuckets.." + Turtle "..turtleBuckets)
print("Backup errore: "..backup)
fs.delete(latch)
assert(not fs.exists(latch),"Non posso cancellare il latch")
print("ERRORE REGULATOR SBLOCCATO; checkpoint invariato")
if cfg.miner_autostart==true then
 print("Autostart ON: reboot SOLO N03 e ripresa miner")
 os.reboot()
else
 print("Autostart OFF: N03 resta FERMA.")
 print("Esegui reboot, poi CHECK_START/ARM_START/START da centrale 54.")
end
