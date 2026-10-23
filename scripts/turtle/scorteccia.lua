-- MegaZero: cassa sopra = tronchi, cassa sotto = uscita, ascia nello slot 2
assert(turtle.getItemDetail(2) and turtle.getItemDetail(2).name:match('_axe$'), 'Metti l ascia nello slot 2')
for s = 1, 16 do
  if s ~= 2 then assert(turtle.getItemCount(s) == 0, 'Svuota lo slot ' .. s) end
end
assert(not turtle.detect(), 'Libera lo spazio davanti alla Turtle')
local n = 0
print('Scortecciatrice attiva! Ctrl+T per fermare.')
while true do
  assert(turtle.getItemDetail(2), 'Ascia esaurita')
  turtle.select(1)
  if turtle.suckUp(1) then
    local item = turtle.getItemDetail(1)
    local tipo = item and item.name:match('^minecraft:([%w_]+)_log$')
    assert(tipo and not tipo:match('^stripped_'), 'Nella cassa sopra c e un oggetto non valido')
    local risultato = 'minecraft:stripped_' .. tipo .. '_log'
    assert(turtle.place(), 'Non riesco a piazzare il tronco')
    turtle.select(2)
    assert(turtle.place(), 'Non riesco a usare l ascia')
    local ok, blocco = turtle.inspect()
    assert(ok and blocco.name == risultato, 'Il tronco non e scortecciato: controlla l ascia')
    turtle.select(1)
    assert(turtle.dig(), 'Non riesco a rompere il tronco')
    local raccolto = turtle.getItemDetail(1)
    assert(raccolto and raccolto.name == risultato, 'Non ho raccolto il tronco nello slot 1')
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
