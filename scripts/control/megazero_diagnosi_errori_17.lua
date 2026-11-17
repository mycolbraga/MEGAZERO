-- MEGAZERO PC54 | DIAGNOSI PASSIVA ERRORI MINIERA-01
-- Legge solo il registro locale della centrale. Non invia comandi.
assert(not turtle and os.getComputerID()==54,"Eseguire SOLO sulla centrale PC54")
local path="/.megazero_control_db"
local f=assert(fs.open(path,"r"),"Database centrale non presente")
local raw=f.readAll();f.close()
local db=assert(textutils.unserialize(raw),"Database centrale illeggibile")
assert(type(db.units)=="table","Elenco unita' mancante")
local t=os.epoch("utc")
local errors,states={},{}
local function text(v)
 if type(v)~="string" or v=="" then return "-" end
 return v:gsub("[\r\n]"," "):sub(1,190)
end
for _,side in ipairs({"N","O","S","E"}) do
 for n=1,10 do
  local unit=side..string.format("%02d",n)
  local r=db.units["MINIERA-01|"..unit]
  if type(r)=="table" then
   local status=tostring(r.status or "SCONOSCIUTO")
   states[status]=(states[status] or 0)+1
   if status=="ERRORE" or r.error and r.error~="" then
    errors[#errors+1]={unit=unit,r=r}
   end
  else states["NON REGISTRATA"]=(states["NON REGISTRATA"] or 0)+1 end
 end
end
print("MEGAZERO | PC54 | DIAGNOSI PASSIVA")
print("Nessun comando alle Turtle, nessun movimento.")
print("STATO DATABASE:")
for _,key in ipairs({"SCAVO","RIENTRO","BASE","PREPARAZIONE","ERRORE","BLOCCATO","PAUSA","INCOMPLETO","NON REGISTRATA"}) do
 if states[key] then print("  "..key..": "..states[key]) end
end
print("ERRORI REGISTRATI: "..#errors)
for _,item in ipairs(errors) do
 local r=item.r
 local age=r.lastSeen and math.max(0,math.floor((t-r.lastSeen)/1000)) or nil
 print("")
 print(item.unit.." | PC"..tostring(r.sender or "?")..
  " | "..tostring(r.status or "?").." | ultimo contatto "..
  (age and age.."s fa" or "mai"))
 print("  CAUSA: "..text(r.error))
 print("  DETTAGLIO: "..text(r.detail))
 local pos=r.position
 if type(pos)=="table" then print("  POS: "..tostring(pos.x)..","..
  tostring(pos.y)..","..tostring(pos.z)) end
 print("  FUEL: "..tostring(r.fuel or "?")..
  " | AVANZAMENTO: "..tostring(r.progress or "?"))
end
print("")
print("FINE DIAGNOSI: nessuna Turtle modificata.")
