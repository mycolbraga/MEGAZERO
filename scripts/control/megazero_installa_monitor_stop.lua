-- MEGAZERO PC54 | Installa monitor 1.7 con FERMA TUTTO; non muove Turtle.
assert(not turtle and os.getComputerID()==54,"Eseguire solo su PC54")
local url="https://raw.githubusercontent.com/mycolbraga/MEGAZERO/"..
 "4809d4cf85a143b10b2d26fa85011a15712f6853/"..
 "scripts/control/megazero_control.lua"
local resp,why=http.get(url)
assert(resp,"Download monitor fallito: "..tostring(why))
local code=resp.readAll();resp.close()
assert(code:find("^%-%- MEGAZERO CONTROL 1%.7"),
 "Sorgente monitor inattesa")
assert(code:find("FERMA TUTTO",1,true) and
 code:find('command="STOP_ALL"',1,true),
 "Monitor non include lo STOP TUTTO completo")
local fn,err=load(code,"=megazero_control_17")
assert(fn,"Monitor non compilabile: "..tostring(err))
local target=fs.exists("/megazero_control") and "/megazero_control" or
 (fs.exists("/megazero_control.lua") and "/megazero_control.lua" or
 "/megazero_control")
local function read(p)
 local h=fs.open(p,"r")
 if not h then return nil end
 local s=h.readAll();h.close();return s
end
if read(target)==code then
 print("Monitor 1.7 gia' installato: "..target)
 print("Nessun cambiamento. Per visualizzarlo: "..target)
 return
end
local old=read(target)
local space=fs.getFreeSpace("/")
if type(space)=="number" then
 assert(space>#code+(old and #old or 0)+4096,
  "Spazio PC54 insufficiente per staging e backup")
end
local tmp="/.megazero_control_v17_stage"
assert(not fs.exists(tmp),"Staging preesistente: controllo manuale richiesto")
local f=assert(fs.open(tmp,"w"),"Non posso creare file temporaneo")
f.write(code);f.close()
assert(read(tmp)==code,"Staging non integro")
local backup="/.megazero_control_v16_backup"
if old then
 assert(not fs.exists(backup),"Backup monitor gia presente; non sovrascrivo")
 fs.copy(target,backup)
 assert(read(backup)==old,"Backup monitor non verificato")
end
if fs.exists(target) then fs.delete(target) end
local ok,whyMove=pcall(fs.move,tmp,target)
if not ok or read(target)~=code then
 if fs.exists(target) then fs.delete(target) end
 if old and fs.exists(backup) then fs.copy(backup,target) end
 error("Installazione fallita, ripristino vecchio monitor: "..tostring(whyMove))
end
print("Monitor 1.7 installato in "..target)
print("Backup vecchio monitor: "..(old and backup or "non presente"))
print("Pulsante FERMA TUTTO disponibile al prossimo avvio del monitor.")
print("NESSUNA TURTLE AVVIATA, FERMATA O SPOSTATA.")
