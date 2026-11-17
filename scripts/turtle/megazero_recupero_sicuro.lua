-- MEGAZERO RECUPERO GPS v1.2 | rientro sul percorso salvato, NO NUOVO SCAVO
-- Eseguito solo dall'agente amministrativo, mai come startup.
local M={}
local V={{0,-1},{1,0},{0,1},{-1,0}}
local function read(p)
 local f=fs.open(p,"r");if not f then return nil end
 local text=f.readAll();f.close();return text
end
local function write(p,data)
 local f=assert(fs.open(p,"w"),"Impossibile scrivere "..p)
 f.write(data);f.close()
 assert(read(p)==data,"Verifica scrittura fallita "..p)
end
local function home(unit)
 local side,n=unit:match("^([NOSE])(%d%d)$")
 n=tonumber(n)
 assert(side and n and n>=1 and n<=10,"Identita Turtle invalida")
 n=n-1
 if side=="N" then return 2119-2*n,-51,2995,0 end
 if side=="O" then return 2099,-51,2995+2*n,3 end
 if side=="S" then return 2099+2*n,-51,3015,2 end
 return 2119,-51,3015-2*n,1
end
local function gpsFix()
 for i=1,2 do
  local x,y,z=gps.locate(4,false)
  if type(x)=="number" and type(y)=="number" and type(z)=="number" then
   return x,y,z
  end
 end
 error("GPS non disponibile: nessun movimento autorizzato",0)
end
local function samePoint(x,y,z,a,b,c)
 return math.abs(x-a)<0.25 and math.abs(y-b)<0.25 and math.abs(z-c)<0.25
end
local function assertAt(x,y,z)
 local a,b,c=gpsFix()
 assert(samePoint(x,y,z,a,b,c),
  ("GPS non coincide: previsto %s,%s,%s reale %s,%s,%s"):
   format(x,y,z,a,b,c))
end
local function sector(hx,hy,hz,hd,x,y,z)
 if x==hx and y==hy and z==hz then return true end
 if y< -61 or y>0 then return false end
 local forward=(x-hx)*V[hd+1][1]+(z-hz)*V[hd+1][2]
 local left=(hd+3)%4
 local lateral=(x-hx)*V[left+1][1]+(z-hz)*V[left+1][2]
 return forward>=1 and forward<=300 and lateral>=0 and lateral<=1
end
local function validateRoute(cp,hx,hy,hz,hd)
 assert(type(cp)=="table" and type(cp.path)=="table" and
  type(cp.x)=="number" and type(cp.y)=="number" and
  type(cp.z)=="number" and type(cp.d)=="number" and
  cp.d%1==0 and cp.d>=0 and cp.d<=3,"Checkpoint invalido")
 local x,y,z=hx,hy,hz
 for i,p in ipairs(cp.path) do
  assert(type(p)=="table" and (p.m=="F" or p.m=="U" or p.m=="D"),
   "Traccia sconosciuta passo "..i)
  if p.m=="F" then
   assert(type(p.d)=="number" and p.d%1==0 and p.d>=0 and p.d<=3,
    "Direzione traccia errata "..i)
   x=x+V[p.d+1][1];z=z+V[p.d+1][2]
  elseif p.m=="U" then y=y+1
  else y=y-1 end
  assert(sector(hx,hy,hz,hd,x,y,z),"Traccia fuori settore passo "..i)
 end
 assert(x==cp.x and y==cp.y and z==cp.z,
  "Traccia non termina alle coordinate del checkpoint")
 return #cp.path
end
local function orientationFromDelta(dx,dz)
 for d=0,3 do
  if V[d+1][1]==dx and V[d+1][2]==dz then return d end
 end
end
-- Determina la direzione con una sonda REVERSIBILE: non scava e non
-- piazza blocchi. Un passo di prova puo toccare una cella confinante,
-- ma viene immediatamente invertito. Si interrompe se il GPS non torna.
local function calibrate(unit,cp,journal)
 local x,y,z=cp.x,cp.y,cp.z
 assertAt(x,y,z)
 local turns=0
 for attempt=1,4 do
  for _,kind in ipairs({"forward","back"}) do
   local undo=kind=="forward" and "back" or "forward"
   write(journal,textutils.serialize({unit=unit,origin={x,y,z},
    test=kind,turns=turns,phase="BEFORE_TEST"}))
   local ok=turtle[kind]()
   if ok then
    write(journal,textutils.serialize({unit=unit,origin={x,y,z},
     test=kind,turns=turns,phase="AFTER_TEST"}))
    local a,b,c=gpsFix()
    local dx,dz=a-x,c-z
    local face=orientationFromDelta(dx,dz)
    if kind=="back" then
     face=orientationFromDelta(-dx,-dz)
    end
    -- Tornare subito al punto originale, anche se il campione GPS
    -- ha dato un risultato inatteso.
    assert(turtle[undo](),"Sonda: non riesco a tornare al punto di partenza")
    assertAt(x,y,z)
    assert(b==y and face~=nil,"Sonda: spostamento non orizzontale")
    for n=1,turns do
     assert(turtle.turnLeft(),"Sonda: rotazione di ripristino fallita")
    end
    assertAt(x,y,z)
    if fs.exists(journal) then fs.delete(journal) end
    return (face-turns+4)%4
   end
  end
  if attempt<4 then
   write(journal,textutils.serialize({unit=unit,origin={x,y,z},
    phase="BEFORE_TURN",turns=turns}))
   assert(turtle.turnRight(),"Sonda: rotazione impossibile")
   turns=turns+1
  end
 end
 for n=1,turns do assert(turtle.turnLeft(),"Ripristino direzione fallito") end
 assertAt(x,y,z)
 if fs.exists(journal) then fs.delete(journal) end
 error("Orientamento non verificabile: nessuna cella libera per la sonda",0)
end
local function backup(cpPath,latchPath,unit)
 local base="/.megazero_recupero_backup_"..unit.."_"
 local i=1
 while fs.exists(base..i) and i<99 do i=i+1 end
 local dir=base..i
 assert(not fs.exists(dir),"Backup recupero pieno: "..dir)
 fs.makeDir(dir)
 write(dir.."/checkpoint",assert(read(cpPath),"Checkpoint assente"))
 local latch=read(latchPath)
 if latch then write(dir.."/errore",latch) end
 return dir
end

-- Autorizzazione esplicita al varco nel tetto sopra le basi.
-- Solo blocchi vanilla innocui, sulla traccia GPS gia' registrata:
-- mai casse, macchine, Turtle, cablaggi o altri oggetti funzionali.
local function isRoofBlock(unit,hx,hy,hz,hd,x,y,z,block)
 if not sector(hx,hy,hz,hd,x,y,z) then return false end
 local forward=(x-hx)*V[hd+1][1]+(z-hz)*V[hd+1][2]
 local left=(hd+3)%4
 local lateral=(x-hx)*V[left+1][1]+(z-hz)*V[left+1][2]
 if forward<1 or forward>2 or lateral<0 or lateral>1 or
   y< -50 or y> -48 then return false end
 local name=block and block.name
 if type(name)~="string" or not name:match("^minecraft:") then
  return false
 end
 for _,pattern in ipairs({
  "chest","shulker","barrel","hopper","dispenser","dropper",
  "furnace","smoker","blast_furnace","crafting_table",
  "crafter","redstone","repeater","comparator","observer",
  "piston","lever","button","pressure_plate","rail",
  "bedrock","portal","spawner","command_block","structure",
  "turtle","computer","lightning_rod","beacon",
  "water","lava","bubble_column","sign","door","trapdoor"
 }) do
  if name:find(pattern,1,true) then return false end
 end
 return true
end
local function removeRoofObstacle(unit,hx,hy,hz,hd,x,y,z,move)
 local inspectFn=move=="F" and turtle.inspect or
  move=="U" and turtle.inspectUp or turtle.inspectDown
 local digFn=move=="F" and turtle.dig or
  move=="U" and turtle.digUp or turtle.digDown
 local exists,block=inspectFn()
 if not exists then return false,"Ostacolo non identificabile" end
 if not isRoofBlock(unit,hx,hy,hz,hd,x,y,z,block) then
  return false,"Blocco protetto/non autorizzato: "..
   tostring(block and block.name or "?")
 end
 -- Una sola rimozione, poi GPS e movimento verificati dal chiamante.
 local removed,reason=digFn()
 if not removed then
  return false,"Tetto non scavabile: "..tostring(reason)
 end
 local remains=inspectFn()
 if remains then
  return false,"Ostacolo ancora presente dopo il taglio"
 end
 return true,tostring(block.name)
end

local function record(cpPath,cp)
 write(cpPath,textutils.serialize(cp))
end
local function turnTo(cp,want,cpPath)
 while cp.d~=want do
  local n=(want-cp.d)%4==3 and -1 or 1
  cp.pending="TURN";record(cpPath,cp)
  local ok=n==-1 and turtle.turnLeft() or turtle.turnRight()
  assert(ok,"Rotazione rientro fallita")
  cp.d=(cp.d+n+4)%4
  cp.pending=nil;record(cpPath,cp)
 end
end
function M.run(cfg,agent)
 assert(type(cfg)=="table" and type(cfg.unit)=="string" and
   cfg.site=="MINIERA-01","Config recupero non autorizzata")
 local unit=cfg.unit
 local rawcfg=assert(read("/megazero_config"),"Config su disco assente")
 local diskcfg=assert(textutils.unserialize(rawcfg),"Config su disco invalida")
 assert(diskcfg.site=="MINIERA-01" and diskcfg.unit==unit and
  diskcfg.miner_autostart==false and cfg.miner_autostart==false,
  "Autostart attivo o config difforme: NON rientro")
 local cpPath="/.megazero_miner_v23_"..unit.."_LAVORO"
 local latchPath="/.megazero_miner_error"
 local cp=assert(textutils.unserialize(assert(read(cpPath),"Checkpoint mancante")),
  "Checkpoint illeggibile")
 local hx,hy,hz,hd=home(unit)
 local length=validateRoute(cp,hx,hy,hz,hd)
 assert(length>0,"Turtle senza percorso da recuperare")
 assert(cp.pending=="TURN" or cp.pending=="BACK" or cp.pending==nil,
  "Operazione pendente non riconciliabile: "..tostring(cp.pending))
 -- BACK puo aver completato fisicamente l'ultimo passo prima di
 -- un riavvio. Il GPS distingue le due possibilita senza indovinare.
 local gx,gy,gz=gpsFix()
 if not samePoint(cp.x,cp.y,cp.z,gx,gy,gz) then
  assert(cp.pending=="BACK" and length>0,
   "GPS diverso dal checkpoint; nessun rientro automatico")
  local last=cp.path[#cp.path]
  local tx,ty,tz=cp.x,cp.y,cp.z
  if last.m=="F" then
   tx=tx-V[last.d+1][1];tz=tz-V[last.d+1][2]
  elseif last.m=="U" then ty=ty-1
  else ty=ty+1 end
  assert(samePoint(tx,ty,tz,gx,gy,gz),
   "GPS diverso sia dal checkpoint sia dal passo BACK atteso")
  -- Il passo era gia riuscito: registra la fine prima di riprendere.
  local resumeBackup=backup(cpPath,latchPath,unit)
  cp.x,cp.y,cp.z=tx,ty,tz
  cp.path[#cp.path]=nil
  cp.pending=nil
  record(cpPath,cp)
  length=#cp.path
  if length==0 then
   -- Nessun movimento ulteriore, restano da orientare e verificare HOME.
  end
 else
  assertAt(cp.x,cp.y,cp.z)
 end
 local journal="/.megazero_recupero_probe_"..unit
 assert(not fs.exists(journal),"Sonda precedente incompleta: esaminare "..journal)
 local backupDir=backup(cpPath,latchPath,unit)
 local actual=cp.d
 if cp.pending=="TURN" then
  actual=calibrate(unit,cp,journal)
 elseif cp.pending=="BACK" then
  -- BACK e' scritto solo DOPO la rotazione e PRIMA del movimento.
  -- GPS == checkpoint dimostra che quel movimento NON e' avvenuto.
  actual=cp.d
 end
 cp.d=actual
 cp.pending=nil
 record(cpPath,cp)
 local fuel=turtle.getFuelLevel()
 if type(fuel)=="number" then
  assert(fuel>=#cp.path+8,"Carburante insufficiente per rientro: "..fuel)
 end
 agent:report("RIENTRO",{detail="Recupero GPS "..unit.." | "..#cp.path.." passi"})
 local done=0
 while #cp.path>0 do
  assertAt(cp.x,cp.y,cp.z)
  local item=cp.path[#cp.path]
  local tx,ty,tz=cp.x,cp.y,cp.z
  local move
  if item.m=="F" then
   turnTo(cp,(item.d+2)%4,cpPath)
   tx=tx+V[cp.d+1][1];tz=tz+V[cp.d+1][2]
   move=turtle.forward
  elseif item.m=="U" then
   ty=ty-1;move=turtle.down
  else
   ty=ty+1;move=turtle.up
  end
  assert(sector(hx,hy,hz,hd,tx,ty,tz),
   "Recupero rifiutato: prossimo passo fuori settore")
  cp.pending="BACK";record(cpPath,cp)
  local ok,reason=move()
  if not ok then
   -- Non scavare se posizione GPS cambiata o stato di movimento incerto.
   assertAt(cp.x,cp.y,cp.z)
   local direction=item.m=="U" and "D" or
      item.m=="D" and "U" or "F"
   -- L'autorizzazione al tetto vale solo nel settore e vicino alla HOME.
   local dug,what=removeRoofObstacle(unit,hx,hy,hz,hd,tx,ty,tz,direction)
   if dug then
    -- La traccia originale resta invariata fino al movimento riuscito.
    ok,reason=move()
    if not ok then assertAt(cp.x,cp.y,cp.z) end
   else
    reason=tostring(reason).." | "..tostring(what)
   end
   if not ok then
    cp.pending=nil;record(cpPath,cp)
    error("Passaggio rientro bloccato a "..tx..","..ty..","..tz..
     ": "..tostring(reason),0)
   end
  end
  -- Se GPS assente o diverso, lascia BACK pendente per non perdere
  -- la possibilità di riconciliare il passo dopo un reboot.
  assertAt(tx,ty,tz)
  cp.x,cp.y,cp.z=tx,ty,tz
  cp.path[#cp.path]=nil
  cp.pending=nil
  record(cpPath,cp)
  done=done+1
  if done%10==0 then
   agent:report("RIENTRO",{detail=unit.." recupero "..done.."/"..length})
  end
 end
 turnTo(cp,hd,cpPath)
 assertAt(hx,hy,hz)
 assert(cp.pending==nil and #cp.path==0 and cp.x==hx and
  cp.y==hy and cp.z==hz and cp.d==hd,"Rientro HOME non verificato")
 agent:report("PREPARAZIONE",{detail=unit.." tornata HOME | pronto per reset"})
 return "HOME GPS OK; passi recuperati="..done.."; backup="..backupDir
end

function M.homeReady(cfg)
 assert(type(cfg)=="table" and cfg.site=="MINIERA-01" and
  type(cfg.unit)=="string","Sito reset non valido")
 local raw=read("/megazero_config")
 local disk=raw and textutils.unserialize(raw)
 if type(disk)~="table" or disk.unit~=cfg.unit or
  disk.site~=cfg.site or disk.miner_autostart~=false or
  cfg.miner_autostart~=false then
  return false,"Config/autostart non coerente"
 end
 local hx,hy,hz,hd=home(cfg.unit)
 local cpPath="/.megazero_miner_v23_"..cfg.unit.."_LAVORO"
 local cpRaw=read(cpPath)
 local cp=cpRaw and textutils.unserialize(cpRaw)
 if type(cp)~="table" or type(cp.path)~="table" then
  return false,"Checkpoint mancante o illeggibile"
 end
 if cp.pending~=nil or #cp.path>0 or cp.x~=hx or
  cp.y~=hy or cp.z~=hz or cp.d~=hd then
  return false,"Turtle non rientrata nel checkpoint"
 end
 local x,y,z=gps.locate(4,false)
 if type(x)~="number" or type(y)~="number" or
  type(z)~="number" or not samePoint(hx,hy,hz,x,y,z) then
  return false,"GPS non conferma la HOME"
 end
 return true,"GPS/checkpoint HOME confermati"
end
function M.resetZero(cfg)
 local allowed,reason=M.homeReady(cfg)
 assert(allowed,reason)
 local unit=cfg.unit
 local cpPath="/.megazero_miner_v23_"..unit.."_LAVORO"
 local prefix="/.megazero_reset_zero_backup_"..unit.."_"
 local n=1
 while fs.exists(prefix..n) and n<99 do n=n+1 end
 local backupDir=prefix..n
 assert(not fs.exists(backupDir),"Backup reset esauriti")
 fs.makeDir(backupDir)
 write(backupDir.."/checkpoint",assert(read(cpPath)))
 write(backupDir.."/config",assert(read("/megazero_config")))
 local errPath="/.megazero_miner_error"
 local errorRaw=read(errPath)
 if errorRaw then write(backupDir.."/errore",errorRaw) end
 local hx,hy,hz,hd=home(unit)
 local fresh={x=hx,y=hy,z=hz,d=hd,path={},pending=nil,
  level=1,distance=0,finished=false,ore=0,buckets=0,blocked=0,
  waterPending=false,incomplete={},completedLevels={},
  retryComplete=false}
 write(cpPath,textutils.serialize(fresh))
 local cp=assert(textutils.unserialize(assert(read(cpPath))))
 assert(cp.x==hx and cp.y==hy and cp.z==hz and cp.d==hd and
  cp.level==1 and cp.distance==0 and #cp.path==0 and
  cp.finished==false,"Reset checkpoint non verificato")
 if errorRaw then fs.delete(errPath) end
 assert(read(errPath)==nil,"Errore precedente non cancellato")
 return "LIV 1 DIST 0 | BACKUP "..backupDir
end
return M
