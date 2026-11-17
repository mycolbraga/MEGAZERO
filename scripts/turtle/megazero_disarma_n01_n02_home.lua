-- MEGAZERO | DISARMA N01 N02 DA HOME | ERRORI ARCHIVIATI | NO SCAVO
-- Uso dalla SHELL della Turtle: wget run <url>
-- SOLO N01 PC12 e N02 PC14 | GPS HOME + checkpoint verificati | non modifica i sigilli
assert(turtle,"Eseguire SOLO sulla Turtle in errore, NON sulla PC54")
local function read(path)
 local f=fs.open(path,"r")
 if not f then return nil end
 local data=f.readAll();f.close();return data
end
local function write(path,data)
 local f=assert(fs.open(path,"w"),"Scrittura fallita: "..path)
 f.write(data);f.close()
 assert(read(path)==data,"Verifica dati fallita: "..path)
end
local cfgPath="/megazero_config"
local cfgRaw=assert(read(cfgPath),"Config mancante")
local cfg=assert(textutils.unserialize(cfgRaw),"Config non valida")
local unit=cfg.unit
assert(cfg.site=="MINIERA-01" and
 (unit=="N01" or unit=="N02"),
 "SOLO N01/N02: nessuna modifica")
assert(os.getComputerID()==(unit=="N01" and 12 or 14),
 "PC diverso da quello registrato: nessuna modifica")
local side,n=unit:match("^([NO])(%d%d)$")
n=tonumber(n)
local hx,hy,hz,d
if side=="N" then hx,hy,hz,d=2119-2*(n-1),-51,2995,0
else hx,hy,hz,d=2099,-51,2995+2*(n-1),3 end
local x,y,z=gps.locate(4,false)
assert(type(x)=="number" and type(y)=="number" and
 type(z)=="number" and math.abs(x-hx)<0.25 and
 math.abs(y-hy)<0.25 and math.abs(z-hz)<0.25,
 "GPS NON HOME: nessuna modifica")
local cpPath="/.megazero_miner_v23_"..unit.."_LAVORO"
local cpRaw=assert(read(cpPath),"Checkpoint mancante")
local cp=assert(textutils.unserialize(cpRaw),"Checkpoint illeggibile")
assert(cp.x==hx and cp.y==hy and cp.z==hz and cp.d==d and
 type(cp.path)=="table" and #cp.path==0 and cp.pending==nil and
 cp.finished~=true,
 "Checkpoint non HOME o percorso non vuoto: nessuna modifica")
local miner=assert(read("/megazero_miner"),"Miner mancante")
assert(miner:find("^%-%- MEGAZERO MINER v2%.3%.19"),
 "Versione miner inattesa: nessuna modifica")
local errPath="/.megazero_miner_error"
local errRaw=assert(read(errPath),"Errore non presente")
assert(errRaw:find("GALLERIA SOSPESA",1,true) and
 errRaw:find("GALLERIA_INCOMPLETA:",1,true),
 "Non e' una galleria sospesa: nessuna modifica")
assert(cfg.miner_autostart==true or cfg.miner_autostart==false,
 "Stato autostart ambiguo: nessuna modifica")
print(unit.." PC"..os.getComputerID().." | GPS HOME | checkpoint OK")
print("Disarmo e archivio errore. Sigilli, quota e checkpoint intatti.")
local stamp=unit.."_DISARMO2321"
local bakCfg="/.megazero_repair_cfg_"..stamp
local bakErr="/.megazero_repair_latch_"..stamp
local temp="/.megazero_repair_cfg_new"
assert(not fs.exists(temp),"Config temporanea preesistente: STOP")
assert(not fs.exists(bakErr),"Backup errore precedente esistente: STOP")
assert(not fs.exists(bakCfg),"Backup config precedente esistente: STOP")
fs.copy(cfgPath,bakCfg)
assert(read(bakCfg)==cfgRaw,"Backup config fallito")
fs.copy(errPath,bakErr)
assert(read(bakErr)==errRaw,"Backup errore fallito")
if cfg.miner_autostart==true then
 cfg.miner_autostart=false
 local newCfg=textutils.serialize(cfg)
 write(temp,newCfg)
 fs.delete(cfgPath)
 local ok,reason=pcall(fs.move,temp,cfgPath)
 if not ok or read(cfgPath)~=newCfg then
  pcall(function() if fs.exists(cfgPath) then fs.delete(cfgPath) end
    fs.copy(bakCfg,cfgPath) end)
  error("Config non aggiornata: "..tostring(reason))
 end
end
local persisted=assert(textutils.unserialize(read(cfgPath)),
 "Config non leggibile dopo modifica")
assert(persisted.miner_autostart==false and
 persisted.unit==unit and persisted.site=="MINIERA-01",
 "AUTOSTART NON SPENTO: non cancello il latch")
assert(read(cpPath)==cpRaw,"Checkpoint cambiato: STOP")
-- Soltanto dopo conferma autostart OFF e checkpoint immutato.
fs.delete(errPath)
assert(not fs.exists(errPath),"Errore non rimosso: STOP")
local stopPath="/.megazero_stop_all.request"
if fs.exists(stopPath) then
 local stopData=read(stopPath)
 if stopData and not fs.exists("/.megazero_repair_stop_"..stamp) then
  write("/.megazero_repair_stop_"..stamp,stopData)
 end
 fs.delete(stopPath)
end
assert(read(cpPath)==cpRaw,"Checkpoint modificato inaspettatamente")
print("OK "..unit..": autostart OFF; errore archiviato, non risolto.")
print("Checkpoint INVARIATO. Nessuno scavo/rientro.")
print("Riavvio agente di rete senza avviare il miner.")
sleep(1)
os.reboot()
