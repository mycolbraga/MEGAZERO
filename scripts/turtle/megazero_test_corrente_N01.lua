-- MEGAZERO | Test corrente N01 v1.0
-- Test SOLO N01: sorgente dopo corrente al quarto blocco (fino al sesto).
-- Segue max 6 blocchi lungo Z negativo, raccoglie la sorgente e rientra.
-- Non scava dentro la base, non tocca startup, non installa altri miner.
local UNIT,SITE="N01","MINIERA-01"
local STATE="/.megazero_corrente_N01_state"
local MAX=6
local HOME_X,HOME_Y,HOME_Z=2119,-53,2995
local cfgFile=assert(fs.open("/megazero_config","r"),"Config MEGAZERO mancante")
local cfg=assert(textutils.unserialize(cfgFile.readAll()),"Config non valida")
cfgFile.close()
assert(turtle and cfg.unit==UNIT and cfg.site==SITE,"SOLO turtle N01")
local fluidi=assert(dofile("/megazero_fluidi"),"Modulo fluidi mancante")
local rete=assert(dofile("/megazero_rete"),"Modulo rete mancante")
local agent,err=rete.new(UNIT,SITE,cfg.central or 54)
assert(agent,err or "Telemetria non disponibile")
local function save(s)
  local f=assert(fs.open(STATE,"w"))
  f.write(textutils.serialize(s))
  f.close()
end
local function readState()
  if not fs.exists(STATE) then return {steps=0,pending=false,done=false,got=false} end
  local f=assert(fs.open(STATE,"r"))
  local t=assert(textutils.unserialize(f.readAll()),"Stato danneggiato")
  f.close()
  assert(type(t)=="table" and type(t.steps)=="number" and t.steps>=0
    and t.steps<=MAX,"Traccia movimenti non valida")
  assert(not t.pending,"POSIZIONE INCERTA DOPO INTERRUZIONE: controllare N01")
  return t
end
local s=readState()
save(s)
local function position()
  return {x=HOME_X,y=HOME_Y,z=HOME_Z-s.steps}
end
local function signal(status,detail,problem)
  local p=position()
  p.detail=detail
  p.error=problem
  p.fuel=turtle.getFuelLevel()
  pcall(function() agent:report(status,p) end)
  print(status..": "..detail)
end
local function fuelCheck()
  local v=turtle.getFuelLevel()
  assert(type(v)~="number" or v>=s.steps+150,
    "Carburante insufficiente per rientro protetto")
end
local function waterBuckets()
  local count=0
  for i=1,16 do
    local item=turtle.getItemDetail(i)
    if item and item.name=="minecraft:water_bucket" then
      count=count+item.count
    end
  end
  return count
end
local function dumpWater()
  local count=0
  for i=1,16 do
    local item=turtle.getItemDetail(i)
    if item and item.name=="minecraft:water_bucket" then
      turtle.select(i)
      assert(turtle.dropDown(item.count),"Cassa inferiore piena: acqua non scaricata")
      count=count+item.count
    end
  end
  return count
end
-- Scava rocce naturali sicure solo nei primi TRE blocchi.
local safe={
  ["minecraft:stone"]=true,["minecraft:deepslate"]=true,
  ["minecraft:cobbled_deepslate"]=true,["minecraft:cobblestone"]=true,
  ["minecraft:tuff"]=true,["minecraft:andesite"]=true,
  ["minecraft:diorite"]=true,["minecraft:granite"]=true,
  ["minecraft:dirt"]=true,["minecraft:gravel"]=true,
  ["minecraft:calcite"]=true,["minecraft:dripstone_block"]=true
}
local function prepareForward(nextStep)
  for attempt=1,6 do
    local water=fluidi.peek("front")
    if water then
      assert(water.kind=="ACQUA","Lava o altro fluido lungo il test")
      assert(not water.source,"Sorgente: va raccolta prima di avanzare")
      return -- CORRENTE: si puo' attraversare senza bloccarla.
    end
    local exists,b=turtle.inspect()
    if not exists then
      if nextStep>3 then
        error("La corrente finisce senza sorgente in linea retta")
      end
      return
    end
    local name=b and b.name or "?"
    assert(nextStep<=3 and safe[name],
      "Blocco non autorizzato al passo "..nextStep..": "..name)
    local free=0
    for i=1,16 do
      if turtle.getItemCount(i)==0 then free=free+1 end
    end
    assert(free>=2,"Inventario quasi pieno, nessuno scavo")
    local ok,why=turtle.dig()
    assert(ok,"Impossibile scavare: "..tostring(why))
    sleep(0.2)
  end
  error("Ostacolo persistente davanti")
end
local function forward()
  local nextStep=s.steps+1
  assert(nextStep<=MAX,"Limite massimo prova raggiunto")
  local nextZ=HOME_Z-nextStep
  assert(nextZ<=2994 and nextZ>=2695,
    "Passo fuori settore N01")
  fuelCheck()
  prepareForward(nextStep)
  s.pending=true
  save(s)
  local ok,why=turtle.forward()
  if not ok then
    s.pending=false
    save(s)
    error("Avanzamento bloccato: "..tostring(why))
  end
  s.steps=nextStep
  s.pending=false
  save(s)
  signal("PREPARAZIONE","CORRENTE: posizione "..nextStep.."/"..MAX)
end
local function returnHome()
  assert(not s.pending,"Posizione incerta, impossibile rientro automatico")
  while s.steps>0 do
    fuelCheck()
    local ok,why
    for try=1,8 do
      s.pending=true
      save(s)
      ok,why=turtle.back()
      if ok then
        s.steps=s.steps-1
        s.pending=false
        save(s)
        break
      end
      s.pending=false
      save(s)
      sleep(0.3)
    end
    assert(ok,"Rientro bloccato: "..tostring(why))
  end
end
local function test()
  if s.done then
    signal("BASE","TEST GIA' COMPLETATO: nessun movimento")
    return
  end
  if s.steps>0 then
    signal("RIENTRO","Ripristino da test precedente")
    returnHome()
    error("Rientrata da interruzione precedente; controllare prima di ripartire")
  end
  local ok,count=fluidi.ensureBuckets(3)
  assert(ok,"Scorta secchi: "..tostring(count))
  fuelCheck()
  signal("PREPARAZIONE","CORRENTE: cerco sorgente tra quarto e sesto blocco")
  while s.steps<MAX do
    local w=fluidi.peek("front")
    if w and w.kind=="ACQUA" and w.source then
      local targetZ=HOME_Z-s.steps-1
      assert(targetZ<=2991 and targetZ>=2989,
        "Sorgente fuori zona di prova: "..targetZ)
      local before=waterBuckets()
      local result,detail=fluidi.resolve("front",
        {x=HOME_X,y=HOME_Y,z=targetZ},
        function(x,y,z)
          return x==HOME_X and y==HOME_Y and
            z==targetZ and z>=2989 and z<=2991
        end)
      assert(result=="raccolto",
        "Sorgente non raccolta: "..tostring(detail or result))
      assert(waterBuckets()>before,
        "Non e' comparso il secchio d'acqua")
      s.got=true
      save(s)
      sleep(2)
      assert(not fluidi.peek("front"),
        "Acqua ancora presente dopo raccolta: possibile altra sorgente")
      signal("RIENTRO","Sorgente eliminata a Z="..targetZ.."; torno a casa")
      returnHome()
      local dropped=dumpWater()
      assert(dropped>=1,"Secchio d'acqua non scaricato")
      s.done=true
      save(s)
      signal("BASE","TEST CORRENTE OK: sorgente eliminata, secchi scaricati")
      return
    end
    if s.steps>=3 then
      assert(w and w.kind=="ACQUA" and not w.source,
        "La corrente non prosegue dritta: sorgente laterale/sopra o assente")
    end
    forward()
  end
  error("Sorgente non trovata entro il sesto blocco")
end

print("MEGAZERO N01 | TEST CORRENTE 4-6 BLOCCHI")
print("Nessuna modifica a startup, nessun scavo nella base.")
local ok,why=pcall(test)
if not ok then
  printError("TEST CORRENTE: "..tostring(why))
  if not s.pending and s.steps>0 then
    signal("RIENTRO","Anomalia: rientro di sicurezza")
    local returned,reason=pcall(returnHome)
    if not returned then
      signal("ERRORE","RIENTRO NON CONFERMATO",tostring(reason))
    else
      if s.got then pcall(dumpWater) end
      signal("ERRORE","Test fermato; N01 rientrata",tostring(why))
    end
  else
    signal("ERRORE",s.pending and "POSIZIONE INCERTA" or "Test non riuscito alla base",
      tostring(why))
  end
end
print("Premi INVIO per tornare allo startup.")
read()
os.reboot()
