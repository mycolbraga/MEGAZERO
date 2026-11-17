-- MEGAZERO / PC54 | Diagnosi collettiva 40 turtle, SOLA LETTURA.
-- Usa il registro della dashboard: non invia comandi e non muove Turtle.
assert(not turtle and os.getComputerID()==54,
 "Esegui SOLO sulla centrale PC54")
local args={...}
local full=args[1]=="tutti"
local f=assert(fs.open("/.megazero_control_db","r"),
 "Registro PC54 non disponibile")
local raw=f.readAll();f.close()
local db=assert(textutils.unserialize(raw),"Registro centrale illeggibile")
assert(type(db.units)=="table","Registro unita non presente")
local function tidy(s)
 return tostring(s or ""):gsub("[%c]+"," "):gsub("%s+"," ")
end
local categories={
 "REGULATOR/SLOT 1","SECCHI/LAVA","USCITA BASE","FROGLIGHT",
 "ACQUA/FLUIDI","CHECKPOINT/GPS","CARBURANTE",
 "RIENTRO","ALTRO","NESSUN DETTAGLIO"
}
local function reasonType(msg)
 local s=msg:lower()
 if s=="" then return "NESSUN DETTAGLIO" end
 if s:find("regulator",1,true) or s:find("slot 1",1,true) or
    s:find("portare il secchio",1,true) or
    s:find("spostare lava",1,true) then return "REGULATOR/SLOT 1" end
 if s:find("secchi",1,true) or s:find("lava_bucket",1,true) or
    s:find("prelievo",1,true) then return "SECCHI/LAVA" end
 if s:find("uscita dalla base",1,true) or
    s:find("uscita ostruita",1,true) then return "USCITA BASE" end
 if s:find("froglight",1,true) then return "FROGLIGHT" end
 if s:find("acqua",1,true) or s:find("fluido",1,true) or
    s:find("corrente",1,true) or s:find("lago",1,true) then
    return "ACQUA/FLUIDI" end
 if s:find("checkpoint",1,true) or s:find("posizione",1,true) or
    s:find("gps",1,true) or s:find("pending",1,true) then
    return "CHECKPOINT/GPS" end
 if s:find("carburante",1,true) or s:find("fuel",1,true) then
    return "CARBURANTE" end
 if s:find("rientro",1,true) then return "RIENTRO" end
 return "ALTRO"
end
local groups,errors={},{}
local statusCount={}
for _,side in ipairs({"N","O","S","E"}) do
 for n=1,10 do
  local unit=side..string.format("%02d",n)
  local rec=db.units["MINIERA-01|"..unit] or {}
  local state=tostring(rec.status or "NON REGISTRATA")
  statusCount[state]=(statusCount[state] or 0)+1
  if state=="ERRORE" then
   local msg=tidy(rec.error or rec.detail)
   local group=reasonType(msg)
   groups[group]=groups[group] or {}
   local row={unit=unit,pc=rec.sender or "?",message=msg,
    progress=rec.progress}
   table.insert(groups[group],row)
   table.insert(errors,row)
  end
 end
end
print("MEGAZERO / DIAGNOSI PC54 (SOLA LETTURA)")
for _,st in ipairs({"SCAVO","RIENTRO","ERRORE","BASE","PREPARAZIONE"}) do
 print(st..": "..tostring(statusCount[st] or 0))
end
print("ERRORI TOTALI: "..#errors)
for _,category in ipairs(categories) do
 local entries=groups[category]
 if entries and #entries>0 then
  local names={}
  for _,item in ipairs(entries) do names[#names+1]=item.unit end
  print("")
  print(category.." ("..#entries.."): "..table.concat(names,","))
  local example=entries[1].message
  if example=="" then example="Nessun testo registrato" end
  print("  Esempio "..entries[1].unit..": "..example:sub(1,180))
 end
end
if full then
 print("")
 print("DETTAGLI TUTTE LE TURTLE IN ERRORE:")
 for _,item in ipairs(errors) do
  print(item.unit.." PC"..tostring(item.pc)..": "..
   (item.message~="" and item.message or "Non registrato"))
 end
end
print("")
print("NESSUN COMANDO INVIATO. CHECKPOINT INVARIATI.")
print("Per dettaglio completo: stesso comando con 'tutti'.")
