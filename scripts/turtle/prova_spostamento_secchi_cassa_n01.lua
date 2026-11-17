-- MEGAZERO | Test mirato slot della cassa N01 (NON muove Turtle, NON avvia scavo)
-- Tentativo: muove UN secchio vuoto in uno slot libero e lo restituisce.
-- Se pushItems non funziona, nessun oggetto viene prelevato o consumato.
assert(turtle,"Solo su Turtle")
local f=assert(fs.open("/megazero_config","r"))
local cfg=assert(textutils.unserialize(f.readAll()));f.close()
assert(cfg.site=="MINIERA-01" and cfg.unit=="N01","Solo N01")
local ch=assert(peripheral.wrap("top"),"Cassa superiore non disponibile")
assert(type(ch.list)=="function" and type(ch.size)=="function" and
 type(ch.pushItems)=="function","Cassa non espone pushItems")
local name=assert(peripheral.getName(ch),"Nome periferica non trovato")
local items=assert(ch.list(),"Cassa illeggibile")
local bucket
for i=1,ch.size() do
 local it=items[i]
 if it and it.name=="minecraft:bucket" and it.count>=2 then
  bucket=i;break
 end
end
assert(bucket,"Servono almeno 2 secchi vuoti nello stesso slot (regulator)")
local free
for i=ch.size(),1,-1 do if not items[i] then free=i;break end end
assert(free and free~=bucket,"Cassa senza slot vuoto per il test")
print("N01 | TEST SOLO CASSA SUPERIORE")
print("Periferica: "..name)
print("Slot "..bucket.." = "..items[bucket].count.." secchi vuoti")
print("Slot libero scelto: "..free)
print("Sposto soltanto 1 secchio: "..bucket.." -> "..free)
local ok,moved=pcall(function()
 return ch.pushItems(name,bucket,1,free)
end)
print("PUSH: "..(ok and tostring(moved) or ("ERRORE: "..tostring(moved))))
local after=ch.list()
local isMoved=after[free] and after[free].name=="minecraft:bucket" and
 after[free].count>=1
if not isMoved then
 print("NON trasferito; nessun altro tentativo.")
 print("Nessun movimento Turtle, nessun refuel, nessun reboot.")
 return
end
print("Ripristino: "..free.." -> "..bucket)
local okBack,back=pcall(function()
 return ch.pushItems(name,free,1,bucket)
end)
print("RITORNO: "..(okBack and tostring(back) or ("ERRORE: "..tostring(back))))
local final=ch.list()
local original=final[bucket]
if okBack and back==1 and original and original.name=="minecraft:bucket" and
 original.count==items[bucket].count then
 print("OK: 1 secchio spostato e RIPORTATO nella posizione originale.")
else
 printError("Attenzione: un secchio puo' essere rimasto nello slot "..free)
 print("Non e' stato perso: controllare la cassa.")
end
print("Turtle non mossa e configurazione non modificata.")
