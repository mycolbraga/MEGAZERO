-- MEGAZERO | Upgrade centrale 54 a v1.4 HOME Y=-51
-- Compatibile con v1.2 o v1.3. Nessun comando alle Turtle.
assert(not turtle and os.getComputerID()==54,"Solo PC centrale 54")
local target="/megazero_control"
local backup="/.megazero_control_backup_before_v14"
local temp="/.megazero_control.new_v14"
assert(not fs.exists(backup) and not fs.exists(temp),
 "Backup/staging gia' presenti: verifica manuale")
local f=assert(fs.open(target,"r"),"Dashboard non installata")
local old=f.readLine() or "";f.close()
assert(old:match("^%-%- MEGAZERO CONTROL 1%.2") or
 old:match("^%-%- MEGAZERO CONTROL 1%.3"),
 "Installatore valido solo per dashboard v1.2 o v1.3")
local URL="https://raw.githubusercontent.com/mycolbraga/MEGAZERO/0f59ff4e12f78ecac41996bfee3fa5339f60523c/scripts/control/megazero_control.lua"
local resp,why=http.get(URL)
assert(resp,"Download dashboard fallito: "..tostring(why))
local data=resp.readAll();resp.close()
assert(type(data)=="string" and
 data:find("^%-%- MEGAZERO CONTROL 1%.4"),
 "Sorgente dashboard inattesa")
local fn,err=load(data,"=megazero_control_v14")
assert(fn,"Errore sintassi: "..tostring(err))
local out=assert(fs.open(temp,"w"));out.write(data);out.close()
assert(fs.exists(temp),"Staging assente")
fs.copy(target,backup)
assert(fs.exists(backup),"Backup non riuscito")
local success,reason=pcall(function()
 fs.delete(target)
 fs.move(temp,target)
end)
if not success then
 if fs.exists(backup) then
  if fs.exists(target) then fs.delete(target) end
  fs.copy(backup,target)
 end
 error("Update fallito: "..tostring(reason),0)
end
print("CENTRALE 54 v1.4 INSTALLATA: HOME di tutte le 40 Turtle a Y=-51.")
print("Al prossimo avvio il registro esistente verra' migrato senza perdere la telemetria.")
print("Nessuna Turtle mossa o avviata.")
print("Per riaprire: megazero_control")
