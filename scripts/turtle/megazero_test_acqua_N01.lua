-- MEGAZERO | Test acqua a quattro blocchi dalla N01 | v1.0
-- Solo N01: home 2119 -53 2995, NORD. Max tre passi avanti,
-- prelievo sorgente al quarto blocco, tre passi indietro.
-- Non scava, non modifica la base, non altera il vecchio pilot.
local CONFIG="/megazero_config"
local STATE="/.megazero_test_acqua_N01"
local MODULE="/megazero_fluidi"
local HOME={x=2119,y=-53,z=2995}
local TARGET={x=2119,y=-53,z=2991}

assert(turtle,"Eseguire soltanto su una Mining Turtle")
local cf=assert(fs.open(CONFIG,"r"),"Configurazione MEGAZERO mancante")
local cfg=assert(textutils.unserialize(cf.readAll()),"Configurazione corrotta")
cf.close()
assert(cfg.site=="MINIERA-01" and cfg.unit=="N01", "Test esclusivo della N01")
assert(fs.exists(MODULE), "Modulo megazero_fluidi non trovato")
local fluidi=assert(dofile(MODULE),"Modulo fluidi non valido")
assert(type(fluidi.ensureBuckets)=="function" and type(fluidi.peek)=="function"
  and type(fluidi.resolve)=="function", "API fluidi non disponibile")
local rete=assert(dofile("/megazero_rete"),"Telemetria non disponibile")
local agent=assert(rete.new("N01","MINIERA-01",cfg.central or 54))

local function save(s)
  local f=assert(fs.open(STATE,"w"))
  f.write(textutils.serialize(s))
  f.close()
end
local s={steps=0,pending=false,waterCollected=false}
if fs.exists(STATE) then
  local f=assert(fs.open(STATE,"r"))
  s=assert(textutils.unserialize(f.readAll()),"Stato test acqua corrotto")
  f.close()
  assert(type(s.steps)=="number" and s.steps>=0 and s.steps<=3,
    "Numero passi non valido")
  assert(not s.pending,"MOVIMENTO INTERROTTO: posizione fisica incerta; verifica manuale")
  if s.waterCollected and s.steps==0 then
    print("Test precedente completato. Nessun nuovo movimento.")
    print("Riavvia normalmente la N01 con reboot.")
    return
  end
else
  save(s)
end

local function pos()
  return {x=HOME.x,y=HOME.y,z=HOME.z-s.steps}
end
local function report(status,detail,err)
  local p=pos()
  p.detail=detail
  p.error=err
  p.fuel=turtle.getFuelLevel()
  pcall(function() agent:report(status,p) end)
  print(status..": "..detail)
end
local function reserve()
  local fuel=turtle.getFuelLevel()
  if type(fuel)=="number" then
    assert(fuel>=s.steps+120,"Carburante non sufficiente per il ritorno")
  end
end
local function moveForward()
  assert(s.steps<3,"Limite dei tre passi raggiunto")
  local distance=s.steps+1
  local expected={x=HOME.x,y=HOME.y,z=HOME.z-distance}
  assert(expected.z>=2695 and expected.z<=2994,"Fuori settore N01")
  local present,block=turtle.inspect()
  if present then
    local name=type(block)=="table" and block.name or "?"
    local kind=fluidi.peek("front")
    if not kind or kind.kind~="ACQUA" or kind.source then
      error("Percorso non libero al passo "..distance..": "..name)
    end
    -- Attraversare esclusivamente ACQUA CORRENTE, senza sigillarla.
  end
  reserve()
  s.pending=true;save(s)
  local ok,why=turtle.forward()
  if not ok then
    s.pending=false;save(s)
    error("Passo "..distance.." impossibile: "..tostring(why))
  end
  s.steps=distance
  s.pending=false;save(s)
  report("PREPARAZIONE","TEST ACQUA: avanzamento "..distance.."/3")
end
local function goHome()
  if s.pending then error("Movimento non confermato: posizione incerta") end
  while s.steps>0 do
    local ok,why
    for _=1,8 do
      local fuel=turtle.getFuelLevel()
      assert(type(fuel)~="number" or fuel>0,"Nessun carburante per rientrare")
      s.pending=true;save(s)
      ok,why=turtle.back()
      if ok then
        s.steps=s.steps-1
        s.pending=false;save(s)
        break
      end
      s.pending=false;save(s)
      sleep(0.3)
    end
    if not ok then error("RIENTRO OSTACOLATO: "..tostring(why)) end
  end
end
local function countWater()
  local n=0
  for i=1,16 do
    local item=turtle.getItemDetail(i)
    if item and item.name=="minecraft:water_bucket" then n=n+item.count end
  end
  return n
end
local function unloadOneWater()
  for i=1,16 do
    local item=turtle.getItemDetail(i)
    if item and item.name=="minecraft:water_bucket" then
      turtle.select(i)
      local ok=turtle.dropDown(1)
      return ok
    end
  end
  return false
end

local function test()
  if s.steps>0 then
    report("RIENTRO","Traccia incompleta: rientro prima di nuove prove")
    goHome()
    error("Precedente test interrotto: tornata alla base, controllare prima di riprovare")
  end
  local ok,count=fluidi.ensureBuckets(3)
  assert(ok,"Scorta secchi: "..tostring(count))
  reserve()
  report("PREPARAZIONE","TEST ACQUA: 3 passi verso sorgente a 4 blocchi")
  for _=1,3 do moveForward() end
  local fluid=fluidi.peek("front")
  assert(fluid and fluid.kind=="ACQUA" and fluid.source,
    "Sorgente non trovata a 2119,-53,2991; tipo="..tostring(fluid and fluid.kind)..", livello="..tostring(fluid and fluid.level))
  local before=countWater()
  local result,detail=fluidi.resolve("front",TARGET,function(x,y,z)
    return x==TARGET.x and y==TARGET.y and z==TARGET.z
  end)
  assert(result=="raccolto","Bonifica non conclusa: "..tostring(result or detail))
  assert(countWater()>before,"Prelievo non confermato: nessun secchio d'acqua nuovo")
  s.waterCollected=true
  save(s)
  report("RIENTRO","Sorgente raccolta; rientro in corso")
  goHome()
  local dropped=unloadOneWater()
  save(s)
  report("BASE",dropped and "TEST ACQUA OK: sorgente raccolta e secchio scaricato" or
    "TEST ACQUA OK: sorgente raccolta; secchio in inventario (scarico non riuscito)")
end

print("MEGAZERO N01 | TEST ACQUA 4 BLOCCHI")
print("Nessuno scavo; massimo tre passi avanti e ritorno.")
local ok,reason=pcall(test)
if not ok then
  printError("TEST ACQUA: "..tostring(reason))
  if not s.pending and s.steps>0 then
    report("RIENTRO","Problema durante test: rientro di sicurezza")
    local back,why=pcall(goHome)
    if not back then
      report("ERRORE","Rientro non confermato: verificare posizione",tostring(why))
      printError("RIENTRO NON RIUSCITO: "..tostring(why))
    else
      report("ERRORE","Test interrotto ma N01 rientrata",tostring(reason))
    end
  else
    report("ERRORE",s.pending and "POSIZIONE INCERTA" or "Test interrotto alla base",tostring(reason))
  end
end
print("Premi INVIO per riavviare lo startup normale.")
read()
os.reboot()
