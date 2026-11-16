-- MEGAZERO | Dashboard v1.5: posizione e progresso precedenti non attuali
-- Solo PC54. Non invia comandi alle Turtle, non cambia lo startup o il registro.
assert(not turtle and os.getComputerID()==54,"Solo centrale PC 54")
local target="/megazero_control"
local backup="/.megazero_control_backup_before_v15"
local temp="/.megazero_control.new_v15"
assert(not fs.exists(backup) and not fs.exists(temp),
 "Backup/staging v1.5 preesistente: STOP")
local f=assert(fs.open(target,"r"),"Dashboard assente")
local first=f.readLine() or "";f.close()
assert(first:find("^%-%- MEGAZERO CONTROL 1%.4"),
 "Richiesta centrale v1.4: versione installata inattesa")
local url="https://raw.githubusercontent.com/mycolbraga/MEGAZERO/10f0b9db17ad678c5e0bd007d043dda0e4178f76/scripts/control/megazero_control.lua"
local response,err=http.get(url)
assert(response,"Download fallito: "..tostring(err))
local src=response.readAll();response.close()
assert(type(src)=="string" and
 src:find("^%-%- MEGAZERO CONTROL 1%.5"),
 "Sorgente centrale non v1.5")
local fn,why=load(src,"=megazero_control_v15")
assert(fn,"Sintassi dashboard errata: "..tostring(why))
local out=assert(fs.open(temp,"w"));out.write(src);out.close()
assert(fs.exists(temp) and fs.getSize(temp)==#src,"Staging non verificato")
fs.copy(target,backup)
assert(fs.exists(backup),"Backup fallito")
local ok,errorText=pcall(function()
 fs.delete(target)
 fs.move(temp,target)
end)
if not ok then
 if fs.exists(backup) then
  if fs.exists(target) then fs.delete(target) end
  fs.copy(backup,target)
 end
 error("Aggiornamento fallito: "..tostring(errorText),0)
end
print("CENTRALE v1.5 installata: POS di PREPARAZIONE non verificata, progress vecchio rimosso.")
print("DB e startup conservati. Nessuna Turtle mossa o avviata.")
print("Riapri dashboard: megazero_control")
