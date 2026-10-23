# Diario MegaZero

Annotare nuovi progressi con **data, modifica, prova e stato**, senza inventare collaudi.

## 23 ottobre 2026 — Registro GitHub e smelter

- **Revisione punto 17 — galline:** il giocatore conferma **gestione manuale delle galline**, ma **raccolta delle uova automatica e collegata a Refined Storage**. La distinzione è essenziale: **pollo e piume non risultano automatizzati**, e il loro invio a RS non è confermato. Prossimo controllo: cactus.

- **Revisione punto 17 — mucche e maiali:** il giocatore conferma che la farm delle **mucche NON è automatizzata**, e funziona manualmente **come quella dei maiali**. Registrare entrambe come farm esistenti e operative, a **gestione manuale**. Produzioni previste: mucche carne/pelle, maiali carne. Non attribuire ad alcuna collegamento a Refined Storage senza conferma. Prossima verifica: galline.

- **Revisione punto 17 — grano/pane:** il giocatore conferma che la farm del complesso delle 30 farm è **costruita, automatizzata e collegata a Refined Storage**, ma produce **SOLO PANE**. Non contare il grano come prodotto separato della farm né presumere che entri in RS.

- **Revisione punto 17 — carote, successiva conferma:** l'**unica** farm di carote costruita è **automatizzata e collegata a Refined Storage**, come la farm delle patate. La seconda farm inizialmente prevista resta **NON COSTRUITA**. La conferma aggiorna la precedente nota che dava l'automazione da verificare.

- **Revisione punto 17 — carote:** nel complesso delle 30 farm il giocatore conferma **una sola farm costruita**, mentre la seconda originariamente prevista **non è stata costruita**. Non segnare automaticamente completate tutte e due, né presumere automazione e collegamento a Refined Storage per quella esistente: informazioni ancora da verificare.

- **Revisione punto 17 — bacche rosse (Sweet Berries), complesso delle 30 farm:** confermato dal giocatore che la farm è **costruita, automatizzata e collegata a Refined Storage**. Stato COMPLETATA. Modalità tecnica di raccolta non documentata; prossimo controllo: carote.

- **Revisione punto 17 — lana, complesso delle 30 farm:** il giocatore conferma che la farm lana è **già costruita, automatizzata e collegata direttamente a Refined Storage**. Stato COMPLETATA; metodo tecnico di raccolta non ancora specificato. La farm delle bacche rosse è il prossimo punto da verificare.

- **Revisione punto 16 — Gino:** il giocatore conferma che **la stalla è già stata costruita all'interno del complesso delle 30 farm**. Segnata COMPLETATA, non più tra i progetti da realizzare. Gino è il cavallo con armatura azzurra.

- **Revisione punto 15 — Stronghold/Portale dell'End:** il giocatore conferma che la situazione è invariata: Stronghold già individuata intorno a X1436 Y23 Z1044, portale ancora **NON attivato**, 0/12 occhi al rilevamento, due biblioteche esplorate/individuate. Non attribuire un completamento non avvenuto.

- **Revisione punto 14 — Metro della mob farm:** il giocatore conferma **nessuna modifica al momento**. Collegamento funzionante tra spiaggia e mob farm aerea, tratto storico di circa 150 blocchi e +110 Y, durata circa 1:30.

- **Revisione punto 13 — Monumento oceanico:** confermato stato invariato dopo la prima esplorazione (X≈1136, Z≈2752): **26 spugne** e **8 blocchi d'oro** recuperati. Nessun altro lavoro al monumento registrato.

- **Decisione del giocatore — farm alberi 1×1:** i programmi `querceto_1x1.lua` e `abeteto_1x1.lua` restano archiviati e **saranno provati solo quando serviranno**. Nessun collaudo effettuato, automazione nuova farm non ancora attiva. Non proporre test adesso.

- **Punto 12 — scarico e adattamento programmi nuova farm 1×1:** il giocatore indica come scarico il **blocco davanti alla base**: Turtle X1903 Y66 Z2715 NORD → scarico X1903 Y66 Z2714, acqua prevista sotto a Y65. Creati `querceto_1x1.lua` e `abeteto_1x1.lua`, adattamenti dei file storici a otto postazioni e percorso lungo Z decrescente. **Ancora da collaudare in gioco**: modalità prova, acqua e giro reale; gli script originali sono invariati.

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
