-- MEGAZERO ADMIN AGENT v1.3 | OTA e avvio remoto a doppia autorizzazione
-- Pacchetti mirati dal PC 54; update consentito solo a Turtle ferma.
local M={}
local PROTOCOL="megazero.admin.v1"
local RELEASE="bcb8cde9124f9eb1b1537ce311c127355d91c5e9"
local BASE="https://raw.githubusercontent.com/mycolbraga/MEGAZERO/"..RELEASE.."/scripts/turtle/"
local MARKER="/.megazero_ota235_state"
local PACKAGE={
 {name="megazero_miner",remote="megazero_miner.lua",prefix="-- MEGAZERO MINER v2.3.5"},
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
 return "/.megazero_stage_235_"..name
end
local function backupPath(name)
 return "/.megazero_ota_backup_235_"..name
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
 if cfg.miner_autostart~=false then
  return false,"Miner abilitato: vietato aggiornare" end
 if fs.exists("/.megazero_miner_error") then
  return false,"Errore miner presente: verifica manuale" end
 if telemetry.status=="SCAVO" or telemetry.status=="RIENTRO" then
  return false,"Turtle in movimento" end
 local cp=mineInfo(cfg.unit)
 if cp.checkpoint_invalid then return false,"Checkpoint corrotto" end
 if cp.saved and not cp.finished then
  return false,"Checkpoint di lavoro presente: non aggiorno" end
 if cp.pending or (cp.path_count and cp.path_count>0) then
  return false,"Percorso di rientro non concluso" end
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
  fileCount=#PACKAGE,version="2.3.5"}))
end
local function commitUpdate(unit)
 local data=assert(read(MARKER),"Nessun update preparato")
 local mark=assert(textutils.unserialize(data),"Manifest staging illeggibile")
 assert(mark.unit==unit and mark.release==RELEASE and
   mark.fileCount==#PACKAGE and mark.version=="2.3.5",
   "Staging non corrispondente")
 for _,item in ipairs(PACKAGE) do
  verifyFile(stagePath(item.name),item)
  assert(not fs.exists(backupPath(item.name)),
    "Backup gia' esistente: "..backupPath(item.name))
 end
 local originals={}
 for _,item in ipairs(PACKAGE) do
  local target=existing(item.name)
  local existed=fs.exists(target)
  originals[#originals+1]={target=target,backup=backupPath(item.name),
    existed=existed}
 end
 local ok,err=pcall(function()
  -- Prima salvare tutti i file originali, poi toccare i programmi.
  for _,v in ipairs(originals) do
   if v.existed then fs.copy(v.target,v.backup) end
  end
  for i,item in ipairs(PACKAGE) do
   local v=originals[i]
   if fs.exists(v.target) then fs.delete(v.target) end
   fs.move(stagePath(item.name),v.target)
   verifyFile(v.target,item)
  end
 end)
 if not ok then
  local recovered=true
  for _,v in ipairs(originals) do
   local success=pcall(function()
    if fs.exists(v.target) then fs.delete(v.target) end
    if v.existed and fs.exists(v.backup) then fs.copy(v.backup,v.target)
    elseif v.existed then error("Backup mancante: "..v.target) end
   end)
   if not success then recovered=false end
  end
  error("Installazione fallita; ripristino "..(recovered and "eseguito" or
    "NON COMPLETO")..": "..tostring(err))
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
 if diskCfg.miner_autostart~=false or cfg.miner_autostart~=false then
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
  return false,"Miner non v2.3.5" end
 local chest=peripheral.wrap("top")
 if not chest or type(chest.list)~="function" or
    type(chest.pushItems)~="function" or type(chest.size)~="function" then
  return false,"Cassa rifornimento superiore non disponibile" end
 local lower=peripheral.wrap("bottom")
 if not lower or type(lower.list)~="function" then
  return false,"Cassa inferiore per scarico non disponibile" end
 local blocked,block=turtle.inspect()
 if blocked then
  return false,"Uscita dalla base ostruita: "..tostring(block and block.name) end
 local available=0
 local items=chest.list()
 if type(items)~="table" then return false,"Cassa superiore illeggibile" end
 for _,item in pairs(items) do
  if item.name=="minecraft:lava_bucket" then available=available+item.count end
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
 print("ADMIN AGENT v1.3 | "..unit.." | PC "..central)
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
     accepted=false,phase="FAILED",agent_version="1.3"}
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
       response.accepted=true;response.phase="DONE"
      end
      response.package_version="2.3.5"
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
