-- MEGAZERO N05 | Calibra heading dopo pending TURN, senza scavare.
-- Un unico passo di prova ORIZZONTALE, GPS prima/dopo, ritorno immediato.
-- NON avvia rientro/scavo; niente reboot o modifica altri computer.
assert(turtle and os.getComputerID()==17,"Solo sulla Turtle N05 (PC17)")
local cpPath="/.megazero_miner_v23_N05_LAVORO"
local backup="/.megazero_N05_backup_PENDING_TURN"
local journal="/.megazero_N05_calibrazione_info"
local function read(p)
 local f=assert(fs.open(p,"r"),"Impossibile leggere "..p)
 local t=f.readAll();f.close();return t
end
local function write(p,t)
 local f=assert(fs.open(p,"w"),"Impossibile scrivere "..p)
 f.write(t);f.close()
end
local cfg=assert(textutils.unserialize(read("/megazero_config")),"Config N05 non valida")
assert(cfg.site=="MINIERA-01" and cfg.unit=="N05","Non e' la N05")
local data=read(cpPath)
local s=assert(textutils.unserialize(data),"Checkpoint N05 non leggibile")
assert(type(s)=="table" and s.x==2110 and s.y==-5 and s.z==2975
 and s.d==0 and s.pending=="TURN" and
 type(s.path)=="table" and #s.path==83 and s.finished~=true,
 "Checkpoint diverso dalla diagnostica: STOP senza modifiche")
assert(not fs.exists(backup) and not fs.exists(journal),
 "Calibrazione gia' cominciata: controllare backup/journal, NON ritentare")
local function locate()
 local x,y,z=gps.locate(3,false)
 assert(type(x)=="number" and type(y)=="number" and type(z)=="number",
   "GPS non disponibile: STOP")
 return x,y,z
end
local x,y,z=locate()
local function near(a,b) return math.abs(a-b)<0.25 end
assert(near(x,s.x) and near(y,s.y) and near(z,s.z),
 "GPS non coincide con checkpoint: STOP")
-- Prima di muovere, archivia ESATTAMENTE il checkpoint originale.
fs.copy(cpPath,backup)
assert(read(backup)==data,"Backup N05 incompleto: STOP")
write(journal,"PREPARATA | GPS "..x..","..y..","..z..
 " | cp 83 passi | pending TURN")
print("N05: backup salvato; GPS "..x..","..y..","..z)
print("Cerco un passo libero senza DIG, poi torno alla stessa cella.")
local moved=false
local afterX,afterY,afterZ=nil,nil,nil
for trial=1,4 do
 local blocked=turtle.inspect()
 if not blocked then
  write(journal,"PROVA IN CORSO | tentativo "..trial..
   " | se interrotta verificare GPS prima di ripetere")
  local ok,why=turtle.forward()
  if ok then
   moved=true
   local check,gx,gy,gz=pcall(locate)
   if not check then
    printError("GPS assente dopo il passo: ritorno immediato")
   else
    afterX,afterY,afterZ=gx,gy,gz
   end
   -- Prima torna nella cella di partenza, senza scavare e senza girarsi.
   local ret,whyBack=turtle.back()
   if not ret then
    write(journal,"ATTENZIONE: passo effettuato, RITORNO FALLITO: "..tostring(whyBack))
    error("NON MUOVERE: ritorno di prova fallito, GPS da controllare",0)
   end
   local okBack,bx,by,bz=pcall(locate)
   if not okBack or not (near(bx,x) and near(by,y) and near(bz,z)) then
    write(journal,"ATTENZIONE: ritorno fisico non confermato dal GPS")
    error("NON RIAVVIARE: GPS rientro prova non confermato",0)
   end
   break
  end
 end
 if trial<4 then
  local turned,why=turtle.turnRight()
  assert(turned,"Rotazione di prova non riuscita: "..tostring(why))
 end
end
assert(moved,"Nessuna direzione libera per prova: STOP")
assert(afterX and afterY and afterZ,
 "GPS durante prova non valido: non modifico il checkpoint")
local dx=math.floor(afterX-x+0.5)
local dy=math.floor(afterY-y+0.5)
local dz=math.floor(afterZ-z+0.5)
local heading
if dx==0 and dy==0 and dz==-1 then heading=0
elseif dx==1 and dy==0 and dz==0 then heading=1
elseif dx==0 and dy==0 and dz==1 then heading=2
elseif dx==-1 and dy==0 and dz==0 then heading=3
end
assert(heading~=nil and near(afterX,x+dx) and near(afterY,y+dy) and
 near(afterZ,z+dz),"Movimento GPS inatteso: NON modifico checkpoint")
local again=read(cpPath)
assert(again==data,"Checkpoint modificato durante calibrazione: STOP")
-- Solo dopo doppia verifica GPS aggiorna la direzione fisica e
-- libera il pending TURN. Tutti gli 83 passi e la posizione restano identici.
s.d=heading
s.pending=nil
local stage="/.megazero_N05_checkpoint_calibrato"
assert(not fs.exists(stage),"Checkpoint calibrato temporaneo preesistente")
write(stage,textutils.serialize(s))
local verify=assert(textutils.unserialize(read(stage)),"Staging N05 illeggibile")
assert(verify.pending==nil and verify.d==heading and
 verify.x==2110 and verify.y==-5 and verify.z==2975 and
 #verify.path==83,"Staging non coerente")
fs.delete(cpPath)
fs.move(stage,cpPath)
write(journal,"OK | GPS ritorno "..x..","..y..","..z..
 " | direzione reale "..heading.." | 83 passi | pending risolto")
print("CALIBRAZIONE OK. GPS rientrato alla cella originale.")
print("Direzione fisica confermata: "..heading.." (0=N,1=E,2=S,3=O)")
print("Checkpoint: pending=nil; 83 passi CONSERVATI.")
print("N05 FERMA: non avviare ancora il miner.")
