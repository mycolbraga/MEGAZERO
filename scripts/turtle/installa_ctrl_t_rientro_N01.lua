-- MEGAZERO | N01: installa boot 1.2 + miner 2.3.6 (SOLO TEST)
-- Non muove la Turtle. Disattiva autostart. Conserva checkpoint/latch.
assert(turtle and os.getComputerID()==12,"Solo N01 PC 12")
local configPath="/megazero_config"
local function read(path)
 local f=assert(fs.open(path,"r"),"File mancante: "..path)
 local s=f.readAll();f.close();return s
end
local cfg=assert(textutils.unserialize(read(configPath)),"Config invalida")
assert(cfg.unit=="N01" and cfg.site=="MINIERA-01","Identita' inattesa")
local function existing(name)
 if fs.exists("/"..name) then return "/"..name end
 if fs.exists("/"..name..".lua") then return "/"..name..".lua" end
 error("Programma mancante: "..name)
end
local items={
 {name="megazero_boot",head="-- MEGAZERO BOOT 1.1",
  newhead="-- MEGAZERO BOOT 1.2",
  commit="f19ed26ed61f09b91d86e52997a983884540c793"},
 {name="megazero_miner",head="-- MEGAZERO MINER v2.3.5",
  newhead="-- MEGAZERO MINER v2.3.6",
  commit="16cfa71fd77e18e24d66a58e2b2fedac6a190d48"}
}
local backups={}
for _,it in ipairs(items) do
 it.target=existing(it.name)
 it.backup=it.target..".before_ctrl_t_v12"
 it.stage=it.target..".new_ctrl_t_v12"
 assert(not fs.exists(it.backup) and not fs.exists(it.stage),
  "Backup/staging preesistente: "..it.name)
 local old=read(it.target)
 assert(old:sub(1,#it.head)==it.head,
  "Versione inattesa di "..it.name..", non sovrascrivo")
 backups[it.name]=old
end
local cbak="/.megazero_config_before_ctrl_t_v12"
local cstage="/.megazero_config.new_ctrl_t_v12"
assert(not fs.exists(cbak) and not fs.exists(cstage),
 "Backup/staging config preesistente: STOP")
for _,it in ipairs(items) do
 local url="https://raw.githubusercontent.com/mycolbraga/MEGAZERO/"..
   it.commit.."/scripts/turtle/"..it.name..".lua"
 local response,err=http.get(url)
 assert(response,"Download fallito "..it.name..": "..tostring(err))
 local code=response.readAll();response.close()
 assert(type(code)=="string" and code:sub(1,#it.newhead)==it.newhead,
  "Versione sorgente non attesa: "..it.name)
 local fn,why=load(code,"="..it.name)
 assert(fn,"Errore sintassi "..it.name..": "..tostring(why))
 local f=assert(fs.open(it.stage,"w"));f.write(code);f.close()
 assert(fs.getSize(it.stage)==#code,"Stage non verificato: "..it.name)
end
-- Mette in sicurezza il prossimo reboot PRIMA di aggiornare programmi.
cfg.miner_autostart=false
local cf=assert(fs.open(cstage,"w"))
cf.write(textutils.serialize(cfg));cf.close()
fs.copy(configPath,cbak)
assert(fs.getSize(cbak)>0,"Backup configurazione non riuscito")
for _,it in ipairs(items) do
 fs.copy(it.target,it.backup)
 assert(fs.getSize(it.backup)==#backups[it.name],
  "Backup fallito: "..it.name)
end
local ok,err=pcall(function()
 fs.delete(configPath)
 fs.move(cstage,configPath)
 for _,it in ipairs(items) do
  fs.delete(it.target)
  fs.move(it.stage,it.target)
 end
end)
if not ok then
 if fs.exists(cbak) then
  if fs.exists(configPath) then fs.delete(configPath) end
  fs.copy(cbak,configPath)
 end
 for _,it in ipairs(items) do
  if fs.exists(it.backup) then
   if fs.exists(it.target) then fs.delete(it.target) end
   fs.copy(it.backup,it.target)
  end
 end
 error("Installazione annullata e rollback tentato: "..tostring(err),0)
end
print("N01: BOOT 1.2 + MINER 2.3.6 INSTALLATI.")
print("Autostart DISATTIVO: reboot NON avvia lo scavo.")
print("Checkpoint e latch CONSERVATI. Nessun movimento.")
print("Agente v1.3 non aggiornato: test rientro prima di uso generale.")
