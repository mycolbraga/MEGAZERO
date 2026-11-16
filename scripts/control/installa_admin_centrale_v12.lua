-- MEGAZERO | Aggiorna centrale 54 da v1.1 a v1.2
-- Nessun comando alle Turtle; DB e startup invariati.
assert(not turtle and os.getComputerID()==54,
 "Solo computer centrale 54")
local target="/megazero_control"
local backup="/.megazero_control_backup_1_1"
local staged="/.megazero_control.new_v12"
local f=assert(fs.open(target,"r"),"Programma centrale mancante")
local first=f.readLine();f.close()
assert(first and first:find("^%-%- MEGAZERO CONTROL 1%.1"),
 "Versione centrale inattesa: richiesto v1.1")
assert(not fs.exists(backup) and not fs.exists(staged),
 "Backup/staging preesistenti: verificare prima")
local url="https://raw.githubusercontent.com/mycolbraga/MEGAZERO/registro/megazero/scripts/control/megazero_control.lua"
local response,why=http.get(url)
assert(response,"Download fallito: "..tostring(why))
local source=response.readAll();response.close()
assert(type(source)=="string" and
 source:find("^%-%- MEGAZERO CONTROL 1%.2"),
 "Dashboard scaricata non v1.2")
local code,parseError=load(source,"=megazero_control.lua")
assert(code,"Sintassi centrale non valida: "..tostring(parseError))
local out=assert(fs.open(staged,"w"))
out.write(source);out.close()
local ok,errorText=pcall(function()
 fs.copy(target,backup)
 fs.delete(target)
 fs.move(staged,target)
end)
if not ok then
 if fs.exists(backup) then
  if fs.exists(target) then fs.delete(target) end
  fs.copy(backup,target)
 end
 error("Aggiornamento non completato: "..tostring(errorText),0)
end
print("CENTRALE 54 aggiornata a v1.2")
print("Backup: "..backup)
print("Nessuna Turtle toccata; registro e startup invariati.")
print("Avvia: megazero_control")
