-- MEGAZERO | N02 recupero SOLO rientro da checkpoint calibrato
-- Usa miner v2.3.10 in modalita' rientroOnly (non esegue nuovo scavo).
-- Non cancella error latch, non attiva autostart, non riavvia.
assert(turtle and os.getComputerID()==14,"Questo programma e' SOLO per N02 PC14")
local SRC="https://raw.githubusercontent.com/mycolbraga/MEGAZERO/"..
 "5bc9dbcdd7b2d402033b012f9a7a2a20a669da4e/scripts/turtle/megazero_miner.lua"
local CP="/.megazero_miner_v23_N02_LAVORO"
local CAL="/.megazero_N02_calibrazione_info"
local BACKUP="/.megazero_N02_rientro81_checkpoint_originale"
local CFG="/megazero_config"
local function read(path)
 local f=assert(fs.open(path,"r"),"File non leggibile: "..path)
 local s=f.readAll();f.close();return s
end
local function loc()
 local x,y,z=gps.locate(3,false)
 assert(type(x)=="number" and type(y)=="number" and
  type(z)=="number","GPS non disponibile: rientro non avviato")
 return x,y,z
end
local function near(a,b) return math.abs(a-b)<0.25 end
local cfg=assert(textutils.unserialize(read(CFG)),"Configurazione illeggibile")
assert(cfg.site=="MINIERA-01" and cfg.unit=="N02","Identita' diversa da N02")
local calib=read(CAL)
assert(calib:find("OK | GPS ritorno",1,true) and
 calib:find("direzione reale 2",1,true),
 "Calibrazione non confermata: rientro non avviato")
local raw=read(CP)
local s=assert(textutils.unserialize(raw),"Checkpoint non leggibile")
assert(type(s)=="table" and type(s.path)=="table" and #s.path==81 and
 s.pending==nil and s.x==2116 and s.y==-5 and s.z==2975 and
 s.d==2 and s.level==1 and s.finished~=true,
 "Checkpoint cambiato dopo calibrazione: rientro NON avviato")
local x,y,z=loc()
assert(near(x,s.x) and near(y,s.y) and near(z,s.z),
 "GPS iniziale discordante, non muovo N02")
assert(type(turtle.getFuelLevel())=="number" and turtle.getFuelLevel()>#s.path+200,
 "Carburante insufficiente per rientro con margine")
assert(not fs.exists(BACKUP),"Rientro gia' tentato: STOP, non ripetere alla cieca")
-- Verifica codice esatto prima di toccare file/checkpoint.
local response,why=http.get(SRC)
assert(response,"Download miner fallito: "..tostring(why))
local code=response.readAll();response.close()
assert(code:find("^%-%- MEGAZERO MINER v2%.3%.10"),
 "Versione miner di recupero diversa da v2.3.10")
local chunk,err=load(code,"=megazero_miner_rientro")
assert(chunk,"Miner non compilabile: "..tostring(err))
local runner=assert(chunk(),"Modulo miner non valido")
assert(type(runner)=="function","Miner rientro non utilizzabile")
local network=assert(dofile("/megazero_rete"),"Modulo telemetria non disponibile")
local agent,netErr=network.new("N02","MINIERA-01",54)
assert(agent,netErr or "Telemetria non disponibile")
-- Impedisce un riavvio involontario dello SCAVO dopo il recupero.
local configBackup="/.megazero_N02_rientro81_config_originale"
assert(not fs.exists(configBackup),"Backup config recupero gia' presente")
fs.copy(CP,BACKUP)
assert(read(BACKUP)==raw,"Backup checkpoint incompleto")
fs.copy(CFG,configBackup)
local cfgSaved=read(CFG)
local disarmed={}
for k,v in pairs(cfg) do disarmed[k]=v end
disarmed.miner_autostart=false
local temp="/.megazero_N02_rientro81_config_tmp"
assert(not fs.exists(temp),"File config temporaneo preesistente")
local f=assert(fs.open(temp,"w"))
f.write(textutils.serialize(disarmed));f.close()
fs.delete(CFG)
fs.move(temp,CFG)
print("N02 | RIENTRO CONTROLLATO SOLO HOME")
print("81 passi salvati. GPS reale e direzione convalidati.")
print("Autostart OFF. Niente nuovo scavo.")
print("NON PREMERE CTRL+T / NON RIAVVIARE durante il rientro.")
-- La modalita' rientroOnly del miner ripercorre la traccia al contrario,
-- salva il checkpoint a ogni passo e infine prova lo scarico in HOME.
local ok,problem=pcall(runner,agent,disarmed,{rientroOnly=true})
if not ok then
 printError("Rientro interrotto: "..tostring(problem))
 printError("NON riavviare o ritentare: prima leggere GPS e checkpoint.")
 return
end
local latest=assert(textutils.unserialize(read(CP)),"Checkpoint finale illeggibile")
local gx,gy,gz=loc()
local home=latest.x==2117 and latest.y==-51 and latest.z==2995 and
 latest.pending==nil and type(latest.path)=="table" and #latest.path==0 and
 near(gx,2117) and near(gy,-51) and near(gz,2995)
if not home then
 printError("HOME NON CONFERMATA: non riavviare, verificare checkpoint")
 print("GPS="..gx..","..gy..","..gz.." | restanti="..
  tostring(type(latest.path)=="table" and #latest.path or "?"))
 return
end
print("N02: HOME CONFERMATA! GPS "..gx..","..gy..","..gz)
print("Checkpoint: 0 passi, pending=nil, livello "..tostring(latest.level)..
 " dist "..tostring(latest.distance))
print("Miner non riavviato, autostart OFF; latch errore da archiviare DOPO verifica.")
print("Lascia N02 ferma e manda schermata.")
