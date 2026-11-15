-- MEGAZERO | MINIERA NORD - Turtle 01 | gestione fluidi integrata (DA COLLAUDARE)
-- Tratta larga 2 blocchi: X 2118..2119, Z 2695..2994 (300 blocchi).
-- Dall'alto in basso: Y 0..-58. Il primo bedrock vanilla puo' iniziare a Y=-59.
-- Base: 2119,-52,2995; Facing NORD. Cassa sopra lava, sotto scarico.
-- Uscita e colonna risalita: 2119,-52..0,2994 (1 blocco a nord).
-- Non scavare con altre Turtle finche' il percorso non e' verificato.
-- Comandi: miniera_nord_01_fluidi prova | test | avvia
-- DEFAULT=prova: controlla l'allestimento SENZA MUOVERSI.
-- test: scava prime 10 celle poi torna. avvia: continua tutto.

local mode=({...})[1] or "prova"
assert(mode=="prova" or mode=="test" or mode=="avvia", "Uso: miniera_nord_01 prova | test | avvia")
local XMIN, XMAX = 2118, 2119
local ZMIN, ZMAX = 2695, 2994
local YMIN, YMAX = -58, 0
local HX, HY, HZ = 2119, -52, 2995
local STAGING_Z, SKY = 2994, 0
local JOB = "miniera_nord_01_fluidi_v1"
local STATE_FILE = "miniera_nord_01_fluidi.state"
local WIDTH = XMAX-XMIN+1
local PER_LEVEL = WIDTH*(ZMAX-ZMIN+1)
local TOTAL = PER_LEVEL*(YMAX-YMIN+1)

local s
if fs.exists(STATE_FILE) then
  local f=assert(fs.open(STATE_FILE,"r"))
  s=textutils.unserialize(f.readAll())
  f.close()
  assert(type(s)=="table" and s.job==JOB
    and type(s.next)=="number", "Salvataggio non valido")
else
  s={job=JOB, x=HX,y=HY,z=HZ,d=1,next=0}
end

local function save()
  local f=assert(fs.open(STATE_FILE,"w"))
  f.write(textutils.serialize(s))
  f.close()
end
save()

-- Direzioni: 0 Ovest, 1 Nord, 2 Est, 3 Sud
local function face(d)
  while s.d~=d do
    if (d-s.d)%4==3 then
      assert(turtle.turnLeft())
      s.d=(s.d+3)%4
    else
      assert(turtle.turnRight())
      s.d=(s.d+1)%4
    end
    save()
  end
end

-- Solo blocchi appartenenti alla corsia della N01 (2 x 300, livelli -58..0).
local function inArea(x,y,z)
  return x>=XMIN and x<=XMAX and z>=ZMIN and z<=ZMAX
    and y>=YMIN and y<=YMAX
end

local function targetPos(where)
  if where=="up" then return s.x,s.y+1,s.z end
  if where=="down" then return s.x,s.y-1,s.z end
  if s.d==0 then return s.x-1,s.y,s.z end
  if s.d==1 then return s.x,s.y,s.z-1 end
  if s.d==2 then return s.x+1,s.y,s.z end
  return s.x,s.y,s.z+1
end

local function checkBlock(block)
  if not block or not block.name then return end
  local n=block.name
  if n=="minecraft:bedrock" then error("Bedrock sulla rotta a "..s.x..","..s.y..","..s.z) end
  if n:find("turtle",1,true) or n:find("chest",1,true)
      or n:find("barrel",1,true) or n:find("refinedstorage",1,true)
      or n:find("cable",1,true) or n:find("computer",1,true)
      or n:find("modem",1,true) then
    error("Blocco protetto sulla rotta: "..n.." a "..s.x..","..s.y..","..s.z)
  end
end

local function fluidType(block)
  local n=block and block.name
  if n=="minecraft:water" or n=="minecraft:flowing_water" then return "water" end
  if n=="minecraft:lava" or n=="minecraft:flowing_lava" then return "lava" end
  return nil
end

local function isSource(block)
  local level=block and block.state and block.state.level
  -- In Minecraft la sorgente ha level 0. Se non abbiamo lo stato,
  -- proviamo comunque con il secchio, verificando l'oggetto ottenuto.
  return level==nil or tonumber(level)==0
end

local function fuel()
  local f=turtle.getFuelLevel()
  return type(f)=="number" and f or math.huge
end

local function slotOf(id)
  for i=1,16 do
    local d=turtle.getItemDetail(i)
    if d and d.name==id then return i end
  end
end
local function freeSlot()
  for i=1,16 do if turtle.getItemCount(i)==0 then return i end end
end
local function countItem(id)
  local n=0
  for i=1,16 do
    local d=turtle.getItemDetail(i)
    if d and d.name==id then n=n+d.count end
  end
  return n
end

local function singleEmptyBucket()
  local src=slotOf("minecraft:bucket")
  if not src then error("SERVIZIO_SECCHI: mancano secchi vuoti") end
  if turtle.getItemCount(src)==1 then return src end
  local dst=freeSlot()
  if not dst then error("SERVIZIO_SECCHI: manca uno slot per raccogliere il liquido") end
  turtle.select(src)
  assert(turtle.transferTo(dst,1),"Impossibile separare un secchio vuoto")
  return dst
end

local collected=0
local function collectFluid(where,block)
  local typ=fluidType(block)
  if not typ or not isSource(block) then return false end
  local bucketSlot=singleEmptyBucket()
  local place=(where=="up" and turtle.placeUp)
    or (where=="down" and turtle.placeDown) or turtle.place
  turtle.select(bucketSlot)
  local ok=place()
  local d=turtle.getItemDetail(bucketSlot)
  if not ok or not d or d.name~=("minecraft:"..typ.."_bucket") then
    -- Se il livello non era disponibile, potrebbe trattarsi di un flusso.
    if block.state and block.state.level==nil then return false end
    if not block.state then return false end
    error("LIQUIDO NON RACCOLTO: "..typ.." "..where.." @"..s.x..","..s.y..","..s.z)
  end
  collected=collected+1
  if typ=="lava" then
    local limit=turtle.getFuelLimit()
    if fuel()~=math.huge and (type(limit)~="number" or fuel()<limit) then
      assert(turtle.refuel(1),"Raccolta lava: impossibile usare come carburante")
    end
  end
  return true
end

local discardJunk -- definita sotto
local bypassFluids=false -- durante il solo rientro si evita la bonifica ripetuta

local function step(where,protect)
  local go,inspect,dig,attack
  if where=="up" then
    go,inspect,dig,attack=turtle.up,turtle.inspectUp,turtle.digUp,turtle.attackUp
  elseif where=="down" then
    go,inspect,dig,attack=turtle.down,turtle.inspectDown,turtle.digDown,turtle.attackDown
  else
    go,inspect,dig,attack=turtle.forward,turtle.inspect,turtle.dig,turtle.attack
  end
  for tries=1,50 do
    if fuel()==0 then error("Carburante terminato") end
    local exists,block=inspect()
    local liquid=exists and fluidType(block)
    if exists and not liquid then checkBlock(block) end
    if protect and exists and not liquid then
      error("Corridoio di ritorno protetto ostruito a "..s.x..","..s.y..","..s.z)
    end
    if liquid and not bypassFluids then
      local tx,ty,tz=targetPos(where)
      if inArea(tx,ty,tz) and isSource(block) then
        collectFluid(where,block)
      end
    end
    if go() then
      if where=="up" then s.y=s.y+1
      elseif where=="down" then s.y=s.y-1
      elseif s.d==0 then s.x=s.x-1
      elseif s.d==1 then s.z=s.z-1
      elseif s.d==2 then s.x=s.x+1
      else s.z=s.z+1 end
      save()
      return
    end
    if exists and not liquid then
      local worked=dig()
      if discardJunk then discardJunk() end
      if not worked then sleep(0.3) end
    elseif not exists then
      attack()
    end
    sleep(0.2)
  end
  error("Bloccata a "..s.x..","..s.y..","..s.z)
end

-- Bonifica delle sorgenti accessibili in tutte le direzioni, compresi
-- acqua sotto i piedi e lava laterale. Non modifica corsie altrui.
local function sweepFluids()
  local oldDir=s.d
  local flowing=false
  local function scan(where)
    local tx,ty,tz=targetPos(where)
    if not inArea(tx,ty,tz) then return end
    local inspect=(where=="up" and turtle.inspectUp)
      or (where=="down" and turtle.inspectDown) or turtle.inspect
    for attempt=1,3 do
      local ok,b=inspect()
      if not ok or not fluidType(b) then return end
      if not isSource(b) then
        flowing=true
        return
      end
      if not collectFluid(where,b) then
        flowing=true
        return
      end
      -- Nelle sorgenti infinite, verifica dopo l'aggiornamento dell'acqua.
      sleep(0.2)
    end
    local ok,b=inspect()
    if ok and fluidType(b) and isSource(b) then
      error("LIQUIDO INFINITO: sorgente rigenerata in "..where)
    end
  end
  scan("down")
  scan("up")
  for d=0,3 do
    face(d)
    scan("forward")
  end
  face(oldDir)
  if collected>0 then
    -- Sorgente rimossa: attendi il deflusso prima di valutare altre correnti.
    s.flowStreak=0
    collected=0
  elseif flowing then
    s.flowStreak=(s.flowStreak or 0)+1
    if s.flowStreak>2 then
      error("CORRENTE NON RISOLTA: sorgente non raggiunta entro 2 celle, "
        ..s.x..","..s.y..","..s.z)
    end
  else
    s.flowStreak=0
  end
  save()
end

local function moveX(x)
  while s.x~=x do face(x<s.x and 0 or 2);step("forward") end
end
local function moveZ(z)
  while s.z~=z do face(z<s.z and 1 or 3);step("forward") end
end
local function atHome()
  return s.x==HX and s.y==HY and s.z==HZ
end

-- Rientro per colonna scavata a nord della base; mai attraversare la cassa sopra.
local function returnHome()
  local old=bypassFluids
  bypassFluids=true
  local ok,msg=pcall(function()
    if atHome() then face(1);return end
    while s.y<SKY do step("up") end
    while s.y>SKY do step("down") end
    moveZ(STAGING_Z)
    moveX(HX)
    while s.y>HY do step("down", true) end
    face(3)
    step("forward", true)
    face(1)
  end)
  bypassFluids=old
  if not ok then error(msg) end
end

local function emptySlots()
  local n=0
  for i=1,16 do if turtle.getItemCount(i)==0 then n=n+1 end end
  return n
end

local function consolidateBuckets()
  local first
  for i=1,16 do
    local d=turtle.getItemDetail(i)
    if d and d.name=="minecraft:bucket" then
      if not first then first=i
      else
        turtle.select(i)
        turtle.transferTo(first)
      end
    end
  end
end

local function dump()
  assert(atHome(),"Scarico solo alla base")
  consolidateBuckets()
  local saved=0
  for i=1,16 do
    local d=turtle.getItemDetail(i)
    if d then
      turtle.select(i)
      local keep=0
      if d.name=="minecraft:bucket" then
        keep=math.min(d.count,math.max(0,8-saved))
        saved=saved+keep
      end
      local toDrop=d.count-keep
      if toDrop>0 then
        local done=false
        for retry=1,40 do
          if turtle.getItemCount(i)<=keep then done=true;break end
          turtle.dropDown(toDrop)
          sleep(0.2)
        end
        assert(done or turtle.getItemCount(i)<=keep,
          "Cassa inferiore piena o assente: impossibile scaricare "..d.name)
      end
    end
  end
end

local function prepareTopItem(id)
  local chest=peripheral.wrap("top")
  assert(chest and chest.list and chest.pushItems and chest.size,
    "Cassa superiore non leggibile")
  local items=chest.list()
  local wanted
  for slot,item in pairs(items) do
    if item.name==id and item.count>=1 then wanted=slot;break end
  end
  if not wanted then return false end
  if wanted~=1 then
    local name=assert(peripheral.getName(chest))
    if items[1] then
      local free
      for i=chest.size(),2,-1 do
        if not items[i] then free=i;break end
      end
      assert(free,"Cassa superiore: serve uno slot libero")
      assert(chest.pushItems(name,1,items[1].count,free)==items[1].count,
        "Impossibile liberare slot 1 cassa")
    end
    assert(chest.pushItems(name,wanted,1,1)==1,
      "Impossibile selezionare "..id)
  end
  return true
end

local function ensureBuckets()
  assert(atHome(),"Rifornimento secchi solo alla base")
  consolidateBuckets()
  local warned=false
  while countItem("minecraft:bucket")<8 do
    if not prepareTopItem("minecraft:bucket") then
      if not warned then print("Attendo secchi VUOTI nella cassa superiore...");warned=true end
      sleep(1)
    else
      warned=false
      local slot=slotOf("minecraft:bucket") or freeSlot()
      if not slot then dump();slot=freeSlot() end
      assert(slot,"Inventario senza posto per secchi")
      turtle.select(slot)
      if not turtle.suckUp(math.min(8-countItem("minecraft:bucket"),16)) then
        sleep(0.5)
      end
    end
  end
  consolidateBuckets()
end

local function refuelAtHome()
  assert(atHome(),"Rifornimento solo alla base")
  dump()
  local limit=turtle.getFuelLimit()
  -- 12000 e' la SCORTA MINIMA, non un limite massimo artificiale.
  -- La lava raccolta durante lo scavo continua ad aggiungere carburante.
  local goal=type(limit)=="number" and math.min(limit,12000) or 12000
  local warned=false
  while fuel()<goal do
    if not prepareTopItem("minecraft:lava_bucket") then
      if not warned then print("Attendo lava nella cassa superiore...");warned=true end
      sleep(1)
    else
      warned=false
      local slot=freeSlot()
      if not slot then
        dump();slot=freeSlot()
      end
      assert(slot,"Nessuno slot libero per carburante")
      turtle.select(slot)
      if turtle.suckUp(1) then
        local item=turtle.getItemDetail(slot)
        if item and item.name=="minecraft:lava_bucket" then
          assert(turtle.refuel(1),"Impossibile rifornire dalla lava")
          if countItem("minecraft:bucket")>8 then
            assert(turtle.dropDown(1),"Impossibile scaricare il secchio vuoto")
          end
        elseif item then
          assert(turtle.dropUp(),"Materiale inatteso non restituibile")
        end
      else
        sleep(0.5)
      end
    end
  end
  dump()
  ensureBuckets()
  print("Carburante: "..tostring(fuel()).." | Secchi vuoti: "..countItem("minecraft:bucket"))
end

-- Serpentina continua 2x300. Inverte Z a ogni livello e scende da Y0.
-- Le fasce delle altre Turtle nord non sono comprese nello scavo.
local function cell(i)
  local lev=math.floor(i/PER_LEVEL)
  local off=i%PER_LEVEL
  -- Ogni livello dispari ripercorre la serpentina al contrario;
  -- il cambio di quota resta sempre su due celle sovrapposte.
  if lev%2==1 then off=PER_LEVEL-1-off end
  local row=math.floor(off/WIDTH)
  local col=off%WIDTH
  local x=(row%2==0) and (XMAX-col) or (XMIN+col)
  local z=ZMAX-row
  return x,YMAX-lev,z
end

local function goCell(x,y,z)
  if s.x==x and s.y==y and s.z==z then return end
  local dist=math.abs(s.x-x)+math.abs(s.y-y)+math.abs(s.z-z)
  if dist==1 then
    if s.y~=y then step(y>s.y and "up" or "down")
    elseif s.x~=x then face(x<s.x and 0 or 2);step("forward")
    else face(z<s.z and 1 or 3);step("forward") end
    return
  end
  assert(atHome(),"Posizione inattesa: rientrare prima alla base")
  -- Esce a nord della base. La colonna a Z2994 viene scavata alla prima uscita.
  face(1)
  step("forward") -- 2119,-52,2994: parete di roccia consentita
  while s.y<SKY do step("up") end
  moveZ(z)
  moveX(x)
  while s.y>y do step("down") end
end

local function returnDistance(x,y,z)
  return math.abs(SKY-y)+math.abs(HX-x)+math.abs(STAGING_Z-z)
    +(SKY-HY)+1
end
local function outwardDistance(x,y,z)
  return 1+(SKY-HY)+math.abs(z-STAGING_Z)
    +math.abs(HX-x)+(SKY-y)
end

-- Scarta solo materiali comuni conosciuti; salva TUTTO il resto,
-- per non perdere minerali/drop di mod con nomi imprevisti.
local JUNK={}
for _,id in ipairs({
  "minecraft:cobblestone", "minecraft:cobbled_deepslate",
  "minecraft:stone", "minecraft:deepslate", "minecraft:tuff",
  "minecraft:granite", "minecraft:diorite", "minecraft:andesite",
  "minecraft:dirt", "minecraft:coarse_dirt", "minecraft:gravel",
  "minecraft:sand", "minecraft:red_sand", "minecraft:calcite",
  "minecraft:dripstone_block", "minecraft:pointed_dripstone"
}) do JUNK[id]=true end

discardJunk = function()
  if atHome() then return end
  for i=1,16 do
    local item=turtle.getItemDetail(i)
    if item and JUNK[item.name] then
      turtle.select(i)
      if not turtle.dropDown(item.count) then
        error("Impossibile scartare "..item.name.." sul campo")
      end
    end
  end
end

local function run()
  assert(atHome() or (s.next>0 and mode~="prova"),
    "La Turtle non e' alla base e non ha uno stato valido")
  if mode=="prova" then
    assert(atHome(),"PROVA: Turtle non alla base")
    assert(s.d==1,"PROVA: previsto orientamento NORD; lo stato salvato indica altro")
    local top=peripheral.wrap("top")
    local bottom=peripheral.wrap("bottom")
    assert(top and top.list,"PROVA: inventario della cassa superiore non rilevato")
    assert(bottom and bottom.list,"PROVA: inventario della cassa inferiore non rilevato")
    print("PROVA OK: casse sopra e sotto riconosciute.")
    print("Coordinate e facing NORD assunti dalla configurazione, non letti con GPS.")
    print("Nessun movimento. Test = 10 celle, Avvia = scavo completo.")
    return
  end
  if not atHome() then
    print("Ripresa dopo interruzione: rientro alla base")
    returnHome()
  end
  if s.next>=TOTAL then
    dump()
    print("Scavo gia' completato")
    return
  end
  refuelAtHome()
  local target=mode=="test" and math.min(TOTAL,10) or TOTAL
  print("Miniera nord: Y0 -> Y-58, Z2994..2695; "..TOTAL.." posizioni")
  while s.next<target do
    local x,y,z=cell(s.next)
    local reserve=returnDistance(x,y,z)+150
    if atHome() then reserve=reserve+outwardDistance(x,y,z) end
    if emptySlots()<=2 or fuel()<reserve then
      returnHome()
      refuelAtHome()
    end
    local ok,why=pcall(function()
      goCell(x,y,z)
      sweepFluids()
      discardJunk()
    end)
    if not ok and tostring(why):find("SERVIZIO_SECCHI",1,true) then
      print("Rifornimento automatico secchi: rientro alla base")
      returnHome()
      refuelAtHome()
    elseif not ok then
      error(why)
    else
      s.next=s.next+1
      save()
    end
    if s.next%1000==0 then
      print(s.next.."/"..TOTAL.." - quota "..y)
    end
  end
  returnHome()
  dump()
  if mode=="test" then
    print("TEST COMPLETATO: "..s.next.." celle. Turtle rientrata.")
  else
    print("SCAVO COMPLETATO. Turtle alla base.")
  end
end

local ok,why=pcall(run)
if not ok then
  printError("ERRORE: "..tostring(why))
  -- Se una sorgente non e' bonificabile, non tentare rientri ciechi.
  local dangerous=tostring(why):find("LIQUIDO",1,true)
    or tostring(why):find("CORRENTE",1,true)
    or tostring(why):find("Bedrock sulla rotta",1,true)
    or tostring(why):find("Blocco protetto sulla rotta",1,true)
  if not atHome() and not dangerous then
    local recovered,msg=pcall(returnHome)
    if not recovered then
      printError("RIENTRO NON RIUSCITO: "..tostring(msg))
    end
  end
  if dangerous then print("FERMATA DI SICUREZZA: controlla il passaggio prima di riprendere") end
  if atHome() then print("Turtle alla base: controlla l'errore") end
end