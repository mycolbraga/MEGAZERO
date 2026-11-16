-- MEGAZERO | Upgrade agente v1.0 -> v1.1 senza movimento
-- Uso sulla N02 ferma: wget run <URL> N02
assert(turtle,"Comando per Turtle")
local args={...}
local cfgFile=assert(fs.open("/megazero_config","r"))
local cfg=assert(textutils.unserialize(cfgFile.readAll()),"Config non valida")
cfgFile.close()
assert(args[1]==cfg.unit and cfg.site=="MINIERA-01",
 "Sigla diversa dalla Turtle")
assert(cfg.miner_autostart==false,
 "Miner abilitato: installazione agente rifiutata")
local target="/megazero_admin_agent"
assert(fs.exists(target),"Agente precedente assente")
local f=assert(fs.open(target,"r"))
local header=f.readLine();f.close()
assert(header and header:find("^%-%- MEGAZERO ADMIN AGENT v1%.0"),
 "Agente diverso dalla v1.0: non sovrascrivo")
local boot=assert(fs.open("/megazero_boot","r"))
local bootHeader=boot.readLine();boot.close()
assert(bootHeader and bootHeader:find("^%-%- MEGAZERO BOOT 1%.1"),
 "Boot v1.1 richiesto")
local temp="/.megazero_admin_agent.new_v11"
local backup="/.megazero_admin_agent.backup_v10"
assert(not fs.exists(temp) and not fs.exists(backup),
 "Installazione precedente incompleta o backup gia' presente")
local url="https://raw.githubusercontent.com/mycolbraga/MEGAZERO/registro/megazero/scripts/turtle/megazero_admin_agent.lua"
local response,err=http.get(url)
assert(response,"Download fallito: "..tostring(err))
local source=response.readAll();response.close()
assert(type(source)=="string" and
 source:find("^%-%- MEGAZERO ADMIN AGENT v1%.1"),
 "Agente scaricato non v1.1")
local compiled,why=load(source,"=megazero_admin_agent.lua")
assert(compiled,"Agente non valido: "..tostring(why))
local out=assert(fs.open(temp,"w"))
out.write(source);out.close()
local ok,reason=pcall(function()
 fs.copy(target,backup)
 fs.delete(target)
 fs.move(temp,target)
end)
if not ok then
 if fs.exists(backup) then
  if fs.exists(target) then fs.delete(target) end
  fs.copy(backup,target)
 end
 error("Upgrade fallito, verificare backup: "..tostring(reason),0)
end
print("AGENTE ADMIN v1.1 installato su "..cfg.unit)
print("Nessuno scavo, startup e config invariati.")
print("Riavvia la Turtle SOLO quando vuoi caricare il nuovo agente.")
