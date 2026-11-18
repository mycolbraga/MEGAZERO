-- MEGAZERO | N02 PC14 | RIASSUNTO COPIE CHECKPOINT | SOLO LETTURA
-- Nessun movimento, nessuna modifica.
assert(turtle and os.getComputerID()==14,"Solo N02 PC14")
local f=assert(fs.open("/megazero_config","r"),"Config mancante")
local cfg=assert(textutils.unserialize(f.readAll()),"Config non leggibile")
f.close()
assert(cfg.site=="MINIERA-01" and cfg.unit=="N02","Config non N02")
local gx,gy,gz=gps.locate(4,false)
assert(type(gx)=="number" and type(gy)=="number" and type(gz)=="number",
 "GPS assente")
local function read(p)
 local h=fs.open(p,"r");if not h then return nil end
 local s=h.readAll();h.close();return s
end
local function analyze(p)
 local raw=read(p)
 if not raw then return nil end
 local ok,cp=pcall(textutils.unserialize,raw)
 if not ok or type(cp)~="table" or type(cp.path)~="table" or
  type(cp.x)~="number" or type(cp.y)~="number" or
  type(cp.z)~="number" or type(cp.d)~="number" then return nil end
 return {p=p,cp=cp,len=#raw,n=#cp.path,
  match=math.abs(cp.x-gx)<0.25 and
  math.abs(cp.y-gy)<0.25 and math.abs(cp.z-gz)<0.25}
end
local original="/.megazero_miner_v23_N02_LAVORO"
local active=analyze(original)
local candidates={}
for _,name in ipairs(fs.list("/")) do
 local p="/"..name
 if fs.isDir(p) and
  (name:find("^%.megazero_ota2316_backup_N02_") or
   name:find("^%.megazero_ota2316_saved%d*_N02_")) then
  local q=analyze(p.."/checkpoint")
  if q then candidates[#candidates+1]=q end
 end
end
table.sort(candidates,function(a,b)return a.p<b.p end)
local matches,nonempty=0,0
for _,q in ipairs(candidates) do
 if q.match then matches=matches+1 end
 if q.n>0 then nonempty=nonempty+1 end
end
print("N02 PC14 | CHECKPOINT | SOLO LETTURA")
print("GPS: "..gx..","..gy..","..gz)
print("LIBERI: "..tostring(fs.getFreeSpace("/")).." B")
print("ORIGINALE: "..(active and ("VALIDO path="..active.n..
 " pending="..tostring(active.cp.pending)) or "NON LEGGIBILE"))
print("BACKUP VALIDI: "..#candidates)
print("BACKUP GPS CORRISPONDENTE: "..matches)
print("BACKUP CON PERCORSO: "..nonempty)
for i,q in ipairs(candidates) do
 if q.n>0 or q.match then
  print("COPIA "..i..": "..q.cp.x..","..q.cp.y..","..q.cp.z..
   " path="..q.n.." pend="..tostring(q.cp.pending)..
   " GPSmatch="..tostring(q.match))
 end
end
print("FINE | NESSUN MOVIMENTO / FILE MODIFICATO")
