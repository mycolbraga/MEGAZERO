-- MEGAZERO QUERCETO - NUOVA FARM 8x 1x1
-- Copia adattata dal programma storico; originale INALTERATO.
-- Turtle base: 1903,66,2715, guarda NORD. Chest dietro a 1903,66,2716.
-- Terra = Y66, primo tronco = Y67; la Turtle sale 1 blocco durante il lavoro.
-- Coppie di alberi X=1899 e 1907, Z=2712/2705/2698/2691.
-- Punto di scarico: 1903,66,2714, acqua SOTTO a 1903,65,2714.
-- Prima fare 'prova': verifica percorso e acqua senza tagli o piantagioni.
-- Script NON ancora collaudato nel mondo di gioco.

local mode = ({...})[1] or "prova"
if mode ~= "prova" and mode ~= "giro" and mode ~= "avvia" then
  error("Uso: querceto_1x1.lua prova | giro | avvia", 0)
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
local CHECK_FILE = ".nuova_oak_1x1_prova_ok"
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

local function oakLog(name)
  return name == "minecraft:oak_log" or name == "minecraft:oak_wood"
end

local function sapling(name)
  return name == "minecraft:oak_sapling"
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
    or oakLog(name) or name == "minecraft:oak_planks"
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
    local received = takeFromChest("minecraft:oak_sapling", missing)
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
  if ok and block and (oakLog(block.name) or sapling(block.name)) then
    print(label .. ": " .. block.name .. " OK")
    return true
  end
  print(label .. ": NON riconosco tronco/piantina davanti (" ..
    (ok and block.name or "aria") .. ")")
  return false
end

-- Raccoglie tronchi collegati e RAMI SPARSI nella chioma.
-- Dai tronchi superiori cerca fino a 2 celle attraverso ARIA o FOGLIE DI QUERCIA;
-- in ciascuna controlla le 6 direzioni: intercetta tronchi staccati/diagonali.
-- NON attraversa muri, strutture o blocchi diversi dalle foglie di quercia.
-- Volume per ogni albero: +/-3 su X/Z, fino a +18 Y, per non toccare vicini.
-- Ricognizione limitata per evitare consumi e percorsi eccessivi.
local function chopConnectedTree(rootX, rootZ)
  local seen, seenCount = {}, 0
  local scouted = {}             -- posizione -> profondita' residua gia' esplorata
  local scoutVisits = 0
  local MAX_SCOUT_VISITS = 180 -- limite sicurezza, per singolo albero
  local scoutLimitReached = false
  local function within(x, y, z)
    return math.abs(x - rootX) <= 3 and math.abs(z - rootZ) <= 3
      and y >= WORK_Y and y <= WORK_Y + 18
  end
  local function key(x, y, z)
    return x .. ":" .. y .. ":" .. z
  end

  local visit -- dichiarata prima: usata anche dalla ricognizione diagonale
  local scoutLeaves -- esplorazione fino a 2 celle dalla parte alta dei tronchi

  -- Dalla posizione di ricognizione guarda le 6 facce. Scava SOLO oak_log/wood.
  local function inspectForLogs()
    local scoutDir = p.dir

    if within(p.x, p.y + 1, p.z) then
      local ok, b = turtle.inspectUp()
      if ok and oakLog(b.name) then
        local done, why = turtle.digUp()
        if not done then fail("Ramo diagonale sopra non tagliato: " .. tostring(why)) end
        up()
        visit()
        down()
      end
    end

    for d = 0, 3 do
      face(d)
      local v = dirVectors[d]
      if within(p.x + v[1], p.y, p.z + v[2]) then
        local ok, b = turtle.inspect()
        if ok and oakLog(b.name) then
          local done, why = turtle.dig()
          if not done then fail("Ramo diagonale non tagliato: " .. tostring(why)) end
          forward(1)
          visit()
          backward(1)
        end
      end
    end

    if within(p.x, p.y - 1, p.z) then
      local ok, b = turtle.inspectDown()
      if ok and oakLog(b.name) then
        local done, why = turtle.digDown()
        if not done then fail("Ramo diagonale sotto non tagliato: " .. tostring(why)) end
        down()
        visit()
        up()
      end
    end
    face(scoutDir)
  end

  -- Da un tronco (oppure da una cella di ricognizione), percorre fino a
  -- depth celle di aria/foglie. Da ogni cella cerca tronchi in 6 direzioni.
  -- Evita cicli e ricontrolli con la profondita' residua per posizione.
  scoutLeaves = function(depth)
    if depth <= 0 then return end
    local startDir = p.dir
    for d = 0, 3 do
      face(d)
      local v = dirVectors[d]
      local nx, nz = p.x + v[1], p.z + v[2]
      local cellKey = key(nx, p.y, nz)
      local remaining = depth - 1
      if within(nx, p.y, nz) and p.y >= WORK_Y + 2
        and (scouted[cellKey] == nil or scouted[cellKey] < remaining) then
        local blocked, b = turtle.inspect()
        if not blocked or (b and b.name == "minecraft:oak_leaves") then
          if scoutVisits < MAX_SCOUT_VISITS then
            scouted[cellKey] = remaining
            scoutVisits = scoutVisits + 1
            if blocked then
              local done, why = turtle.dig()
              if not done then fail("Foglie chioma non rimosse: " .. tostring(why)) end
            end
            forward(1)
            inspectForLogs()
            scoutLeaves(remaining)
            backward(1)
          else
            scoutLimitReached = true
          end
        end
      end
    end
    face(startDir)
  end

  visit = function()
    local posKey = key(p.x, p.y, p.z)
    if seen[posKey] then return end
    seen[posKey] = true
    seenCount = seenCount + 1
    if seenCount > 100 then fail("Oltre 100 posizioni di tronco: fermata di sicurezza") end
    local originalDir = p.dir

    -- Prima segui i tronchi uniti faccia a faccia (comportamento gia' collaudato).
    if within(p.x, p.y + 1, p.z) then
      local ok, b = turtle.inspectUp()
      if ok and oakLog(b.name) then
        local done, why = turtle.digUp()
        if not done then fail("Tronco sopra non tagliato: " .. tostring(why)) end
        up()
        visit()
        down()
      end
    end

    for d = 0, 3 do
      face(d)
      local v = dirVectors[d]
      if within(p.x + v[1], p.y, p.z + v[2]) then
        local ok, b = turtle.inspect()
        if ok and oakLog(b.name) then
          local done, why = turtle.dig()
          if not done then fail("Tronco laterale non tagliato: " .. tostring(why)) end
          forward(1)
          visit()
          backward(1)
        end
      end
    end

    if within(p.x, p.y - 1, p.z) then
      local ok, b = turtle.inspectDown()
      if ok and oakLog(b.name) then
        local done, why = turtle.digDown()
        if not done then fail("Tronco sotto non tagliato: " .. tostring(why)) end
        down()
        visit()
        up()
      end
    end

    -- Cerca tronchi nascosti anche oltre due foglie/aria nella chioma.
    -- Solo dai tronchi a quota +2 o superiore: non tocca il viale.
    if p.y >= WORK_Y + 2 then
      scoutLeaves(2)
    end
    face(originalDir)
  end

  visit()
  if scoutLimitReached then
    print("ATTENZIONE: limite ricognizione chioma raggiunto; potrebbero restare rami.")
  end
end

local function processTree(label, rootX, rootZ)
  -- Qui la Turtle e' a un blocco dal tronco, rivolta verso il tronco.
  -- Raccogli eventuali oggetti vicini (non garantisce tutta la raccolta foglie).
  turtle.suckDown()
  local ok, block = turtle.inspect()
  if ok and sapling(block.name) then
    return -- non e' ancora cresciuta
  end
  if ok and not oakLog(block.name) then
    print(label .. ": blocco inatteso " .. block.name .. "; salto")
    return
  end
  if ok and oakLog(block.name) then
    local done, why = turtle.dig()
    if not done then fail(label .. ": impossibile tagliare: " .. tostring(why)) end
    forward(1) -- occupa temporaneamente il posto del tronco tagliato
    chopConnectedTree(rootX, rootZ)
    turtle.suckDown()
    backward(1)
    treesCut = treesCut + 1
  end
  -- Se la pianta non c'e' o e' stata tagliata, ripiantala.
  if not selectSapling() then fail(label .. ": mancano le piantine di quercia") end
  local clear, obstacle = turtle.inspect()
  if clear then
    fail(label .. ": impossibile piantare, c'e' " .. obstacle.name)
  end
  local planted, why = turtle.place()
  if not planted then fail(label .. ": ripiantagione fallita: " .. tostring(why)) end
  print(label .. ": piantata")
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
    goodWest = checkTree("Q" .. (index + 1))
  else
    processTree("Q" .. (index + 1), WEST_X, z)
  end
  backward(3)

  face(0) -- EST
  forward(3) -- X1906; albero davanti X1907
  if simulation then
    goodEast = checkTree("Q" .. (8 - index))
  else
    processTree("Q" .. (8 - index), EAST_X, z)
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
    print("Ora: querceto_1x1.lua giro (test) oppure avvia")
  else
    if fs.exists(CHECK_FILE) then fs.delete(CHECK_FILE) end
    print("PROVA NON SUPERATA. Nessun blocco tagliato.")
  end
  return
end

if not fs.exists(CHECK_FILE) then
  error("Prima esegui: querceto_1x1.lua prova", 0)
end

print("QUERCETO NUOVO 1x1 - raccolta in acqua")
while true do
  waitForSaplings()
  prepareFuel(800)
  treesCut = 0
  up() -- da Y66 a Y67, quota tronchi
  face(3) -- NORD
  forward(3) -- Z2712 prima coppia
  for i, z in ipairs(Z_TREES) do
    pairAt(z, false)
    if i < #Z_TREES then forward(7) end
  end
  backHome()
  storeInWater()
  print("Giro terminato. Querce tagliate: " .. treesCut)
  print("Piantine rimaste: " .. countSaplings())
  if mode == "giro" then
    print("GIRO DI TEST CONCLUSO: Turtle alla base.")
    break
  end
  print("Attendo 90 secondi...")
  sleep(90)
end