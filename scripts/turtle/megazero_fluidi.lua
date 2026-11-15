-- MEGAZERO FLUIDI v1.0 | Modulo bonifica + collaudo fermo N01
-- Uso sul terminale N01: megazero_fluidi N01
-- Uso come modulo futuro: local fluidi = dofile("/megazero_fluidi")
-- NON muove, NON scava, NON crea fluidi. Gestisce solo la faccia ispezionata.

local M = {}
local FLUIDS = {
  ["minecraft:water"]="ACQUA",
  ["minecraft:lava"]="LAVA"
}
local SOLIDS = {
  ["minecraft:cobblestone"]=true,
  ["minecraft:cobbled_deepslate"]=true,
  ["minecraft:stone"]=true,
  ["minecraft:deepslate"]=true,
  ["minecraft:tuff"]=true
}

local function info(slot)
  return turtle.getItemDetail(slot)
end

local function selectItem(name)
  for i=1,16 do
    local item=info(i)
    if item and item.name==name then
      turtle.select(i)
      return i,item.count
    end
  end
end

local function freeSlot()
  for i=1,16 do
    if turtle.getItemCount(i)==0 then return i end
  end
end

function M.countBuckets()
  local n=0
  for i=1,16 do
    local item=info(i)
    if item and item.name=="minecraft:bucket" then n=n+item.count end
  end
  return n
end

local function lavaInTopChest()
  local chest=peripheral.wrap("top")
  if not chest or not chest.list or not chest.size
      or not chest.pushItems then
    return false,"Cassa sopra non leggibile"
  end
  local items=chest.list()
  local wanted
  for slot,item in pairs(items) do
    if item.name=="minecraft:lava_bucket" and item.count>0 then
      wanted=slot
      break
    end
  end
  if not wanted then return false,"Nessun secchio di lava sopra" end
  if wanted~=1 then
    local name=peripheral.getName(chest)
    if items[1] then
      local empty
      for i=chest.size(),2,-1 do
        if not items[i] then empty=i;break end
      end
      if not empty then return false,"Serve uno slot libero nella cassa sopra" end
      if chest.pushItems(name,1,items[1].count,empty)~=items[1].count then
        return false,"Non riesco a liberare lo slot 1 della cassa"
      end
    end
    if chest.pushItems(name,wanted,1,1)~=1 then
      return false,"Impossibile portare il secchio nello slot 1"
    end
  end
  return true
end

-- Da usare SOLO presso la propria cassa, prima di iniziare un lavoro.
-- Non esiste tetto artificiale a 4000: usa getFuelLimit().
function M.ensureBuckets(minimum)
  assert(type(minimum)=="number" and minimum>=0 and minimum<=10,
    "Scorta richiesta non valida")
  local count=M.countBuckets()
  while count<minimum do
    local limit=turtle.getFuelLimit()
    local fuel=turtle.getFuelLevel()
    if type(limit)~="number" or type(fuel)~="number" then
      return false,"Carburante illimitato/non numerico: rifornimento non disponibile"
    end
    if fuel>=limit then
      return false,"Carburante pieno: non posso produrre altri secchi vuoti"
    end
    local slot=freeSlot()
    if not slot then
      return false,"Inventario pieno: non c'e' spazio per un secchio di lava"
    end
    local ok,err=lavaInTopChest()
    if not ok then return false,err end
    turtle.select(slot)
    if not turtle.suckUp(1) then
      return false,"Secchio di lava non prelevato dalla cassa sopra"
    end
    local got=info(slot)
    if not got or got.name~="minecraft:lava_bucket" then
      return false,"Oggetto inatteso prelevato dall'alto: fermo per sicurezza"
    end
    if not turtle.refuel(1) then
      return false,"Rifornimento lava fallito"
    end
    local empty=info(slot)
    if not empty or empty.name~="minecraft:bucket" then
      return false,"Secchio vuoto non trovato dopo il rifornimento"
    end
    count=M.countBuckets()
  end
  return true,count
end

local function inspectAt(side)
  if side=="front" then return turtle.inspect()
  elseif side=="up" then return turtle.inspectUp()
  elseif side=="down" then return turtle.inspectDown()
  else error("Direzione non valida: "..tostring(side)) end
end
local function placeAt(side)
  if side=="front" then return turtle.place()
  elseif side=="up" then return turtle.placeUp()
  else return turtle.placeDown() end
end

function M.peek(side)
  local present,block=inspectAt(side)
  if not present or type(block)~="table" then return nil end
  local kind=FLUIDS[block.name]
  if not kind then return nil end
  local level=block.state and tonumber(block.state.level)
  return {kind=kind, name=block.name, source=(level==0), level=level}
end

local function oneEmptyBucket()
  local original,count=selectItem("minecraft:bucket")
  if not original then return false,"Nessun secchio vuoto disponibile" end
  if count>1 then
    local target=freeSlot()
    if not target then return false,"Serve uno slot libero per separare il secchio" end
    if not turtle.transferTo(target,1) then
      return false,"Non riesco a separare un secchio vuoto"
    end
    turtle.select(target)
  end
  return true
end

local function solidSlot()
  for i=1,16 do
    local item=info(i)
    if item and SOLIDS[item.name] then
      turtle.select(i)
      return i,item.name
    end
  end
end

-- Il chiamante deve autorizzare le coordinate fisiche della cella.
-- Risultati: "libero", "raccolto", "sigillato" oppure nil + errore.
-- Una cella SIGILLATA resta solida: NON va scavata subito.
function M.resolve(side, pos, allowed)
  if type(pos)~="table" or type(allowed)~="function"
      or not allowed(pos.x,pos.y,pos.z) then
    return nil,"Cella non autorizzata: protezione settore/base"
  end
  local collected=0
  for attempt=1,5 do
    local fluid=M.peek(side)
    if not fluid then
      return collected>0 and "raccolto" or "libero",collected
    end
    if fluid.source then
      local ok,err=oneEmptyBucket()
      if not ok then return nil,err end
      local before=fluid.kind
      local placed,reason=placeAt(side)
      if not placed then
        return nil,"Prelievo "..before.." non riuscito: "..tostring(reason)
      end
      collected=collected+1
      sleep(0.25)
    else
      -- Corrente: isolare il flusso con un blocco pieno, non scavarlo
      -- immediatamente (altrimenti puo' riformarsi).
      local slot,name=solidSlot()
      if not slot then
        return nil,"Corrente "..fluid.kind..": mancano blocchi pieni"
      end
      local placed,reason=placeAt(side)
      if not placed then
        return nil,"Impossibile sigillare "..fluid.kind..": "..tostring(reason)
      end
      sleep(0.25)
      local now=M.peek(side)
      local exists,block=inspectAt(side)
      if now or not exists or type(block)~="table" or block.name~=name then
        return nil,"Sigillatura non confermata: verifica necessaria"
      end
      return "sigillato",name
    end
  end
  return nil,"Sorgenti rigenerate ripetutamente: richiede isolamento"
end

local args={...}
if #args>0 then
  if args[1]~="N01" then
    printError("Test autorizzato SOLO sulla Turtle N01")
    return
  end
  assert(turtle,"Da eseguire su una Turtle")
  local f=assert(fs.open("/megazero_config","r"),
    "Configurazione MEGAZERO non trovata")
  local cfg=textutils.unserialize(f.readAll())
  f.close()
  assert(cfg and cfg.site=="MINIERA-01" and cfg.unit=="N01",
    "Non e' la N01 della miniera")
  print("MEGAZERO | TEST BONIFICA N01")
  print("NESSUN MOVIMENTO / SCAVO / LAVA GENERATA")
  print("Verifico scorta di 3 secchi vuoti...")
  local ok,detail=M.ensureBuckets(3)
  print("Scorta: "..(ok and "OK" or "DA VERIFICARE"))
  if not ok then printError(detail) else print("Secchi vuoti: "..detail) end
  print("Carburante: "..tostring(turtle.getFuelLevel())
    .."/"..tostring(turtle.getFuelLimit()))
  print("Controllo il blocco esterno davanti alla N01...")
  local fluid=M.peek("front")
  if fluid then
    print(fluid.kind..", "..(fluid.source and "SORGENTE" or "CORRENTE"))
    local result,more=M.resolve("front",{x=2119,y=-53,z=2994},
      function(x,y,z) return x==2119 and y==-53 and z==2994 end)
    if result then
      print("BONIFICA: "..result.." | "..tostring(more))
    else
      printError("BONIFICA NON RISOLTA: "..tostring(more))
    end
  else
    print("Nessun fluido davanti: nessuna modifica al mondo.")
  end
  print("Premi INVIO per tornare allo startup MEGAZERO.")
  read()
  os.reboot()
else
  return M
end
