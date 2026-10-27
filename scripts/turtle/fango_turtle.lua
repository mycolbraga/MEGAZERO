-- MEGAZERO | FARM FANGO AUTOMATICA | CC:Tweaked / Minecraft 1.21.1
--
-- Layout fisso (Turtle immobile):
--  SOPRA   = cassa di RIFORNIMENTO (terra + ampolle d'acqua)
--  DAVANTI = 1 blocco di ARIA, dove la Turtle lavora
--  SOTTO   = cassa di USCITA (fango + ampolle vuote)
--
-- RS: Exporter terra/ampolle piene -> cassa sopra;
--     Importer fango/ampolle vuote <- cassa sotto.
-- Le ampolle vuote possono tornare via RS al dispenser di riempimento.
--
-- Comandi: fango_turtle prova | giro | avvia
--          giro = 1 blocco; avvia = ciclo continuo. Ctrl+T per fermare.
-- Non richiede carburante: la Turtle non si muove.
--
-- ATTENZIONE: minecraft:potion e' l'ID di tutte le pozioni,
-- incluse le ampolle d'acqua. Mettere nella cassa SOLO ampolle
-- d'acqua, mai pozioni differenti.

local mode=({...})[1] or "prova"
if mode~="prova" and mode~="giro" and mode~="avvia" then
  error("Uso: fango_turtle prova | giro | avvia",0)
end

local DIRT="minecraft:dirt"
local WATER_BOTTLE="minecraft:potion"
local EMPTY_BOTTLE="minecraft:glass_bottle"
local MUD="minecraft:mud"
local DIRT_TARGET=64

local function fail(msg)
  error("FANGO: "..msg,0)
end

local function count(name)
  local n=0
  for i=1,16 do
    local item=turtle.getItemDetail(i)
    if item and item.name==name then n=n+item.count end
  end
  return n
end

local function selectItem(name)
  for i=1,16 do
    local item=turtle.getItemDetail(i)
    if item and item.name==name then
      turtle.select(i)
      return true
    end
  end
  return false
end

local function freeSlot()
  for i=1,16 do
    if not turtle.getItemDetail(i) then return i end
  end
end

local function freeSlots()
  local n=0
  for i=1,16 do
    if not turtle.getItemDetail(i) then n=n+1 end
  end
  return n
end

local function verifyChest(direction,label)
  local ok,block
  if direction=="top" then ok,block=turtle.inspectUp()
  else ok,block=turtle.inspectDown() end
  if not ok or not block or
    not (block.name:find("chest",1,true) or block.name:find("barrel",1,true)) then
    fail("Non trovo la cassa "..label)
  end
  local inv=peripheral.wrap(direction)
  if not inv or not inv.list or not inv.size or not inv.pushItems then
    fail("Cassa "..label.." non riconosciuta come inventory peripheral")
  end
  return inv
end

local input=verifyChest("top","SOPRA")
verifyChest("bottom","SOTTO")

local function checkWorkArea()
  local ok,block=turtle.inspect()
  if ok then
    fail("Davanti non c'e' aria ma "..block.name.."; libera il posto di lavoro")
  end
end

-- Porta solo l'item cercato nello slot 1 della cassa in ingresso.
-- Stessa logica di rifornimento selettivo delle farm legname MEGAZERO.
-- Se la cassa superiore e' piena, usa uno slot Turtle temporaneo.
local function pullFromTop(name,requested)
  local contents=input.list()
  local source
  for i=1,input.size() do
    local item=contents[i]
    if item and item.name==name then
      source=i
      break
    end
  end
  if not source then return 0 end

  local destination,capacity
  if name==DIRT then
    for i=1,16 do
      local item=turtle.getItemDetail(i)
      if item and item.name==DIRT and item.count<64 then
        destination=i
        capacity=64-item.count
        break
      end
    end
  end
  if not destination then
    destination=freeSlot()
    capacity=name==WATER_BOTTLE and 1 or 64
  end
  if not destination then fail("Inventario pieno, impossibile rifornirsi") end

  local amount=math.min(requested,capacity,contents[source].count)
  if amount<=0 then return 0 end

  -- Se lo slot 1 contiene altro, lo liberiamo. Quando la cassa
  -- e' completamente piena usiamo TEMPORANEAMENTE uno slot Turtle,
  -- evitando l'errore "impossibile liberare slot 1".
  local parkedSlot,parkedItem
  if source~=1 then
    if contents[1] then
      local empty
      for i=1,input.size() do
        if not contents[i] then empty=i; break end
      end
      if empty then
        local n=input.pushItems("top",1,contents[1].count,empty)
        if n~=contents[1].count then
          fail("Non riesco a spostare lo slot 1 nella cassa SOPRA")
        end
      else
        parkedSlot=freeSlot()
        if not parkedSlot or parkedSlot==destination then
          fail("Cassa sopra piena: manca uno slot libero per lo scambio")
        end
        turtle.select(parkedSlot)
        local ok,why=turtle.suckUp(contents[1].count)
        parkedItem=turtle.getItemDetail(parkedSlot)
        if not ok or not parkedItem or parkedItem.name~=contents[1].name
          or parkedItem.count~=contents[1].count then
          fail("Impossibile svuotare temporaneamente slot 1: "..tostring(why))
        end
      end
    end
    local n=input.pushItems("top",source,amount,1)
    if n~=amount then
      fail("Non riesco a selezionare "..name.." nella cassa SOPRA")
    end
  end

  local before=turtle.getItemCount(destination)
  turtle.select(destination)
  local ok,why=turtle.suckUp(amount)
  local received=turtle.getItemDetail(destination)
  local gained=turtle.getItemCount(destination)-before
  if not ok or not received or received.name~=name or gained~=amount then
    fail("Rifornimento errato di "..name..": "..tostring(why))
  end
  if parkedSlot then
    turtle.select(parkedSlot)
    local returned=turtle.dropUp(parkedItem.count)
    if not returned or turtle.getItemCount(parkedSlot)~=0 then
      fail("Impossibile restituire alla cassa SOPRA lo stack temporaneo")
    end
  end
  return gained
end

local function dropOutputs()
  -- Non scaricare MAI la terra o le ampolle piene.
  for i=1,16 do
    local item=turtle.getItemDetail(i)
    if item and (item.name==MUD or item.name==EMPTY_BOTTLE) then
      turtle.select(i)
      local ok,why=turtle.dropDown(item.count)
      if not ok or turtle.getItemCount(i)~=0 then
        fail("Cassa sotto piena: scarico fallito per "..item.name.." ("..tostring(why)..")")
      end
    end
  end
end

local function restock()
  dropOutputs()
  -- Riserva sempre due slot per gli output della lavorazione.
  if count(DIRT)<DIRT_TARGET then
    while count(DIRT)<DIRT_TARGET do
      if freeSlots()<3 and count(DIRT)>0 then break end
      if pullFromTop(DIRT,DIRT_TARGET-count(DIRT))==0 then break end
    end
  end
  -- UNA SOLA ampolla per ciclo. Finche' esiste gia' un'ampolla
  -- nell'inventario NON ne prende altre dalla cassa.
  if count(WATER_BOTTLE)==0 and freeSlots()>=3 then
    pullFromTop(WATER_BOTTLE,1)
  end
end

local function waitForInputs()
  while true do
    restock()
    if count(DIRT)>0 and count(WATER_BOTTLE)>0 and freeSlots()>=2 then return end
    print("Attendo terra/ampolle: terra="..count(DIRT)..
      " acqua="..count(WATER_BOTTLE).." slot liberi="..freeSlots())
    sleep(10)
  end
end

local function produceOne()
  checkWorkArea()
  waitForInputs()
  if not selectItem(DIRT) then fail("Terra assente") end
  local placed,why=turtle.place()
  if not placed then fail("Non riesco a piazzare terra: "..tostring(why)) end

  local ok,block=turtle.inspect()
  if not ok or block.name~=DIRT then
    fail("La terra piazzata non e' stata verificata")
  end
  if not selectItem(WATER_BOTTLE) then
    fail("Ampolla d'acqua assente DOPO aver piazzato terra")
  end
  local used,why2=turtle.place()
  local converted,mud=turtle.inspect()
  if not used or not converted or mud.name~=MUD then
    fail("Conversione fallita ("..tostring(why2).."), non scavo")
  end

  local dug,why3=turtle.dig()
  if not dug then fail("Scavo del fango fallito: "..tostring(why3)) end
  local remaining=turtle.inspect()
  if remaining then fail("Postazione non libera dopo la raccolta") end
  if count(MUD)<1 then
    fail("Fango scavato ma non presente in inventario")
  end
  dropOutputs()
end

checkWorkArea()
if mode=="prova" then
  print("PROVA OK: cassa SOPRA, cassa SOTTO, area DAVANTI libera.")
  print("Ampolle: una alla volta, terra in scorta fino a 64.")
  print("SOLO terra e AMPOLLE D'ACQUA, non altre pozioni.")
  print("Ora: fango_turtle giro, poi fango_turtle avvia.")
  return
end

local total=0
while true do
  produceOne()
  total=total+1
  if total%16==0 or mode=="giro" then
    print("Fango prodotto: "..total.." | terra="..count(DIRT)..
      " | ampolle piene="..count(WATER_BOTTLE))
  end
  if mode=="giro" then break end
  sleep(0.1)
end
