-- MEGAZERO | INSTALLER v1.0: Regulator 3 secchi vuoti | Miner 2.3.9
-- Funziona su N01 e sulle altre 39, SOLO A HOME FERMA.
-- Backup e verifica versioni; non muove, non scava, non riavvia.
assert(turtle,"Esegui questo script direttamente sulla Turtle")
local RELEASE="b9390d61dff1ad153b9017d9d0312471e7f64eec"
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
local side,num=type(unit)=="string" and unit:match("^([NOSE])(%d%d)$")
num=tonumber(num)
assert(cfg.site=="MINIERA-01" and side and num and num>=1 and num<=10,
 "Questa non e' una Turtle del sito MINIERA-01")
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
  after="-- MEGAZERO MINER v2.3.9"},
 {name="megazero_admin_agent",before="-- MEGAZERO ADMIN AGENT v1.",
  after="-- MEGAZERO ADMIN AGENT v1.6"},
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
end
if allUpdated then
 print(unit.." gia' aggiornata: miner 2.3.9, agente 1.6")
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
 latch:find("portare il secchio nello slot 1",1,true)
if hasLatch then
 assert(knownError,"Errore non relativo a secchi/lava: "..latch:sub(1,140))
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
local chest=peripheral.wrap("top")
local below=peripheral.wrap("bottom")
assert(chest and type(chest.list)=="function" and
 below and type(below.list)=="function",
 "Casse sopra/sotto assenti: non garantita posizione HOME")
print("MEGAZERO "..unit.." | HOME checkpoint verificato se presente")
print("NUOVO: miner 2.3.9, agente 1.6, Regulator secchi vuoti")
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
local backup="/.megazero_regulator239_backup_"..unit
assert(not fs.exists(backup),"Backup precedente presente: "..backup)
local tmpFiles={}
for _,m in ipairs(oldModules) do
 m.tmp="/.megazero_239_tmp_"..m.name
 assert(not fs.exists(m.tmp),"Staging gia' esistente: "..m.tmp)
 tmpFiles[#tmpFiles+1]=m.tmp
end
local tmpConfig="/.megazero_239_tmp_config"
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
print(unit..": AGGIORNATA a miner 2.3.9 / agente 1.6.")
print("3 secchi VUOTI da Regulator, niente fuel sprecato per crearli.")
print("BOOT, coordinate e checkpoint non modificati.")
print("Backup "..backup)
print("AUTOSTART OFF, nessun movimento o reboot.")
print("Dalla propria HOME, ora esegui: reboot")
