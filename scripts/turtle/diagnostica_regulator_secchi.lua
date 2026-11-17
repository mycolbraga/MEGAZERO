-- MEGAZERO | diagnostica SOLO LETTURA: cassa superiore e Turtle
-- Nessun movimento, download, refuel, prelievo o modifica al mondo.
assert(turtle,"Eseguire sulla Turtle N01")
local f=assert(fs.open("/megazero_config","r"))
local c=textutils.unserialize(f.readAll());f.close()
assert(type(c)=="table" and c.unit=="N01" and c.site=="MINIERA-01",
 "Diagnostica solo N01")
print("DIAGNOSTICA N01 | ZERO MODIFICHE")
print("Autostart: "..tostring(c.miner_autostart))
print("Fuel: "..tostring(turtle.getFuelLevel()).."/"..tostring(turtle.getFuelLimit()))
local chest=peripheral.wrap("top")
assert(chest and type(chest.list)=="function" and type(chest.size)=="function",
 "Cassa superiore non accessibile")
local items=chest.list()
local emptyCount,lavaCount,otherCount=0,0,0
local occupied={}
for s,item in pairs(items) do
 if item.name=="minecraft:bucket" then emptyCount=emptyCount+item.count
 elseif item.name=="minecraft:lava_bucket" then lavaCount=lavaCount+item.count
 else otherCount=otherCount+item.count end
 occupied[#occupied+1]={s=s,item=item}
end
table.sort(occupied,function(a,b)return a.s<b.s end)
print("CASSA TOP: "..chest.size().." slot | occupati "..#occupied)
print("SECCHI VUOTI="..emptyCount.." | LAVA="..lavaCount.." | ALTRO="..otherCount)
for i=1,math.min(#occupied,26) do
 local entry=occupied[i]
 local nm=entry.item.name=="minecraft:bucket" and "VUOTO" or
   (entry.item.name=="minecraft:lava_bucket" and "LAVA" or entry.item.name)
 print("CASSA "..entry.s..": "..entry.item.count.."x "..nm)
end
local busy,total=0,0
print("TURTLE:")
for i=1,16 do
 local item=turtle.getItemDetail(i)
 if item then
  busy=busy+1
  total=total+item.count
  print("  "..i..": "..item.count.."x "..item.name)
 end
end
print("TURTLE "..busy.."/16 slot occupati; oggetti "..total)
print("Nessuna modifica: premi Ctrl+T se serve e poi reboot.")
