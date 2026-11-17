-- MEGAZERO PC54 | RAGGRUPPA 40 ERRORI PER CAUSA | SOLO LETTURA
-- Nessuna comunicazione alle Turtle. Non cambia checkpoint, programmi o stato.
assert(not turtle and os.getComputerID()==54,"Usare PC54")
local f=assert(fs.open("/.megazero_control_db","r"),"Database PC54 assente")
local raw=f.readAll();f.close()
local db=assert(textutils.unserialize(raw),"Database PC54 non leggibile")
assert(type(db.units)=="table","Elenco unit mancanti")
local groups={}
local statusCount={}
local function contains(s,needle)
 return type(s)=="string" and s:find(needle,1,true)~=nil
end
local function classify(e,d)
 local s=tostring(e or "").." | "..tostring(d or "")
 if contains(s,"SIGILLO_SU_CELLA_2X2:ACQUA") then return "SIGILLO ACQUA NELLA GALLERIA 2x2" end
 if contains(s,"SIGILLO_SU_CELLA_2X2:LAVA") then return "SIGILLO LAVA NELLA GALLERIA 2x2" end
 if contains(s,"Blocco non minerario sconosciuto: minecraft:water") then return "ACQUA TRATTATA COME BLOCCO" end
 if contains(s,"Blocco non minerario sconosciuto: minecraft:lava") then return "LAVA TRATTATA COME BLOCCO" end
 if contains(s,"GALLERIA_INCOMPLETA") then return "GALLERIA INCOMPLETA (ALTRA CAUSA)" end
 if contains(s,"SCORTE:") then return "SCORTE / RIFORNIMENTI" end
 if contains(s,"Blocco non minerario sconosciuto") then return "BLOCCO SCONOSCIUTO" end
 if contains(s,"RIENTRO:") then return "RIENTRO BLOCCATO" end
 return "ALTRO / DA ISPEZIONARE"
end
local affected=0
local total=0
for _,side in ipairs({"N","O","S","E"}) do
 for number=1,10 do
  local unit=side..string.format("%02d",number)
  local rec=db.units["MINIERA-01|"..unit]
  if type(rec)=="table" then
   total=total+1
   local st=tostring(rec.status or "?")
   statusCount[st]=(statusCount[st] or 0)+1
   if st=="ERRORE" or (type(rec.error)=="string" and rec.error~="") then
    local category=classify(rec.error,rec.detail)
    groups[category]=groups[category] or {}
    groups[category][#groups[category]+1]=unit.." (PC"..tostring(rec.sender or "?")..")"
    affected=affected+1
   end
  end
 end
end
print("MEGAZERO PC54 | RAGGRUPPAMENTO PER CAUSA")
print("SOLO LETTURA - NESSUNA TURTLE MODIFICATA")
print("Registrate: "..total.."/40 | errori registrati: "..affected)
local states={}
for k in pairs(statusCount) do states[#states+1]=k end
table.sort(states)
for _,st in ipairs(states) do print(st..": "..statusCount[st]) end
local categories={}
for k in pairs(groups) do categories[#categories+1]=k end
table.sort(categories,function(a,b)
 if #groups[a]==#groups[b] then return a<b end
 return #groups[a]>#groups[b]
end)
for _,k in ipairs(categories) do
 print("")
 print(#groups[k].."x "..k)
 print("  "..table.concat(groups[k],", "))
end
print("")
print("FINE. Solo registro PC54: GPS e checkpoint da verificare a parte.")
