-- MEGAZERO | Aggiornamento miner v2.3.2 da GitHub sulla singola Turtle
-- wget run <URL_DI_QUESTO_FILE>
-- Non avvia scavo, NON modifica autostart, salva backup del codice precedente.
assert(turtle,"Eseguire su una Turtle")
local base="https://raw.githubusercontent.com/mycolbraga/MEGAZERO/registro/megazero/scripts/turtle/"
local items={
 {name="megazero_miner",remote="megazero_miner.lua",prefix="-- MEGAZERO MINER v2.3.2"},
 {name="megazero_fluidi",remote="megazero_fluidi.lua",prefix="-- MEGAZERO FLUIDI v1.0"},
 {name="megazero_auto",remote="megazero_auto.lua",prefix="-- MEGAZERO | Gestione avvio automatico"}
}
local staged={}
for _,v in ipairs(items) do
 local response,err=http.get(base..v.remote)
 assert(response,"Download "..v.remote.." non riuscito: "..tostring(err))
 local source=response.readAll()
 response.close()
 assert(type(source)=="string" and source:sub(1,#v.prefix)==v.prefix,
  "Sorgente inattesa: "..v.remote.."; nessun file sostituito")
 local compiled,why=load(source,"="..v.remote)
 assert(compiled,"Errore sintassi "..v.remote..": "..tostring(why))
 local target="/"..v.name
 local temp=target..".new_v2"
 assert(not fs.exists(temp),"File temporaneo gia' presente: "..temp)
 local f=assert(fs.open(temp,"w"))
 f.write(source)
 f.close()
 staged[#staged+1]={target=target,temp=temp}
 print("Verificato: "..v.remote)
end
for _,v in ipairs(staged) do
 local backup=v.target..".backup_pre_v232"
 if fs.exists(v.target) and not fs.exists(backup) then
  fs.copy(v.target,backup)
 end
 if fs.exists(v.target) then fs.delete(v.target) end
 fs.move(v.temp,v.target)
 print("Aggiornato: "..v.target)
end
print("MEGAZERO miner v2.3.2 installato; checkpoint v23 conservato.")
print("Startup e miner_autostart NON sono stati modificati.")
print("Nessuno scavo avviato. Verificare prima di attivare tutte le Turtle.")
