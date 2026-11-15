-- MEGAZERO | Telemetria Turtle v1.0
-- Modalita' test: "megazero_rete N01" (nessun movimento/scavo).
-- Modalita' modulo: local rete=dofile("megazero_rete").new("N01")
-- La centrale e' il computer CC:Tweaked 54, con discovery Rednet opzionale.

local M = {}
local PROTOCOL = "megazero.control.v1"
local HOSTNAME = "megazero-central"
local DEFAULT_SITE = "MINIERA-01"
local FALLBACK_ID = 54
local INTERVAL_MS = 20000

local valid = {
  SCAVO=true, RIENTRO=true, BASE=true, ERRORE=true,
  PAUSA=true, PREPARAZIONE=true
}

local function stringa(v, limit)
  if type(v) ~= "string" then return nil end
  return v:gsub("[%c]", " "):sub(1, limit or 160)
end

local function modemWireless()
  return peripheral.find("modem", function(_, m)
    return m.isWireless and m.isWireless()
  end)
end

function M.new(unit, site, centralId)
  assert(type(unit) == "string" and #unit > 0 and #unit <= 20
    and not unit:find("|", 1, true), "Identificativo Turtle non valido")
  site = site or DEFAULT_SITE
  assert(type(site) == "string" and #site > 0 and #site <= 30
    and not site:find("|", 1, true), "Identificativo miniera non valido")

  local modem = modemWireless()
  if not modem then
    return nil, "Nessun Wireless/Ender Modem disponibile sulla Turtle"
  end
  local modemName = peripheral.getName(modem)
  rednet.open(modemName)

  -- Cerca la centrale per nome. Se non e' caricata, usa l'ID noto.
  local found, remoteId = pcall(rednet.lookup, PROTOCOL, HOSTNAME)
  local server = (found and type(remoteId) == "number")
    and remoteId or centralId or FALLBACK_ID

  local agent = {
    unit=unit,
    site=site,
    server=server,
    status="PREPARAZIONE",
    detail="",
    lastSent=0,
    extra={}
  }

  local function buildPacket()
    local packet = {
      kind="status",
      version=1,
      site=agent.site,
      unit=agent.unit,
      status=agent.status,
      detail=agent.detail
    }
    for _,k in ipairs({"x","y","z","fuel","progress","error"}) do
      packet[k] = agent.extra[k]
    end
    local level = turtle.getFuelLevel()
    if type(level) == "number" then
      packet.fuel = level
    end
    return packet
  end

  function agent:send()
    local ok = rednet.send(self.server, buildPacket(), PROTOCOL)
    -- "ok" indica invio locale, NON consegna confermata alla centrale.
    if ok then self.lastSent = os.epoch("utc") end
    return ok
  end

  function agent:report(state, fields)
    assert(valid[state], "Stato telemetria non valido: "..tostring(state))
    self.status = state
    fields = fields or {}
    assert(type(fields)=="table", "Dati telemetria non validi")
    if fields.detail ~= nil then
      self.detail = stringa(fields.detail, 160) or ""
    end
    for _,k in ipairs({"x","y","z","fuel","progress","error"}) do
      local value = fields[k]
      if value ~= nil then
        if k=="error" then
          self.extra[k] = stringa(value, 160)
        elseif type(value)=="number" then
          self.extra[k] = math.floor(value)
        end
      end
    end
    if state ~= "ERRORE" then self.extra.error = nil end
    return self:send()
  end

  function agent:heartbeat()
    if os.epoch("utc")-self.lastSent >= INTERVAL_MS then
      return self:send()
    end
    return true
  end

  function agent:heartbeatLoop()
    while true do
      self:heartbeat()
      sleep(5)
    end
  end

  return agent
end

local args = {...}
if #args > 0 then
  local unit = args[1]
  local site = args[2] or DEFAULT_SITE
  local agent, err = M.new(unit, site)
  if not agent then
    printError(err)
    return
  end
  print("MEGAZERO - TEST RETE (NON SCAVA)")
  print("Turtle: "..site.."/"..unit)
  print("Centrale individuata/ID: "..agent.server)
  local sent = agent:report("PREPARAZIONE", {
    detail="TEST RETE: Turtle ferma, programma minerario non avviato"
  })
  print("Invio Rednet: "..tostring(sent))
  print("L'invio NON conferma la ricezione alla centrale.")
  print("Aggiornamento ogni 20s. Ctrl+T per interrompere.")
  agent:heartbeatLoop()
else
  return M
end
