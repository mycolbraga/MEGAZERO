-- MEGAZERO | Installazione e prova unica del miner 40 settori, SOLO N01.
-- Da usare con: wget run <URL_DI_QUESTO_FILE> [distanza=48] [livelli=2]
-- Scarica /megazero_miner se manca, NON modifica startup o /megazero_config.
-- ATTENZIONE: esegue scavo reale nei limiti indicati.

local args={...}
local dist=tonumber(args[1] or "48")
local levels=tonumber(args[2] or "2")
assert(dist and dist>=1 and dist<=300 and dist%1==0,"Distanza 1..300")
assert(levels and levels>=1 and levels<=20 and levels%1==0,"Livelli 1..20")
assert(turtle,"Eseguire su una Mining Turtle")
local c=assert(fs.open("/megazero_config","r"),"Config MEGAZERO assente")
local cfg=assert(textutils.unserialize(c.readAll()),"Config corrotta")
c.close()
assert(cfg.site=="MINIERA-01" and cfg.unit=="N01",
 "Questa prima prova e' consentita soltanto sulla N01")
assert(not fs.exists("/.megazero_miner_error"),
 "Esiste un errore miner irrisolto: controllare prima di riprendere")
assert(fs.exists("/megazero_fluidi"),"Modulo /megazero_fluidi mancante")
assert(fs.exists("/megazero_rete"),"Modulo /megazero_rete mancante")
local program="/megazero_miner"
if not fs.exists(program) then
 print("Scarico il miner comune a tutte le 40 turtle...")
 local url="https://raw.githubusercontent.com/mycolbraga/MEGAZERO/registro/megazero/scripts/turtle/megazero_miner.lua"
 local response,err=http.get(url)
 assert(response,"Download fallito: "..tostring(err))
 local source=response.readAll();response.close()
 assert(type(source)=="string" and
  source:sub(1,#"-- MEGAZERO MINER v1.0")=="-- MEGAZERO MINER v1.0",
  "Il download non sembra il miner MEGAZERO")
 local parsed,why=load(source,"=megazero_miner")
 assert(parsed,"Errore di sintassi: "..tostring(why))
 local file=assert(fs.open(program,"w"))
 file.write(source);file.close()
 print("Miner installato, startup invariato.")
else
 print("Il miner e' gia' presente: non lo sovrascrivo.")
end
local miner=assert(dofile(program),"Miner non caricabile")
assert(type(miner)=="function","Il miner non restituisce una funzione")
local rete=assert(dofile("/megazero_rete"),"Modulo rete non caricabile")
local agent,why=rete.new(cfg.unit,cfg.site,cfg.central or 54)
assert(agent,why or "Modem non disponibile")
print("MEGAZERO N01 | PROVA MULTILIVELLO")
print("Distanza: "..dist.." | quote: "..levels.." | area N01")
print("Il miner verra' AVVIATO ORA. Non premere Ctrl+T.")
miner(agent,cfg,{distance=dist,levels=levels,prova=true})
print("Prova terminata: controlla BASE/ERRORE sulla centrale.")
print("Per riprendere lo startup normale usa: reboot")
