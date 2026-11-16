-- MEGAZERO | Gestione avvio automatico PER SINGOLA Turtle
-- Uso da shell: megazero_auto stato | attiva | disattiva
-- Non riavvia e non avvia lo scavo: cambia solo /megazero_config.
local args={...}
local cmd=args[1] or "stato"
assert(cmd=="stato" or cmd=="attiva" or cmd=="disattiva",
 "Uso: megazero_auto stato | attiva | disattiva")
assert(turtle,"Da eseguire direttamente sulla Turtle")
local path="/megazero_config"
local f=assert(fs.open(path,"r"),"Configurazione MEGAZERO mancante")
local cfg=assert(textutils.unserialize(f.readAll()),"Configurazione non valida")
f.close()
assert(type(cfg)=="table" and cfg.site=="MINIERA-01" and
 type(cfg.unit)=="string" and cfg.unit:match("^[NOSE]%d%d$"),
 "Identificativo Turtle o miniera non validi")
if cmd=="stato" then
 print(cfg.unit.." | avvio miner: "..(cfg.miner_autostart and "ATTIVO" or "DISATTIVO"))
 return
end
if cmd=="attiva" then
 assert(not fs.exists("/.megazero_miner_error"),
  "Errore miner presente: risolverlo prima dell'avvio")
 for _,file in ipairs({"/megazero_boot","/megazero_rete","/megazero_fluidi","/megazero_miner"}) do
  assert(fs.exists(file) or fs.exists(file..".lua"),"Modulo mancante: "..file)
 end
 local minerPath=fs.exists("/megazero_miner") and "/megazero_miner" or "/megazero_miner.lua"
 local m=assert(fs.open(minerPath,"r"))
 local header=m.readLine() or ""
 m.close()
 assert(header:find("^%-%- MEGAZERO MINER v2%.3%.2"),
  "Miner non v2.3.2: aggiornare prima di attivare l'avvio automatico")
end
cfg.miner_autostart=(cmd=="attiva")
local temp=path..".tmp_auto"
assert(not fs.exists(temp),"Configurazione temporanea gia' esistente: verificare")
local w=assert(fs.open(temp,"w"))
w.write(textutils.serialize(cfg))
w.close()
local bak=path..".bak_auto"
if fs.exists(bak) then fs.delete(bak) end
fs.copy(path,bak)
fs.delete(path)
fs.move(temp,path)
print(cfg.unit.." | avvio miner al reboot: "..(cfg.miner_autostart and "ATTIVO" or "DISATTIVO"))
print("Configurazione precedente salvata in "..bak)
print("Nessun movimento avviato; nessun reboot eseguito.")
