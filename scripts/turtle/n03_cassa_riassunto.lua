-- N03 PC15: sintesi cassa superiore, SOLO LETTURA
assert(turtle and os.getComputerID()==15,"Solo N03 PC15")
local f=assert(fs.open("/megazero_config","r"))
local cfg=assert(textutils.unserialize(f.readAll()))
f.close()
assert(cfg.unit=="N03" and cfg.site=="MINIERA-01","Configurazione errata")
local c=assert(peripheral.wrap("top"),"Cassa sopra assente")
local a=assert(c.list(),"Cassa non leggibile")
local buckets,lava,others,free={}, {}, {}, {}
for i=1,c.size() do
 local v=a[i]
 if not v then free[#free+1]=i
 elseif v.name=="minecraft:bucket" then buckets[#buckets+1]=i.."("..v.count..")"
 elseif v.name=="minecraft:lava_bucket" then lava[#lava+1]=i.."("..v.count..")"
 else others[#others+1]=i..":"..v.count.."x"..v.name end
end
local one=a[1]
print("N03 PC15 CASSA SOPRA | SOLO LETTURA")
print("SLOT 1: "..(one and one.count.."x"..one.name or "VUOTO"))
print("SECCHI VUOTI slot(qta): "..(#buckets>0 and table.concat(buckets,", ") or "NESSUNO"))
print("LAVA slot(qta): "..(#lava>0 and table.concat(lava,", ") or "NESSUNA"))
print("SLOT LIBERI: "..#free.." | "..table.concat(free,", "))
print("ALTRI TIPI: "..#others)
for i,v in ipairs(others) do if i<=3 then print(v) end end
print("NESSUN OGGETTO SPOSTATO")
