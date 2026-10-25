# Stark Estate — studio nuove linee di produzione (PROPOSTE, non impianti confermati)

**Avviato 23/10/2026.** Studio per la schematic `Stark_Estate_MegaZero_MONTAGNA_RIPRISTINATA.litematic`, posizionata in Litematica a **2138,63,2680 / CW_90 / NONE**. Dati di fabbisogno geometrico da `STARK_ESTATE_MONTAGNA_RIPRISTINATA_MATERIALI.md`. Le ricette tecniche Energized Power dipendono dalla **versione effettivamente installata** e vanno sempre confermate con REI/EMI/JEI in-game prima di acquistare macchine o creare processing pattern.

## PRIORITÀ ALTA — Catena sabbia/ghiaia/arenaria

**Stato aggiornato il 26/10/2026: due Frantoi (Crusher) di Energized Power GIÀ PIAZZATI, uno sopra ciascuno dei due nuovi Heat Generator, anch'essi GIÀ PIAZZATI.** Il giocatore ha confermato direttamente questo montaggio verticale. **Da verificare** lava sorgente a contatto con i generatori, reale alimentazione FE dei Frantoi, loro corretto funzionamento, ricette effettive e collegamento a Refined Storage; non dichiarare la linea produttiva collaudata. Non richiedere di costruire o piazzare di nuovo i quattro blocchi. Il circuito di automazione è ancora un progetto, non una linea completa verificata.

`Cobblestone auto (GIÀ PRESENTE, RS) → Crusher Energized Power → Gravel → secondo Crusher → Sand → autocrafting RS di Sandstone / Concrete Powder / cottura Glass`.

La documentazione ufficiale Energized Power conferma l'esistenza del **Crusher** e gli esempi `Stone→Cobblestone→Gravel→Sand`. Il mod offre **Auto Crafter**, **Auto Stonecutter** e integrazione con macchine a ingresso/uscita automatici. Controllare tipo e rapporto effettivo delle ricette in base alla versione 1.21.1 installata.

Materiali della MONTAGNA_RIPRISTINATA:
- **Sandstone:** 3.746 blocchi. Ricetta vanilla 4 sabbia → 1 arenaria = **14.984 sabbia**.
- **Green Concrete Powder:** 3.887 blocchi. Ricetta 4 sabbia + 4 ghiaia + 1 colorante verde → 8 polvere. **486 craft → 3.888 blocchi prodotti**, **1.944 sabbia + 1.944 ghiaia + 486 colorante verde** (1 eccedente). **Farm cactus per colorante già completata e RS-connessa**, ma cottura/crafting specifici da impostare e verificare.
- **Totale minimo sabbia per arenaria e cemento verde:** **16.928 sabbia**, oltre a sabbia per vetro e altri eventuali impieghi.
- **Ghiaia per la sola polvere verde:** 1.944 ghiaia; assumendo la relazione **1 cobblestone→1 gravel→1 sand**, serviranno **18.872 cobblestone** per i due prodotti insieme. **Questo rapporto è un'ipotesi da verificare in REI/EMI per la build installata**, non una resa misurata.
- **Vetro grigio:** 954 blocchi; ulteriore ramo sabbia→vetro tramite smelter già completato→colorazione (eventuale crafting e fabbisogno esatto da verificare).
- Architettura: esportare cobblestone solo con scorte adeguate, trattenere un ramo gravel, alimentare il secondo Crusher, inviare sabbia/gravel a RS, creare i pattern per sandstone e concrete green. Usare Detector RS **gradualmente** per contenere produzioni e consumi: evitare linee compostaggio/scarti non volute dal giocatore.

Fonti: https://wiki.jddev0.com/books/energized-power/page/newbies e https://www.minecraft.net/en-us/article/concrete-powder

## PRIORITÀ DA VALUTARE — Terra (dirt)

La schematic conta **784.717 blocchi di terra** come parte del **rilievo originale**, NON come scorta sicuramente da accumulare. Altre voci di terreno includono **23.870 stone naturale** e **4.406 grass blocks**. **Prima** di tentare farm enormi, usare la *Material List per il placement specifico* confrontata con il promontorio già presente; distinguere blocchi della schematic dalle differenze rispetto al mondo.

Metodi possibili:
1. **Coarse Dirt vanilla:** 2 dirt + 2 gravel → 4 coarse dirt; convertire posizionandolo e usando una zappa, poi scavare 4 dirt (guadagno netto 2 dirt per 2 gravel consumati). **Crafting automatizzabile via RS**, ma piazzamento / uso zappa / raccolta richiedono una fase fisica che non è automaticamente risolta da RS o dal classico programma Mining Turtle. Possibile studio di Block Placer Energized Power + automazione adeguata, oppure processo semiautomatico.
2. **Azalea/rooted dirt:** crescita azalea con Bone Meal trasforma il blocco sotto in rooted dirt; zappa → dirt. Richiede sistema di posizionamento, crescita, uso zappa e raccolta (non promettere automazione totale).
3. **Moss → podzol:** convertire pietra in moss con Bone Meal, far crescere abete 2×2 per trasformare zona in podzol e ottenere dirt. Coinvolge Turtle/posizionamento e raccolta; da prototipare prima di dichiarare una farm pronta.
4. **Recupero mediante Terraforming/Mining Turtle:** utile se il terreno realmente mancante è enorme, ma tenere separata la raccolta dai blocchi che si vogliono preservare.

Fonti: https://minecraft.wiki/w/Tutorial:Dirt_farming e https://minecraft.wiki/w/Dirt

## ALTRI INTERMEDI IMPORTANTI

- **Stripped Pale Oak WOOD 9.837**, non confonderlo con **stripped pale oak LOG** prodotto dalla Turtle scortecciatrice. Ricetta vanilla **4 stripped pale oak log→3 stripped pale oak wood**; servono teoricamente **13.116 stripped logs per 9.837 wood**, senza sottrarre scorte. Proposta: aggiungere crafting RS *su richiesta*, non rifare la farm Pale Oak esistente. Fonte: https://minecraft.wiki/w/Stripped_Wood
- **Smooth Stone 3.853 blocchi + 1.850 slabs**: fabbisogno teorico già registrato **4.780 smooth stone** incluse lastre; lo smelter RS esiste e funziona, non costruire un nuovo smelter.
- **Moss 3.690:** possibile rinnovare il moss usando bonemeal su pietra; Bone Meal farm già costruita e collegata a RS ma filtri ancora da completare. Prototipo eventuale, non dichiarare farm costruita.
- **Birch planks 2.667:** Sawmill Energized Power può essere un'alternativa alla ricetta delle assi; controllare resa effettiva nel gioco. Non presumere una farm betulle operativa.
- **Brown mushroom blocks** e **coral blocks**: sono ID di blocchi interi, non uguali a funghi drop o semplici piante; studiare raccolta corretta con Silk Touch.
- **Green Concrete Powder 3.887:** ricordare che la farm cactus già presente copre la materia per il colorante verde, ma il processo specifico non è stato confermato come costruito.

## Verifiche essenziali prima della costruzione

1. **La macchina Crusher è già posseduta?** Non dichiararla costruita finché il giocatore non lo conferma.
2. **Versione precisa Energized Power nel modpack:** per confermare quantità output, consumo FE e disponibilità delle macchine sul Fabric 1.21.1.
3. **Quali blocchi sono realmente mancanti al placement attuale?** La colonna totale della schematic non equivale alla lista da costruire.
4. **Produzione di energia/velocità desiderata:** dimensionare il numero di Crusher, impiegando scorte RS e Detector invece di far girare catene ininterrottamente a magazzino pieno.

**Stato: SOLO STUDIO PROGETTUALE**, nessun Crusher o nuova farm dirt dichiarati costruiti.
