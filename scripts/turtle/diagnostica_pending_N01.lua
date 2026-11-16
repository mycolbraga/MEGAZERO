-- MEGAZERO | Diagnostica N01 checkpoint v23. SOLA LETTURA, NESSUN MOVIMENTO.
assert(turtle, "Richiede una Turtle")
local cf=assert(fs.open("/megazero_config","r"),"Config mancante")
local cfg=assert(textutils.unserialize(cf.readAll()),"Config non valida")
cf.close()
assert(cfg.unit=="N01" and cfg.site=="MINIERA-01","Solo N01")
local path="/.megazero_miner_v23_N01_LAVORO"
local f=assert(fs.open(path,"r"),"Checkpoint non trovato")
local raw=f.readAll();f.close()
local cp=assert(textutils.unserialize(raw),"Checkpoint non valido")
assert(type(cp)=="table","Checkpoint non tabella")
print("=== DIAGNOSTICA N01, SOLA LETTURA ===")
print("PENDING: "..tostring(cp.pending))
print("POS SALVATA: "..tostring(cp.x)..","..tostring(cp.y)..","..tostring(cp.z))
print("DIREZIONE SALVATA (0=N,1=E,2=S,3=O): "..tostring(cp.d))
print("LIVELLO: "..tostring(cp.level).." | DISTANZA: "..tostring(cp.distance))
print("TRACCIA: "..(type(cp.path)=="table" and #cp.path or -1).." passi")
local last=type(cp.path)=="table" and cp.path[#cp.path] or nil
if last then
 print("ULTIMO PASSO: "..tostring(last.m).." | direzione "..tostring(last.d))
else print("ULTIMO PASSO: nessuno") end
local latch=fs.exists("/.megazero_miner_error")
print("ERRORE LATCH: "..(latch and "SI" or "NO"))
print("NON MUOVERE N01: dati solo informativi.")
