-- MEGAZERO | Sblocco controllato N01 dopo rientro gia' riuscito
-- Nessun movimento, nessun reboot, checkpoint INALTERATO.
assert(turtle,"Questo controllo deve essere eseguito sulla Turtle N01.")
local CONFIG="/megazero_config"
local CHECKPOINT="/.megazero_miner_v23_N01_LAVORO"
local LATCH="/.megazero_miner_error"
local BACKUP="/.megazero_miner_error.backup_rientro_N01"
local MINER="/megazero_miner"
local function read(path)
 local f,reason=fs.open(path,"r")
 assert(f,"File richiesto: "..path.." ("..tostring(reason)..")")
 local raw=f.readAll()
 f.close()
 return raw
end
local cfg=assert(textutils.unserialize(read(CONFIG)),"Configurazione non valida")
assert(cfg.unit=="N01" and cfg.site=="MINIERA-01",
 "Questa procedura vale SOLO per N01 della prima miniera")
assert(cfg.miner_autostart==true,
 "Avvio miner non attivo: non altero la configurazione")
local file=fs.exists(MINER) and MINER or (MINER..".lua")
local miner=read(file)
assert(miner:match("^%-%- MEGAZERO MINER v2%.3%.1"),
 "Prima aggiornare il miner alla v2.3.1")
local s=assert(textutils.unserialize(read(CHECKPOINT)),
 "Checkpoint v23 non leggibile: non sblocco")
assert(type(s)=="table" and type(s.path)=="table"
 and type(s.level)=="number" and type(s.distance)=="number",
 "Checkpoint incompleto: non sblocco")
assert(s.pending==nil and #s.path==0,
 "Movimento o rientro ancora pendente: non sblocco")
assert(s.x==2119 and s.y==-53 and s.z==2995,
 "Il salvataggio NON indica la base N01: non sblocco")
assert(not s.finished,"Lavoro gia' segnato concluso")
local cause=read(LATCH)
assert(cause:find("Rientro da precedente interruzione: verifica prima di riprendere",1,true),
 "Errore diverso dal recupero gia' concluso: non sblocco. Dettaglio: "..cause:sub(1,150))
assert(not fs.exists(BACKUP),
 "Backup preesistente: "..BACKUP.."; non lo sovrascrivo")
assert(fs.exists("/megazero_fluidi") or fs.exists("/megazero_fluidi.lua"),
 "Modulo fluidi mancante: non sblocco")
print("N01: checkpoint valido, posizione registrata alla base.")
print("Quota indice "..s.level..", distanza "..s.distance.." / 300.")
print("Errore confermato: recupero precedente concluso.")
fs.move(LATCH,BACKUP)
assert(not fs.exists(LATCH),"Impossibile archiviare il vecchio errore")
print("Sblocco riuscito. Errore archiviato in:")
print(BACKUP)
print("Checkpoint INALTERATO; nessun movimento o reboot.")
print("NON riavviare finche' i chunk del corridoio non sono caricati.")
