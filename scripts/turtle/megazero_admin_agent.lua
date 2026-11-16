-- MEGAZERO ADMIN AGENT v1.1 | PING, CHECK, PREPARE, COMMIT: NON SCAVA
-- Pacchetti mirati dal PC 54; update consentito solo a Turtle ferma.
local M={}
local PROTOCOL="megazero.admin.v1"
local RELEASE="f30c85a2d20b0152a58a77180a48e2606e81d7ce"
local BASE="https://raw.githubusercontent.com/mycolbraga/MEGAZERO/"..RELEASE.."/scripts/turtle/"
local MARKER="/.megazero_ota231_state"
local PACKAGE={
 {name="megazero_miner",remote="megazero_miner.lua",prefix="-- MEGAZERO MINER v2.3.1"},
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
 return "/.megazero_stage_231_"..name
end
local function backupPath(name)
 return "/.megazero_ota_backup_231_"..name
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
  if firstLine(existing(item.name))~=item.prefix then ready=false end
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
  fileCount=#PACKAGE,version="2.3.1"}))
end
local function commitUpdate(unit)
 local data=assert(read(MARKER),"Nessun update preparato")
 local mark=assert(textutils.unserialize(data),"Manifest staging illeggibile")
 assert(mark.unit==unit and mark.release==RELEASE and
   mark.fileCount==#PACKAGE and mark.version=="2.3.1",
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
 print("ADMIN AGENT v1.1 | "..unit.." | PC "..central)
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
     accepted=false,phase="FAILED",agent_version="1.1"}
    local ok,err=pcall(function()
     if command=="PING" or command=="STATUS" or command=="CHECK_UPDATE" then
      local latch=read("/.megazero_miner_error")
      response.miner=mineInfo(unit)
      response.boot_version=firstLine(existing("megazero_boot")) or "?"
      response.miner_autostart=cfg.miner_autostart==true
      response.error_latch=latch and latch:sub(1,160) or nil
      response.current_status=telemetry.status
      response.fuel=turtle.getFuelLevel()
      if command=="CHECK_UPDATE" then
       response.update_available=not checkBundle()
       response.staged=fs.exists(MARKER)
       local allowed,reason=checkStopped(cfg,telemetry)
       response.update_allowed=allowed
       response.block_reason=reason
      end
      response.accepted=true;response.phase="DONE"
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
      response.package_version="2.3.1"
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
  end
 end
end
return M
