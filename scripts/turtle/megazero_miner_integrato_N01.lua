-- MEGAZERO | Miner + fluidi integrati, PILOT N01 v1.0
-- SOLO MINIERA-01/N01. MAX 8 celle Y=-1; rientro alla home Y=-53.
-- Riusa megazero_fluidi, megazero_rete e il percorso del pilot validato.
-- NON e' il miner 40/40, non modifica startup e non parte da solo.

local UNIT, SITE = "N01", "MINIERA-01"
local STATE = "/.megazero_integrato_N01_state"
local HX, HY, HZ = 2119, -53, 2995
local TARGET_Y, CELLS = -1, 8
-- 0=NORD, 1=EST, 2=SUD, 3=OVEST
local DX = {[0]=0,[1]=1,[2]=0,[3]=-1}
local DZ = {[0]=-1,[1]=0,[2]=1,[3]=0}
local PROTECTED = {
  ["minecraft:bedrock"]=true,["minecraft:barrier"]=true,
  ["minecraft:chest"]=true,["minecraft:trapped_chest"]=true,
  ["minecraft:barrel"]=true,["minecraft:hopper"]=true,
  ["minecraft:shulker_box"]=true,["minecraft:obsidian"]=true
}
local function readFile(path)
  if not fs.exists(path) then return nil end
  local f=assert(fs.open(path,"r"))
  local v=f.readAll();f.close();return v
end
local conf=assert(readFile("/megazero_config"),"Config MEGAZERO mancante")
local cfg=assert(textutils.unserialize(conf),"Config MEGAZERO invalida")
assert(turtle and cfg.unit==UNIT and cfg.site==SITE,
  "Solo N01 della MINIERA-01 autorizzata")
local fluidi=assert(dofile("/megazero_fluidi"),"Modulo fluidi non disponibile")
local rete=assert(dofile("/megazero_rete"),"Modulo telemetria non disponibile")
local agent,err=rete.new(UNIT,SITE,cfg.central or 54)
assert(agent,err or "Modem non trovato")
local s={x=HX,y=HY,z=HZ,d=0,path={},pending=nil,completed=false,ore={},buckets=0,plugs=0,flowObserved=false,waterSourceCollected=false}
local old=readFile(STATE)
if old then
  local recovered=assert(textutils.unserialize(old),"Salvataggio N01 non leggibile")
  assert(type(recovered)=="table" and type(recovered.path)=="table" and
    recovered.x and recovered.y and recovered.z and recovered.d,
    "Salvataggio N01 errato")
  s=recovered
  assert(not s.pending,
    "MOVIMENTO/ROTAZIONE INTERROTTI: posizione incerta; verifica manuale")
end
local function save()
  local f=assert(fs.open(STATE,"w"));f.write(textutils.serialize(s));f.close()
end
save()
local function atHome()return s.x==HX and s.y==HY and s.z==HZ end
local function inside(x,y,z)
  return x>=2118 and x<=2119 and z>=2695 and z<=2994 and y>=-53 and y<=0
end
local function protectedName(name)
  local n=tostring(name or "?"):lower()
  if PROTECTED[n] then return true end
  -- Divieto di danneggiare turtle, casse, cavi, macchine e infrastrutture mod.
  for _,word in ipairs({"turtle","chest","shulker","modem","cable",
    "computer","importer","exporter","receiver","transmitter",
    "storage","machine","pipe","furnace","drawer","tank",
    "pump","generator","charger","monitor","spawner"}) do
    if n:find(word,1,true) then return true end
  end
  return false
end
local function signal(status,detail,errorText)
  pcall(function()
    agent:report(status,{x=s.x,y=s.y,z=s.z,fuel=turtle.getFuelLevel(),
      detail=detail,error=errorText,
      progress=math.min(100,math.floor((s.gallery or 0)/CELLS*100))})
  end)
  print(status..": "..detail)
end
local function turnTo(d)
  while s.d~=d do
    local move=(d-s.d)%4==3 and -1 or 1
    s.pending={operation="turn"};save()
    local ok=(move==-1) and turtle.turnLeft() or turtle.turnRight()
    assert(ok,"Rotazione fallita")
    s.d=(s.d+move+4)%4
    s.pending=nil;save()
  end
end
local function target(kind)
  if kind=="U" then return s.x,s.y+1,s.z
  elseif kind=="D" then return s.x,s.y-1,s.z end
  return s.x+DX[s.d],s.y,s.z+DZ[s.d]
end
local function look(kind)
  if kind=="U" then return turtle.inspectUp()
  elseif kind=="D" then return turtle.inspectDown()
  else return turtle.inspect() end
end
local function dig(kind)
  if kind=="U" then return turtle.digUp()
  elseif kind=="D" then return turtle.digDown()
  else return turtle.dig() end
end
local function fluidSide(kind)
  if kind=="U" then return "up" elseif kind=="D" then return "down"
  else return "front" end
end
local function reserve(add)
  local fuel=turtle.getFuelLevel()
  -- Distanza di rientro stimata con i passi effettivi, piu' margine.
  assert(type(fuel)~="number" or fuel>=#s.path+(add or 0)+180,
    "Riserva carburante insufficiente: rientro")
end
local function freeSlots()
  local n=0
  for i=1,16 do if turtle.getItemCount(i)==0 then n=n+1 end end
  return n
end
local function countItem(name)
  local count=0
  for i=1,16 do
    local item=turtle.getItemDetail(i)
    if item and item.name==name then count=count+item.count end
  end
  return count
end
local function bonify(side,x,y,z,flowCanBeTraversed)
  assert(inside(x,y,z),"Bonifica fuori settore vietata: "..x..","..y..","..z)
  local current=fluidi.peek(side)
  if not current then return "libero" end
  local beforeWater=countItem("minecraft:water_bucket")
  local beforeLava=countItem("minecraft:lava_bucket")
  if current.source then
    signal("SCAVO","BONIFICA sorgente "..current.kind.." a "..x..","..y..","..z)
    local result,msg=fluidi.resolve(side,{x=x,y=y,z=z},function(cx,cy,cz)
      return cx==x and cy==y and cz==z and inside(cx,cy,cz)
    end)
    assert(result=="raccolto","Sorgente non rimossa: "..tostring(msg or result))
    local got=(current.kind=="ACQUA") and countItem("minecraft:water_bucket")>beforeWater
      or (current.kind=="LAVA" and countItem("minecraft:lava_bucket")>beforeLava)
    assert(got,"Secchio riempito non rilevato")
    s.buckets=(s.buckets or 0)+1
    if current.kind=="ACQUA" then s.waterSourceCollected=true end
    save()
    sleep(0.7)
    assert(not fluidi.peek(side),"Liquido rigenerato dopo prelievo")
    return "raccolto"
  end
  -- Una corrente sul lato interno puo' essere sigillata e lasciata intatta.
  -- NON si scava subito il blocco di chiusura.
  if flowCanBeTraversed then
    assert(current.kind=="ACQUA", "Colata di lava non attraversabile alla cieca")
    s.flowObserved=true;save()
    return "acqua_corrente"
  end
  signal("SCAVO","BONIFICA corrente laterale "..current.kind.." a "..x..","..y..","..z)
  local result,msg=fluidi.resolve(side,{x=x,y=y,z=z},function(cx,cy,cz)
    return cx==x and cy==y and cz==z and inside(cx,cy,cz)
  end)
  assert(result=="sigillato","Sigillo corrente non riuscito: "..tostring(msg or result))
  s.plugs=(s.plugs or 0)+1;save()
  return "sigillato"
end
local function clearPath(kind,x,y,z,protect)
  -- Prima uscita: vietato scavare infrastrutture nei pressi della home.
  if protect then
    local liquid=fluidi.peek(fluidSide(kind))
    if liquid then
      local result=bonify(fluidSide(kind),x,y,z,kind=="F")
      assert(result=="libero" or result=="raccolto" or
        result=="acqua_corrente","Uscita ancora ostruita dal fluido")
    end
    local exists,b=look(kind)
    assert(not exists or fluidi.peek(fluidSide(kind)),
      "Uscita dalla base ostruita: "..tostring(b and b.name))
    return
  end
  for i=1,8 do
    local side=fluidSide(kind)
    local liquid=fluidi.peek(side)
    if liquid then
      local outcome=bonify(side,x,y,z,kind=="F")
      if outcome=="acqua_corrente" then return end
      if outcome=="sigillato" then
        error("Sigillo sul percorso: non scavarlo per riaprire il flusso")
      end
    end
    local exists,b=look(kind)
    if not exists then return end
    local name=type(b)=="table" and b.name or "?"
    assert(not protectedName(name),"Blocco protetto davanti: "..name)
    assert(freeSlots()>=2,"Inventario quasi pieno: rientro con materiali")
    local ok,reason=dig(kind)
    assert(ok,"Scavo impossibile su "..name..": "..tostring(reason))
    sleep(0.2)
  end
  assert(not look(kind),"Blocco persistente dopo scavo")
end
local function move(kind,protect)
  local x,y,z=target(kind)
  assert(inside(x,y,z),"Movimento fuori settore o nella base vietato")
  reserve(1)
  clearPath(kind,x,y,z,protect)
  s.pending={operation=kind,x=x,y=y,z=z};save()
  local fn=kind=="U" and turtle.up or kind=="D" and turtle.down or turtle.forward
  local ok,why=fn()
  if not ok then
    s.pending=nil;save()
    error("Movimento bloccato: "..tostring(why))
  end
  s.path[#s.path+1]={kind=kind,d=s.d}
  s.x,s.y,s.z=x,y,z
  s.pending=nil;save()
end
local function returnHome()
  assert(not s.pending,"Posizione incerta: non forzare il rientro")
  while #s.path>0 do
    reserve(0)
    local step=s.path[#s.path]
    local fn
    if step.kind=="F" then
      turnTo((step.d+2)%4)
      fn=turtle.forward
    elseif step.kind=="U" then fn=turtle.down
    else fn=turtle.up end
    local ok,why
    for i=1,8 do
      s.pending={operation="rientro"};save()
      ok,why=fn()
      if ok then
        if step.kind=="F" then
          s.x=s.x+DX[s.d];s.z=s.z+DZ[s.d]
        elseif step.kind=="U" then s.y=s.y-1
        else s.y=s.y+1 end
        table.remove(s.path)
        s.pending=nil;save()
        break
      end
      s.pending=nil;save()
      sleep(0.3)
    end
    assert(ok,"Rientro impedito: "..tostring(why))
  end
  assert(atHome(),"Il percorso di ritorno non termina alla home")
  turnTo(0)
end
local function mineSide()
  -- La corsia di N01 e' larga 2; solo sinistra (-X) e' autorizzata.
  local oldDir=s.d
  turnTo(3) -- OVEST
  local x,y,z=target("F")
  if inside(x,y,z) then
    local liquid=fluidi.peek("front")
    if liquid then bonify("front",x,y,z,false) end
    -- Per ora NON si insegue la vena: il pilot valida soltanto il ciclo fluidi.
  end
  turnTo(oldDir)
end
local function clearHead()
  local x,y,z=target("U")
  if not inside(x,y,z) then return end
  clearPath("U",x,y,z,false)
end
local function unloadHome()
  assert(atHome(),"Scarico soltanto alla propria postazione")
  -- Riutilizzo lava raccolta come carburante, lasciando i secchi vuoti.
  local limit=turtle.getFuelLimit()
  for i=1,16 do
    local item=turtle.getItemDetail(i)
    if item and item.name=="minecraft:lava_bucket" then
      local level=turtle.getFuelLevel()
      if type(limit)=="number" and type(level)=="number" and level<limit then
        turtle.select(i);turtle.refuel(1)
      end
    end
  end
  local toKeep=3
  local blocksToKeep=16
  for i=1,16 do
    local item=turtle.getItemDetail(i)
    if item then
      turtle.select(i)
      if item.name=="minecraft:bucket" then
        local keep=math.min(toKeep,item.count)
        toKeep=toKeep-keep
        if item.count>keep then
          assert(turtle.dropDown(item.count-keep),"Scarico secchi eccedenti fallito")
        end
      elseif item.name=="minecraft:cobbled_deepslate" or
          item.name=="minecraft:cobblestone" then
        local keep=math.min(blocksToKeep,item.count)
        blocksToKeep=blocksToKeep-keep
        if item.count>keep then
          assert(turtle.dropDown(item.count-keep),"Scarico pietra eccedente fallito")
        end
      else
        assert(turtle.dropDown(),"Scarico cassa inferiore pieno o impossibile")
      end
    end
  end
end
local function test()
  assert(not s.pending,"Movimento sospeso: posizione incerta")
  if #s.path>0 then
    signal("RIENTRO","Ripresa dopo arresto: rientro preventivo")
    returnHome()
    error("Test precedente interrotto: verifica e riprova in nuova esecuzione")
  end
  assert(atHome(),"N01 non risulta alla home")
  if s.completed then
    signal("BASE","Pilot integrato gia completato, nessun secondo scavo")
    return
  end
  unloadHome()
  local ok,why=fluidi.ensureBuckets(3)
  assert(ok,"Secchi vuoti mancanti: "..tostring(why))
  reserve(100)
  signal("SCAVO","INTEGRATO N01: uscita, bonifica, 8 celle, ritorno")
  turnTo(0)
  move("F",true) -- da home al primo blocco fuori dalla base
  -- Salita interamente ESTERNA alla base fino a Y=-1.
  while s.y<TARGET_Y do move("U") end
  clearHead() -- galleria alta due blocchi (testa a Y=0)
  mineSide()
  s.gallery=1;save()
  for i=2,CELLS do
    turnTo(0)
    move("F")
    clearHead()
    mineSide()
    s.gallery=i;save()
    if i%2==0 then signal("SCAVO","INTEGRATO: galleria "..i.."/"..CELLS) end
  end
  -- Non dichiarare tutto bonificato in presenza di acqua ancora in galleria.
  local liquid=fluidi.peek("front")
  assert(not liquid,"Corrente/sorgente ancora davanti a fine tratta")
  if s.flowObserved then
    assert(s.waterSourceCollected,
      "Corrente attraversata senza eliminare alcuna sorgente: rientro con allarme")
  end
  signal("RIENTRO","8/8 celle: ritorno alla postazione N01")
  returnHome()
  unloadHome()
  s.completed=true;save()
  signal("BASE","INTEGRATO OK: 8/8, bonifiche="..(s.buckets or 0)..
    ", sigilli="..(s.plugs or 0)..", rientro e scarico OK")
end

print("MEGAZERO | PILOT INTEGRATO N01 | Y -53 -> -1 | MAX 8 CELLE")
local ok,why=pcall(test)
if not ok then
  printError("PILOT INTEGRATO: "..tostring(why))
  if not s.pending and #s.path>0 then
    signal("RIENTRO","Anomalia: tentativo rientro di sicurezza")
    local recovered,reason=pcall(returnHome)
    if not recovered then
      signal("ERRORE","RIENTRO NON CONFERMATO",tostring(reason))
      printError("Rientro non riuscito: "..tostring(reason))
    else
      signal("ERRORE","Test interrotto, turtle rientrata",tostring(why))
    end
  else
    signal("ERRORE",s.pending and "POSIZIONE INCERTA" or
      "Test interrotto alla postazione",tostring(why))
  end
end
print("Premi INVIO per riavviare lo startup MEGAZERO.")
read()
os.reboot()
