-- MEGAZERO | N01 ripristino diretto dalla posizione reale e RESET a casa.
-- Specifico per N01 computer 12, checkpoint noto e orientamento NORD confermato.
-- NON richiede GPS; non eseguire se la Turtle si e' spostata dopo il dump.
-- Dopo il rientro, checkpoint archiviato e autostart disabilitato.
assert(turtle and os.getComputerID()==12, "SOLO N01 - computer ID 12")

local CONFIG="/megazero_config"
local CHECKPOINT="/.megazero_miner_v23_N01_LAVORO"
local BACKUP_CP="/.megazero_N01_rescue_original"
local BACKUP_CONFIG="/.megazero_N01_rescue_config"
local ARCHIVE="/.megazero_N01_rescue_reset_checkpoint"
local STAGED_CP="/.megazero_N01_rescue_staged"
local STAGED_CONFIG="/.megazero_N01_rescue_config_staged"
local MARKER="/.megazero_N01_rescue_started"
local MINER=fs.exists("/megazero_miner") and "/megazero_miner" or "/megazero_miner.lua"

local function read(path)
 local f=assert(fs.open(path,"r"),"File mancante: "..path)
 local data=f.readAll();f.close();return data
end
local function write(path,data)
 local f=assert(fs.open(path,"w"),"Impossibile scrivere: "..path)
 f.write(data);f.close()
end
local function saveReplace(path,data,temp)
 assert(not fs.exists(temp),"Staging precedente presente: "..temp)
 write(temp,data)
 assert(read(temp)==data,"Staging non verificato")
 fs.delete(path)
 fs.move(temp,path)
 assert(read(path)==data,"Scrittura non verificata")
end
local cfg=assert(textutils.unserialize(read(CONFIG)),"Config non valida")
assert(cfg.unit=="N01" and cfg.site=="MINIERA-01","Unita' inattesa")
assert(type(cfg.miner_autostart)=="boolean","Autostart non valido")
local source=read(MINER)
assert(source:find("^%-%- MEGAZERO MINER v2%.3%.3"),"Miner v2.3.3 richiesto")
local data=assert(textutils.unserialize(read(CHECKPOINT)),"Checkpoint illeggibile")
assert(type(data)=="table" and type(data.path)=="table","Traccia mancante")
assert(data.pending=="TURN" and data.x==2118 and data.y==-10 and
 data.z==2985 and data.d==3 and #data.path==54,
 "Checkpoint diverso da quello diagnosticato: STOP senza modifiche")
local last=data.path[#data.path]
assert(type(last)=="table" and last.m=="F" and last.d==3,
 "Ultimo passo non corrisponde: STOP")
assert(data.level==4 and data.distance==9,"Avanzamento diverso: STOP")
assert(not fs.exists("/.megazero_miner_error"),"Errore miner presente: STOP")
assert(not fs.exists(BACKUP_CP) and not fs.exists(BACKUP_CONFIG) and
 not fs.exists(ARCHIVE) and not fs.exists(STAGED_CP) and
 not fs.exists(STAGED_CONFIG) and not fs.exists(MARKER),
 "Procedura gia' iniziata o backup presente: NON ripetere")
assert(type(turtle.getFuelLevel())=="number" and turtle.getFuelLevel()>=150,
 "Fuel insufficiente per il rientro")
local mod=dofile("/megazero_rete")
assert(type(mod)=="table" and type(mod.new)=="function","Telemetria mancante")
local miner=assert(dofile(MINER),"Miner non caricabile")
assert(type(miner)=="function","Miner non valido")

-- Disabilita il riavvio automatico PRIMA di qualsiasi operazione sulla traccia.
-- In caso di interruzione o reboot, N01 non riparte da sola.
fs.copy(CHECKPOINT,BACKUP_CP)
fs.copy(CONFIG,BACKUP_CONFIG)
cfg.miner_autostart=false
saveReplace(CONFIG,textutils.serialize(cfg),STAGED_CONFIG)

-- Dal dump di CC:Tweaked: N01 era a 2118,-8,2985 rivolta a NORD.
-- Due passi in alto non sono nella traccia originale (54 passi).
-- Li aggiungiamo come due U gia' eseguiti: goHome li invertira' con
-- due DOWN, poi ripercorrera' esattamente i 54 passi originali.
-- Nessun comando di movimento e' stato eseguito prima del salvataggio.
data.x=2118; data.y=-8; data.z=2985; data.d=0
data.pending=nil
data.path[#data.path+1]={m="U",d=0}
data.path[#data.path+1]={m="U",d=0}
assert(#data.path==56,"Traccia corretta non valida")
saveReplace(CHECKPOINT,textutils.serialize(data),STAGED_CP)
write(MARKER,"N01 return-only started; monitor checkpoint, DO NOT restart")

local agent,why=mod.new(cfg.unit,cfg.site,cfg.central or 54)
assert(agent,why or "Agente telemetria assente")
print("N01: rientro a casa con 56 passi, da posizione NORD")
print("Autostart DISABILITATO, checkpoint originale salvato.")
miner(agent,cfg,{rientroOnly=true})

if fs.exists("/.megazero_miner_error") then
 error("Rientro interrotto: errore miner. NON riavviare / NON azzerare.")
end
local cp=assert(textutils.unserialize(read(CHECKPOINT)),
 "Checkpoint dopo rientro illeggibile")
assert(type(cp)=="table" and type(cp.path)=="table" and #cp.path==0
 and cp.pending==nil and cp.x==2119 and cp.y==-53 and cp.z==2995
 and cp.level==4 and cp.distance==9,
 "Rientro non verificato: checkpoint mantenuto, NON azzerato")
-- Archivia la traccia completata e azzera per ripartenza da livello 1.
fs.move(CHECKPOINT,ARCHIVE)
assert(not fs.exists(CHECKPOINT) and fs.exists(ARCHIVE),
 "Checkpoint non archiviato correttamente")
fs.delete(MARKER)
print("N01 ALLA BASE: 2119,-53,2995")
print("RESET ESEGUITO: al futuro avvio riparte dal livello 1.")
print("AUTOSTART OFF: resta ferma con le altre 39.")
print("Backup checkpoint originale: "..BACKUP_CP)
