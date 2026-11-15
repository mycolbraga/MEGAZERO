-- MEGAZERO - Installatore telemetria Turtle (non distruttivo)
-- Uso: wget run <URL_DI_QUESTO_FILE> N02
-- Installa il modulo e avvia il test, senza muovere la turtle.
-- Non modifica programmi di scavo, startup, label o inventario.

local args = {...}
local unit = args[1]
local site = args[2] or "MINIERA-01"

local front, n = type(unit) == "string" and unit:match("^([NOSE])(%d%d)$")
n = tonumber(n)
if not front or not n or n < 1 or n > 10 then
  printError("Sigla non valida. Usa N01..N10, O01..O10, S01..S10 o E01..E10.")
  return
end
if type(site) ~= "string" or site == "" or #site > 30 or site:find("|", 1, true) then
  printError("Nome sito non valido")
  return
end
if not turtle then
  printError("Questo programma va eseguito su una Turtle.")
  return
end
local final = "/megazero_rete"
if fs.exists(final) or fs.exists(final .. ".lua") then
  printError("File megazero_rete gia' presente: non sovrascrivo.")
  print("Puoi avviare il modulo esistente con: megazero_rete " .. unit)
  return
end
local modem = peripheral.find("modem", function(_, m)
  return m.isWireless and m.isWireless()
end)
if not modem then
  printError("Nessun modem wireless/Ender Modem riconosciuto.")
  return
end

local url = "https://raw.githubusercontent.com/mycolbraga/MEGAZERO/registro/megazero/scripts/turtle/megazero_rete.lua"
print("MEGAZERO | installo telemetria " .. site .. "/" .. unit)
print("Scarico il modulo...")
local response, err = http.get(url)
if not response then
  printError("Download non riuscito: " .. tostring(err))
  return
end
local body = response.readAll()
response.close()
if type(body) ~= "string"
    or body:sub(1, #"-- MEGAZERO | Telemetria Turtle v1.0")
      ~= "-- MEGAZERO | Telemetria Turtle v1.0" then
  printError("Risposta inattesa dal repository. Nessun file installato.")
  return
end
local temp = "/.megazero_rete_download"
if fs.exists(temp) then
  printError("Esiste il file temporaneo " .. temp .. ": non lo sovrascrivo.")
  return
end
local file, reason = fs.open(temp, "w")
if not file then
  printError("Impossibile salvare il modulo: " .. tostring(reason))
  return
end
file.write(body)
file.close()
fs.move(temp, final)
print("Installato: " .. final)
print("Test rete: nessun movimento e nessuno scavo.")
print("Ctrl+T interrompe il test. Il file rimane installato.")
shell.run(final, unit, site)
