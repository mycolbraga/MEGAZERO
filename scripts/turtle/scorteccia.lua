-- MegaZero: cassa sopra = tronchi + asce di ferro di ricambio
-- Cassa sotto = uscita; slot 1 = tronco, slot 2 = ascia, slot 3 = buffer
-- Nessun modem necessario: riordina temporaneamente gli slot della cassa superiore.
local IRON_AXE = 'minecraft:iron_axe'
local chest = peripheral.wrap('top')
assert(chest and chest.list and chest.size and chest.pushItems,
  'Serve una cassa/inventario riconosciuto sopra la Turtle')
local chestName = peripheral.getName(chest)
assert(chestName, 'Non riesco a identificare la cassa superiore')

local function isLog(item)
  if not item then return false end
  local kind = item.name:match('^minecraft:([%w_]+)_log$')
  return kind ~= nil and not kind:match('^stripped_')
end

local function isAxe(item)
  return item and item.name == IRON_AXE
end

-- Porta l'oggetto desiderato al primo slot della cassa e lo aspira.
-- Se la cassa e' piena, usa temporaneamente lo slot 3 della Turtle.
local function takeFromChest(predicate, destSlot)
  assert(turtle.getItemCount(destSlot) == 0, 'Slot ' .. destSlot .. ' occupato')
  assert(turtle.getItemCount(3) == 0, 'Svuota lo slot buffer 3')
  local items = chest.list()
  local source
  for i = 1, chest.size() do
    if predicate(items[i]) then source = i; break end
  end
  if not source then return false end

  local buffered = false
  if source ~= 1 and items[1] then
    local free
    for i = 2, chest.size() do
      if not items[i] then free = i; break end
    end
    if free then
      local moved = chest.pushItems(chestName, 1, items[1].count, free)
      assert(moved == items[1].count,
        'Impossibile liberare il primo slot della cassa')
    else
      turtle.select(3)
      assert(turtle.suckUp(items[1].count),
        'Impossibile mettere temporaneamente da parte il primo stack')
      buffered = true
    end
  end

  if source ~= 1 then
    local moved = chest.pushItems(chestName, source, 1, 1)
    assert(moved == 1, 'Impossibile spostare l oggetto scelto nella cassa')
  end

  turtle.select(destSlot)
  local sucked = turtle.suckUp(1)
  if buffered then
    turtle.select(3)
    local warned = false
    while not turtle.dropUp() do
      if not warned then print('Cassa piena: attendo di restituire il buffer...'); warned = true end
      sleep(3)
    end
  end
  assert(sucked, 'Impossibile prelevare l oggetto scelto')
  turtle.select(destSlot)
  local result = turtle.getItemDetail(destSlot)
  assert(result and predicate(result),
    'L oggetto prelevato non corrisponde a quello atteso')
  return true
end

local function ensureAxe()
  local current = turtle.getItemDetail(2)
  if current then
    assert(current.name:match('_axe$'), 'Nello slot 2 c e un oggetto che non e un ascia')
    return
  end
  print('Ascia consumata: cerco ricambio nella cassa sopra...')
  local warned = false
  while not takeFromChest(isAxe, 2) do
    if not warned then
      print('Nessuna ascia di ferro disponibile: attendo rifornimento...')
      warned = true
    end
    sleep(5)
  end
  print('Ascia di ferro nuova caricata nello slot 2.')
end

for s = 1, 16 do
  if s ~= 2 then assert(turtle.getItemCount(s) == 0, 'Svuota lo slot ' .. s) end
end
local initial = turtle.getItemDetail(2)
assert(not initial or initial.name:match('_axe$'),
  'Nello slot 2 deve esserci un ascia oppure deve essere vuoto')
assert(not turtle.detect(), 'Libera lo spazio davanti alla Turtle')

local n = 0
print('Scortecciatrice con ricambio asce attiva! Ctrl+T per fermare.')
while true do
  ensureAxe()
  if takeFromChest(isLog, 1) then
    local item = turtle.getItemDetail(1)
    local tipo = item.name:match('^minecraft:([%w_]+)_log$')
    local risultato = 'minecraft:stripped_' .. tipo .. '_log'
    turtle.select(1)
    assert(turtle.place(), 'Non riesco a piazzare il tronco')
    turtle.select(2)
    turtle.place()
    local ok, blocco = turtle.inspect()
    if not (ok and blocco.name == risultato) and not turtle.getItemDetail(2) then
      ensureAxe()
      turtle.select(2)
      turtle.place()
      ok, blocco = turtle.inspect()
    end
    assert(ok and blocco.name == risultato,
      'Il tronco non e scortecciato: controlla l ascia')
    turtle.select(1)
    assert(turtle.dig(), 'Non riesco a rompere il tronco')
    local raccolto = turtle.getItemDetail(1)
    assert(raccolto and raccolto.name == risultato,
      'Non ho raccolto il tronco nello slot 1')
    local avviso = false
    while not turtle.dropDown() do
      if not avviso then print('Uscita piena: attendo...'); avviso = true end
      sleep(3)
    end
    n = n + 1
    if n % 16 == 0 then print('Scortecciati: ' .. n) end
  else
    sleep(2)
  end
end
