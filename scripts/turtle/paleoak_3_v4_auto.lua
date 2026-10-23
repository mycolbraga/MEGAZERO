-- MEGAZERO - PALE OAK 3x (alberi 2x2) - V4 - ABBATTIMENTO MIRATO + AUTO - CC:Tweaked, MC 1.21.1
-- Programma SEPARATO da querceto2.txt. Non cambiare posizione/orientamento della Turtle.
-- Base: 1910,67,2732 - guarda EST (+X), chest dietro (OVEST).
-- Corsia: Z=2731. Terreno dei 3 quadrati a Y=66, sapling/tronchi a Y=67.
-- P1 X=1914..1915 Z=2729..2730
-- P2 X=1922..1923 Z=2732..2733
-- P3 X=1932..1933 Z=2729..2730
-- Rifornimento chest: Pale Oak Sapling (obiettivo 16), Bone Meal (obiettivo 128), lava.
-- Scarico: acqua a (1911,66,2733). Foglie solo se ostacolano la ricerca del legno.
-- USO: paleoak_3_v4_auto.lua prova | paleoak_3_v4_auto.lua giro | paleoak_3_v4_auto.lua avvia
-- avvia: P1 -> P2 -> P3 -> base -> scarica -> aspetta 120 sec -> nuovo giro.
-- NON ripete la ricerca dopo ogni taglio, e NON controlla due volte la stessa postazione nello stesso giro.
-- IMPORTANTE: prima di giro/avvia eseguire "prova" senza dig/place.

local mode = ({...})[1] or "prova"
if mode ~= "prova" and mode ~= "giro" and mode ~= "avvia" then
  error("Uso: paleoak_3_v4_auto.lua prova | giro | avvia", 0)
end

local HOME_X, HOME_Y, HOME_Z = 1910, 67, 2732
local LANE_Z = 2731
local SAPLING = "minecraft:pale_oak_sapling"
local LOG = "minecraft:pale_oak_log"
local WOOD = "minecraft:pale_oak_wood"
local LEAVES = "minecraft:pale_oak_leaves"
local BONE = "minecraft:bone_meal"
local CHECK_FILE = ".paleoak_3_v4_prova_ok"
local ROUND_PAUSE = 120 -- secondi tra due giri completi in modalita avvia
local TARGET_SAPLINGS, TARGET_BONE = 16, 128
local MAX_Y = HOME_Y + 23
local MAX_WOOD = 180
local MAX_GROW_TRIES = 128
local PLOTS = {
  {name="P1", x=1914, zmin=2729, zmax=2730, near=3}, -- nord da corsia
  {name="P2", x=1922, zmin=2732, zmax=2733, near=1}, -- sud da corsia
  {name="P3", x=1932, zmin=2729, zmax=2730, near=3}, -- nord da corsia
}

-- Direzioni: 0=est, 1=sud, 2=ovest, 3=nord
local vectors = { [0]={1,0}, [1]={0,1}, [2]={-1,0}, [3]={0,-1} }
local p = {x=HOME_X, y=HOME_Y, z=HOME_Z, dir=0}
local cutCount = 0
local fuelAtLeast

local function fatal(message)
  error(message .. " | Turtle prevista: " .. p.x .. "," .. p.y .. "," .. p.z ..
    " direzione=" .. p.dir .. ". NON riavviare se non e' alla base verso EST.", 0)
end

local function face(dir)
  while p.dir ~= dir do
    if (dir-p.dir)%4 == 3 then
      if not turtle.turnLeft() then fatal("Rotazione sinistra fallita") end
      p.dir = (p.dir+3)%4
    else
      if not turtle.turnRight() then fatal("Rotazione destra fallita") end
      p.dir = (p.dir+1)%4
    end
  end
end

local function moveForward()
  if fuelAtLeast and not fuelAtLeast(1) then fatal("Carburante finito") end
  local ok, why = turtle.forward()
  if not ok then fatal("Passaggio bloccato, NON scavo: " .. tostring(why)) end
  local v = vectors[p.dir]
  p.x, p.z = p.x+v[1], p.z+v[2]
end
local function moveBackward()
  if fuelAtLeast and not fuelAtLeast(1) then fatal("Carburante finito") end
  local ok, why = turtle.back()
  if not ok then fatal("Ritorno bloccato, NON scavo: " .. tostring(why)) end
  local v = vectors[p.dir]
  p.x, p.z = p.x-v[1], p.z-v[2]
end
local function moveUp()
  if fuelAtLeast and not fuelAtLeast(1) then fatal("Carburante finito") end
  local ok, why = turtle.up()
  if not ok then fatal("Salita bloccata, NON scavo: " .. tostring(why)) end
  p.y=p.y+1
end
local function moveDown()
  if fuelAtLeast and not fuelAtLeast(1) then fatal("Carburante finito") end
  local ok, why = turtle.down()
  if not ok then fatal("Discesa bloccata, NON scavo: " .. tostring(why)) end
  p.y=p.y-1
end

local function isLog(name)
  return name == LOG or name == WOOD
end
local function countItem(name)
  local n=0
  for i=1,16 do
    local item=turtle.getItemDetail(i)
    if item and item.name == name then n=n+item.count end
  end
  return n
end
local function selectItem(name)
  for i=1,16 do
    local item=turtle.getItemDetail(i)
    if item and item.name==name then turtle.select(i); return true end
  end
  return false
end
local function freeInventory()
  for i=1,16 do if not turtle.getItemDetail(i) then return true end end
  return false
end
local function safeDig(direction, expected)
  local ok, block
  if direction == "up" then ok, block=turtle.inspectUp()
  elseif direction == "down" then ok, block=turtle.inspectDown()
  else ok, block=turtle.inspect() end
  if not ok or not block or not expected(block.name) then
    fatal("Taglio rifiutato: blocco inatteso " .. (ok and block.name or "aria"))
  end
  if not freeInventory() then fatal("Inventario pieno PRIMA del taglio: nessun drop sacrificato") end
  local done, why
  if direction=="up" then done,why=turtle.digUp()
  elseif direction=="down" then done,why=turtle.digDown()
  else done,why=turtle.dig() end
  if not done then fatal("Taglio fallito: " .. tostring(why)) end
end

-- Solo per sicurezza alla base. La chest deve essere dietro la Turtle.
local function verifyChest()
  if p.x~=HOME_X or p.y~=HOME_Y or p.z~=HOME_Z then fatal("Verifica chest fuori base") end
  face(2)
  local ok,b=turtle.inspect()
  face(0)
  if not ok or not b or not (b.name:find("chest",1,true) or b.name=="minecraft:barrel") then
    fatal("Chest non trovata dietro la Turtle")
  end
end

-- Stessa logica di rifornimento selettivo usata dal programma querceto2.
-- La chest va lasciata con almeno uno slot libero per lo scambio.
local function pickupSlot(name)
  for i=1,16 do
    local item=turtle.getItemDetail(i)
    if item and item.name==name then
      local max=item.maxCount or (name=="minecraft:lava_bucket" and 1 or 64)
      if item.count<max then return i,max-item.count end
    end
  end
  for i=1,16 do
    if not turtle.getItemDetail(i) then return i,(name=="minecraft:lava_bucket" and 1 or 64) end
  end
  return nil,0
end

local function takeFromChest(itemName, requested)
  if p.x~=HOME_X or p.y~=HOME_Y or p.z~=HOME_Z then fatal("Prelievo permesso solo a casa") end
  face(2)
  local chest=peripheral.wrap("front")
  if not chest or not chest.list or not chest.pushItems or not chest.size then
    face(0); fatal("Chest non visibile come inventory peripheral")
  end
  local contents=chest.list()
  local source
  for i=1,chest.size() do
    if contents[i] and contents[i].name==itemName then source=i; break end
  end
  if not source then face(0); return 0 end
  local toSlot,capacity=pickupSlot(itemName)
  if not toSlot then face(0); fatal("Inventario pieno: impossibile prelevare " .. itemName) end
  local amount=math.min(requested,capacity,contents[source].count)
  if amount<=0 then face(0); return 0 end
  if source~=1 then
    if contents[1] then
      local free
      for i=1,chest.size() do if not contents[i] then free=i; break end end
      if not free then face(0); fatal("Serve uno slot libero nella chest") end
      local moved=chest.pushItems("front",1,contents[1].count,free)
      if moved~=contents[1].count then face(0); fatal("Non riesco a liberare slot 1 chest") end
    end
    local moved=chest.pushItems("front",source,amount,1)
    if moved~=amount then face(0); fatal("Impossibile preparare il prelievo " .. itemName) end
  end
  local before=turtle.getItemCount(toSlot)
  turtle.select(toSlot)
  local ok,why=turtle.suck(amount)
  local item=turtle.getItemDetail(toSlot)
  if not ok or not item or item.name~=itemName or turtle.getItemCount(toSlot)-before~=amount then
    face(0); fatal("Prelievo fallito " .. itemName .. ": " .. tostring(why))
  end
  face(0)
  return amount
end
local function returnBuckets()
  face(2)
  for i=1,16 do
    local item=turtle.getItemDetail(i)
    if item and item.name=="minecraft:bucket" then
      turtle.select(i)
      local ok,why=turtle.drop(item.count)
      if not ok or turtle.getItemCount(i)~=0 then face(0); fatal("Secchi vuoti non restituiti: " .. tostring(why)) end
    end
  end
  face(0)
end
local function emergencyFuelItem(name)
  return name=="minecraft:coal" or name=="minecraft:charcoal"
    or name==LOG or name==WOOD or name=="minecraft:pale_oak_planks"
end
fuelAtLeast=function(amount)
  local f=turtle.getFuelLevel()
  if f=="unlimited" then return true end
  if type(f)~="number" then fatal("Carburante non numerico") end
  while turtle.getFuelLevel()<amount do
    local used=false
    for i=1,16 do
      local item=turtle.getItemDetail(i)
      if item and emergencyFuelItem(item.name) then
        turtle.select(i)
        if turtle.refuel(1) then used=true; break end
      end
    end
    if not used then return false end
  end
  return true
end
local function prepareFuel(target)
  if turtle.getFuelLevel()=="unlimited" then return end
  local limit=turtle.getFuelLimit()
  if type(limit)=="number" then target=math.min(target,limit) end
  while turtle.getFuelLevel()<target do
    local amount=takeFromChest("minecraft:lava_bucket",1)
    if amount>0 then
      if not selectItem("minecraft:lava_bucket") then fatal("Lava prelevata ma non nell'inventario") end
      local ok,why=turtle.refuel(1)
      if not ok then fatal("Rifornimento lava fallito: " .. tostring(why)) end
      returnBuckets()
    else
      if not fuelAtLeast(target) then fatal("Carburante insufficiente: rifornire chest con lava") end
    end
  end
end
local function replenishItem(itemName,target)
  while countItem(itemName)<target do
    local got=takeFromChest(itemName,target-countItem(itemName))
    if got==0 then break end
  end
end
local function restock()
  if p.x~=HOME_X or p.y~=HOME_Y or p.z~=HOME_Z then fatal("Rifornimento fuori base") end
  replenishItem(SAPLING,TARGET_SAPLINGS)
  replenishItem(BONE,TARGET_BONE)
  prepareFuel(1800)
  print("Scorte: sapling=" .. countItem(SAPLING) .. " bone meal=" .. countItem(BONE)
    .. " carburante=" .. tostring(turtle.getFuelLevel()))
end

-- Spostamenti lungo il corridoio protetto Z=2731.
local function toLane()
  if p.x~=HOME_X or p.y~=HOME_Y or p.z~=HOME_Z then fatal("toLane richiede la base") end
  face(3); moveForward() -- da (1910,2732) a (1910,2731)
  face(0)
end
local function gotoPlot(plot)
  if p.z~=LANE_Z or p.y~=HOME_Y or p.x>plot.x then fatal("Fuori dalla corsia o ordine errato") end
  face(0)
  while p.x<plot.x do moveForward() end
end
local function backHome()
  if p.z~=LANE_Z or p.y~=HOME_Y then fatal("Ritorno: fuori corsia") end
  face(2)
  while p.x>HOME_X do moveForward() end
  face(1); moveForward() -- (1910,2732)
  face(0)
end
local function nearZ(plot)
  return plot.near==3 and plot.zmax or plot.zmin
end
local function farZ(plot)
  return plot.near==3 and plot.zmin or plot.zmax
end
local function checkFront(plot)
  if p.x~=plot.x or p.z~=LANE_Z or p.y~=HOME_Y then fatal("Non sono al punto d'accesso " .. plot.name) end
  face(plot.near)
  local ok,b=turtle.inspect()
  return ok and b.name or "minecraft:air"
end

-- A pianta non cresciuta, passiamo a Y=68 sopra ciascuno dei quattro posti.
-- La Turtle NON si trova nel volume di crescita durante l'uso della bone meal.
local function fillSaplings(plot)
  local state=checkFront(plot)
  if isLog(state) then fatal(plot.name .. ": taglio incompleto: tronco presente quando provo a piantare") end
  if state~=SAPLING and state~="minecraft:air" then
    fatal(plot.name .. ": blocco inatteso sul quadrato: " .. state)
  end
  local function checkAndPlant()
    local ok,b=turtle.inspectDown()
    if ok and b.name==SAPLING then return end
    if ok then fatal(plot.name .. ": blocco sulla terra: " .. b.name) end
    if not selectItem(SAPLING) then fatal(plot.name .. ": germogli esauriti prima di ripiantare") end
    local planted,why=turtle.placeDown()
    if not planted then fatal(plot.name .. ": sapling non piantato: " .. tostring(why)) end
    local found,after=turtle.inspectDown()
    if not found or after.name~=SAPLING then fatal(plot.name .. ": ripiantagione non verificata") end
  end
  face(plot.near)
  moveUp()             -- sopra corsia a Y=68
  moveForward()        -- X=xMin, Z=nearZ, Y=68
  checkAndPlant()
  moveForward()        -- X=xMin, Z=farZ
  checkAndPlant()
  face(0); moveForward() -- X=xMin+1, Z=farZ
  checkAndPlant()
  face((plot.near+2)%4); moveForward() -- X=xMin+1, Z=nearZ
  checkAndPlant()
  moveForward()          -- X=xMin+1, Z=2731
  face(2); moveForward() -- X=xMin, Z=2731
  moveDown()             -- Y=67
  face(0)
end

local function growTree(plot)
  local state=checkFront(plot)
  if state==LOG or state==WOOD then return true end
  if state~=SAPLING then fatal(plot.name .. ": non vedo il sapling per la farina d'ossa: " .. state) end
  local tries=0
  while tries<MAX_GROW_TRIES do
    if not selectItem(BONE) then
      print(plot.name .. ": Bone Meal finita; lascio i 4 sapling e passo oltre")
      face(0)
      return false
    end
    local before=countItem(BONE)
    local ok,why=turtle.place()
    local after=countItem(BONE)
    local found,b=turtle.inspect()
    if found and isLog(b.name) then face(0); return true end
    if not found or b.name~=SAPLING then fatal(plot.name .. ": crescita con blocco inatteso " .. (found and b.name or "aria")) end
    if not ok and after==before then
      print(plot.name .. ": Bone Meal non applicabile (" .. tostring(why) .. "); lascio i sapling")
      face(0)
      return false
    end
    if after>=before then
      print(plot.name .. ": la Bone Meal non viene consumata; salto per sicurezza")
      face(0)
      return false
    end
    tries=tries+1
  end
  face(0)
  print(plot.name .. ": limite Bone Meal raggiunto, lascio i germogli")
  return false
end

-- Abbattimento V3: niente ricerca ricorsiva tra foglie e niente passaggi doppi.
-- Vanilla Backport utilizza dark_oak_trunk_placer: un fusto 2x2 che puo'
-- piegarsi in cima, piu' brevi colonne di rami entro un anello 4x4 intorno
-- al punto iniziale. Le punte dei rami stanno nella zona immediatamente sotto
-- la cima. Questa logica non presume che i rami siano collegati al tronco.
--
-- FASE 1: percorre ESCLUSIVAMENTE legno collegato, una visita per tronco.
-- FASE 2: dall'alto controlla UNA volta le 12 colonne dell'anello 4x4.
--         Se trova un ramo, lo taglia scendendo lungo la colonna.
--         Ispeziona i capi dei rami a quota cima-1, secondo il generatore dark oak.
-- In caso di ostacoli non previsti si blocca SENZA dichiarare il lavoro finito.
local function chopPaleOak(plot)
  local visited = {}
  local woodCount, leavesRemoved, probeCount = 0, 0, 0
  local highestLog = HOME_Y
  local minX, maxX = plot.x-2, plot.x+3
  local minZ, maxZ = plot.zmin-2, plot.zmax+2
  local function within(x,y,z)
    return x>=minX and x<=maxX and z>=minZ and z<=maxZ
      and y>=HOME_Y and y<=MAX_Y
  end
  local function key(x,y,z) return x..":"..y..":"..z end
  local function sideTarget(side)
    if side=="up" then return p.x,p.y+1,p.z end
    if side=="down" then return p.x,p.y-1,p.z end
    local v=vectors[p.dir]
    return p.x+v[1],p.y,p.z+v[2]
  end
  local function inspectSide(side)
    if side=="up" then return turtle.inspectUp() end
    if side=="down" then return turtle.inspectDown() end
    return turtle.inspect()
  end
  local function advance(side)
    if side=="up" then moveUp() elseif side=="down" then moveDown() else moveForward() end
  end
  local function retreat(side)
    if side=="up" then moveDown() elseif side=="down" then moveUp() else moveBackward() end
  end
  local function accountLog(x,y,z)
    local k=key(x,y,z)
    if visited[k] then fatal(plot.name .. ": tronco gia' processato a " .. k) end
    visited[k]=true
    woodCount=woodCount+1
    if woodCount>MAX_WOOD then fatal(plot.name .. ": limite sicurezza tronchi superato") end
    if y>highestLog then highestLog=y end
  end

  -- Visita ricorsiva SOLO sulle facce in cui si vede realmente legno.
  -- Nessuna ricognizione di celle vuote o foglie, nessuna ripetizione globale.
  local visit
  visit=function()
    local saved=p.dir
    local function test(side)
      local x,y,z=sideTarget(side)
      if not within(x,y,z) or visited[key(x,y,z)] then return end
      local ok,b=inspectSide(side)
      if not ok or not b or not isLog(b.name) then return end
      safeDig(side,isLog)
      advance(side)
      accountLog(x,y,z)
      visit()
      retreat(side)
    end
    test("up")
    for dir=0,3 do face(dir); test("front") end
    test("down")
    face(saved)
  end

  local state=checkFront(plot)
  if not isLog(state) then fatal(plot.name .. ": tronco iniziale assente: " .. state) end
  local startX,startY,startZ=sideTarget("front")
  safeDig("front",isLog)
  moveForward()
  accountLog(startX,startY,startZ)
  visit()
  -- Siamo ancora dentro il primo blocco dell'albero (coordinate root).

  -- Muovi attraverso aria o, SOLO quando ostacolano il passaggio,
  -- foglie di Pale Oak. Mai rompere terra, acqua, vetro o altri blocchi.
  local function clearPass(side)
    local ok,b=inspectSide(side)
    if not ok then return end
    if b.name~=LEAVES then fatal(plot.name .. ": ostacolo non previsto durante ricognizione: "..b.name) end
    safeDig(side,function(n) return n==LEAVES end)
    leavesRemoved=leavesRemoved+1
  end
  local function riseTo(y)
    while p.y<y do clearPass("up"); moveUp() end
  end
  local function descendTo(y)
    while p.y>y do clearPass("down"); moveDown() end
  end
  local function walkTo(x,z)
    if p.y~=highestLog then fatal(plot.name .. ": ricognizione fuori quota") end
    local function xAxis()
      while p.x~=x do
        face(p.x<x and 0 or 2)
        clearPass("front"); moveForward()
      end
    end
    local function zAxis()
      while p.z~=z do
        face(p.z<z and 1 or 3)
        clearPass("front"); moveForward()
      end
    end
    xAxis(); zAxis()
  end
  local scanY=highestLog
  if scanY>MAX_Y then fatal(plot.name .. ": albero troppo alto") end
  riseTo(scanY)

  local function scanOneColumn()
    probeCount=probeCount+1
    -- I rami secondari del dark oak terminano 1 blocco sotto la cima.
    -- La Turtle passa lungo un anello UNA volta sola, alla stessa quota.
    local ok,b=turtle.inspectDown()
    if not ok or not isLog(b.name) then return end
    repeat
      local nx,ny,nz=p.x,p.y-1,p.z
      if not within(nx,ny,nz) then fatal(plot.name .. ": ramo oltre il perimetro") end
      safeDig("down",isLog)
      accountLog(nx,ny,nz)
      moveDown()
      local again,below=turtle.inspectDown()
      if not again or not isLog(below.name) then break end
    until false
    riseTo(scanY)
  end

  -- Anello 4x4 delle sole possibili colonne secondarie: esattamente 12.
  -- Si usa un percorso contiguo, non un ritorno alla radice dopo ogni colonna.
  local ring={}
  for x=plot.x-1,plot.x+2 do ring[#ring+1]={x,plot.zmin-1} end
  for z=plot.zmin,plot.zmax+1 do ring[#ring+1]={plot.x+2,z} end
  for x=plot.x+1,plot.x-1,-1 do ring[#ring+1]={x,plot.zmax+1} end
  for z=plot.zmax,plot.zmin,-1 do ring[#ring+1]={plot.x-1,z} end

  for _,cell in ipairs(ring) do
    walkTo(cell[1],cell[2])
    scanOneColumn()
  end
  walkTo(startX,startZ)
  descendTo(HOME_Y)
  face(plot.near)
  moveBackward() -- esce dal tronco e torna alla corsia
  face(0)
  print(plot.name .. ": legno=" .. woodCount .. ", colonne rami controllate=" .. probeCount ..
        ", foglie di passaggio=" .. leavesRemoved)
  if woodCount<4 then fatal(plot.name .. ": abbattimento incompleto: troppo poco legno") end
  return woodCount
end

local function processPlot(plot)
  local state=checkFront(plot)
  if isLog(state) then
    print(plot.name .. ": albero gia' cresciuto, inizio il taglio")
  elseif state==SAPLING or state=="minecraft:air" then
    print(plot.name .. ": completo i germogli e provo a farlo crescere")
    fillSaplings(plot)
    if not growTree(plot) then return false end
  else
    fatal(plot.name .. ": blocco imprevisto: " .. state)
  end
  chopPaleOak(plot)
  -- Albero finito: lascia i quattro sapling, SENZA far crescere un secondo albero.
  fillSaplings(plot)
  cutCount=cutCount+1
  print(plot.name .. ": ripiantati 4 sapling")
  return true
end

-- Ritorno temporaneo a casa e scarico nell'acqua, SENZA buttare riserve.
local function goWater()
  if p.x~=HOME_X or p.y~=HOME_Y or p.z~=HOME_Z then fatal("Scarico solo dalla base") end
  face(0); moveForward() -- (1911,67,2732)
  face(1); moveForward() -- (1911,67,2733)
  local ok,b=turtle.inspectDown()
  if not ok or b.name~="minecraft:water" then fatal("Manca acqua sotto a 1911,66,2733") end
end
local function leaveWater()
  face(3); moveForward() -- (1911,67,2732)
  face(2); moveForward() -- (1910,67,2732)
  face(0)
end
local function discharge()
  goWater()
  local stacks=0
  for i=1,16 do
    local item=turtle.getItemDetail(i)
    if item then
      local keep=(item.name==SAPLING or item.name==BONE or item.name=="minecraft:coal"
        or item.name=="minecraft:charcoal" or item.name=="minecraft:lava_bucket"
        or item.name=="minecraft:bucket")
      if not keep then
        turtle.select(i)
        local ok,why=turtle.dropDown()
        if not ok or turtle.getItemCount(i)~=0 then fatal("Scarico in acqua fallito per " .. item.name .. ": " .. tostring(why)) end
        stacks=stacks+1
      end
    end
  end
  leaveWater()
  print("Scaricati in acqua " .. stacks .. " stack")
end

verifyChest()

if mode=="prova" then
  print("PROVA SENZA TAGLI/PIANTAGIONI: verifica corsia e accessi")
  prepareFuel(170)
  toLane()
  local good=true
  for _,plot in ipairs(PLOTS) do
    gotoPlot(plot)
    local state=checkFront(plot)
    print(plot.name .. " accesso: (" .. plot.x .. ",67," .. LANE_Z .. ") -> " .. state)
    if state~="minecraft:air" and state~=SAPLING and not isLog(state) then good=false end
    face(0)
  end
  backHome()
  -- Verifica il punto di scarico senza rilasciare oggetti.
  goWater(); leaveWater()
  if good then
    local h=fs.open(CHECK_FILE,"w")
    if not h then fatal("Impossibile scrivere checkpoint prova") end
    h.write("ok")
    h.close()
    print("PROVA OK. Ora: paleoak_3_v4_auto.lua giro | avvia")
  else
    if fs.exists(CHECK_FILE) then fs.delete(CHECK_FILE) end
    print("PROVA FALLITA: controlla le posizioni indicate, nessun blocco toccato")
  end
  return
end

if not fs.exists(CHECK_FILE) then error("Prima esegui: paleoak_3_v3.lua prova",0) end

local function oneRound(round)
  print("PALE OAK - giro " .. round .. " (P1 -> P2 -> P3)")
  cutCount=0
  -- Rifornimenti eseguiti solo all'inizio di ciascun giro, alla base.
  restock()
  if countItem(SAPLING)<4 then fatal("Meno di 4 germogli disponibili") end
  toLane()
  for _,plot in ipairs(PLOTS) do
    gotoPlot(plot)
    if countItem(SAPLING)<4 then fatal(plot.name .. ": servono almeno 4 germogli") end
    processPlot(plot) -- una sola elaborazione per postazione e per giro
    if p.x~=plot.x or p.y~=HOME_Y or p.z~=LANE_Z then
      fatal("La Turtle non e' tornata correttamente in corsia")
    end
  end
  backHome()
  discharge()
  print("GIRO " .. round .. " TERMINATO: alberi tagliati=" .. cutCount .. "/3. Turtle alla base verso EST")
end

if mode=="giro" then
  oneRound(1)
  print("Modalita GIRO: terminato, mi fermo.")
  return
end

-- AUTO: riparte SOLO dopo che ha completato tutte le tre postazioni, e dopo
-- una pausa alla base. Nessun secondo controllo alla fine del taglio di un albero.
-- Arresto manuale: Ctrl+T. Prima di riavviare controllare la posizione reale.
local round=0
while true do
  round=round+1
  oneRound(round)
  print("AUTO: prossimo giro tra " .. ROUND_PAUSE .. " secondi (attendo alla base).")
  sleep(ROUND_PAUSE)
end