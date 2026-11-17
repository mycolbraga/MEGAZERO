-- MEGAZERO | Installatore UNIVERSALE di flotta: miner 2.3.14, agent 1.11
-- Esegui su una qualunque N/O/S/E 01..10, ferma alla HOME. NON in SCAVO.
-- Non interrompe scavi, non muove, non riavvia. Mantiene checkpoint.
assert(turtle,"Da eseguire solo su una Turtle, non sulla centrale")
local RELEASE="64e6387606900d27c03d4294cf4fc9bb6f3d30aa"
local BASE="https://raw.githubusercontent.com/mycolbraga/MEGAZERO/"..
 RELEASE.."/scripts/turtle/"
local function read(p)
 local f=assert(fs.open(p,"r"),"File non leggibile: "..p)
 local d=f.readAll();f.close();return d
end
local function write(p,d)
 local f=assert(fs.open(p,"w"),"Scrittura fallita: "..p)
 f.write(d);f.close()
 assert(read(p)==d,"Scrittura incompleta: "..p)
end
local function locate()
 local x,y,z=gps.locate(4,false)
 assert(type(x)=="number" and type(y)=="number" and type(z)=="number",
  "GPS assente: nessun aggiornamento")
 return x,y,z
end
local function near(a,b) return math.abs(a-b)<0.25 end
local function existing(n)
 if fs.exists("/"..n) then return "/"..n end
 if fs.exists("/"..n..".lua") then return "/"..n..".lua" end
 error("Modulo mancante: "..n,0)
end
local cfgPath="/megazero_config"
local cfg=assert(textutils.unserialize(read(cfgPath)),"Config illeggibile")
local side,num
if type(cfg.unit)=="string" then side,num=cfg.unit:match("^([NOSE])(%d%d)$") end
num=tonumber(num)
assert(cfg.site=="MINIERA-01" and side and num and num>=1 and num<=10,
 "Turtle non appartenente a MINIERA-01")
local unit=cfg.unit
local blocked,block=turtle.inspect()
assert(not blocked or (block and block.name=="minecraft:water"),
 "Uscita "..unit.." ostruita da BLOCCO SOLIDO: "..
 tostring(block and block.name or "?")..
 ". Nessun aggiornamento effettuato.")
local i=num-1
local hx,hy,hz,hd
if side=="N" then hx,hy,hz,hd=2119-2*i,-51,2995,0
elseif side=="O" then hx,hy,hz,hd=2099,-51,2995+2*i,3
elseif side=="S" then hx,hy,hz,hd=2099+2*i,-51,3015,2
else hx,hy,hz,hd=2119,-51,3015-2*i,1 end
local x,y,z=locate()
assert(near(x,hx) and near(y,hy) and near(z,hz),
 "NON HOME ("..unit.."): GPS "..x..","..y..","..z)
local cpPath="/.megazero_miner_v23_"..unit.."_LAVORO"
assert(fs.exists(cpPath),
 "Checkpoint "..unit.." assente: niente update, verifica avanzamento")
local cpRaw=read(cpPath)
local cp=assert(textutils.unserialize(cpRaw),"Checkpoint illeggibile")
assert(type(cp)=="table" and type(cp.path)=="table" and
 cp.pending==nil and #cp.path==0 and
 cp.x==hx and cp.y==hy and cp.z==hz and cp.d==hd and
 cp.finished~=true,
 "Checkpoint non HOME, movimento pendente o lavoro finito: STOP")
local boot=read(existing("megazero_boot"))
assert(boot:find("^%-%- MEGAZERO BOOT 1%.2"),
 "BOOT non v1.2, installazione fermata per sicurezza")
local top=assert(peripheral.wrap("top"),"Cassa superiore non collegata")
local bottom=assert(peripheral.wrap("bottom"),"Cassa inferiore non collegata")
assert(type(top.list)=="function" and type(bottom.list)=="function",
 "Casse non ispezionabili")
local empties,lava=0,0
for _,it in pairs(top.list()) do
 if it.name=="minecraft:bucket" then empties=empties+it.count end
 if it.name=="minecraft:lava_bucket" then lava=lava+it.count end
end
for slot=1,16 do
 local it=turtle.getItemDetail(slot)
 if it and it.name=="minecraft:bucket" then empties=empties+it.count end
end
-- Il rifornimento verra controllato dal miner al prossimo avvio.
local latch="/.megazero_miner_error"
local hasLatch=fs.exists(latch)
local err=hasLatch and read(latch) or ""
local allowed={
 "Non riesco a spostare lava nello slot 1",
 "spostare lava nello slot 1",
 "Scorta secchi non ottenibile",
 "Regulator: mancano",
 "Scorta secchi insufficiente",
 "Impossibile raggiungere i secchi vuoti",
 "Cassa superiore da verificare: impossibile ripristinare gli slot",
 "Troppi rientri per le scorte sullo stesso livello",
 "Prelievo secchi dalla cassa fallito",
 "Slot Turtle esauriti durante prelievo secchi",
 "Carburante pieno",
 "slot 1 cassa lava",
 "spostare materiale verso lo slot 1",
 "portare il secchio nello slot 1",
 "Blocco non minerario sconosciuto: minecraft:verdant_froglight",
 "Blocco non minerario sconosciuto: minecraft:pearlescent_froglight",
 "Blocco non minerario sconosciuto: minecraft:ochre_froglight",
 "Uscita dalla base ostruita",
 "Slot 1 riempito dal Regulator"
}
if hasLatch then
 local valid=false
 for _,reason in ipairs(allowed) do
  if err:find(reason,1,true) then valid=true;break end
 end
 assert(valid,"Errore non riconosciuto: "..err:sub(1,145))
end
local pkg={
 {name="megazero_miner",prefix="-- MEGAZERO MINER v2.3.14"},
 {name="megazero_admin_agent",prefix="-- MEGAZERO ADMIN AGENT v1.11"},
 {name="megazero_auto",prefix="-- MEGAZERO | Gestione avvio automatico"}
}
local already=true
for _,m in ipairs(pkg) do
 m.path=existing(m.name)
 m.old=read(m.path)
 if m.name=="megazero_miner" then
  assert(m.old:find("^%-%- MEGAZERO MINER v2%.3%."),
   "Miner sconosciuto, STOP")
 elseif m.name=="megazero_admin_agent" then
  assert(m.old:find("^%-%- MEGAZERO ADMIN AGENT v1%."),
   "Agente sconosciuto, STOP")
 else
  assert(m.old:sub(1,#m.prefix)==m.prefix,
   "Gestione avvio sconosciuta, STOP")
 end
 if m.old:sub(1,#m.prefix)~=m.prefix then already=false end
end
if not read(existing("megazero_auto")):find("Miner non v2.3.14",1,true) then
 already=false
end
print(unit.." PC"..os.getComputerID()..": GPS HOME confermata, uscita libera o acqua ammessa")
print("Checkpoint: "..#cp.path.." passi, lvl "..tostring(cp.level)..
 " dist "..tostring(cp.distance))
print("Scorte: "..empties.." secchi vuoti, "..lava.." lava in cassa")
if already and not hasLatch then
 print("V2.3.14 / AGENTE 1.11 GIA' INSTALLATI; nessuna modifica.")
 return
end
-- Scarica e verifica TUTTO prima di cambiare qualsiasi file.
for _,m in ipairs(pkg) do
 local response,why=http.get(BASE..m.name..".lua")
 assert(response,"Download "..m.name.." fallito: "..tostring(why))
 m.new=response.readAll();response.close()
 assert(m.new:sub(1,#m.prefix)==m.prefix,
  "Versione download inattesa "..m.name)
 assert(load(m.new,"="..m.name),"Modulo Lua non compilabile "..m.name)
end
local backupBase="/.megazero_flotta_2314_backup_"..unit.."_"
local n=1
while fs.exists(backupBase..n) and n<50 do n=n+1 end
local backup=backupBase..n
assert(not fs.exists(backup),"Troppi backup: STOP")
local staged={}
for _,m in ipairs(pkg) do
 m.tmp="/.megazero_update_2314_tmp_"..m.name
 assert(not fs.exists(m.tmp),"Update precedente incompleto: "..m.tmp)
 staged[#staged+1]=m.tmp
end
local cfgTmp="/.megazero_update_2314_tmp_config"
assert(not fs.exists(cfgTmp),"Update precedente incompleto: "..cfgTmp)
local cfgNew={}
for k,v in pairs(cfg) do cfgNew[k]=v end
cfgNew.miner_autostart=false
-- Backup integrale checkpoint, config, errore e moduli.
fs.makeDir(backup)
for _,m in ipairs(pkg) do
 fs.copy(m.path,backup.."/"..m.name)
 assert(read(backup.."/"..m.name)==m.old,"Backup errato "..m.name)
end
fs.copy(cfgPath,backup.."/megazero_config")
assert(read(backup.."/megazero_config")==read(cfgPath),"Backup config errato")
fs.copy(cpPath,backup.."/checkpoint")
assert(read(backup.."/checkpoint")==cpRaw,"Backup checkpoint errato")
if hasLatch then
 fs.copy(latch,backup.."/megazero_miner_error")
 assert(read(backup.."/megazero_miner_error")==err,"Backup latch errato")
end
for _,m in ipairs(pkg) do write(m.tmp,m.new) end
write(cfgTmp,textutils.serialize(cfgNew))
-- Disabilita autostart prima di sostituire i moduli.
fs.delete(cfgPath);fs.move(cfgTmp,cfgPath)
local success,why=pcall(function()
 for _,m in ipairs(pkg) do
  fs.delete(m.path);fs.move(m.tmp,m.path)
  assert(read(m.path)==m.new,"Sostituzione incompleta "..m.name)
 end
end)
if not success then
 local all=true
 for _,m in ipairs(pkg) do
  local ok=pcall(function()
   if fs.exists(m.path) then fs.delete(m.path) end
   fs.copy(backup.."/"..m.name,m.path)
  end)
  if not ok then all=false end
 end
 error("Installazione fallita! Moduli "..(all and "ripristinati" or
  "DA VERIFICARE")..", autostart OFF: "..tostring(why),0)
end
if hasLatch then fs.delete(latch) end
assert(read(cpPath)==cpRaw,"ERRORE: checkpoint modificato inaspettatamente")
print(unit..": INSTALLATA v2.3.14 / agente v1.11")
print("Checkpoint e HOME invariati. Backup: "..backup)
print("Autostart OFF; NESSUNO SCAVO o REBOOT.")
print("Prossimo passo: reboot per caricare agente v1.11, poi avvio da PC54.")
