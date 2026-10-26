# Stark Estate — progetto MegaZero

**Revisione del registro: 23/10/2026.** Villa ispirata alla casa di Tony Stark / Malibu Point Rework, scelta sia per il riferimento cinematografico sia per l'architettura. Mondo di destinazione: **MegaZero, Minecraft Java 1.21.1**, con Litematica.

**STATO CANTIERE — 26/10/2026: COSTRUZIONE INIZIATA.** Il giocatore ha confermato con screenshot la posa del **primo blocco** della Stark Estate in Litematica, su un particolare decorativo in tufo. Non è più soltanto una costruzione pianificata; restano però da realizzare quasi tutti i blocchi della villa e il terreno. Nessun avanzamento percentuale dedotto.

## File originali e versioni schematic

I seguenti file, già generati nelle precedenti conversazioni, sono **recuperabili nella Libreria ChatGPT** (non confondere le versioni):

| File originale | Funzione / note |
| --- | --- |
| `malibu-point-rework.zip` | Sorgente originale del progetto; descritto come proveniente da Java 1.21.4. |
| `Stark_Estate_MegaZero_1.21.1_PREVIEW.litematic` | Villa con parte di terreno; circa **141×95×56**, **60.105 blocchi non-aria**. |
| `Stark_Estate_MegaZero_1.21.1_TERRAIN.litematic` | Variante con terreno, distinta dalla Preview; ingombro e conteggi definitivi da ricontrollare. |
| `Stark_Estate_MegaZero_MONTAGNA_RIPRISTINATA.litematic` | **Versione attualmente scelta e posizionata**, origine X=2138 Y=63 Z=2680, CW_90. Dimensioni **161×96×137**, **882.605 blocchi non-aria**. **Conteggio COMPLETO estratto (226 ID)**: [lista materiali Montagna](STARK_ESTATE_MONTAGNA_RIPRISTINATA_MATERIALI.md). |
| `Stark_Estate_MegaZero_ISOLA_COMPLETA.litematic` | Villa + intero paesaggio originale; **328×340×72**, **3.522.622 blocchi non-aria** (inclusi **3.212.141 blocchi di terra**). |
| `stark_estate_ingombro.png` | Immagine d'ingombro conservata nella Libreria. |
| `Stark_Estate_Lista_Materiali.xlsx` | Foglio con **229 ID di blocchi**, confronto Preview / isola completa, stack, categorie e note. |
| `Stark_Estate_Lista_Materiali.txt` | Elenco testuale degli stessi materiali. Copia integrale preservata nel repository: **[STARK_ESTATE_LISTA_MATERIALI_COMPLETA.txt](STARK_ESTATE_LISTA_MATERIALI_COMPLETA.txt)**. |

**Importante:** la PREVIEW era alleggerita/tagliata sul terreno e non rappresenta la montagna completa. La versione con montagna ripristinata è una *terza versione* e non bisogna applicarle senza verifica i conteggi della Preview o dell'isola completa. Non è stato stabilito un elenco definitivo dei soli blocchi ancora da posare nel mondo corrente.

## Posizionamento Litematica — origine verificata da screenshot 23/10/2026

**Configurazione mostrata nell'interfaccia «Gestisci posizionamenti schema»:**

| Campo | Valore |
| --- | --- |
| **Origine X** | **2138** |
| **Origine Y** | **63** |
| **Origine Z** | **2680** |
| **Rotazione** | **CW_90** (90° orari) |
| **Specchiatura** | **NONE** (nessuna) |

**SCHEMATIC CONFERMATA DAL GIOCATORE: `Stark_Estate_MegaZero_MONTAGNA_RIPRISTINATA.litematic`.** Questi sono i valori del suo posizionamento Litematica visualizzati nello screenshot e confermati dal giocatore il 23/10/2026, non la posizione del giocatore. Preservare **X=2138, Y=63, Z=2680**, rotazione **CW_90**, specchiatura **NONE**. La quota Y=63 non va modificata. Il vecchio riferimento X=2196,Y=66,Z=506 è obsoleto come origine operativa.

## Posizionamento e coordinate già discusse

- **Area scelta:** promontorio nel bioma **Cherry Grove**, da preservare come ubicazione della Stark Estate.
- **Riferimento visuale:** giocatore/camera **X=2082, Y=103, Z=2698**, vista orientata verso **OVEST**.
- **Riferimento lato ciliegi:** **X=2088, Y=104, Z=2702**.
- **Riferimento base esistente:** circa **X=1916, Z=2719**, usato per confrontare le distanze con la villa.
- **Decisione del giocatore (22/10/2026):** mantenere posizione/orientamento correnti e non spostare verticalmente la struttura. **Conferma visiva successiva 23/10/2026:** origine **2138,63,2680**, rotazione **CW_90**, specchiatura **NONE**.
- **Valore storico riportato per l'origine della schematic:** **X=2196, Y=66, Z=506**, **NON più utilizzabile come origine del posizionamento attuale**. Conservarlo solo per cronologia: è stato superato dall'origine **X=2138, Y=63, Z=2680** letta direttamente nelle impostazioni Litematica.
- **Origine del posizionamento visibile in Litematica:** **X=2138, Y=63, Z=2680**, rotazione **CW_90**, specchiatura **NONE**, confermate direttamente da screenshot. L'origine della bounding box/angolo fisico della villa può non coincidere con l'origine Litematica quando vi sono offset o rotazioni; non dedurla senza osservare il posizionamento.

## Materiali: MONTAGNA_RIPRISTINATA — lista verificata direttamente

**La versione attualmente posizionata in MegaZero è MONTAGNA_RIPRISTINATA, non la Preview.** La distinta integrale è disponibile qui: **[STARK_ESTATE_MONTAGNA_RIPRISTINATA_MATERIALI.md](STARK_ESTATE_MONTAGNA_RIPRISTINATA_MATERIALI.md)**.

Estrazione verificata direttamente dai dati NBT della schematic: **882.605 blocchi non-aria su 226 ID Minecraft distinti**, **1.234.867 posizioni d'aria escluse**. Il totale coincide esattamente con i metadati Litematica.

| Materiale | Montagna | Preview (storica) |
| --- | ---: | ---: |
| Terra / dirt (rilievo) | 784.717 | 9.423 |
| Pietra / stone (rilievo) | 23.870 | 1.484 |
| Pale Oak scortecciato | **9.837** | 9.590 |
| Blocchi luce invisibile `minecraft:light` | 6.738 | 4.785 |
| Blocchi d'erba | 4.406 | 2.974 |
| Acqua | 4.223 | 390 |
| Polvere di cemento verde | 3.887 | 1.937 |
| Pietra liscia (blocchi) | **3.853** | 3.525 |
| Arenaria | 3.746 | 0 |
| Muschio | 3.690 | 1.961 |
| Assi di betulla | **2.667 — OK confermato 26/10/2026** | 3 |
| Lastre Pale Oak | 2.559 | 2.550 |
| Lastre di pietra liscia | **1.850** | 1.799 |

**Pietra liscia per questa variante:** 3.853 blocchi pieni + **927** blocchi da destinare alla produzione delle 1.850 lastre (309 ricette da 3 blocchi → 6 lastre) = **4.780 blocchi teorici di pietra liscia**, senza sottrarre scorte, blocchi già in loco o sostituzioni.

**Categorie della distinta originale, applicate alla Montagna:** 816.800 blocchi di terreno/rilievo, 46.087 blocchi «costruzione/finiture», 7.524 vegetazione/natura, 6.738 blocchi luce non ottenibili normalmente in Survival, 4.223 acqua/fluido, più illuminazione, arredi e redstone. **Queste categorie sono classificazioni descrittive, non quantità automaticamente da raccogliere**. Il rilievo del promontorio già esistente e le scorte RS devono essere confrontati con Litematica.

Il foglio **`Stark_Estate_MONTAGNA_RIPRISTINATA_Materiali.xlsx`** è stato creato e salvato anche nella Libreria ChatGPT: contiene conteggi, categorie, stack, quantità Preview e differenze. Distinguere sempre **conteggio della schematic** da **blocchi ancora mancanti**.

## Materiali: quantità della PREVIEW, non rimanenze

Fonte integrale: **[lista materiali completa su GitHub](STARK_ESTATE_LISTA_MATERIALI_COMPLETA.txt)**. I conteggi rappresentano tutti i blocchi presenti nella schematic della PREVIEW, **non** i materiali ancora da procurare dopo aver considerato inventario, cantiere e terreno già esistente.

| Materiale | Quantità PREVIEW |
| --- | ---: |
| Legno di quercia pallida scortecciato (`stripped_pale_oak_wood`) | **9.590** |
| Terra | 9.423 |
| Blocco di luce invisibile (`minecraft:light`) | 4.785 |
| Pietra liscia, blocchi pieni | **3.525** |
| Blocchi d'erba | 2.974 |
| Lastre di quercia pallida | **2.550** |
| Muschio | 1.961 |
| Polvere di cemento verde | 1.937 |
| Lastre di pietra liscia | **1.799** |
| Pietra normale (`minecraft:stone`) | **1.484** |
| Mattoni di pietra | 1.311 |
| Assi di abete | 1.084 |
| Erba corta | 1.080 |
| Vetro grigio | 954 |
| Pietrisco / cobblestone | 891 |
| Corallo tubolare morto (blocco) | 808 |
| Assi della giungla | 771 |
| Rame esposto cerato | 709 |
| Blocco di fungo marrone | 700 |

**Calcolo pietra liscia:** per **1.799 lastre** servono **900 blocchi di pietra liscia** con ricetta 3→6; ai **3.525 blocchi pieni** si sommano dunque **900** per un **fabbisogno teorico di 4.425 blocchi di pietra liscia**, ipotizzando zero scorte e nessuna altra produzione. La **pietra normale 1.484** è un conteggio separato, come i mattoni di pietra 1.311.

**Avvertenze materiali:** `minecraft:light` non è normalmente ottenibile in Survival, quindi richiede gestione/sostituzione; terra, erba, pietra, acqua e vegetazione possono essere già presenti nel terreno reale. La lista completa copre **229 identificativi** e aggrega stati/orientamenti dei blocchi; non include le materie prime intermedie dei crafting.

## Infrastrutture MegaZero già predisposte

- **Legno Pale Oak:** già presenti farm alberi 2×2 e Turtle scortecciatrice automatizzata; il datapack che ripristina i drop delle foglie Pale Oak è stato sistemato.
- **Pietra:** smelter 10 fornaci automatico e collegato a Refined Storage, circuito lava/secchi e cobblestone automatici; dal 23/10/2026 confermata anche la stazione tecnica Stone Liquefier (Energized Power), cobblestone, lava e riempimento secchi, **tutta collegata a RS**.
- **Pietra liscia — scorta aggiornata il 25/10/2026:** il giocatore riferisce **3 casse doppie piene** di pietra liscia (equivalenti a **10.368 blocchi**, assumendo 54 slot con stack da 64 per cassa). Per la schematic attuale occorrono **3.853 blocchi pieni** e **1.850 lastre**: le lastre risultano **già completate**. Di conseguenza, sulla sola pietra liscia piena, surplus teorico **6.515 blocchi** (prima dell'effettivo impiego nella costruzione). **Sospendere la produzione di pietra liscia**; la quantità deriva dalla descrizione delle casse, non da inventario RS letto direttamente. Produzione avviata intorno al 23/10/2026. Un Processing Pattern **Cobblestone → Stone** è stato collaudato; altri pattern specifici restano da confermare, non presumere.
- **Collegamento RS direttamente al cantiere della Stark Estate GIÀ FUNZIONANTE:** Network Transmitter / Network Receiver e Grid vicina alla villa; distanza riferita circa **169 blocchi**. Non servono 300 cavi né una batteria di casse doppie solo per trasportare e immagazzinare i materiali in loco. I chunk necessari devono essere caricati perché la connessione operi.
- L'estimazione precedente di circa **21 casse doppie** per la Preview (**19** escludendo luce/acqua/fuoco) era uno scenario logistico, ora **superato come soluzione necessaria** dal collegamento RS funzionante.

## Studio di ulteriori automazioni materiali

**Avviato il 23/10/2026 su richiesta del giocatore:** [studio produzioni con Energized Power, RS e Turtle](STARK_ESTATE_STUDIO_PRODUZIONI.md). Contiene la possibile catena cobblestone→gravel→sand→sandstone, produzione green concrete powder, metodi per dirt e altri blocchi. **Sono proposte da verificare, non impianti già costruiti.**

## Questioni realmente aperte

1. **Origine e variante Litematica — VERIFICATE (23/10/2026):** versione **`Stark_Estate_MegaZero_MONTAGNA_RIPRISTINATA.litematic`**, X=2138, Y=63, Z=2680, rotazione CW_90, specchiatura NONE. Non spostare la quota né riproporre la verifica del nome della schematic.
2. **COMPLETATO — estrazione materiali della MONTAGNA_RIPRISTINATA:** elenco completo **226 ID / 882.605 blocchi non-aria**, salvato in [STARK_ESTATE_MONTAGNA_RIPRISTINATA_MATERIALI.md](STARK_ESTATE_MONTAGNA_RIPRISTINATA_MATERIALI.md). Restano da determinare soltanto le **quantità effettivamente ancora da costruire/procurare**, sottraendo terreno presente e scorte RS.
3. **Confrontare la Material List di Litematica nel piazzamento reale con le scorte RS** per determinare i blocchi *mancanti*, senza confondere il conteggio geometrico con l'approvvigionamento.
4. **Rilevare scorte correnti** di Pale Oak scortecciato, pietra liscia e altre risorse prioritarie. Nessuna quantità di scorte effettive ancora confermata.

**Non riproporre:** scelta della villa, collegamento RS al cantiere, smelter, lava/secchi, generatore cobblestone e farm Pale Oak come strutture ancora da costruire.
