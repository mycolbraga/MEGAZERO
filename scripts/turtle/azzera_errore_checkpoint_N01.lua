-- MEGAZERO | N01: archivia vecchio errore e checkpoint dopo riposizionamento manuale.
-- Non muove la Turtle, non tocca miner/autostart/startup. Solo PC 12.
assert(turtle and os.getComputerID()==12,"Solo N01 PC 12")
local f=assert(fs.open("/megazero_config","r"),"Config N01 mancante")
local cfg=assert(textutils.unserialize(f.readAll()),"Config non valida")
f.close()
assert(cfg.site=="MINIERA-01" and cfg.unit=="N01" and
 cfg.miner_autostart==false,"N01 non ferma/autostart attivo: STOP")
local miner=fs.exists("/megazero_miner") and "/megazero_miner" or "/megazero_miner.lua"
local fm=assert(fs.open(miner,"r"),"Miner non installato")
local header=fm.readLine() or ""
fm.close()
assert(header:find("^%-%- MEGAZERO MINER v2%.3%.5"),
 "Miner non v2.3.5: STOP")
local items={
 {"/.megazero_miner_error","/.megazero_N01_reset_error_archivio"},
 {"/.megazero_miner_v23_N01_LAVORO","/.megazero_N01_reset_checkpoint_archivio"}
}
for _,item in ipairs(items) do
 if fs.exists(item[1]) then
  assert(not fs.exists(item[2]),
   "Archivio gia' presente: "..item[2].."; STOP")
 end
end
for _,item in ipairs(items) do
 if fs.exists(item[1]) then
  fs.copy(item[1],item[2])
  assert(fs.exists(item[2]) and fs.getSize(item[2])==fs.getSize(item[1]),
   "Archivio non verificato: "..item[1].."; STOP")
  fs.delete(item[1])
  print("ARCHIVIATO: "..item[1])
 else print("ASSENTE (OK): "..item[1]) end
end
print("N01 pulita per partenza da ZERO.")
print("Miner v2.3.5 INALTERATO; avvio automatico DISATTIVO.")
print("Nessun movimento/scavo. Ora installare agente admin.")
