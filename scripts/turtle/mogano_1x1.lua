-- MEGAZERO MOGANO (JUNGLE) - FARM 8x 1x1
-- Variante derivata dal programma per gli abeti; originale lasciato INALTERATO.
-- Turtle base: 1903,66,2715, guarda NORD. Chest dietro a 1903,66,2716.
-- Terra = Y66, primo tronco = Y67; la Turtle sale 1 blocco durante il lavoro.
-- Coppie di alberi X=1899 e 1907, Z=2712/2705/2698/2691.
-- Punto di scarico: 1903,66,2714, acqua SOTTO a 1903,65,2714.
-- Prima fare 'prova': verifica percorso e acqua senza tagli o piantagioni.
-- Variante MOGANO con Bone Meal; NON ancora collaudata in gioco.
-- Su ogni posizione usiamo Bone Meal al massimo 16 volte per evitare sprechi
-- se la crescita non riesce per mancanza di spazio.
-- Nota: gli arboscelli jungle hanno drop inferiore alla media; RS/chest deve
-- reintegrare le piantine se la raccolta delle foglie non basta.

local mode = ({...})[1] or "prova"
if mode ~= "prova" and mode ~= "giro" and mode ~= "avvia" then
  error("Uso: mogano_1x1.lua prova | giro | avvia", 0)
end

local HOME_X, HOME_Y, HOME_Z = 1903, 66, 2715
local WORK_Y = HOME_Y + 1 -- livello della base dei tronchi, Y=67
local LANE_X = 1903
local Z_TREES = {2712, 2705, 2698, 2691}
local WEST_X, EAST_X = 1899, 1907
local dirVectors = {
  [0] = {1, 0},  -- est (+X)
  [1] = {0, 1},  -- sud (+Z)
  [2] = {-1, 0}, -- ovest (-X)
  [3] = {0, -1}, -- nord (-Z)
}
local p = {x = HOME_X, y = HOME_Y, z = HOME_Z, dir = 3}
local CHECK_FILE = ".nuova_jungle_1x1_bonemeal_prova_ok"
local BONE_MEAL = "minecraft:bone_meal"
local BONE_MEAL_TARGET = 128
local MAX_BONE_MEAL_PER_TREE = 16
local boneMealUsed = 0
local treesCut = 0
local fuelAtLeast -- combustibile locale: implementazione piu' sotto

local function fail(message)
  error(message .. " | Posizione prevista: " ..
    p.x .. ", " .. p.y .. ", " .. p.z .. ", direzione=" .. p.dir ..
    ". NON riavviare finche' non e' di nuovo a casa verso NORD.", 0)
end

local function face(wanted)
  while p.dir ~= wanted do
    if (wanted - p.dir) % 4 == 3 then
      if not turtle.turnLeft() then fail("Impossibile girare") end
      p.dir = (p.dir + 3) % 4
    else
      if not turtle.turnRight() then fail("Impossibile girare") end
      p.dir = (p.dir + 1) % 4
    end
  end
end

local function forward(n)
  for _ = 1, n do
    if fuelAtLeast and not fuelAtLeast(1) then fail("Carburante esaurito durante l'andata") end
    local ok, reason = turtle.forward()
    if not ok then fail("Passaggio bloccato (NON scavo): " .. tostring(reason)) end
    local d = dirVectors[p.dir]
    p.x, p.z = p.x + d[1], p.z + d[2]
  end
end

local function backward(n)
  for _ = 1, n do
    if fuelAtLeast and not fuelAtLeast(1) then fail("Carburante esaurito durante il ritorno") end
    local ok, reason = turtle.back()
    if not ok then fail("Ritorno bloccato (NON scavo): " .. tostring(reason)) end
    local d = dirVectors[p.dir]
    p.x, p.z = p.x - d[1], p.z - d[2]
  end
end

local function up()
  if fuelAtLeast and not fuelAtLeast(1) then fail("Carburante esaurito durante la salita") end
  local ok, reason = turtle.up()
  if not ok then fail("Salita bloccata: " .. tostring(reason)) end
  p.y = p.y + 1
end

local function down()
  if fuelAtLeast and not fuelAtLeast(1) then fail("Carburante esaurito durante la discesa") end
  local ok, reason = turtle.down()
  if not ok then fail("Discesa bloccata: " .. tostring(reason)) end
  p.y = p.y - 1
end

local function jungleLog(name)
  return name == "minecraft:jungle_log" or name == "minecraft:jungle_wood"
end

local function sapling(name)
  return name == "minecraft:jungle_sapling"
end

local function countSaplings()
  local total = 0
  for slot = 1, 16 do
    local item = turtle.getItemDetail(slot)
    if item and sapling(item.name) then total = total + item.count end
  end
  return total
end

local function selectSapling()
  for slot = 1, 16 do
    local item = turtle.getItemDetail(slot)
    if item and sapling(item.name) then
      turtle.select(slot)
      return true
    end
  end
  return false
end

local function countBoneMeal()
  local total = 0
  for slot = 1, 16 do
    local item = turtle.getItemDetail(slot)
    if item and item.name == BONE_MEAL then total = total + item.count end
  end
  return total
end

local function selectBoneMeal()
  for slot = 1, 16 do
    local item = turtle.getItemDetail(slot)
    if item and item.name == BONE_MEAL then
      turtle.select(slot)
      return true
    end
  end
  return false
end

-- Il legno e' un carburante DI EMERGENZA; la priorita' a casa e' la lava.
local function fuelItem(name)
  return name == "minecraft:coal" or name == "minecraft:charcoal"
    or jungleLog(name) or name == "minecraft:jungle_planks"
end

fuelAtLeast = function(amount)
  local fuel = turtle.getFuelLevel()
  if fuel == "unlimited" then return true end
  if type(fuel) ~= "number" then fail("Livello carburante non valido") end
  while turtle.getFuelLevel() < amount do
    local used = false
    for slot = 1, 16 do
      local item = turtle.getItemDetail(slot)
      if item and fuelItem(item.name) then
        turtle.select(slot)
        if turtle.refuel(1) then used = true; break end
      end
    end
    if not used then return false end
  end
  return true
end

local function verifyChest()
  if p.x ~= HOME_X or p.y ~= HOME_Y or p.z ~= HOME_Z then
    fail("Il controllo della chest si fa solo alla base")
  end
  face(1)
  local ok, block = turtle.inspect()
  face(3)
  if not ok or not block or
    not (block.name:find("chest", 1, true) or block.name == "minecraft:barrel") then
    fail("Non vedo la chest dietro. Orientamento/posizione da verificare")
  end
end

-- Prelievo SELETTIVO dalla chest davanti alla Turtle (verso OVEST).
-- Nota CC:Tweaked: turtle.suck() non sceglie lo slot sorgente.
-- Usiamo inventory.list/pushItems sulla chest per portare il materiale in slot 1.
local function pickupSlot(name)
  for slot = 1, 16 do
    local item = turtle.getItemDetail(slot)
    if item and item.name == name then
      local limit = item.maxCount or (name == "minecraft:lava_bucket" and 1 or 64)
      if item.count < limit then return slot, limit - item.count end
    end
  end
  for slot = 1, 16 do
    if not turtle.getItemDetail(slot) then
      return slot, (name == "minecraft:lava_bucket" and 1 or 64)
    end
  end
  return nil, 0
end

local function takeFromChest(itemName, requested)
  if p.x ~= HOME_X or p.y ~= HOME_Y or p.z ~= HOME_Z then
    fail("Il rifornimento si fa solo davanti alla chest")
  end
  face(1)
  local chest = peripheral.wrap("front")
  if not chest or not chest.list or not chest.pushItems or not chest.size then
    face(3)
    fail("Chest non visibile come inventario CC:Tweaked")
  end
  local contents = chest.list()
  local source
  for i = 1, chest.size() do
    if contents[i] and contents[i].name == itemName then
      source = i
      break
    end
  end
  if not source then face(3); return 0 end
  local toSlot, capacity = pickupSlot(itemName)
  if not toSlot then face(3); fail("Inventario Turtle pieno, impossibile prelevare " .. itemName) end
  local amount = math.min(requested, capacity, contents[source].count)
  if amount <= 0 then face(3); return 0 end

  -- Se lo slot 1 contiene un altro oggetto, spostalo in uno slot vuoto.
  -- Non usiamo suck() alla cieca: rischierebbe di prendere mele o secchi vuoti.
  if source ~= 1 then
    if contents[1] then
      local free
      for i = 1, chest.size() do
        if not contents[i] then free = i; break end
      end
      if not free then
        face(3)
        fail("La chest deve avere almeno 1 slot libero per il rifornimento")
      end
      local moved = chest.pushItems("front", 1, contents[1].count, free)
      if moved ~= contents[1].count then
        face(3)
        fail("Non riesco a liberare lo slot 1 della chest")
      end
    end
    local moved = chest.pushItems("front", source, amount, 1)
    if moved ~= amount then
      face(3)
      fail("Impossibile preparare " .. itemName .. " per il prelievo")
    end
  end
  local before = turtle.getItemCount(toSlot)
  turtle.select(toSlot)
  local ok, why = turtle.suck(amount)
  local item = turtle.getItemDetail(toSlot)
  local gained = turtle.getItemCount(toSlot) - before
  if not ok or not item or item.name ~= itemName or gained ~= amount then
    face(3)
    fail("Prelievo non verificato per " .. itemName .. ": " .. tostring(why))
  end
  face(3)
  return gained
end

local function returnEmptyBuckets()
  face(1)
  for slot = 1, 16 do
    local item = turtle.getItemDetail(slot)
    if item and item.name == "minecraft:bucket" then
      turtle.select(slot)
      local done, why = turtle.drop(item.count)
      if not done or turtle.getItemCount(slot) ~= 0 then
        face(3)
        fail("Non posso restituire i secchi vuoti: " .. tostring(why))
      end
    end
  end
  face(3)
end

-- Rifornimento alla base. Ogni secchio pieno vale circa 1000 movimenti.
-- Al termine del viaggio usa automaticamente il prossimo secchio, se necessario.
local function prepareFuel(target)
  if turtle.getFuelLevel() == "unlimited" then return end
  local limit = turtle.getFuelLimit()
  if type(limit) == "number" then target = math.min(target, limit) end
  while turtle.getFuelLevel() < target do
    local got = takeFromChest("minecraft:lava_bucket", 1)
    if got > 0 then
      local slot
      for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if item and item.name == "minecraft:lava_bucket" then slot = i; break end
      end
      if not slot then fail("Non trovo il secchio di lava appena prelevato") end
      turtle.select(slot)
      local ok, reason = turtle.refuel(1)
      if not ok then fail("Non posso usare la lava: " .. tostring(reason)) end
      returnEmptyBuckets()
      print("Rifornimento lava: " .. tostring(turtle.getFuelLevel()) .. " movimenti")
    else
      -- Ultima risorsa: carbone, carbonella o tronchi gia' nella Turtle.
      if not fuelAtLeast(target) then
        fail("Carburante insufficiente: aggiungi secchi di lava alla chest")
      end
    end
  end
end

local function waitForSaplings()
  while countSaplings() < 8 do
    local missing = 8 - countSaplings()
    local received = takeFromChest("minecraft:jungle_sapling", missing)
    if received == 0 then
      print("Attendo sapling nella chest (" .. countSaplings() .. "/8)...")
      sleep(30)
    else
      print("Prelevati " .. received .. " sapling (" .. countSaplings() .. "/8)")
    end
  end
end

-- Alla base prende fino a due stack dalla chest, senza aspettare una scorta piena.
-- Se e' totalmente esaurito aspetta alla base, non partira' senza fertilizzante.
local function waitForBoneMeal()
  while true do
    local count = countBoneMeal()
    while count < BONE_MEAL_TARGET do
      local got = takeFromChest(BONE_MEAL, math.min(64, BONE_MEAL_TARGET - count))
      if got == 0 then break end
      count = countBoneMeal()
    end
    if count > 0 then
      print("Bone Meal pronto: " .. count .. "/" .. BONE_MEAL_TARGET)
      return
    end
    print("Attendo Bone Meal nella chest...")
    sleep(30)
  end
end

local function checkTree(label)
  local ok, block = turtle.inspect()
  if ok and block and (jungleLog(block.name) or sapling(block.name)) then
    print(label .. ": " .. block.name .. " OK")
    return true
  end
  print(label .. ": NON riconosco tronco/piantina davanti (" ..
    (ok and block.name or "aria") .. ")")
  return false
end

-- MOGANO NORMALE 1x1: tronco verticale, senza rami laterali di legno.
-- Tagliamo esclusivamente i tronchi sopra la posizione di partenza,
-- lasciando decadere naturalmente le foglie (la raccolta rimane ad acqua).
-- Il mogano gigante 2x2 NON e' supportato da questo programma.
-- Dopo la prima scavata la Turtle si trova GIA' nel blocco del tronco base.
local function chopConnectedTree(rootX, rootZ)
  if p.x ~= rootX or p.z ~= rootZ or p.y ~= WORK_Y then
    fail("Posizione iniziale mogano non corretta")
  end
  local climbed = 0
  local MAX_TRUNK_HEIGHT = 30
  while climbed < MAX_TRUNK_HEIGHT do
    local ok, block = turtle.inspectUp()
    if not ok or not block or not jungleLog(block.name) then break end
    local done, why = turtle.digUp()
    if not done then fail("Impossibile tagliare il tronco sopra: " .. tostring(why)) end
    up()
    climbed = climbed + 1
  end
  -- Torna sempre alla quota iniziale (Y67) lungo la colonna svuotata.
  for _ = 1, climbed do down() end
  if climbed == MAX_TRUNK_HEIGHT then
    fail("Mogano troppo alto: raggiunto il limite di 31 tronchi; verifica l'albero")
  end
end

-- Fertilizza solo un arboscello riconosciuto; non applica mai
-- Bone Meal su altri blocchi. Dopo 16 tentativi rinvia al giro successivo.
local function growWithBoneMeal(label)
  local used = 0
  while used < MAX_BONE_MEAL_PER_TREE do
    local exists, block = turtle.inspect()
    if exists and jungleLog(block.name) then return true end
    if not exists or not sapling(block.name) then
      print(label .. ": non vedo piantina di mogano; rinvio")
      return false
    end
    if not selectBoneMeal() then
      print(label .. ": Bone Meal esaurito durante il giro; rinvio")
      return false
    end
    local slot = turtle.getSelectedSlot()
    local before = turtle.getItemCount(slot)
    local applied, why = turtle.place()
    local consumed = before - turtle.getItemCount(slot)
    if not applied or consumed <= 0 then
      print(label .. ": Bone Meal non applicato (" .. tostring(why) .. "); rinvio")
      return false
    end
    used = used + consumed
    boneMealUsed = boneMealUsed + consumed
    sleep(0.1)
  end
  local exists, block = turtle.inspect()
  if exists and jungleLog(block.name) then return true end
  print(label .. ": non cresciuto dopo " .. used .. " Bone Meal: controlla spazio/luci")
  return false
end

local function plantSapling(label)
  if not selectSapling() then fail(label .. ": mancano le piantine di mogano") end
  local exists, obstacle = turtle.inspect()
  if exists then
    fail(label .. ": impossibile piantare, c'e' " .. obstacle.name)
  end
  local planted, why = turtle.place()
  if not planted then fail(label .. ": ripiantagione fallita: " .. tostring(why)) end
  print(label .. ": piantata")
end

local function processTree(label, rootX, rootZ)
  -- Albero gia' cresciuto: taglia; arboscello: applica Bone Meal.
  -- Piazzola vuota: pianta prima, poi prova a far crescere.
  turtle.suckDown()
  local exists, block = turtle.inspect()
  if exists and not (sapling(block.name) or jungleLog(block.name)) then
    print(label .. ": blocco inatteso " .. block.name .. "; salto")
    return
  end
  if not exists then
    plantSapling(label)
    exists, block = turtle.inspect()
  end
  if exists and sapling(block.name) then
    if not growWithBoneMeal(label) then return end
  end
  exists, block = turtle.inspect()
  if not exists or not jungleLog(block.name) then
    print(label .. ": nessun tronco riconosciuto, non scavo")
    return
  end
  local done, why = turtle.dig()
  if not done then fail(label .. ": impossibile tagliare: " .. tostring(why)) end
  forward(1)
  chopConnectedTree(rootX, rootZ)
  turtle.suckDown()
  backward(1)
  treesCut = treesCut + 1
  plantSapling(label)
end


-- Al livello di lavoro (Y67): viale X1903, tronchi a +-4 X.
-- La Turtle si ferma a tre passi dal centro, adiacente al tronco.
local function pairAt(z, simulation)
  if p.x ~= LANE_X or p.z ~= z or p.y ~= WORK_Y then
    fail("Fuori dal viale o dalla quota dei tronchi")
  end
  local index = math.floor((Z_TREES[1] - z) / 7)
  local goodWest, goodEast = true, true
  face(2) -- OVEST
  forward(3) -- X1900; albero davanti X1899
  if simulation then
    goodWest = checkTree("A" .. (index + 1))
  else
    processTree("A" .. (index + 1), WEST_X, z)
  end
  backward(3)

  face(0) -- EST
  forward(3) -- X1906; albero davanti X1907
  if simulation then
    goodEast = checkTree("A" .. (8 - index))
  else
    processTree("A" .. (8 - index), EAST_X, z)
  end
  backward(3)
  face(3) -- NORD per avanzare alla prossima coppia
  return goodWest and goodEast
end

local function backHome()
  if p.x ~= LANE_X or p.y ~= WORK_Y then fail("Fuori dal viale al ritorno") end
  if p.z > HOME_Z then fail("Z oltre il punto di partenza") end
  face(1) -- SUD
  forward(HOME_Z - p.z)
  down() -- rientra alla base Y66
  face(3) -- NORD, chest dietro
end

-- Un blocco avanti alla base e scarico VERSO IL BASSO.
local function gotoWaterOutlet()
  if p.x ~= HOME_X or p.y ~= HOME_Y or p.z ~= HOME_Z then
    fail("Lo scarico parte solo dalla base")
  end
  face(3) -- NORD
  forward(1) -- 1903,66,2714
  local found, block = turtle.inspectDown()
  if not found or not block or block.name ~= "minecraft:water" then
    backward(1) -- torna in sicurezza alla base
    fail("Non trovo acqua sotto 1903,65,2714: scarico annullato")
  end
end

local function returnFromWaterOutlet()
  face(1) -- SUD
  forward(1)
  face(3) -- NORD
end

local function storeInWater()
  verifyChest()
  gotoWaterOutlet()
  local droppedStacks = 0
  for slot = 1, 16 do
    local item = turtle.getItemDetail(slot)
    if item then
      -- Teniamo arboscelli, Bone Meal, carbone/carbonella e secchi, non il legno.
      local keep = sapling(item.name)
        or item.name == BONE_MEAL
        or item.name == "minecraft:coal"
        or item.name == "minecraft:charcoal"
        or item.name == "minecraft:lava_bucket"
        or item.name == "minecraft:bucket"
      if not keep then
        turtle.select(slot)
        local before = turtle.getItemCount(slot)
        local success, why = turtle.dropDown()
        local after = turtle.getItemCount(slot)
        if not success or after ~= 0 then
          fail("Scarico in acqua incompleto per " .. item.name .. ": " .. tostring(why)
            .. " (prima=" .. before .. ", dopo=" .. after .. ")")
        end
        droppedStacks = droppedStacks + 1
      end
    end
  end
  returnFromWaterOutlet()
  print("Scarico in acqua completato: " .. droppedStacks .. " stack")
end

verifyChest()

if mode == "prova" then
  print("PROVA SICURA: non scavo e non pianto")
  prepareFuel(130)
  up() -- da Y66 a Y67, quota tronchi
  face(3) -- NORD
  forward(3) -- Z2712 prima coppia
  local good = true
  -- Verifica tutte le 8 posizioni e le corsie senza tagliare nulla.
  for i, z in ipairs(Z_TREES) do
    if not pairAt(z, true) then good = false end
    if i < #Z_TREES then forward(7) end
  end
  backHome()
  -- Nella prova controlliamo anche il punto di scarico SENZA gettare nulla.
  gotoWaterOutlet()
  returnFromWaterOutlet()
  print("Punto di scarico acqua (1903,65,2714): OK")
  if good then
    local handle = fs.open(CHECK_FILE, "w")
    handle.write("ok")
    handle.close()
    print("PROVA SUPERATA: Turtle tornata alla chest.")
    print("Ora: mogano_1x1.lua giro (test) oppure avvia")
  else
    if fs.exists(CHECK_FILE) then fs.delete(CHECK_FILE) end
    print("PROVA NON SUPERATA. Nessun blocco tagliato.")
  end
  return
end

if not fs.exists(CHECK_FILE) then
  error("Prima esegui: mogano_1x1.lua prova", 0)
end

print("MOGANO NUOVO 1x1 - raccolta in acqua")
while true do
  waitForSaplings()
  waitForBoneMeal()
  prepareFuel(3000)
  treesCut = 0
  boneMealUsed = 0
  up() -- da Y66 a Y67, quota tronchi
  face(3) -- NORD
  forward(3) -- Z2712 prima coppia
  for i, z in ipairs(Z_TREES) do
    pairAt(z, false)
    if i < #Z_TREES then forward(7) end
  end
  backHome()
  storeInWater()
  print("Giro terminato. Mogani tagliati: " .. treesCut)
  print("Piantine rimaste: " .. countSaplings())
  print("Bone Meal utilizzato: " .. boneMealUsed .. ", residuo: " .. countBoneMeal())
  if mode == "giro" then
    print("GIRO DI TEST CONCLUSO: Turtle alla base.")
    break
  end
  -- Nessuna pausa fissa: il giro successivo riusa subito il Bone Meal.
  sleep(0.2)
end