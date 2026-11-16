-- MEGAZERO | Solo agente 1.3 su N01 dopo rientro e reset fisico
-- NON modifica boot, miner, config o startup. NON avvia scavo.
assert(turtle and os.getComputerID()==12,"Solo N01 PC 12")
local cfgFile=assert(fs.open("/megazero_config","r"),"Config mancante")
local cfg=assert(textutils.unserialize(cfgFile.readAll()),"Config non valida")
cfgFile.close()
assert(cfg.unit=="N01" and cfg.site=="MINIERA-01" and
 cfg.miner_autostart==false,"N01/autostart non sicuro")
assert(not fs.exists("/.megazero_miner_error"),"Errore miner presente")
assert(not fs.exists("/.megazero_miner_v23_N01_LAVORO"),
 "Checkpoint di scavo attivo: N01 non pronta")
local boot=assert(fs.open("/megazero_boot","r"),"Boot assente")
local header=boot.readLine() or "";boot.close()
assert(header:find("^%-%- MEGAZERO BOOT 1%.1"),
 "Boot 1.1 richiesto")
local target="/megazero_admin_agent"
assert(not fs.exists(target) and not fs.exists(target..".lua"),
 "Agente gia' installato: non sovrascrivo")
local stage="/.megazero_N01_admin_v13.new"
assert(not fs.exists(stage),"Staging agente gia' presente")
local URL="https://raw.githubusercontent.com/mycolbraga/MEGAZERO/be1f9a7bbbd35222be7324d49352dda7413e4122/scripts/turtle/megazero_admin_agent.lua"
local r,e=http.get(URL)
assert(r,"Download agente fallito: "..tostring(e))
local src=r.readAll();r.close()
assert(src and src:find("^%-%- MEGAZERO ADMIN AGENT v1%.3"),
 "Agente non v1.3")
local fn,reason=load(src,"=megazero_admin_agent_v13")
assert(fn,"Agente non compilabile: "..tostring(reason))
local f=assert(fs.open(stage,"w"));f.write(src);f.close()
fs.move(stage,target)
print("N01: Agente admin v1.3 installato. Nessuno scavo avviato.")
print("Boot, config, checkpoint e startup invariati.")
print("Attivazione agente al prossimo reboot, solo dopo conferma HOME fisica.")
