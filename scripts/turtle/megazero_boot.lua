-- MEGAZERO BOOT 1.0 | Avvio permanente di telemetria e futuro miner
-- Startup usa: shell.run("/megazero_boot")
-- Sicurezza: miner disabilitato fino alla configurazione e ai test.
-- ATTENZIONE: non programma alcun movimento o scavo autonomamente.

local CONFIG="/megazero_config"
local MODULE="/megazero_rete"
local MINER="/megazero_miner"
local ERROR_LATCH="/.megazero_miner_error"

local function readFile(path)
  local f=fs.open(path,"r")
  if not f then return nil end
  local s=f.readAll()
  f.close()
  return s
end

local raw=readFile(CONFIG)
assert(raw, "Configurazione MEGAZERO non trovata: "..CONFIG)
local ok,cfg=pcall(textutils.unserialize,raw)
assert(ok and type(cfg)=="table", "Configurazione MEGAZERO non valida")
assert(type(cfg.unit)=="string" and cfg.unit:match("^[NOSE]%d%d$"),
  "Identificativo Turtle mancante o errato")
assert(type(cfg.site)=="string" and #cfg.site>0,"Nome miniera mancante")

if not fs.exists(MODULE) and fs.exists(MODULE..".lua") then
  MODULE=MODULE..".lua"
end
assert(fs.exists(MODULE),"Modulo megazero_rete mancante")
local good,telemetry=pcall(dofile,MODULE)
assert(good and type(telemetry)=="table"
  and type(telemetry.new)=="function",
  "Modulo telemetria non caricabile: "..tostring(telemetry))

local agent,err=telemetry.new(cfg.unit,cfg.site,cfg.central or 54)
assert(agent,err or "Impossibile inizializzare la rete")

print("MEGAZERO BOOT 1.0 | "..cfg.site.."/"..cfg.unit)
print("CENTRALE: "..agent.server)

local function report(status,details)
  local goodSend,why=pcall(function()
    return agent:report(status,details)
  end)
  if not goodSend then printError("Telemetria: "..tostring(why)) end
end

local minerRequested=(cfg.miner_autostart==true)
local minerPresent=fs.exists(MINER) or fs.exists(MINER..".lua")
local latched=fs.exists(ERROR_LATCH)

if not minerRequested then
  report("PREPARAZIONE",{detail="Avvio automatico attivo; miner non abilitato"})
elseif latched then
  local cause=readFile(ERROR_LATCH) or "errore precedente non risolto"
  report("ERRORE",{
    detail="MINER BLOCCATO: necessario intervento manuale",
    error=cause:sub(1,160)
  })
elseif not minerPresent then
  report("ERRORE",{
    detail="MINER NON INSTALLATO: nessuno scavo avviato",
    error="File /megazero_miner assente"
  })
else
  report("PREPARAZIONE",{detail="Startup operativo; avvio miner in corso"})
end

local function heartbeat()
  while true do
    local okHeartbeat,why=pcall(function()
      agent:heartbeat()
    end)
    if not okHeartbeat then
      printError("Errore heartbeat: "..tostring(why))
    end
    sleep(5)
  end
end

local function setErrorLatch(errorText)
  local f=fs.open(ERROR_LATCH,"w")
  if f then
    f.write(tostring(errorText))
    f.close()
  end
end

local function runMiner()
  local file=fs.exists(MINER) and MINER or (MINER..".lua")
  local okLoad,miningEntry=pcall(dofile,file)
  if not okLoad or type(miningEntry)~="function" then
    local errorText="Miner non valido: deve restituire function(agent,config)"
    if not okLoad then errorText=errorText.."; "..tostring(miningEntry) end
    setErrorLatch(errorText)
    report("ERRORE",{error=errorText,detail="Miner non avviato"})
    printError(errorText)
    return
  end

  -- Lo stesso agente telemetrico e' usato dal programma minerario:
  -- gli heartbeat ripetono lo stato reale inviato dal miner.
  local okMine,why=pcall(miningEntry,agent,cfg)
  if not okMine then
    local errorText=tostring(why)
    setErrorLatch(errorText)
    report("ERRORE",{
      detail="Miner terminato con errore; STOP fino a verifica",
      error=errorText
    })
    printError("MINER FERMO: "..errorText)
    -- Non eseguire tentativi di rientro improvvisati nel boot:
    -- il miner definitivo deve gestire rientro/coordinate/percorso.
  else
    print("Programma minerario terminato.")
    -- Il miner deve comunicare il proprio stato finale in autonomia.
    -- Non dichiarare 'ALLA BASE' senza averne verificato la posizione.
  end
end

if minerRequested and minerPresent and not latched then
  print("MINER: avvio automatico abilitato")
  parallel.waitForAll(heartbeat,runMiner)
else
  print("MINER: non avviato | telemetria continua")
  heartbeat()
end
