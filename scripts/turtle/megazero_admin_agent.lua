-- MEGAZERO ADMIN AGENT v1.14 | OTA sicuro da HOME con checkpoint conservato
-- Pacchetti mirati dal PC 54; update consentito solo a Turtle ferma.
local M={}
local PROTOCOL="megazero.admin.v1"
local RELEASE="c73386041f6008a5b25bbf33f5e37b5091d8772e"
local BASE="https://raw.githubusercontent.com/mycolbraga/MEGAZERO/"..RELEASE.."/scripts/turtle/"
local MARKER="/.megazero_ota2316_state"
local PACKAGE={
 {name="megazero_miner",remote="megazero_miner.lua",prefix="-- MEGAZERO MINER v2.3.16"},
 {name="megazero_fluidi",remote="megazero_fluidi.lua",prefix="-- MEGAZERO FLUIDI v1.1"},
 {name="megazero_auto",remote="megazero_auto.lua",prefix="-- MEGAZERO | Gestione avvio automatico"},
 {name="megazero_admin_agent",remote="megazero_admin_agent.lua",
  prefix="-- MEGAZERO ADMIN AGENT v1.14"}
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
 return "/.megazero_stage_2316_"..name
end
local function backupPath(name)
 return "/.megazero_ota_backup_2316_"..name
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
    summary.saved_d=v.d
  else
   summary.checkpoint_invalid=true
  end
 end
 return summary
end
-- Un update DI SOFTWARE non richiede HOME o checkpoint vuoto.
-- Richiede pero' miner realmente fermo e autostart spento sul disco.
local function checkStopped(cfg,telemetry)
 if telemetry.status=="SCAVO" or telemetry.status=="RIENTRO" then
  return false,"Turtle in movimento"
 end
 local raw=read("/megazero_config")
 local ok,disk=pcall(textutils.unserialize,raw or "")
 if not ok or type(disk)~="table" or
    disk.unit~=cfg.unit or disk.site~=cfg.site then
  return false,"Configurazione su disco non valida"
 end
 if disk.miner_autostart~=false or cfg.miner_autostart~=false then
  return false,"Autostart abilitato: non posso provare miner fermo"
 end
 local cp=mineInfo(cfg.unit)
 if cp.checkpoint_invalid then return false,"Checkpoint non leggibile" end
 return true,"Aggiornamento file consentito; checkpoint intatto"
end
-- L'agente puo installare release future senza nuovo bootstrap locale:
-- PC54 autorizzato indica lo SHA e le tre versioni previste.
-- Download solo dal repository noto, a file fissi; Lua compilato e verificato.
local function targetPackage(request)
 local release=RELEASE
 local minerVersion="2.3.16"
 local fluidVersion="1.1"
 local agentVersion="1.14"
 if type(request)=="table" and request.release~=nil then
  assert(type(request.release)=="string" and
   #request.release==40 and request.release:match("^[0-9a-f]+$"),
   "SHA release non valido")
  local function version(v)
   return type(v)=="string" and #v<=15 and
    v:match("^%d+%.%d+%.?%d*$")~=nil
  end
  assert(version(request.package_version),"Versione miner non valida")
  assert(version(request.fluid_version),"Versione fluidi non valida")
  assert(version(request.agent_target_version),"Versione agente non valida")
  release=request.release
  minerVersion=request.package_version
  fluidVersion=request.fluid_version
  agentVersion=request.agent_target_version
 end
 local p={
  {name="megazero_miner",remote="megazero_miner.lua",
    prefix="-- MEGAZERO MINER v"..minerVersion},
  {name="megazero_fluidi",remote="megazero_fluidi.lua",
    prefix="-- MEGAZERO FLUIDI v"..fluidVersion},
  {name="megazero_auto",remote="megazero_auto.lua",
    prefix="-- MEGAZERO | Gestione avvio automatico"},
  {name="megazero_admin_agent",remote="megazero_admin_agent.lua",
    prefix="-- MEGAZERO ADMIN AGENT v"..agentVersion}
 }
 return release,minerVersion,p
end
local function checkBundle(request)
 local _,_,items=targetPackage(request)
 for _,item in ipairs(items) do
  local header=firstLine(existing(item.name))
  if not header or header:sub(1,#item.prefix)~=item.prefix then
   return false
  end
 end
 return true
end
local function verifyFile(path,item)
 local source=assert(read(path),"File mancante "..path)
 assert(source:sub(1,#item.prefix)==item.prefix,
  "Versione inattesa: "..item.name)
 local compiled,why=load(source,"="..item.remote)
 assert(compiled,"Lua non valido "..item.name..": "..tostring(why))
 return source
end
local function prepareUpdate(unit,request)
 local release,version,items=targetPackage(request)
 assert(not fs.exists(MARKER),"Pacchetto precedente gia preparato")
 local base="https://raw.githubusercontent.com/mycolbraga/MEGAZERO/"..
  release.."/scripts/turtle/"
 for _,item in ipairs(items) do
  local response,why=http.get(base..item.remote)
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
 write(MARKER,textutils.serialize({
  unit=unit,release=release,version=version,items=items
 }))
end
local function commitUpdate(unit)
 local data=assert(read(MARKER),"Nessun update preparato")
 local mark=assert(textutils.unserialize(data),"Staging illeggibile")
 assert(mark.unit==unit and type(mark.release)=="string" and
  #mark.release==40 and type(mark.items)=="table" and
  #mark.items==4,"Staging non corrispondente")
 local items=mark.items
 for k,base in ipairs(PACKAGE) do
  local item=items[k]
  assert(item and item.name==base.name and item.remote==base.remote and
   type(item.prefix)=="string" and
   item.prefix:find("^%-%- MEGAZERO "),
   "Staging inatteso: "..base.name)
  verifyFile(stagePath(item.name),item)
 end
 local cpPath="/.megazero_miner_v23_"..unit.."_LAVORO"
 local cpRaw=read(cpPath)
 local configPath="/megazero_config"
 local cfgRaw=assert(read(configPath),"Config assente")
 local cfg=assert(textutils.unserialize(cfgRaw),"Config non leggibile")
 assert(cfg.unit==unit and cfg.site=="MINIERA-01","Config diversa")
 assert(cfg.miner_autostart==false,"Autostart attivo: OTA vietato")
 local errPath="/.megazero_miner_error"
 local errRaw=read(errPath)
 local backupDir="/.megazero_ota2316_backup_"..unit.."_"..
  mark.release:sub(1,10)
 assert(not fs.exists(backupDir),"Backup release gia presente")
 fs.makeDir(backupDir)
 write(backupDir.."/megazero_config",cfgRaw)
 if cpRaw then write(backupDir.."/checkpoint",cpRaw) end
 if errRaw then write(backupDir.."/megazero_miner_error",errRaw) end
 local originals={}
 for _,item in ipairs(items) do
  local target=existing(item.name)
  local existed=fs.exists(target)
  local backup=backupDir.."/"..item.name
  originals[#originals+1]={target=target,backup=backup,existed=existed}
  if existed then fs.copy(target,backup) end
 end
 local temp=configPath..".ota2316.tmp"
 assert(not fs.exists(temp),"Config temporanea gia presente")
 cfg.miner_autostart=false
 write(temp,textutils.serialize(cfg))
 local ok,why=pcall(function()
  fs.delete(configPath);fs.move(temp,configPath)
  for k,item in ipairs(items) do
   local old=originals[k]
   if fs.exists(old.target) then fs.delete(old.target) end
   fs.move(stagePath(item.name),old.target)
   verifyFile(old.target,item)
  end
  assert(read(cpPath)==cpRaw,"Checkpoint modificato durante OTA")
  assert(read(errPath)==errRaw,"Errore precedente modificato durante OTA")
 end)
 if not ok then
  local recovered=true
  for _,old in ipairs(originals) do
   local good=pcall(function()
    if fs.exists(old.target) then fs.delete(old.target) end
    if old.existed then fs.copy(old.backup,old.target) end
   end)
   if not good then recovered=false end
  end
  local good=pcall(function()
   if fs.exists(configPath) then fs.delete(configPath) end
   fs.copy(backupDir.."/megazero_config",configPath)
  end)
  if not good then recovered=false end
  error("OTA fallito; ripristino "..(recovered and "OK" or "DA VERIFICARE")..
   ": "..tostring(why))
 end
 fs.delete(MARKER)
 return #items,mark.version
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
 if cp.checkpoint_invalid or not cp.saved then
  return false,"Checkpoint assente/non leggibile" end
 if cp.finished then return false,"Lavoro gia' completato" end
 if cp.pending or cp.path_count~=0 then
  return false,"Traccia attiva o posizione incerta" end
 local hx,hy,hz=homeFor(cfg.unit)
 if cp.saved_x~=hx or cp.saved_y~=hy or cp.saved_z~=hz then
  return false,"Checkpoint non alla propria base" end
 local side=cfg.unit:sub(1,1)
 local facing=side=="N" and 0 or side=="O" and 3 or
   side=="S" and 2 or 1
 if cp.saved_d~=facing then
  return false,"Orientamento del checkpoint non HOME" end
 local x,y,z=gps.locate(4,false)
 if type(x)~="number" or type(y)~="number" or
   type(z)~="number" or math.abs(x-hx)>0.25 or
   math.abs(y-hy)>0.25 or math.abs(z-hz)>0.25 then
  return false,"GPS HOME non verificata" end
 for _,name in ipairs({"megazero_miner","megazero_fluidi","megazero_auto"}) do
  local path=existing(name)
  if not fs.exists(path) then return false,"Modulo mancante: "..name end
  local source=read(path)
  local fn,err=load(source or "","="..name)
  if not fn then return false,"Modulo non compilabile: "..name.." "..tostring(err) end
 end
 local version=firstLine(existing("megazero_miner"))
 if not version or version:sub(1,#PACKAGE[1].prefix)~=PACKAGE[1].prefix then
  return false,"Miner non v2.3.16" end
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
 return true,"GPS e checkpoint HOME verificati, scorte pronte"
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
 print("ADMIN AGENT v1.14 | "..unit.." | PC "..central)
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
     accepted=false,phase="FAILED",agent_version="1.14"}
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
       response.update_available=not checkBundle(request)
       response.staged=fs.exists(MARKER)
       local allowed,reason=checkStopped(cfg,telemetry)
       response.update_allowed=allowed
       response.block_reason=reason
      end
      response.accepted=true;response.phase="DONE"
     elseif command=="RESET_AUDIT" then
      -- Solo controllo, nessun movimento e nessuna scrittura.
      local cpPath="/.megazero_miner_v23_"..unit.."_LAVORO"
      local rawCp=read(cpPath)
      local parsed,cp=pcall(textutils.unserialize,rawCp or "")
      local side,n=unit:match("^([NOSE])(%d%d)$")
      n=tonumber(n)
      local i=n-1
      local hx,hy,hz,d
      if side=="N" then hx,hy,hz,d=2119-2*i,-51,2995,0
      elseif side=="O" then hx,hy,hz,d=2099,-51,2995+2*i,3
      elseif side=="S" then hx,hy,hz,d=2099+2*i,-51,3015,2
      else hx,hy,hz,d=2119,-51,3015-2*i,1 end
      local gx,gy,gz=gps.locate(4,false)
      local gpsOK=type(gx)=="number" and type(gy)=="number"
       and type(gz)=="number"
      local home=gpsOK and math.abs(gx-hx)<=0.25
       and math.abs(gy-hy)<=0.25 and math.abs(gz-hz)<=0.25
      local cpOK=parsed and type(cp)=="table" and
       type(cp.path)=="table" and type(cp.x)=="number"
       and type(cp.y)=="number" and type(cp.z)=="number"
       and type(cp.d)=="number"
      response.reset_audit={
       gps_ok=gpsOK,gps_x=gx,gps_y=gy,gps_z=gz,
       home_x=hx,home_y=hy,home_z=hz,home_d=d,
       gps_home=home==true,cp_ok=cpOK==true,
       saved_x=cpOK and cp.x or nil,
       saved_y=cpOK and cp.y or nil,
       saved_z=cpOK and cp.z or nil,
       saved_d=cpOK and cp.d or nil,
       pending=cpOK and cp.pending or nil,
       path_count=cpOK and #cp.path or nil,
       level=cpOK and cp.level or nil,
       distance=cpOK and cp.distance or nil,
       autostart=cfg.miner_autostart==true,
       error_latched=read("/.megazero_miner_error")~=nil,
       ready_home=cpOK and home and cp.pending==nil
        and #cp.path==0 and cp.x==hx and cp.y==hy
        and cp.z==hz and cp.d==d and
        cfg.miner_autostart==false
      }
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
     elseif command=="RESTART_IDLE" then
      local allowed,reason=checkStopped(cfg,telemetry)
      assert(allowed,reason)
      response.accepted=true;response.phase="RESTARTING"
     elseif command=="PREPARE_UPDATE" or command=="COMMIT_UPDATE" then
      local allowed,reason=checkStopped(cfg,telemetry)
      assert(allowed,reason)
      if command=="PREPARE_UPDATE" then
       prepareUpdate(unit,request)
       response.accepted=true;response.phase="STAGED"
      else
       response.installed,response.package_version=commitUpdate(unit)
       cfg.miner_autostart=false
       telemetry:report("PREPARAZIONE",{
        detail="OTA installata; autostart OFF, checkpoint ed errori conservati"
       })
       response.accepted=true;response.phase="DONE"
      end
      response.package_version=response.package_version or "2.3.16"
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
   if response.accepted==true and
      ((response.phase=="STARTING" and response.command=="START") or
       (response.phase=="RESTARTING" and response.command=="RESTART_IDLE")) then
    -- Invio ACK prima del reboot. STARTING non equivale a scavo confermato.
    sleep(2)
    os.reboot()
   end
  end
 end
end
return M
