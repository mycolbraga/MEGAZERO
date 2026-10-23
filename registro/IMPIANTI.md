# Stato degli impianti

Snapshot: 23 ottobre 2026.

| Impianto | Stato | Dettagli |
| --- | --- | --- |
| Smelter | **COMPLETATO e provato** | 10 fornaci tradizionali in parallelo; alimentazione con lava; secchi vuoti recuperati e reimmessi nel ciclo; prodotti in RS. |
| Lava e riempimento secchi | **COMPLETATI** | Entrambi automatici; non riprogettare. |
| Cottura continua RS | **COMPLETATA** | Exporter filtrato per i materiali da cuocere sempre. |
| Cottura su richiesta RS | **COMPLETATA e provata** | Processing Pattern: test Cobblestone → Stone concluso. Autocrafter rivolto **direttamente alla cassa**, non all'Exporter. |
| Cobblestone infinita | **COMPLETATA** | Produzione automatica confermata. |
| Farm alberi 2×2 (ex querceto) | **AUTOMATIZZATA, oggi usata per Pale Oak** | La precedente area del querceto è stata convertita alla coltivazione di alberi 2×2; attualmente Pale Oak, 3 postazioni, Bone Meal, taglio e ripiantagione con Turtle. Ultima versione dello script consegnata V4; stato esatto del collaudo da documentare. **Non esiste un vecchio querceto 1×1 separato da aggiungere alle farm attive.** |
| Scortecciatura Pale Oak | **COMPLETATA secondo il giocatore** | Seconda Turtle con programma originale `scripts/turtle/scorteccia.lua`: tronchi dalla cassa sopra, ascia slot 2, scarico cassa sotto; lavora in ciclo continuo. Non proporla come lavoro mancante. |
| Refined Storage | **OPERATIVO** | Grid/controller; almeno due dischi 16K in precedenza; Importer, Exporter, Regulator; rete a distanza smelter con Transmitter/Receiver. Upgrade 64K da verificare. |
| Trading Hall | **32 POSTAZIONI ATTIVE** | Zombificazione integrata; espansione a 72 progettata, non confermata finita. |
| Slime farm | **COMPLETATA — PASSIVA** | Il giocatore conferma produzione **passiva e automatica**, senza intervento manuale; scavo 16×16 fino a bedrock; collegata a RS; 71 sticky piston completati. |
| Mob farm XP | **XP OPERATIVA; DROP ANCORA MANUALI** | Kill **manuale da preservare** per XP/Mending; livello 28→38 in ~5 min, riparazioni Mending, drop vari e witch. Il giocatore conferma che **raccolta/gestione dei drop è manuale**. **DA PROGETTARE** scarico, smistamento verso RS dei materiali utili e smaltimento automatico delle eccedenze/oggetti indesiderati. |
| Farm oro Nether | **OPERATIVA, CON LAVORI APERTI** | Confermati 70 lingotti/10 min (~420/h). Conversione automatica delle pepite in lingotti **ancora da realizzare**; collegamento a Refined Storage **ancora da realizzare** (confermato 23/10/2026). |
| Canna da zucchero | **COMPLETATA, AUTOMATIZZATA E COLLEGATA A RS** | Integrata nel complesso delle 30 farm: **taglio con Observer e pistoni**, raccolta con **carrello con tramoggia e tramogge**, scarico collegato a **Refined Storage**; confermato 23/10/2026. La vecchia farm separata 18×12 con flying machine **non esiste più**. |
| Funghi marroni | **COMPLETATA E COLLAUDATA — confermata 23/10/2026** | Stanza 16×16 con 4 funghi madre, 32 dispenser d'acqua e funzionamento con timer. Il giocatore conferma che la struttura è ancora questa, senza modifiche. |
| Hoglin | **OPERATIVA — RESA ATTUALMENTE BUONA, DA MONITORARE** | Piattaforma 12×10, quattro funghi scarlatti; spawn verificato. Resa migliorata rispetto all'inizio e al momento più che soddisfacente (conferma del giocatore 23/10/2026). **Continuare a osservare la produzione**, senza modifiche necessarie adesso. Modalità di raccolta di carne/pelle non ancora documentata. |
| Patate | **COMPLETATA — AUTOMATICA E COLLEGATA A RS** | Produzione nel complesso delle 30 farm; **villager raccolgono automaticamente le patate e il prodotto viene inviato a Refined Storage**, confermato il 23/10/2026. Una vecchia farm separata era stata rimossa per la stalla di Gino (solo nota storica). Numero di moduli attuali non ancora documentato. |
| Farm alberi 1×1 (nuova) | **SOLO STRUTTURA COSTRUITA — AUTOMAZIONE DA FARE** | Seconda farm 1×1 costruita, confermato 23/10/2026. **Non ancora automatizzata**: occorre adattare alle nuove coordinate i programmi originari `querceto2.txt` e `abeteto_8.lua`, preservando gli originali. Posizioni Turtle/alberi/viale/scarico, orientamento e geometria attuale ancora da rilevare. Distinta dalla farm 2×2 già operativa. |
| Script querceto/abeteto a 8 alberi | **ARCHIVIATI** | `querceto2.txt` e `abeteto_8.lua` sono programmi storici; non implicano che le vecchie strutture esistano ancora separatamente o che la nuova farm 1×1 usi già quegli script. |
| Monumento oceanico | **ESPLORATO — STATO CONFERMATO 23/10/2026** | X≈1136, Z≈2752; recuperate **26 spugne** e **8 blocchi d'oro** dalla stanza del tesoro. Il giocatore conferma nessun ulteriore intervento o recupero rispetto alla prima esplorazione. |
| Metro mob farm | **REALIZZATA** | ~150 blocchi orizzontali, +110 Y, tempo circa 1:30. |

### Risoluzioni e preferenze già confermate

- Fix datapack per loot foglie Pale Oak su Vanilla Backport: drop ripristinati.
- Overlay Litematica «Lista Materiali, chunk rimanenti (7)»: risolto.
- RS: target scorte circa **500 per prodotto**, Detector installati **gradualmente** in base alla necessità; controllo dell'ingresso, non grande impianto di compostaggio. Eventuali eccedenze possono rimanere sul campo e despawnare.
- Preferenza fornaci tradizionali; Powered Furnace scartata; Stone Liquefier resta nel progetto.
