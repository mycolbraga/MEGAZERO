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
