-- MEGAZERO | Ispezione SOLA LETTURA del checkpoint di N01
-- NON muove, non cancella, non modifica configurazione o miner.
assert(turtle and os.getComputerID()==12,"Eseguire solo su N01 (PC 12)")
local cp="/.megazero_miner_v23_N01_LAVORO"
if not fs.exists(cp) then
 print("CHECKPOINT: ASSENTE")
 return
end
if fs.isDir(cp) then
 printError("CHECKPOINT inatteso: e' una cartella")
 return
end
local f=assert(fs.open(cp,"r"),"Impossibile leggere checkpoint")
local raw=f.readAll();f.close()
local ok,s=pcall(textutils.unserialize,raw)
if not ok or type(s)~="table" then
 printError("Checkpoint non leggibile; non e' stato modificato")
 return
end
print("N01 | CHECKPOINT SOLO LETTURA")
print("POS SALVATA: "..tostring(s.x)..","..tostring(s.y)..","..tostring(s.z))
print("DIREZIONE (0=N,1=E,2=S,3=O): "..tostring(s.d))
print("LIVELLO: "..tostring(s.level).." | DISTANZA: "..tostring(s.distance))
print("TRACCIA PASSI: "..tostring(type(s.path)=="table" and #s.path or "?"))
print("OPERAZIONE PENDENTE: "..tostring(s.pending))
print("COMPLETATO: "..tostring(s.finished))
local cf=fs.open("/megazero_config","r")
if cf then
 local rawCfg=cf.readAll();cf.close()
 local good,c=pcall(textutils.unserialize,rawCfg)
 print("AUTOSTART: "..tostring(good and type(c)=="table" and c.miner_autostart or false))
end
print("ERRORE LATCH: "..(fs.exists("/.megazero_miner_error") and "PRESENTE" or "ASSENTE"))
print("HOME FISICA CONFERMATA DALL'UTENTE: 2119,-51,2995 (NORD)")
print("NESSUN FILE MODIFICATO; NESSUN MOVIMENTO.")
