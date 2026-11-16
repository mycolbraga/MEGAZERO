-- MEGAZERO | Aggiorna agente su Turtle ferma da v1.1/v1.2 a v1.3
-- Uso: wget run <URL> N02 (con boot v1.1 e miner_autostart=false)
assert(turtle,"Richiede una Turtle")
local args={...}
local cfgFile=assert(fs.open("/megazero_config","r"),"Config mancante")
local cfg=assert(textutils.unserialize(cfgFile.readAll()),"Config non valida")
cfgFile.close()
assert(cfg.site=="MINIERA-01" and cfg.unit==args[1] and
 cfg.miner_autostart==false,"Identita'/stato inattesi: STOP")
local target="/megazero_admin_agent"
local prev=assert(fs.open(target,"r"),"Agente non installato")
local header=prev.readLine() or "";prev.close()
assert(header:find("^%-%- MEGAZERO ADMIN AGENT v1%.1") or
 header:find("^%-%- MEGAZERO ADMIN AGENT v1%.2"),
 "Versione agente diversa dalla v1.1/v1.2")
local boot=assert(fs.open("/megazero_boot","r"),"Boot assente")
local bootLine=boot.readLine() or "";boot.close()
assert(bootLine:find("^%-%- MEGAZERO BOOT 1%.1"),"Boot v1.1 richiesto")
local backup="/.megazero_admin_agent.backup_before_v13"
local stage="/.megazero_admin_agent.new_v13"
assert(not fs.exists(backup) and not fs.exists(stage),
 "Aggiornamento gia' preparato o backup presente")
local URL="https://raw.githubusercontent.com/mycolbraga/MEGAZERO/be1f9a7bbbd35222be7324d49352dda7413e4122/scripts/turtle/megazero_admin_agent.lua"
local response,why=http.get(URL)
assert(response,"Download fallito: "..tostring(why))
local src=response.readAll();response.close()
assert(src and src:find("^%-%- MEGAZERO ADMIN AGENT v1%.3"),
 "Sorgente agente non v1.3")
local fn,err=load(src,"=megazero_admin_agent")
assert(fn,"Sintassi agente errata: "..tostring(err))
local f=assert(fs.open(stage,"w"));f.write(src);f.close()
fs.copy(target,backup)
assert(fs.exists(backup),"Backup agente non riuscito")
local ok,reason=pcall(function()
 fs.delete(target)
 fs.move(stage,target)
end)
if not ok then
 if fs.exists(backup) then
  if fs.exists(target) then fs.delete(target) end
  fs.copy(backup,target)
 end
 error("Agente non aggiornato: "..tostring(reason),0)
end
print("AGENTE ADMIN v1.3 installato su "..cfg.unit)
print("Nessun movimento e nessun avvio. Reboot necessario per caricare l'agente.")
