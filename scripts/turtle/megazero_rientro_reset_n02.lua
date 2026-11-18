-- MEGAZERO | N02 PC14 | RIENTRO GPS + NUOVO CHECKPOINT SOLO N02
-- NON tocca altre Turtle, nessun miner, nessuna deviazione di settore.
assert(turtle and os.getComputerID()==14,"Questo comando e' SOLO per N02 PC14")
local function read(p)
 local h=fs.open(p,"r"); if not h then return nil end
 local v=h.readAll();h.close();return v
end
local function pos()
 local x,y,z=gps.locate(4,false)
 assert(type(x)=="number" and type(y)=="number" and
  type(z)=="number","GPS non disponibile: nessun movimento")
 return x,y,z
end
local rawCfg=assert(read("/megazero_config"),"Configurazione assente")
local cfg=assert(textutils.unserialize(rawCfg),"Configurazione illeggibile")
assert(cfg.site=="MINIERA-01" and cfg.unit=="N02","Non e' N02")
assert(read("/megazero_miner"):find("^%-%- MEGAZERO MINER v2%.3%.21"),
 "Versione miner diversa da 2.3.21: STOP")
local x,y,z=pos()
assert(x==2117 and z==2994 and y>=-51 and y<=-25 and y%1==0,
 "N02 non nel pozzo atteso (2117, -25..-51, 2994): STOP")
local fuel=turtle.getFuelLevel()
assert(type(fuel)~="number" or fuel>=y+51+4,
 "Carburante insufficiente per rientro")
local cpPath="/.megazero_miner_v23_N02_LAVORO"
assert(fs.exists(cpPath),"Checkpoint originale mancante")
local destBackup="/.megazero_n02_checkpoint_originale_salvato"
assert(not fs.exists(destBackup),"Backup N02 gia presente: STOP")
local errPath="/.megazero_miner_error"
local errBackup="/.megazero_n02_errore_originale_salvato"
assert(not fs.exists(errBackup),"Backup errore N02 gia presente: STOP")
local tempCfg="/.megazero_n02_cfg_home.tmp"
assert(not fs.exists(tempCfg),"Configurazione temporanea gia presente: STOP")
local safeBlocks={
 ["minecraft:stone"]=true,["minecraft:deepslate"]=true,
 ["minecraft:cobbled_deepslate"]=true,["minecraft:cobblestone"]=true,
 ["minecraft:andesite"]=true,["minecraft:diorite"]=true,
 ["minecraft:granite"]=true,["minecraft:tuff"]=true,
 ["minecraft:gravel"]=true,["minecraft:sand"]=true,
 ["minecraft:dirt"]=true,["minecraft:calcite"]=true
}
print("N02 PC14 | GPS "..x..","..y..","..z)
print("Rientro nella propria colonna, nessun reset prima della HOME.")
-- Il pozzo e' la cella esterna N02: X2117 Z2994.
while y> -51 do
 local expected=y-1
 local ok,why=turtle.down()
 if not ok then
  local present,block=turtle.inspectDown()
  local name=present and block and block.name or "?"
  assert(safeBlocks[name]==true,
   "Discesa bloccata da "..name.." a Y"..expected.."; nessuno scavo")
  local dug,reason=turtle.digDown()
  assert(dug,"Non posso liberare la colonna: "..tostring(reason))
  ok,why=turtle.down()
 end
 assert(ok,"Discesa interrotta: "..tostring(why))
 local a,b,c=pos()
 assert(a==2117 and b==expected and c==2994,
  "GPS inatteso dopo discesa: FERMO")
 y=b
end
print("Pozzo raggiunto: 2117 -51 2994")
-- All'inizio della risalita il miner punta a NORD; un singolo BACK
-- dovrebbe riportare alla postazione. Se non coincide, annulla il passo.
local ok,reason=turtle.back()
assert(ok,"HOME ostruita: "..tostring(reason))
local a,b,c=pos()
if a~=2117 or b~=-51 or c~=2995 then
 local rollback=turtle.forward()
 assert(rollback,"Direzione non confermata e ritorno indietro fallito")
 local rx,ry,rz=pos()
 assert(rx==2117 and ry==-51 and rz==2994,"GPS non tornato nel pozzo")
 error("Orientamento diverso da NORD: STOP, nessun checkpoint modificato")
end
print("GPS HOME N02 confermata: 2117 -51 2995")
-- La procedura agisce solo ora sul checkpoint di N02.
local newCp={x=2117,y=-51,z=2995,d=0,path={},pending=nil,
 level=1,distance=0,finished=false,ore=0,buckets=0,blocked=0,
 waterPending=false,incomplete={},completedLevels={},retryComplete=false,
 seals={},waterSeals={}}
local newRaw=textutils.serialize(newCp)
local newCfg={}
for k,v in pairs(cfg) do newCfg[k]=v end
newCfg.miner_autostart=false
local cfgText=textutils.serialize(newCfg)
assert(fs.getFreeSpace("/")>=#newRaw+#cfgText+128,
 "GPS HOME raggiunta, ma poco spazio per checkpoint/config: NON modifica file")
-- Archivia il vecchio checkpoint senza duplicarlo.
fs.move(cpPath,destBackup)
local h=fs.open(cpPath,"w")
if not h then
 fs.move(destBackup,cpPath)
 error("Spazio insufficiente per checkpoint: vecchio ripristinato")
end
h.write(newRaw);h.close()
assert(read(cpPath)==newRaw,"Nuovo checkpoint non verificato")
-- L'originale config e' conservato: ripristinabile, senza copiare su disco.
local cfgBackup="/.megazero_n02_cfg_originale_salvata"
assert(not fs.exists(cfgBackup),"Backup config preesistente: STOP")
fs.move("/megazero_config",cfgBackup)
local cfile=fs.open("/megazero_config","w")
if not cfile then
 fs.move(cfgBackup,"/megazero_config")
 error("Config non scrivibile: originale ripristinata")
end
cfile.write(cfgText);cfile.close()
local persisted=assert(textutils.unserialize(read("/megazero_config")))
assert(persisted.unit=="N02" and persisted.miner_autostart==false,
 "Autostart non disattivato: verificare prima di riavviare")
assert(read(cpPath)==newRaw,"Checkpoint alterato dopo salvataggio")
if fs.exists(errPath) then fs.move(errPath,errBackup) end
local stop="/.megazero_stop_all.request"
if fs.exists(stop) then
 local stopBackup="/.megazero_n02_stop_originale_salvato"
 assert(not fs.exists(stopBackup),"Backup STOP esistente: non cancello")
 fs.move(stop,stopBackup)
end
print("N02 HOME, CHECKPOINT NUOVO 0%, AUTOSTART OFF")
print("Vecchio checkpoint e errore archiviati; 39 Turtle intatte.")
print("Riavvio N02, senza scavo.")
sleep(1)
os.reboot()
