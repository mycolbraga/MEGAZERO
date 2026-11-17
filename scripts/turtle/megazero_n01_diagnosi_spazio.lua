-- MEGAZERO | DIAGNOSI SPAZIO N01 | SOLO LETTURA
-- Non elimina, non scarica file, non muove la Turtle.
assert(turtle and os.getComputerID()==1 or turtle,
 "Eseguire sulla Turtle N01")
local f=fs.open("/megazero_config","r")
assert(f,"Configurazione assente")
local cfg=textutils.unserialize(f.readAll());f.close()
assert(type(cfg)=="table" and cfg.unit=="N01" and
 cfg.site=="MINIERA-01","Questo controllo e' solo per N01")
assert(cfg.miner_autostart==false,
 "Autostart attivo: non intervenire")
local function size(path,depth)
 if depth>8 then return 0 end
 if not fs.exists(path) then return 0 end
 if not fs.isDir(path) then return fs.getSize(path) end
 local n=0
 for _,entry in ipairs(fs.list(path)) do
  n=n+size(fs.combine(path,entry),depth+1)
 end
 return n
end
local function head(path)
 local r=fs.open(path,"r")
 if not r then return "-" end
 local h=r.readLine();r.close();return h or "-"
end
print("N01 | DIAGNOSI OTA FALLITA - SOLA LETTURA")
print("Spazio disponibile: "..tostring(fs.getFreeSpace("/")))
print("Miner: "..head("/megazero_miner"))
print("Agente: "..head("/megazero_admin_agent"))
local marker="/.megazero_ota2316_state"
print("Marker OTA: "..(fs.exists(marker) and "PRESENTE" or "assente"))
if fs.exists(marker) then
 local m=fs.open(marker,"r")
 local ok,v=pcall(textutils.unserialize,m.readAll());m.close()
 print("Release stage: "..(ok and type(v)=="table" and
 tostring(v.release) or "NON LEGGIBILE"))
end
local items={}
for _,name in ipairs(fs.list("/")) do
 if name:find("megazero_ota",1,true) or
    name:find("megazero_stage",1,true) or
    name:find("megazero_recupero_backup",1,true) or
    name:find("megazero_reset",1,true) then
  local path="/"..name
  items[#items+1]={path=path,bytes=size(path,0)}
 end
end
table.sort(items,function(a,b)return a.bytes>b.bytes end)
print("Archivi/staging individuati: "..#items)
for i,v in ipairs(items) do
 print(v.path.." | "..v.bytes.." byte")
end
print("NESSUN FILE MODIFICATO; NESSUN MOVIMENTO")
