-- MEGAZERO N02 PC14 | RECUPERO OTA LOW-SPACE | NESSUNA COPIA DEL CHECKPOINT
-- Usa solo i 4 moduli staged gia' scaricati. Backup reversibile dei programmi.
-- NON elimina backup precedenti, checkpoint, configurazione o log di errore.
assert(turtle and os.getComputerID()==14,"Solo N02 PC14, NON la centrale")
local function read(p)
 local h=fs.open(p,"r")
 if not h then return nil end
 local v=h.readAll()
 h.close()
 return v
end
local function header(p)
 local h=fs.open(p,"r")
 if not h then return nil end
 local s=h.readLine();h.close()
 return s
end
local cfgRaw=assert(read("/megazero_config"),"Config mancante")
local cfg=assert(textutils.unserialize(cfgRaw),"Config illeggibile")
assert(cfg.site=="MINIERA-01" and cfg.unit=="N02" and
 cfg.miner_autostart==false,"N02 non disarmata: STOP")
local x,y,z=gps.locate(4,false)
assert(type(x)=="number" and type(y)=="number" and type(z)=="number"
 and math.abs(x-2117)<0.25 and math.abs(y+51)<0.25
 and math.abs(z-2995)<0.25,"GPS NON HOME: STOP")
local cpPath="/.megazero_miner_v23_N02_LAVORO"
local cpRaw=assert(read(cpPath),"Checkpoint originale mancante")
local cp=assert(textutils.unserialize(cpRaw),"Checkpoint illeggibile")
assert(cp.x==2117 and cp.y==-51 and cp.z==2995 and cp.d==0
 and type(cp.path)=="table" and #cp.path==0 and cp.pending==nil
 and not cp.finished,"Checkpoint NON HOME: STOP")
local errBefore=read("/.megazero_miner_error")
local marker="/.megazero_ota2316_state"
local mark=assert(textutils.unserialize(assert(read(marker),
 "Marker OTA assente")),"Marker OTA illeggibile")
local release="f6887ed109e0321c712a4a9785f94bbbeb56680e"
assert(mark.unit=="N02" and mark.release==release and
 mark.version=="2.3.21" and type(mark.items)=="table" and
 #mark.items==4,"Marker della release inatteso: STOP")
local names={"megazero_miner","megazero_fluidi","megazero_auto","megazero_admin_agent"}
local expected={"-- MEGAZERO MINER v2.3.21",
 "-- MEGAZERO FLUIDI v1.3",
 "-- MEGAZERO | Gestione avvio automatico",
 "-- MEGAZERO ADMIN AGENT v1.20"}
local old={"-- MEGAZERO MINER v2.3.19",
 "-- MEGAZERO FLUIDI v1.2",
 "-- MEGAZERO | Gestione avvio automatico",
 "-- MEGAZERO ADMIN AGENT v1.19"}
local backupDir="/.megazero_ota2316_backup_N02_f6887ed109"
assert(fs.exists(backupDir) and fs.isDir(backupDir),
 "Backup parziale OTA assente: STOP")
for i,name in ipairs(names) do
 local stage="/.megazero_stage_2316_"..name
 local target="/"..name
 local backup=backupDir.."/"..name
 assert(not fs.exists(backup),"Il backup "..name.." esiste gia': STOP")
 assert(not fs.exists(target..".lua"),"Moduli .lua imprevisti: STOP")
 assert(header(target) and header(target):sub(1,#old[i])==old[i],
  "Versione installata inattesa: "..name)
 local data=assert(read(stage),"Staging mancante: "..name)
 assert(data:sub(1,#expected[i])==expected[i],
  "Versione staged inattesa: "..name)
 assert(mark.items[i] and mark.items[i].name==name and
  mark.items[i].prefix==expected[i],
  "Manifest staging non coerente: "..name)
 local compiled,why=load(data,"="..name)
 assert(compiled,"Lua non valido "..name..": "..tostring(why))
end
print("N02 PC14 | GPS/CP HOME OK | 4 file staged validi")
print("Spazio libero: "..tostring(fs.getFreeSpace("/")))
print("Installo con MOVE, non duplico il checkpoint.")
local moved={}
local good,reason=pcall(function()
 for i,name in ipairs(names) do
  local target="/"..name
  local stage="/.megazero_stage_2316_"..name
  local backup=backupDir.."/"..name
  fs.move(target,backup)
  moved[i]={target=target,stage=stage,backup=backup,installed=false}
  fs.move(stage,target)
  moved[i].installed=true
  assert(header(target):sub(1,#expected[i])==expected[i],
    "Verifica installazione fallita: "..name)
  print("INSTALLATO "..name)
 end
 assert(read(cpPath)==cpRaw,"Checkpoint modificato: STOP")
 assert(read("/megazero_config")==cfgRaw,"Config modificata: STOP")
 assert(read("/.megazero_miner_error")==errBefore,
  "File errore modificato: STOP")
end)
if not good then
 printError("ERRORE INSTALLAZIONE: "..tostring(reason))
 local rollbackOK=true
 for i=#moved,1,-1 do
  local v=moved[i]
  if fs.exists(v.target) then
   if not fs.exists(v.stage) then
    local ok=pcall(fs.move,v.target,v.stage)
    if not ok then rollbackOK=false end
   else
    rollbackOK=false
   end
  end
  if fs.exists(v.backup) and not fs.exists(v.target) then
   local ok=pcall(fs.move,v.backup,v.target)
   if not ok then rollbackOK=false end
  else
   rollbackOK=false
  end
 end
 printError("RIPRISTINO: "..(rollbackOK and "OK" or "VERIFICARE MANUALMENTE"))
 printError("N02 NON AVVIATA. Marker e checkpoint conservati.")
 return
end
fs.delete(marker)
assert(not fs.exists(marker),"Marker OTA ancora presente")
print("N02 AGGIORNATA | miner 2.3.21 fluidi 1.3 agente 1.20")
print("Checkpoint e vecchi programmi conservati, nessuno scavo.")
print("Riavvio senza autostart.")
sleep(1)
os.reboot()
