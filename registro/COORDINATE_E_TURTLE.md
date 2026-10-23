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
| Stronghold / End Portal | ~1436,23,1044; 0/12 occhi al rilevamento, due biblioteche |
| Tetto Nether | 1079,7,3091 |
| Monumento oceanico | 1136, Z2752 |
| Mob farm aerea | spiaggia 1841,62,2792 → torre 1700,151,2949 |
| Ex querceto 8 posti (solo riferimento storico) | X 1913,1920,1927,1934; Z 2735/2728. La farm originaria è diventata l'attuale farm alberi 2×2. |
| Scavo Turtle 32×16 | partenza 1890,75,2766; stop a Y39, stato da verificare |

## Nuova farm alberi 1×1 (struttura separata)

**Solo struttura costruita**, confermato il 23 ottobre 2026. **Nessun automatismo Turtle ancora realizzato** per questa farm. La farm 1×1 è distinta dalla 2×2 Pale Oak. Il lavoro concordato è **fare due nuovi programmi adattando i file originali** `scripts/turtle/querceto2.txt` e `scripts/turtle/abeteto_8.lua` alle nuove coordinate, senza sovrascrivere i sorgenti storici.

**Informazioni necessarie prima dell'adattamento:** coordinate X/Y/Z di partenza della nuova Turtle, verso cui guarda, posizione della cassa di rifornimento e del punto di scarico, coordinate di tutti i tronchi 1×1 e configurazione dei corridoi/ostacoli. I due codici originali sono vincolati alla precedente geometria: `HOME_X/Y/Z`, `LANE_Z`, `X_TREES`, `SOUTH_Z`/`NORTH_Z`, le sequenze di spostamento da 7 blocchi e scarico fisso a (1911,66,2733); adattare anche controlli e messaggi associati. **Non trasferire automaticamente le vecchie coordinate.**

**Base nuova Turtle (confermata da screenshot e giocatore il 23/10/2026):** giocatore **in piedi sopra la Turtle** a **X=1903, Y=67, Z=2715**; la Turtle stessa occupa il blocco **X=1903, Y=66, Z=2715** (un blocco sotto i piedi del giocatore). **Cassa dietro alla base:** giocatore in piedi sulla cassa a **X=1903, Y=67, Z=2716**, dunque cassa a **X=1903, Y=66, Z=2716**. La cassa è quindi a **SUD (+Z)** rispetto alla Turtle. L'indicatore HUD **N** descrive la direzione del *giocatore*, **non conferma il verso in cui guarda la Turtle**: orientamento Turtle ancora da verificare. Per avere la cassa dietro alla Turtle come negli script, la Turtle dovrebbe guardare **NORD (−Z)**.

**Posizioni di piantagione 1×1 confermate dal giocatore (23/10/2026):** nel secondo screenshot il giocatore era **in piedi sul primo blocco destinato all'albero** a X=1899, Y=68, Z=2712; le altre sette coordinate sono state fornite direttamente. Non confondere più queste posizioni con una semplice indicazione del mirino.

| Albero | X | Y | Z | Fila |
| --- | ---: | ---: | ---: | --- |
| 1 | 1899 | 68 | 2712 | Ovest |
| 2 | 1899 | 68 | 2705 | Ovest |
| 3 | 1899 | 68 | 2698 | Ovest |
| 4 | 1899 | 68 | 2691 | Ovest |
| 5 | 1907 | 68 | 2691 | Est |
| 6 | 1907 | 68 | 2698 | Est |
| 7 | 1907 | 68 | 2705 | Est |
| 8 | 1907 | 68 | 2712 | Est |

**Geometria calcolata:** due file parallele X=1899 e X=1907, quattro postazioni per fila; Z=2712, 2705, 2698, 2691 (passo 7); distanza orizzontale fra file X=8. Corridoio centrale ipotizzato sull'asse **X=1903**: 4 blocchi fra corsia e ciascun tronco. Se la Turtle inizia effettivamente a Z=2715 rivolta a nord, la prima coppia è 3 blocchi avanti. **La posizione X=1903 Z=2715 è dedotta dal primo screenshot, non ancora confermata.**

**Quote reali:** Turtle blocco **Y=66**, terreno d'impianto **Y=67** perché il giocatore stava in piedi sui blocchi di terra a **Y=68**; il primo tronco/sapling è quindi collocato a **Y=68**. Il programma dovrà gestire il **dislivello tra Turtle (Y=66) e tronchi (Y=68)**, senza scambiare HUD giocatore e quota dei blocchi.

**Da verificare prima di adattare/avviare i due programmi:** direzione in cui guarda **fisicamente la Turtle** (la direzione HUD N non basta), posizione effettiva dello scarico in acqua, accessibilità del corridoio e spazio necessario alla salita. Percorrenza verso **−Z** e offset laterali **±4 X**; non basta cambiare i numeri superficiali.

**Stato script nuovi:** NON ANCORA GENERATI; le **otto postazioni e la base della Turtle sono note**, rimangono da verificare orientamento della Turtle, percorso/dislivello e punto di scarico. Gli originali `querceto2.txt` e `abeteto_8.lua` restano invariati.

## Turtle scortecciatrice dedicata

Script originale: [`scripts/turtle/scorteccia.lua`](../scripts/turtle/scorteccia.lua), fornito dal giocatore il 23/10/2026. **Non è la Turtle che abbatte i tre Pale Oak**: è una seconda automazione.

- Ingresso: cassa **sopra** la Turtle, tronchi vanilla con ID `minecraft:*_log`.
- Attrezzo: ascia nello **slot 2**; gli altri slot devono essere vuoti alla partenza.
- Spazio davanti: libero per piazzare il tronco, usare l'ascia, ispezionare il blocco e raccoglierlo.
- Uscita: cassa **sotto** la Turtle; in caso di uscita piena attende e riprova ogni 3 secondi.
- Se manca input attende 2 secondi. Ogni 16 pezzi stampa il conteggio.
- Controlla il risultato `minecraft:stripped_*_log`; interrompe se inserito un oggetto non valido o se l'operazione fallisce.
- **Coordinate Turtle scortecciatrice non ancora registrate**, non inventarle.
