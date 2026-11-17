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
  local state= gps==cp and "GPS=CP" or "GPS!=CP"
  print(("%s PC%s | %s | pend=%s | d=%s | passi=%s"):format(unit,pc,state,pending,dir,steps))
  print(("  GPS %s  |  CP %s  | liv %s dist %s"):format(gps,cp,lev,dist))
 end
end
f.close()
print("Righe non-HOME: "..n)
print("SOLO LETTURA: nessun movimento, reset o avvio.")
