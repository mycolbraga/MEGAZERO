-- MEGAZERO | Sblocco sicuro N01: solo errore mossy_cobblestone
-- Non muove Turtle, non elimina checkpoint, non modifica autostart.
assert(turtle,"Da eseguire sulla Turtle N01.")
local CONFIG="/megazero_config"
local CHECKPOINT="/.megazero_miner_v23_N01_LAVORO"
local LATCH="/.megazero_miner_error"
local BACKUP="/.megazero_miner_error.backup_mossy_N01"
local function read(path)
 local f=assert(fs.open(path,"r"),"File assente: "..path)
 local v=f.readAll();f.close();return v
end
local cfg=assert(textutils.unserialize(read(CONFIG)),"Config N01 non valida")
assert(cfg.site=="MINIERA-01" and cfg.unit=="N01" and
 cfg.miner_autostart==true,
 "Sito/unit o autostart diversi dal previsto: non sblocco")
local miner=fs.exists("/megazero_miner") and "/megazero_miner"
 or "/megazero_miner.lua"
assert(read(miner):find("^%-%- MEGAZERO MINER v2%.3%.2"),
 "Prima installare miner v2.3.2")
local saved=assert(textutils.unserialize(read(CHECKPOINT)),
 "Checkpoint illeggibile")
assert(type(saved)=="table" and type(saved.path)=="table"
 and type(saved.level)=="number" and type(saved.distance)=="number",
 "Checkpoint incompleto")
assert(saved.pending==nil and #saved.path==0,
 "Percorso o spostamento non concluso: blocco conservato")
assert(saved.x==2119 and saved.y==-53 and saved.z==2995,
 "La posizione SALVATA non risulta alla base: blocco conservato")
assert(not saved.finished,"Lavoro gia' completato")
local cause=read(LATCH)
assert(cause:find("Blocco non minerario sconosciuto: minecraft:mossy_cobblestone",1,true),
 "Errore differente da mossy cobblestone: non sblocco. "..cause:sub(1,140))
assert(not fs.exists(BACKUP),"Backup gia' presente: "..BACKUP)
assert(fs.exists("/megazero_fluidi") or fs.exists("/megazero_fluidi.lua"),
 "Modulo fluidi mancante")
print("N01: salva quota indice "..saved.level..", distanza "..saved.distance.."/300")
print("Rientro e checkpoint registrati alla base; errore riconosciuto.")
print("Nessun blocco/scavo eseguito da questo programma.")
fs.move(LATCH,BACKUP)
assert(not fs.exists(LATCH),"Archiviazione errore fallita")
print("SBLOCCO OK, errore conservato in: "..BACKUP)
print("Checkpoint INALTERATO. Nessun reboot eseguito.")
