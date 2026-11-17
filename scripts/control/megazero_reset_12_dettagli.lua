-- MEGAZERO PC54 | 12 checkpoint pendenti: estratto rapporto GPS read-only
-- Legge unicamente il report gia creato. Nessuna rete, movimento o scrittura.
assert(not turtle and os.getComputerID()==54, "Eseguire solo su PC54")
local path="/megazero_reset_40_audit.txt"
assert(fs.exists(path), "Rapporto GPS non trovato: "..path)
local f=assert(fs.open(path,"r"))
print("MEGAZERO | TARTARUGHE FUORI HOME | CHECKPOINT vs GPS")
local n=0
while true do
 local line=f.readLine()
 if not line then break end
 local unit,pc,kind,gps,cp,dir,pending,steps,lev,dist=
  line:match("^([NOSE]%d%d) PC(%d+) | (.-) | GPS ([%d%-,.]+) | CP ([%d%-,.]+) | d=([%d%-]+) pend=(%S+) passi=(%S+) liv=(%S+) dist=(%S+)")
 if unit and kind~="HOME" then
  n=n+1
  local x,y,z=gps:match("^(-?%d+),(-?%d+),(-?%d+)$")
  local cx,cy,cz=cp:match("^(-?%d+),(-?%d+),(-?%d+)$")
  local delta="?"
  if x and cx then
   delta=("%+d,%+d,%+d"):format(x-cx,y-cy,z-cz)
  end
  print(("%s | pend=%s | d=%s | path=%s | GPS-CP %s"):format(unit,pending,dir,steps,delta))
 end
end
f.close()
print("Righe non-HOME: "..n)
print("SOLO LETTURA: nessun movimento, reset o avvio.")
