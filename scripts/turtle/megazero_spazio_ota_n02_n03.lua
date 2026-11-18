-- MEGAZERO | N02/N03 | DIAGNOSI SPAZIO OTA | SOLO LETTURA
-- Non cancella alcun file, non modifica checkpoint e non muove la Turtle.
assert(turtle and (os.getComputerID()==14 or os.getComputerID()==15),
 "SOLO N02 PC14 oppure N03 PC15")
local f=assert(fs.open("/megazero_config","r"),"Config assente")
local cfg=assert(textutils.unserialize(f.readAll()),"Config illeggibile")
f.close()
local unit=assert(cfg.unit,"Unit mancante")
assert(cfg.site=="MINIERA-01" and
 ((unit=="N02" and os.getComputerID()==14) or
  (unit=="N03" and os.getComputerID()==15)),
 "Identita Turtle diversa: STOP")
local function readfirst(p)
 if not fs.exists(p) or fs.isDir(p) then return "MANCANTE" end
 local h=fs.open(p,"r")
 if not h then return "NON LEGGIBILE" end
 local line=h.readLine() or "VUOTO"
 h.close()
 return line
end
local function size(p)
 if not fs.exists(p) then return 0 end
 if not fs.isDir(p) then return fs.getSize(p) end
 local n=0
 for _,name in ipairs(fs.list(p)) do n=n+size(fs.combine(p,name)) end
 return n
end
local function showSpace()
 local free=fs.getFreeSpace("/")
 local used=size("/")
 local capacity=fs.getCapacity and fs.getCapacity("/") or nil
 print("USATI: "..used.." B | LIBERI: "..tostring(free).." B")
 if capacity then print("CAPACITA: "..tostring(capacity).." B") end
end
print("MEGAZERO | "..unit.." PC"..os.getComputerID().." | SPAZIO OTA")
print("SOLA LETTURA: nessuna modifica al filesystem")
print("AUTOSTART: "..tostring(cfg.miner_autostart))
print("MINER: "..readfirst("/megazero_miner"))
print("AGENTE: "..readfirst("/megazero_admin_agent"))
print("FLUIDI: "..readfirst("/megazero_fluidi"))
showSpace()
local files={}
for _,name in ipairs(fs.list("/")) do
 local full="/"..name
 local bytes=size(full)
 files[#files+1]={name=name,bytes=bytes,dir=fs.isDir(full)}
end
table.sort(files,function(a,b)
 if a.bytes==b.bytes then return a.name<b.name end
 return a.bytes>b.bytes
end)
print("12 ELEMENTI PIU' GRANDI IN ROOT:")
for i=1,math.min(12,#files) do
 local x=files[i]
 print(i..". "..x.bytes.." B "..(x.dir and "[DIR] " or "")..x.name)
end
print("BACKUP / STAGING:")
local seen=0
for _,x in ipairs(files) do
 if x.name:find("^%.megazero_ota2316_") or
    x.name:find("^%.megazero_stage_2316_") or
    x.name:find("^%.megazero_repair_") then
  print(x.bytes.." B "..(x.dir and "[DIR] " or "")..x.name)
  seen=seen+1
 end
end
if seen==0 then print("nessuno dei tipi controllati") end
print("MARKER OTA: "..tostring(fs.exists("/.megazero_ota2316_state")))
print("CHECKPOINT PRESENTE: "..tostring(fs.exists(
 "/.megazero_miner_v23_"..unit.."_LAVORO")))
print("FINE DIAGNOSI. NESSUN FILE ELIMINATO.")
