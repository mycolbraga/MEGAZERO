-- MEGAZERO | Riparazione manuale SOLO Turtle ferme per errore slot 1 lava
-- UNA sola installazione; NON muove, NON scava, NON riavvia.
-- Installa miner 2.3.7, admin 1.5, auto aggiornato, disattiva autostart.
-- Non modifica BOOT 1.2, startup o checkpoint validi.
assert(turtle,"Eseguire direttamente su una Turtle")
local function read(path)
 local f=assert(fs.open(path,"r"),"File mancante: "..path)
 local s=f.readAll();f.close();return s
end
local function write(path,data)
 local f=assert(fs.open(path,"w"),"Scrittura fallita: "..path)
 f.write(data);f.close()
 assert(fs.getSize(path)==#data,"Scrittura incompleta: "..path)
end
local cfg=assert(textutils.unserialize(read("/megazero_config")),"Config illeggibile")
local unit=assert(cfg.unit,"Sigla Turtle mancante")
assert(type(unit)=="string" and unit:match("^[NOSE]%d%d$") and
 unit~="N01" and cfg.site=="MINIERA-01",
 "Riparazione limitata alle Turtle N02..E10 (N01 ESCLUSA)")
local side,num=unit:match("^([NOSE])(%d%d)$")
num=tonumber(num)
assert(num and num>=1 and num<=10,"Sigla non valida")
local i=num-1
local hx,hy,hz
if side=="N" then hx,hy,hz=2119-2*i,-51,2995
elseif side=="O" then hx,hy,hz=2099,-51,2995+2*i
elseif side=="S" then hx,hy,hz=2099+2*i,-51,3015
else hx,hy,hz=2119,-51,3015-2*i end
local boot=fs.exists("/megazero_boot") and "/megazero_boot" or "/megazero_boot.lua"
assert(read(boot):find("^%-%- MEGAZERO BOOT 1%.2"),"BOOT non 1.2: STOP")
local targets={
 {name="megazero_miner",before="-- MEGAZERO MINER v2.3.6",
  after="-- MEGAZERO MINER v2.3.7",
  ref="dc031ac51a3b267dd721f11d6d20a19a457be1dc"},
 {name="megazero_admin_agent",before="-- MEGAZERO ADMIN AGENT v1.4",
  after="-- MEGAZERO ADMIN AGENT v1.5",
  ref="6429fdce338653e4be3c19068810cdc9841dfe6c"},
 {name="megazero_auto",before="-- MEGAZERO | Gestione avvio automatico",
  after="-- MEGAZERO | Gestione avvio automatico",
  ref="19a011e1a1467fe2e338f0ccee412a7172bd7ee0"}
}
for _,it in ipairs(targets) do
 it.path=fs.exists("/"..it.name) and "/"..it.name or
   (fs.exists("/"..it.name..".lua") and "/"..it.name..".lua")
 assert(it.path,"File programma mancante: "..it.name)
 it.old=read(it.path)
 assert(it.old:sub(1,#it.before)==it.before,
  "Versione diversa dal previsto: "..it.name)
end
local latchPath="/.megazero_miner_error"
assert(fs.exists(latchPath) and not fs.isDir(latchPath),
 "Nessun errore miner: NON riparo Turtle diversa")
local latch=read(latchPath)
assert(latch:lower():find("spostare lava nello slot 1",1,true) or
       latch:lower():find("slot 1 cassa lava",1,true),
 "Errore non riconosciuto come BUG LAVA SLOT 1: "..latch:sub(1,130))
local cpPath="/.megazero_miner_v23_"..unit.."_LAVORO"
if fs.exists(cpPath) then
 local saved=assert(textutils.unserialize(read(cpPath)),"Checkpoint non leggibile")
 assert(type(saved)=="table" and saved.x==hx and saved.y==hy and
   saved.z==hz and saved.pending==nil and
   type(saved.path)=="table" and #saved.path==0 and
   saved.level==1 and (saved.distance==nil or saved.distance==0),
   "Checkpoint non iniziale: STOP, non tocco i dati")
end
-- GPS e' solo controllo INFORMATIVO. Se disponibile e dice NON HOME,
-- fermarsi invece di fare supposizioni. Assenza GPS non blocca il fix.
local okGPS,x,y,z=pcall(gps.locate,3,false)
if okGPS and type(x)=="number" and type(y)=="number" and type(z)=="number" then
 print("GPS "..math.floor(x+0.5)..","..math.floor(y+0.5)..","..math.floor(z+0.5))
 assert(math.abs(x-hx)<0.5 and math.abs(y-hy)<0.5 and
  math.abs(z-hz)<0.5,"GPS NON alla HOME di "..unit..": STOP")
else
 print("GPS non disponibile: niente blocco GPS, verificati errore e checkpoint")
end
local backup="/.megazero_lava237_backup_"..unit
assert(not fs.exists(backup),"Riparazione gia' iniziata: "..backup)
for _,it in ipairs(targets) do
 local url="https://raw.githubusercontent.com/mycolbraga/MEGAZERO/"..
  it.ref.."/scripts/turtle/"..it.name..".lua"
 local response,err=http.get(url)
 assert(response,"Download fallito "..it.name..": "..tostring(err))
 it.code=response.readAll();response.close()
 assert(type(it.code)=="string" and
  it.code:sub(1,#it.after)==it.after,"Versione inattesa: "..it.name)
 local fn,why=load(it.code,"="..it.name)
 assert(fn,"Sintassi non valida "..it.name..": "..tostring(why))
end
local newConfig={}
for k,v in pairs(cfg) do newConfig[k]=v end
newConfig.miner_autostart=false
local cfgNew=textutils.serialize(newConfig)
local stages={}
for _,it in ipairs(targets) do
 it.stage="/.megazero_fix237_stage_"..it.name
 assert(not fs.exists(it.stage),"Staging presente: "..it.stage)
 stages[#stages+1]=it.stage
end
local cfgStage="/.megazero_fix237_stage_config"
assert(not fs.exists(cfgStage),"Staging config gia' presente")
for _,it in ipairs(targets) do write(it.stage,it.code) end
write(cfgStage,cfgNew)
fs.makeDir(backup)
for _,it in ipairs(targets) do
 fs.copy(it.path,backup.."/"..it.name)
 assert(read(backup.."/"..it.name)==it.old,"Backup non valido: "..it.name)
end
local oldConfig=read("/megazero_config")
fs.copy("/megazero_config",backup.."/megazero_config")
fs.copy(latchPath,backup.."/megazero_miner_error")
assert(read(backup.."/megazero_config")==oldConfig and
 read(backup.."/megazero_miner_error")==latch,"Backup config/latch non valido")
-- Autostart OFF prima di sostituire il codice. Nessuna chiamata a reboot.
fs.delete("/megazero_config")
fs.move(cfgStage,"/megazero_config")
local ok,reason=pcall(function()
 for _,it in ipairs(targets) do
  fs.delete(it.path)
  fs.move(it.stage,it.path)
  assert(read(it.path)==it.code,"Installazione non verificata: "..it.name)
 end
end)
if not ok then
 -- FAIL SAFE: ripristina codici ma lascia l'avvio automatico DISATTIVO.
 for _,it in ipairs(targets) do
  if fs.exists(it.path) then fs.delete(it.path) end
  fs.copy(backup.."/"..it.name,it.path)
 end
 error("Installazione NON riuscita, codici originali ripristinati e autostart OFF: "..
  tostring(reason),0)
end
fs.delete(latchPath)
print("MEGAZERO "..unit..": RIPARATA (LAVA SLOT 1).")
print("MINER 2.3.7 | AGENTE 1.5 | BOOT 1.2 invariato.")
print("ERRORE archiviato in "..backup)
print("AUTOSTART OFF | Nessun movimento, nessuno scavo, nessun reboot.")
print("Da questa HOME puoi dare: reboot")
