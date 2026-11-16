# MEGAZERO — Piano tecnico per gestione remota delle 40 Mining Turtle

**Stato:** specifica progettuale; NON software installato o in funzione.
**Data:** 16 novembre 2026.
**Repository/branch:** `mycolbraga/MEGAZERO` — `registro/megazero`.
**Obiettivo:** dal Computer centrale ID **54** verificare, aggiornare e avviare le 40 Turtle della miniera con pochi comandi, senza interrompere i lavori in corso e senza forzare Turtle fuori dai propri settori.

## Stato di partenza verificato nei sorgenti
- `scripts/control/megazero_control.lua`: dashboard e registro ricezione telemetria, protocollo `megazero.control.v1`, **nessun controllo remoto**.
- `scripts/turtle/megazero_rete.lua`: invia `kind=status` con unit/site, stato, progresso e posizione riportata; **non riceve comandi**.
- `scripts/turtle/megazero_boot.lua`: esegue rete e, se `miner_autostart=true` e nessun latch d'errore, miner locale. Nessun listener amministrativo.
- `scripts/turtle/megazero_miner.lua`: miner v2.3 con confini, giornale di ritorno, checkpoint `/.megazero_miner_v23_<UNIT>_LAVORO`; NON è automaticamente migrabile da una versione all'altra durante il lavoro.
- `scripts/turtle/megazero_aggiorna_miner_v2.lua`: scarica file localmente dalla Turtle e verifica che i Lua compilino; NON è un aggiornamento inviabile da remoto.
- Il registro `registro/SALA_CONTROLLO_TURTLE.md` riporta installati startup e telemetria sulle 40 Turtle e dashboard 4×3 su 12 monitor, tutte visibili (conferma del giocatore, 15 novembre). N01 ha iniziato lo scavo il 16 novembre; **non toccarla ora**.
- La centrale attuale ammette solo `SCAVO, RIENTRO, BASE, ERRORE, PAUSA, PREPARAZIONE`; stati emessi dal miner come `BLOCCATO` e `INCOMPLETO` devono essere resi compatibili nel futuro aggiornamento della dashboard e della rete.

## Architettura proposta

```text
Computer 54: centrale attuale + gestore amministrativo
       |
       | Rednet, protocollo distinto megazero.admin.v1
       |
   [agente v1 su ciascuna Turtle]
       | controlla identità/unit, versione, posizione e stato
       | scarica file in staging; verifica; effettua rollback se necessario
       +----> miner v2.x (separato, non riscritto)
       +----> telemetria esistente (continua)
```

L'amministrazione deve restare compatibile con il protocollo telemetrico v1 e **non intercettare né cambiare** i dati già visibili sulla dashboard. Preferenza: integrare la ricezione admin nel boot e la gestione comandi nel ciclo eventi della centrale; no processi concorrenti scollegati che assumano il controllo esclusivo di Rednet.

## Limitazione inevitabile: bootstrap iniziale sulle Turtle

L'attuale boot e l'attuale modulo rete delle 39 Turtle **non ascoltano comandi**. La centrale non può quindi installare software remoto su macchine che non abbiano ancora un ricevitore. È necessaria **una sola installazione locale per Turtle** (39 in attesa; N01 soltanto quando torna a casa e si ferma), tramite un installatore non distruttivo.

Dopo questa singola preparazione, aggiornamenti, configurazioni e attivazioni possono essere governati dal Computer 54. Evitare di chiedere 39 volte l'installazione completa di startup/rete: sono già presenti.

Bootstrap locale richiesto (futuro script):
1. verifica file esistenti e unità N/O/S/E 01–10;
2. backup di `/megazero_boot` e config, mai sovrascrivere `/startup.lua` non previsto;
3. scarica e compila il piccolo modulo `megazero_agent`;
4. prepara un `megazero_boot` che esegua il listener anche se il miner è disabilitato;
5. mantiene `miner_autostart=false` per le 39 Turtle;
6. riavvio della singola Turtle solo dopo installazione verificata, senza avvio scavo;
7. invia `HELLO` con ID vero del computer, unit, sito, versioni e disponibilità.

## Protocollo amministrativo (proposta, non implementato)

Separato da `megazero.control.v1`: **`megazero.admin.v1`**.

Campi in ogni richiesta:
- `kind=admin_request`, `version=1`, `site=MINIERA-01`;
- `target_unit`, `target_computer_id` (nessun target implicito);
- `request_id` univoco, `nonce` di sessione, `command`, `args`;
- versione richiesta o manifest esatto; `source=54` verificata contro mittente effettivo del pacchetto.

Risposta sempre mirata:
- `kind=admin_ack`, `request_id`, `unit`, `computer_id`;
- `accepted=false|true`, `phase=RECEIVED|CHECKING|STAGED|READY|APPLYING|DONE|FAILED`;
- versione precedente/nuova, errore concreto, timestamp. Un ACK non equivale a installazione completa: serve `DONE` dopo controllo post-riavvio.

Comandi da sviluppare in ordine di rischio crescente:
1. **PING / STATUS / INVENTORY**: presenza, posizione stimata, fuel, error latch, stato, versione miner/agent/boot;
2. **CHECK_UPDATE**: confronta manifest e rileva modifiche, non scrive;
3. **PREPARE_UPDATE**: scarica in `*.new` e verifica sintassi, identità, hash/manifest dove disponibile; non sostituisce;
4. **COMMIT_UPDATE**: quando ferma alla base, salva backup e sostituisce in modo recuperabile; conferma versione dopo reboot;
5. **ARM_START**: installata e validata, abilitazione `miner_autostart` senza movimento immediato;
6. **START**: avvia solo Turtle esplicitamente armate e senza error latch;
7. **STOP_AFTER_RETURN / DISABLE_AUTOSTART**: impedisce futuri avvii senza fermare di colpo una Turtle lontana dalla base; comando di arresto immediato richiede comportamento sicuro del miner, non `reboot` remoto cieco.

**Sicurezza del protocollo:** tabella di abbinamento ID Turtle/ID computer verificata al primo provisioning; rifiutare ordini da mittenti non abbinati, richieste duplicate o scadute e target non corrispondenti. Rednet non costituisce autenticazione crittografica: valutare segreto per unità e convalida del messaggio se il mondo ha più computer non affidabili. Nessun comando `eval`, shell remota arbitraria o URL indicato da pacchetti non autorizzati. Il client scarica solo i file previsti dal manifest fidato del repo.

## Stato operativo e sicurezza inviolabile

- **Turtle in SCAVO o RIENTRO:** NO update/reboot/nuovo start. Può rispondere a STATUS e registrare una richiesta differita fino al rientro. N01 rimane intatta mentre lavora.
- **Turtle PREPARAZIONE/BASE:** può controllare, preparare e applicare un aggiornamento, previa validazione che si trovi davvero alla base; se non verificabile, non procedere.
- **Turtle ERRORE/posizione incerta:** mai avvio automatico; no cancellazione automatica `/.megazero_miner_error`, no reset del checkpoint per sbloccarla.
- **Turtle OFFLINE:** non interpretare come guasto sicuro; può essere chunk non caricato. Non segnare comandi come eseguiti senza ACK, né accodarli senza scadenza.
- **Confini minerari:** nessun comando remoto modifica `inSector`, base, orientamento, quota o quota di carburante senza una nuova versione verificata e approvata.
- **Checkpoint v2.3:** un cambio versione del miner richiede migrazione esplicita o intervento solo dopo il completamento in corso. NON riavviare uno stato `/.megazero_miner_v23_...` da una nuova versione che usi `/.megazero_miner_v24_...` come fosse lavoro nuovo.
- **Rollback:** backup codice/boot/config, integrità verificata, ritorno alla versione precedente in caso di mancato avvio; non toccare inventario o dati di mining in rollback. Rollback automatico solo del codice, non dei movimenti già eseguiti.
- **Nessun avvio massivo accidentale** da una pressione sul monitor: operazioni rischiose richiedono comando esplicito + riepilogo target + conferma, e rollout con soglia di errore.
- **Audit:** log centrale per target, versione, operazione, richiesta, ACK, esito e tempo. Stato `PENDING` per risposte non ricevute.

## Aggiornamento di 39 Turtle con una sola procedura

Dopo il bootstrap:
1. Il Computer 54 interroga tutte le Turtle e costruisce la lista degli **ID realmente connessi**: attive/inattive, versioni e stato, senza dedurre dalla sola posizione registrata.
2. Un comando di `CHECK_UPDATE` esamina solo Turtle ferme e disponibili; stampa differenze e possibili conflitti.
3. Un comando di `PREPARE_UPDATE` scarica e verifica la stessa versione per tutte le Turtle idonee, senza attivare miner.
4. La centrale controlla ACK reali e sospende l'operazione se ci sono risposte mancanti/errori. Nessuna Turtle con aggiornamento parziale viene avviata.
5. `COMMIT_UPDATE` e verifica post-riavvio, con fallback/rollback.
6. Solo a richiesta esplicita, `ARM_START` e `START` in piccoli gruppi. Prima una Turtle di altro fronte, poi 2–3, poi gruppi massimi di 10 (un fronte per volta), interrompendo la diffusione al primo errore importante.

La **comodità per l'utente** deve essere un *unico comando amministrativo* con stato completo e conferme, non un avvio contemporaneo non supervisionato di 40 Turtle.

## Interfaccia della centrale

Mantenere il monitor 4×3 esistente con i 4 quadranti. Per ogni Turtle visualizzare:
- id e stato `PREPARAZIONE/SCAVO/RIENTRO/BASE/BLOCCATO/INCOMPLETO/ERRORE/OFFLINE`;
- versione miner/agent e disponibilità aggiornamento;
- ultima posizione **stimata** e ora di ricezione; niente posizione apparentemente in tempo reale se il packet è vecchio;
- percentuale progresso, fuel, quota, ostacoli, error latch e conteggio gallerie sospese;
- eventuale fase amministrativa `PENDING/STAGED/WAITING_AT_BASE/DONE/FAILED`.

Per operazioni importanti si usa inizialmente il terminale del Computer 54 con conferma testuale. Eventuali pulsanti sul monitor saranno una fase successiva, non prioritaria. Migliorare la telemetria: attualmente il miner invia coordinate complete periodiche, mentre heartbeat ripete quelle vecchie.

## Milestone implementative

A. **Progettazione**: questo file. Nessuna modifica ai programmi attualmente in esecuzione.
B. **Agente remoto + bootstrap non distruttivo**: provarlo su una Turtle ferma (es. N02), mantenendo mining disabilitato.
C. **Servizio admin sulla centrale 54**: PING/STATUS con ACK; verificare corrispondenza ID/nomi senza controllare movimenti.
D. **Update OTA staged e rollback**: prima su una Turtle ferma, poi altre ferme; i manifest devono essere versionati.
E. **Avvio controllato**: prima un'altra Turtle, poi 2–3, poi un fronte per volta dopo collaudo.
F. **Gestione versioni/checkpoint durante lavorazioni lunghe**, audit e UI estesa.

**NOTA:** questo è il piano e non una funzionalità già funzionante. Le fasi B–F richiedono codice nuovo e prove in Minecraft.


## Prima implementazione pubblicata - PING remoto (16 novembre 2026)

**File scritti e verificati su GitHub, NON ancora installati/collaudati nel mondo Minecraft:**

- `scripts/turtle/megazero_admin_agent.lua` — AGENT v1.0: ascolta su `megazero.admin.v1` solamente i comandi `PING`/`STATUS` provenienti dall'ID centrale `cfg.central` (54), con target unit/site/computerID espliciti. Risponde con `admin_reply` e `request_id` per ACK legato alla richiesta; riporta fuel, latch, versioni e checkpoint **salvato**, non posizione fisica garantita.
- `scripts/turtle/megazero_boot.lua` — BOOT v1.1: carica l'agente soltanto se installato e lo esegue parallelamente alla telemetria; **non modifica la logica miner/autostart esistente**. Le Turtle senza agente funzionano ancora con il boot precedente già installato.
- `scripts/control/megazero_control.lua` — CONTROL v1.1: dashboard 40 Turtle preservata con `PING REMOTO` nella scheda selezionata; legame risposta con ID computer reale, sender Rednet, request_id, unit e sito; mostra versioni, checkpoint ed eventuale errore. Nessun comando che muova Turtle.
- `scripts/turtle/installa_admin.lua` — installazione locale di agente e boot v1.1 **solo a miner fermo e disabilitato**, con controllo corrispondenza sigla, compilazione Lua, file temporanei e backup boot. Non tocca startup/config/miner e non esegue reboot.
- `scripts/control/installa_admin_centrale.lua` — sostituisce `/megazero_control` soltanto su computer 54, scaricando/compilando v1.1 e salvando backup; non cancella `/.megazero_control_db`, né modifica startup. Non riavvia da solo.

**Sequenza di collaudo (una azione per volta):**

1. Sul Computer 54: fermare solo il programma della dashboard con Ctrl+T, poi `wget run https://raw.githubusercontent.com/mycolbraga/MEGAZERO/registro/megazero/scripts/control/installa_admin_centrale.lua`. Verificare output; quindi `megazero_control` ripristina la dashboard aggiornata. **N01 resta in scavo indipendentemente dalla UI centrale.**
2. Su N02: fermare solo il vecchio boot con Ctrl+T; verificare che `miner_autostart=false`; `wget run https://raw.githubusercontent.com/mycolbraga/MEGAZERO/registro/megazero/scripts/turtle/installa_admin.lua N02`; controllare il messaggio e solo successivamente `reboot`. Non attiva scavo.
3. Dal monitor centrale: toccare N02, poi `TOCCA QUI: PING REMOTO`. Attendere `PING OK` e visualizzare i dati. Se c'e' assenza di ACK, nessuna altra azione avviata, verificare stato, modem, ID, chunk.
4. Dopo conferma in gioco: estendere installazione locale del ricevitore alle altre Turtle **ferme e con scavo disabilitato**. **N01 non deve essere interrotta ne' aggiornata mentre scava.**
5. Milestone seguente: realizzare `CHECK_UPDATE`, staged OTA, rollback e autorizzazioni di avvio mirato, senza recuperare materiale esterno al settore e senza azzerare i checkpoint.

**Risultato tecnico della verifica pre-pubblicazione:** cinque file presenti nel branch `registro/megazero`, firme e interfacce coerenti, controlli statici di struttura e delimitatori passati. La compilazione Lua effettiva sara' controllata dagli installatori in CC:Tweaked, poi dal test reale.
