-- MEGAZERO | Recupero N02 dalla HOME, installa miner 2.3.10 / agent 1.7
-- Funziona su N01 e sulle altre 39, SOLO A HOME FERMA.
-- Backup e verifica versioni; non muove, non scava, non riavvia.
assert(turtle and os.getComputerID()==14,"Programma SOLO N02, PC 14")
local RELEASE="0c5db788c8b897fe7be78a53c07ceaea0dc1b579"
local SOURCE="https://raw.githubusercontent.com/mycolbraga/MEGAZERO/"..
 RELEASE.."/scripts/turtle/"
local function read(path)
 local f=assert(fs.open(path,"r"),"Impossibile leggere "..path)
 local data=f.readAll();f.close();return data
end
local function write(path,body)
 local f=assert(fs.open(path,"w"),"Impossibile scrivere "..path)
 f.write(body);f.close()
 assert(read(path)==body,"Scrittura incompleta: "..path)
end
local function existing(name)
 if fs.exists("/"..name) then return "/"..name end
 if fs.exists("/"..name..".lua") then return "/"..name..".lua" end
 error("Modulo mancante: "..name,0)
end
local configPath="/megazero_config"
local cfg=assert(textutils.unserialize(read(configPath)),"Config non valida")
local unit=cfg.unit
local side,num
if type(unit)=="string" then side,num=unit:match("^([NOSE])(%d%d)$") end
num=tonumber(num)
assert(cfg.site=="MINIERA-01" and side and num and num>=1 and num<=10,
 "Questa non e' una Turtle del sito MINIERA-01")
assert(unit=="N02","Questa riparazione e' riservata a N02")
local n=num-1
local hx,hy,hz
if side=="N" then hx,hy,hz=2119-2*n,-51,2995
elseif side=="O" then hx,hy,hz=2099,-51,2995+2*n
elseif side=="S" then hx,hy,hz=2099+2*n,-51,3015
else hx,hy,hz=2119,-51,3015-2*n end
local boot=existing("megazero_boot")
assert(read(boot):find("^%-%- MEGAZERO BOOT 1%.2"),
 "BOOT diverso da 1.2, installazione bloccata")
local oldModules={
 {name="megazero_miner",before="-- MEGAZERO MINER v2.3.",
  after="-- MEGAZERO MINER v2.3.10"},
 {name="megazero_admin_agent",before="-- MEGAZERO ADMIN AGENT v1.",
  after="-- MEGAZERO ADMIN AGENT v1.7"},
 {name="megazero_auto",before="-- MEGAZERO | Gestione avvio automatico",
  after="-- MEGAZERO | Gestione avvio automatico"}
}
local allUpdated=true
for _,m in ipairs(oldModules) do
 m.path=existing(m.name)
 m.original=read(m.path)
 assert(m.original:sub(1,#m.before)==m.before,
  "Modulo sconosciuto, STOP: "..m.name)
 if m.original:sub(1,#m.after)~=m.after then allUpdated=false end
 if m.name=="megazero_auto" and
    not m.original:find("Miner non v2.3.10",1,true) then allUpdated=false end
end
if allUpdated then
 print(unit.." gia' aggiornata: miner 2.3.10, agente 1.7")
 print("Nessuna operazione. Stato autostart NON modificato.")
 return
end
-- Non interrompere Turtle impegnate: l'installer va avviato solo
-- DOPO rientro alla HOME e console libera.
local latchPath="/.megazero_miner_error"
local hasLatch=fs.exists(latchPath)
local latch=hasLatch and read(latchPath) or ""
local knownError=
 latch:find("Scorta secchi non ottenibile",1,true) or
 latch:find("Carburante pieno",1,true) or
 latch:find("spostare lava nello slot 1",1,true) or
 latch:find("slot 1 cassa lava",1,true) or
 latch:find("spostare materiale verso lo slot 1",1,true) or
 latch:find("portare il secchio nello slot 1",1,true) or
 latch:find("Slot Turtle esauriti durante prelievo secchi",1,true) or
 latch:find("Prelievo secchi dalla cassa fallito",1,true) or
 latch:find("Impossibile raggiungere i secchi vuoti",1,true)
if hasLatch then
 local recoveredPositionError =
    latch:find("Posizione fisica incerta dopo riavvio",1,true)
 assert(knownError or recoveredPositionError,
  "Errore non previsto per N02: "..latch:sub(1,140))
else
 assert(cfg.miner_autostart==false,
  "Autostart attivo senza errore: prima ferma la Turtle e torna alla HOME")
end
local cpPath="/.megazero_miner_v23_"..unit.."_LAVORO"
if fs.exists(cpPath) then
 local cp=assert(textutils.unserialize(read(cpPath)),"Checkpoint non leggibile")
 assert(type(cp)=="table" and type(cp.path)=="table" and
  cp.pending==nil and #cp.path==0 and
  cp.x==hx and cp.y==hy and cp.z==hz,
  "Checkpoint NON alla HOME / movimento pendente: nessuna modifica")
end
-- L'errore di posizione di N02 si puo' archiviare SOLO dopo
-- il rientro controllato documentato e la verifica GPS HOME.
assert(fs.exists(cpPath),"N02: checkpoint mancante, NON posso aggiornare")
assert(fs.exists("/.megazero_N02_rientro81_checkpoint_originale"),
 "Manca il backup dell'operazione di rientro: fermo")
assert(fs.exists("/.megazero_N02_calibrazione_info"),
 "Manca diagnostica/calibrazione: fermo")
local journal=read("/.megazero_N02_calibrazione_info")
assert(journal:find("OK | GPS ritorno",1,true),
 "Calibrazione non riuscita")
local x,y,z=gps.locate(4,false)
assert(type(x)=="number" and type(y)=="number" and type(z)=="number",
 "N02: GPS non disponibile, NON aggiorno")
assert(math.abs(x-hx)<0.25 and math.abs(y-hy)<0.25 and math.abs(z-hz)<0.25,
 "N02 NON alla HOME reale: "..tostring(x)..","..tostring(y)..","..tostring(z))
print("N02 GPS HOME confermata: "..x..","..y..","..z)
local chest=peripheral.wrap("top")
local below=peripheral.wrap("bottom")
assert(chest and type(chest.list)=="function" and
 below and type(below.list)=="function",
 "Casse sopra/sotto assenti: non garantita posizione HOME")
print("MEGAZERO "..unit.." | HOME checkpoint verificato se presente")
print("NUOVO: miner 2.3.10, agente 1.7, Regulator secchi vuoti")
-- Download e verifica di ogni sorgente PRIMA di modificare i moduli.
for _,m in ipairs(oldModules) do
 local response,reason=http.get(SOURCE..m.name..".lua")
 assert(response,"Download "..m.name.." fallito: "..tostring(reason))
 m.code=response.readAll();response.close()
 assert(m.code:sub(1,#m.after)==m.after,
  "Versione download errata: "..m.name)
 local compiled,err=load(m.code,"="..m.name)
 assert(compiled,"Codice non compilabile: "..m.name.." "..tostring(err))
end
local cfgNew={}
for key,value in pairs(cfg) do cfgNew[key]=value end
cfgNew.miner_autostart=false
local backup="/.megazero_regulator2310_backup_"..unit
assert(not fs.exists(backup),"Backup precedente presente: "..backup)
local tmpFiles={}
for _,m in ipairs(oldModules) do
 m.tmp="/.megazero_2310_tmp_"..m.name
 assert(not fs.exists(m.tmp),"Staging gia' esistente: "..m.tmp)
 tmpFiles[#tmpFiles+1]=m.tmp
end
local tmpConfig="/.megazero_2310_tmp_config"
assert(not fs.exists(tmpConfig),"Staging config gia' esistente")
for _,m in ipairs(oldModules) do write(m.tmp,m.code) end
write(tmpConfig,textutils.serialize(cfgNew))
fs.makeDir(backup)
for _,m in ipairs(oldModules) do
 fs.copy(m.path,backup.."/"..m.name)
 assert(read(backup.."/"..m.name)==m.original,
  "Backup non valido: "..m.name)
end
fs.copy(configPath,backup.."/megazero_config")
assert(read(backup.."/megazero_config")==read(configPath),"Backup config errato")
if hasLatch then
 fs.copy(latchPath,backup.."/megazero_miner_error")
 assert(read(backup.."/megazero_miner_error")==latch,"Backup errore errato")
end
if fs.exists(cpPath) then
 fs.copy(cpPath,backup.."/checkpoint")
 assert(read(backup.."/checkpoint")==read(cpPath),"Backup checkpoint errato")
end
-- Disabilita autostart PRIMA di sostituire i file, senza fare reboot.
fs.delete(configPath)
fs.move(tmpConfig,configPath)
local good,reason=pcall(function()
 for _,m in ipairs(oldModules) do
  fs.delete(m.path)
  fs.move(m.tmp,m.path)
  assert(read(m.path)==m.code,"Verifica installazione fallita: "..m.name)
 end
end)
if not good then
 local restored=true
 for _,m in ipairs(oldModules) do
  local ok=pcall(function()
   if fs.exists(m.path) then fs.delete(m.path) end
   fs.copy(backup.."/"..m.name,m.path)
  end)
  if not ok then restored=false end
 end
 error("Update fallito, moduli "..(restored and "ripristinati" or "DA VERIFICARE")..
  ", autostart OFF: "..tostring(reason),0)
end
if hasLatch then fs.delete(latchPath) end
print(unit..": AGGIORNATA a miner 2.3.10 / agente 1.7.")
print("3 secchi VUOTI dal Regulator con slot 1; lava senza oggetti inattesi.")
print("BOOT, coordinate e checkpoint non modificati.")
print("Backup "..backup)
print("AUTOSTART OFF, nessun movimento o reboot.")
print("Dalla propria HOME, ora esegui: reboot")
