# MEGAZERO — Progetto base mineraria e Mining Turtle

## Stato (15 novembre 2026)
**Base fisica allestita (conferma del giocatore e screenshot, 15 novembre 2026):** turtle, casse e collegamenti già piazzati e collegati. Restano da progettare, implementare e verificare i programmi minerari, i percorsi e l'operatività end-to-end. **Numero confermato dal giocatore: 40 Mining Turtle già installate, 10 per ognuno dei quattro lati.**

## Area della base — coordinate aggiornate e confermate (15 novembre 2026)
- **Angolo 1:** **X=2099, Y=-52, Z=3015**.
- **Angolo 2:** **X=2119, Y=-52, Z=2995**. Il precedente **Y=-25 era un errore di trascrizione** corretto esplicitamente dal giocatore: **la quota è sempre Y=-52**.
- **Intervallo delle coordinate:** X **2099..2119**, Z **2995..3015**, **Y=-52**.
- **Distanza fra le coordinate estreme:** 20 blocchi su X e 20 su Z. **Contando entrambi gli estremi: 21×21 blocchi** (441 posizioni su un piano). Questo conteggio non equivale a una base scavata su più livelli.
- Le coordinate effettive comunicate dal giocatore **sostituiscono i precedenti perimetri ipotetici** 10×18 e 20×20. **Postazioni fisiche già sistemate**; resta da mappare l'esatta disposizione di ogni turtle e i percorsi operativi.
- **Stato aggiornato:** base allestita e collegata secondo il giocatore; lo screenshot mostra file di postazioni con turtle/casse e collegamenti visibili. La fotografia non permette da sola di verificare funzionalità elettrica/logica di RS, scarico, rifornimento o conteggio totale delle turtle.
- **Destinazione:** Mining Turtle, casse di scarico/rifornimento, collegamenti Refined Storage, percorsi e componenti necessari.

## Contesto della caverna
- Ingresso alto intorno a **Y=+50**, passaggio osservato a **Y=+24**, fondo intorno a **Y=-52**.
- Grande cavità aperta, con deepslate e minerali visibili, almeno una **mineshaft** e colate/pozze di lava.
- Il giocatore riferisce uno sviluppo di circa **300 blocchi verso EST (+X)**, e presenza anche verso ovest. **Confini X/Z della caverna non ancora misurati**.
- Non confondere le coordinate dell'area base con i confini della caverna o delle zone da scavare.

## Orientamento rispetto alla base — confermato dal giocatore (15 novembre 2026)
- **OVEST (-X):** la caverna prosegue.
- **EST (+X):** inizia la mineshaft.
- **NORD (-Z):** parete di roccia.
- **SUD (+Z):** parete di roccia.
- Si tratta dell'orientamento **visto dalla base mineraria** (coordinate attuali: X 2099..2119, Z 2995..3015, Y=-52), non dei confini assoluti dell'intera caverna.
- Percorsi di uscita, direzione iniziale delle turtle e tracciati minerari **ancora da progettare**.

## Obiettivo concordato
- Mettere al lavoro più Mining Turtle per **raccogliere minerali**, non per accumulare pietra, deepslate e altri scarti.
- Strategia proposta: **gallerie 1×2**, verifica di pareti/soffitto/pavimento, estrazione delle vene riconosciute (inclusi minerali delle mod da identificare), ritorno al tracciato.
- Gestione da realizzare: scarico automatizzato verso RS, rifornimento (preferenza per secchi di lava come nelle turtle MEGAZERO), scarto del materiale comune, risparmio dello stato/ripresa, prevenzione collisioni e gestione dei chunk caricati.
- **Non esiste ancora un programma minerario verificato per questa base**; si intende riusare, solo dopo controllo, logiche funzionanti delle turtle precedenti.

## Lava — decisione attuale
- Il giocatore intende **bonificare personalmente le cascate principali**, usando acqua presso le sorgenti.
- Alle turtle si vorrebbe affidare soltanto la **gestione della lava residua incontrata durante lo scavo**, con arresto sicuro in caso di passaggio non gestibile. Questa funzionalità è **da progettare e collaudare**, non già implementata.
- Non è stato concordato lo svuotamento automatico di intere pozze.

## Quattro fronti minerari in contemporanea — proposta del giocatore (15 novembre 2026)
- **Quattro scavi principali contemporanei** nelle direzioni **NORD (-Z), SUD (+Z), EST (+X), OVEST (-X)**. **Installazione confermata dall'utente: 10 Mining Turtle per ciascuno dei quattro lati, 40 complessive.**
- **NORD/SUD:** pareti di roccia già indicate vicino alla base; possibili gallerie nella roccia.
- **EST:** inizio della mineshaft; tracciato da verificare per evitare di trattare i vuoti della miniera come roccia piena.
- **OVEST:** la caverna continua; percorso in spazio aperto da pianificare.
- Il giocatore **conferma 10 turtle per lato (NORD/SUD/EST/OVEST)**, già piazzate. Restano da definire e verificare orientamento individuale, corsie, percorsi e dimensioni dei tunnel; non inventare le coordinate delle singole postazioni.
- **Il posizionamento fisico è stato realizzato dal giocatore** nel perimetro rilevato (X2099..2119, Z2995..3015: 21×21 blocchi inclusivi). Prima del codice servono la mappatura delle postazioni effettive e gli accessi per ciascun fronte; gestire vuoti/dislivelli, settori, rientro, rifornimento e scarico RS.

## Avanzamento in gioco — conferma fotografica (15 novembre 2026)
- Il giocatore comunica esplicitamente **«GIÀ TUTTO PIAZZATO E COLLEGATO»** e fornisce screenshot dell'interno della base.
- Visibili più postazioni di turtle, casse collocate sopra e sotto, cablaggi e zona centrale percorribile, con illuminazione installata.
- Registrare **installazione fisica e collegamenti come completati sulla base della conferma del giocatore**. La fotografia non consente di contare tutte le postazioni né di dimostrare che gli importer/exporter o il sistema di rifornimento funzionino: test operativi ancora da fare.
- Non proporre di riprogettare o ricostruire l'allestimento già completato se non richiesto; partire dalla configurazione esistente per predisporre i programmi.

## Prima postazione di riferimento — angolo NORD-EST (15 novembre 2026)
- **Punto di partenza scelto dal giocatore:** **X=2119, Y=-52, Z=2995** (angolo NORD-EST del perimetro).
- **Orientamento iniziale:** **NORD (-Z)**, esplicitamente indicato dal giocatore («FACING NORD»).
- Da questa posizione un eventuale primo avanzamento diritto va verso **X=2119, Y=-52, Z=2994**. Questa è solo geometria, **nessun movimento è ancora stato comandato o testato**.
- La configurazione delle altre turtle, l'assegnazione dei settori, il programma e la logica di uscita/rientro sono da stabilire. Non inventare ulteriori coordinate di postazioni.

## Lunghezza iniziale dei quattro scavi principali — scelta del giocatore (15 novembre 2026)
- **Avanzamento massimo iniziale: 300 blocchi per ciascuno dei quattro fronti** NORD, SUD, EST e OVEST. Non implica che ogni turtle scavi lungo la stessa linea o che tutta l'area venga svuotata; sono limiti di avanzamento per le direzioni principali, da ripartire in corsie e settori.
- **NORD (-Z):** dalla prima turtle nota a **(2119, -52, 2995)**, 300 spostamenti verso nord portano a **Z=2695** (X=2119 per quella linea). Primo blocco davanti: Z=2994.
- **SUD (+Z):** dal confine sud della base **Z=3015**, limite indicativo **Z=3315**.
- **EST (+X):** dal confine est della base **X=2119**, limite indicativo **X=2419**.
- **OVEST (-X):** dal confine ovest della base **X=2099**, limite indicativo **X=1799**.
- Questi sono **limiti di calcolo**, non punti di partenza fissati per le turtle dei fronti SUD/EST/OVEST. Le postazioni effettive e le coordinate dei singoli corridoi non sono ancora state comunicate.
- **Quote di scavo concordate:** dalla quota **Y=0** scendendo **fino alla bedrock**, in ogni fronte (300 blocchi di lunghezza). **Il limite inferiore è la bedrock reale incontrata**: non assumere una quota Y uniforme scavabile su ogni colonna e non tentare di romperla.
- **Quota della base:** Y=-52. La turtle di riferimento è a **(2119,-52,2995)** rivolta NORD; percorso protetto di uscita/risalita a Y=0, schema degli strati e rientro sono **da progettare**. Non riutilizzare la vecchia quota SKY=89 del precedente programma.
- **Script di partenza indicato dall'utente:** `scavo_1680_1783_dal_67_in_su(1).lua` (allegato in chat), funzionante secondo l'utente. Riutilizzare la logica di rifornimento lava dalla cassa superiore, scarico dalla inferiore, stato e ritorno; cambiare esclusivamente quanto serve, una volta definite le traiettorie.
- **Stato:** solo pianificazione dei limiti, nessun programma nuovo scritto o testato in gioco.

## Prima bozza programma per NORD-01 (15 novembre 2026)
- È stata preparata in chat, come **file locale allegabile** (non ancora pubblicato come codice su GitHub), una **bozza non collaudata in Minecraft**: `miniera_nord_01.lua`.
- **Basata sul file di scavo funzionante fornito dal giocatore:** `scavo_1680_1783_dal_67_in_su(1).lua`. Conserva logiche di scarico nella cassa sotto, rifornimento con lava da quella sopra, stato persistente, rientro e controllo carburante.
- Prima turtle: **(2119,-52,2995), facing NORD**. Per il modello iniziale si è **assunta provvisoriamente** una striscia completa di **2 blocchi di larghezza** X=2118..2119 e 300 di lunghezza Z=2695..2994; non è ancora una conferma del giocatore sul tipo di galleria.
- Quote della bozza: Y=0..-58, scendendo dall'alto. La bedrock dell'Overworld Java può comparire a partire da Y=-59; lo strato Y=-59 e quelli sottostanti richiedono gestione distinta e **non sono inclusi** in questa prima bozza.
- Percorso **ipotizzato, non confermato**: uscita un blocco a nord della base in (2119,-52,2994), salita nello stesso asse fino a Y=0, poi serpentina orizzontale e livelli in discesa. Prima di un test con movimento verificare che la colonna scelta non interferisca con elementi della base.
- `prova` è non distruttiva (controlla accessibilità inventari sopra/sotto); `test` scava dieci celle del primo livello Y=0 e la colonna di salita iniziale, poi rientra; `avvia` esegue il lavoro esteso.
- Il programma scarta solo pietre/terra/ghiaia comuni note, preservando gli item non riconosciuti, inclusi gli eventuali drop minerali di mod. Si ferma su lava/acqua, bedrock o parti strutturali protette: **la bonifica automatica della lava non è ancora implementata**.
- **Validazione fatta fuori dal gioco:** parsing Lua 5.3 e simulazione semplificata delle API, riuscita per il test breve e una versione miniatura del percorso completo; **non equivale a collaudo nel mondo Minecraft**.
- **Non avviare questa bozza né tutti i fronti**: la modalità selettiva scelta successivamente e la progettazione coordinata richiedono un programma diverso.

## Decisione su progettazione complessiva delle turtle (15 novembre 2026)
- L'utente ha scelto esplicitamente **modalità B: estrazione mineraria selettiva**, cioè gallerie e ricerca/raccolta delle vene, **NON sbancamento completo**.
- L'utente richiede di **progettare insieme tutto il sistema**, non sviluppare ogni turtle isolatamente: i quattro fronti NORD, SUD, EST, OVEST con **10 turtle installate per fronte (40 in totale)** devono poter operare contemporaneamente senza collisioni, sovrapposizioni, incroci dei percorsi di uscita/rientro o interferenze con le casse della base.
- Prima di scrivere nuovo codice, definire la **mappa completa delle postazioni reali**, le corsie/settori indipendenti, gli accessi e i percorsi protetti comuni, i limiti delle vene e una politica sicura di precedenza/stop.
- L'infrastruttura fisica della base è già piazzata e collegata secondo l'utente: **non proporre di ricostruirla da zero**.
- I limiti generali già concordati restano: 300 blocchi per fronte, quote di estrazione da Y=0 alla bedrock; base a Y=-52.
- Il file locale **`miniera_nord_01.lua` è una bozza SUPERATA DA NON AVVIARE**: scava completamente un volume 2×300×59 e non implementa l'estrazione selettiva, né il coordinamento delle altre turtle.
- Il file funzionante fornito dal giocatore **`scavo_1680_1783_dal_67_in_su(1).lua`** è il **riferimento per le parti comuni già funzionanti** (salvataggio avanzamento, rientro, rifornimento lava sopra, scarico sotto), da adattare dopo aver definito il funzionamento dell'intero sistema.
- **Non inventare coordinate individuali delle altre turtle**: è nota solo la prima in (2119,-52,2995) rivolta NORD. Nessun nuovo programma minerario selettivo è stato scritto o collaudato.

## Punti ancora da definire
- **Conteggio confermato: 40 turtle, 10 per lato.** Mappare posizione e orientamento individuale, punti di uscita e percorsi protetti, senza presumere spaziatura o coordinate delle altre 39 turtle.
- Documentare il layout **già costruito** di casse, importers, alimentazione/carburante e rete RS; verificarne il comportamento nei test, senza considerarlo già testato.
- Definire corsie/settori di ciascuna turtle, percorso protetto di risalita dalla base Y=-52 al primo strato Y=0, ordine di scavo in discesa fino alla bedrock e rientro (300 blocchi per direzione già scelti).
- Elenco dei minerali vanilla e mod da mantenere; trattamento di tutti gli altri drop.
- Metodo sicuro per scartare gli scarti senza perdere minerali.
- Progettare come distribuire in modo selettivo la ricerca di vene lungo gallerie e pareti già esposte, senza scavare interamente il volume.
- Progettare **tutte le postazioni e i percorsi insieme**, quindi eseguire prove controllate prima di avviare più turtle contemporaneamente.

**Nota di stato:** la struttura fisica e i collegamenti sono riportati come **già piazzati e collegati dal giocatore** (screenshot 15 novembre 2026); i **programmi minerari e la loro funzionalità** non sono ancora stati verificati. Non confondere installazione e funzionamento.
