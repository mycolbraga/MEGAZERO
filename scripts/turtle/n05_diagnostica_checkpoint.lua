-- MEGAZERO N05 | DIAGNOSTICA SOLA LETTURA - NO SCAVO / MOVIMENTO
assert(turtle and os.getComputerID()==17,"Solo N05 (PC 17)")
local function read(p)
 if not fs.exists(p) then return nil end
 local f=assert(fs.open(p,"r"),"Impossibile leggere "..p)
 local s=f.readAll();f.close()
 return s
end
local cfg=assert(textutils.unserialize(read("/megazero_config") or ""),"Config illeggibile")
assert(cfg.site=="MINIERA-01" and cfg.unit=="N05","Questa non e' N05")
print("=== N05 DIAGNOSTICA | NESSUN MOVIMENTO ===")
print("Autostart: "..tostring(cfg.miner_autostart))
print("Fuel: "..tostring(turtle.getFuelLevel()))
local errorText=read("/.megazero_miner_error")
print("Errore salvato: "..tostring(errorText or "nessuno"))
local cp="/.megazero_miner_v23_N05_LAVORO"
local raw=read(cp)
print("Checkpoint: "..(raw and "PRESENTE" or "ASSENTE"))
if raw then
 local ok,s=pcall(textutils.unserialize,raw)
 if not ok or type(s)~="table" then
  print("CHECKPOINT NON DECODIFICABILE")
 else
  print("POS salvata: "..tostring(s.x)..","..tostring(s.y)..","..tostring(s.z))
  print("DIREZIONE (0=N 1=E 2=S 3=O): "..tostring(s.d))
  print("PENDING: "..tostring(s.pending))
  print("LIVELLO: "..tostring(s.level).." DISTANZA: "..tostring(s.distance))
  print("FINITO: "..tostring(s.finished))
  if type(s.path)=="table" then
   print("PASSI TRACCIATI: "..#s.path)
   for i=math.max(1,#s.path-3),#s.path do
    local p=s.path[i]
    if p then print(i..": "..tostring(p.m).." d="..tostring(p.d)) end
   end
  else print("TRACCIA NON VALIDA") end
 end
end
local other=fs.list("/")
for _,f in ipairs(other) do
 if f:find("megazero_miner_v23_N05",1,true) and "/"..f~=cp then
  print("Altro checkpoint: /"..f)
 end
end
local ok,x,y,z=pcall(gps.locate,3,false)
if ok and type(x)=="number" then
 print("GPS Turtle: "..x..","..y..","..z)
else print("GPS Turtle: NON DISPONIBILE") end
print("=== FINE | N05 NON MOSSA ===")
