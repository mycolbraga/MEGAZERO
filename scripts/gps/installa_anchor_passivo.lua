-- MEGAZERO | installazione GPS passivo su G1-G4 | nessuna Turtle toccata
-- Interrompere prima il vecchio "gps host" con Ctrl+T.
-- Uso: wget run <URL> G1
assert(not turtle,"Solo computer GPS")
local arg={...}
local name=arg[1]
local xyz={
 G1={2097,108,2713},G2={2100,108,2713},
 G3={2100,108,2716},G4={2100,111,2716}
}
local pos=assert(xyz[name],"Inserisci G1, G2, G3 oppure G4")
local boot="/startup.lua"
local bootBak="/startup_pre_megazero_gps.lua"
local bootTmp="/startup.new_megazero_gps"
local target="/megazero_anchor_passivo"
local stage="/megazero_anchor_passivo.new"
for _,p in ipairs({bootBak,bootTmp,target,stage}) do
 assert(not fs.exists(p),"File gia' presente, non sovrascrivo: "..p)
end
local f=assert(fs.open(boot,"r"),"startup.lua assente")
local old=f.readAll();f.close()
assert(old:find("gps",1,true) and old:find("host",1,true),
 "Startup non contiene il vecchio GPS host")
for _,v in ipairs(pos) do
 assert(old:find(tostring(v),1,true),
 "Coordinate vecchio host non coerenti con "..name)
end
local modem=peripheral.find("modem",function(_,m)
 return m.isWireless and m.isWireless()
end)
assert(modem,"Ender Modem non trovato")
local url="https://raw.githubusercontent.com/mycolbraga/MEGAZERO/e46957be94f18d9411abbf3e0c9d166b028ef994/scripts/gps/megazero_anchor_passivo.lua"
local response,err=http.get(url)
assert(response,"Download fallito: "..tostring(err))
local code=response.readAll();response.close()
assert(code:find("^%-%- MEGAZERO | GPS host %+ rilevamento passivo Turtle v1%.0"),
 "Codice inatteso")
local chunk,why=load(code,"=megazero_anchor_passivo")
assert(chunk,"Sintassi non valida: "..tostring(why))
local f1=assert(fs.open(stage,"w"));f1.write(code);f1.close()
local bootSource='shell.run("/megazero_anchor_passivo", "'..name..'")\n'
local f2=assert(fs.open(bootTmp,"w"));f2.write(bootSource);f2.close()
local bf,bwhy=load(bootSource,"=startup.lua")
assert(bf,"Nuovo startup non compilabile: "..tostring(bwhy))
fs.copy(boot,bootBak)
assert(fs.exists(bootBak) and fs.getSize(bootBak)==#old,
 "Backup startup non verificato, STOP")
fs.move(stage,target)
fs.delete(boot)
fs.move(bootTmp,boot)
print(name..": GPS host + monitoraggio passivo INSTALLATI.")
print("Vecchio startup conservato in "..bootBak)
print("Nessuna Turtle modificata. Esegui: reboot")
