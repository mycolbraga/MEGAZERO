-- MEGAZERO | N01 RIENTRO CONTROLLATO v1.0
-- Si esegue SOLO dopo aver fermato manualmente il miner: non riavvia.
-- Riutilizza il miner unico v2.3.3 e il checkpoint v23 inalterato.
assert(turtle,"Eseguire sulla Turtle N01")
local function read(path)
 local f=assert(fs.open(path,"r"),"File assente: "..path)
 local raw=f.readAll();f.close();return raw
end
local cfg=assert(textutils.unserialize(read("/megazero_config")),
 "Configurazione illeggibile")
assert(cfg.unit=="N01" and cfg.site=="MINIERA-01",
 "Solo su N01 del primo settore")
assert(cfg.miner_autostart==true,
 "Autostart non attivo; verificare lo stato prima del rientro")
local minerPath=fs.exists("/megazero_miner") and
 "/megazero_miner" or "/megazero_miner.lua"
local source=read(minerPath)
assert(source:find("^%-%- MEGAZERO MINER v2%.3%.3"),
 "Installare prima il miner v2.3.3")
local checkpoint="/.megazero_miner_v23_N01_LAVORO"
local s=assert(textutils.unserialize(read(checkpoint)),
 "Checkpoint v23 non leggibile")
assert(type(s)=="table" and type(s.path)=="table" and
 type(s.x)=="number" and type(s.y)=="number" and
 type(s.z)=="number" and type(s.d)=="number",
 "Traccia non valida")
assert(s.pending==nil,
 "Posizione fisica incerta (pending): NON muovere, controllo manuale")
assert(not fs.exists("/.megazero_miner_error"),
 "Errore miner presente: non eseguo un rientro non verificato")
print("N01: percorso salvato "..#s.path.." passi")
print("Indice quota "..tostring(s.level)..
 ", galleria salvata "..tostring(s.distance).."/300")
if #s.path>0 then
 print("Rientro controllato verso 2119,-53,2995")
else
 assert(s.x==2119 and s.y==-53 and s.z==2995,
  "Traccia vuota ma posizione diversa dalla base: STOP")
 print("Checkpoint gia' alla propria base")
end
local mod=dofile("/megazero_rete")
local agent,err=mod.new(cfg.unit,cfg.site,cfg.central or 54)
assert(agent,err or "Modem telemetria assente")
local miner=assert(dofile(minerPath),"Miner non caricabile")
assert(type(miner)=="function","Entry miner non valida")
miner(agent,cfg,{rientroOnly=true})
local after=assert(textutils.unserialize(read(checkpoint)),
 "Checkpoint dopo rientro non leggibile")
assert(type(after.path)=="table" and #after.path==0 and
 after.pending==nil and after.x==2119 and
 after.y==-53 and after.z==2995 and
 not fs.exists("/.megazero_miner_error"),
 "Rientro non confermato: NON riavviare")
assert(after.level==s.level and after.distance==s.distance,
 "Quota/distanza cambiate in modo inatteso: NON riavviare")
print("N01 A CASA. Miner FERMO, checkpoint invariato.")
print("Non riavviare ancora: disabilitare l'autostart prima dell'agente.")
