-- MEGAZERO N02 | Diagnostica SOLO LETTURA (nessun movimento)
-- Non cambia checkpoint, non accende miner, non esegue reboot.
assert(turtle and os.getComputerID()==14,"Questo controllo e' SOLO per N02 (PC14)")
local function read(p)
 if not fs.exists(p) then return nil end
 local f=fs.open(p,"r")
 if not f then return nil end
 local s=f.readAll();f.close();return s
end
local cfgRaw=read("/megazero_config")
local cfg=cfgRaw and textutils.unserialize(cfgRaw)
assert(type(cfg)=="table" and cfg.unit=="N02" and cfg.site=="MINIERA-01",
 "Configurazione inattesa: non e' N02")
print("=== N02 | NESSUNA MODIFICA ===")
print("Computer: "..os.getComputerID())
print("Autostart: "..tostring(cfg.miner_autostart))
print("Carburante: "..tostring(turtle.getFuelLevel()))
local err=read("/.megazero_miner_error")
print("Errore salvato: "..tostring(err or "nessuno"))
local cpPath="/.megazero_miner_v23_N02_LAVORO"
local cpRaw=read(cpPath)
print("Checkpoint "..cpPath..": "..(cpRaw and "PRESENTE" or "ASSENTE"))
if cpRaw then
 local ok,s=pcall(textutils.unserialize,cpRaw)
 if ok and type(s)=="table" then
  print("POS salvata: "..tostring(s.x)..","..tostring(s.y)..","..tostring(s.z))
  print("Direzione (0=N 1=E 2=S 3=O): "..tostring(s.d))
  print("PENDING: "..tostring(s.pending))
  print("Livello: "..tostring(s.level).." | Distanza: "..tostring(s.distance))
  print("Completato: "..tostring(s.finished))
  if type(s.path)=="table" then
   local n=#s.path
   print("PASSI TRACCIATI: "..n)
   for i=math.max(1,n-3),n do
    local p=s.path[i]
    if p then print("  "..i..": "..tostring(p.m).." d="..tostring(p.d)) end
   end
  else
   print("Percorso: DATI NON VALIDi")
  end
 else
  print("CHECKPOINT NON DECODIFICABILE")
 end
end
local names=fs.list("/")
for _,p in ipairs(names) do
 if p:find("megazero_miner_v23_N02",1,true) and
  ("/"..p)~=cpPath then print("Altro file checkpoint: /"..p) end
end
local okGPS,x,y,z=pcall(gps.locate,2,false)
if okGPS and type(x)=="number" then
 print("GPS Turtle: "..tostring(x)..","..tostring(y)..","..tostring(z))
else
 print("GPS Turtle: non disponibile (GPS passivo sulla centrale separato)")
end
print("=== FINE | N02 NON MOSSA ===")
