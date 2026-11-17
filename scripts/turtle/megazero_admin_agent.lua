-- MEGAZERO ADMIN AGENT v1.11 | OTA sicuro da HOME con checkpoint conservato
-- Pacchetti mirati dal PC 54; update consentito solo a Turtle ferma.
local M={}
local PROTOCOL="megazero.admin.v1"
local RELEASE="6129e2450931eac9acc502e559e84d1c24a7f87c"
local BASE="https://raw.githubusercontent.com/mycolbraga/MEGAZERO/"..RELEASE.."/scripts/turtle/"
local MARKER="/.megazero_ota2314_state"
local PACKAGE={
 {name="megazero_miner",remote="megazero_miner.lua",prefix="-- MEGAZERO MINER v2.3.14"},
 {name="megazero_fluidi",remote="megazero_fluidi.lua",prefix="-- MEGAZERO FLUIDI v1.0"},
 {name="megazero_auto",remote="megazero_auto.lua",prefix="-- MEGAZERO | Gestione avvio automatico"}
}

local function read(path)
 local f=fs.open(path,"r")
 if not f then return nil end
 local v=f.readAll();f.close();return v
end
local function write(path,value)
 local f=assert(fs.open(path,"w"),"Scrittura non riuscita: "..path)
 f.write(value);f.close()
end
local function firstLine(path)
 local f=fs.open(path,"r")
 if not f then return nil end
 local s=f.readLine();f.close()
 return type(s)=="string" and s:sub(1,120) or nil
end
local function existing(name)
 if fs.exists("/"..name) then return "/"..name end
 if fs.exists("/"..name..".lua") then return "/"..name..".lua" end
 return "/"..name
end
local function stagePath(name)
 return "/.megazero_stage_2314_"..name
end
local function backupPath(name)
 return "/.megazero_ota_backup_2314_"..name
end
local function mineInfo(unit)
 local header=firstLine(existing("megazero_miner"))
 local cp="/.megazero_miner_v23_"..unit.."_LAVORO"
 local checkpoint=read(cp)
 local summary={present=header~=nil,version=header or "NON INSTALLATO",
  saved=checkpoint~=nil}
 if checkpoint then
  local ok,v=pcall(textutils.unserialize,checkpoint)
  if ok and type(v)=="table" then
   summary.level=type(v.level)=="number" and v.level or nil
   summary.distance=type(v.distance)=="number" and v.distance or nil
   summary.path_count=type(v.path)=="table" and #v.path or nil
   summary.pending=v.pending~=nil
   summary.finished=v.finished==true
   summary.saved_x=v.x;summary.saved_y=v.y;summary.saved_z=v.z
  else
   summary.checkpoint_invalid=true
  end
 end
 return summary
end
local function checkStopped(cfg,telemetry)
 if telemetry.status=="SCAVO" or telemetry.status=="RIENTRO" then
  return false,"Turtle impegnata in scavo/rientro" end
 -- Il miner puo' avere autostart attivo ma essere terminato con ERRORE.
 if cfg.miner_autostart==true and telemetry.status~="ERRORE" then
  return false,"Miner ancora abilitato: non posso provare sia fermo" end
 local cp=mineInfo(cfg.unit)
 if cp.checkpoint_invalid or cp.pending or (cp.path_count and cp.path_count>0) then
  return false,"Checkpoint pendente o illeggibile" end
 if cp.finished then return false,"Lavoro gia' finito" end
 local side,n=cfg.unit:match("^([NOSE])(%d%d)$")
 n=tonumber(n)
 if not side or not n or n<1 or n>10 then return false,"Unita non valida" end
 local k=n-1
 local x0,y0,z0,d0
 if side=="N" then x0,y0,z0,d0=2119-2*k,-51,2995,0
 elseif side=="O" then x0,y0,z0,d0=2099,-51,2995+2*k,3
 elseif side=="S" then x0,y0,z0,d0=2099+2*k,-51,3015,2
 else x0,y0,z0,d0=2119,-51,3015-2*k,1 end
 if cp.saved then
  local c=read("/.megazero_miner_v23_"..cfg.unit.."_LAVORO")
  local ok,state=pcall(textutils.unserialize,c or "")
  if not ok or type(state)~="table" or type(state.path)~="table" or
   state.pending~=nil or #state.path~=0 or state.x~=x0 or
   state.y~=y0 or state.z~=z0 or state.d~=d0 then
   return false,"Checkpoint non alla propria HOME" end
 end
 local x,y,z=gps.locate(4,false)
 if type(x)~="number" or math.abs(x-x0)>0.25 or
   math.abs(y-y0)>0.25 or math.abs(z-z0)>0.25 then
  return false,"GPS HOME non verificata" end
 local err=read("/.megazero_miner_error")
 if err then
  local allowed={"Slot 1 riempito dal Regulator","Uscita dalla base ostruita",
    "Regulator:","Scorta secchi","Prelievo secchi",
    "spostare lava nello slot 1","Impossibile raggiungere i secchi vuoti",
    "Blocco non minerario sconosciuto: minecraft:verdant_froglight",
    "Blocco non minerario sconosciuto: minecraft:pearlescent_froglight",
    "Blocco non minerario sconosciuto: minecraft:ochre_froglight"}
  local found=false
  for _,reason in ipairs(allowed) do
   if err:find(reason,1,true) then found=true;break end
  end
  if not found then return false,"Errore non previsto: controllare la Turtle" end
 end
 return true
end
local function checkBundle()
 local ready=true
 for _,item in ipairs(PACKAGE) do
  local line=firstLine(existing(item.name))
  if not line or line:sub(1,#item.prefix)~=item.prefix then ready=false end
 end
 return ready
end
local function verifyFile(path,item)
 local source=assert(read(path),"File mancante "..path)
 assert(source:sub(1,#item.prefix)==item.prefix,
   "Versione inattesa: "..item.name)
 local compiled,why=load(source,"="..item.remote)
 assert(compiled,"Lua non valido "..item.name..": "..tostring(why))
 return source
end
local function prepareUpdate(unit)
 assert(not fs.exists(MARKER),"Pacchetto precedente gia' preparato")
 for _,item in ipairs(PACKAGE) do
  local response,why=http.get(BASE..item.remote)
  assert(response,"Download "..item.remote.." fallito: "..tostring(why))
  local data=response.readAll();response.close()
  assert(type(data)=="string" and data:sub(1,#item.prefix)==item.prefix,
    "Versione download inattesa: "..item.remote)
  local compiled,err=load(data,"="..item.remote)
  assert(compiled,"Sintassi download errata: "..tostring(err))
  local temp=stagePath(item.name)
  if fs.exists(temp) then fs.delete(temp) end
  write(temp,data)
  verifyFile(temp,item)
 end
 write(MARKER,textutils.serialize({unit=unit,release=RELEASE,
  fileCount=#PACKAGE,version="2.3.14"}))
end
local function commitUpdate(unit)
 local data=assert(read(MARKER),"Nessun update preparato")
 local mark=assert(textutils.unserialize(data),"Manifest staging illeggibile")
 assert(mark.unit==unit and mark.release==RELEASE and
   mark.fileCount==#PACKAGE and mark.version=="2.3.14",
   "Staging non corrispondente")
 for _,item in ipairs(PACKAGE) do
  verifyFile(stagePath(item.name),item)
  assert(not fs.exists(backupPath(item.name)),
    "Backup OTA gia esistente: "..backupPath(item.name))
 end
 local cpPath="/.megazero_miner_v23_"..unit.."_LAVORO"
 local cpRaw=read(cpPath)
 local configPath="/megazero_config"
 local cfgRaw=assert(read(configPath),"Config assente")
 local cfg=assert(textutils.unserialize(cfgRaw),"Config illeggibile")
 assert(cfg.unit==unit and cfg.site=="MINIERA-01","Config non corrisponde")
 local errPath="/.megazero_miner_error"
 local errRaw=read(errPath)
 local backupDir="/.megazero_ota2314_backup_"..unit
 assert(not fs.exists(backupDir),"Backup OTA precedente presente")
 fs.makeDir(backupDir)
 write(backupDir.."/megazero_config",cfgRaw)
 if cpRaw then write(backupDir.."/checkpoint",cpRaw) end
 if errRaw then write(backupDir.."/megazero_miner_error",errRaw) end
 local originals={}
 for _,item in ipairs(PACKAGE) do
  local target=existing(item.name)
  local existed=fs.exists(target)
  local backup=backupPath(item.name)
  originals[#originals+1]={target=target,backup=backup,existed=existed}
  if existed then fs.copy(target,backup) end
 end
 -- Disarma il boot al prossimo riavvio; mai riavviare durante l'OTA.
 local temp=configPath..".ota2314.tmp"
 assert(not fs.exists(temp),"File config temporaneo OTA gia presente")
 cfg.miner_autostart=false
 write(temp,textutils.serialize(cfg))
 local ok,why=pcall(function()
  fs.delete(configPath);fs.move(temp,configPath)
  for k,item in ipairs(PACKAGE) do
   local v=originals[k]
   if fs.exists(v.target) then fs.delete(v.target) end
   fs.move(stagePath(item.name),v.target)
   verifyFile(v.target,item)
  end
  assert(read(cpPath)==cpRaw,"Checkpoint cambiato durante OTA")
  if errRaw then fs.delete(errPath) end
 end)
 if not ok then
  local recovered=true
  for _,v in ipairs(originals) do
   local good=pcall(function()
    if fs.exists(v.target) then fs.delete(v.target) end
    if v.existed then fs.copy(v.backup,v.target) end
   end)
   if not good then recovered=false end
  end
  local good=pcall(function()
   if fs.exists(configPath) then fs.delete(configPath) end
   fs.copy(backupDir.."/megazero_config",configPath)
   if errRaw then
    if fs.exists(errPath) then fs.delete(errPath) end
    fs.copy(backupDir.."/megazero_miner_error",errPath)
   end
  end)
  if not good then recovered=false end
  error("OTA fallito; ripristino "..(recovered and "OK" or "DA VERIFICARE")..
   ": "..tostring(why))
 end
 fs.delete(MARKER)
 return #PACKAGE
end

-- Controllo per l'avvio remoto, SENZA muovere la Turtle.
-- Le coordinate reali/orientamento non possono essere provati senza GPS.
local function homeFor(unit)
 local side,n=unit:match("^([NOSE])(%d%d)$")
 n=tonumber(n)
 assert(side and n and n>=1 and n<=10,"Sigla Turtle sconosciuta")
 local i=n-1
 if side=="N" then return 2119-2*i,-51,2995 end
 if side=="O" then return 2099,-51,2995+2*i end
 if side=="S" then return 2099+2*i,-51,3015 end
 return 2119,-51,3015-2*i
end
local function checkStart(cfg,telemetry)
 local raw=read("/megazero_config")
 local ok,diskCfg=pcall(textutils.unserialize,raw or "")
 if not ok or type(diskCfg)~="table" then
  return false,"Configurazione su disco non valida" end
 if diskCfg.unit~=cfg.unit or diskCfg.site~=cfg.site then
  return false,"Identita' config discordante" end
 if diskCfg.miner_autostart~=false then
  return false,"Avvio miner gia' abilitato" end
 if telemetry.status~="PREPARAZIONE" and telemetry.status~="BASE" then
  return false,"Stato non autorizzato: "..tostring(telemetry.status) end
 if fs.exists("/.megazero_miner_error") then
  return false,"Errore miner non risolto" end
 if fs.exists(MARKER) then
  return false,"Aggiornamento OTA ancora preparato" end
 local cp=mineInfo(cfg.unit)
 if cp.checkpoint_invalid then return false,"Checkpoint non leggibile" end
 if cp.saved then
  if cp.finished then return false,"Lavoro gia' completato" end
  if cp.pending or cp.path_count~=0 then
   return false,"Traccia attiva o posizione incerta" end
  local hx,hy,hz=homeFor(cfg.unit)
  if cp.saved_x~=hx or cp.saved_y~=hy or cp.saved_z~=hz then
   return false,"Checkpoint non alla propria base" end
 end
 for _,name in ipairs({"megazero_miner","megazero_fluidi","megazero_auto"}) do
  local path=existing(name)
  if not fs.exists(path) then return false,"Modulo mancante: "..name end
  local source=read(path)
  local fn,err=load(source or "","="..name)
  if not fn then return false,"Modulo non compilabile: "..name.." "..tostring(err) end
 end
 local version=firstLine(existing("megazero_miner"))
 if not version or version:sub(1,#PACKAGE[1].prefix)~=PACKAGE[1].prefix then
  return false,"Miner non v2.3.14" end
 local boot=firstLine(existing("megazero_boot"))
 if not boot or not boot:find("^%-%- MEGAZERO BOOT 1%.2") then
  return false,"BOOT non v1.2" end
 local chest=peripheral.wrap("top")
 if not chest or type(chest.list)~="function" then
  return false,"Cassa rifornimento superiore non disponibile" end
 local lower=peripheral.wrap("bottom")
 if not lower or type(lower.list)~="function" then
  return false,"Cassa inferiore per scarico non disponibile" end
 local blocked,block=turtle.inspect()
 if blocked and not (block and block.name=="minecraft:water") then
  return false,"Uscita dalla base ostruita: "..tostring(block and block.name) end
 local available,buckets=0,0
 local items=chest.list()
 if type(items)~="table" then return false,"Cassa superiore illeggibile" end
 for _,item in pairs(items) do
  if item.name=="minecraft:lava_bucket" then available=available+item.count
  elseif item.name=="minecraft:bucket" then buckets=buckets+item.count end
 end
 for i=1,16 do
  local it=turtle.getItemDetail(i)
  if it and it.name=="minecraft:bucket" then buckets=buckets+it.count end
 end
 if buckets<3 then
  return false,"Regulator: servono 3 secchi vuoti tra cassa sopra e Turtle, disponibili "..buckets
 end
 local fuel=turtle.getFuelLevel()
 if type(fuel)=="number" and fuel<10000 and available<1 then
  return false,"Manca lava nella cassa superiore" end
 return true,"Controlli base e rifornimento superati: posizione fisica non verificata"
end
local function enableAutostart(cfg)
 local path="/megazero_config"
 local raw=assert(read(path),"Configurazione assente")
 local diskCfg=assert(textutils.unserialize(raw),"Configurazione non leggibile")
 assert(diskCfg.unit==cfg.unit and diskCfg.site==cfg.site and
   diskCfg.miner_autostart==false,"Configurazione cambiata: avvio vietato")
 local temp="/.megazero_remote_start_config.new"
 assert(not fs.exists(temp),"Config temporanea gia' presente")
 diskCfg.miner_autostart=true
 write(temp,textutils.serialize(diskCfg))
 local before=assert(read(path),"Config originale non leggibile")
 local backup="/.megazero_remote_start_config.backup"
 if fs.exists(backup) then fs.delete(backup) end
 fs.copy(path,backup)
 fs.delete(path)
 local ok,why=pcall(fs.move,temp,path)
 if not ok then
  if fs.exists(backup) then fs.copy(backup,path) end
  error("Config remoto non applicata: "..tostring(why))
 end
 return true
end

function M.listen(cfg,telemetry)
 assert(type(cfg)=="table" and type(telemetry)=="table",
  "Agente remoto richiede configurazione e rete")
 local unit,site=cfg.unit,cfg.site
 local central=cfg.central or 54
 assert(type(unit)=="string" and unit:match("^[NOSE]%d%d$"),
  "Identificativo non valido")
 assert(site=="MINIERA-01" and type(central)=="number",
  "Sito o centrale inattesi")
 local selfID=os.getComputerID()
 local seen={}
 local arm=nil
 print("ADMIN AGENT v1.11 | "..unit.." | PC "..central)
 while true do
  local sender,request=rednet.receive(PROTOCOL)
  if sender==central and type(request)=="table" and
     request.kind=="admin_request" and request.version==1 and
     request.site==site and request.target_unit==unit and
     request.target_computer_id==selfID and
     type(request.request_id)=="string" and
     #request.request_id>0 and #request.request_id<=64 then
   local response=seen[request.request_id]
   if not response then
    local command=request.command
    response={kind="admin_reply",version=1,site=site,unit=unit,
     computer_id=selfID,request_id=request.request_id,command=command,
     accepted=false,phase="FAILED",agent_version="1.11"}
    local ok,err=pcall(function()
     if command=="PING" or command=="STATUS" or command=="CHECK_UPDATE" or command=="CHECK_START" then
      local latch=read("/.megazero_miner_error")
      response.miner=mineInfo(unit)
      response.boot_version=firstLine(existing("megazero_boot")) or "?"
      response.miner_autostart=cfg.miner_autostart==true
      response.error_latch=latch and latch:sub(1,160) or nil
      response.current_status=telemetry.status
      response.fuel=turtle.getFuelLevel()
      if command=="CHECK_START" then
       local allowed,reason=checkStart(cfg,telemetry)
       response.start_allowed=allowed
       response.start_reason=reason
       response.start_requires_physical_check=true
      end
      if command=="CHECK_UPDATE" then
       response.update_available=not checkBundle()
       response.staged=fs.exists(MARKER)
       local allowed,reason=checkStopped(cfg,telemetry)
       response.update_allowed=allowed
       response.block_reason=reason
      end
      response.accepted=true;response.phase="DONE"
     elseif command=="ARM_START" then
      local allowed,reason=checkStart(cfg,telemetry)
      assert(allowed,reason)
      arm={id=request.request_id,expiry=os.epoch("utc")+20000}
      response.accepted=true;response.phase="ARMED"
      response.arm_id=arm.id
      response.expires_in=20
     elseif command=="START" then
      assert(arm and os.epoch("utc")<=arm.expiry,
       "Autorizzazione scaduta: ripetere ARM_START")
      assert(type(request.arm_id)=="string" and request.arm_id==arm.id,
       "Autorizzazione avvio non corrispondente")
      arm=nil
      local allowed,reason=checkStart(cfg,telemetry)
      assert(allowed,reason)
      enableAutostart(cfg)
      response.accepted=true;response.phase="STARTING"
     elseif command=="PREPARE_UPDATE" or command=="COMMIT_UPDATE" then
      local allowed,reason=checkStopped(cfg,telemetry)
      assert(allowed,reason)
      if command=="PREPARE_UPDATE" then
       prepareUpdate(unit)
       response.accepted=true;response.phase="STAGED"
      else
       response.installed=commitUpdate(unit)
       cfg.miner_autostart=false
       local e=read("/.megazero_miner_error")
       if e then fs.delete("/.megazero_miner_error") end
       telemetry:report("BASE",{detail="OTA completato; HOME ferma; checkpoint invariato"})
       response.accepted=true;response.phase="DONE"
      end
      response.package_version="2.3.14"
     else
      response.reason="Comando non abilitato su v1.1"
     end
    end)
    if not ok then
     response.accepted=false;response.phase="FAILED"
     response.reason=tostring(err):sub(1,160)
    end
    seen[request.request_id]=response
   end
   rednet.send(central,response,PROTOCOL)
   if response.accepted==true and response.phase=="STARTING"
      and response.command=="START" then
    -- Invio ACK prima del reboot. STARTING non equivale a scavo confermato.
    sleep(2)
    os.reboot()
   end
  end
 end
end
return M
