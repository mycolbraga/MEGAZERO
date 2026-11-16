-- MEGAZERO MINER v2.1 | 40 Turtle, gallerie 2x2, fluidi, fuel 10000, scarti selettivi
-- Modulo per megazero_boot: return function(agent, config, opzioni)
-- Non eseguire in automatico prima del collaudo di N01.
-- Gallerie Y -1,-4,...,-61 (testa a Y 0,...,-60), max 300.
-- Spawner scavabili; blocchi tecnici protetti; verificare la quota bedrock reale.
-- Ritorno fisico per passi inversi; nessun lavoro dentro il perimetro base.

local M = {}
local DXY = {[0]={0,-1},[1]={1,0},[2]={0,1},[3]={-1,0}}
local BASE_Y = -53
local LEVELS={}
for y=-1,-61,-3 do LEVELS[#LEVELS+1]=y end
local ORE_WORDS = {":ore_", "_ore"}
local GRAVITY = { ["minecraft:gravel"]=true, ["minecraft:sand"]=true,
 ["minecraft:red_sand"]=true }
-- Solo scarti vanilla certi; NON buttare minerali, mod sconosciute o flint.
local DISCARD = {}
for _,n in ipairs({
 "stone","cobblestone","deepslate","cobbled_deepslate","tuff",
 "granite","diorite","andesite","calcite","dripstone_block",
 "pointed_dripstone","gravel","sand","red_sand","dirt",
 "coarse_dirt","rooted_dirt","grass_block","netherrack",
 "basalt","smooth_basalt","blackstone","soul_sand"
}) do DISCARD["minecraft:"..n]=true end
-- Scorta per bloccare i fluidi presa SOLO dallo scavo.
local SEAL_STOCK={}
for _,n in ipairs({"cobblestone","cobbled_deepslate","stone","deepslate",
 "tuff","granite","diorite","andesite","calcite","blackstone"}) do
 SEAL_STOCK["minecraft:"..n]=true
end
local NATURAL = {}
for _,n in ipairs({
 "stone","deepslate","cobbled_deepslate","cobblestone",
 "tuff","granite","diorite","andesite","dirt","grass_block",
 "gravel","sand","red_sand","calcite","dripstone_block",
 "pointed_dripstone","clay","moss_block","mud","packed_mud",
 "rooted_dirt","coarse_dirt","soul_sand","basalt","smooth_basalt",
 "blackstone","netherrack","terracotta"
}) do NATURAL["minecraft:"..n]=true end

local function isOre(b)
 if not b or type(b.name)~="string" then return false end
 local n=b.name:lower()
 for _,word in ipairs(ORE_WORDS) do if n:find(word,1,true) then return true end end
 if n=="minecraft:ancient_debris" then return true end
 if type(b.tags)=="table" then
  for tag,present in pairs(b.tags) do
   if present and type(tag)=="string"
       and (tag:find("ores/",1,true) or tag:find(":ores",1,true)
        or tag:find(":ore_",1,true)) then return true end
  end
 end
 return false
end
local function isSpawner(b)
 local n=type(b)=="table" and b.name or tostring(b or "")
 return type(n)=="string" and (n=="minecraft:spawner" or n:match("[_:]spawner$")~=nil)
end
local function unsafe(name)
 local n=tostring(name or "?"):lower()
 -- Redstone ore e spawner sono scavabili; componenti tecnici restano protetti.
 if isOre({name=n}) or isSpawner({name=n}) then return false end
 for _,word in ipairs({
 "chest","turtle","computer","modem","cable","machine","pipe",
 "importer","exporter","receiver","transmitter","drawer","monitor",
 "hopper","shulker","barrel","furnace","spawner","pump","storage",
 "generator","charger","redstone","crafting","door","piston","bedrock",
 "barrier","command_block","structure_block"
 }) do if n:find(word,1,true) then return true end end
 return false
end
local function homeFor(unit)
 local side,number
 if type(unit)=="string" then side,number=unit:match("^([NOSE])(%d%d)$") end
 number=tonumber(number)
 assert(side and number and number>=1 and number<=10,
   "Identificativo non valido, richiesto N/O/S/E + 01..10")
 local i=number-1
 if side=="N" then return 2119-2*i,BASE_Y,2995,0
 elseif side=="O" then return 2099,BASE_Y,2995+2*i,3
 elseif side=="S" then return 2099+2*i,BASE_Y,3015,2
 else return 2119,BASE_Y,3015-2*i,1 end
end
-- Compatibile con il loader /megazero_boot gia' installato.
function M.start(agent,cfg,options)
 assert(turtle and type(agent)=="table" and type(cfg)=="table",
   "Questo miner richiede Turtle, config e agente telemetrico")
 assert(cfg.site=="MINIERA-01","Sito non previsto da questa versione")
 options=options or {}
 local maxDistance=options.distance or 300
 local maxLevels=options.levels or #LEVELS
 assert(type(maxDistance)=="number" and maxDistance>=1 and maxDistance<=300
  and maxDistance%1==0,"Distanza non valida")
 assert(type(maxLevels)=="number" and maxLevels>=1 and maxLevels<=#LEVELS
  and maxLevels%1==0,"Numero livelli non valido")
 local hx,hy,hz,front=homeFor(cfg.unit)
 local left=(front+3)%4
 local dir=DXY[front]
 local side=DXY[left]
 local mode=(options.prova and "_PROVA" or "_LAVORO")
 local PATH="/.megazero_miner_v21_"..cfg.unit..mode..
   (options.prova and ("_"..maxDistance.."x"..maxLevels) or "")
 local LATCH="/.megazero_miner_error"
 local fluidi=assert(dofile("/megazero_fluidi"),
   "Modulo fluidi assente: scaricare megazero_fluidi")
 local s={x=hx,y=hy,z=hz,d=front,path={},pending=nil,level=1,
   distance=0,finished=false,ore=0,buckets=0,blocked=0,waterPending=false}
 local function read(p)
  if not fs.exists(p) then return nil end
  local f=assert(fs.open(p,"r"));local v=f.readAll();f.close();return v
 end
 local old=read(PATH)
 if old then
  local value=assert(textutils.unserialize(old),"Stato miner corrotto")
  assert(type(value)=="table" and type(value.path)=="table"
   and value.x and value.y and value.z and value.d and value.level,
   "Traccia di scavo non valida")
  s=value
 end
 local function save()
  local f=assert(fs.open(PATH,"w"))
  f.write(textutils.serialize(s));f.close()
 end
 local function latch(why)
  local f=fs.open(LATCH,"w")
  if f then f.write(tostring(why));f.close() end
 end
 local function atHome()return s.x==hx and s.y==hy and s.z==hz end
 local function inSector(x,y,z)
  if y < -61 or y > 0 then return false end
  local dx,dz=x-hx,z-hz
  local forward=dx*dir[1]+dz*dir[2]
  local lateral=dx*side[1]+dz*side[2]
  return forward>=1 and forward<=300 and lateral>=0 and lateral<=1
 end
 local function canOccupy(x,y,z)
  return (x==hx and y==hy and z==hz) or inSector(x,y,z)
 end
 local function detailStatus(state,detail,problem)
  pcall(function()
   agent:report(state,{
    x=s.x,y=s.y,z=s.z,fuel=turtle.getFuelLevel(),
    detail=detail,error=problem,
    progress=math.min(100,math.floor(
      ((s.level-1)*maxDistance+math.min(maxDistance,s.distance))/
      (maxLevels*maxDistance)*100))
   })
  end)
  print(state..": "..detail)
 end
 local function coords(move)
  if move=="U" then return s.x,s.y+1,s.z end
  if move=="D" then return s.x,s.y-1,s.z end
  local d=DXY[s.d]
  return s.x+d[1],s.y,s.z+d[2]
 end
 local function inspect(move)
  if move=="U" then return turtle.inspectUp() end
  if move=="D" then return turtle.inspectDown() end
  return turtle.inspect()
 end
 local function dig(move)
  if move=="U" then return turtle.digUp() end
  if move=="D" then return turtle.digDown() end
  return turtle.dig()
 end
 local function fluidSide(move)
  return move=="U" and "up" or (move=="D" and "down" or "front")
 end
 local function currentFuel()
  local fuel=turtle.getFuelLevel()
  return type(fuel)=="number" and fuel or math.huge
 end
 local function reserveGoing(extra)
  assert(currentFuel()>=#s.path+(extra or 0)+180,
   "SCORTE: carburante vicino alla riserva di rientro")
 end
 local function reserveReturning()
  assert(currentFuel()>=#s.path+8,
   "Carburante non sufficiente al percorso di rientro")
 end
 local function freeSlots()
  local free=0
  for i=1,16 do if turtle.getItemCount(i)==0 then free=free+1 end end
  return free
 end
 local function compactInventory()
  -- Unisce stack compatibili prima di giudicare l'inventario pieno.
  for i=16,1,-1 do
   local item=turtle.getItemDetail(i)
   if item then
    for j=1,i-1 do
     local target=turtle.getItemDetail(j)
     if target and item.name==target.name then
      turtle.select(i)
      turtle.transferTo(j)
     end
     if turtle.getItemCount(i)==0 then break end
    end
   end
  end
 end
 local function pruneInventory(atBase)
  -- 16 blocchi di scavo per sigillare correnti, tutti gli altri scarti
  -- cadono nel mondo, mai nella cassa collegata a Refined Storage.
  local reserved=16
  compactInventory()
  for i=1,16 do
   local it=turtle.getItemDetail(i)
   if it and DISCARD[it.name] then
    local keep=0
    if SEAL_STOCK[it.name] then
     keep=math.min(reserved,it.count)
     reserved=reserved-keep
    end
    local excess=it.count-keep
    if excess>0 then
     turtle.select(i)
     local ok=atBase and turtle.drop(excess) or turtle.dropDown(excess)
     assert(ok,"Impossibile espellere materiale comune "..it.name)
    end
   end
  end
 end
 local function countItem(name)
  local n=0
  for i=1,16 do
   local item=turtle.getItemDetail(i)
   if item and item.name==name then n=n+item.count end
  end
  return n
 end
 local function turnTo(want)
  while s.d~=want do
   local n=(want-s.d)%4==3 and -1 or 1
   s.pending="TURN";save()
   local ok=n==-1 and turtle.turnLeft() or turtle.turnRight()
   assert(ok,"Rotazione impossibile")
   s.d=(s.d+n+4)%4
   s.pending=nil;save()
  end
 end
 -- I blocchi rimasti a sigillare le correnti non vanno rimossi subito.
 local traceCurrent -- ricerca sorgente dopo una corrente, definita dopo i movimenti
 local function bonify(move,x,y,z,allowFlow)
  assert(inSector(x,y,z),"Bonifica fuori fascia")
  local sideName=fluidSide(move)
  local f=fluidi.peek(sideName)
  if not f then return true end
  if not f.source and allowFlow then
   detailStatus("SCAVO","SEGUO CORRENTE "..f.kind.." da "..x..","..y..","..z)
   assert(type(traceCurrent)=="function","Ricerca corrente non inizializzata")
   local found=traceCurrent(f.kind)
   assert(found,"Sorgente "..f.kind..
     " non trovata nella propria fascia entro 64 celle: rientro di sicurezza")
   -- Il flusso rimasto dopo il prelievo puo' impiegare vari tick
   -- a svanire, soprattutto con la lava in grandi colonne.
   local timeout=f.kind=="LAVA" and 120 or 15
   local cleared=false
   for sec=1,timeout do
    if not fluidi.peek(sideName) then cleared=true;break end
    sleep(1)
   end
   assert(cleared,
     "Corrente "..f.kind.." ancora presente dopo il prelievo: verificare sorgenti ulteriori")
   s.waterPending=false;save()
   return true
  end
  local before=f.kind=="ACQUA" and countItem("minecraft:water_bucket")
    or countItem("minecraft:lava_bucket")
  detailStatus("SCAVO","BONIFICA "..f.kind.." "..x..","..y..","..z)
  local result,why=fluidi.resolve(sideName,{x=x,y=y,z=z},
    function(cx,cy,cz) return cx==x and cy==y and cz==z and
      inSector(cx,cy,cz) end)
  if result=="raccolto" then
   local after=f.kind=="ACQUA" and countItem("minecraft:water_bucket")
     or countItem("minecraft:lava_bucket")
   assert(after>before,"Prelievo non confermato nel secchio")
   s.buckets=s.buckets+1
   if f.kind=="ACQUA" then s.waterPending=false end
   save()
   sleep(0.4)
   assert(not fluidi.peek(sideName),"La sorgente si e' rigenerata")
   return true
  end
  if result=="sigillato" then
   s.blocked=s.blocked+1;save()
   return false -- lasciare il tappo integro; non scavarlo.
  end
  error("Bonifica fallita: "..tostring(why or result))
 end
 local function prepare(move,x,y,z,first,fluidTransit)
  -- Mai scavare o bonificare all'interno della base.
  assert(inSector(x,y,z),"Intervento fuori area o dentro la base vietato")
  if first then
   local exists=inspect(move)
   assert(not exists and not fluidi.peek(fluidSide(move)),
    "Uscita dalla base ostruita: non rompo infrastrutture")
   return
  end
  local freeChecks,digs=0,0
  -- Niente limite di otto colpi: sabbia e gravel possono cadere a colonne.
  -- Occorrono tre controlli consecutivi a vuoto prima di avanzare.
  while digs<256 do
   local f=fluidi.peek(fluidSide(move))
   if f then
    if fluidTransit and f.kind==fluidTransit and not f.source then return end
    local clear=bonify(move,x,y,z,true)
    if not clear then
     error("Cella sigillata contro una corrente: non puo' essere attraversata")
    end
    if f.kind=="ACQUA" and not f.source then return end
   end
   local exists,block=inspect(move)
   if not exists then
    freeChecks=freeChecks+1
    if freeChecks>=3 then return end
    sleep(0.15)
   else
    freeChecks=0
    local name=block and block.name or "?"
    if name=="minecraft:bedrock" then error("BEDROCK IN PERCORSO") end
    assert(not unsafe(name),"Infrastruttura o blocco protetto: "..name)
    assert(NATURAL[name] or isOre(block) or isSpawner(block),
     "Blocco non minerario sconosciuto: "..name)
    if freeSlots()<=2 then pruneInventory(false);compactInventory() end
    assert(freeSlots()>2,"SCORTE: inventario quasi pieno")
    local ok,why=dig(move)
    assert(ok,"Scavo impossibile "..name..": "..tostring(why))
    digs=digs+1
    sleep(GRAVITY[name] and 0.3 or 0.15)
   end
  end
  error("Colonna di gravel/sabbia o blocchi troppo lunga: oltre 256 tentativi")
 end
 local function step(move,first,oreOnly,fluidTransit)
  local x,y,z=coords(move)
  assert(canOccupy(x,y,z),"Movimento vietato fuori corsia")
  reserveGoing(1)
  if freeSlots()<=2 then pruneInventory(false);compactInventory() end
  assert(freeSlots()>2,"SCORTE: inventario quasi pieno")
  if oreOnly then
   local exists,block=inspect(move)
   assert(exists and isOre(block),"Nessun minerale nel ramo")
   local ok,why=dig(move)
   assert(ok,"Impossibile estrarre minerale: "..tostring(why))
   sleep(0.1)
   local f=fluidi.peek(fluidSide(move))
   if f then
    assert(bonify(move,x,y,z,false),"Vena aperta su corrente sigillata")
   end
   -- Dopo un minerale, gravel/sabbia sovrastanti possono ricadere.
   local still,b=inspect(move)
   if still and b and GRAVITY[b.name] then
    prepare(move,x,y,z,false)
   end
   assert(not inspect(move),"Vena ostruita dopo scavo")
   s.ore=s.ore+1;save()
  else
   prepare(move,x,y,z,first,fluidTransit)
  end
  pruneInventory(false)
  s.pending="STEP";save()
  local fn=move=="U" and turtle.up or move=="D" and turtle.down
    or turtle.forward
  local ok,why=fn()
  if not ok then
   s.pending=nil;save()
   error("Turtle bloccata: "..tostring(why))
  end
  s.path[#s.path+1]={m=move,d=s.d}
  s.x,s.y,s.z=x,y,z
  s.pending=nil;save()
  pcall(function() agent:heartbeat() end)
 end
 local function reverseOne()
  assert(not s.pending,"Posizione incerta dopo reboot")
  reserveReturning()
  local n=#s.path
  local item=assert(s.path[n],"Percorso di ritorno mancante")
  local fn,dx,dy,dz
  if item.m=="F" then
   turnTo((item.d+2)%4)
   fn=turtle.forward
   dx,dy,dz=DXY[s.d][1],0,DXY[s.d][2]
  elseif item.m=="U" then fn=turtle.down;dx,dy,dz=0,-1,0
  else fn=turtle.up;dx,dy,dz=0,1,0 end
  for attempt=1,8 do
   s.pending="BACK";save()
   local ok=fn()
   if ok then
    s.x,s.y,s.z=s.x+dx,s.y+dy,s.z+dz
    s.path[n]=nil
    s.pending=nil;save()
    pcall(function() agent:heartbeat() end)
    return
   end
   s.pending=nil;save()
   -- Gravel/sabbia ricaduti su una corsia gia' percorsa: rimuoverli
   -- SOLO se il prossimo blocco e' ancora dentro il settore autorizzato.
   local nx,ny,nz=s.x+dx,s.y+dy,s.z+dz
   if inSector(nx,ny,nz) then
    local inspectFn=item.m=="U" and turtle.inspectDown or
      (item.m=="D" and turtle.inspectUp or turtle.inspect)
    local digFn=item.m=="U" and turtle.digDown or
      (item.m=="D" and turtle.digUp or turtle.dig)
    local present,b=inspectFn()
    if present and b and GRAVITY[b.name] then
     assert(freeSlots()>0,"Rientro: inventario pieno e gravel nel passaggio")
     local cleared,reason=digFn()
     assert(cleared,"Rientro: gravel non eliminabile: "..tostring(reason))
    end
   end
   sleep(0.35)
  end
  error("Rientro bloccato al passo "..n.." a "..s.x..","..s.y..","..s.z)
 end
 local function goHome()
  while #s.path>0 do reverseOne() end
  assert(atHome(),"Rientro non terminato alla propria postazione")
  turnTo(front)
 end
 local function inspectDir(kind,d)
  if kind=="U" then return turtle.inspectUp() end
  if kind=="D" then return turtle.inspectDown() end
  turnTo(d)
  return turtle.inspect()
 end
 local function dirTarget(kind,d)
  if kind=="U" then return s.x,s.y+1,s.z end
  if kind=="D" then return s.x,s.y-1,s.z end
  return s.x+DXY[d][1],s.y,s.z+DXY[d][2]
 end
 -- Adattamento della prova corrente N01 al motore di tutte le Turtle.
 -- Segue soltanto le celle che contengono il fluido cercato, senza
 -- scavare deviazioni, fino a 64 celle/64 passi nella fascia riservata.
 -- Cerca davanti, sui lati, dietro, sopra e sotto; resta nel settore.
 -- Al termine torna esattamente al punto da cui la corrente era stata vista.
 traceCurrent=function(kind)
  local seen={}
  local used=0
  local originX,originY,originZ=s.x,s.y,s.z
  local originLength=#s.path
  local buckets=kind=="ACQUA" and "minecraft:water_bucket" or "minecraft:lava_bucket"
  local function visit(depth)
   if depth>64 or used>=64 then return false end
   local savedDir=s.d
   local choices={{"F",front},{"F",left},{"F",(front+1)%4},
     {"F",(front+2)%4},{"U",0},{"D",0}}
   for _,entry in ipairs(choices) do
    if used>=64 then break end
    local move,d=entry[1],entry[2]
    local x,y,z=dirTarget(move,d)
    local key=x..":"..y..":"..z
    if inSector(x,y,z) and not seen[key] then
     seen[key]=true
     if move=="F" then turnTo(d) end
     local sideName=fluidSide(move)
     local f=fluidi.peek(sideName)
     if f and f.kind==kind then
      if f.source then
       local old=countItem(buckets)
       local result,why=fluidi.resolve(sideName,{x=x,y=y,z=z},
        function(cx,cy,cz) return cx==x and cy==y and cz==z and
          inSector(cx,cy,cz) end)
       if result=="raccolto" then
        assert(countItem(buckets)>old,"Secchio pieno non confermato")
        s.buckets=s.buckets+1;save()
        detailStatus("SCAVO","SORGENTE "..kind.." raccolta a "..key)
        turnTo(savedDir)
        return true
       end
       error("Sorgente "..kind.." non raccolta: "..tostring(why or result))
      elseif depth<64 then
       used=used+1
       step(move,false,false,kind)
       local found=visit(depth+1)
       reverseOne()
       if found then
        turnTo(savedDir)
        return true
       end
      end
     end
    end
   end
   turnTo(savedDir)
   return false
  end
  local found=visit(0)
  assert(s.x==originX and s.y==originY and s.z==originZ
    and #s.path==originLength,"Ricerca corrente non rientrata all'origine")
  return found
 end
 local function extractVein()
  -- DFS selettiva con rientro automatico al nodo di partenza.
  -- Solo ORE riconosciute, max 32 minerali per punto di ispezione.
  local seen,remaining={},32
  local origin=#s.path
  local function visit()
   if remaining<=0 then return end
   local savedDir=s.d
   local choices={
    {"F",front},{"F",left},{"F",(front+2)%4},
    {"F",(left+2)%4},{"U",0},{"D",0}
   }
   for _,c in ipairs(choices) do
    if remaining<=0 then break end
    local move,d=c[1],c[2]
    local x,y,z=dirTarget(move,d)
    local k=x..":"..y..":"..z
    if inSector(x,y,z) and not seen[k] then
     seen[k]=true
     local exists,b=inspectDir(move,d)
     if exists and isOre(b) then
      reserveGoing(32)
      remaining=remaining-1
      step(move,false,true)
      visit()
      reverseOne()
     end
    end
   end
   turnTo(savedDir)
  end
  visit()
  assert(#s.path==origin,"Uscita da vena non tornata al tunnel")
  turnTo(front)
 end
 local function scanSide()
  -- Solo lato SINISTRO rispetto alla direzione di lavoro, entro 2 blocchi.
  turnTo(left)
  local x,y,z=coords("F")
  if inSector(x,y,z) then
   local f=fluidi.peek("front")
   if f then bonify("F",x,y,z,false) end
  end
  turnTo(front)
 end
 local function scanCell()
  turnTo(front)
  -- Bonifica soffitto e area sinistra prima di estrarre le vene.
  local x,y,z=coords("U")
  if inSector(x,y,z) then
   local f=fluidi.peek("up")
   if f then bonify("U",x,y,z,true) end
  end
  -- La seconda colonna fa parte della galleria 2x2: non sigillarla
  -- preventivamente per poi rompere il tappo entrando nella fascia.
  -- La bonifica avviene quando carveWidth apre la seconda colonna.
  extractVein()
 end
 local function unload()
  assert(atHome(),"Scarico solo alla base")
  pruneInventory(true)
  local limit=turtle.getFuelLimit()
  for i=1,16 do
   local it=turtle.getItemDetail(i)
   if it and it.name=="minecraft:lava_bucket" and
      type(limit)=="number" and currentFuel()<limit then
    turtle.select(i);turtle.refuel(1)
   end
  end
  local keepBuckets=3
  local keepStone=16
  for i=1,16 do
   local it=turtle.getItemDetail(i)
   if it then
    local keep=0
    if it.name=="minecraft:bucket" then
     keep=math.min(keepBuckets,it.count);keepBuckets=keepBuckets-keep
    elseif SEAL_STOCK[it.name] then
     keep=math.min(keepStone,it.count);keepStone=keepStone-keep
    end
    local count=it.count-keep
    if count>0 then
     turtle.select(i)
     assert(turtle.dropDown(count),"Cassa inferiore piena: scarico incompleto")
    end
   end
  end
 end
 -- La cassa superiore fornisce lava e, se presenti, secchi vuoti.
 -- I blocchi da sigillo vengono conservati da quelli scavati.
 local function pullFromTop(name,amount)
  local c=peripheral.wrap("top")
  assert(c and c.list and c.pushItems and c.size,
   "Cassa superiore per rifornimento non disponibile")
  local items=c.list()
  local found
  for slot,it in pairs(items) do
   if it.name==name and it.count>0 then found=slot;break end
  end
  if not found then return false end
  if found~=1 then
   local chestName=assert(peripheral.getName(c))
   if items[1] then
    local free
    for j=c.size(),2,-1 do if not items[j] then free=j;break end end
    assert(free,"Cassa superiore senza slot libero per riordinare")
    assert(c.pushItems(chestName,1,items[1].count,free)==items[1].count,
     "Impossibile liberare slot 1 nella cassa")
   end
   assert(c.pushItems(chestName,found,items[found].count,1)>0,
    "Impossibile spostare materiale verso lo slot 1")
  end
  compactInventory()
  local slot
  for i=1,16 do if turtle.getItemCount(i)==0 then slot=i;break end end
  assert(slot,"Inventario Turtle senza slot per rifornimento")
  turtle.select(slot)
  assert(turtle.suckUp(amount),"Prelievo dalla cassa superiore fallito")
  local got=turtle.getItemDetail(slot)
  assert(got and got.name==name,"Oggetto inatteso dalla cassa superiore")
  return true
 end
 local function getLava()
  local c=peripheral.wrap("top")
  assert(c and c.list and c.pushItems and c.size,
    "Cassa superiore per lava non disponibile")
  local items=c.list()
  local found
  for slot,it in pairs(items) do
   if it.name=="minecraft:lava_bucket" and it.count>0 then found=slot;break end
  end
  assert(found,"Secchi lava finiti nella cassa sopra")
  if found~=1 then
   local name=assert(peripheral.getName(c))
   if items[1] then
    local free
    for i=c.size(),2,-1 do if not items[i] then free=i;break end end
    assert(free,"Cassa rifornimento senza slot libero")
    assert(c.pushItems(name,1,items[1].count,free)==items[1].count,
      "Non riesco a liberare slot 1 cassa lava")
   end
   assert(c.pushItems(name,found,1,1)==1,
     "Non riesco a spostare lava nello slot 1")
  end
  local slot
  for i=1,16 do if turtle.getItemCount(i)==0 then slot=i;break end end
  assert(slot,"Slot Turtle esauriti per il carburante")
  turtle.select(slot)
  assert(turtle.suckUp(1),"Secchio di lava non prelevato")
  local it=turtle.getItemDetail(slot)
  assert(it and it.name=="minecraft:lava_bucket","Oggetto imprevisto dalla cassa")
  assert(turtle.refuel(1),"Rifornimento fallito")
  -- Il secchio vuoto rimane nell'inventario finche' serve.
 end
 local function supply()
  assert(atHome(),"Rifornimento solo alla propria postazione")
  compactInventory()
  unload()
  -- Preferisce i secchi vuoti dalla cassa, senza consumare lava inutilmente.
  local attempts=0
  while countItem("minecraft:bucket")<3 and attempts<3 do
   if not pullFromTop("minecraft:bucket",3-countItem("minecraft:bucket")) then break end
   attempts=attempts+1
  end
  if countItem("minecraft:bucket")<3 then
   local ok,why=fluidi.ensureBuckets(3)
   assert(ok,"Scorta secchi non ottenibile: "..tostring(why))
  end
  local limit=turtle.getFuelLimit()
  local fuel=turtle.getFuelLevel()
  if type(limit)=="number" and type(fuel)=="number" then
   -- Non e' un tetto al fuel: si puo' bruciare altra lava per avere secchi.
   local goal=math.min(limit,10000)
   while currentFuel()<goal do getLava() end
  end
  unload() -- Tiene 3 secchi, 16 blocchi; scarica il resto.
 end
 local function carveHead()
  local x,y,z=coords("U")
  if inSector(x,y,z) then
   prepare("U",x,y,z,false)
  end
 end
 -- Ogni avanzamento completa anche la seconda colonna della fascia.
 -- Mantiene una galleria fisicamente larga 2 e alta 2, poi torna all'asse.
 local function carveWidth()
  turnTo(left)
  local x,y,z=coords("F")
  assert(inSector(x,y,z),"Seconda colonna fuori settore")
  step("F")
  carveHead()
  scanCell()
  reverseOne()
  turnTo(front)
 end
 local function processLevel()
  local yTarget=LEVELS[s.level]
  assert(yTarget,"Livello non valido")
  -- HOME -> esterno un solo blocco a Y=-53.
  turnTo(front)
  step("F",true)
  while s.y<yTarget do step("U") end
  while s.y>yTarget do step("D") end
  -- Il primo punto esterno conta come 1° blocco della galleria.
  for dist=1,maxDistance do
   if dist>1 then turnTo(front);step("F") end
   carveHead() -- tunnel 2 blocchi alto, senza scavare tutto il volume.
   if dist>s.distance then
    scanCell()
    carveWidth()
    s.distance=dist;save()
    if dist%20==0 then
     detailStatus("SCAVO","LIV "..s.level.."/"..maxLevels..
      ", galleria "..dist.."/"..maxDistance)
    end
   end
   if freeSlots()<=2 then pruneInventory(false);compactInventory() end
   if freeSlots()<=2 or currentFuel()<#s.path+260 then
    error("SCORTE: rientro per inventario o carburante")
   end
  end
  assert(not s.waterPending,
    "Acqua corrente attraversata senza sorgente rimossa: bonifica incompleta")
  detailStatus("RIENTRO","Livello "..s.level.." completato; ritorno e scarico")
  goHome()
  s.level=s.level+1;s.distance=0;save()
  supply()
 end
 local function run()
  assert(not s.pending,
    "Posizione fisica incerta dopo riavvio: verifica manuale")
  if #s.path>0 then
   detailStatus("RIENTRO","Recupero traccia precedente prima di proseguire")
   goHome()
   error("Rientro da precedente interruzione: verifica prima di riprendere")
  end
  assert(atHome(),"Posizione iniziale diversa dalla postazione")
  if s.finished then
   detailStatus("BASE","Lavoro gia' concluso: nessun nuovo scavo")
   return
  end
  supply()
  while s.level<=maxLevels do
   detailStatus("SCAVO","Quota "..LEVELS[s.level]..
    ", settore personale "..cfg.unit)
   local ok,problem=pcall(processLevel)
   if not ok then
    local why=tostring(problem)
    detailStatus("RIENTRO","Anomalia: ritorno lungo il percorso",why)
    if #s.path>0 and not s.pending then goHome() end
    if why:find("SCORTE:",1,true) and atHome() then
     supply()
    elseif why:find("BEDROCK IN PERCORSO",1,true) and atHome() then
     -- Bedrock a un livello impedisce il passaggio: non scavarla.
     s.level=s.level+1;s.distance=0;save()
    else
     error("Scavo interrotto: "..why)
    end
   end
  end
  s.finished=true;save()
  detailStatus("BASE","COMPLETATO: "..maxLevels.." quote, ore estratte "..s.ore)
 end
 local ok,reason=pcall(run)
 if not ok then
  local why=tostring(reason)
  local returned=false
  if not s.pending and #s.path>0 then
   detailStatus("RIENTRO","Problema: rientro di emergenza")
   local back,msg=pcall(goHome)
   if not back then why=why.." | RIENTRO NON RIUSCITO: "..tostring(msg) end
  end
  returned=atHome() and #s.path==0 and not s.pending
  latch(why)
  detailStatus("ERRORE",returned and
   "Rientrata alla propria base: intervento richiesto" or
   "ATTENZIONE: rientro non confermato",why)
  printError(why)
 end
end

return function(agent,cfg,options)
 return M.start(agent,cfg,options)
end
