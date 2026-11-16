-- MEGAZERO | Aggiornamento centrale 1.1 - SOLO PING/STATUS
-- Non modifica startup, registro, config o Turtle
assert(not turtle,"Eseguire sul COMPUTER centrale, non sulle Turtle")
assert(os.getComputerID()==54,"Computer inatteso: richiesto ID 54")
local target="/megazero_control"
local backup="/.megazero_control_backup_1_0"
local staged="/.megazero_control.new_admin"
assert(fs.exists(target),"Programma /megazero_control non trovato")
assert(not fs.exists(backup),"Backup gia' esistente; controllare prima di aggiornare")
assert(not fs.exists(staged),"Aggiornamento incompleto: "..staged)
local current=assert(fs.open(target,"r"));local header=current.readLine();current.close()
assert(type(header)=="string" and header:find("^%-%- MEGAZERO CONTROL 1%.0"),
 "Versione centrale diversa dalla 1.0; non sovrascrivo")
local url="https://raw.githubusercontent.com/mycolbraga/MEGAZERO/registro/megazero/scripts/control/megazero_control.lua"
local response,why=http.get(url)
assert(response,"Download centrale fallito: "..tostring(why))
local body=response.readAll();response.close()
assert(type(body)=="string" and body:find("^%-%- MEGAZERO CONTROL 1%.1"),
 "File centrale inatteso")
local compiled,err=load(body,"=megazero_control.lua")
assert(compiled,"Sintassi centrale non valida: "..tostring(err))
local file=assert(fs.open(staged,"w"))
file.write(body);file.close()
local ok,reason=pcall(function()
 fs.copy(target,backup)
 fs.delete(target)
 fs.move(staged,target)
end)
if not ok then
 if fs.exists(backup) then
  if fs.exists(target) then fs.delete(target) end
  fs.copy(backup,target)
 end
 error("Aggiornamento non completato: "..tostring(reason),0)
end
print("Centrale 54 aggiornata: MEGAZERO CONTROL 1.1")
print("Backup: "..backup)
print("Registro e startup INALTERATI. Nessun comando Turtle inviato.")
print("Avvia: megazero_control")
