# Mining Turtle — script archiviati

**Le copie qui presenti non certificano che la stessa versione sia installata o collaudata nel mondo.**

- `paleoak_3_v4_auto.lua`: ultima versione consegnata per la **farm 2×2, riconversione dell'ex querceto**, attualmente Pale Oak (tre postazioni); modalità prova, giro, avvia.
- `querceto2.txt`: **codice storico** dell'ex querceto per 8 querce 1×1. **L'impianto originario è stato trasformato nella farm 2×2**; lo script non identifica un'altra farm attiva. Non sovrascrivere.
- `abeteto_8.lua`: programma storico per 8 abeti 1×1. Non è ancora confermato che sia in uso nella **nuova seconda farm 1×1**.
- `scorteccia.lua`: **VERSIONE OPERATIVA COLLAUDATA IN GIOCO il 25/10/2026**, confermata funzionante dal giocatore. Cassa sopra: tronchi vanilla **e asce di ferro di ricambio**, in qualunque slot; la Turtle prende da sola una nuova ascia quando quella nello slot 2 si rompe, attendendo nuovi ricambi se esauriti. Cassa sotto: uscita dei tronchi scortecciati; slot 3 buffer temporaneo. **NON modificare questa versione funzionante senza richiesta esplicita**. Il sorgente originale del 23/10/2026 rimane recuperabile nella cronologia Git.

La **seconda farm 1×1** ha la struttura già costruita; sono state generate due nuove versioni per la sua configurazione reale, **ma non ancora collaudate nel gioco**:

- `querceto_1x1.lua`: nuova farm 8 querce 1×1, derivata da `querceto2.txt`.
- `abeteto_1x1.lua`: nuova farm 8 abeti 1×1, derivata da `abeteto_8.lua`.

Base X1903 Y66 Z2715 NORD, chest SUD Z2716, alberi X1899/1907 con Z2712/2705/2698/2691; scarico a X1903 Y66 Z2714 con acqua da verificare sotto a Y65. **Ordine:** preparare sapling di specie corretta su tutte e 8 le postazioni, eseguire `prova`, poi `giro`, e solo dopo il collaudo `avvia`. I file storici non sono stati alterati.

Prima di avviare, controllare coordinate e orientamento della Turtle e usare modalità `prova` se disponibile.

## Abeti — nuova versione derivata dal betulleto (26/10/2026)

- **[abeteto_nuove_1x1.lua](abeteto_nuove_1x1.lua): NUOVO script abeti 1×1**, derivato da `betulle_nuove_1x1.lua`, distinto dal precedente `abeteto_1x1.lua` conservato inalterato.
- Stessa nuova farm da 8 alberi: Turtle **1903,66,2715 NORD**, chest dietro **1903,66,2716**, posizioni alberi X1899/1907 e Z2712/2705/2698/2691.
- **QUOTA CORRETTA Y67:** Turtle Y66, terreno Y66, primo tronco/germoglio Y67. L'originario Y68 era una trascrizione erronea delle coordinate HUD del giocatore. Script corretto il 26/10 con **UNA salita all'andata e UNA discesa al ritorno**. Prima di tagliare, eseguire **`abeteto_nuove_1x1 prova`**, che verifica piantine/tronchi.
- Usa SOLO `minecraft:spruce_log`, `minecraft:spruce_wood`, `minecraft:spruce_sapling`, Bone Meal per accelerare la crescita, rifornimento lava automatico e scarico in acqua; non brucia il legno raccolto.
- `prova` controlla senza scavare/piantare; `giro` fa un giro reale; `avvia` esegue **cicli continui** (1 secondo di intervallo, non i 90 secondi del vecchio programma). **NON COLLAUDATO NEL MONDO.** Prima di provarlo sistemare i germogli di abete e la cassa di rifornimento; non avviare contemporaneamente i programmi di altre specie nella stessa Turtle.

## Betulle — nuova farm 1×1 (25/10/2026)

- [betulle_nuove_1x1.lua](betulle_nuove_1x1.lua): adattato dall'abeteto 1×1 **della nuova farm**, non dalla vecchia farm 2×2.
- Base Turtle **1903,66,2715 NORD**; chest **1903,66,2716**.
- Piante: **X1899 e X1907**, **Z2712/2705/2698/2691**.
- Quota dei germogli/tronchi: **Y68 secondo correzione più recente del giocatore**; il registro del 23 ottobre indicava Y67. Verificare la quota in gioco prima di eseguire.
- Bone meal dalla chest, sapling di betulla, lava, scarico nel canale d'acqua.
- **Stato: NON collaudato in gioco**. Eseguire `betulle_nuove_1x1 prova`, solo se supera `giro` e poi `avvia`.
- Gli script storici originali restano invariati.
