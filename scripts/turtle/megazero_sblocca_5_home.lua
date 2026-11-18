-- MEGAZERO | SBLOCCA SOLO 5 ERRORI ALLA HOME | NO RESET
-- N07 N08 N09 N10 S07, non muove le Turtle e non tocca il checkpoint.
assert(turtle,"Questo comando richiede una Turtle")
local function read(p)
 local h=fs.open(p,"r");if not h then return nil end
 local v=h.readAll();h.close();return v
end
local function write(p,v)
 local h=assert(fs.open(p,"w"),"Non posso scrivere "..p)
 h.write(v);h.close()
 assert(read(p)==v,"Verifica scrittura fallita: "..p)
end
local cfgPath="/megazero_config"
local raw=assert(read(cfgPath),"Configurazione mancante")
local cfg=assert(textutils.unserialize(raw),"Configurazione illeggibile")
local unit=cfg.unit
local expected={
 N07={x=2107,y=-51,z=2995,d=0},
 N08={x=2105,y=-51,z=2995,d=0},
 N09={x=2103,y=-51,z=2995,d=0},
 N10={x=2101,y=-51,z=2995,d=0},
 S07={x=2111,y=-51,z=3015,d=2}
}
local home=expected[unit]
assert(cfg.site=="MINIERA-01" and home,"Solo N07 N08 N09 N10 S07")
-- Identita verificata da config + GPS HOME, indipendentemente dall ID.
assert(cfg.miner_autostart==true or cfg.miner_autostart==false,
 "Autostart non leggibile")
local gx,gy,gz=gps.locate(4,false)
assert(type(gx)=="number" and type(gy)=="number" and type(gz)=="number"
 and math.abs(gx-home.x)<0.25 and math.abs(gy-home.y)<0.25
 and math.abs(gz-home.z)<0.25,"GPS NON HOME: STOP senza modifiche")
local cpPath="/.megazero_miner_v23_"..unit.."_LAVORO"
local cpRaw=assert(read(cpPath),"Checkpoint assente")
local cp=assert(textutils.unserialize(cpRaw),"Checkpoint illeggibile")
assert(cp.x==home.x and cp.y==home.y and cp.z==home.z and cp.d==home.d
 and type(cp.path)=="table" and #cp.path==0 and cp.pending==nil,
 "Checkpoint non HOME o percorso non vuoto: STOP")
local latch="/.megazero_miner_error"
local errorRaw=assert(read(latch),"Nessun errore da archiviare")
local known
if unit=="S07" then
 known=errorRaw:find("SIGILLO_SU_CELLA_2X2:LAVA:",1,true) and
  errorRaw:find("GALLERIA",1,true)
else
 known=errorRaw:find("Blocco non minerario sconosciuto: minecraft:amethyst_block",1,true)
  or errorRaw:find("Blocco non minerario sconosciuto: minecraft:budding_amethyst",1,true)
end
assert(known,"Causa errore diversa da quella registrata: STOP")
local minerHeader=(read("/megazero_miner") or ""):sub(1,90)
assert(minerHeader:find("^%-%- MEGAZERO MINER v2%.3%.23") or
 minerHeader:find("^%-%- MEGAZERO MINER v2%.3%.24"),
 "Versione miner inattesa: STOP")
local stamp="_"..unit.."_2327"
local cfgBak="/.megazero_sblocco_cfg"..stamp
local errBak="/.megazero_sblocco_error"..stamp
local stopBak="/.megazero_sblocco_stop"..stamp
local tmp="/.megazero_sblocco_cfg_tmp"
assert(not fs.exists(cfgBak) and not fs.exists(errBak) and
 not fs.exists(stopBak) and not fs.exists(tmp),
 "Backup sblocco esistente: STOP senza duplicare")
local altered={}
for k,v in pairs(cfg) do altered[k]=v end
altered.miner_autostart=false
local desired=textutils.serialize(altered)
assert(fs.getFreeSpace("/")>=#raw+#errorRaw+#desired+1024,
 "Spazio insufficiente per archiviare: NON modifico i checkpoint")
fs.copy(cfgPath,cfgBak)
assert(read(cfgBak)==raw,"Backup config non riuscito")
fs.copy(latch,errBak)
assert(read(errBak)==errorRaw,"Backup errore non riuscito")
write(tmp,desired)
fs.delete(cfgPath)
local ok,why=pcall(fs.move,tmp,cfgPath)
if not ok or read(cfgPath)~=desired then
 if fs.exists(cfgPath) then fs.delete(cfgPath) end
 fs.copy(cfgBak,cfgPath)
 error("Configurazione non aggiornata: "..tostring(why))
end
assert(read(cpPath)==cpRaw,"Checkpoint modificato: STOP")
local stop="/.megazero_stop_all.request"
if fs.exists(stop) then
 local old=assert(read(stop),"STOP marker illeggibile")
 write(stopBak,old)
 fs.delete(stop)
end
fs.delete(latch)
assert(not fs.exists(latch),"Latch non eliminato: STOP")
assert(read(cpPath)==cpRaw,"Checkpoint alterato dopo sblocco")
print(unit.." PC"..os.getComputerID()..": GPS HOME, AUTO OFF, errore archiviato")
print("Checkpoint immutato. Riavvio solo agente, NESSUNO SCAVO.")
sleep(1)
os.reboot()
