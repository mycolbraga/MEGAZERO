-- MEGAZERO | N01 tornata a mano: ARCHIVIO checkpoint incoerente e latch
-- NON muove, NON riavvia, NON modifica i programmi e NON avvia miner.
assert(turtle and os.getComputerID()==12,"Solo N01 (PC 12)")
local HOME_X,HOME_Y,HOME_Z=2119,-51,2995
local function read(path)
 local f=assert(fs.open(path,"r"),"File assente: "..path)
 local value=f.readAll()
 f.close()
 return value
end
local cfg=assert(textutils.unserialize(read("/megazero_config")),"Config invalida")
assert(cfg.site=="MINIERA-01" and cfg.unit=="N01" and
 cfg.miner_autostart==false,"N01/autostart non sicuro")
local boot=fs.exists("/megazero_boot") and "/megazero_boot" or "/megazero_boot.lua"
local miner=fs.exists("/megazero_miner") and "/megazero_miner" or "/megazero_miner.lua"
assert(read(boot):find("^%-%- MEGAZERO BOOT 1%.2"),"BOOT 1.2 richiesto")
assert(read(miner):find("^%-%- MEGAZERO MINER v2%.3%.6"),"MINER 2.3.6 richiesto")
local cp="/.megazero_miner_v23_N01_LAVORO"
local latch="/.megazero_miner_error"
assert(fs.exists(cp) and not fs.isDir(cp),"Checkpoint N01 atteso non presente")
local saved=assert(textutils.unserialize(read(cp)),"Checkpoint illeggibile")
assert(type(saved)=="table" and
 saved.x==HOME_X and saved.y==HOME_Y and saved.z==HOME_Z and saved.d==0 and
 type(saved.path)=="table" and #saved.path==0 and saved.pending=="STEP",
 "Checkpoint diverso dalla schermata: NON archivio")
assert(fs.exists(latch) and not fs.isDir(latch),"Latch errore atteso non presente")
-- Una sola verifica GPS durante RECUPERO. Il miner in lavoro NON dipende dal GPS.
print("Controllo UNA VOLTA la HOME con GPS (non muove)...")
local x,y,z=gps.locate(4,false)
assert(x and y and z,"GPS non disponibile: nessun file modificato")
local function near(a,b) return math.abs(a-b)<=0.25 end
assert(near(x,HOME_X) and near(y,HOME_Y) and near(z,HOME_Z),
 "GPS diverso dalla HOME: "..tostring(x)..","..tostring(y)..","..tostring(z))
print("HOME GPS CONFERMATA: "..x..","..y..","..z)
local files={
 {source=cp,archive="/.megazero_N01_checkpoint_manual_ARCHIVIO"},
 {source=latch,archive="/.megazero_N01_latch_manual_ARCHIVIO"}
}
local stamp=tostring(os.epoch("utc"))
for _,f in ipairs(files) do
 f.archive=f.archive.."_"..stamp
 assert(not fs.exists(f.archive),"Archivio gia' presente: "..f.archive)
end
-- Copia entrambi PRIMA di togliere un qualsiasi blocco.
for _,f in ipairs(files) do
 fs.copy(f.source,f.archive)
 assert(fs.exists(f.archive) and fs.getSize(f.archive)==fs.getSize(f.source) and
  read(f.archive)==read(f.source),"Backup non verificato: "..f.source)
end
for _,f in ipairs(files) do fs.delete(f.source) end
print("N01: checkpoint e latch ARCHIVIATI, NON cancellati definitivamente.")
print("Miner 2.3.6, BOOT 1.2 e autostart OFF invariati.")
print("Nessun movimento / nessun reboot. Pronta per test rientro controllato.")
