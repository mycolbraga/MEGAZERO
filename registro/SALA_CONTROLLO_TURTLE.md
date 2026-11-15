# MEGAZERO — Sala di controllo riutilizzabile per le Turtle

## Decisione (15 novembre 2026)
L'utente ha **approvato** una sala di controllo permanente **nella base principale**, distinta dal sito minerario, per vedere a distanza lo stato delle Mining Turtle senza recarsi a ogni controllo presso la miniera. Ha chiesto esplicitamente che l'infrastruttura sia **riutilizzabile per nuove miniere e, in futuro, altre turtle/farm**.

**Stato attuale (aggiornamento confermato dal giocatore, 15 novembre 2026):** **Hardware centrale già montato nella base principale**: Advanced Computer, 4 Advanced Monitor 2×2 e Ender Modem collegato al computer, secondo la conferma «già fatto tutto». Il secondo Ender Modem per una turtle fa parte del kit preparato, ma **non è ancora verificata in chat la sua effettiva installazione/operatività**. Nessun test delle periferiche, della rete o del software ancora concluso. Prossimo passo: sul computer centrale verificare via Lua `peripheral.find("monitor")` e `peripheral.find("modem")`.

## Verifica periferiche completata (15 novembre 2026)
- Screenshot fornito dal giocatore del computer centrale in prompt Lua: eseguito `print("Monitor:", peripheral.find("monitor") ~= nil, "Modem:", peripheral.find("modem") ~= nil)` con output **`Monitor: true Modem: true`**.
- **Confermato:** il computer riconosce un monitor e un modem come periferiche.
- **Test display confermato dal giocatore con screenshot:** dal computer centrale è stata scritta la stringa `MEGAZERO CONTROL ONLINE` sul monitor 2×2. **Riconoscimento e scrittura monitor verificati.**
- **Non ancora provato:** tipo/portata del modem, apertura Rednet, comunicazione con una turtle, software dashboard e caricamento chunk.
- Prossima verifica: scrivere una stringa di prova sull'Advanced Monitor dal computer, senza avviare alcuna turtle.

## Identificativo centrale (15 novembre 2026)
- **ID CC:Tweaked del computer centrale comunicato dal giocatore: `54`.**
- È l'ID da utilizzare nei test di comunicazione fra la prima turtle e la centrale. Per rendere la sala controllo riutilizzabile su più siti, il progetto definitivo non deve dipendere esclusivamente da un numero scritto nel codice: prevedere registrazione/ricerca del server con protocollo.
- Il giocatore ha fornito il numero `54` dopo il comando di apertura Rednet; la conferma visiva di `RETE: true` non è stata fornita esplicitamente, quindi non considerare la comunicazione con una turtle già testata.

## Primo modem sulla turtle — conferma installazione (15 novembre 2026)
- Il giocatore conferma **Ender Modem già montato** sulla prima turtle mineraria di test, postazione **(2119,-53,2995), facing NORD**.
- Stato successivo: **verificare che la turtle riconosca la periferica modem** da Lua, senza muovere/scavare, poi organizzare una prova di invio/ricezione verso il computer centrale CC:Tweaked **ID 54**.
- **Non è ancora stata verificata la ricezione effettiva dei messaggi** tra miniera e centrale; tenere presenti chunk caricati, computer ricevente in ascolto e l'eventuale uscita dal programma `lua` sul computer centrale.

## Software centrale preparato (15 novembre 2026)
- **Prima versione pubblicata nel repository:** [`scripts/control/megazero_control.lua`](../scripts/control/megazero_control.lua), con registrazione iniziale di **40 postazioni MINIERA-01**, supporto a più siti e salvataggio dello stato locale.
- **Protocollo previsto per i futuri client Turtle:** `megazero.control.v1`. Il computer centrale registra l'hostname Rednet `megazero-central` e riceve messaggi versione 1: `{kind="status",version=1,site="MINIERA-01",unit="N01",status="SCAVO",x=...,y=...,z=...,fuel=...,progress=...}`.
- **Stati supportati:** SCAVO, RIENTRO, BASE, ERRORE, PAUSA, PREPARAZIONE. I 40 placeholder iniziali indicano «MAI COLLEGATA», non guasti. Assenza aggiornamenti da oltre 90 s indicata «SENZA SEGNALE» (non equiparare automaticamente a guasto).
- **Interfaccia:** 4 quadranti NORD/SUD/OVEST/EST sul monitor 2×2; tocco di una riga per dettagli e tocco del fondo per cambiare sito/pagina. La schermata non invia ordini alle turtle (sola visualizzazione).
- **Installazione sul computer centrale ID 54**, dalla shell normale (non dal prompt `lua>`): `wget https://raw.githubusercontent.com/mycolbraga/MEGAZERO/registro/megazero/scripts/control/megazero_control.lua megazero_control`, poi `megazero_control`.
- **Test reale non ancora eseguito**: codice pubblicato e letto dal repository; il funzionamento sul computer CC:Tweaked, l'interfaccia e la rete tra base e miniera richiedono la verifica del giocatore. Nessun client turtle installato o programma di mining modificato. La bozza di mining vecchia resta da NON avviare.

## Primo avvio del software centrale riuscito (15 novembre 2026)
- Il giocatore ha installato con `wget` e avviato `megazero_control` sul **computer ID 54** della base principale.
- Screenshot del terminale: **`MEGAZERO CONTROL attivo | Computer ID 54`**, **`In attesa dei messaggi dalle Turtle...`**, **`Ctrl+T per uscire salvando il registro.`**
- **Confermato:** lo script centrale è partito senza errori visibili e il suo ciclo di ricezione è attivo.
- **Ancora da verificare:** vista dashboard sul monitor con le 40 postazioni, ricezione effettiva Rednet da una turtle, salvataggio/ripristino stato e caricamento chunk.

## Avvio automatico configurato (15 novembre 2026)
- Sul computer centrale CC:Tweaked **ID 54** il giocatore ha creato e salvato il file `startup` tramite `edit startup`, inserendo `shell.run("megazero_control")`.
- **Verifica completata:** dopo il comando `reboot` sul computer centrale **ID 54**, il giocatore ha confermato **sì**, la dashboard MEGAZERO CONTROL si avvia automaticamente e compare sul monitor. Nessuna verifica di comunicazione con una turtle ancora svolta.

## Modulo di telemetria delle Turtle preparato (15 novembre 2026)
- **Pubblicato:** [`scripts/turtle/megazero_rete.lua`](../scripts/turtle/megazero_rete.lua), **versione 1.0**, in forma di programma autonomo per il test radio e di modulo riutilizzabile nel futuro programma minerario.
- **Installazione futura su ciascuna turtle:** `wget https://raw.githubusercontent.com/mycolbraga/MEGAZERO/registro/megazero/scripts/turtle/megazero_rete.lua megazero_rete`.
- **Test non distruttivo sulla prima turtle N01 (quando si torna alla cava, non ora):** `megazero_rete N01`. Non si sposta, scava o rifornisce: invia `PREPARAZIONE` e un heartbeat ogni 20 secondi con sito `MINIERA-01`, unità `N01` e livello carburante reale. Si può interrompere con Ctrl+T.
- Il protocollo coincide con quello della centrale: `megazero.control.v1`, hostname `megazero-central` per `rednet.lookup`, fallback ID **54**. Il codice cerca un modem wireless/Ender sulla turtle, apre Rednet e invia l'aggiornamento. `rednet.send()` non conferma la consegna remota: la prova conclusiva sarà la visualizzazione della turtle sulla dashboard.
- La funzione `dofile("megazero_rete").new("N01", "MINIERA-01")` è disponibile per la futura integrazione nel programma minerario; i metodi `report(stato, dati)`, `heartbeat()` e `heartbeatLoop()` richiedono **integrazione esplicita** nelle operazioni di movimento, ritorno e gestione errori. Non dichiarare operativi avanzamento, posizione, errori o rientro finché i corrispondenti dati non sono inviati dal programma di scavo.
- **Non installato né testato in Minecraft sulle turtle**; **nessuna modifica** allo script di scavo originale già funzionante. Non sostituisce il programma di scavo e non avvia automaticamente il mining. Restano da realizzare/testare il miner selettivo per le 40 fasce, il ritorno di sicurezza e la gestione chunk.

## Installazione hardware completa alla miniera (15 novembre 2026)
- L'utente ha comunicato di essere arrivato in miniera con **39 Ender Modem**, da aggiungere a quello già montato su **N01**. Successivamente ha confermato **«fatto»** dopo la richiesta di montarli su tutte le altre Mining Turtle.
- **Stato dichiarato dall'utente:** tutti i **40 Ender Modem installati** sulle 40 turtle. Installazione software e test di comunicazione sulle turtle **ancora da eseguire**.
- **Primo passo scelto:** scaricare sulla N01 il modulo `megazero_rete` dal repository; non avviare scavi.

## Test trasmissione N01 (15 novembre 2026)
- Screenshot del giocatore dalla turtle N01 in miniera, dopo `megazero_rete N01`: `MEGAZERO - TEST RETE (NON SCAVA)`, `Turtle: MINIERA-01/N01`, `Centrale individuata/ID: 54`, **`Invio Rednet: true`**, heartbeat ogni 20 secondi.
- **Confermato:** apertura modem della turtle e invio locale Rednet senza errore. **Non confermato:** reale ricezione alla centrale, perché `rednet.send` non fornisce acknowledgement e il programma ha fallback sull'ID 54.
- **Prossima verifica senza spostarsi:** interrompere il test con Ctrl+T sulla N01 e interrogare `rednet.lookup("megazero.control.v1","megazero-central")` dal prompt Lua dopo aver aperto il modem; se restituisce `54` significa che la centrale ha risposto in rete, `nil` indica nessuna risposta (verificare soprattutto il caricamento dei chunk della base principale).

## Test bidirezionale Rednet N01 → centrale 54 confermato (15 novembre 2026)
- Il giocatore, dalla prima turtle N01 alla miniera, ha eseguito `rednet.lookup("megazero.control.v1","megazero-central")` dopo apertura del modem; risposta **`54`**.
- **Confermato:** il computer centrale Rednet risponde alle richieste di individuazione dalla miniera; portata di rete e caricamento dei chunk erano sufficienti nel momento del test. Il test di invio precedente su N01 restituiva `Invio Rednet: true`.
- **Ancora NON confermato:** comparsa dello stato N01 sulla dashboard centrale (l'invio di uno stato non ha acknowledgement applicativo), permanenza del caricamento dei chunk e comunicazione da tutte le altre 39 turtle.
- Procedura concordata: riavviare `megazero_rete N01` dopo `exit()` da Lua e lasciarlo in esecuzione, quindi configurare le altre turtle durante questa visita alla miniera, evitando viaggi avanti-indietro.

## Installatore unico per le altre 39 Turtle (15 novembre 2026)
- Dopo il test positivo `rednet.lookup(...)` della N01, il giocatore ha confermato di aver **riavviato `megazero_rete N01`** e di averla lasciata attiva; la visibilità nella dashboard principale è ancora da verificare.
- **Pubblicato e verificato nel repository:** [`scripts/turtle/installa_rete.lua`](../scripts/turtle/installa_rete.lua), una procedura di installazione a **comando unico** `wget run https://raw.githubusercontent.com/mycolbraga/MEGAZERO/registro/megazero/scripts/turtle/installa_rete.lua N02` da ripetere sulle altre turtle cambiando la sigla (`N02`–`N10`, `O01`–`O10`, `S01`–`S10`, `E01`–`E10`).
- L'installatore valida il formato dell'ID, controlla la presenza del modem, scarica il modulo `megazero_rete` solo se non esiste già, **non sovrascrive file preesistenti** e avvia subito il test di telemetria senza alcun movimento/scavo. Non tocca `startup`, l'inventario, lo scavo o i file di stato precedenti.
- **Non ancora testato sul gioco**; fare la prima prova su N02 prima di distribuirlo alle restanti 38. Il solo invio radio non è la prova della ricezione sulla dashboard. La telemetria eseguita manualmente **non si riavvia automaticamente** al reboot delle turtle; verrà integrata nel futuro programma minerario.

## Installatore verificato in gioco su N02 (15 novembre 2026)
- Screenshot del giocatore dopo l'esecuzione di `wget run .../scripts/turtle/installa_rete.lua N02`: il terminale della N02 visualizza `MEGAZERO - TEST RETE (NON SCAVA)`, `Turtle: MINIERA-01/N02`, `Centrale individuata/ID: 54`, **`Invio Rednet: true`**; aggiornamento ogni 20 s.
- **Confermato:** l'installatore ha scaricato e avviato il test radio sulla N02 senza errore evidente. N01 era stata avviata prima. Non è ancora stata confermata direttamente la visualizzazione degli stati sul monitor centrale.
- Si può distribuire lo stesso comando sulle altre **38 turtle** variando la sigla corretta; non avviare il programma minerario. Ogni test resta in esecuzione sulla rispettiva turtle finché non viene interrotto o il computer si spegne.

## Telemetria installata su tutte le 40 Turtle — dichiarazione utente (15 novembre 2026)
- Dopo il test riuscito su N02 e l'installazione a comando unico delle restanti 38, l'utente ha confermato in chat **«OK FATTO TUTTO»**. Considerare **installazione/avvio manuale del test `megazero_rete` su tutte e 40 le Turtle dichiarati completati** dal giocatore, con modem già montati su tutte.
- **Non ancora verificato dalla dashboard:** arrivo dei 40 messaggi, correttezza degli ID e persistenza dello stato mentre il giocatore si sposta dalla miniera alla base principale.
- **Prossimo test unico di integrazione:** tornare alla base principale, visualizzare la dashboard della centrale 54 e verificare quali unità compaiono `PREPARAZIONE` (e quali `MAI COLLEGATA` o `SENZA SEGNALE`), attendendo almeno 20–30 secondi di esecuzione con entrambi i siti caricati. Se alcune risultano `SENZA SEGNALE`, analizzare chunk loading prima di imputare un guasto ai modem.
- **Attenzione:** gli script di test non hanno un `startup` sulle turtle: dopo reboot o riavvio manuale delle turtle i test non ripartono da soli; il modulo di telemetria sarà integrato nel futuro programma di scavo. **Il mining coordinato per 40 turtle non è ancora scritto o collaudato**.

## Piano forceload delle quattro fasce minerarie (15 novembre 2026)
- Il giocatore ha **scelto esplicitamente `/forceload`**, non chunk loader costruiti fisicamente. Non proporre installazioni o craft di chunk loader.
- **NORD:** `/forceload add 2100 2695 2119 2994` — 40 chunk (X chunk 131..132, Z chunk 168..187).
- **SUD:** `/forceload add 2099 3016 2118 3315` — 40 chunk (X 131..132, Z 188..207).
- **OVEST:** `/forceload add 1799 2995 2098 3014` — 40 chunk (X 112..131, Z 187..188).
- **EST:** `/forceload add 2120 2996 2419 3015` — 40 chunk (X 132..151, Z 187..188).
- Le quattro fasce includono già i 4 chunk della base delle turtle e hanno 4 intersezioni ai lati: **156 chunk distinti** complessivamente. Non è necessario un quinto comando per la base mineraria.
- **Base principale:** posizione diversa da quella della miniera; manca la coppia di coordinate. Da aggiungere almeno il chunk che ospita il computer 54, per esempio con `/forceload add ~ ~` quando il giocatore è presso il computer. Controllare l'eventuale monitor oltre un confine di chunk.
- **Comandi suggeriti, NON ancora confermati eseguiti dall'utente.** Ogni `/forceload add` comprende meno di 256 chunk. Verifica successiva: `/forceload query`. Attenzione al costo prestazionale dei chunk sempre caricati e alla persistenza della forzatura finché non viene rimossa.
- Documentazione comando: https://minecraft.wiki/w/Commands/forceload

## Architettura riutilizzabile
- **Un Computer centrale** (consigliato **Advanced Computer**) nella base principale.
- **Parete di Advanced Monitor** colorati; dimensione suggerita iniziale **4×3 = 12 blocchi monitor**, scalabile in futuro. I monitor contigui e correttamente orientati formano uno schermo unico.
- **Un Ender Modem** collegato al computer centrale. Per display adiacente al computer si può evitare il cablaggio; se distante: modem cablati + Networking Cable come periferica remota.
- **Un Ender Modem equipaggiato su ciascuna delle 40 Mining Turtle**: il modem usa uno dei due slot laterali di upgrade, l'altro deve mantenere il piccone (se già montato). Controllare gli upgrade prima di equipaggiare: non sostituire il piccone accidentalmente.
- Comunicazione tramite `rednet` (CC:Tweaked); Ender Modem senza limite di distanza tra macchine caricate, anche fra dimensioni.
- **Caricamento chunk indipendente dalla rete**: i modem NON tengono caricati i chunk. Serve una strategia per computer centrale e 4 fronti minerari fino a 300 blocchi, tenendo conto del costo prestazionale. Senza chunk caricati le turtle non avanzano e l'assenza di aggiornamento va descritta come NON RAGGIUNGIBILE, non automaticamente ERRORE.
- Il mondo dell'utente è **Minecraft single-player**, non un server.

## Materiali — allestimento finale di riferimento (40 turtle, schermo 4×3)
- **1 Advanced Computer** (se non già disponibile).
- **12 Advanced Monitor**, ottenuti con **3 craft da 4 monitor**.
- **41 Ender Modem**: 40 sulle turtle più 1 al computer centrale.
- **Opzionali:** Wired Modem e Networking Cable per separare fisicamente display e computer; Speaker per allarmi; Pocket Computer + Ender Modem per terminale portatile; periferiche ulteriori per farm.
- I 40 blocchi Turtle, casse, cablaggi di rifornimento e scarico nella base mineraria sono già installati secondo conferma del giocatore, e **non** vanno ricraftati per il monitoraggio.

### Risorse di crafting standard CC:Tweaked (salvo modifiche del modpack: verificare in REI/JEI)
- Ender Modem: **8 lingotti d'oro + 1 Eye of Ender**, produce 1. Per 41: **328 lingotti d'oro + 41 Eye of Ender**.
- Advanced Monitor: **8 lingotti d'oro + 1 pannello di vetro**, produce **4 monitor**. Per 12: **24 lingotti d'oro + 3 pannelli di vetro**.
- Advanced Computer: **7 lingotti d'oro + 1 redstone + 1 pannello di vetro**.
- **Totale** se va realizzato tutto da zero: **359 lingotti d'oro, 41 Eye of Ender, 4 pannelli di vetro, 1 redstone**. Per gli Eye of Ender servono in vanilla **41 perle di Ender e 41 polveri di blaze**.
- Controllare le ricette nel modpack attuale: eventuali override possono cambiare le quantità.

### Kit minimo per prova di rete e display, prima di produrre i 41 modem
- **1 Advanced Computer**.
- **4 Advanced Monitor** (1 craft: 8 oro + 1 pannello).
- **2 Ender Modem** (1 sulla prima turtle, 1 alla centrale).
- Risorse se completamente da zero: **31 lingotti d'oro, 2 Eye of Ender, 2 pannelli di vetro, 1 redstone**.
- **Prima verificare comunicazione bidirezionale** e riconoscimento del monitor senza far muovere la turtle, poi installare progressivamente gli altri modem e ampliare lo schermo.

## Modello dati multi-sito (design, non ancora codice)
Ogni turtle comunica:
- `site_id` (es. `cava_01`, `cava_02`, `farm_legno`) — **non** fissare la centrale alla cava corrente.
- `unit_id` univoco e stabile (es. `N01` **all'interno del sito**), e vero `computer_id` numerico di CC:Tweaked.
- `home`: coordinate della postazione, `facing`, coordinate correnti stimate/tracciate, settore e quota.
- `status`: PREPARAZIONE, IN_SCAVO, IN_RIENTRO, ALLA_BASE, ERRORE_IN_BASE, NON_RAGGIUNGIBILE; più dettagli testuali, progressione, carburante.
- `error_info`: causa, coordinate dell'anomalia, avanzamento e timestamp/logica di ordinamento.
- `heartbeat`: aggiornamento periodico, per esempio ogni 15–30 secondi, e invii immediati sui cambi di stato.
- La centrale mantiene un **registro persistente dei siti e delle unità**: aggiungere una nuova miniera significa aggiungere un nuovo `site_id` e le sue turtle, **senza riscrivere il programma centrale**.

## Sicurezza dei comandi
- Il monitor deve inizialmente essere **solo lettura/diagnostica**. Comandi remoti (pausa, ripresa, avvio, conferma allarmi) eventuali e separati, con messaggi di conferma e controlli rigorosi: non permettere avvii involontari o ripresa automatica dopo errori.
- La regola prioritaria già confermata **prevale sempre**: davanti a un problema recuperabile la turtle deve **interrompere l'estrazione, rientrare alla propria postazione e segnalare l'errore**; mantenere margine carburante e registrazione sicura del percorso. La centrale informa, **non sostituisce** la sicurezza della turtle.
- In assenza di aggiornamenti la dashboard deve indicare **NON RAGGIUNGIBILE / ULTIMO CONTATTO**, senza indovinare se sia per chunk scaricato, rete o guasto.
- Il computer centrale salva le informazioni a file per non perdere lo storico dopo reboot.

## Sequenza concreta
1. Preparare il **kit minimo** (Advanced Computer, 4 Advanced Monitor, 2 Ender Modem).
2. Collocare il computer e il piccolo display nella base principale; attaccare il modem al computer su un lato differente dal display.
3. Equipaggiare un Ender Modem sull'upgrade libero di **una turtle esistente**, preservando l'attrezzo da miniera. Provare invio/ricezione `rednet` (test **non distruttivo**, turtle immobile).
4. Realizzare software centrale riutilizzabile per registry, dashboard e log; integrare un client `rednet` in uno script di turtle ancora da sviluppare e collaudare.
5. Verificare davvero la copertura dei chunk e gli aggiornamenti fra base principale e cava.
6. A rete verificata, completare 41 modem e parete 4×3, integrare tutte le 40 turtle.
7. Per i nuovi scavi registrare nuovi siti e aggiungere altre turtle, senza sostituire il computer/monitor principale.

## Riferimenti tecnici
- Official CC:Tweaked modems: https://www.tweaked.cc/peripheral/modem.html
- Official monitors (ricetta 4 Advanced Monitor): https://tweaked.cc/mc-1.21.y/peripheral/monitor.html
- Official rednet: https://tweaked.cc/module/rednet.html
- Official turtle upgrades: https://tweaked.cc/module/turtle.html
- Official peripheral adjacency: https://www.tweaked.cc/mc-1.21.x/module/peripheral.html
