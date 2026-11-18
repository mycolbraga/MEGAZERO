-- MEGAZERO N06 PC18 | RIPRENDI DOPO MOVEMENT OBSTRUCTED | NO RESET
-- Solo dalla HOME di N06. Checkpoint immutato; altre 39 intatte.
assert(turtle and os.getComputerID()==18,"SOLO N06 PC18")
local function read(p)
 local h=fs.open(p,"r")
 if not h then return nil end
 local v=h.readAll();h.close();return v
end
local cfgRaw=assert(read("/megazero_config"),"Config mancante")
local cfg=assert(textutils.unserialize(cfgRaw),"Config illeggibile")
assert(cfg.site=="MINIERA-01" and cfg.unit=="N06","Identita non N06")
assert(cfg.miner_autostart==true,"Autostart NON attivo: stop")
local miner=assert(read("/megazero_miner"),"Miner mancante")
assert(miner:find("^%-%- MEGAZERO MINER v2%.3%.21"),
 "Versione miner diversa, stop")
local cpPath="/.megazero_miner_v23_N06_LAVORO"
local cpRaw=assert(read(cpPath),"Checkpoint mancante")
local cp=assert(textutils.unserialize(cpRaw),"Checkpoint illeggibile")
assert(cp.x==2109 and cp.y==-51 and cp.z==2995 and cp.d==0
 and type(cp.path)=="table" and #cp.path==0 and cp.pending==nil,
 "Checkpoint N06 non HOME, nessuna modifica")
local x,y,z=gps.locate(4,false)
assert(type(x)=="number" and type(y)=="number" and type(z)=="number"
 and math.abs(x-2109)<0.25 and math.abs(y+51)<0.25
 and math.abs(z-2995)<0.25,"GPS non HOME, nessuna modifica")
local err="/.megazero_miner_error"
local raw=assert(read(err),"Errore non presente")
assert(raw:find("Movement obstructed",1,true) and
 raw:find("Turtle bloccata:",1,true),
 "Errore diverso da Movement obstructed: stop")
assert(not fs.exists("/.megazero_stop_all.request"),
 "STOP ALL ancora presente, nessuna ripartenza")
local base="/.megazero_n06_blocco_movimento_"
local i=1
while fs.exists(base..i) and i<100 do i=i+1 end
assert(i<100 and not fs.exists(base..i),"Archivi errori pieni")
assert(read(cpPath)==cpRaw and read("/megazero_config")==cfgRaw,
 "Checkpoint o config cambiati")
fs.move(err,base..i)
assert(read(base..i)==raw,"Errore non archiviato correttamente")
assert(read(cpPath)==cpRaw,"Checkpoint modificato: non riparto")
print("N06 GPS HOME | CHECKPOINT CONSERVATO")
print("Errore di movimento archiviato in "..base..i)
print("Riavvio N06 per ritentare; 39 Turtle NON toccate.")
sleep(1)
os.reboot()
