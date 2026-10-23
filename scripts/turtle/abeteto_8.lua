-- ABETETO 8 - ABETI 1x1 - CC:Tweaked - adattamento del 17 ottobre 2026
-- ADATTAMENTO DEL PROGRAMMA ORIGINALE querceto2.txt (salvato a parte).
-- ATTENZIONE: per la prima prova rimuovi gli alberi/piantine di quercia
-- dalle otto posizioni e metti 1 piantina di abete per ciascuna.
-- Imposta anche l'Exporter/fornitura della chest su minecraft:spruce_sapling.
-- Non usare insieme con querceto2.txt: checkpoint separato.
-- Chest dietro la Turtle: solo rifornimento sapling e lava.
-- Richiede almeno uno slot libero nella chest per selezionare gli oggetti.
-- Scarico raccolto verso il basso sopra l acqua a X=1911 Y=66 Z=2733.
-- La raccolta dei drop delle foglie e' affidata all'acqua/tramogge.
-- Non spostare ne' ruotare la Turtle durante l'esecuzione.
-- Punto di partenza: Turtle a X=1910, Y=67, Z=2732
-- Orientamento: EST (verso X crescente), chest subito dietro (OVEST).
-- Prova senza tagli: abeteto_8.lua prova
-- Singolo giro con taglio: abeteto_8.lua giro
-- Avvio automatico: abeteto_8.lua avvia
-- Non spostare la Turtle durante l'esecuzione.

local mode = ({...})[1] or "prova"
if mode ~= "prova" and mode ~= "giro" and mode ~= "avvia" then
  error("Uso: abeteto_8.lua prova | giro | avvia", 0)
end

local HOME_X, HOME_Y, HOME_Z = 1910, 67, 2732
local LANE_Z = 2732
local X_TREES = {1913, 1920, 1927, 1934}
local SOUTH_Z, NORTH_Z = 2735, 2728
local dirVectors = {
  [0] = {1, 0},  -- est (+X)
  [1] = {0, 1},  -- sud (+Z)
  [2] = {-1, 0}, -- ovest (-X)
  [3] = {0, -1}, -- nord (-Z)
}
local p = {x = HOME_X, y = HOME_Y, z = HOME_Z, dir = 0}
local CHECK_FILE = ".abeteto_8_prova_ok"
local treesCut = 0
local fuelAtLeast -- combustibile locale: implementazione piu' sotto

local function fail(message)
  error(message .. " | Posizione prevista: " ..
    p.x .. ", " .. p.y .. ", " .. p.z .. ", direzione=" .. p.dir ..
    ". NON riavviare finche' non e' di nuovo a casa verso EST.", 0)
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

local function spruceLog(name)
  return name == "minecraft:spruce_log" or name == "minecraft:spruce_wood"
end

local function sapling(name)
  return name == "minecraft:spruce_sapling"
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

-- Il legno e' un carburante DI EMERGENZA; la priorita' a casa e' la lava.
local function fuelItem(name)
  return name == "minecraft:coal" or name == "minecraft:charcoal"
    or spruceLog(name) or name == "minecraft:spruce_planks"
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
  face(2)
  local ok, block = turtle.inspect()
  face(0)
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
  face(2)
  local chest = peripheral.wrap("front")
  if not chest or not chest.list or not chest.pushItems or not chest.size then
    face(0)
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
  if not source then face(0); return 0 end
  local toSlot, capacity = pickupSlot(itemName)
  if not toSlot then face(0); fail("Inventario Turtle pieno, impossibile prelevare " .. itemName) end
  local amount = math.min(requested, capacity, contents[source].count)
  if amount <= 0 then face(0); return 0 end

  -- Se lo slot 1 contiene un altro oggetto, spostalo in uno slot vuoto.
  -- Non usiamo suck() alla cieca: rischierebbe di prendere mele o secchi vuoti.
  if source ~= 1 then
    if contents[1] then
      local free
      for i = 1, chest.size() do
        if not contents[i] then free = i; break end
      end
      if not free then
        face(0)
        fail("La chest deve avere almeno 1 slot libero per il rifornimento")
      end
      local moved = chest.pushItems("front", 1, contents[1].count, free)
      if moved ~= contents[1].count then
        face(0)
        fail("Non riesco a liberare lo slot 1 della chest")
      end
    end
    local moved = chest.pushItems("front", source, amount, 1)
    if moved ~= amount then
      face(0)
      fail("Impossibile preparare " .. itemName .. " per il prelievo")
    end
  end
  local before = turtle.getItemCount(toSlot)
  turtle.select(toSlot)
  local ok, why = turtle.suck(amount)
  local item = turtle.getItemDetail(toSlot)
  local gained = turtle.getItemCount(toSlot) - before
  if not ok or not item or item.name ~= itemName or gained ~= amount then
    face(0)
    fail("Prelievo non verificato per " .. itemName .. ": " .. tostring(why))
  end
  face(0)
  return gained
end

local function returnEmptyBuckets()
  face(2)
  for slot = 1, 16 do
    local item = turtle.getItemDetail(slot)
    if item and item.name == "minecraft:bucket" then
      turtle.select(slot)
      local done, why = turtle.drop(item.count)
      if not done or turtle.getItemCount(slot) ~= 0 then
        face(0)
        fail("Non posso restituire i secchi vuoti: " .. tostring(why))
      end
    end
  end
  face(0)
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
    local received = takeFromChest("minecraft:spruce_sapling", missing)
    if received == 0 then
      print("Attendo sapling nella chest (" .. countSaplings() .. "/8)...")
      sleep(30)
    else
      print("Prelevati " .. received .. " sapling (" .. countSaplings() .. "/8)")
    end
  end
end

local function checkTree(label)
  local ok, block = turtle.inspect()
  if ok and block and (spruceLog(block.name) or sapling(block.name)) then
    print(label .. ": " .. block.name .. " OK")
    return true
  end
  print(label .. ": NON riconosco tronco/piantina davanti (" ..
    (ok and block.name or "aria") .. ")")
  return false
end

-- ABETI NORMALI 1x1: tronco verticale, senza rami laterali di legno.
-- Tagliamo esclusivamente i tronchi sopra la posizione di partenza,
-- lasciando decadere naturalmente le foglie (la raccolta rimane ad acqua).
-- Questo e' piu' rapido e sicuro rispetto alla ricerca di rami delle querce.
-- Dopo la prima scavata la Turtle si trova GIA' nel blocco del tronco base.
local function chopConnectedTree(rootX, rootZ)
  if p.x ~= rootX or p.z ~= rootZ or p.y ~= HOME_Y then
    fail("Posizione iniziale abete non corretta")
  end
  local climbed = 0
  local MAX_TRUNK_HEIGHT = 30
  while climbed < MAX_TRUNK_HEIGHT do
    local ok, block = turtle.inspectUp()
    if not ok or not block or not spruceLog(block.name) then break end
    local done, why = turtle.digUp()
    if not done then fail("Impossibile tagliare il tronco sopra: " .. tostring(why)) end
    up()
    climbed = climbed + 1
  end
  -- Torna sempre alla quota iniziale (Y67) lungo la colonna svuotata.
  for _ = 1, climbed do down() end
  if climbed == MAX_TRUNK_HEIGHT then
    fail("Abete troppo alto: raggiunto il limite di 31 tronchi; verifica l'albero")
  end
end

local function processTree(label, rootX, rootZ)
  -- Qui la Turtle e' a un blocco dall'abete 1x1, rivolta verso il tronco.
  -- Raccogli eventuali oggetti vicini (non garantisce tutta la raccolta foglie).
  turtle.suckDown()
  local ok, block = turtle.inspect()
  if ok and sapling(block.name) then
    return -- non e' ancora cresciuta
  end
  if ok and not spruceLog(block.name) then
    print(label .. ": blocco inatteso " .. block.name .. "; salto")
    return
  end
  if ok and spruceLog(block.name) then
    local done, why = turtle.dig()
    if not done then fail(label .. ": impossibile tagliare: " .. tostring(why)) end
    forward(1) -- occupa temporaneamente il posto del tronco tagliato
    chopConnectedTree(rootX, rootZ)
    turtle.suckDown()
    backward(1)
    treesCut = treesCut + 1
  end
  -- Se la pianta non c'e' o e' stata tagliata, ripiantala.
  if not selectSapling() then fail(label .. ": mancano le piantine di abete") end
  local clear, obstacle = turtle.inspect()
  if clear then
    fail(label .. ": impossibile piantare, c'e' " .. obstacle.name)
  end
  local planted, why = turtle.place()
  if not planted then fail(label .. ": ripiantagione fallita: " .. tostring(why)) end
  print(label .. ": piantata")
end

local function pairAt(x, simulation)
  if p.x ~= x or p.z ~= LANE_Z or p.y ~= HOME_Y then
    fail("Fuori dal viale: non proseguo")
  end
  local index = math.floor((x - 1913) / 7)
  -- Abete sul lato sud (+Z): due passi, il tronco e' al terzo.
  face(1)
  forward(2)
  if simulation then
    local good = checkTree("A" .. (index + 1))
    backward(2)
    face(3)
    forward(3)
    local good2 = checkTree("A" .. (8 - index))
    backward(3)
    face(0)
    return good and good2
  end
  processTree("A" .. (index + 1), x, SOUTH_Z)
  backward(2)

  -- Abete sul lato nord (-Z): tre passi, il tronco e' al quarto.
  face(3)
  forward(3)
  processTree("A" .. (8 - index), x, NORTH_Z)
  backward(3)
  face(0)
  return true
end

local function backHome()
  if p.z ~= LANE_Z or p.y ~= HOME_Y then fail("Non sono nel viale") end
  face(2)
  forward(p.x - HOME_X)
  face(0)
end

-- Da casa (1910,67,2732), vai sopra il canale a (1911,66,2733).
-- La Turtle rimane a Y=67 e scarica sotto, NON davanti.
local function gotoWaterOutlet()
  if p.x ~= HOME_X or p.y ~= HOME_Y or p.z ~= HOME_Z then
    fail("Lo scarico acqua parte solo dalla base")
  end
  face(0)
  forward(1) -- X=1911, Z=2732
  face(1)
  forward(1) -- X=1911, Y=67, Z=2733: acqua a Y=66
  local found, block = turtle.inspectDown()
  if not found or not block or block.name ~= "minecraft:water" then
    -- Nessuno scarico: torna alla base prima di segnalare il problema.
    backward(1)
    face(2)
    forward(1)
    face(0)
    fail("Acqua non trovata sotto il punto di scarico (1911,66,2733)")
  end
end

local function returnFromWaterOutlet()
  -- Dal punto di scarico: torna esattamente a casa rivolto a EST.
  face(1)
  backward(1) -- X=1911, Z=2732
  face(2)
  forward(1) -- X=1910, Z=2732
  face(0)
end

local function storeInWater()
  verifyChest()
  gotoWaterOutlet()
  local droppedStacks = 0
  for slot = 1, 16 do
    local item = turtle.getItemDetail(slot)
    if item then
      -- Teniamo le piantine, carbone/carbonella e secchi, non il legno.
      local keep = sapling(item.name)
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
  forward(3) -- X 1913, Z 2732
  local good = true
  -- Verifica tutte le 8 posizioni e le corsie senza tagliare nulla.
  for i, x in ipairs(X_TREES) do
    if not pairAt(x, true) then good = false end
    if i < #X_TREES then forward(7) end
  end
  backHome()
  -- Nella prova controlliamo anche il punto di scarico SENZA gettare nulla.
  gotoWaterOutlet()
  returnFromWaterOutlet()
  print("Punto di scarico acqua (1911,66,2733): OK")
  if good then
    local handle = fs.open(CHECK_FILE, "w")
    handle.write("ok")
    handle.close()
    print("PROVA SUPERATA: Turtle tornata alla chest.")
    print("Ora: abeteto_8.lua giro (test) oppure avvia")
  else
    if fs.exists(CHECK_FILE) then fs.delete(CHECK_FILE) end
    print("PROVA NON SUPERATA. Nessun blocco tagliato.")
  end
  return
end

if not fs.exists(CHECK_FILE) then
  error("Prima esegui: abeteto_8.lua prova", 0)
end

print("ABETETO 8 - ABETI 1x1 - raccolta in acqua")
while true do
  waitForSaplings()
  prepareFuel(3000)
  treesCut = 0
  forward(3) -- X=1913, centro del viale
  for i, x in ipairs(X_TREES) do
    pairAt(x, false)
    if i < #X_TREES then forward(7) end
  end
  backHome()
  storeInWater()
  print("Giro terminato. Abeti tagliati: " .. treesCut)
  print("Piantine rimaste: " .. countSaplings())
  if mode == "giro" then
    print("GIRO DI TEST CONCLUSO: Turtle alla base.")
    break
  end
  print("Attendo 90 secondi...")
  sleep(90)
end