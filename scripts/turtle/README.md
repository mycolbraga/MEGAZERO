# Mining Turtle — script archiviati

**Le copie qui presenti non certificano che la stessa versione sia installata o collaudata nel mondo.**

- `paleoak_3_v4_auto.lua`: ultima versione consegnata per la **farm 2×2, riconversione dell'ex querceto**, attualmente Pale Oak (tre postazioni); modalità prova, giro, avvia.
- `querceto2.txt`: **codice storico** dell'ex querceto per 8 querce 1×1. **L'impianto originario è stato trasformato nella farm 2×2**; lo script non identifica un'altra farm attiva. Non sovrascrivere.
- `abeteto_8.lua`: programma storico per 8 abeti 1×1. Non è ancora confermato che sia in uso nella **nuova seconda farm 1×1**.
- `scorteccia.lua`: **programma originale fornito dal giocatore**, Turtle scortecciatrice dedicata: cassa superiore con tronchi vanilla, ascia nello slot 2, posa/scortecciatura/verifica/raccolta e scarico nella cassa inferiore. Non alterato rispetto all'allegato.

La **seconda farm 1×1** ha la struttura già costruita; sono state generate due nuove versioni per la sua configurazione reale, **ma non ancora collaudate nel gioco**:

- `querceto_1x1.lua`: nuova farm 8 querce 1×1, derivata da `querceto2.txt`.
- `abeteto_1x1.lua`: nuova farm 8 abeti 1×1, derivata da `abeteto_8.lua`.

Base X1903 Y66 Z2715 NORD, chest SUD Z2716, alberi X1899/1907 con Z2712/2705/2698/2691; scarico a X1903 Y66 Z2714 con acqua da verificare sotto a Y65. **Ordine:** preparare sapling di specie corretta su tutte e 8 le postazioni, eseguire `prova`, poi `giro`, e solo dopo il collaudo `avvia`. I file storici non sono stati alterati.

Prima di avviare, controllare coordinate e orientamento della Turtle e usare modalità `prova` se disponibile.

## Betulle — nuova farm 1×1 (25/10/2026)

- [betulle_nuove_1x1.lua](betulle_nuove_1x1.lua): adattato dall'abeteto 1×1 **della nuova farm**, non dalla vecchia farm 2×2.
- Base Turtle **1903,66,2715 NORD**; chest **1903,66,2716**.
- Piante: **X1899 e X1907**, **Z2712/2705/2698/2691**.
- Quota dei germogli/tronchi: **Y68 secondo correzione più recente del giocatore**; il registro del 23 ottobre indicava Y67. Verificare la quota in gioco prima di eseguire.
- Bone meal dalla chest, sapling di betulla, lava, scarico nel canale d'acqua.
- **Stato: NON collaudato in gioco**. Eseguire `betulle_nuove_1x1 prova`, solo se supera `giro` e poi `avvia`.
- Gli script storici originali restano invariati.
