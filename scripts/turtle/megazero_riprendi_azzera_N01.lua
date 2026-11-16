-- MEGAZERO | N01 RESCUE CONTINUATION v1.0. Solo PC 12.
-- Dopo primo DOWN riuscito, rientro fermo al passo 55 di 56.
-- Concludi rientro e RESET solo alla base; conserva backup originali.
assert(turtle and os.getComputerID()==12,"SOLO N01 Computer 12")
local CONFIG="/megazero_config"
local PATH="/.megazero_miner_v23_N01_LAVORO"
local MARKER="/.megazero_N01_rescue_started"
local ORIGINAL="/.megazero_N01_rescue_original"
local CONFIG_BACKUP="/.megazero_N01_rescue_config"
local ARCHIVE="/.megazero_N01_rescue_reset_checkpoint"
local LATCH="/.megazero_miner_error"
local BACKUP_LATCH="/.megazero_N01_rescue_latch_block55"
local BACKUP_MINER="/.megazero_N01_rescue_miner_v233"
local STAGE="/.megazero_N01_rescue_miner_v234.new"
local MINER=fs.exists("/megazero_miner") and "/megazero_miner" or "/megazero_miner.lua"
local URL="https://raw.githubusercontent.com/mycolbraga/MEGAZERO/39444bbe79f2615b369194e01adf3d8b69877508/scripts/turtle/megazero_miner.lua"
local function read(path)
 local f=assert(fs.open(path,"r"),"File assente: "..path)
 local raw=f.readAll();f.close()
 return raw
end
local function write(path,raw)
 local f=assert(fs.open(path,"w"),"Impossibile scrivere: "..path)
 f.write(raw);f.close()
end
local cfg=assert(textutils.unserialize(read(CONFIG)),"Config non valida")
assert(cfg.unit=="N01" and cfg.site=="MINIERA-01" and cfg.miner_autostart==false,
 "N01/autostart inattesi: fermo, nessuna modifica")
assert(fs.exists(MARKER) and fs.exists(ORIGINAL) and fs.exists(CONFIG_BACKUP),
 "Il primo recupero non e' stato avviato; procedura inattesa")
assert(not fs.exists(ARCHIVE) and not fs.exists(BACKUP_LATCH)
 and not fs.exists(BACKUP_MINER) and not fs.exists(STAGE),
 "Secondo recupero gia' iniziato: STOP")
local cp=assert(textutils.unserialize(read(PATH)),"Checkpoint illeggibile")
assert(type(cp)=="table" and type(cp.path)=="table" and
 cp.pending==nil and cp.x==2118 and cp.y==-9 and cp.z==2985 and
 cp.d==0 and #cp.path==55 and cp.level==4 and cp.distance==9,
 "Checkpoint diverso dopo la fermata: STOP")
local last=cp.path[#cp.path]
assert(type(last)=="table" and last.m=="U" and last.d==0,
 "Ultimo passo di ritorno inatteso: STOP")
local msg=read(LATCH)
assert(msg:find("Rientro bloccato al passo 55 a 2118,-9,2985",1,true),
 "Errore diverso dal blocco diagnosticato: STOP")
assert(type(turtle.getFuelLevel())=="number" and turtle.getFuelLevel()>100,
 "Carburante insufficiente per rientro")
local prev=read(MINER)
assert(prev:find("^%-%- MEGAZERO MINER v2%.3%.3"),"Miner precedente non v2.3.3")
local resp,why=http.get(URL)
assert(resp,"Download miner v2.3.4 non riuscito: "..tostring(why))
local source=resp.readAll();resp.close()
assert(source and source:find("^%-%- MEGAZERO MINER v2%.3%.4"),
 "Versione miner scaricata diversa da v2.3.4")
local compiled,parseErr=load(source,"=megazero_miner_234")
assert(compiled,"Miner scaricato con sintassi errata: "..tostring(parseErr))
write(STAGE,source)
assert(read(STAGE)==source,"Download salvato non coincide")
-- Archivi per recupero in caso di guasto.
fs.copy(MINER,BACKUP_MINER)
fs.copy(LATCH,BACKUP_LATCH)
assert(read(BACKUP_MINER)==prev and read(BACKUP_LATCH)==msg,
 "Impossibile verificare i backup; STOP")
fs.delete(MINER)
fs.move(STAGE,MINER)
assert(read(MINER)==source,"Miner v2.3.4 non verificato")
fs.delete(LATCH)
local mod=dofile("/megazero_rete")
assert(type(mod)=="table" and type(mod.new)=="function","Modulo rete mancante")
local agent,agentErr=mod.new(cfg.unit,cfg.site,cfg.central or 54)
assert(agent,"Agente telemetria mancante: "..tostring(agentErr))
local run=dofile(MINER)
assert(type(run)=="function","Miner caricato non valido")
print("N01: riprendo rientro da 2118,-9,2985, 55 passi.")
print("Se c'e' pietra naturale nel settore, la scavo. NON scavo base.")
run(agent,cfg,{rientroOnly=true})
assert(not fs.exists(LATCH),
 "Rientro non riuscito: NON azzerare e NON riavviare")
local after=assert(textutils.unserialize(read(PATH)),
 "Checkpoint finale non leggibile")
assert(type(after)=="table" and type(after.path)=="table" and
 #after.path==0 and after.pending==nil and
 after.x==2119 and after.y==-53 and after.z==2995,
 "Non ancora alla base: checkpoint intatto, NON azzerare")
fs.move(PATH,ARCHIVE)
assert(fs.exists(ARCHIVE) and not fs.exists(PATH),
 "Archivio checkpoint non confermato")
fs.delete(MARKER)
print("N01 RIENTRATA. Checkpoint AZZERATO dopo rientro.")
print("AUTOSTART DISATTIVO: ferma per avvio con le altre 39.")
print("Originale di sicurezza: "..ORIGINAL)
