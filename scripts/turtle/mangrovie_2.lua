-- MEGAZERO | FARM 2 MANGROVIE | CC:Tweaked / Minecraft Java 1.21.1
-- Turtle Mining: 1943,65,2715, NORD (-Z). Cassa DIETRO: 1943,65,2716.
-- Propaguli: 1944,66,2708 e 1944,66,2695. Suolo sotto: Y65.
-- Raccoglie SOLO blocchi di mangrovia con visita 3D limitata a 13x13.
-- Output alla cassa dietro, NON e' previsto alcuno scarico ad acqua.
-- Sicurezza: non scava suolo/altri blocchi e non esce dalla zona autorizzata.
-- PRIMA PROVA: comando 'mangrovie_2 prova'; poi 'giro' e infine 'avvia'.
-- IMPORTANTE: versione da collaudare IN GIOCO: esplorazione 3D puo'
-- lasciare porzioni isolate del medesimo albero (nessuna garanzia 100%).
-- I propaguli non cadono dalle foglie: la chest deve poterli reintegrare.

local mode = ({...})[1] or "prova"
if mode ~= "prova" and mode ~= "giro" and mode ~= "avvia" then
  error("Uso: mangrovie_2 prova | giro | avvia", 0)
end

local HOME = {x=1943, y=65, z=2715}
local TREES = {{x=1944,y=66,z=2708}, {x=1944,y=66,z=2695}}
local LIMIT_X, LIMIT_Z, LIMIT_Y = 6, 6, 27
local SAPLING = "minecraft:mangrove_propagule"
local BONE = "minecraft:bone_meal"
local MAX_GROW_BONE = 20
local MIN_BONE = 64
local MIN_FUEL = 2500
local CHECK = ".mangrovie_2_prova_ok"
local p = {x=HOME.x,y=HOME.y,z=HOME.z,dir=3}
local DIRS = {
  [0]={1,0,0}, -- E
  [1]={0,0,1}, -- S
  [2]={-1,0,0},-- W
  [3]={0,0,-1},-- N
  [4]={0,1,0}, -- UP
  [5]={0,-1,0} -- DOWN
}
local ORDER = {5,4,0,1,2,3}
local currentTree = nil
local harvested = {logs=0,roots=0,leaves=0,propagules=0}
local fertilizer = 0

local function stop(why)
  error(why.." | TURTLE: "..p.x..","..p.y..","..p.z..
    " direzione "..p.dir..". Rimettila alla base verso NORD prima di ripartire.",0)
end

local function face(d)
  if d >= 4 then return end
  while p.dir ~= d do
    if (d-p.dir)%4 == 3 then
      if not turtle.turnLeft() then stop("Rotazione a sinistra fallita") end
      p.dir = (p.dir+3)%4
    else
      if not turtle.turnRight() then stop("Rotazione a destra fallita") end
      p.dir = (p.dir+1)%4
    end
  end
end

local function inspect(d)
  if d == 4 then return turtle.inspectUp() end
  if d == 5 then return turtle.inspectDown() end
  face(d)
  return turtle.inspect()
end

local function dig(d)
  if d == 4 then return turtle.digUp() end
  if d == 5 then return turtle.digDown() end
  face(d)
  return turtle.dig()
end

local function place(d)
  if d == 4 then return turtle.placeUp() end
  if d == 5 then return turtle.placeDown() end
  face(d)
  return turtle.place()
end

local function step(d)
  local fuel = turtle.getFuelLevel()
  if type(fuel) == "number" and fuel < 1 then stop("Finito carburante") end
  local ok,why
  if d == 4 then ok,why=turtle.up()
  elseif d == 5 then ok,why=turtle.down()
  else face(d); ok,why=turtle.forward() end
  if not ok then stop("Movimento bloccato: "..tostring(why)) end
  local v=DIRS[d]
  p.x,p.y,p.z=p.x+v[1],p.y+v[2],p.z+v[3]
end

local function reverse(d)
  if d==4 then return 5 end
  if d==5 then return 4 end
  return (d+2)%4
end

local function targetCoords(d)
  local v=DIRS[d]
  return p.x+v[1],p.y+v[2],p.z+v[3]
end

local function inBounds(x,y,z,t)
  return x>=t.x-LIMIT_X and x<=t.x+LIMIT_X
    and z>=t.z-LIMIT_Z and z<=t.z+LIMIT_Z
    and y>=t.y-1 and y<=t.y+LIMIT_Y
end

local function classification(name)
  if name=="minecraft:mangrove_log" or name=="minecraft:mangrove_wood"
    or name=="minecraft:stripped_mangrove_log" or name=="minecraft:stripped_mangrove_wood" then
    return "logs"
  elseif name=="minecraft:mangrove_roots" or name=="minecraft:muddy_mangrove_roots" then
    return "roots"
  elseif name=="minecraft:mangrove_leaves" then return "leaves"
  elseif name==SAPLING then return "propagules"
  end
  return nil
end

local function selectItem(id)
  for i=1,16 do
    local v=turtle.getItemDetail(i)
    if v and v.name==id then turtle.select(i); return true end
  end
  return false
end

local function countItem(id)
  local n=0
  for i=1,16 do
    local v=turtle.getItemDetail(i)
    if v and v.name==id then n=n+v.count end
  end
  return n
end

local function freeSlot()
  for i=1,16 do if not turtle.getItemDetail(i) then return i end end
end

local function keep(id)
  return id==SAPLING or id==BONE or id=="minecraft:bucket"
    or id=="minecraft:lava_bucket" or id=="minecraft:coal"
    or id=="minecraft:charcoal"
end

local function chest()
  if p.x~=HOME.x or p.y~=HOME.y or p.z~=HOME.z then
    stop("Per accedere alla cassa occorre tornare alla base")
  end
  face(1)
  local ok,b=turtle.inspect()
  if not ok or not b or
    not (b.name:find("chest",1,true) or b.name=="minecraft:barrel") then
    stop("Cassa non trovata dietro la Turtle")
  end
end

local function unload()
  chest()
  for i=1,16 do
    local item=turtle.getItemDetail(i)
    if item and not keep(item.name) then
      turtle.select(i)
      local n=item.count
      if not turtle.drop() or turtle.getItemCount(i)~=0 then
        stop("Cassa PIENA: impossibile scaricare "..item.name.." x"..n)
      end
    end
  end
  -- Restituisci i secchi vuoti; non servono nella Turtle.
  for i=1,16 do
    local item=turtle.getItemDetail(i)
    if item and item.name=="minecraft:bucket" then
      turtle.select(i)
      if not turtle.drop() then stop("Non riesco a restituire i secchi") end
    end
  end
  face(3)
end

local function fuelLevel()
  local f=turtle.getFuelLevel()
  if f=="unlimited" then return math.huge end
  if type(f)~="number" then stop("Lettura carburante non valida") end
  return f
end

local function refuelLocal()
  if fuelLevel()>=MIN_FUEL then return end
  local limit=turtle.getFuelLimit()
  local target=MIN_FUEL
  if type(limit)=="number" then target=math.min(target,limit) end
  for i=1,16 do
    local v=turtle.getItemDetail(i)
    if v and (v.name=="minecraft:lava_bucket" or v.name=="minecraft:coal"
      or v.name=="minecraft:charcoal") then
      turtle.select(i)
      if fuelLevel()<target then turtle.refuel(v.name=="minecraft:lava_bucket" and 1 or v.count) end
    end
  end
end

-- Una sola chest condivisa: prelievo controllato, senza fingere che
-- chest.pushItems("front") possa trasferire oggetti direttamente alla Turtle.
-- turtle.suck() preleva nell'ordine della chest: tenere gli INPUT ordinati in
-- testa, e filtrare con Importer RS il raccolto di legno/radici.
local function loadInputs()
  chest()
  unload()
  refuelLocal()
  local attempts=0
  while countItem(SAPLING)<2 or countItem(BONE)<MIN_BONE or fuelLevel()<MIN_FUEL do
    local slot=freeSlot()
    if not slot then
      stop("Inventario pieno cercando rifornimenti: svuota la chest output/filtra RS")
    end
    turtle.select(slot)
    if turtle.suck(64) then
      attempts=0
      refuelLocal()
    else
      attempts=attempts+1
      if attempts==1 then
        print("Attendo propaguli (2), Bone Meal (64+) e carburante dalla chest...")
      end
      sleep(15)
    end
  end
  -- Non prelevare altro a caso: la cassa puo' contenere anche il raccolto.
  face(3)
  print("Scorte Turtle: "..countItem(SAPLING).." propaguli, "..
    countItem(BONE).." Bone Meal; fuel "..tostring(fuelLevel()))
end

local function bonemeal(d)
  if not selectItem(BONE) then return false end
  local slot=turtle.getSelectedSlot()
  local before=turtle.getItemCount(slot)
  local ok=place(d)
  local n=before-turtle.getItemCount(slot)
  if ok and n>0 then fertilizer=fertilizer+n; return true end
  return false
end

local function matureHanging(d)
  for _=1,5 do
    local ok,b=inspect(d)
    if not ok or not b or b.name~=SAPLING then return false end
    if not b.state or b.state.hanging==false or b.state.hanging=="false" then return true end
    if tonumber(b.state.age or 0)>=4 then return true end
    if not bonemeal(d) then return false end
  end
  local ok,b=inspect(d)
  return ok and b and b.name==SAPLING and b.state
    and tonumber(b.state.age or 0)>=4
end

local function safeClearAndStep(d,forPath)
  local tx,ty,tz=targetCoords(d)
  if currentTree and not inBounds(tx,ty,tz,currentTree) then
    stop("Tentativo di uscire dall'area 13x13 autorizzata")
  end
  local exists,b=inspect(d)
  if exists then
    local kind=classification(b.name)
    if not kind then
      if forPath then stop("Ostacolo NON mangrovia: "..b.name) end
      return false
    end
    if b.name==SAPLING then
      if not b.state or b.state.hanging==false or b.state.hanging=="false" then
        -- Non distruggere i propaguli piantati alle postazioni.
        return false
      end
      if not matureHanging(d) then return false end
    end
    if not dig(d) then
      if forPath then stop("Impossibile scavare "..b.name) end
      return false
    end
    harvested[kind]=harvested[kind]+1
  end
  step(d)
  return true
end

local function walkToStand(t)
  if p.x~=HOME.x or p.y~=HOME.y or p.z~=HOME.z then
    stop("La partenza verso un albero avviene soltanto da HOME")
  end
  -- Prima saliamo al piano propaguli, poi percorriamo la corsia X=1943.
  step(4)
  face(3)
  for _=1,HOME.z-t.z do
    safeClearAndStep(3,true)
  end
  face(0)
end

local function walkHome(t)
  if p.x~=1943 or p.y~=66 or p.z~=t.z then
    stop("La Turtle non e' ritornata nella corsia prima del rientro")
  end
  face(1)
  for _=1,HOME.z-t.z do safeClearAndStep(1,true) end
  step(5)
  face(3)
end

local function plantSeed(label)
  local exists,b=inspect(0)
  if exists then stop(label..": non posso ripiantare: "..b.name) end
  if not selectItem(SAPLING) then stop(label..": propaguli finiti prima del reimpianto") end
  local ok,why=place(0)
  if not ok then stop(label..": piantagione fallita ("..tostring(why)..")") end
  print(label..": propagulo piantato")
end

local function growSeed(label)
  for i=1,MAX_GROW_BONE do
    local ok,b=inspect(0)
    if ok and b and b.name~=SAPLING then
      if classification(b.name) then return true end
      stop(label..": blocco estraneo nella postazione "..b.name)
    end
    if not ok then stop(label..": nessun propagulo davanti alla Turtle") end
    if not bonemeal(0) then
      print(label..": Bone Meal finito o impossibile da applicare")
      return false
    end
    sleep(0.1)
  end
  local ok,b=inspect(0)
  if ok and b and b.name~=SAPLING and classification(b.name) then return true end
  print(label..": albero non cresciuto con "..MAX_GROW_BONE.." Bone Meal; rinvio")
  return false
end

local function key(x,y,z) return x..":"..y..":"..z end

-- Visita 3D SOLO i blocchi collegati per faccia ai tronchi/radici/foglie.
-- Stack esplicito (non ricorsivo), torna sempre al punto d'ingresso.
-- Limiti fissi impediscono di raggiungere l'altro albero (centri a 13).
local function harvestConnected(t)
  currentTree=t
  local exists,b=inspect(0)
  if not exists or not classification(b.name) or b.name==SAPLING then
    currentTree=nil; return false
  end
  if not safeClearAndStep(0,true) then currentTree=nil; return false end
  local visited={}
  visited[key(p.x,p.y,p.z)]=true
  local stack={{from=0,next=1}}
  local maxNodes=2000
  local nodes=1
  while #stack>0 do
    local fr=stack[#stack]
    if fr.next>#ORDER then
      local back=reverse(fr.from)
      -- I blocchi visitati sono stati rimossi: il rientro usa aria.
      step(back)
      table.remove(stack)
    else
      local d=ORDER[fr.next]
      fr.next=fr.next+1
      local nx,ny,nz=targetCoords(d)
      if inBounds(nx,ny,nz,t) then
        local k=key(nx,ny,nz)
        if not visited[k] then
          visited[k]=true
          local ok,block=inspect(d)
          if ok and block and classification(block.name) then
            if not (block.name==SAPLING and
              (not block.state or block.state.hanging==false
                or block.state.hanging=="false")) then
              if safeClearAndStep(d,false) then
                nodes=nodes+1
                if nodes>maxNodes then stop("Limite massimo visita raggiunto") end
                table.insert(stack,{from=d,next=1})
                if nodes%25==0 then
                  turtle.suckDown()
                  print("Mangrovia "..t.z..": "..nodes.." blocchi visitati")
                end
              end
            end
          end
        end
      end
    end
  end
  -- Lo stack DFS ha gia' riportato la Turtle al punto di ingresso,
  -- un blocco a OVEST del propagulo.
  if p.x~=t.x-1 or p.y~=t.y or p.z~=t.z then
    stop("Errore di ritorno DFS mangrovia")
  end
  currentTree=nil
  face(0)
  print("Mangrovia Z="..t.z..": visita "..nodes.." blocchi")
  return true
end

local function processTree(t,index)
  local label="M"..index
  walkToStand(t)
  local exists,b=inspect(0)
  if not exists then
    plantSeed(label)
    exists,b=inspect(0)
  end
  if exists and b.name==SAPLING then
    if not growSeed(label) then
      walkHome(t); return
    end
  elseif exists and not classification(b.name) then
    stop(label..": ostacolo "..b.name)
  end
  if harvestConnected(t) then
    plantSeed(label)
  end
  walkHome(t)
  unload()
end

local function checkChest()
  chest()
  face(3)
end

checkChest()
if mode=="prova" then
  print("PROVA SENZA SCAVI: chest dietro verificata.")
  print("Turtle HOME 1943,65,2715 NORD; alberi:")
  for i,t in ipairs(TREES) do
    print(i..": "..t.x..","..t.y..","..t.z.." | area 13x13")
  end
  print("La prova NON certifica che il corridoio sia libero.")
  local f=fs.open(CHECK,"w")
  f.write("ok"); f.close()
  print("Ora: mangrovie_2 giro | poi mangrovie_2 avvia")
  return
end
if not fs.exists(CHECK) then error("Prima esegui: mangrovie_2 prova",0) end

while true do
  harvested={logs=0,roots=0,leaves=0,propagules=0}
  fertilizer=0
  loadInputs()
  -- PRIMA la mangrovia vicina, per liberare la corsia verso la seconda.
  for i,t in ipairs(TREES) do processTree(t,i) end
  print("Giro completo. Tronchi/legno "..harvested.logs..
    ", radici "..harvested.roots..", foglie "..harvested.leaves..
    ", propaguli "..harvested.propagules..", Bone Meal "..fertilizer)
  if mode=="giro" then
    print("FINE GIRO DI TEST: Turtle a HOME, orientata NORD")
    break
  end
  -- Nessuna pausa 90/180 s: le nuove piante crescono col Bone Meal al giro seguente.
  sleep(0.2)
end
