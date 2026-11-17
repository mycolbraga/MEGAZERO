-- MEGAZERO N01 | SOLO AGENTE 1.17 | RIPARAZIONE OTA A BASSO SPAZIO
-- Nessun movimento, nessun reset, nessuna modifica al miner 2.3.17.
assert(turtle,"Usare sulla Turtle N01")
local function read(path)
 local h=fs.open(path,"r")
 if not h then return nil end
 local s=h.readAll();h.close();return s
end
local cfgRaw=assert(read("/megazero_config"),"Config assente")
local cfg=assert(textutils.unserialize(cfgRaw),"Config illeggibile")
assert(cfg.site=="MINIERA-01" and cfg.unit=="N01" and
 cfg.miner_autostart==false,"Non e' N01 ferma con autostart OFF")
local cpPath="/.megazero_miner_v23_N01_LAVORO"
local cpRaw=assert(read(cpPath),"Checkpoint mancante")
local cp=assert(textutils.unserialize(cpRaw),"Checkpoint non valido")
assert(cp.x==2119 and cp.y==-51 and cp.z==2995
 and cp.d==0 and cp.level==1 and cp.distance==0 and
 type(cp.path)=="table" and #cp.path==0 and cp.pending==nil,
 "Checkpoint non HOME/zero: intervento vietato")
local x,y,z=gps.locate(4,false)
assert(x and y and z and math.abs(x-2119)<0.25
 and math.abs(y+51)<0.25 and math.abs(z-2995)<0.25,
 "GPS non conferma HOME: intervento vietato")
local function existing(name)
 if fs.exists("/"..name) then return "/"..name end
 if fs.exists("/"..name..".lua") then return "/"..name..".lua" end
 error("File non trovato: "..name)
end
local function first(path)
 local h=assert(read(path),"File mancante: "..path)
 return h:match("([^\n]*)") or ""
end
assert(first(existing("megazero_miner")):find("^%-%- MEGAZERO MINER v2%.3%.17"),
 "Miner non v2.3.17: non tocco nulla")
assert(first(existing("megazero_fluidi")):find("^%-%- MEGAZERO FLUIDI v1%.2"),
 "Fluidi non v1.2: non tocco nulla")
local agent=existing("megazero_admin_agent")
local current=first(agent)
assert(current:find("^%-%- MEGAZERO ADMIN AGENT v1%.16")
 or current:find("^%-%- MEGAZERO ADMIN AGENT v1%.17"),
 "Versione agente inattesa: "..current)
print("N01 | Miner 2.3.17 e fluidi 1.2 OK")
print("Agente su disco: "..current)
local url="https://raw.githubusercontent.com/mycolbraga/MEGAZERO/"..
 "c8b84193f40509f7107d6851983c8ab2d6d338fa/"..
 "scripts/turtle/megazero_admin_agent.lua"
local h,why=http.get(url)
assert(h,"Download agente fallito: "..tostring(why))
local source=h.readAll();h.close()
assert(type(source)=="string" and
 source:find("^%-%- MEGAZERO ADMIN AGENT v1%.17"),
 "Download agente non v1.17")
local compiled,err=load(source,"=megazero_admin_agent")
assert(compiled,"Agente scaricato non compilabile: "..tostring(err))
print("Agente 1.17 validato in memoria: "..#source.." byte")
if current:find("^%-%- MEGAZERO ADMIN AGENT v1%.17") then
 print("Gia' installato: basta riavviare per caricarlo.")
 assert(read(cpPath)==cpRaw and read("/megazero_config")==cfgRaw,
 "Checkpoint/config cambiati: stop")
 print("Riavvio N01; miner_autostart OFF.")
 sleep(1);os.reboot()
end
local function free()
 local n=fs.getFreeSpace("/")
 return type(n)=="number" and n or math.huge
end
print("Spazio prima della pulizia: "..tostring(free()))
-- SOLO residui dei pacchetti OTA; NON eliminare i backup di reset,
-- di rientro, checkpoint, file installati o config.
local removed=0
for _,name in ipairs(fs.list("/")) do
 if name==".megazero_ota2316_state" or
  name:match("^%.megazero_stage_2316_") or
  name:match("^%.megazero_ota2316_backup_N01_") or
  name:match("^%.megazero_ota_backup_2316_") or
  name:match("^%.megazero_ota_backup_235_") then
  fs.delete("/"..name)
  assert(not fs.exists("/"..name),"OTA non eliminata: "..name)
  removed=removed+1
 end
end
print("Residui OTA eliminati: "..removed)
print("Spazio disponibile: "..tostring(free()))
assert(free()>=#source+8192,
 "Spazio insufficiente anche per agente singolo: STOP")
local stage="/.megazero_agent117_N01_new"
local backup="/.megazero_agent116_N01_backup"
assert(not fs.exists(stage) and not fs.exists(backup),
 "Backup/staging agente gia presente: STOP senza sovrascrivere")
local w=assert(fs.open(stage,"w"),"Impossibile aprire staging")
w.write(source);w.close()
assert(read(stage)==source,"Staging incompleto: nessuna sostituzione")
assert(read(cpPath)==cpRaw and read("/megazero_config")==cfgRaw,
 "Checkpoint/config cambiati: stop")
fs.move(agent,backup)
local ok,msg=pcall(fs.move,stage,agent)
if not ok then
 pcall(fs.move,backup,agent)
 error("Installazione fallita; agente precedente ripristinato: "..tostring(msg))
end
assert(read(agent)==source,"Agente installato diverso da sorgente")
assert(read(cpPath)==cpRaw and read("/megazero_config")==cfgRaw,
 "Checkpoint/config non invariati: fermare, nessun avvio")
print("Agente 1.17 installato su N01; backup vecchio conservato.")
print("Checkpoint e configurazione invariati.")
print("Riavvio N01 senza scavo.")
sleep(1)
os.reboot()
