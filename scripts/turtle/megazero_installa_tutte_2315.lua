-- MEGAZERO | INSTALLATORE UNICO 2.3.15 / agente 1.12 / 40 Turtle.
-- ESEGUIRE SOLO dal prompt > di una Turtle FERMA; non durante SCAVO.
-- Esegue backup integrale e NON modifica checkpoint, posizione o avanzamento.
-- Eventuali checkpoint pending / fuori HOME restano bloccati, NON avviati.
assert(turtle,"Programma solo per Mining Turtle, NON PC54")
local RELEASE="cc11b60e91fef35e3621782e35ba3a127a27a3ba"
local BASE="https://raw.githubusercontent.com/mycolbraga/MEGAZERO/"..
 RELEASE.."/scripts/turtle/"
local function read(path)
 local h=assert(fs.open(path,"r"),"File mancante: "..path)
 local body=h.readAll();h.close();return body
end
local function write(path,data)
 local h=assert(fs.open(path,"w"),"Impossibile scrivere "..path)
 h.write(data);h.close()
 assert(read(path)==data,"Scrittura non verificata: "..path)
end
local function existing(name)
 if fs.exists("/"..name) then return "/"..name end
 if fs.exists("/"..name..".lua") then return "/"..name..".lua" end
 error("Programma mancante: "..name,0)
end
local cfgPath="/megazero_config"
local cfgRaw=read(cfgPath)
local cfg=assert(textutils.unserialize(cfgRaw),"Config illeggibile")
local unit=cfg.unit
local side,n
if type(unit)=="string" then side,n=unit:match("^([NOSE])(%d%d)$") end
n=tonumber(n)
assert(cfg.site=="MINIERA-01" and side and n and n>=1 and n<=10,
 "Turtle non riconosciuta: nessun aggiornamento")
local k=n-1
local hx,hy,hz,hd
if side=="N" then hx,hy,hz,hd=2119-2*k,-51,2995,0
elseif side=="O" then hx,hy,hz,hd=2099,-51,2995+2*k,3
elseif side=="S" then hx,hy,hz,hd=2099+2*k,-51,3015,2
else hx,hy,hz,hd=2119,-51,3015-2*k,1 end
local cpPath="/.megazero_miner_v23_"..unit.."_LAVORO"
local cpRaw=read(cpPath)
local cp=assert(textutils.unserialize(cpRaw),"Checkpoint illeggibile")
assert(type(cp)=="table" and type(cp.path)=="table" and
 type(cp.x)=="number" and type(cp.y)=="number" and
 type(cp.z)=="number" and type(cp.d)=="number" and
 type(cp.level)=="number","Checkpoint malformato: STOP")
assert(read(existing("megazero_boot")):find("^%-%- MEGAZERO BOOT 1%.2"),
 "BOOT non v1.2: installazione fermata")
local x,y,z=gps.locate(4,false)
local gpsOK=type(x)=="number" and type(y)=="number" and type(z)=="number"
local atHome=cp.pending==nil and #cp.path==0 and
 cp.x==hx and cp.y==hy and cp.z==hz and cp.d==hd and
 gpsOK and math.abs(x-hx)<0.25 and math.abs(y-hy)<0.25 and
 math.abs(z-hz)<0.25
local latchPath="/.megazero_miner_error"
local latchRaw=fs.exists(latchPath) and read(latchPath) or nil
local modules={
 {name="megazero_miner",head="-- MEGAZERO MINER v2.3.15"},
 {name="megazero_admin_agent",head="-- MEGAZERO ADMIN AGENT v1.12"},
 {name="megazero_auto",head="-- MEGAZERO | Gestione avvio automatico"}
}
local upToDate=true
for _,m in ipairs(modules) do
 m.path=existing(m.name)
 m.old=read(m.path)
 if m.old:sub(1,#m.head)~=m.head then upToDate=false end
 assert(m.old:sub(1,11)=="-- MEGAZERO ",
  "Programma non riconosciuto: "..m.name)
end
if not read(existing("megazero_auto")):find("Miner non v2.3.15",1,true) then
 upToDate=false
end
print("MEGAZERO "..unit.." PC"..os.getComputerID())
print("Checkpoint: liv "..tostring(cp.level).." dist "..tostring(cp.distance)..
 " passi "..#cp.path.." pending "..tostring(cp.pending or "NO"))
print("GPS: "..(gpsOK and (x..","..y..","..z) or "NON DISPONIBILE"))
print("HOME verificata: "..(atHome and "SI" or "NO"))
if upToDate and cfg.miner_autostart==false then
 print("Gia aggiornata. Nessun file modificato.")
 if latchRaw then print("Errore precedente ancora presente: controllare prima di avviare.") end
 return
end
-- Download e compilazione di tutti i moduli prima di qualsiasi sostituzione.
for _,m in ipairs(modules) do
 local h,why=http.get(BASE..m.name..".lua")
 assert(h,"Download fallito "..m.name..": "..tostring(why))
 m.new=h.readAll();h.close()
 assert(m.new:sub(1,#m.head)==m.head,"Release errata: "..m.name)
 local f,err=load(m.new,"="..m.name)
 assert(f,"Sintassi non valida "..m.name..": "..tostring(err))
end
assert(modules[3].new:find("Miner non v2.3.15",1,true),
 "Autostart non richiede miner v2.3.15")
local backupBase="/.megazero_2315_backup_"..unit.."_"
local idx=1
while fs.exists(backupBase..idx) and idx<99 do idx=idx+1 end
local backup=backupBase..idx
assert(not fs.exists(backup),"Troppi backup")
local configTemp="/.megazero_2315_cfg_temp"
assert(not fs.exists(configTemp),"Config staging precedente: STOP")
for _,m in ipairs(modules) do
 m.temp="/.megazero_2315_tmp_"..m.name
 assert(not fs.exists(m.temp),"Staging precedente: "..m.temp)
end
-- Backup integrale di checkpoint, configurazione, errore e programmi.
fs.makeDir(backup)
write(backup.."/megazero_config",cfgRaw)
write(backup.."/checkpoint",cpRaw)
if latchRaw then write(backup.."/error_latch",latchRaw) end
for _,m in ipairs(modules) do
 write(backup.."/"..m.name,m.old)
 write(m.temp,m.new)
end
local nextCfg={}
for key,val in pairs(cfg) do nextCfg[key]=val end
nextCfg.miner_autostart=false
write(configTemp,textutils.serialize(nextCfg))
local ok,why=pcall(function()
 fs.delete(cfgPath);fs.move(configTemp,cfgPath)
 for _,m in ipairs(modules) do
  fs.delete(m.path);fs.move(m.temp,m.path)
  assert(read(m.path)==m.new,"Modulo non verificato "..m.name)
 end
 assert(read(cpPath)==cpRaw,"Checkpoint cambiato: STOP")
end)
if not ok then
 local modulesRestored=true
 for _,m in ipairs(modules) do
  local good=pcall(function()
   if fs.exists(m.path) then fs.delete(m.path) end
   fs.copy(backup.."/"..m.name,m.path)
  end)
  if not good then modulesRestored=false end
 end
 printError("Aggiornamento fallito: "..tostring(why))
 printError("Moduli "..(modulesRestored and "ripristinati" or "DA VERIFICARE"))
 printError("AUTOSTART resta disabilitato. NON RIAVVIARE.")
 return
end
-- Errore riconosciuto puo' essere cancellato SOLO alla HOME verificata.
local clear=false
if atHome and latchRaw then
 for _,reason in ipairs({
  "Slot 1 riempito dal Regulator","spostare lava nello slot 1",
  "Uscita dalla base ostruita","Regulator:","Scorta secchi",
  "Prelievo secchi","Blocco non minerario sconosciuto: minecraft:verdant_froglight",
  "Blocco non minerario sconosciuto: minecraft:pearlescent_froglight",
  "Blocco non minerario sconosciuto: minecraft:ochre_froglight"
 }) do
  if latchRaw:find(reason,1,true) then clear=true;break end
 end
end
if clear then fs.delete(latchPath) end
assert(read(cpPath)==cpRaw,"ERRORE: checkpoint non conservato")
print(unit..": SOFTWARE AGGIORNATO miner 2.3.15 / agente 1.12")
print("Checkpoint e progresso INVARIATI, backup: "..backup)
print("AUTOSTART OFF | NESSUNO SCAVO / REBOOT")
if not atHome then
 print("FUORI HOME/PENDING: NON riavviare lo scavo prima del recupero.")
elseif latchRaw and not clear then
 print("ERRORE non riconosciuto conservato. Recupero da verificare.")
else
 print("HOME confermata. Avvio solo dopo verifica centrale PC54.")
end
