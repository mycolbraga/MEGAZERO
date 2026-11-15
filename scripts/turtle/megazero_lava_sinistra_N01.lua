-- MEGAZERO | Collaudo lava laterale sinistra N01 v1.0
-- Identifica e prova a prelevare una sorgente di lava raggiungibile
-- nella fascia X=2118..2119, Z=2989..2994, Y=-53.
-- Niente avvio automatico del miner e nessuno sconfinamento.
-- Non e' il programma di produzione per 40 Turtle.

local HOME={x=2119,y=-53,z=2995,d=0}
local STATE='/.megazero_lava_sinistra_N01'
local DIR_X={[0]=0,[1]=1,[2]=0,[3]=-1}
local DIR_Z={[0]=-1,[1]=0,[2]=1,[3]=0}
local SAFE={
 ['minecraft:stone']=true,['minecraft:deepslate']=true,
 ['minecraft:cobbled_deepslate']=true,['minecraft:cobblestone']=true,
 ['minecraft:tuff']=true,['minecraft:andesite']=true,
 ['minecraft:diorite']=true,['minecraft:granite']=true,
 ['minecraft:dirt']=true,['minecraft:gravel']=true,
 ['minecraft:calcite']=true,['minecraft:dripstone_block']=true
}

assert(turtle,'Eseguire su una Mining Turtle')
local f=assert(fs.open('/megazero_config','r'),'Config MEGAZERO mancante')
local cfg=assert(textutils.unserialize(f.readAll()),'Config non leggibile')
f.close()
assert(cfg.site=='MINIERA-01' and cfg.unit=='N01', 'Solo N01 autorizzata')
local fluidi=assert(dofile('/megazero_fluidi'),'Modulo fluidi non trovato')
local rete=assert(dofile('/megazero_rete'),'Modulo di rete mancante')
local agent,msg=rete.new('N01','MINIERA-01',cfg.central or 54)
assert(agent,msg or 'Modem assente')

local s={x=HOME.x,y=HOME.y,z=HOME.z,d=HOME.d,path={},pending=nil,done=false,found=false}
local function save()
 local h=assert(fs.open(STATE,'w'))
 h.write(textutils.serialize(s))
 h.close()
end
if fs.exists(STATE) then
 local h=assert(fs.open(STATE,'r'))
 local previous=assert(textutils.unserialize(h.readAll()),'Stato di prova illeggibile')
 h.close()
 assert(type(previous)=='table' and type(previous.path)=='table'
   and type(previous.x)=='number' and type(previous.z)=='number'
   and type(previous.d)=='number' and not previous.pending,
   'Stato in movimento interrotto: posizione non certa, verifica manuale')
 s=previous
end
save()

local function report(status,detail,problem)
 pcall(function()
  agent:report(status,{x=s.x,y=s.y,z=s.z,
   fuel=turtle.getFuelLevel(),detail=detail,error=problem})
 end)
 print(status..': '..detail)
end
local function inside(x,z)
 return x>=2118 and x<=2119 and z>=2989 and z<=2994
end
local function fuelReserve()
 local fuel=turtle.getFuelLevel()
 assert(type(fuel)~='number' or fuel>=#s.path+130,
  'Carburante insufficiente per il ritorno')
end
local function face(want)
 while s.d~=want do
  local right=(want-s.d)%4
  local change=right==3 and -1 or 1
  s.pending='turn';save()
  local ok= change==-1 and turtle.turnLeft() or turtle.turnRight()
  assert(ok,'Rotazione non riuscita')
  s.d=(s.d+change+4)%4
  s.pending=nil;save()
 end
end
local function currentFront()
 return s.x+DIR_X[s.d],s.z+DIR_Z[s.d]
end
local function digNatural(x,z)
 assert(inside(x,z),'Scavo fuori fascia N01 vietato')
 for i=1,6 do
  local fluid=fluidi.peek('front')
  if fluid then
   return false, 'Liquido davanti: '..fluid.kind..' ('..tostring(fluid.level)..')'
  end
  local exists,block=turtle.inspect()
  if not exists then return true end
  local name=type(block)=='table' and block.name or '?'
  if not SAFE[name] then return false,'Blocco non autorizzato: '..name end
  local free=0
  for slot=1,16 do
   if turtle.getItemCount(slot)==0 then free=free+1 end
  end
  if free<2 then return false,'Inventario troppo pieno per scavare' end
  local ok,why=turtle.dig()
  if not ok then return false,'Scavo fallito: '..tostring(why) end
  sleep(0.2)
 end
 return false,'Blocco ricorrente davanti'
end
local function forward()
 local tx,tz=currentFront()
 assert(inside(tx,tz),'Movimento fuori fascia N01 vietato')
 fuelReserve()
 local ok,why=digNatural(tx,tz)
 assert(ok,why)
 s.pending='forward';save()
 local moved,reason=turtle.forward()
 if not moved then
  s.pending=nil;save()
  error('Avanzamento bloccato: '..tostring(reason))
 end
 s.path[#s.path+1]={direction=s.d}
 s.x,s.z=tx,tz
 s.pending=nil;save()
end
local function goHome()
 assert(not s.pending,'Posizione dubbia: no rientro automatico')
 while #s.path>0 do
  fuelReserve()
  local step=s.path[#s.path]
  face((step.direction+2)%4)
  local ok,why
  for i=1,8 do
   s.pending='return';save()
   ok,why=turtle.forward()
   if ok then
    s.x=s.x+DIR_X[s.d]
    s.z=s.z+DIR_Z[s.d]
    table.remove(s.path)
    s.pending=nil;save()
    break
   end
   s.pending=nil;save()
   sleep(0.3)
  end
  assert(ok,'Rientro bloccato: '..tostring(why))
 end
 assert(s.x==HOME.x and s.z==HOME.z and s.y==HOME.y,
   'Percorso invertito ma non alla postazione')
 face(HOME.d)
end
local function lavaBuckets()
 local n=0
 for i=1,16 do
  local item=turtle.getItemDetail(i)
  if item and item.name=='minecraft:lava_bucket' then n=n+item.count end
 end
 return n
end
local function sourceAtFront()
 local fluid=fluidi.peek('front')
 if not fluid then return nil end
 if fluid.kind~='LAVA' then return nil,'Fluido non previsto: '..fluid.kind end
 if not fluid.source then return false end
 local x,z=currentFront()
 if not inside(x,z) then return nil,'Sorgente fuori settore: '..x..','..z end
 local before=lavaBuckets()
 report('PREPARAZIONE','LAVA: prelievo sorgente '..x..',-53,'..z)
 local result,why=fluidi.resolve('front',{x=x,y=-53,z=z},function(cx,cy,cz)
  return cy==-53 and inside(cx,cz) and cx==x and cz==z
 end)
 if result~='raccolto' then return nil,'Prelievo non confermato: '..tostring(why or result) end
 if lavaBuckets()<=before then return nil,'Secchio lava non presente dopo prelievo' end
 sleep(2)
 if fluidi.peek('front') then return nil,'Liquido ancora nella cella dopo prelievo' end
 s.found=true;save()
 return true
end
local function checkLeft()
 face(3) -- OVEST: lato sinistro della N01 che lavora a NORD
 local found,err=sourceAtFront()
 face(0)
 if err then error(err) end
 return found
end
local function recycleLava()
 assert(s.x==HOME.x and s.z==HOME.z,'Rifornimento soltanto alla base')
 local n=0
 local limit=turtle.getFuelLimit()
 for i=1,16 do
  local item=turtle.getItemDetail(i)
  if item and item.name=='minecraft:lava_bucket' then
   local fuel=turtle.getFuelLevel()
   if type(limit)=='number' and type(fuel)=='number' and fuel<limit then
    turtle.select(i)
    if turtle.refuel(1) then n=n+1 end
   end
  end
 end
 return n
end
local function test()
 if s.done then
  report('BASE','TEST LAVA GIA COMPLETATO, non ripeto')
  return
 end
 if #s.path>0 then
  report('RIENTRO','Ripresa: torno alla base prima di altri test')
  goHome()
  error('Traccia precedente recuperata; test annullato per verifica')
 end
 assert(s.x==HOME.x and s.z==HOME.z,'N01 non in home secondo il registro')
 local ok,n=fluidi.ensureBuckets(3)
 assert(ok,'Secchi vuoti non disponibili: '..tostring(n))
 report('PREPARAZIONE','TEST LAVA SINISTRA: settore X2118..2119')
 -- Prima corsia esterna X=2119: max tre passi verso nord, controllo a sinistra.
 for i=1,3 do
  local fluid=fluidi.peek('front')
  if fluid and fluid.kind=='LAVA' then break end
  forward()
  if checkLeft() then break end
 end
 -- Se non l'abbiamo ancora raccolta, avviciniamo il lato interno X=2118.
 if not s.found then
  face(3)
  local direct,err=sourceAtFront()
  if err then error(err) end
  if not direct then
   -- Se c'e' colata a sinistra, NON attraversarla: sorgente non raggiunta.
   local fluid=fluidi.peek('front')
   assert(not fluid,'Corrente a sinistra: impossibile attraversarla in sicurezza')
   forward() -- passo verso X=2118 allo stesso Z, senza lava nella cella
   face(0)
   -- Sorgente fino a due blocchi ulteriori verso nord nella fascia X2118.
   for i=1,3 do
    local found,msg=sourceAtFront()
    if msg then error(msg) end
    if found then break end
    local flow=fluidi.peek('front')
    assert(not flow,'Lava corrente davanti, sorgente non raggiungibile senza isolamento')
    if s.z<=2989 then break end
    forward()
   end
  end
 end
 assert(s.found,'Nessuna sorgente lava raggiungibile nel settore N01')
 report('RIENTRO','Sorgente lava prelevata; ritorno alla home')
 goHome()
 local used=recycleLava()
 s.done=true;save()
 report('BASE','TEST LAVA: sorgente raccolta; rientro OK; lava usata come carburante: '..used)
end

print('MEGAZERO | N01 TEST LAVA DA SINISTRA')
print('Solo N01; fuori base, massimo tre passi a NORD + corsia X2118.')
local ok,why=pcall(test)
if not ok then
 printError('TEST LAVA: '..tostring(why))
 if not s.pending and #s.path>0 then
  report('RIENTRO','Test interrotto, recupero lungo il percorso')
  local back,reason=pcall(goHome)
  if not back then
   report('ERRORE','RIENTRO NON CONFERMATO',tostring(reason))
  else
   report('ERRORE','Test non concluso: N01 rientrata',tostring(why))
  end
 else
  report('ERRORE',s.pending and 'POSIZIONE INCERTA' or 'Test non concluso alla home',tostring(why))
 end
end
print('Premi INVIO per riavviare lo startup MEGAZERO.')
read()
os.reboot()
