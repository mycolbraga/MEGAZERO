-- MEGAZERO MINER v2.3.20 | Froglight scavabili, resto protetto
-- Modulo per megazero_boot: return function(agent, config, opzioni)
-- Non eseguire in automatico prima del collaudo di N01.
-- Gallerie Y -1,-4,...,-61 (testa a Y 0,...,-60), max 300.
-- Spawner scavabili; blocchi tecnici protetti; verificare la quota bedrock reale.
-- Ritorno fisico per passi inversi; nessun lavoro dentro il perimetro base.

local M = {}
local DXY = {[0]={0,-1},[1]={1,0},[2]={0,1},[3]={-1,0}}
local BASE_Y = -51
local LEVELS={}
for y=-1,-61,-3 do LEVELS[#LEVELS+1]=y end
local ORE_WORDS = {":ore_", "_ore"}
local GRAVITY = { ["minecraft:gravel"]=true, ["minecraft:sand"]=true,
 ["minecraft:red_sand"]=true }
-- Solo scarti vanilla certi; NON buttare minerali, mod sconosciute o flint.
local DISCARD = {}
for _,n in ipairs({
 "stone","cobblestone","mossy_cobblestone","deepslate","cobbled_deepslate","tuff",
 "granite","diorite","andesite","calcite","dripstone_block",
 "pointed_dripstone","gravel","sand","red_sand","dirt",
 "coarse_dirt","rooted_dirt","grass_block","netherrack",
 "basalt","smooth_basalt","blackstone","soul_sand"
}) do DISCARD["minecraft:"..n]=true end
-- Scorta per bloccare i fluidi presa SOLO dallo scavo.
local SEAL_TARGET=64 -- uno stack di pietre raccolte per coperture e sigilli
local SEAL_STOCK={}
for _,n in ipairs({"cobblestone","cobbled_deepslate","stone","deepslate",
 "tuff","granite","diorite","andesite","calcite","blackstone"}) do
 SEAL_STOCK["minecraft:"..n]=true
end
local NATURAL = {}
for _,n in ipairs({
 "stone","deepslate","cobbled_deepslate","cobblestone","mossy_cobblestone",
 "tuff","granite","diorite","andesite","dirt","grass_block",
 "gravel","sand","red_sand","calcite","dripstone_block",
 "pointed_dripstone","clay","moss_block","mud","packed_mud",
 "rooted_dirt","coarse_dirt","glow_lichen","soul_sand","basalt","smooth_basalt",
 "blackstone","netherrack","terracotta"
}) do NATURAL["minecraft:"..n]=true end
-- Eccezione richiesta per tutte le Turtle: SOLO le tre Froglight vanilla.
-- Gli altri blocchi costruiti e i componenti restano protetti.
local ALLOWED_DECOR = {
 ["minecraft:verdant_froglight"]=true,
 ["minecraft:pearlescent_froglight"]=true,
 ["minecraft:ochre_froglight"]=true
}

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
 local PATH="/.megazero_miner_v23_"..cfg.unit..mode..
   (options.prova and ("_"..maxDistance.."x"..maxLevels) or "")
 local LATCH="/.megazero_miner_error"
 local fluidi=assert(dofile("/megazero_fluidi"),
   "Modulo fluidi assente: scaricare megazero_fluidi")
 local s={x=hx,y=hy,z=hz,d=front,path={},pending=nil,level=1,
   distance=0,finished=false,ore=0,buckets=0,blocked=0,waterPending=false,
   incomplete={},retryComplete=false}
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
 s.incomplete=s.incomplete or {}
 -- Tappi piazzati su celle della galleria: non scavarli alla cieca.
 -- Persistono nel checkpoint anche dopo rientri e riavvii.
 s.seals=s.seals or {}
 local migrated=false
 -- Versioni precedenti: ricostruisce il tipo dei tappi gia' piazzati
 -- usando SOLTANTO il loro errore registrato nel checkpoint.
 s.waterSeals=s.waterSeals or {}
 local migratedWater=false
 for key in pairs(s.seals) do
  for _,entry in pairs(s.incomplete) do
   if type(entry)=="table" and type(entry.lastError)=="string"
    and entry.lastError:find("SIGILLO_SU_CELLA_2X2:ACQUA:"..key,1,true) then
    if not s.waterSeals[key] then
     s.waterSeals[key]=true
     migratedWater=true
    end
   end
  end
 end
 if migratedWater then migrated=true end
 if s.retryComplete==nil then s.retryComplete=false end
 if type(s.completedLevels)~="table" then
  migrated=true
  s.completedLevels={}
  local reached=s.retryComplete and maxLevels or math.min(maxLevels,s.level-1)
  for n=1,reached do
   if s.incomplete[tostring(n)]==nil then s.completedLevels[tostring(n)]=true end
  end
 end
 if s.finished and next(s.incomplete)~=nil then
  s.finished=false;migrated=true
 end
 -- BOOT 1.2 intercetta Ctrl+T e passa un flag, senza terminare il programma.
 local RETURN_REQUESTED="MEGAZERO_RETURN_REQUESTED"
 local REMOTE_STOP="/.megazero_stop_all.request"
 local function stopRequested()
  return fs.exists(REMOTE_STOP) or
    (type(options.stopRequested)=="function" and
      options.stopRequested()==true)
 end
 local function abortIfStop()
  if stopRequested() then error(RETURN_REQUESTED,0) end
 end
 local function save()
  local f=assert(fs.open(PATH,"w"))
  f.write(textutils.serialize(s));f.close()
 end
 if migrated then save() end
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
  -- Avanzamento per sezioni 2x2 completate, non per livelli visitati.
  local complete,total=0,maxLevels*maxDistance
  for n=1,maxLevels do
   local k=tostring(n)
   if s.completedLevels[k]==true then
    complete=complete+maxDistance
   else
    local deferred=s.incomplete[k]
    local done=deferred and deferred.distance or 0
    if s.level==n then done=math.max(done,s.distance or 0) end
    complete=complete+math.max(0,math.min(maxDistance,done))
   end
  end
  local percent=total>0 and math.floor(100*complete/total) or 0
  pcall(function()
   agent:report(state,{
    x=s.x,y=s.y,z=s.z,fuel=turtle.getFuelLevel(),
    detail=detail,error=problem,progress=percent
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
  -- Conserva fino a UN SOLO stack di UN SOLO blocco adatto ai sigilli.
  -- Il resto degli scarti viene espulso nel mondo, mai verso Refined Storage.
  compactInventory()
  local totals={}
  for i=1,16 do
   local it=turtle.getItemDetail(i)
   if it and SEAL_STOCK[it.name] then
    totals[it.name]=(totals[it.name] or 0)+it.count
   end
  end
  local chosen,bestCount=nil,0
  for _,name in ipairs({
   "minecraft:cobbled_deepslate","minecraft:cobblestone","minecraft:tuff",
   "minecraft:stone","minecraft:deepslate","minecraft:granite",
   "minecraft:diorite","minecraft:andesite","minecraft:calcite",
   "minecraft:blackstone"
  }) do
   local count=totals[name] or 0
   if count>bestCount then chosen,bestCount=name,count end
  end
  local reserved=SEAL_TARGET
  for i=1,16 do
   local it=turtle.getItemDetail(i)
   if it and DISCARD[it.name] then
    local keep=0
    if it.name==chosen then
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
 -- Una colonna verticale stretta NON e' automaticamente un lago.
 -- Prima tentare sigillatura; se persiste, fermarsi alla stessa quota.
 local function markBlocked(reason,kind,x,y,z)
  error("GALLERIA_INCOMPLETA:"..reason..":"..kind..":"..x..":"..y..":"..z)
 end
 local function sealKey(x,y,z)
  return x..":"..y..":"..z
 end
 local function bonify(move,x,y,z,allowFlow)
  abortIfStop()
  assert(inSector(x,y,z),"Bonifica fuori settore")
  local face=fluidSide(move)
  local f=fluidi.peek(face)
  if not f then return true end
  local allowed=function(cx,cy,cz)
   return cx==x and cy==y and cz==z and inSector(cx,cy,cz)
  end
  -- ORDINE: raccolta della SORGENTE con secchio -> sigillo della
  -- corrente residua -> tentativo di continuare SOLO se la cella e'
  -- libera. Non togliere un tappo mentre il fluido puo rigenerarsi.
  local result,detail=fluidi.resolve(face,{x=x,y=y,z=z},allowed)
  if result=="libero" or result=="raccolto" then
   assert(not fluidi.peek(face),
    "Bonifica non confermata: fluido rimasto dopo prelievo")
   if result=="raccolto" then
    s.buckets=s.buckets+1;save()
    detailStatus("SCAVO","SORGENTE "..f.kind.." raccolta a "..
     x..","..y..","..z)
   end
   return true
  end
  local failure=detail
  if not result then
   -- Il prelievo puo fallire per assenza di secchi o per fonte
   -- non prelevabile. Prima di rinunciare tenta il sigillo.
   result,detail=fluidi.seal(face,{x=x,y=y,z=z},allowed)
   if result=="libero" then return true end
   if not result then
    local msg=tostring(failure or detail or "Fluido non gestito")
    if msg:find("secchio",1,true) or
       msg:find("slot libero",1,true) or
       msg:find("SCORTE:",1,true) or
       tostring(detail):find("SCORTE:",1,true) then
     error("SCORTE: "..msg.." | sigillo: "..tostring(detail),0)
    end
    markBlocked("FLUIDO_NON_GESTIBILE",f.kind,x,y,z)
   end
  end
  assert(result=="sigillato","Risultato bonifica imprevisto")
  -- Il blocco piazzato occupa ancora una cella del 2x2.
  -- Non dichiararla completata e non romperlo subito:
  -- il chiamante deve provare una via alternativa sicura.
  local key=sealKey(x,y,z)
  s.seals[key]=detail or true
  if f.kind=="ACQUA" then s.waterSeals[key]=true end
  s.blocked=s.blocked+1
  save()
  detailStatus("SCAVO","SIGILLO "..f.kind.." a "..x..","..y..","..z)
  markBlocked("SIGILLO_SU_CELLA_2X2",f.kind,x,y,z)
 end
 local function prepare(move,x,y,z,first,fluidTransit)
  -- Mai scavare o bonificare all'interno della base.
  assert(inSector(x,y,z),"Intervento fuori area o dentro la base vietato")
  if first then
   -- Acqua ammessa SOLO al primo passo fuori HOME, lava/solidi protetti.
   local exists,block=inspect(move)
   local flow=fluidi.peek(fluidSide(move))
   assert(not exists or (block and block.name=="minecraft:water"),
    "Uscita dalla base ostruita da blocco solido: non rompo infrastrutture")
   assert(not flow or flow.kind=="ACQUA",
    "Uscita dalla base ostruita da fluido diverso da acqua")
   return
  end
  local freeChecks,digs,fluidAttempts=0,0,0
  -- Niente limite di otto colpi: sabbia e gravel possono cadere a colonne.
  -- Occorrono tre controlli consecutivi a vuoto prima di avanzare.
  while digs<256 do
   abortIfStop()
   local key=sealKey(x,y,z)
   local sealed=s.seals[key]
   if sealed then
    local exists,block=inspect(move)
    if exists and block and (sealed==true or block.name==sealed) then
     if move=="U" and s.waterSeals[key]==true and
        type(sealed)=="string" and block.name==sealed then
      -- Solo nel pozzo verticale: riapre un tappo d'ACQUA
      -- registrato da QUESTA Turtle. Non rompe tappi di lava.
      -- La corrente verra' attraversata senza ostruire la corsia.
      local ok,why=turtle.digUp()
      assert(ok,"Riapertura sigillo acqua fallita: "..tostring(why))
      s.seals[key]=nil;s.waterSeals[key]=nil;save()
      sleep(0.15)
     else
      markBlocked("TAPPO_DA_NON_RIMUOVERE","SOLIDO",x,y,z)
     end
    else
     -- Tappo gia' rimosso/cambiato: nessuna modifica al blocco ignoto.
     s.seals[key]=nil;s.waterSeals[key]=nil;save()
    end
   end
   local f=fluidi.peek(fluidSide(move))
   if f then
    -- Pozzo verticale di accesso: l'acqua che cade da livelli sopra
    -- e' attraversabile. Sigillarla qui bloccherebbe l'unica salita.
    -- LAVA non attraversabile: resta gestita dalla bonifica sicura.
    if move=="U" and f.kind=="ACQUA" then
     return
    end
    if fluidTransit and f.kind==fluidTransit and not f.source then return end
    fluidAttempts=fluidAttempts+1
    if fluidAttempts>4 then
     markBlocked("FLUIDO_PERSISTENTE",f.kind,x,y,z)
    end
    -- bonify torna SOLO a cella vuota; se sigilla una cella
    -- 2x2 segnala incompleta e la deviazione prova altre vie.
    bonify(move,x,y,z,true)
   end
   local exists,block=inspect(move)
   if not exists then
    freeChecks=freeChecks+1
    if freeChecks>=3 then return end
    sleep(0.15)
   else
    freeChecks=0
    local name=block and block.name or "?"
    -- L'acqua/lava puo' apparire fra peek() e inspect() mentre
    -- scorrono le correnti. Non trattarla come blocco solido sconosciuto.
    if name=="minecraft:water" or name=="minecraft:lava" then
     local kind=name=="minecraft:water" and "ACQUA" or "LAVA"
     if move=="U" and kind=="ACQUA" then
      -- Salita nel proprio pozzo: corrente d'acqua attraversabile.
      return
     end
     fluidAttempts=fluidAttempts+1
     if fluidAttempts>4 then
      markBlocked("FLUIDO_INSTABILE",kind,x,y,z)
     end
     bonify(move,x,y,z,true)
    else
    if name=="minecraft:bedrock" then error("BEDROCK IN PERCORSO") end
    assert(not unsafe(name),"Infrastruttura o blocco protetto: "..name)
    assert(NATURAL[name] or ALLOWED_DECOR[name] or isOre(block) or isSpawner(block),
     "Blocco non minerario sconosciuto: "..name)
    if freeSlots()<=2 then pruneInventory(false);compactInventory() end
    assert(freeSlots()>2,"SCORTE: inventario quasi pieno")
    local ok,why=dig(move)
    assert(ok,"Scavo impossibile "..name..": "..tostring(why))
    digs=digs+1
    sleep(GRAVITY[name] and 0.3 or 0.15)
    end
   end
  end
  error("Colonna di gravel/sabbia o blocchi troppo lunga: oltre 256 tentativi")
 end
 local function step(move,first,oreOnly,fluidTransit)
  abortIfStop()
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
    local cleared=bonify(move,x,y,z,false)
    if not cleared then
     markBlocked("FLUIDO_SIGILLATO_IN_VENA",f.kind,x,y,z)
    end
   end
   -- Dopo un minerale, gravel/sabbia sovrastanti possono ricadere.
   local still,b=inspect(move)
   if still then
    -- Dopo un minerale puo apparire lichen, altro blocco o un fluido.
    prepare(move,x,y,z,false)
   end
   assert(not inspect(move),"Vena ostruita dopo pulizia")
   s.ore=s.ore+1;save()
  else
   prepare(move,x,y,z,first,fluidTransit)
  end
  if freeSlots()<=4 then pruneInventory(false) end
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
 -- Cerca una via alternativa per una singola cella in avanti.
 -- Qualunque passo avvenuto viene aggiunto a s.path e puo essere ripercorso
 -- all'indietro: nessuna deviazione senza checkpoint.
 local reverseOne
 local function stepForwardDetour()
  local origin=#s.path
  turnTo(front)
  local tx,ty,tz=coords("F")
  local ok,why=pcall(function() step("F") end)
  if ok then return end
  if s.pending or #s.path~=origin then error(why,0) end
  if not tostring(why):find("GALLERIA_INCOMPLETA:",1,true) then
   error(why,0)
  end
  -- Seconda corsia, poi varianti sopra/sotto, sempre nel settore.
  -- Si torna alla stessa cella prevista dal percorso principale.
  local routes={
   {{"F",left},{"F",front},{"F",(left+2)%4}},
   {{"U"},{"F",front},{"D"}},
   {{"D"},{"F",front},{"U"}}
  }
  for _,route in ipairs(routes) do
   local success,reason=pcall(function()
    for _,leg in ipairs(route) do
     local move,heading=leg[1],leg[2]
     if heading~=nil then turnTo(heading) end
     step(move)
    end
    assert(s.x==tx and s.y==ty and s.z==tz,
     "Deviazione non rientrata nella stessa cella della galleria")
    turnTo(front)
   end)
   if success then
    detailStatus("SCAVO","Deviazione completata; continuo a verificare il 2x2")
    return
   end
   if s.pending then error(reason,0) end
   while #s.path>origin do reverseOne() end
   turnTo(front)
  end
  markBlocked("NESSUNA_DEVIAZIONE_SICURA","FLUIDO",tx,ty,tz)
 end
 reverseOne=function()
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
  local lastReason="sconosciuto"
  for attempt=1,8 do
   s.pending="BACK";save()
   local ok,reason=fn()
   if ok then
    s.x,s.y,s.z=s.x+dx,s.y+dy,s.z+dz
    s.path[n]=nil
    s.pending=nil;save()
    pcall(function() agent:heartbeat() end)
    return
   end
   lastReason=tostring(reason or "movimento negato")
   s.pending=nil;save()
   -- Solo sulla propria corsia: liberare blocchi naturali che occupano
   -- un passaggio percorso, mai casse, Turtle, impianti o altre strutture.
   local nx,ny,nz=s.x+dx,s.y+dy,s.z+dz
   local inspectFn=item.m=="U" and turtle.inspectDown or
     (item.m=="D" and turtle.inspectUp or turtle.inspect)
   local digFn=item.m=="U" and turtle.digDown or
     (item.m=="D" and turtle.digUp or turtle.dig)
   local present,block=inspectFn()
   if present then
    local name=block and block.name or "sconosciuto"
    assert(inSector(nx,ny,nz),
      "RIENTRO: blocco presso la base protetto: "..name)
    local allowed=block and
      (GRAVITY[name] or NATURAL[name] or ALLOWED_DECOR[name] or
        (isOre(block) and not unsafe(name)))
    assert(allowed,"RIENTRO: blocco NON naturale: "..name)
    assert(freeSlots()>0,"RIENTRO: inventario pieno davanti a "..name)
    local cleared,why=digFn()
    assert(cleared,"RIENTRO: non riesco a scavare "..name..
      " ("..tostring(why)..")")
   end
   sleep(0.35)
  end
  error("Rientro bloccato al passo "..n.." a "..
    s.x..","..s.y..","..s.z.."; causa movimento: "..lastReason)
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
   abortIfStop()
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
       local problem=tostring(why or result)
       if problem:find("secchio vuoto",1,true) or
          problem:find("slot libero",1,true) then
        error("SCORTE: "..problem)
       end
       markBlocked("SORGENTE_NON_RACCOLTA",kind,x,y,z)
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
   abortIfStop()
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
  abortIfStop()
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
  abortIfStop()
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
  local keepStone=SEAL_TARGET
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
 -- Regulator: trasferimenti verificati e tentativi limitati.
 -- Lo slot 1 puo' cambiare mentre il Regulator inserisce oggetti:
 -- non presumere mai che contenga ancora l'oggetto richiesto.
 local function pullFromTop(name,amount)
  if amount<=0 then return end
  local chest=peripheral.wrap("top")
  assert(chest and type(chest.list)=="function" and
    type(chest.size)=="function" and type(chest.pushItems)=="function",
    "Cassa superiore senza interfaccia trasferimenti")
  local chestName=assert(peripheral.getName(chest),"Nome cassa superiore assente")
  local label=name=="minecraft:bucket" and "secchi vuoti" or
    (name=="minecraft:lava_bucket" and "secchi lava" or name)
  local remaining,attempts=amount,0
  local function retry(reason)
   attempts=attempts+1
   assert(attempts<=40,"Regulator: impossibile prelevare "..label..
     " dopo 40 verifiche; ultimo: "..reason)
   sleep(0.1)
  end
  while remaining>0 do
   abortIfStop()
   local contents=assert(chest.list(),"Cassa superiore non leggibile")
   local source
   for i=1,chest.size() do
    local it=contents[i]
    if it and it.name==name and it.count>0 then source=i;break end
   end
   assert(source,"Regulator: mancano "..remaining.." "..label.." nella cassa superiore")
   if source~=1 then
    local current=contents[1]
    if current and current.name~=name then
     local park
     for i=chest.size(),2,-1 do
      if not contents[i] then park=i;break end
     end
     assert(park,"Cassa rifornimenti piena: manca slot libero per "..label)
     local moved=chest.pushItems(chestName,1,current.count,park)
     if moved~=current.count then retry("parcheggio slot 1 non completo") end
    end
    local first=chest.list()[1]
    if first and first.name~=name then
     retry("slot 1 riempito da "..first.name)
    else
     local src=chest.list()[source]
     if src and src.name==name then
      local moved=chest.pushItems(chestName,source,
       math.min(src.count,remaining),1)
      if moved<=0 then retry("trasferimento verso slot 1 fallito") end
     else
      retry("Regulator ha spostato la sorgente")
     end
    end
   end
   local first=chest.list()[1]
   if first and first.name==name then
    local slot
    for i=1,16 do
     if turtle.getItemCount(i)==0 then slot=i;break end
    end
    assert(slot,"Inventario Turtle senza slot libero")
    turtle.select(slot)
    local ok,why=turtle.suckUp(math.min(first.count,remaining))
    local got=turtle.getItemDetail(slot)
    if ok and got and got.name==name then
     remaining=remaining-got.count
     attempts=0
    elseif got then
     -- Cambio di contenuto nel tick di prelievo: restituisci
     -- esattamente l'oggetto imprevisto, senza distruggerlo.
     assert(turtle.dropUp(got.count),
      "Oggetto imprevisto "..got.name.." non restituibile alla cassa")
     retry("prelevato "..got.name.." anziche "..label)
    else
     retry("suckUp non riuscito: "..tostring(why))
    end
   else
    retry("slot 1 non contiene "..label)
   end
  end
 end
 local function pullBucketsFromTop(required)
  pullFromTop("minecraft:bucket",required)
 end
 local function getLava()
  pullFromTop("minecraft:lava_bucket",1)
  local slot=turtle.getSelectedSlot()
  local got=turtle.getItemDetail(slot)
  assert(got and got.name=="minecraft:lava_bucket",
   "Prelievo lava inatteso: nessun rifornimento")
  local ok,reason=turtle.refuel(1)
  assert(ok,"Rifornimento lava fallito: "..tostring(reason))
 end
 local function supply()
  abortIfStop()
  assert(atHome(),"Rifornimento solo alla propria postazione")
  compactInventory()
  unload()
  -- Prima rifornisci carburante: il Regulator puo occupare slot 1 con lava.
  local limit=turtle.getFuelLimit()
  local fuel=turtle.getFuelLevel()
  if type(limit)=="number" and type(fuel)=="number" then
   -- La lava e' usata solo per rifornire carburante quando serve.
   local goal=math.min(limit,10000)
   while currentFuel()<goal do
    abortIfStop()
    getLava()
   end
  end
  -- Mantieni tre secchi vuoti anche quando non serve lava.
  pullBucketsFromTop(3-countItem("minecraft:bucket"))
  assert(countItem("minecraft:bucket")>=3,
    "Scorta secchi insufficiente dopo il prelievo dalla cassa superiore")
  unload() -- Tiene 3 secchi e fino a SEAL_TARGET blocchi dallo scavo.
 end
 -- Crea una superficie di passaggio su liquido sotto la Turtle,
 -- senza usare secchi. Il blocco di copertura e' sempre nel settore.
 local function coverLakeFloor()
  local x,y,z=s.x,s.y-1,s.z
  if not inSector(x,y,z) then return end
  local f=fluidi.peek("down")
  if not f then return end
  -- Corrente sotto al percorso: NON coprirla alla cieca,
  -- potrebbe provenire dal settore di un'altra Turtle.
  -- Cerca la sorgente solo nel proprio settore; se irrisolta, differisce.
  if not f.source then
   local clear=bonify("D",x,y,z,true)
   if not clear or fluidi.peek("down") then
    markBlocked("CORRENTE_SUL_PAVIMENTO",f.kind,x,y,z)
   end
   return
  end
  -- Superficie sorgente sotto la galleria: coprire con pietra dello scavo,
  -- senza prelevare secchi e senza uscire dal settore.
  local chosen
  for i=1,16 do
   local item=turtle.getItemDetail(i)
   if item and SEAL_STOCK[item.name] and item.count>0 then
    turtle.select(i);chosen=item.name;break
   end
  end
  if not chosen then markBlocked("LAGO_SENZA_BLOCCHI",f.kind,x,y,z) end
  local ok,why=turtle.placeDown()
  if not ok then markBlocked("LAGO_COPERTURA_FALLITA",f.kind,x,y,z) end
  local exists,block=turtle.inspectDown()
  if not exists or not block or block.name~=chosen or fluidi.peek("down") then
   markBlocked("LAGO_COPERTURA_NON_CONFERMATA",f.kind,x,y,z)
  end
  s.blocked=s.blocked+1;save()
  detailStatus("SCAVO","BLOCCO DI COPERTURA "..f.kind.." in "..x..","..y..","..z)
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
  coverLakeFloor()
  carveHead()
  scanCell()
  reverseOne()
  turnTo(front)
 end
 local function processLevel()
  abortIfStop()
  local yTarget=LEVELS[s.level]
  assert(yTarget,"Livello non valido")
  -- HOME -> esterno un solo blocco a Y=-51.
  turnTo(front)
  step("F",true)
  while s.y<yTarget do step("U") end
  while s.y>yTarget do step("D") end
  coverLakeFloor()
  -- Il primo punto esterno conta come 1° blocco della galleria.
  for dist=1,maxDistance do
   abortIfStop()
   if dist>1 then stepForwardDetour() end
   coverLakeFloor()
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
   if freeSlots()<=4 or currentFuel()<#s.path+260 then pruneInventory(false);compactInventory() end
   if freeSlots()<=2 or currentFuel()<#s.path+260 then
    error("SCORTE: slot liberi "..freeSlots().."/16, carburante "..
     currentFuel()..", passi da HOME "..#s.path..
     ", posizione "..s.x..","..s.y..","..s.z)
   end
  end
  assert(not s.waterPending,
    "Acqua corrente attraversata senza sorgente rimossa: bonifica incompleta")
  pruneInventory(false) -- Non riportare gli scarti alla base dopo una galleria.
  detailStatus("RIENTRO","Livello "..s.level.." completato; ritorno e scarico")
  goHome()
  s.level=s.level+1;s.distance=0;save()
  supply()
 end
 local function run()
  assert(not s.pending,
    "Posizione fisica incerta dopo riavvio: verifica manuale")
  if #s.path>0 then
   -- Un chunk scaricato puo' riavviare il computer con una galleria aperta.
   -- Ripercorrere solo la traccia salvata, senza resettare quota o distanza.
   detailStatus("RIENTRO","Recupero traccia precedente prima di proseguire")
   goHome()
   assert(atHome() and #s.path==0 and not s.pending,
     "Rientro da interruzione non verificato")
   if not options.rientroOnly then
    detailStatus("BASE","Rientro precedente riuscito; scarico e riprendo checkpoint")
   end
  end
  assert(atHome(),"Posizione iniziale diversa dalla postazione")
  if options.rientroOnly then
   -- Scavo FERMO: soltanto rientro sulla traccia, nessun nuovo livello.
   -- Non cambiare distanza, quota o lo stato del completamento.
   local unloaded,whyUnload=pcall(unload)
   if unloaded then
    detailStatus("BASE","Rientro controllato completato; miner fermo")
   else
    detailStatus("BASE","Alla base; scarico rimandato: "..tostring(whyUnload))
   end
   return
  end
  if s.retryComplete and next(s.incomplete)~=nil then
   local count=0
   for _ in pairs(s.incomplete) do count=count+1 end
   detailStatus("ERRORE","GALLERIE SOSPESE: "..count..
     "; recupero esplicito richiesto, checkpoint conservato",
     "Lavoro non completo")
   return
  end
  if s.finished then
   detailStatus("BASE","Lavoro gia' concluso: nessun nuovo scavo")
   return
  end
  supply()
  local function attemptLevel(isRetry)
   detailStatus("SCAVO","Quota "..LEVELS[s.level]..
    ", settore personale "..cfg.unit..(isRetry and " RITENTATIVO" or ""))
   -- Non ripartire da zero dopo un rientro per inventario.
   -- s.distance e' l'ultima cella COMPLETATA, salvata in checkpoint.
   -- Si ripercorrono le celle fino a quel punto, senza riscavarle.
   local trips,stalled=0,0
   while true do
    abortIfStop()
    local distanceBefore=s.distance or 0
    local oreBefore=s.ore or 0
    local blockedBefore=s.blocked or 0
    local ok,problem=pcall(processLevel)
    if ok then
     s.lastScorte=nil;s.lastScorteAt=nil
     s.incomplete[tostring(s.level-1)]=nil
     s.completedLevels[tostring(s.level-1)]=true
     save()
     return true
    end
    local why=tostring(problem)
    if why:find(RETURN_REQUESTED,1,true) then
     error(RETURN_REQUESTED,0)
    end
    local blocked=why:find("GALLERIA_INCOMPLETA:",1,true)~=nil
    detailStatus("RIENTRO","Interruzione livello "..s.level..", rientro",why)
    local stoppedX,stoppedY,stoppedZ=s.x,s.y,s.z
    if #s.path>0 then
     assert(not s.pending,"Posizione incerta: impossibile pianificare rientro")
     goHome()
    end
    if blocked then
     local key=tostring(s.level)
     local entry=s.incomplete[key] or {attempts=0}
     entry.attempts=entry.attempts+1
     entry.distance=math.max(entry.distance or 0,s.distance or 0)
     entry.lastError=why
     entry.stoppedAt={x=stoppedX,y=stoppedY,z=stoppedZ}
     s.incomplete[key]=entry
     detailStatus("BLOCCATO","Galleria "..key..
       " sospesa; salvata per il recupero",why)
     -- Non scendere di quota: la stessa colonna di lava potrebbe
     -- saltare tutte le gallerie fino alla bedrock.
     save()
     error("GALLERIA SOSPESA (quota invariata): "..why,0)
    end
    if why:find("SCORTE:",1,true) and atHome() then
     trips=trips+1
     -- Anche una vena ricca senza aumento della distanza e' progresso.
     local progressed=(s.distance or 0)>distanceBefore or
       (s.ore or 0)>oreBefore or (s.blocked or 0)>blockedBefore
     stalled=progressed and 0 or stalled+1
     s.lastScorte=why
     s.lastScorteAt={x=stoppedX,y=stoppedY,z=stoppedZ,
       level=s.level,distance=s.distance,
       trips=trips,stalled=stalled}
     save()
     if stalled>=5 or trips>=80 then
      error("SCORTE: rientro ripetuto senza soluzione; liv "..s.level..
       " dist "..tostring(s.distance).." | viaggio "..trips..
       " senza progressi "..stalled.." | ultimo motivo: "..why..
       " | punto "..stoppedX..","..stoppedY..","..stoppedZ)
     end
     detailStatus("BASE","Rifornimento; riprendo liv "..s.level..
       " da distanza completata "..tostring(s.distance)..
       " (rientro "..trips..", progressi "..tostring(progressed)..")")
     -- NON azzerare s.distance: l'errore precedente obbligava
     -- a riscavare dall'inizio e consumava tutti i 5 tentativi.
     supply()
    elseif why:find("BEDROCK IN PERCORSO",1,true) and atHome() then
     s.level=s.level+1;s.distance=0;save()
     return true
    else
     error("Scavo interrotto: "..why)
    end
   end
  end
  -- Prima completa tutti i livelli non ostacolati.
  while s.level<=maxLevels do
   attemptLevel(false)
  end
  -- Poi riprova UNA volta le gallerie sospese, non all'infinito.
  if not s.retryComplete then
   local deferred={}
   for level,_ in pairs(s.incomplete) do
    local n=tonumber(level)
    if n and n>=1 and n<=maxLevels then deferred[#deferred+1]=n end
   end
   table.sort(deferred)
   for _,level in ipairs(deferred) do
    local entry=s.incomplete[tostring(level)]
    s.level=level
    s.distance=entry and entry.distance or 0
    save()
    attemptLevel(true)
   end
   s.retryComplete=true
   s.level=maxLevels+1;s.distance=0;save()
  end
  local missing=0
  for _,_ in pairs(s.incomplete) do missing=missing+1 end
  if missing>0 then
   s.finished=false;save()
   detailStatus("ERRORE","GALLERIE SOSPESE: "..missing.." da recuperare.",
     "Lavoro non completato; recupero controllato necessario")
  else
   s.finished=true;save()
   detailStatus("BASE","COMPLETATO: "..maxLevels..
     " quote, minerali estratti "..s.ore)
  end
 end
 -- Disabilita avvio automatico SOLO DOPO rientro confermato.
 local function disarmAutostart()
  local configPath="/megazero_config"
  local raw=assert(read(configPath),"Config assente")
  local disk=assert(textutils.unserialize(raw),"Config non leggibile")
  assert(disk.unit==cfg.unit and disk.site==cfg.site,"Identita' config diversa")
  if disk.miner_autostart==false then return true end
  local tmp="/.megazero_ctrl_t_cfg.new"
  local bak="/.megazero_ctrl_t_cfg.last"
  assert(not fs.exists(tmp),"Config di arresto temporanea gia' presente")
  disk.miner_autostart=false
  local f=assert(fs.open(tmp,"w"));f.write(textutils.serialize(disk));f.close()
  if fs.exists(bak) then fs.delete(bak) end
  fs.copy(configPath,bak)
  fs.delete(configPath)
  local ok,why=pcall(fs.move,tmp,configPath)
  if not ok then
   if fs.exists(bak) then fs.copy(bak,configPath) end
   error("Impossibile disattivare autostart: "..tostring(why))
  end
  return true
 end
 local ok,reason=pcall(run)
 if not ok and tostring(reason):find(RETURN_REQUESTED,1,true) then
  detailStatus("RIENTRO","CTRL+T ricevuto: termino operazioni e rientro")
  local backOK,backError=false,nil
  if s.pending then
   backError="checkpoint con operazione pendente: non posso supporre la posizione"
  else
   backOK,backError=pcall(goHome)
  end
  local returned=backOK and atHome() and #s.path==0 and not s.pending
  if returned then
   local unloadOK,unloadError=pcall(unload)
   local disableOK,disableError=pcall(disarmAutostart)
   if disableOK then
    local remote=fs.exists(REMOTE_STOP)
    local label=remote and "STOP REMOTO" or "CTRL+T"
    local msg=unloadOK and (label..": HOME raggiunta, scarico concluso, autostart OFF") or
      (label..": HOME raggiunta, SCARICO DA VERIFICARE: "..tostring(unloadError))
    detailStatus("BASE",msg)
    if remote then
     -- Marker eliminato SOLO dopo HOME confermata e autostart OFF.
     fs.delete(REMOTE_STOP)
     print("STOP REMOTO: HOME raggiunta. Riavvio l'agente di controllo.")
     sleep(1)
     os.reboot()
    end
    print("Rientro concluso. Console pronta: puoi eseguire reboot dalla HOME.")
    return
   end
   latch("HOME raggiunta ma autostart non disabilitato: "..tostring(disableError))
   detailStatus("ERRORE","HOME raggiunta, ma configurazione arresto non salvata",
     tostring(disableError))
   return
  end
  local why="CTRL+T: RIENTRO NON RIUSCITO: "..tostring(backError)
  latch(why)
  detailStatus("ERRORE","Rientro non confermato: movimento fermato",why)
  printError(why)
  return
 end
 if not ok then
  local why=tostring(reason)
  local returned=false
  if not s.pending and #s.path>0 then
   detailStatus("RIENTRO","Problema: rientro di emergenza")
   local back,msg=pcall(goHome)
   if not back then why=why.." | RIENTRO NON RIUSCITO: "..tostring(msg) end
  end
  returned=atHome() and #s.path==0 and not s.pending
  if returned then
   -- Anche un errore vero deve tentare lo scarico dopo il rientro.
   local okUnload,whyUnload=pcall(unload)
   if not okUnload then
    why=why.." | SCARICO DOPO ERRORE: "..tostring(whyUnload)
   end
  end
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
