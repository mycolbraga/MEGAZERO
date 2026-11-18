-- MEGAZERO | O02 PC24 | DISARMA SOLO ERRORE BUBBLE_COLUMN HOME
-- Non scava, non si muove, non tocca altri checkpoint.
assert(turtle and os.getComputerID()==24,
 "SOLO O02 PC24")
local function read(p)
 local h=fs.open(p,"r")
 if not h then return nil end
 local v=h.readAll();h.close();return v
end
local function write(p,raw)
 local h=assert(fs.open(p,"w"),"Scrittura fallita "..p)
 h.write(raw);h.close()
 assert(read(p)==raw,"Verifica scrittura fallita "..p)
end
local cfgPath="/megazero_config"
local cfgRaw=assert(read(cfgPath),"Config assente")
local cfg=assert(textutils.unserialize(cfgRaw),"Config non leggibile")
local unit=cfg.unit
assert(cfg.site=="MINIERA-01" and
 (unit=="O02" and os.getComputerID()==24),
 "Identita PC/Turtle incoerente")
local hx,hy,hz=2099,-51,2997
local x,y,z=gps.locate(4,false)
assert(type(x)=="number" and type(y)=="number" and
 type(z)=="number" and math.abs(x-hx)<0.25 and
 math.abs(y-hy)<0.25 and math.abs(z-hz)<0.25,
 "GPS NON HOME: nessuna modifica")
local cpPath="/.megazero_miner_v23_"..unit.."_LAVORO"
local cpRaw=assert(read(cpPath),"Checkpoint mancante")
local cp=assert(textutils.unserialize(cpRaw),"Checkpoint illeggibile")
assert(cp.x==hx and cp.y==hy and cp.z==hz and cp.d==3
 and type(cp.path)=="table" and #cp.path==0 and
 cp.pending==nil and cp.finished~=true,
 "Checkpoint non HOME o percorso non vuoto: STOP")
local miner=assert(read("/megazero_miner"),"Miner mancante")
assert(miner:find("^%-%- MEGAZERO MINER v2%.3%.21"),
 "Miner non 2.3.21: STOP")
assert(cfg.miner_autostart==true,"Autostart non attivo: STOP")
local errPath="/.megazero_miner_error"
local errRaw=assert(read(errPath),"Nessun latch da archiviare")
assert(errRaw:find("Blocco non minerario sconosciuto: minecraft:bubble_column",1,true),
 "Errore diverso da bubble_column: STOP senza modifiche")
local stamp=unit.."_BOLLE2323"
local backupCfg="/.megazero_repair_cfg_"..stamp
local backupErr="/.megazero_repair_latch_"..stamp
local backupStop="/.megazero_repair_stop_"..stamp
local tmp=cfgPath..".magma2322.tmp"
assert(not fs.exists(backupCfg) and not fs.exists(backupErr)
 and not fs.exists(backupStop) and not fs.exists(tmp),
 "Backup/temporanei gia presenti: STOP")
local modified={}
for k,v in pairs(cfg) do modified[k]=v end
modified.miner_autostart=false
local newCfg=textutils.serialize(modified)
assert(fs.getFreeSpace("/")>=#newCfg+#cfgRaw+#errRaw+512,
 "Spazio insufficiente: STOP senza modifica")
write(tmp,newCfg)
fs.copy(cfgPath,backupCfg)
assert(read(backupCfg)==cfgRaw,"Backup config fallito")
fs.copy(errPath,backupErr)
assert(read(backupErr)==errRaw,"Backup errore fallito")
assert(read(cpPath)==cpRaw,"Checkpoint cambiato durante verifica: STOP")
-- Mantiene sempre un backup della configurazione per rollback.
fs.delete(cfgPath)
local moved,reason=pcall(fs.move,tmp,cfgPath)
if not moved or read(cfgPath)~=newCfg then
 if fs.exists(cfgPath) then fs.delete(cfgPath) end
 fs.copy(backupCfg,cfgPath)
 error("Config NON aggiornata: "..tostring(reason))
end
local check=assert(textutils.unserialize(read(cfgPath)))
assert(check.miner_autostart==false and check.unit==unit,
 "Autostart non spento: STOP")
assert(read(cpPath)==cpRaw,"Checkpoint alterato: STOP")
local stopPath="/.megazero_stop_all.request"
if fs.exists(stopPath) then
 local stopRaw=assert(read(stopPath),"Marker STOP non leggibile")
 write(backupStop,stopRaw)
 fs.delete(stopPath)
end
fs.delete(errPath)
assert(not fs.exists(errPath),"Latch non cancellato: STOP")
assert(read(cpPath)==cpRaw,"Checkpoint modificato: STOP")
print("OK "..unit.." PC"..os.getComputerID()..
 ": GPS HOME, autostart OFF, errore bolle archiviato")
print("CHECKPOINT INVARIATO. Nessuno scavo.")
sleep(1)
os.reboot()
