-- MEGAZERO | Installazione avvio automatico Turtle v1.0
-- Esempio: wget run <URL_DI_QUESTO_FILE> N01
-- Operazione locale unica: registra la sigla, scarica il launcher,
-- crea startup.lua SOLO se assente, poi riavvia automaticamente.
-- Nessun movimento, scavo o modifica del vecchio programma minerario.

local args={...}
local unit=args[1]
local site=args[2] or "MINIERA-01"

local face,number
if type(unit)=="string" then
  face,number=unit:match("^([NOSE])(%d%d)$")
end
number=tonumber(number)
if not face or not number or number<1 or number>10 then
  printError("Sigla errata: N01..N10, O01..O10, S01..S10, E01..E10")
  return
end
if type(site)~="string" or site=="" or #site>30
    or site:find("|",1,true) then
  printError("Nome sito non valido")
  return
end
if not turtle then
  printError("Installatore da usare su una Turtle, non sul computer 54")
  return
end

-- Non sovrascrivere installazioni precedenti o altri programmi startup.
for _,p in ipairs({
  "/startup", "/startup.lua", "/megazero_boot",
  "/megazero_boot.lua", "/megazero_config"
}) do
  if fs.exists(p) then
    printError("File gia' presente: "..p)
    print("Nessuna modifica. Verificare prima di sostituire uno startup.")
    return
  end
end
local modem=peripheral.find("modem",function(_,m)
  return m.isWireless and m.isWireless()
end)
if not modem then
  printError("Ender/Wireless Modem non rilevato: installazione annullata")
  return
end

local BASE="https://raw.githubusercontent.com/mycolbraga/MEGAZERO/registro/megazero/scripts/turtle/"
local function fetch(path,signature)
  local response,reason=http.get(BASE..path)
  if not response then
    error("Download "..path..": "..tostring(reason),0)
  end
  local body=response.readAll()
  response.close()
  if type(body)~="string" or body:sub(1,#signature)~=signature then
    error("File "..path.." non valido. Nessuna installazione.",0)
  end
  return body
end

print("MEGAZERO | startup definitivo "..site.."/"..unit)
local ok,boot=pcall(fetch,"megazero_boot.lua","-- MEGAZERO BOOT 1.0")
if not ok then printError(boot);return end

local moduleExists=fs.exists("/megazero_rete")
  or fs.exists("/megazero_rete.lua")
local moduleSource
if not moduleExists then
  local okModule,body=pcall(fetch,
    "megazero_rete.lua","-- MEGAZERO | Telemetria Turtle v1.0")
  if not okModule then printError(body);return end
  moduleSource=body
end

local function writeNew(path,body)
  if fs.exists(path) then
    error("Conflitto sul file "..path.."; non sovrascrivo",0)
  end
  local file,reason=fs.open(path,"w")
  if not file then
    error("Non posso scrivere "..path..": "..tostring(reason),0)
  end
  file.write(body)
  file.close()
end

-- Scrive startup.lua per ultimo: finche' non esiste, nessun boot parziale.
local installed,why=pcall(function()
  if moduleSource then
    writeNew("/megazero_rete",moduleSource)
  end
  writeNew("/megazero_boot",boot)
  writeNew("/megazero_config",textutils.serialize({
    unit=unit,
    site=site,
    central=54,
    miner_autostart=false,
  }))
  writeNew("/startup.lua",'shell.run("/megazero_boot")\n')
end)
if not installed then
  printError("INSTALLAZIONE INCOMPLETA: "..tostring(why))
  print("Non riavvio. Controllare i file prima di riprovare.")
  return
end

print("Startup creato. Sigla: "..unit.." | Sito: "..site)
print("Al reboot: rete attiva; SCAVO DISABILITATO.")
print("Il boot supportera' il miner futuro SENZA cambiare startup.")
print("Riavvio automatico tra 2 secondi...")
sleep(2)
os.reboot()
