-- MEGAZERO N02 PC14 | TROVA CHECKPOINT VALIDI | SOLO LETTURA
-- Diagnosi dalla Turtle, non muove e non modifica file.
assert(turtle and os.getComputerID()==14,"SOLO N02 PC14")
local function read(p)
 local f=fs.open(p,"r");if not f then return nil end
 local data=f.readAll();f.close();return data
end
local config=assert(textutils.unserialize(assert(read("/megazero_config"),"Config mancante")),"Config corrotta")
assert(config.unit=="N02" and config.site=="MINIERA-01","Identita' errata")
local function info(path)
 if not fs.exists(path) or fs.isDir(path) then return "ASSENTE" end
 local data=read(path)
 if not data then return "NON LEGGIBILE" end
 local ok,cp=pcall(textutils.unserialize,data)
 if not ok or type(cp)~="table" or
  type(cp.path)~="table" or
  type(cp.x)~="number" or type(cp.y)~="number" or type(cp.z)~="number" then
  return "DANNEGGIATO ("..#data.." byte)"
 end
 local last=cp.path[#cp.path]
 return "VALIDO "..#data.."B pos="..cp.x..","..cp.y..","..cp.z..
  " dir="..tostring(cp.d).." path="..#cp.path..
  " pending="..tostring(cp.pending)..
  " liv="..tostring(cp.level).." dist="..tostring(cp.distance)..
  " last="..tostring(last and last.m or "-")
end
print("N02 PC14 | SOLO LETTURA | GPS / CHECKPOINT")
local x,y,z=gps.locate(4,false)
print("GPS="..tostring(x)..","..tostring(y)..","..tostring(z))
print("LIBERI="..tostring(fs.getFreeSpace("/")))
local original="/.megazero_miner_v23_N02_LAVORO"
print("ORIGINALE: "..info(original))
local candidates={}
for _,name in ipairs(fs.list("/")) do
 local p="/"..name
 if fs.isDir(p) and (name:find("^%.megazero_ota2316_backup_N02_") or
  name:find("^%.megazero_ota2316_saved")) then
  if fs.exists(p.."/checkpoint") then
   candidates[#candidates+1]=p.."/checkpoint"
  end
 elseif name:find("megazero") and
  (name:find("checkpoint") or name:find("miner_v23_")) and p~=original and
  not fs.isDir(p) then
  candidates[#candidates+1]=p
 end
end
table.sort(candidates)
print("COPIE TROVATE: "..#candidates)
for i,p in ipairs(candidates) do
 local label=p:match("N02_(%x+)/checkpoint") or
  p:match("saved_N02_(%x+)/checkpoint") or p:sub(-12)
 print(i.." ["..label:sub(1,10).."] "..info(p))
end
print("FINE: SOLA LETTURA")
