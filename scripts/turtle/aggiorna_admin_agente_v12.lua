-- MEGAZERO | Upgrade agente admin da v1.1 a v1.2, senza scavo
-- Su N02 ferma: wget run <URL> N02
assert(turtle,"Richiede una Turtle")
local arg={...}
local cfgFile=assert(fs.open("/megazero_config","r"))
local cfg=assert(textutils.unserialize(cfgFile.readAll()),"Config non valida")
cfgFile.close()
assert(arg[1]==cfg.unit and cfg.site=="MINIERA-01",
 "Sigla non corrispondente")
assert(cfg.miner_autostart==false,"Miner abilitato: STOP")
local target="/megazero_admin_agent"
local backup="/.megazero_admin_agent.backup_v11"
local staged="/.megazero_admin_agent.new_v12"
assert(fs.exists(target),"Agente precedente assente")
local f=assert(fs.open(target,"r"))
local first=f.readLine();f.close()
assert(first and first:find("^%-%- MEGAZERO ADMIN AGENT v1%.1"),
 "Agente non v1.1: non aggiorno")
local boot=assert(fs.open("/megazero_boot","r"))
local header=boot.readLine();boot.close()
assert(header and header:find("^%-%- MEGAZERO BOOT 1%.1"),
 "Boot v1.1 richiesto")
assert(not fs.exists(staged) and not fs.exists(backup),
 "Staging o backup v1.1 gia' presente")
local url="https://raw.githubusercontent.com/mycolbraga/MEGAZERO/registro/megazero/scripts/turtle/megazero_admin_agent.lua"
local response,why=http.get(url)
assert(response,"Download fallito: "..tostring(why))
local src=response.readAll();response.close()
assert(type(src)=="string" and src:find("^%-%- MEGAZERO ADMIN AGENT v1%.2"),
 "Versione scaricata non v1.2")
local compiled,err=load(src,"=megazero_admin_agent.lua")
assert(compiled,"Errore sintassi: "..tostring(err))
local w=assert(fs.open(staged,"w"));w.write(src);w.close()
local ok,problem=pcall(function()
 fs.copy(target,backup)
 fs.delete(target)
 fs.move(staged,target)
end)
if not ok then
 if fs.exists(backup) then
  if fs.exists(target) then fs.delete(target) end
  fs.copy(backup,target)
 end
 error("Installazione incompleta: "..tostring(problem),0)
end
print("AGENTE ADMIN v1.2 installato su "..cfg.unit)
print("Startup/config/miner INALTERATI, nessuno scavo.")
print("Reboot richiesto per caricare il nuovo agente.")
