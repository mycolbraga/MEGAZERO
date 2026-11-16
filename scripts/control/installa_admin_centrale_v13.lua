-- MEGAZERO | Aggiorna centrale 54 da v1.2 a v1.3
-- Database, startup e Turtle invariati; nessun comando remoto eseguito.
assert(not turtle and os.getComputerID()==54,"Solo Computer 54")
local target="/megazero_control"
local backup="/.megazero_control_backup_1_2"
local temp="/.megazero_control.new_v13"
local f=assert(fs.open(target,"r"),"Programma centrale assente")
local head=f.readLine();f.close()
assert(head and head:find("^%-%- MEGAZERO CONTROL 1%.2"),
 "Centrale non v1.2: non sovrascrivo")
assert(not fs.exists(backup) and not fs.exists(temp),
 "Backup o staging precedente presente: verifica prima")
local url="https://raw.githubusercontent.com/mycolbraga/MEGAZERO/registro/megazero/scripts/control/megazero_control.lua"
local response,why=http.get(url)
assert(response,"Download centrale fallito: "..tostring(why))
local src=response.readAll();response.close()
assert(type(src)=="string" and src:find("^%-%- MEGAZERO CONTROL 1%.3"),
 "Versione inattesa dalla repository")
local fn,err=load(src,"=megazero_control.lua")
assert(fn,"Errore sintassi: "..tostring(err))
local w=assert(fs.open(temp,"w"));w.write(src);w.close()
local ok,problem=pcall(function()
 fs.copy(target,backup)
 fs.delete(target)
 fs.move(temp,target)
end)
if not ok then
 if fs.exists(backup) then
  if fs.exists(target) then fs.delete(target) end
  fs.copy(backup,target)
 end
 error("Aggiornamento non completato: "..tostring(problem),0)
end
print("CENTRALE 54 v1.3 installata.")
print("Backup: "..backup)
print("Registro e startup invariati, NESSUNA Turtle avviata.")
print("Riapri con: megazero_control")
