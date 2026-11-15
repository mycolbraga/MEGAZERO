# MEGAZERO — Progetto base mineraria e Mining Turtle

## Stato (15 novembre 2026)
**Base fisica allestita (conferma del giocatore e screenshot, 15 novembre 2026):** turtle, casse e collegamenti già piazzati e collegati. Restano da progettare, implementare e verificare i programmi minerari, i percorsi e l'operatività end-to-end. Il numero esatto di turtle installate non è stato comunicato come conteggio verificato.

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
- **Quattro scavi principali contemporanei** nelle direzioni **NORD (-Z), SUD (+Z), EST (+X), OVEST (-X)**. **Previsione dell'utente: 8–10 Mining Turtle per ciascuno dei quattro fronti (32–40 turtle complessive)**. Quantità preliminare, non definitiva.
- **NORD/SUD:** pareti di roccia già indicate vicino alla base; possibili gallerie nella roccia.
- **EST:** inizio della mineshaft; tracciato da verificare per evitare di trattare i vuoti della miniera come roccia piena.
- **OVEST:** la caverna continua; percorso in spazio aperto da pianificare.
- Le **quattro direzioni di scavo** e la previsione **8–10 turtle per direzione** sono state indicate dal giocatore; ripartizione esatta, disposizione, percorsi e dimensioni dei tunnel restano da progettare.
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

## Punti ancora da definire
- Contare le turtle effettivamente posizionate e mappare posizione/orientamento individuale, punti di uscita e percorsi protetti (previsione originaria: 8–10 per fronte).
- Documentare il layout **già costruito** di casse, importers, alimentazione/carburante e rete RS; verificarne il comportamento nei test, senza considerarlo già testato.
- Coordinate/quote/limiti dei settori minerari e percorso protetto dalla base.
- Elenco dei minerali vanilla e mod da mantenere; trattamento di tutti gli altri drop.
- Metodo sicuro per scartare gli scarti senza perdere minerali.
- Strategia effettiva di estrazione dalle pareti esposte vs gallerie nella roccia.
- Test con una turtle e galleria breve **prima** di estendere il sistema.

**Nota di stato:** la struttura fisica e i collegamenti sono riportati come **già piazzati e collegati dal giocatore** (screenshot 15 novembre 2026); i **programmi minerari e la loro funzionalità** non sono ancora stati verificati. Non confondere installazione e funzionamento.
