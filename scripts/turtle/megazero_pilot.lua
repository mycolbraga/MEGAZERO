-- MEGAZERO | Primo test minerario v1.0 - solo N01
-- 8 blocchi longitudinali max, Y=-53 -> Y=-1 (test), rientro e scarico.
-- Non e' lo scavo selettivo completo; nessun'altra Turtle viene avviata.
-- Richiede /megazero_config, /megazero_rete e piccone della Mining Turtle.

local CONFIG = "/megazero_config"
local SAVE = "/.megazero_pilot_state"
local SITE = "MINIERA-01"
local UNIT = "N01"
local LIMIT = 8
local TARGET_Y = -1 -- turtle a Y=-1, spazio testa fino a Y=0
local DIR = { N=0, E=1, S=2, O=3 }
local DX = { [0]=0,[1]=1,[2]=0,[3]=-1 }
local DZ = { [0]=-1,[1]=0,[2]=1,[3]=0 }
local BACK = { [0]=2,[1]=3,[2]=0,[3]=1 }

local function fileRead(path)
  if not fs.exists(path) then return nil end
  local f = assert(fs.open(path,"r"))
  local value = f.readAll()
  f.close()
  return value
end
local function fileWrite(path, value)
  local f = assert(fs.open(path,"w"))
  f.write(value)
  f.close()
end
local raw = assert(fileRead(CONFIG), "Configurazione mancante: "..CONFIG)
local cfg = assert(textutils.unserialize(raw), "Configurazione illeggibile")
assert(cfg.site==SITE and cfg.unit==UNIT,
  "Questo test e' SOLO per N01 della MINIERA-01")
assert(turtle, "Il programma funziona solo su Mining Turtle")

-- Mappa compatibile con le 40 postazioni del progetto: N01 e' a NE.
local home = {x=2119,y=-53,z=2995,d=DIR.N}
local s = {x=home.x,y=home.y,z=home.z,d=home.d,path={},pending=nil,done=false}
local saved = fileRead(SAVE)
if saved then
  local old = textutils.unserialize(saved)
  assert(type(old)=="table" and type(old.path)=="table"
    and old.unit==UNIT and old.site==SITE,
    "Stato precedente incoerente: test BLOCCATO")
  s=old
end
s.unit=UNIT
s.site=SITE
local function checkpoint()
  fileWrite(SAVE,textutils.serialize(s))
end
checkpoint()

local telemetry = dofile("/megazero_rete")
assert(type(telemetry)=="table" and telemetry.new, "Modulo rete mancante")
local agent,err = telemetry.new(UNIT,SITE,cfg.central or 54)
assert(agent,err or "Modem non disponibile")
local function signal(status, detail, errorText)
  pcall(function()
    agent:report(status,{
      x=s.x,y=s.y,z=s.z,fuel=turtle.getFuelLevel(),
      detail=detail,error=errorText
    })
  end)
  print(status..": "..tostring(detail))
end

local function atHome()
  return s.x==home.x and s.y==home.y and s.z==home.z
end
local function inBase(x,z)
  return x>=2099 and x<=2119 and z>=2995 and z<=3015
end
local function inSector(x,z)
  return x>=2118 and x<=2119 and z>=2695 and z<=2994
end
local function canOccupy(x,y,z)
  if x==home.x and y==home.y and z==home.z then return true end
  return inSector(x,z) and y>=-63 and y<=0
end

local function coordsAfter(kind)
  local x,y,z=s.x,s.y,s.z
  if kind=="F" then x=x+DX[s.d]; z=z+DZ[s.d]
  elseif kind=="U" then y=y+1
  elseif kind=="D" then y=y-1
  else error("Passo sconosciuto") end
  return x,y,z
end
local function facing(want)
  while s.d~=want do
    local right=(want-s.d)%4
    local ok
    if right==3 then
      ok=turtle.turnLeft()
      assert(ok,"Impossibile girare a sinistra")
      s.d=(s.d+3)%4
    else
      ok=turtle.turnRight()
      assert(ok,"Impossibile girare a destra")
      s.d=(s.d+1)%4
    end
    checkpoint()
  end
end
local function inspectKind(kind)
  if kind=="U" then return turtle.inspectUp()
  elseif kind=="D" then return turtle.inspectDown()
  else return turtle.inspect() end
end
local function digKind(kind)
  if kind=="U" then return turtle.digUp()
  elseif kind=="D" then return turtle.digDown()
  else return turtle.dig() end
end
local function unsafe(name)
  if type(name)~="string" then return false end
  local n=name:lower()
  return n=="minecraft:bedrock" or n:find("water",1,true)
    or n:find("lava",1,true) or n:find("turtle",1,true)
    or n:find("chest",1,true) or n:find("barrel",1,true)
    or n:find("modem",1,true) or n:find("cable",1,true)
    or n:find("computer",1,true) or n:find("hopper",1,true)
    or n:find("machine",1,true) or n:find("pipe",1,true)
    or n:find("furnace",1,true)
end
local function clear(kind,tx,ty,tz)
  if inBase(tx,tz) then
    error("Protezione base: nessuno scavo nel perimetro interno")
  end
  for _=1,6 do
    local exists,block=inspectKind(kind)
    if not exists then return end
    local name=type(block)=="table" and block.name or "?"
    if unsafe(name) then error("Ostacolo protetto o fluido: "..name) end
    local free=0
    for slot=1,16 do
      if turtle.getItemCount(slot)==0 then free=free+1 end
    end
    if free<2 then
      error("Inventario quasi pieno: rientro per scarico")
    end
    local ok,reason=digKind(kind)
    if not ok then error("Non posso scavare "..name..": "..tostring(reason)) end
    sleep(0.1)
  end
  local exists=inspectKind(kind)
  if exists then error("Blocco persistente/falling block") end
end
local function fuel()
  local f=turtle.getFuelLevel()
  return type(f)=="number" and f or math.huge
end
local function reserve(extra)
  if fuel()<#s.path+(extra or 0)+120 then
    error("Carburante insufficiente: rientro preventivo richiesto")
  end
end
local function move(kind,protect)
  local x,y,z=coordsAfter(kind)
  assert(canOccupy(x,y,z),
    "Movimento vietato fuori settore: "..x..","..y..","..z)
  reserve(1)
  if protect then
    local exists=inspectKind(kind)
    if exists then error("Ingresso esterno ostruito: non scavo vicino alla base") end
  else
    clear(kind,x,y,z)
  end
  -- Journal pre-movimento: se la macchina si spegne in questa finestra
  -- la posizione fisica e' incerta e si richiede una verifica manuale.
  s.pending={kind=kind,x=x,y=y,z=z,d=s.d}
  checkpoint()
  local fn=kind=="F" and turtle.forward or
    (kind=="U" and turtle.up or turtle.down)
  local ok,reason=fn()
  if not ok then
    s.pending=nil
    checkpoint()
    error("Spostamento bloccato: "..tostring(reason))
  end
  s.x,s.y,s.z=x,y,z
  s.path[#s.path+1]={kind=kind,d=s.d}
  s.pending=nil
  checkpoint()
end

local function stepBack(item)
  local fn
  if item.kind=="F" then
    facing(item.d)
    fn=turtle.back
  elseif item.kind=="U" then fn=turtle.down
  else fn=turtle.up end
  -- Il percorso di andata e' libero. Non scavare MAI verso la base.
  for _=1,8 do
    local ok=fn()
    if ok then
      if item.kind=="F" then
        s.x=s.x-DX[item.d]; s.z=s.z-DZ[item.d]
      elseif item.kind=="U" then s.y=s.y-1
      else s.y=s.y+1 end
      table.remove(s.path)
      checkpoint()
      return
    end
    sleep(0.35)
  end
  error("Rientro impedito da ostacolo sul percorso preesistente")
end
local function goHome()
  if s.pending then
    error("Movimento interrotto durante il salvataggio: posizione incerta")
  end
  while #s.path>0 do
    stepBack(s.path[#s.path])
  end
  assert(atHome(),"Percorso inverso terminato lontano dalla base")
  facing(home.d)
end
local function emptyInventory()
  assert(atHome(),"Scarico consentito solo alla base")
  for i=1,16 do
    turtle.select(i)
    for _=1,40 do
      if turtle.getItemCount(i)==0 then break end
      turtle.dropDown()
      sleep(0.1)
    end
    assert(turtle.getItemCount(i)==0,
      "Scarico impossibile: cassa sotto piena o assente")
  end
end

-- Rifornimento ispirato al programma funzionante fornito dal giocatore:
-- secchi di lava dalla cassa sopra; secchi vuoti nella cassa sotto.
local function getLavaBucket()
  local chest=peripheral.wrap("top")
  assert(chest and chest.list and chest.pushItems and chest.size,
    "Cassa superiore non leggibile")
  local items=chest.list()
  local wanted
  for slot,item in pairs(items) do
    if item.name=="minecraft:lava_bucket" and item.count>=1 then
      wanted=slot;break
    end
  end
  if not wanted then return false end
  if wanted~=1 then
    local name=assert(peripheral.getName(chest))
    if items[1] then
      local free
      for i=chest.size(),2,-1 do
        if not items[i] then free=i;break end
      end
      assert(free,"Cassa superiore piena: impossibile liberare slot 1")
      assert(chest.pushItems(name,1,items[1].count,free)==items[1].count,
        "Spostamento contenuto cassa fallito")
    end
    assert(chest.pushItems(name,wanted,1,1)==1,
      "Impossibile posizionare il secchio nel primo slot")
  end
  return true
end
local function refuelHome()
  assert(atHome(),"Rifornimento consentito solo alla base")
  emptyInventory()
  local cap=turtle.getFuelLimit()
  local goal=type(cap)=="number" and math.min(cap,1000) or 1000
  while fuel()<goal do
    assert(getLavaBucket(),"Nessun secchio di lava nella cassa superiore")
    local slot
    for i=1,16 do if turtle.getItemCount(i)==0 then slot=i;break end end
    assert(slot,"Inventario pieno: impossibile rifornire")
    turtle.select(slot)
    assert(turtle.suckUp(1),"Impossibile prelevare il secchio")
    local item=turtle.getItemDetail(slot)
    assert(item and item.name=="minecraft:lava_bucket",
      "La cassa sopra non ha consegnato lava: controllare il sistema")
    assert(turtle.refuel(1),"Rifornimento fallito")
    assert(turtle.dropDown(),"Impossibile scaricare secchio vuoto")
  end
end

local oreFound={}
local function isOre(info)
  if type(info)~="table" or type(info.name)~="string" then return false end
  local n=info.name:lower()
  if n:find("_ore",1,true) or n:find(":ore_",1,true) then return true end
  if type(info.tags)=="table" then
    for tag,yes in pairs(info.tags) do
      if yes and type(tag)=="string" and (tag:find("ores/",1,true)
        or tag:find(":ores",1,true) or tag:find(":ore_",1,true)) then
        return true
      end
    end
  end
  return false
end
local function scan(kind)
  local found,b=inspectKind(kind)
  if found and isOre(b) then
    oreFound[b.name]=(oreFound[b.name] or 0)+1
  end
end
local function scanCurrent()
  scan("D")
  scan("U")
  facing(DIR.O) -- corsia laterale di N01 a OVEST, ma qui NON si scava
  scan("F")
  facing(DIR.N)
end

local function run()
  assert(not s.pending,"Movimento in sospeso: non posso ricostruire la posizione")
  if #s.path>0 then
    signal("RIENTRO","Percorso salvato: rientro preventivo")
    goHome()
  end
  assert(atHome(),"Posizione iniziale non alla base")
  if s.done then
    signal("BASE","Test gia' completato. Nessuno scavo ripetuto")
    return
  end
  refuelHome()
  signal("SCAVO","PILOT N01: test uscita e rientro, max 8 blocchi")
  -- Da casa un solo passo esterno, poi salita verticale fuori dalla base.
  move("F",true)
  while s.y<TARGET_Y do move("U") end
  clear("U",s.x,s.y+1,s.z)
  scanCurrent()
  for step=2,LIMIT do
    facing(DIR.N)
    move("F")
    clear("U",s.x,s.y+1,s.z)
    scanCurrent()
    if step%2==0 then
      signal("SCAVO","PILOT N01: galleria "..step.."/"..LIMIT)
    end
  end
  signal("RIENTRO","Test concluso: rientro alla propria cassa")
  goHome()
  emptyInventory()
  s.done=true
  checkpoint()
  local list={}
  for ore,count in pairs(oreFound) do list[#list+1]=ore.."="..count end
  table.sort(list)
  signal("BASE","TEST OK: rientrata; minerali rilevati "..table.concat(list,", "))
end

print("MEGAZERO PILOT | N01 | max 8 blocchi, ritorno home")
local ok,reason=pcall(run)
if not ok then
  local errText=tostring(reason)
  printError("ERRORE PILOT: "..errText)
  if not s.pending and #s.path>0 then
    signal("RIENTRO","Errore: tento rientro",errText)
    local returned,why=pcall(goHome)
    if not returned then
      errText=errText.." | RIENTRO NON RIUSCITO: "..tostring(why)
      printError(errText)
    end
  end
  if atHome() and #s.path==0 then
    signal("ERRORE","Test interrotto: turtle rientrata alla base",errText)
  else
    signal("ERRORE","ATTENZIONE: posizione da verificare",errText)
  end
end
print("Telemetria attiva; Ctrl+T termina il test locale.")
agent:heartbeatLoop()
