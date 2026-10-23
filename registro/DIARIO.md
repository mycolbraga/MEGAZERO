# Diario MegaZero

Annotare nuovi progressi con **data, modifica, prova e stato**, senza inventare collaudi.

## 23 ottobre 2026 — Registro GitHub e smelter

- **Punto 12 — orientamento della Turtle nuova farm 1×1 confermato:** la Turtle a X=1903, Y=66, Z=2715 **guarda NORD (verso Z decrescente)**, con cassa alle sue spalle a X=1903, Y=66, Z=2716 (SUD). L'unica informazione infrastrutturale essenziale ancora da rilevare è il **punto di scarico**, poi preparare le due versioni adattate degli script 1×1 senza toccare gli originali.

- **RETTIFICA DEL GIOCATORE — altezza farm alberi 1×1:** la Turtle è **allo stesso livello della terra degli alberi**; la base del tronco/sapling è **un solo blocco sopra**. Corregge e **sostituisce** la deduzione precedente 'Turtle Y66, terreno Y67, tronco Y68' e ogni indicazione che occorra superare due blocchi di dislivello. Altezza Turtle registrata Y66, terreno da considerare Y66, tronco Y67; Y68 nella lista è quota HUD del giocatore durante il rilievo, non quota tronco.

- **Punto 12 — quota Turtle confermata:** screenshot HUD del giocatore **in piedi sopra la Turtle** a X=1903, Y=67, Z=2715: il **blocco Turtle è a 1903,66,2715**, con cassa a **1903,66,2716**. Gli 8 terreni di piantagione sono a **Y=67**, perché il giocatore era in piedi su di essi a Y=68; i tronchi occupano la quota Y=68 alla base. Resta da confermare la direzione effettiva della Turtle: il simbolo HUD N descrive solo l'orientamento del giocatore. Da adattare dislivello e scarico. Questa conferma supera le precedenti annotazioni incerte sulla base.

- **Punto 12 — coordinate definitive dei punti alberi 1×1:** il giocatore conferma di essere in piedi sul terreno destinato all'albero nello screenshot a **1899,68,2712**. Fornite altre 7 posizioni: **1899,68,2705 / 2698 / 2691** e **1907,68,2691 / 2698 / 2705 / 2712**. Totale 8 alberi, due file X1899 e X1907, quattro righe distanti 7 su Z, asse centrale stimato X1903. Restano da verificare quota e orientamento della Turtle e scarico acqua prima di modificare i due script; gli originali non sono stati toccati.

- **Nuova farm alberi 1×1, primo terreno a sinistra:** secondo screenshot mostra il giocatore a **X=1899, Y=68, Z=2712**, rivolto a nord, con mirino su un blocco di terra nel canale d'acqua. Coordinate esatte del blocco di terra ancora da confermare, non confondere con HUD giocatore. Nessun programma adattato ancora.

- **Nuova farm 1×1, primo riferimento visivo:** screenshot HUD X=1903 Y=67 Z=2716, giocatore sopra la cassa, Turtle a un blocco davanti. Indicazione Nord suggerisce Turtle a X=1903 Z=2715, da confermare, così come quota Y e orientamento della Turtle. Le coordinate degli alberi non sono ancora state fornite; nessuno script modificato.

- **Ulteriore precisazione punto 12 — nuova farm 1×1:** il giocatore conferma **solo la struttura costruita**, non l'automazione. Occorre prendere i programmi storici `querceto2.txt` e `abeteto_8.lua` e adattarne le coordinate per la nuova farm. Controllati i sorgenti GitHub: oltre a home e coordinate alberi, contengono geometria del viale, spostamenti fissi (7 blocchi) e punto di scarico in acqua. Preservare i programmi originali e attendere coordinate/geometria della nuova struttura prima di produrre le due versioni aggiornate.

- **Revisione punto 12 — Alberi:** correzione del giocatore: **l'ex querceto è l'attuale farm per alberi 2×2**, usata per Pale Oak. Ha **appena costruito una seconda farm per gli alberi 1×1**. Non esistono tre farm distinte «querceto storico / Pale Oak / nuova 1×1». Gli script precedenti restano archiviati. Per la nuova 1×1 non sono ancora documentati specie, coordinate e automazione.

- **Revisione punto 11 — Patate:** il giocatore conferma che la produzione attuale fa parte del **complesso delle 30 farm**. La precedente nota sulle farm di patate separate è storica; una struttura originaria era stata rimossa per la stalla di Gino. Il giocatore conferma ora **raccolta automatica con villager e trasferimento delle patate direttamente a Refined Storage**: punto 11 completato; resta solo non precisato il numero di moduli attuali.

- **Revisione punto 10 — Hoglin farm:** confermata struttura 12×10 con quattro funghi scarlatti; resa migliorata, attualmente più che soddisfacente. **Continuare a monitorare l'andamento**, senza modifiche immediate. Modalità di raccolta carne/pelle non specificata.

- **Revisione punto 9 — Farm funghi marroni:** confermata dal giocatore ancora invariata: stanza 16×16, quattro funghi madre, 32 dispenser d'acqua e timer. Impianto completato e collaudato.

- **Revisione punto 8 — Canna da zucchero COMPLETATA:** il giocatore conferma che la vecchia farm separata 18×12 con flying machine non esiste più. La produzione è **integrata nel complesso delle 30 farm**, con **taglio automatico Observer+pistoni**, raccolta con **carrello a tramoggia e tramogge** e **collegamento già operativo a Refined Storage**. Nessun lavoro di raccolta/collegamento RS da riproporre.

- **Revisione punto 7 — Farm d'oro Nether:** confermata resa registrata di circa 70 lingotti/10 minuti, mentre la trasformazione automatica delle pepite e il collegamento a Refined Storage non sono ancora realizzati.

- **Revisione registro, punto 6 — Mob farm XP:** il giocatore conferma che **tutti i drop sono ancora gestiti manualmente**. Richiesta progettazione futura di un sistema di **scarico/smistamento/smaltimento automatico**, mantenendo le uccisioni manuali per XP/Mending. Lavoro aperto, nessun impianto drop automatico ancora confermato.

- **Revisione registro, punto 5 — Slime farm confermata:** completata e **produce passivamente**, senza intervento manuale; già collegata a Refined Storage.

- **Revisione registro, punto 4 — Trading Hall:** il giocatore conferma **ancora 32 postazioni attive**; l'espansione prevista a 72 non è conclusa. Nessun avanzamento intermedio confermato.

- **Revisione registro, punto 3 — Refined Storage confermato dal giocatore:** sistema RS operativo; gestione degli ingressi tramite Detector da implementare gradualmente, target circa 500 unità per risorsa; nessuna grande linea di smaltimento. Restano **non specificati** numero di Detector già installati ed eventuali ampliamenti dei dischi.

- Aggiunto il programma originale **`scorteccia(1).lua`** consegnato dal giocatore, archiviato senza modifiche logiche come `scripts/turtle/scorteccia.lua`. Scortecciatura con Turtle separata: tronchi dalla cassa sopra, ascia slot 2, output nella cassa sotto.

- Repository GitHub `mycolbraga/MEGAZERO` creato dal giocatore; branch `registro/megazero` creato e documentazione iniziale pubblicata.
- Smelter 10 fornaci e circuito lava/secchi/RS già funzionanti.
- Test autocrafting Cobblestone → Stone riuscito, Autocrafter orientato verso **cassa** e non Exporter.
- Farm Pale Oak e scortecciatura dichiarate già automatizzate dal giocatore; versione live non ulteriormente verificata.
- Inizio produzione pietra liscia per Stark Estate; scorte prodotte da verificare.

## 22 ottobre 2026 — Pale Oak, Litematica e cottura

- Pale Oak Vanilla Backport: datapack corretto per drop foglie, sapling tornati disponibili.
- Turtle Pale Oak passata da 8 querce tradizionali a 3 alberi 2×2; ricerca rami iniziale troppo lenta; V4 automatica consegnata.
- Overlay Litematica «Lista Materiali, chunk rimanenti (7)» rimosso.
- Rete RS wireless smelter completata.

## Precedenti

Trading Hall 32 postazioni, farm slime, mob farm XP, oro, funghi marroni, Hoglin. **Nota storica:** la vecchia canna da zucchero 18×12 è stata successivamente incorporata nel complesso delle 30 farm. Stato corrente in `IMPIANTI.md`.
