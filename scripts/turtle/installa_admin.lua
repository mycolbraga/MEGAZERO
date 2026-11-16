-- MEGAZERO | Bootstrap admin v1.1 su Turtle ferma | NON avvia scavo
-- Uso: wget run <URL> N02
assert(turtle,"Esegui questo installatore su una Turtle, non sulla centrale")
local args={...}
local unit=args[1]
local cfgPath="/megazero_config"
local bootPath="/megazero_boot"
local agentPath="/megazero_admin_agent"
local backup="/.megazero_boot_pre_admin"
local bootTemp="/.megazero_boot.new_admin"
local agentTemp="/.megazero_admin_agent.new"
local function read(path)
 local f=assert(fs.open(path,"r"),"File mancante: "..path)
 local data=f.readAll();f.close();return data
end
local cfg=assert(textutils.unserialize(read(cfgPath)),"Config non valida")
assert(type(unit)=="string" and unit:match("^[NOSE]%d%d$")
 and cfg.unit==unit and cfg.site=="MINIERA-01",
 "Sigla non corrispondente alla configurazione di questa Turtle")
assert(cfg.miner_autostart==false,
 "Turtle abilitata allo scavo: bootstrap amministrativo rifiutato")
local oldBoot=read(bootPath)
assert(oldBoot:find("^%-%- MEGAZERO BOOT 1%.0"),
 "Boot diverso dalla v1.0: non sovrascrivo")
for _,p in ipairs({backup,bootTemp,agentTemp,agentPath,agentPath..".lua"}) do
 assert(not fs.exists(p),"Installazione esistente/incompleta: "..p)
end
assert(peripheral.find("modem",function(_,m)
 return m.isWireless and m.isWireless()
end),"Modem wireless/Ender assente")

local base="https://raw.githubusercontent.com/mycolbraga/MEGAZERO/registro/megazero/scripts/turtle/"
local function fetch(remote,prefix)
 local response,why=http.get(base..remote)
 assert(response,"Download fallito "..remote..": "..tostring(why))
 local content=response.readAll();response.close()
 assert(type(content)=="string" and content:sub(1,#prefix)==prefix,
  "Firma inattesa di "..remote)
 local chunk,parseError=load(content,"="..remote)
 assert(chunk,"Sintassi non valida "..remote..": "..tostring(parseError))
 return content
end
print("Bootstrap amministrativo "..unit.." (MINER FERMO)")
local newAgent=fetch("megazero_admin_agent.lua","-- MEGAZERO ADMIN AGENT v1.1")
local newBoot=fetch("megazero_boot.lua","-- MEGAZERO BOOT 1.1")
local function write(path,body)
 local f=assert(fs.open(path,"w"),"Impossibile scrivere "..path)
 f.write(body);f.close()
end
write(agentTemp,newAgent)
write(bootTemp,newBoot)
local ok,err=pcall(function()
 fs.copy(bootPath,backup)
 fs.move(agentTemp,agentPath)
 fs.delete(bootPath)
 fs.move(bootTemp,bootPath)
end)
if not ok then
 if fs.exists(backup) then
  if fs.exists(bootPath) then fs.delete(bootPath) end
  fs.copy(backup,bootPath)
 end
 printError("Installazione annullata: "..tostring(err))
 print("Se necessario, controlla i file .new e backup prima di riprovare")
 return
end
print("AGENTE v1.1 e BOOT v1.1 installati su "..unit)
print("STARTUP e CONFIG INALTERATI, miner_autostart=false")
print("Nessun movimento. Esegui REBOOT solo quando vuoi avviare l'ascolto.")
