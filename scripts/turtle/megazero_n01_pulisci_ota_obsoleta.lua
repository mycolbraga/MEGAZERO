-- MEGAZERO | N01 | RIPARAZIONE SPAZIO OTA | SOLO FILE TEMPORANEI
-- Non tocca checkpoint, configurazione, backup reset/rientri o miner.
assert(turtle,"Eseguire sulla Turtle N01")
local function read(p)
 local f=assert(fs.open(p,"r"),"File obbligatorio mancante: "..p)
 local raw=f.readAll();f.close();return raw
end
local cfg=assert(textutils.unserialize(read("/megazero_config")),"Config invalida")
assert(cfg.unit=="N01" and cfg.site=="MINIERA-01" and
 cfg.miner_autostart==false,"N01 non ferma con autostart OFF")
local cpPath="/.megazero_miner_v23_N01_LAVORO"
local cpRaw=read(cpPath)
local cp=assert(textutils.unserialize(cpRaw),"Checkpoint invalido")
assert(type(cp.path)=="table" and #cp.path==0 and cp.pending==nil
 and cp.x==2119 and cp.y==-51 and cp.z==2995 and cp.d==0
 and cp.level==1 and cp.distance==0,
 "Checkpoint non azzerato/HOME: non cancello nulla")
local x,y,z=gps.locate(4,false)
assert(type(x)=="number" and math.abs(x-2119)<0.25 and
 type(y)=="number" and math.abs(y+51)<0.25 and
 type(z)=="number" and math.abs(z-2995)<0.25,
 "GPS non HOME: nessuna cancellazione")
local function header(name)
 local f=assert(fs.open("/"..name,"r"),"Manca "..name)
 local h=f.readLine();f.close();return h or ""
end
assert(header("megazero_miner"):find("^%-%- MEGAZERO MINER v2%.3%.16"),
 "Miner non 2.3.16: non cancello nulla")
assert(header("megazero_fluidi"):find("^%-%- MEGAZERO FLUIDI v1%.1"),
 "Fluidi non 1.1: non cancello nulla")
assert(header("megazero_admin_agent"):find("^%-%- MEGAZERO ADMIN AGENT v1%.16"),
 "Agente non 1.16: non cancello nulla")
local function free()
 local v=fs.getFreeSpace("/")
 return type(v)=="number" and v or math.huge
end
local function bytes(path)
 if not fs.exists(path) then return 0 end
 if not fs.isDir(path) then return fs.getSize(path) end
 local total=0
 for _,entry in ipairs(fs.list(path)) do
  total=total+bytes(fs.combine(path,entry))
 end
 return total
end
print("N01 | Pulizia soltanto OTA obsoleta")
print("Spazio iniziale: "..tostring(free()))
local freed,n=0,0
local function remove(name)
 local path="/"..name
 if not fs.exists(path) then return end
 local b=bytes(path)
 fs.delete(path)
 assert(not fs.exists(path),"Cancellazione non riuscita: "..path)
 freed=freed+b;n=n+1
 print("Vecchio OTA: "..name.." ("..b.." B)")
end
-- Risultati del commit fallito: N01 e' confermata ancora alle vecchie versioni.
-- Il marker impedirebbe il prossimo PREPARE_UPDATE: rimuoverlo insieme allo staging.
for _,name in ipairs(fs.list("/")) do
 if name==".megazero_ota2316_state" or
    name:match("^%.megazero_stage_2316_") or
    name:match("^%.megazero_ota_backup_235_") or
    name:match("^%.megazero_ota_backup_2316_") then
  remove(name)
 end
end
-- Conserva i backup reset/rientro; elimina copie OTA vecchie solo finche'
-- serve spazio per staging + backup della nuova release.
local old={}
for _,name in ipairs(fs.list("/")) do
 if name:match("^%.megazero_ota2316_backup_N01_[0-9a-f]+$") then
  old[#old+1]=name
 end
end
table.sort(old)
for _,name in ipairs(old) do
 if free()>=220000 then break end
 remove(name)
end
if fs.exists("/megazero_config.ota2316.tmp") then
 remove("megazero_config.ota2316.tmp")
end
assert(read(cpPath)==cpRaw,"Checkpoint modificato: fermo!")
assert(cfg.miner_autostart==false,"Autostart inatteso")
print("Backup reset e recupero NON toccati.")
print("File OTA rimossi: "..n.." | Byte liberati: "..freed)
print("Spazio disponibile: "..tostring(free()))
if free()<180000 then
 printError("SPAZIO ANCORA INSUFFICIENTE: NON RILANCIARE OTA")
else
 print("N01 pronta a RIPROVARE OTA da PC54; nessun movimento/scavo.")
end
