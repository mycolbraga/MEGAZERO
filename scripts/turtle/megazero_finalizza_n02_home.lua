-- MEGAZERO N02 PC14 | FINALIZZA ALLA HOME DOPO RIENTRO | NO MOVIMENTO
-- Risolve disco pieno senza perdere vecchio checkpoint, backup o progressi.
assert(turtle and os.getComputerID()==14,"SOLO N02 PC14")
local function read(p)
 local f=fs.open(p,"r")
 if not f then return nil end
 local v=f.readAll();f.close();return v
end
local function first(p)
 local f=fs.open(p,"r")
 if not f then return nil end
 local v=f.readLine();f.close();return v
end
local raw=assert(read("/megazero_config"),"Configurazione N02 assente")
local cfg=assert(textutils.unserialize(raw),"Configurazione illeggibile")
assert(cfg.unit=="N02" and cfg.site=="MINIERA-01","Identita' diversa")
local x,y,z=gps.locate(4,false)
assert(type(x)=="number" and type(y)=="number" and
 type(z)=="number" and math.abs(x-2117)<0.25 and
 math.abs(y+51)<0.25 and math.abs(z-2995)<0.25,
 "GPS non HOME: nessuna modifica")
local cpPath="/.megazero_miner_v23_N02_LAVORO"
local cpRaw=assert(read(cpPath),"Checkpoint N02 mancante")
local cp=assert(textutils.unserialize(cpRaw),"Checkpoint non leggibile")
assert(cp.x==2117 and cp.y==-51 and cp.z==2995 and cp.d==0
 and type(cp.path)=="table" and #cp.path==0 and
 cp.pending==nil and cp.level==1 and cp.distance==0,
 "Checkpoint nuovo non HOME 0%: STOP")
assert(fs.exists("/.megazero_n02_checkpoint_originale_salvato"),
 "Vecchio checkpoint non archiviato: STOP")
assert((first("/megazero_miner") or ""):find("^%-%- MEGAZERO MINER v2%.3%.21"),
 "Miner non 2.3.21")
assert((first("/megazero_admin_agent") or ""):find("^%-%- MEGAZERO ADMIN AGENT v1%.20"),
 "Agente non 1.20")
print("N02 GPS HOME + checkpoint nuovo OK")
print("LIBERI prima: "..tostring(fs.getFreeSpace("/")))
local base="/.megazero_ota2316_"
local suffixes={"backup_N02_f6887ed109","saved_N02_f6887ed109",
 "saved2_N02_f6887ed109"}
local candidates={}
for _,s in ipairs(suffixes) do
 local folder=base..s
 candidates[#candidates+1]={folder.."/megazero_admin_agent",
  "-- MEGAZERO ADMIN AGENT v1.19"}
 candidates[#candidates+1]={folder.."/megazero_miner",
  "-- MEGAZERO MINER v2.3.19"}
end
for _,item in ipairs(candidates) do
 if fs.getFreeSpace("/")>=8192 then break end
 local p,prefix=item[1],item[2]
 if fs.exists(p) and not fs.isDir(p) then
  local h=first(p) or ""
  if h:sub(1,#prefix)==prefix then
   fs.delete(p)
   print("Eliminata SOLTANTO vecchia copia software: "..p:match("[^/]+$"))
  end
 end
end
local updated={}
for k,v in pairs(cfg) do updated[k]=v end
updated.miner_autostart=false
local newRaw=textutils.serialize(updated)
assert(fs.getFreeSpace("/")>=#newRaw+512,
 "Spazio ancora insufficiente: config e checkpoint INVARIATI")
local path="/megazero_config"
local backup="/.megazero_n02_cfg_originale_salvata"
assert(not fs.exists(backup),"Backup configurazione preesistente: STOP")
fs.move(path,backup)
local h=fs.open(path,"w")
if not h then
 fs.move(backup,path)
 error("Scrittura config impossibile; originale ripristinata")
end
h.write(newRaw);h.close()
local saved=read(path)
if saved~=newRaw then
 if fs.exists(path) then fs.delete(path) end
 fs.move(backup,path)
 error("Verifica configurazione fallita; originale ripristinata")
end
local check=assert(textutils.unserialize(saved))
assert(check.miner_autostart==false and check.unit=="N02",
 "Configurazione autostart inattesa: STOP")
assert(read(cpPath)==cpRaw,"Checkpoint alterato: STOP")
local err="/.megazero_miner_error"
local errBackup="/.megazero_n02_errore_originale_salvato"
if fs.exists(err) then
 assert(not fs.exists(errBackup),"Archivio errore precedente esistente")
 fs.move(err,errBackup)
end
local stop="/.megazero_stop_all.request"
local stopBackup="/.megazero_n02_stop_originale_salvato"
if fs.exists(stop) then
 assert(not fs.exists(stopBackup),"Archivio STOP precedente esistente")
 fs.move(stop,stopBackup)
end
print("N02 SISTEMATA | HOME | AUTOSTART OFF")
print("Checkpoint nuovo 0%, vecchio checkpoint ARCHIVIATO.")
print("Nessun movimento, nessun intervento su altre Turtle.")
sleep(0.5)
os.reboot()
