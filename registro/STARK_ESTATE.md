# Stark Estate — progetto MegaZero

**Revisione del registro: 23/10/2026.** Villa ispirata alla casa di Tony Stark / Malibu Point Rework, scelta sia per il riferimento cinematografico sia per l'architettura. Mondo di destinazione: **MegaZero, Minecraft Java 1.21.1**, con Litematica.

## File originali e versioni schematic

I seguenti file, già generati nelle precedenti conversazioni, sono **recuperabili nella Libreria ChatGPT** (non confondere le versioni):

| File originale | Funzione / note |
| --- | --- |
| `malibu-point-rework.zip` | Sorgente originale del progetto; descritto come proveniente da Java 1.21.4. |
| `Stark_Estate_MegaZero_1.21.1_PREVIEW.litematic` | Villa con parte di terreno; circa **141×95×56**, **60.105 blocchi non-aria**. |
| `Stark_Estate_MegaZero_1.21.1_TERRAIN.litematic` | Variante con terreno, distinta dalla Preview; ingombro e conteggi definitivi da ricontrollare. |
| `Stark_Estate_MegaZero_MONTAGNA_RIPRISTINATA.litematic` | Variante con rilievo/montagna ripristinata; circa **161×137×96**, **882.605 blocchi non-aria**. Conteggio materiali specifico **non ancora ricostruito**. |
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

**Questi sono i valori del posizionamento Litematica visualizzato nello screenshot**, non la posizione del giocatore. Preservare X=2138, Y=63, Z=2680 e rotazione CW_90: la quota Y=63 è stata verificata dall'interfaccia. Lo screenshot **non mostra il nome della versione `.litematic` caricata**, quindi non dedurlo dalla sola schermata. L'eventuale origine X=2196,Y=66,Z=506 è obsoleta come riferimento operativo.

## Posizionamento e coordinate già discusse

- **Area scelta:** promontorio nel bioma **Cherry Grove**, da preservare come ubicazione della Stark Estate.
- **Riferimento visuale:** giocatore/camera **X=2082, Y=103, Z=2698**, vista orientata verso **OVEST**.
- **Riferimento lato ciliegi:** **X=2088, Y=104, Z=2702**.
- **Riferimento base esistente:** circa **X=1916, Z=2719**, usato per confrontare le distanze con la villa.
- **Decisione del giocatore (22/10/2026):** mantenere posizione/orientamento correnti e non spostare verticalmente la struttura. **Conferma visiva successiva 23/10/2026:** origine **2138,63,2680**, rotazione **CW_90**, specchiatura **NONE**.
- **Valore storico riportato per l'origine della schematic:** **X=2196, Y=66, Z=506**, **NON più utilizzabile come origine del posizionamento attuale**. Conservarlo solo per cronologia: è stato superato dall'origine **X=2138, Y=63, Z=2680** letta direttamente nelle impostazioni Litematica.
- **Origine del posizionamento visibile in Litematica:** **X=2138, Y=63, Z=2680**, rotazione **CW_90**, specchiatura **NONE**, confermate direttamente da screenshot. L'origine della bounding box/angolo fisico della villa può non coincidere con l'origine Litematica quando vi sono offset o rotazioni; non dedurla senza osservare il posizionamento.

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
- **Produzione pietra liscia avviata** intorno al 23/10/2026; quantità attualmente accumulata non documentata. Un Processing Pattern **Cobblestone → Stone** è stato collaudato; altri pattern specifici restano da confermare, non presumere.
- **Collegamento RS direttamente al cantiere della Stark Estate GIÀ FUNZIONANTE:** Network Transmitter / Network Receiver e Grid vicina alla villa; distanza riferita circa **169 blocchi**. Non servono 300 cavi né una batteria di casse doppie solo per trasportare e immagazzinare i materiali in loco. I chunk necessari devono essere caricati perché la connessione operi.
- L'estimazione precedente di circa **21 casse doppie** per la Preview (**19** escludendo luce/acqua/fuoco) era uno scenario logistico, ora **superato come soluzione necessaria** dal collegamento RS funzionante.

## Questioni realmente aperte

1. **Origine di posizionamento Litematica — VERIFICATA (23/10/2026):** X=2138, Y=63, Z=2680, rotazione CW_90, specchiatura NONE. Non spostare la quota. Rimane utile solo verificare **quale variante della schematic è attualmente caricata**, non la posizione nei controlli.
2. **Ricalcolare la distinta materiali della variante effettivamente scelta/posizionata**, specialmente se è quella con montagna ripristinata; le 229 righe oggi archiviate sono il confronto Preview/isola, non il computo certo della montagna ripristinata.
3. **Confrontare la Material List di Litematica nel piazzamento reale con le scorte RS** per determinare i blocchi *mancanti*, senza confondere il conteggio geometrico con l'approvvigionamento.
4. **Rilevare scorte correnti** di Pale Oak scortecciato, pietra liscia e altre risorse prioritarie. Nessuna quantità di scorte effettive ancora confermata.

**Non riproporre:** scelta della villa, collegamento RS al cantiere, smelter, lava/secchi, generatore cobblestone e farm Pale Oak come strutture ancora da costruire.
