# Coordinate e Mining Turtle

## Farm alberi 2×2 (ex querceto; attualmente Pale Oak)

Il giocatore conferma il 23/10/2026 che **la vecchia farm del querceto è stata riconvertita per gli alberi 2×2**, oggi usata per Pale Oak. Non è una struttura aggiuntiva rispetto alle tre postazioni qui sotto. La compatibilità dei programmi con altre specie 2×2 andrà verificata prima dell'uso.

**Casa Turtle:** X=1910 Y=67 Z=2732, rivolta a **EST**; chest dietro (OVEST). **Corsia confermata:** Z=2731. **Scarico:** Turtle sopra acqua a (1911,67,2733), acqua Y=66.

| Postazione | Riferimento giocatore | Quadrato dedotto dalla chat* |
| --- | --- | --- |
| P1 | 1914,67,2729 | X 1914–1915; Z 2729–2730 |
| P2 | 1922,67,2732 | X 1922–1923; Z 2732–2733 |
| P3 | 1932,67,2729 | X 1932–1933; Z 2729–2730 |

*Dagli screenshot, con giocatore sempre sul blocco in basso a sinistra; verificare con ispezione reale prima di modificare i percorsi.*

**Ciclo richiesto:** raggiungere P1→P2→P3; se ci sono tronchi tagliare **tutto il legno**, inclusi i rami nascosti, eliminando solo le foglie necessarie per accedervi; se ci sono 0–4 sapling completarli in quadrato e usare Bone Meal fino alla crescita; tagliare e ripiantare quattro germogli; **non** ricontrollare subito la stessa pianta. Se finisce Bone Meal lascia germogli e prosegue. Scorte: 16 sapling, 128 Bone Meal, 2 secchi di lava disponibili. Ritorno alla base per rifornimento e scarico. Errori con coordinate, senza proseguire alla cieca. Modalità prova/giro/avvia, senza ricognizioni e passaggi ripetuti.

**Script:** `paleoak_3_v4_auto.lua` (ultima versione consegnata, collaudo definitivo in partita non confermato), `querceto2.txt` e `abeteto_8.lua` (storici).

## Altri punti

| Luogo | Coordinate / note |
| --- | --- |
| Stronghold / End Portal | **Stato confermato 23/10/2026:** circa X=1436, Y=23, Z=1044; portale trovato ma **ancora NON attivato**, 0/12 occhi segnalati, **due biblioteche** individuate. Nessun ulteriore avanzamento rispetto all'esplorazione precedente. |
| Tetto Nether | 1079,7,3091 |
| Monumento oceanico | 1136, Z2752 |
| Mob farm aerea | spiaggia 1841,62,2792 → torre 1700,151,2949 |
| Ex querceto 8 posti (solo riferimento storico) | X 1913,1920,1927,1934; Z 2735/2728. La farm originaria è diventata l'attuale farm alberi 2×2. |
| Scavo Turtle 32×16 | **COMPLETATO**, confermato il 23/10/2026. Partenza 1890,75,2766; profondità-obiettivo del progetto Y39 (quota finale non nuovamente precisata). |

## Nuova farm alberi 1×1 (struttura separata)

**Solo struttura costruita**, confermato il 23 ottobre 2026. **Nessun automatismo Turtle ancora realizzato** per questa farm. La farm 1×1 è distinta dalla 2×2 Pale Oak. Il lavoro concordato è **fare due nuovi programmi adattando i file originali** `scripts/turtle/querceto2.txt` e `scripts/turtle/abeteto_8.lua` alle nuove coordinate, senza sovrascrivere i sorgenti storici.

**Informazioni necessarie prima dell'adattamento:** coordinate X/Y/Z di partenza della nuova Turtle, verso cui guarda, posizione della cassa di rifornimento e del punto di scarico, coordinate di tutti i tronchi 1×1 e configurazione dei corridoi/ostacoli. I due codici originali sono vincolati alla precedente geometria: `HOME_X/Y/Z`, `LANE_Z`, `X_TREES`, `SOUTH_Z`/`NORTH_Z`, le sequenze di spostamento da 7 blocchi e scarico fisso a (1911,66,2733); adattare anche controlli e messaggi associati. **Non trasferire automaticamente le vecchie coordinate.**

**Base nuova Turtle (confermata da screenshot e giocatore il 23/10/2026):** giocatore **in piedi sopra la Turtle** a **X=1903, Y=67, Z=2715**; la Turtle stessa occupa il blocco **X=1903, Y=66, Z=2715** (un blocco sotto i piedi del giocatore). **Cassa dietro alla base:** giocatore in piedi sulla cassa a **X=1903, Y=67, Z=2716**, dunque cassa a **X=1903, Y=66, Z=2716**. La cassa è quindi a **SUD (+Z)** rispetto alla Turtle. L'indicatore HUD **N** descriveva la visuale del giocatore, ma **il giocatore ha ora confermato espressamente che la Turtle guarda NORD (−Z), con la cassa alle spalle a SUD (+Z)**. Orientamento **VERIFICATO**.

**Otto posizioni X/Z dei terreni confermate dal giocatore (23/10/2026).** Le terne qui sotto riportano le **coordinate HUD del giocatore in piedi sulle postazioni**, così come comunicate (Y HUD=68); **non usare Y=68 come quota del blocco di terra**. L'utente ha corretto esplicitamente il dislivello: **Turtle e terra degli alberi sono sullo stesso livello; il germoglio/tronco inizia solo 1 blocco sopra**. Per il percorso utilizzare la quota fisica della Turtle come quota del terreno, non un salto di due blocchi.

| Albero | X | Y HUD giocatore | Z | Fila |
| --- | ---: | ---: | ---: | --- |
| 1 | 1899 | 68 | 2712 | Ovest |
| 2 | 1899 | 68 | 2705 | Ovest |
| 3 | 1899 | 68 | 2698 | Ovest |
| 4 | 1899 | 68 | 2691 | Ovest |
| 5 | 1907 | 68 | 2691 | Est |
| 6 | 1907 | 68 | 2698 | Est |
| 7 | 1907 | 68 | 2705 | Est |
| 8 | 1907 | 68 | 2712 | Est |

**Geometria calcolata:** due file parallele X=1899 e X=1907, quattro postazioni per fila; Z=2712, 2705, 2698, 2691 (passo 7); distanza fra file X=8. Corridoio centrale ipotizzato sull'asse **X=1903**: 4 blocchi fra corsia e ciascun tronco. **Base Turtle X=1903 Z=2715 confermata** dal giocatore (screenshot in piedi sopra la Turtle), a tre blocchi lungo Z dalla prima coppia. La Turtle guarda **NORD (−Z)**, come confermato direttamente dal giocatore.

**CORREZIONE ESPLICITA DEL GIOCATORE — prevale sulle deduzioni dagli HUD:** la **Turtle è alla stessa altezza della terra degli alberi**; il tronco/sapling cresce **un solo blocco più in alto**. La Turtle occupa il blocco registrato a **Y=66**; per il percorso considerare quindi la **terra anch'essa a Y=66** e il **primo tronco/sapling a Y=67**. Le coordinate HUD Y=68 rilevate sopra i terreni non devono essere interpretate come coordinate del blocco di terra. **Non programmare una salita artificiale di due blocchi.**

**Da verificare prima di adattare/avviare i due programmi:** posizione effettiva dello **scarico in acqua** e accessibilità del corridoio. Orientamento **NORD confermato**. Percorrenza verso **−Z** e offset laterali **±4 X**; **nessuna salita di due blocchi**. Non basta cambiare i numeri superficiali.

**Scarico identificato dal giocatore (23/10/2026):** **un blocco davanti alla base della Turtle**; dato che guarda NORD, la posizione di scarico è **X=1903, Y=66, Z=2714**, con `dropDown()` verso il blocco inferiore **X=1903, Y=65, Z=2714**. **La presenza dell'acqua a Y65 è da verificare con `prova`**, non ancora collaudata.

**Script nuovi GENERATI ma NON ancora collaudati in gioco:** [`querceto_1x1.lua`](../scripts/turtle/querceto_1x1.lua) e [`abeteto_1x1.lua`](../scripts/turtle/abeteto_1x1.lua), copie adattate degli originali. Percorso NORD a Z decrescente, due file est/ovest e quota di lavoro Y67; la Turtle sale di un blocco da Y66 per raggiungere la base dei tronchi e ridiscende alla base Y66 prima dello scarico. **Prima di avviare `giro` o `avvia`, eseguire la `prova` senza tagli.** Gli originali `querceto2.txt` e `abeteto_8.lua` restano invariati.

## Turtle scortecciatrice dedicata

Script attuale: [`scripts/turtle/scorteccia.lua`](../scripts/turtle/scorteccia.lua), derivato da quello fornito dal giocatore il 23/10/2026. **VERSIONE CON RICAMBIO AUTOMATICO DELLE ASCE DI FERRO COLLAUDATA E CONFERMATA FUNZIONANTE DAL GIOCATORE il 25/10/2026. Conservare come versione stabile e non modificare senza richiesta.** Non è la Turtle che abbatte i tre Pale Oak: è una seconda automazione.

- Ingresso: cassa **sopra** la Turtle con tronchi vanilla `minecraft:*_log` **e circa 10 asce di ferro di ricambio**; le asce possono essere mescolate ai tronchi, il programma le cerca fra gli slot.
- Attrezzo: **slot 2** della Turtle; al consumo recupera automaticamente una nuova ascia di ferro dalla cassa superiore e attende se non sono disponibili ricambi. **Slot 1** per i tronchi, **slot 3** per buffer temporaneo; gli altri slot vuoti alla partenza.
- Spazio davanti: libero per piazzare il tronco, usare l'ascia, ispezionare e raccogliere.
- Uscita: cassa **sotto** la Turtle; se piena, attende e riprova ogni 3 secondi.
- Se mancano tronchi attende 2 secondi. Ogni 16 pezzi stampa il conteggio.
- Controlla il risultato `minecraft:stripped_*_log`; blocca la lavorazione se la scortecciatura non riesce.
- **Il codice prima della modifica resta recuperabile nella cronologia Git**; non sovrascrivere la versione attuale funzionante.
- **Coordinate Turtle scortecciatrice non ancora registrate**, non inventarle.

### Abeti 1×1 — versione derivata dalle betulle (26/10/2026)

Creato [`scripts/turtle/abeteto_nuove_1x1.lua`](../scripts/turtle/abeteto_nuove_1x1.lua), copiando e adattando **il programma delle betulle più recente**, senza toccare il vecchio `abeteto_1x1.lua`. Geometria invariata: Turtle 1903,66,2715 NORD, chest 1903,66,2716; alberi X1899/1907 a Z2712/2705/2698/2691; **`WORK_Y=67` CORRETTO il 26/10**: la Turtle e il terreno sono entrambi a Y66; il primo tronco è a Y67. La confusione con Y68 nasce dalle coordinate HUD del giocatore in piedi sul blocco. Script aggiornato per salire e ridiscendere una sola volta; eseguire comunque `prova`. Rifornimento `spruce_sapling`, Bone Meal, lava; scarico in acqua, preserva il legno raccolto; nuova modalità `avvia` a ciclo continuo, pausa 1 s. Stato: **script creato, NON collaudato in partita**. I tre modi sono `prova`, `giro`, `avvia` e serve superare `prova` prima di eseguire gli altri.

### Betulle nella nuova farm 1×1 — aggiornamento 25/10/2026

Il programma per betulle è [`scripts/turtle/betulle_nuove_1x1.lua`](../scripts/turtle/betulle_nuove_1x1.lua).
**NON usare la vecchia geometria del querceto a X1910.**

Coordinate della nuova Turtle: **1903,66,2715 NORD**, cassa dietro **1903,66,2716 SUD**.
Alberi alle file **X1899 e X1907**, Z **2712,2705,2698,2691**.
Il giocatore ha precisato il 25 ottobre che le piantine sono a **Y68**, in contrasto col valore **Y67** dedotto nel registro del 23 ottobre: applicata Y68 al nuovo script, da controllare in gioco in modalità `prova` prima di procedere.
Bone meal e germogli sono prelevati dalla cassa, scarico a **1903,66,2714** verso acqua sotto (Y65).
**Stato: file archiviato su GitHub, collaudo nel mondo NON confermato.**
