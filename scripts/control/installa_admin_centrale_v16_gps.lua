-- MEGAZERO | Upgrade dashboard PC54 da 1.5 a 1.6 con GPS passivo
-- Preserva registro, telemetria e tutti i comandi esistenti.
assert(not turtle and os.getComputerID()==54,"Solo centrale PC54")
local target="/megazero_control"
local backup="/.megazero_control_backup_before_v16"
local temp="/.megazero_control.new_v16"
assert(not fs.exists(backup) and not fs.exists(temp),
 "Backup/staging gia' presente: non sovrascrivo")
local old=assert(fs.open(target,"r"),"Dashboard assente")
local head=old.readLine() or "";old.close()
assert(head:find("^%-%- MEGAZERO CONTROL 1%.5"),
 "Dashboard non v1.5: non sovrascrivo")
local url="https://raw.githubusercontent.com/mycolbraga/MEGAZERO/e0da9284ce8b1e52977e7044d027dba2ecee5134/scripts/control/megazero_control.lua"
local r,err=http.get(url)
assert(r,"Download dashboard non riuscito: "..tostring(err))
local code=r.readAll();r.close()
assert(code:find("^%-%- MEGAZERO CONTROL 1%.6"),"Dashboard non v1.6")
local chunk,why=load(code,"=megazero_control_v16")
assert(chunk,"Lua invalido: "..tostring(why))
local out=assert(fs.open(temp,"w"));out.write(code);out.close()
assert(fs.getSize(temp)==#code,"Staging dashboard non integro")
fs.copy(target,backup)
assert(fs.exists(backup),"Backup non riuscito")
local ok,why=pcall(function()
 fs.delete(target)
 fs.move(temp,target)
end)
if not ok then
 if fs.exists(backup) then
  if fs.exists(target) then fs.delete(target) end
  fs.copy(backup,target)
 end
 error("Aggiornamento fallito: "..tostring(why),0)
end
print("CENTRALE v1.6: GPS PASSIVO disponibile.")
print("Monitoraggio SOLO informativo; nessuna Turtle modificata.")
print("Registro e startup conservati. Esegui: megazero_control")
