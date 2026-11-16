-- MEGAZERO ADMIN AGENT v1.0 | sola diagnostica, NESSUN movimento
-- Solo pacchetti mirati dal PC centrale abbinato: PING e STATUS.
local M={}
local PROTOCOL="megazero.admin.v1"

local function read(path)
 local f=fs.open(path,"r")
 if not f then return nil end
 local v=f.readAll();f.close();return v
end
local function firstLine(path)
 local f=fs.open(path,"r")
 if not f then return nil end
 local s=f.readLine();f.close()
 return type(s)=="string" and s:sub(1,120) or nil
end
local function mineInfo(unit)
 local name=fs.exists("/megazero_miner") and "/megazero_miner"
   or "/megazero_miner.lua"
 local header=firstLine(name)
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
   summary.saved_x=v.x;summary.saved_y=v.y;summary.saved_z=v.z
  else
   summary.checkpoint_invalid=true
  end
 end
 return summary
end

function M.listen(cfg,telemetry)
 assert(type(cfg)=="table" and type(telemetry)=="table",
   "Agente remoto richiede configurazione e rete")
 local unit,site=cfg.unit,cfg.site
 local central=cfg.central or 54
 assert(type(unit)=="string" and unit:match("^[NOSE]%d%d$"),
  "Nome Turtle non valido")
 assert(site=="MINIERA-01","Sito inatteso")
 assert(type(central)=="number","ID centrale mancante")
 local selfID=os.getComputerID()
 print("ADMIN AGENT v1.0: "..unit.." | ascolto centrale "..central)
 while true do
  local sender,request=rednet.receive(PROTOCOL)
  if sender==central and type(request)=="table"
     and request.kind=="admin_request" and request.version==1
     and request.site==site and request.target_unit==unit
     and request.target_computer_id==selfID
     and type(request.request_id)=="string"
     and #request.request_id>0 and #request.request_id<=64 then
   local command=request.command
   local response={
    kind="admin_reply",version=1,site=site,unit=unit,
    computer_id=selfID,request_id=request.request_id,
    command=command,accepted=false,phase="FAILED"
   }
   if command=="PING" or command=="STATUS" then
    local latch=read("/.megazero_miner_error")
    response.accepted=true
    response.phase="DONE"
    response.agent_version="1.0"
    response.boot_version=firstLine("/megazero_boot")
       or firstLine("/megazero_boot.lua") or "?"
    response.miner=mineInfo(unit)
    response.miner_autostart=cfg.miner_autostart==true
    response.error_latch=latch and latch:sub(1,160) or nil
    response.current_status=telemetry.status
    response.fuel=turtle.getFuelLevel()
   else
    response.reason="Comando non abilitato; solo PING/STATUS"
   end
   rednet.send(central,response,PROTOCOL)
  end
 end
end
return M
