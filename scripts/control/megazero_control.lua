-- MEGAZERO CONTROL 1.5 - HOME Y=-51, POS affidabile, OTA e avvio remoto
-- Avvio remoto solo dopo CHECK_START, ARM_START e conferma esplicita.
-- Miniera iniziale: 40 Turtle, 10 per fronte, ancora non collegate via software.

local PROTOCOL = "megazero.control.v1"
local ADMIN_PROTOCOL = "megazero.admin.v1"
local adminSequence = 0
local HOSTNAME = "megazero-central"
local DATA_FILE = "/.megazero_control_db"
local MAIN_SITE = "MINIERA-01"
local OFFLINE_MS = 90000

local monitor = peripheral.find("monitor")
assert(monitor, "Monitor non trovato")
local modem = peripheral.find("modem", function(_, m)
  return m.isWireless and m.isWireless()
end)
assert(modem, "Modem wireless/Ender Modem non trovato")
rednet.open(peripheral.getName(modem))
assert(rednet.isOpen(), "Impossibile aprire Rednet")
local okHost, hostErr = pcall(rednet.host, PROTOCOL, HOSTNAME)
if not okHost then print("Avviso: " .. tostring(hostErr)) end
monitor.setTextScale(0.5)

local db = {units = {}, history = {}}
local site = MAIN_SITE
local selected = nil
local page = 1
local touchRows = {}
local dirty = false

local function now()
  return os.epoch("utc")
end

local function clean(v, max)
  if type(v) ~= "string" then return "" end
  return v:gsub("[%c]", " "):sub(1, max or 80)
end

local function unitKey(s, u)
  return s .. "|" .. u
end

local function loadDatabase()
  if not fs.exists(DATA_FILE) then return end
  local f = fs.open(DATA_FILE, "r")
  if not f then return end
  local raw = f.readAll()
  f.close()
  local valid, saved = pcall(textutils.unserialize, raw)
  if valid and type(saved) == "table" then
    if type(saved.units) == "table" then db.units = saved.units end
    if type(saved.history) == "table" then db.history = saved.history end
  end
end

local function saveDatabase()
  if not dirty then return end
  local tmp = DATA_FILE .. ".tmp"
  local f = fs.open(tmp, "w")
  if not f then
    printError("Registro: impossibile salvare")
    return
  end
  f.write(textutils.serialize(db))
  f.close()
  if fs.exists(DATA_FILE) then fs.delete(DATA_FILE) end
  fs.move(tmp, DATA_FILE)
  dirty = false
end

local function addHistory(msg)
  table.insert(db.history, 1, {t=now(), message=clean(msg, 160)})
  while #db.history > 100 do table.remove(db.history) end
  dirty = true
end

loadDatabase()

local function register(s, u, x, y, z, facing)
  local k = unitKey(s,u)
  if db.units[k] then return end
  db.units[k] = {
    site=s, unit=u, home={x=x,y=y,z=z}, facing=facing
  }
  dirty = true
end

-- Ricostruisce soltanto le HOME canoniche della miniera.
-- Il database precedente e' persistente: register() da solo non aggiorna i record esistenti.
local function canonicalHome(unit)
 local side,suffix=unit:match("^([NOSE])(%d%d)$")
 local number=tonumber(suffix)
 if not number or number<1 or number>10 then return nil end
 local i=number-1
 if side=="N" then return 2119-2*i,2995 end
 if side=="O" then return 2099,2995+2*i end
 if side=="S" then return 2099+2*i,3015 end
 if side=="E" then return 2119,3015-2*i end
 return nil
end
for i=1,10 do
  local n=string.format("%02d", i)
  register(MAIN_SITE, "N"..n, 2119-2*(i-1), -51, 2995, "NORD")
  register(MAIN_SITE, "O"..n, 2099, -51, 2995+2*(i-1), "OVEST")
  register(MAIN_SITE, "S"..n, 2099+2*(i-1), -51, 3015, "SUD")
  register(MAIN_SITE, "E"..n, 2119, -51, 3015-2*(i-1), "EST")
end
for _,rec in pairs(db.units) do
 if rec.site==MAIN_SITE and type(rec.unit)=="string" and
  type(rec.home)=="table" and rec.home.y==-53 then
  local hx,hz=canonicalHome(rec.unit)
  if hx and rec.home.x==hx and rec.home.z==hz then
   rec.home.y=-51
   dirty=true
  end
 end
end
-- Record storici: una POS registrata durante lo scavo non diventa
-- una misura reale dopo reboot o riposizionamento manuale.
for _,rec in pairs(db.units) do
 if type(rec)=="table" and rec.site==MAIN_SITE and
    rec.status=="PREPARAZIONE" and rec.position then
  rec.lastHistoricalPosition=rec.position
  rec.position=nil
  rec.positionVerified=false
  dirty=true
 end
end
saveDatabase()

local validStatus = {
  SCAVO=true, RIENTRO=true, BASE=true, ERRORE=true,
  PAUSA=true, PREPARAZIONE=true, BLOCCATO=true, INCOMPLETO=true
}
local function receive(sender, packet, proto)
  if proto ~= PROTOCOL or type(packet) ~= "table" then return end
  if packet.kind ~= "status" or packet.version ~= 1 then return end
  local s = clean(packet.site, 30)
  local u = clean(packet.unit, 20)
  local state = clean(packet.status, 20):upper()
  if s=="" or u=="" or s:find("|",1,true) or u:find("|",1,true) then return end
  if not validStatus[state] then return end
  local k = unitKey(s,u)
  local rec = db.units[k] or {site=s, unit=u}
  local prevState, prevError = rec.status, rec.error
  rec.status, rec.sender, rec.lastSeen = state, sender, now()
  if rec.startRemoteState and state=="SCAVO" then
    rec.startRemoteState="SCAVO CONFERMATO"
  end
  if state=="SCAVO" or state=="RIENTRO" then
    rec.startAllowed=false
  end
  if type(packet.x)=="number" and type(packet.y)=="number" and type(packet.z)=="number" then
    rec.position = {
      x=math.floor(packet.x), y=math.floor(packet.y), z=math.floor(packet.z)
    }
    rec.positionVerified=true
  elseif state=="PREPARAZIONE" and rec.position then
    -- Senza nuove coordinate la POS precedente non va mostrata come attuale.
    rec.lastHistoricalPosition=rec.position
    rec.position=nil
    rec.positionVerified=false
  end
  if type(packet.fuel)=="number" then rec.fuel=math.floor(packet.fuel) end
  if type(packet.progress)=="number" then
    rec.progress=math.max(0,math.min(100,math.floor(packet.progress)))
  end
  if type(packet.detail)=="string" then rec.detail=clean(packet.detail,160) end
  if type(packet.error)=="string" then
    rec.error=clean(packet.error,160)
  elseif state~="ERRORE" then
    rec.error=nil
  end
  db.units[k]=rec
  if state~=prevState or (state=="ERRORE" and rec.error~=prevError) then
    addHistory(s.."/"..u.." "..state.." "..(rec.error or ""))
  end
  dirty=true
end

local function sendAdmin(rec,command)
 if type(rec.sender)~="number" then
  rec.adminMessage="Computer ID non conosciuto"
  return
 end
 if not rec.lastSeen or now()-rec.lastSeen>OFFLINE_MS then
  rec.adminMessage="SENZA SEGNALE: comando non inviato"
  return
 end
 if rec.adminPending and now()-(rec.adminSent or 0)<30000 then
  rec.adminMessage="Attendi la risposta alla richiesta precedente"
  return
 end
 if command=="COMMIT_UPDATE" and rec.adminStaged~=true then
  rec.adminMessage="Prima prepara e verifica l'aggiornamento"
  return
 end
 if command=="ARM_START" and rec.startAllowed~=true then
  rec.adminMessage="Prima controlla i requisiti di avvio"
  return
 end
 if command=="START" and (not rec.startArmId or not rec.startArmExpires
    or now()>rec.startArmExpires) then
  rec.adminMessage="Autorizzazione scaduta: ripetere ARM_START"
  rec.startArmId=nil
  return
 end
 adminSequence=adminSequence+1
 local id=tostring(os.getComputerID()).."-"..tostring(now()).."-"..tostring(adminSequence)
 local packet={
  kind="admin_request",version=1,site=rec.site,
  target_unit=rec.unit,target_computer_id=rec.sender,
  request_id=id,command=command
 }
 if command=="START" then packet.arm_id=rec.startArmId end
 rec.adminPending=id
 rec.adminPendingCommand=command
 rec.adminSent=now()
 rec.adminMessage=command..": inviato, attendo conferma"
 local ok=rednet.send(rec.sender,packet,ADMIN_PROTOCOL)
 if not ok then
  rec.adminPending=nil
  rec.adminMessage="Invio Rednet fallito"
 end
 dirty=true
end

local function sendPing(rec)
 sendAdmin(rec,"PING")
end

local function receiveAdmin(sender,packet,proto)
 if proto~=ADMIN_PROTOCOL or type(packet)~="table" then return end
 if packet.kind~="admin_reply" or packet.version~=1 then return end
 if packet.site~=MAIN_SITE or type(packet.unit)~="string" then return end
 local rec=db.units[unitKey(packet.site,packet.unit)]
 if not rec or rec.sender~=sender or packet.computer_id~=sender then return end
 if type(rec.adminPending)~="string" or
    packet.request_id~=rec.adminPending then return end
 local requested=rec.adminPendingCommand
 if packet.command~=requested then return end
 rec.adminPending=nil
 rec.adminPendingCommand=nil
 rec.adminLastReply=now()
 if packet.accepted==true and
   (packet.phase=="DONE" or packet.phase=="STAGED" or
    packet.phase=="ARMED" or packet.phase=="STARTING") then
  if requested=="CHECK_START" and packet.phase=="DONE" then
   rec.startAllowed=packet.start_allowed==true
   rec.startReason=clean(packet.start_reason or "",130)
   rec.startArmId=nil
   rec.startArmExpires=nil
  elseif requested=="ARM_START" and packet.phase=="ARMED" then
   rec.startArmId=packet.arm_id
   rec.startArmExpires=now()+18000
  elseif requested=="START" and packet.phase=="STARTING" then
   rec.startArmId=nil
   rec.startAllowed=false
   rec.startArmExpires=nil
   rec.startRemoteState="AVVIO RICHIESTO: aspetto SCAVO"
  end
  if requested=="PREPARE_UPDATE" and packet.phase=="STAGED" then
   rec.adminStaged=true
  elseif requested=="COMMIT_UPDATE" and packet.phase=="DONE" then
   rec.adminStaged=false
  elseif requested=="CHECK_UPDATE" then
   rec.adminStaged=packet.staged==true
  end
  rec.adminMessage=requested.." "..packet.phase.." | PC "..sender
  if type(packet.miner)=="table" then
   rec.adminSnapshot={
    agent=clean(packet.agent_version or "?",20),
    boot=clean(packet.boot_version or "?",90),
    miner=packet.miner,
    fuel=packet.fuel,autostart=packet.miner_autostart,
    latch=clean(packet.error_latch or "",120),
    current_status=clean(packet.current_status or "?",25)
   }
  end
  if requested=="CHECK_UPDATE" then
   rec.updateAvailable=packet.update_available==true
   rec.updateAllowed=packet.update_allowed==true
   rec.updateBlockReason=clean(packet.block_reason or "",100)
  elseif requested=="COMMIT_UPDATE" then
   rec.updateAvailable=false
   rec.startAllowed=false
   rec.startArmId=nil
  end
  addHistory(requested.." "..packet.phase.." "..rec.site.."/"..rec.unit)
 else
  rec.adminMessage=requested.." NEGATO: "..clean(packet.reason or "causa ignota",80)
  addHistory(requested.." NEGATO "..rec.site.."/"..rec.unit)
 end
 dirty=true
end

local function siteNames()
  local list,seen={},{}
  for _,r in pairs(db.units) do
    if type(r)=="table" and type(r.site)=="string" and not seen[r.site] then
      seen[r.site]=true
      table.insert(list,r.site)
    end
  end
  table.sort(list)
  return list
end

local function unitsOf(s)
  local result={}
  for k,r in pairs(db.units) do
    if type(r)=="table" and r.site==s then
      r._key=k
      table.insert(result,r)
    end
  end
  table.sort(result,function(a,b) return a.unit<b.unit end)
  return result
end

local function stateOf(rec)
  if not rec.lastSeen then return "MAI COLLEGATA",colors.gray end
  if now()-rec.lastSeen > OFFLINE_MS then return "SENZA SEGNALE",colors.orange end
  local labels={
    SCAVO={"SCAVO",colors.lime},
    RIENTRO={"RIENTRO",colors.cyan},
    BASE={"ALLA BASE",colors.lightBlue},
    ERRORE={"ERRORE",colors.red},
    PAUSA={"PAUSA",colors.yellow},
    PREPARAZIONE={"PREPARAZIONE",colors.yellow},
    BLOCCATO={"BLOCCATO",colors.orange},
    INCOMPLETO={"INCOMPLETO",colors.orange},
  }
  local v=labels[rec.status]
  if v then return v[1],v[2] end
  return "SCONOSCIUTO",colors.gray
end

local function line(x,y,n,value,ink,bg)
  local w,h=monitor.getSize()
  if y<1 or y>h or x<1 or x>w then return end
  n=math.min(n,w-x+1)
  if n<=0 then return end
  local t=tostring(value):sub(1,n)
  monitor.setCursorPos(x,y)
  monitor.setTextColor(ink or colors.white)
  monitor.setBackgroundColor(bg or colors.black)
  monitor.write(t..string.rep(" ",n-#t))
end

local function row(x,y,width,r)
  local state,ink=stateOf(r)
  local t=string.format(" %-4s %-14s",r.unit,state)
  if r.progress and state=="SCAVO" then t=t.." "..r.progress.."%" end
  line(x,y,width,t,ink)
  table.insert(touchRows,{x1=x,x2=x+width-1,y=y,key=r._key})
end

local function drawDetail(r,w,h)
  local state,ink=stateOf(r)
  line(1,5,w,"[ "..r.site.." / "..r.unit.." ]",colors.black,colors.lightBlue)
  local info={
    "STATO: "..state,
    "PC TURTLE: "..tostring(r.sender or "mai connessa"),
    "HOME: "..(r.home and (r.home.x..","..r.home.y..","..r.home.z) or "?"),
    "POS: "..(r.position and (r.position.x..","..r.position.y..","..r.position.z)
      or "NON VERIFICATA (nessun dato recente)"),
    "CARBURANTE: "..tostring(r.fuel or "?"),
    "AVANZAMENTO: "..(r.progress and (r.progress.."%") or "?"),
    "DETTAGLIO: "..(r.detail or "-"),
    "ERRORE: "..(r.error or "-"),
    "ULTIMO CONTATTO: "..(r.lastSeen and (math.floor(math.max(0,now()-r.lastSeen)/1000).."s fa") or "mai"),
    "CONTROLLO REMOTO: "..(r.adminPending and now()-(r.adminSent or 0)>15000
      and "NESSUNA RISPOSTA dopo 15s" or (r.adminMessage or "Da verificare")),
    "AGENTE: "..(r.adminSnapshot and r.adminSnapshot.agent or "-"),
    "VERSIONE MINER: "..(r.adminSnapshot and
      (r.adminSnapshot.miner.version or "-") or "-"),
    "CHECKPOINT: "..(r.adminSnapshot and
      (r.adminSnapshot.miner.saved and
       ("liv "..tostring(r.adminSnapshot.miner.level or "?")..
        ", dist "..tostring(r.adminSnapshot.miner.distance or "?")) or "nessuno") or "-"),
    "ERRORE LATCH: "..(r.adminSnapshot and
      (r.adminSnapshot.latch~="" and r.adminSnapshot.latch or "no") or "-"),
    "UPDATE: "..(r.adminStaged and "PRONTO, da confermare"
      or (r.updateAvailable and "DISPONIBILE" or "NON PREPARATO")),
    "AGGIORNABILE: "..(r.updateAllowed and "SI" or
      (r.updateBlockReason or "DA VERIFICARE")),
    "AVVIO REMOTO: "..(r.startRemoteState or (r.startAllowed and
      "REQUISITI OK, posizione fisica da confermare" or
      (r.startReason or "DA CONTROLLARE"))),
  }
  for i,t in ipairs(info) do
    local y=5+i
    if y>=h-7 then break end
    line(1,y,w,t,i==1 and ink or colors.white)
  end
  line(1,h-7,w,"TOCCA: CONTROLLA REQUISITI AVVIO (NON MUOVE)",colors.black,colors.lightBlue)
  local armed=r.startArmId and r.startArmExpires and now()<=r.startArmExpires
  line(1,h-6,w,armed and
    "CONFERMA AVVIO TURTLE ENTRO 18 SECONDI" or
    "TOCCA: ARMA AVVIO REMOTO",colors.black,colors.yellow)
  line(1,h-5,w,"TOCCA: CONTROLLA VERSIONE E REQUISITI",colors.black,colors.lightBlue)
  line(1,h-4,w,"TOCCA: PREPARA UPDATE (NON INSTALLA)",colors.black,colors.lightBlue)
  local confirm=r.adminConfirmUntil and now()<r.adminConfirmUntil
  line(1,h-3,w,confirm and
    "CONFERMA: TOCCA DI NUOVO PER INSTALLARE" or
    "TOCCA: INSTALLA UPDATE PREPARATO",colors.black,colors.yellow)
  line(1,h-2,w,"TOCCA QUI: PING REMOTO (NON SCAVA)",colors.black,colors.yellow)
  line(1,h-1,w,"TOCCA PER TORNARE",colors.yellow)
end

local function draw()
  touchRows={}
  monitor.setBackgroundColor(colors.black)
  monitor.clear()
  local w,h=monitor.getSize()
  local names=siteNames()
  if #names==0 then return end
  local valid=false
  for _,n in ipairs(names) do if site==n then valid=true end end
  if not valid then site=names[1] end
  local units=unitsOf(site)
  local active,errors,missing=0,0,0
  for _,r in ipairs(units) do
    local st=stateOf(r)
    if st=="SCAVO" or st=="RIENTRO" then active=active+1 end
    if st=="ERRORE" then errors=errors+1 end
    if st=="SENZA SEGNALE" then missing=missing+1 end
  end
  line(1,1,w," MEGAZERO CONTROL | CENTRALE "..os.getComputerID(),colors.black,colors.lime)
  line(1,2,w,"SITO: "..site.."  TURTLE: "..#units,colors.white)
  line(1,3,w,"ATTIVE: "..active.."  ERRORI: "..errors.."  OFFLINE: "..missing,
    errors>0 and colors.red or colors.lightGray)
  if selected and db.units[selected] then
    drawDetail(db.units[selected],w,h)
  elseif w>=48 and h>=32 and site==MAIN_SITE then
    local groups={N={},O={},S={},E={}}
    for _,r in ipairs(units) do
      local prefix=r.unit:sub(1,1)
      if groups[prefix] then table.insert(groups[prefix],r) end
    end
    local half=math.floor(w/2)
    local tiles={
      {"NORD",groups.N,1,5,half},
      {"SUD",groups.S,half+1,5,w-half},
      {"OVEST",groups.O,1,18,half},
      {"EST",groups.E,half+1,18,w-half},
    }
    for _,t in ipairs(tiles) do
      line(t[3],t[4],t[5]," "..t[1].." ("..#t[2]..")",colors.black,colors.lightBlue)
      for i=1,math.min(10,#t[2]) do
        row(t[3],t[4]+i,t[5],t[2][i])
      end
    end
  else
    local rows=math.max(1,h-8)
    local pages=math.max(1,math.ceil(#units/rows))
    page=math.min(page,pages)
    line(1,4,w,"ELENCO "..#units.." | PAGINA "..page.."/"..pages,colors.black,colors.lightBlue)
    for i=1,rows do
      local r=units[(page-1)*rows+i]
      if not r then break end
      row(1,4+i,w,r)
    end
  end
  line(1,h-1,w,selected and "TOCCA: INDIETRO" or "TOCCA RIGA: DETTAGLIO",colors.gray)
  line(1,h,w,selected and " " or "TOCCA QUI: ALTRO SITO / PAGINA",colors.gray)
end

local function nextSite()
  local names=siteNames()
  if #names<=1 then page=1; return end
  local pos=1
  for i,n in ipairs(names) do if n==site then pos=i;break end end
  site=names[pos%#names+1]
  page=1
end

local function onTouch(x,y)
  local w,h=monitor.getSize()
  if selected then
   local rec=db.units[selected]
   if not rec then selected=nil;return end
   if y==h-2 then
    sendPing(rec)
   elseif y==h-7 then
    rec.startAllowed=false
    rec.startArmId=nil
    sendAdmin(rec,"CHECK_START")
   elseif y==h-6 then
    if rec.startArmId and rec.startArmExpires and now()<=rec.startArmExpires then
     sendAdmin(rec,"START")
    else
     sendAdmin(rec,"ARM_START")
    end
   elseif y==h-5 then
    sendAdmin(rec,"CHECK_UPDATE")
   elseif y==h-4 then
    sendAdmin(rec,"PREPARE_UPDATE")
   elseif y==h-3 then
    if not rec.adminStaged then
     rec.adminMessage="Prima PREPARA UPDATE, attendi STAGED"
    elseif rec.adminConfirmUntil and now()<rec.adminConfirmUntil then
     rec.adminConfirmUntil=nil
     sendAdmin(rec,"COMMIT_UPDATE")
    else
     rec.adminConfirmUntil=now()+15000
     rec.adminMessage="Conferma con un secondo tocco entro 15 secondi"
    end
   else
    selected=nil
   end
   dirty=true
   return
  end
  if y>=h-1 then
    if w<48 or h<32 or site~=MAIN_SITE then
      local pages=math.max(1,math.ceil(#unitsOf(site)/math.max(1,h-8)))
      if page<pages then page=page+1 else nextSite() end
    else
      nextSite()
    end
    return
  end
  for _,hit in ipairs(touchRows) do
    if y==hit.y and x>=hit.x1 and x<=hit.x2 then
      selected=hit.key
      return
    end
  end
end

draw()
print("MEGAZERO CONTROL attivo | Computer ID "..os.getComputerID())
print("In attesa dei messaggi dalle Turtle...")
print("Ctrl+T per uscire salvando il registro.")
local timer=os.startTimer(5)
while true do
  local event,a,b,c=os.pullEventRaw()
  if event=="rednet_message" then
    if c==PROTOCOL then receive(a,b,c)
    elseif c==ADMIN_PROTOCOL then receiveAdmin(a,b,c) end
    draw()
  elseif event=="monitor_touch" and a==peripheral.getName(monitor) then
    onTouch(b,c)
    draw()
  elseif event=="timer" and a==timer then
    saveDatabase()
    draw()
    timer=os.startTimer(5)
  elseif event=="monitor_resize" then
    draw()
  elseif event=="terminate" then
    saveDatabase()
    print("MEGAZERO CONTROL chiuso, registro salvato.")
    break
  end
end
