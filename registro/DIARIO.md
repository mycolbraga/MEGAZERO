# Diario MegaZero

Annotare nuovi progressi con **data, modifica, prova e stato**, senza inventare collaudi.

## 23 ottobre 2026 — Registro GitHub e smelter

- **Revisione punto 8 — Canna da zucchero:** il giocatore conferma che la vecchia farm indipendente 18×12 (flying machine, minecart con tramoggia) non esiste più. La produzione è stata **incorporata nel complesso delle 30 farm**. La nuova configurazione e l'integrazione RS devono ancora essere documentate; non continuare a trattare la vecchia struttura come attiva.

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
