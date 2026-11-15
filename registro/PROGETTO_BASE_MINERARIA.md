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
- **Prima turtle NORD, angolo NORD-EST:** **X=2119, Y=-53, Z=2995**. La Y=-53 è la posizione effettiva delle turtle comunicata successivamente dall'utente (le coordinate di area della base erano state segnate a Y=-52).
- **Orientamento iniziale:** **NORD (-Z)**, esplicitamente indicato dal giocatore («FACING NORD»).
- Il primo blocco davanti alla prima turtle NORD è **X=2119, Y=-53, Z=2994**. Solo geometria: nessun movimento verificato.
- La posizione di tutte le altre 39 turtle e il verso dei quattro lati sono ora comunicati esplicitamente dall'utente (vedere sezione «Mappa esatta»). Restano da progettare percorsi, settori minerari e rientro.

## Mappa esatta delle 40 postazioni — comunicata dal giocatore (15 novembre 2026)
- **Tutte le turtle sono alla quota Y=-53**, mentre gli angoli dell'area della base erano stati precedentemente comunicati come Y=-52. Non confondere la posizione delle turtle con il riferimento del piano della base.
- **NORD, facing NORD (-Z), 10 turtle:** da **(2119,-53,2995)** fino a **(2101,-53,2995)**, avanzando di 2 blocchi lungo X decrescente: X = 2119, 2117, 2115, 2113, 2111, 2109, 2107, 2105, 2103, 2101; Z fisso 2995.
- **OVEST, facing OVEST (-X), 10 turtle:** da **(2099,-53,2995)** fino a **(2099,-53,3013)**, avanzando di 2 blocchi lungo Z crescente: Z = 2995, 2997, 2999, 3001, 3003, 3005, 3007, 3009, 3011, 3013; X fisso 2099.
- **SUD, facing SUD (+Z), 10 turtle:** da **(2099,-53,3015)** fino a **(2117,-53,3015)**, avanzando di 2 blocchi lungo X crescente: X = 2099, 2101, 2103, 2105, 2107, 2109, 2111, 2113, 2115, 2117; Z fisso 3015.
- **EST, facing EST (+X), 10 turtle:** da **(2119,-53,3015)** fino a **(2119,-53,2997)**, avanzando di 2 blocchi lungo Z decrescente: Z = 3015, 3013, 3011, 3009, 3007, 3005, 3003, 3001, 2999, 2997; X fisso 2119.
- **Totale: 40 turtle**, con le quattro postazioni d'angolo assegnate ciascuna a un lato diverso. Tutte le 40 coordinate sono dedotte soltanto dalla progressione esplicita di estremi e passo 2, senza attribuire nuove posizioni arbitrarie.
- La direzione di scavo iniziale per ogni turtle è rivolta all'esterno del perimetro, non verso il centro.
- **Attenzione per la progettazione:** con interasse di 2 blocchi, un attraversamento laterale delle vene potrebbe invadere la corsia della turtle adiacente; prima di programmare definire congiuntamente come separare i settori e consentire la raccolta selettiva senza collisioni.
- **Nessun movimento di prova effettuato** con questa mappa.

## Lunghezza iniziale dei quattro scavi principali — scelta del giocatore (15 novembre 2026)
- **Avanzamento massimo iniziale: 300 blocchi per ciascuno dei quattro fronti** NORD, SUD, EST e OVEST. Non implica che ogni turtle scavi lungo la stessa linea o che tutta l'area venga svuotata; sono limiti di avanzamento per le direzioni principali, da ripartire in corsie e settori.
- **NORD (-Z):** dalla prima turtle confermata in **(2119, -53, 2995)**, 300 spostamenti verso nord portano a **Z=2695** (X=2119 per quella linea). Primo blocco davanti: Z=2994.
- **SUD (+Z):** dal confine sud della base **Z=3015**, limite indicativo **Z=3315**.
- **EST (+X):** dal confine est della base **X=2119**, limite indicativo **X=2419**.
- **OVEST (-X):** dal confine ovest della base **X=2099**, limite indicativo **X=1799**.
- Questi sono **limiti di calcolo**, non punti di partenza fissati per le turtle dei fronti SUD/EST/OVEST. Le postazioni effettive e le coordinate dei singoli corridoi non sono ancora state comunicate.
- **Quote di scavo concordate:** dalla quota **Y=0** scendendo **fino alla bedrock**, in ogni fronte (300 blocchi di lunghezza). **Il limite inferiore è la bedrock reale incontrata**: non assumere una quota Y uniforme scavabile su ogni colonna e non tentare di romperla.
- **Coordinate di base precedentemente fornite:** Y=-52; **quota effettiva delle turtle confermata successivamente:** Y=-53. La turtle di riferimento è a **(2119,-53,2995)** rivolta NORD; percorso protetto di uscita/risalita a Y=0, schema degli strati e rientro sono **da progettare**. Non riutilizzare la vecchia quota SKY=89 del precedente programma.
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
- **Posizioni di tutte le 40 turtle definite dall'utente:** consultare «Mappa esatta». Nessun nuovo programma minerario selettivo è stato scritto o collaudato.

## Settori esclusivi e corsie iniziali — accordo del giocatore (15 novembre 2026)
- **Decisione confermata:** ogni turtle deve avere un settore minerario **esclusivo**, senza attraversare quello di altre turtle durante lo scavo, l'esplorazione delle vene o il rientro; i quattro fronti vanno progettati congiuntamente.
- **Ingresso/uscita:** le 40 turtle, già collocate a Y=-53, sono distanziate di 2 blocchi su ciascun lato. Si può riservare ad ogni postazione un **corridoio iniziale di larghezza 2**, con i due blocchi adiacenti sul lato interno del fronte, senza sovrapporre i corridoi delle vicine:
  - **NORD:** per ogni turtle a (X,-53,2995), corsia nominale iniziale **X-1..X**, direzione **Z decrescente**. Esempio NORD-01 X=2118..2119.
  - **OVEST:** per ogni turtle a (2099,-53,Z), corsia nominale iniziale **Z..Z+1**, direzione **X decrescente**. Esempio OVEST-01 Z=2995..2996.
  - **SUD:** per ogni turtle a (X,-53,3015), corsia nominale iniziale **X..X+1**, direzione **Z crescente**. Esempio SUD-01 X=2099..2100.
  - **EST:** per ogni turtle a (2119,-53,Z), corsia nominale iniziale **Z-1..Z**, direzione **X crescente**. Esempio EST-01 Z=3014..3015.
- **Attenzione:** la larghezza **2** definisce SOLO una **proposta di corsia di uscita** basata sull'interasse delle postazioni; **non è ancora la larghezza definitiva dei settori minerari**. Per seguire efficacemente le vene i settori potrebbero dover essere più ampi, con corsie che divergono senza incroci: geometria ancora da definire prima del codice.
- Si conservano il limite di **300 blocchi di avanzamento per fronte**, l'inizio del lavoro da **Y=0 verso bedrock** e i rientri alle rispettive casse presso la base. L'accesso sicuro da Y=-53 a Y=0 **non è ancora progettato**.
- **Nessun programma nuovo deve essere generato o avviato** prima di aver definito un assetto coerente per tutte e 40 le turtle.

## Piano approvato: 40 fasce minerarie indipendenti (15 novembre 2026)
**Il giocatore ha approvato questa suddivisione complessiva il 15 novembre 2026.** È approvata come **architettura di progetto**, non ancora programmata o verificata in Minecraft; i percorsi di accesso e i dettagli di gestione delle vene devono essere progettati prima dell'esecuzione.

### Geometria 2D per quattro fronti senza sovrapposizione
- **NORD:** X=2100..2119, Z=2695..2994; 10 corsie da 2 blocchi, ciascuna lunga 300.
- **SUD:** X=2099..2118, Z=3016..3315; 10 corsie da 2 blocchi, ciascuna lunga 300.
- **EST:** X=2120..2419, Z=2996..3015; 10 corsie da 2 blocchi, ciascuna lunga 300.
- **OVEST:** X=1799..2098, Z=2995..3014; 10 corsie da 2 blocchi, ciascuna lunga 300.
- Questi quattro rettangoli sono disgiunti anche vicino agli angoli della base. **Prima uscita**: 1 blocco in avanti dalla postazione rispettiva a Y=-53.
- Per ciascuna turtle di base NORD (X,-53,2995) riservare X-1..X; SUD (X,-53,3015) riservare X..X+1; OVEST (2099,-53,Z) riservare Z..Z+1; EST (2119,-53,Z) riservare Z-1..Z. Dimensione di fascia 2 blocchi da confermare con l'utente; nessuna invasione oltre i confini.
- **Esempio NORD**: N01=2118..2119; N02=2116..2117; N10=2100..2101 (tutte per Z=2695..2994).

### Ricerca selettiva dei minerali proposta
- Tunnel di **altezza 2** per corsia, evitando l'escavazione completa del volume; passate a diverse quote da Y=0 verso la bedrock, **distanziate indicativamente 3 blocchi verticali** per osservare i blocchi non scavati di pareti, soffitto e pavimento.
- Esaminare blocchi laterali all'interno della fascia assegnata, sopra e sotto, e inseguire gli eventuali minerali con visita in profondità **solo entro settore privato**; quando la vena supera il confine, non oltrepassarlo: la porzione adiacente spetta all'altra turtle.
- Riservare a ciascuna turtle una via di uscita/rientro protetta e stabile che non possa essere distrutta dalla ricerca minerali.
- **Uscita confermata:** un passo in avanti a Y=-53 oltre il perimetro, poi salita/discesa dalla posizione esterna. Progettare e implementare il rientro nella postazione senza scavare all'interno.
- Logiche di rifornimento, scarico, salvataggio dai programmi precedenti; mantenere i drop minerali vanilla/mod e non eliminare item sconosciuti senza whitelist; gestione della lava e degli scarti da definire. Occhio a chunk loading per lavorazioni fino a 300 blocchi dalla base.
- **Architettura approvata dal giocatore; non è ancora un programma funzionante.** Restano da definire e collaudare le 40 vie di salita da Y=-53 a Y=0, rientri, trattamento dell'acqua/lava, gestione dello stato, caricamento chunk e sicurezza del mining selettivo.

## Uscita sicura dalla base e divieto di scavo interno — confermato dal giocatore (15 novembre 2026)
- **Chiarimento definitivo:** non esistono strutture davanti alle turtle. Casse, cavi e dispositivi RS sono **all'interno della base**, non sul lato esterno. Ogni turtle ha spazio libero per fare **UN movimento in avanti** e, una volta uscita, può **salire e scendere**.
- **Regola tassativa:** NON scavare o svolgere lavori all'interno del perimetro in pianta **X=2099..2119 e Z=2995..3015**, **a qualsiasi quota Y**. Le posizioni iniziali (sul bordo a Y=-53) sono consentite soltanto come punti di parcheggio/rientro: non rompere i blocchi della base.
- **Prima mossa di ciascuna turtle (tutte a Y=-53):**
  - NORD: da (X,-53,2995) a **(X,-53,2994)**, poi salita/discesa fuori dal perimetro;
  - OVEST: da (2099,-53,Z) a **(2098,-53,Z)**, poi salita/discesa fuori dal perimetro;
  - SUD: da (X,-53,3015) a **(X,-53,3016)**, poi salita/discesa fuori dal perimetro;
  - EST: da (2119,-53,Z) a **(2120,-53,Z)**, poi salita/discesa fuori dal perimetro.
- Ogni turtle deve usare la propria posizione esterna di uscita come **colonna di movimento verticale**, secondo la geometria dei settori esclusivi approvati; durante rientro/avanzamento proteggere le strutture e non scavare nella base.
- **Lo spazio per uscita e movimento verticale è confermato dal giocatore**: non richiedere di creare nuove colonne nella base o di modificare casse/cablaggi.
- Restano da programmare e verificare nel gioco percorsi sicuri, gestione di fluidi, minerali, controllo carburante e rientri. Questo chiarimento risolve la geometria base->esterno, ma non prova già che il codice funzioni.

## REQUISITO PRIORITARIO — nessuna turtle abbandonata sul posto (15 novembre 2026)
**Richiesta esplicita e vincolante del giocatore:** «le turtle non devono mai fermarsi sul posto quando hanno un problema; devono sempre tornare alla base a segnalarlo».

### Comportamento obbligatorio dei nuovi programmi
1. **Se compare un errore recuperabile** (lava, acqua, blocco non scavabile, settore non percorribile, inventario quasi pieno, scorta carburante in calo, anomalia mineraria o operazione fallita): **interrompere l'estrazione**, salvare l'errore e le coordinate, quindi **rientrare alla propria postazione** tramite percorso sicuro.
2. **Rientro di emergenza da progettare preventivamente**: traccia reversibile del percorso realmente compiuto (incluse le deviazioni sulle vene), via di uscita protetta, riserva di carburante per la distanza del ritorno + margine, e verifica anticipata dei passaggi critici. Non ripetere tentativi all'infinito nel punto d'errore.
3. Una volta alla base, **segnalare in modo leggibile il guasto**: turtle identificata, causa, coordinate in cui è comparso, stato del rientro e posizione/avanzamento da riprendere. Visualizzazione minima: terminale e file di stato persistente; eventuale segnale centralizzato via rete RS/monitor è **da progettare e concordare**, non ancora presente.
4. **Dopo rientro per guasto non riprendere automaticamente a scavare** finché l'anomalia non è stata risolta o autorizzata a essere saltata.
5. **Non scavare mai nel perimetro interno della base a nessuna quota**, neppure durante recupero. Non danneggiare casse, cavi, altre turtle o vie di transito.

### Limite fisico da gestire apertamente
Il rientro si può garantire per gli errori **da cui esiste un percorso praticabile e carburante sufficiente**. In caso di guasto non recuperabile (passaggio di ritorno fisicamente bloccato, chunk non caricato, turtle distrutta, gioco arrestato o carburante completamente esaurito) nessun programma può promettere un rientro effettivo. La progettazione deve **minimizzare tali situazioni**, rendere impossibile per quanto possibile l'esaurimento carburante in viaggio, e conservare l'ultimo stato prima di ogni movimento. Non dichiarare come infallibile una logica non ancora testata.

**Questa condizione prevale su ogni bozza precedente che usa `error()` al fronte di scavo senza rientro.** Il programma `miniera_nord_01.lua` è già superato e non deve essere avviato.

## Sala di controllo remota alla base principale — decisione approvata (15 novembre 2026)
- **Specifica permanente multi-sito e lista materiali:** [SALA_CONTROLLO_TURTLE.md](./SALA_CONTROLLO_TURTLE.md) — confermata riutilizzabile per miniere future e potenzialmente altri impianti. Kit minimo: Advanced Computer, 4 Advanced Monitor, 2 Ender Modem; a regime 41 Ender Modem e 12 monitor per 40 turtle. Prima verificare la comunicazione a distanza e il caricamento chunk.
- **Scelta approvata dal giocatore:** realizzare una **sala di controllo nella base principale**, separata dalla miniera, per controllare a distanza le 40 Mining Turtle senza dover tornare fisicamente al sito minerario ogni volta. Da sviluppare con CC:Tweaked: computer centrale, uno o più monitor, modem e messaggistica `rednet` dalle turtle.
- Stati proposti per ciascuna turtle: **IN SCAVO**, **IN RIENTRO**, **ALLA BASE**, **ERRORE (rientrata e con causa/coordinate)**, **NON RAGGIUNGIBILE** (mancano aggiornamenti).
- Dashboard organizzata per **NORD/SUD/EST/OVEST**, 10 turtle per ciascun fronte; eventuali dati: ID univoco, avanzamento, posizione registrata, carburante, errore e ora/istante dell'ultima comunicazione.
- Il monitor **non legge automaticamente** le 40 turtle: il software di ogni turtle deve inviare aggiornamenti periodici e segnalazioni esplicite; il computer centrale deve ascoltarli e rendere il cruscotto. Mancanza di segnale non indica automaticamente un guasto fisico: potrebbe essere chunk scaricato, rete non disponibile o turtle non avviata.
- Per distanze di circa **300 blocchi**: modem wireless ordinari CC:Tweaked non sono affidabili per l'intero settore (portata base 64 blocchi); per copertura diretta si propone un **Ender Modem** su ciascuna turtle e un modem compatibile sulla centrale, salvo altre infrastrutture o impostazioni mod. Verificare che le Mining Turtle abbiano uno slot upgrade libero per il modem e che i chunk siano caricati.
- **Stato:** funzionalità **approvata come requisito di progetto**, NON ancora costruita, programmata o collaudata. Necessario test di comunicazione dalla base principale alla miniera prima di equipaggiare tutte le turtle. Se altri mod/addon cambiano la portata degli Ender Modem, verificarlo in gioco. La sala di controllo non sostituisce il rientro fisico obbligatorio delle turtle alla propria postazione in caso di errore.
- **Proposte operative da sviluppare:** ID stabile per ogni turtle; heartbeat periodico; visualizzazione dell'ultima comunicazione (distinguere offline da guasto); memoria locale e centrale degli errori, dei percorsi e delle coordinate; eventuali controlli remoti di pausa/ripresa sicura senza modificare il requisito di ritorno in base.
- **Caricamento chunk:** la comunicazione a distanza non mantiene da sola le turtle attive. Prevedere una strategia di chunk loading nelle zone di lavoro e un servizio di monitoraggio sempre caricato alla base principale.

## Primo collaudo di movimento N01 (prototipo sicuro) — 15 novembre 2026
- **Programma pubblicato nel repository:** [`scripts/turtle/megazero_pilot.lua`](../scripts/turtle/megazero_pilot.lua). **Solo per `MINIERA-01/N01`**: verifica esplicitamente `/megazero_config` per rifiutare altre turtle.
- **Scopo:** primo test reale di geometria, movimento e rientro, non minerario di produzione. La turtle N01 parte dalla home **(2119,-53,2995)** orientata NORD, fa un solo passo esterno a **(2119,-53,2994)**, sale esternamente fino a **Y=-1** (galleria di altezza due fino a Y=0), apre un tunnel rettilineo di **massimo 8 posizioni** e torna indietro per lo stesso percorso, scarica nella cassa inferiore.
- Riusa la logica già funzionante **cassa sopra/secchi di lava, cassa sotto/scarico secchi vuoti** dal vecchio programma; per il pilot punta ad almeno 1000 unità di carburante, verifica la riserva lungo il percorso, conserva tutti i drop, non getta materiali nell'ambiente.
- **Settore rigoroso:** movimenti soltanto nella fascia N01 X=2118..2119/Z=2695..2994, Y=-63..0, oltre alla posizione home; nessuno scavo nel perimetro della base X=2099..2119/Z=2995..3015. Primo passo esterno non scava se ostruito.
- Salva progresso di posizione e breadcrumb su `/.megazero_pilot_state`; se errore recuperabile (per es. lava o acqua identificata, blocco non scavabile, carburante insufficiente) prova a rientrare lungo i passi inversi e invia `ERRORE` alla centrale. In caso di reboot nel mezzo di un movimento (stato `pending`) non può dimostrare quale sia la posizione fisica e si blocca per verifica manuale: nessuna falsa garanzia di rientro infallibile. Rientro può fallire se il percorso è fisicamente ostruito.
- Questo **non scava selettivamente vene**: scava solo passaggi strettamente necessari alla galleria e riconosce alcuni blocchi minerali adiacenti per il report; la logica di vein-following completa è fase successiva. Non è l'algoritmo di produzione per 40 turtle, non abilita nessun miner nello `startup`.
- **Controlli eseguiti fuori dal gioco:** validazione sintattica con `texluac -p`, simulazione Lua mock di percorso libero e di lava incontrata (entrambe tornano esattamente alla home, in caso lava inviano ERRORE). **Nessuna esecuzione in Minecraft ancora confermata**.
- **Uso soltanto sulla N01**, con il bootstrap in esecuzione: `Ctrl+T` per uscire dallo startup (non mentre la turtle è in movimento), dalla shell `wget https://raw.githubusercontent.com/mycolbraga/MEGAZERO/registro/megazero/scripts/turtle/megazero_pilot.lua megazero_pilot`, quindi `megazero_pilot`. **Non premere Ctrl+T durante il movimento**: l'interruzione forzata può impedire il rientro. Al completamento il test continua a inviare heartbeat; `reboot` riporta lo startup standard (miner disabilitato).
- **Distribuzione futura senza camminare:** documentazione ufficiale CC:Tweaked segnala il comando `/computercraft view #ID` o l'interfaccia di `/computercraft dump`, per aprire terminali di computer caricati anche da remoto nel mondo single-player con cheats. Da verificare il comportamento nell'installazione Fabric del giocatore; non equivale a tele-installazione né esegue 40 aggiornamenti in batch.

## Esito primo collaudo N01 — riuscito (15 novembre 2026)
- L'utente ha eseguito realmente `megazero_pilot` sulla **N01** e ha inviato screenshot successivi della dashboard e del terminale.
- La dashboard centrale 54 ha mostrato transizioni di stato **SCAVO → RIENTRO → BASE** per N01.
- Il terminale ha riportato `SCAVO: PILOT N01: galleria 2/8`, `4/8`, `6/8`, `8/8`, poi `RIENTRO: Test concluso: rientro alla propria cassa`, infine **`BASE: TEST OK: rientrata`** e `Telemetria attiva`. Nel report erano presenti anche blocchi minerali, fra cui `minecraft:deepslate_iron_ore`.
- Il giocatore ha confermato **«MI SEMBRA TUTTO OK»**. **Esito positivo secondo l'esecuzione del programma**; non dichiarare come fisicamente ispezionati il deposito nella cassa, la sicurezza in condizioni difficili o il rientro delle altre 39 turtle.
- **Ancora da sviluppare/collaudare:** programma produttivo minerario selettivo con vene/settori per tutti i 40 robot, gestione di lava/acqua/ostacoli e recupero errori, integrazione definitiva con `megazero_boot`; mantenere lo scavo automatico disabilitato sulle altre turtle. Il pilot N01 NON deve essere distribuito sulle altre turtle perché è vincolato alla sua postazione.

## Gestione acqua e lava — requisito automatico obbligatorio (15 novembre 2026)
**Correzione esplicita del giocatore:** «EH NO DEVE GESTIRLA NON L'ASCIARLA LÌ». Nel programma minerario definitivo le turtle devono **bonificare e attraversare acqua e lava automaticamente**, non segnalarle come ostacolo per poi rinunciare e passare oltre. Il rientro per errore è una misura di ultima istanza, soltanto per casi che non possono essere recuperati con risorse/accesso disponibili.

### Procedura progettata — da implementare e verificare
1. **Ispezione continua** di fronte, sopra e sotto, oltre alle verifiche dopo ogni blocco scavato. Non fidarsi soltanto di `turtle.detect()`, che può restituire falso sui fluidi; usare `inspect/inspectUp/inspectDown` e, se disponibile, lo stato del blocco `state.level`. Verificare le varianti modded in gioco.
2. **Sorgente d'acqua** raggiungibile nel proprio settore: usare un **secchio vuoto** con `turtle.place/placeUp/placeDown` per prelevare la sorgente. Verificare il passaggio a secchio d'acqua e la scomparsa della sorgente; riversare poi in sicurezza il secchio raccolto nel circuito di scarico alla base (non svuotarlo a caso in miniera).
3. **Sorgente di lava** raggiungibile nel proprio settore: stesso prelievo con secchio vuoto; se appropriato, consumare il secchio di lava con `turtle.refuel(1)` recuperando quello vuoto per altri prelievi, altrimenti conservarlo per scarico. Verificare che il carburante non sia già al limite e che `refuel` riesca prima di consumare.
4. **Correnti senza sorgente immediatamente raggiungibile:** risalire verso l'alimentazione **solo nei 2 blocchi di larghezza del proprio settore**, schermare la zona con **blocchi pieni, non infiammabili e non waterloggabili** (cobblestone/deepslate) e/o prelevare le sorgenti accessibili. La chiusura deve essere **stabile**: non rompere il tappo nel corridoio se ciò riapre immediatamente la colata. Dopo qualsiasi bonifica, attendere alcuni tick e verificare di nuovo prima di entrare.
5. **Fluido dall'alto/laterale:** mettere in sicurezza apertura e soffitto prima di rompere altri blocchi; impedire cadute di lava/acqua sulla via di ritorno. Se le correnti tornano, correggere la barriera anziché andare avanti alla cieca. Non minare minerali da zone che farebbero saltare la protezione del ritorno.
6. **Scorta autonoma di secchi — decisione esplicita dell'utente:** usare anzitutto **i secchi vuoti già prodotti dai rifornimenti con lava**, trattandoli come materiale di lavoro per la bonifica. **Non scaricare tutti i secchi vuoti nella cassa inferiore**: conservarne a bordo una scorta minima configurabile, senza riempire indiscriminatamente i 16 slot. Se la scorta di secchi è insufficiente, la turtle, quando è alla postazione e ha secchi di lava disponibili, deve **continuare a rifornirsi anche oltre 4.000 unità di carburante** per produrre altri secchi vuoti, finché dispone di capacità sotto il vero limite `turtle.getFuelLimit()`. **4.000 non è un tetto massimo.** Per una Mining Turtle standard il limite di default è 20.000 (dipende da configurazione e tipo): leggerlo dall'API invece di fissarlo nel codice. Se è già piena di carburante, `turtle.refuel()` non può essere usato per generare ulteriori secchi: prevenirlo mantenendo la scorta di secchi in anticipo, e predisporre un'altra fonte di secchi vuoti soltanto come riserva. Gli slot utilizzati per secchi pieni d'acqua/lava non devono far sparire la riserva di vuoti. Conservare una scorta di blocchi di tamponamento, proteggere il carburante di rientro e usare un rifornimento/ricarico programmato quando serve, senza abbandonare la bonifica.
7. **Sicurezza e limiti geometrici:** non sconfinare nei settori delle altre turtle, né scavare dentro la base. In caso di lago o sorgente **fuori settore** che non si può eliminare fisicamente, tentare una bonifica/isolamento permanente con percorso interno alternativo. Se non esiste una soluzione fisicamente realizzabile nei 2 blocchi senza danneggiare i corridoi altrui, segnalare specificamente il limite, rientrare e chiedere intervento (eccezione, NON politica ordinaria). Non promettere eliminazione infinita di fluidi da grandi sorgenti fuori fascia.
8. **Telemetria:** nuova fase `BONIFICA` da aggiungere e testare nella centrale e nel miner (la centrale versione 1.0 non riconosce ancora questa parola). Visualizzare tipo di fluido, coordinate, numero di sorgenti raccolte, blocchi usati e tentativi. Non avviare 40 turtle contemporaneamente prima di collaudare casi di acqua e lava su N01.

### Punto di attenzione sul pilot esistente
Il prototipo `scripts/turtle/megazero_pilot.lua` **attualmente tratta `water` e `lava` come ostacoli insicuri che fanno scattare il rientro**: è accettabile soltanto per il test di geometria N01 già completato e **NON implementa il requisito di gestione fluidi**. La bonifica automatica dovrà essere sviluppata, simulata e collaudata esplicitamente prima dello scavo selettivo di produzione.

**Fonti:** API ufficiale CC:Tweaked `turtle.place()`, `turtle.placeUp()`, `turtle.placeDown()`, `turtle.inspect()`: https://tweaked.cc/mc-1.21.x/module/turtle.html ; comportamento dei fluidi e sostituzione con blocchi pieni: https://minecraft.wiki/w/Fluid . Queste indicazioni descrivono l'architettura proposta, **non un codice già sviluppato o testato nella partita**.

## Modulo fluidi N01 v1.0 pubblicato (15 novembre 2026)
- **Pubblicato su GitHub, branch `registro/megazero`:** [`scripts/turtle/megazero_fluidi.lua`](../scripts/turtle/megazero_fluidi.lua). File letto e verificato dopo il commit. **NON ancora eseguito o collaudato in Minecraft**.
- Prima implementazione riutilizzabile della bonifica: `M.peek(side)` legge acqua/lava vanilla con `inspect` e `state.level` (0 = sorgente), `M.resolve(side, coordinate, allow)` tenta **prelievo sorgente con secchio vuoto** o **sigillatura di una corrente con blocco pieno**, verificando il blocco risultante. Isolamento anche per sorgenti continuamente rigenerate. **Un blocco di tappo resta solido: il futuro miner dovrà aggirarlo/allontanare la sorgente, non scavarne immediatamente il tappo**.
- `M.countBuckets()` conta la scorta; `M.ensureBuckets(minimum)` **solo alla cassa di partenza** usa i secchi di lava dalla cassa superiore per generare secchi vuoti e aumentare il carburante, **senza limite artificiale a 4.000**, rispettando `turtle.getFuelLimit()`. I secchi vuoti **restano nell'inventario**; non sono scaricati nella cassa inferiore. In caso di serbatoio pieno o risorse insufficienti segnala il limite fisico, non inventa secchi.
- Supporta `front`, `up` e `down` come funzioni di intervento; il chiamante deve passare una funzione che **autorizza esplicitamente le coordinate nel proprio settore**, altrimenti nessun intervento.
- **Modalità collaudo fermo N01:** `megazero_fluidi N01`, dopo aver scaricato il programma sulla turtle; verifica configurazione `MINIERA-01/N01`, prepara scorta di **3 secchi**, ispeziona soltanto la cella **(2119,-53,2994)** immediatamente fuori dalla base. Se lì non c'è liquido, il test **non bonifica nulla e non modifica il mondo** (può solo usare secchi di lava in cassa per il carburante). Se trova sorgente/corrente, tenta la bonifica locale. **Non si sposta, non scava e non versa nuovi fluidi**. Attende Invio e riavvia la turtle, tornando allo startup.
- **Non integra ancora il programma di scavo `megazero_pilot`/la versione definitiva, né lo stato `BONIFICA` nel client/dashboard**: il protocollo centrale attuale non lo riconosce. Da integrare e testare **dopo** il collaudo dei secchi. Una corrente sigillata **non equivale** a un corridoio percorribile, e fonti fuori settore/grandi bacini non sono risolvibili in modo garantito: serve pianificazione del percorso e gestione autonoma delle risorse.
- **Percorso di download sulla N01:** `wget https://raw.githubusercontent.com/mycolbraga/MEGAZERO/registro/megazero/scripts/turtle/megazero_fluidi.lua megazero_fluidi`. Per la prova, interrompere eventuale test/boot **solo quando N01 è ferma alla base**; non modificare i 40 file `startup`.

## Punti ancora da definire
- **Conteggio e coordinate delle 40 turtle definiti:** 10 per lato a distanza di 2 blocchi, ciascuna rivolta verso l'esterno (vedere «Mappa esatta»). Da progettare punti di uscita, settori e percorsi protetti.
- Documentare il layout **già costruito** di casse, importers, alimentazione/carburante e rete RS; verificarne il comportamento nei test, senza considerarlo già testato.
- Implementare i settori approvati e il percorso d'accesso confermato (un passo fuori dal perimetro a Y=-53 e poi movimento verticale esterno), le passate da Y=0 alla bedrock e i rientri lungo la propria via d'uscita (300 blocchi per fronte).
- Elenco dei minerali vanilla e mod da mantenere; trattamento di tutti gli altri drop.
- Metodo sicuro per scartare gli scarti senza perdere minerali.
- Implementare e collaudare per tutte e 40 le turtle **rientro di emergenza su errore recuperabile, riserva carburante, tracciamento percorso, file/terminale di allarme in base**, senza arresti volontari sul fronte.
- Progettare come distribuire in modo selettivo la ricerca di vene lungo gallerie e pareti già esposte, senza scavare interamente il volume.
- Progettare **tutte le postazioni e i percorsi insieme**, quindi eseguire prove controllate prima di avviare più turtle contemporaneamente.

**Nota di stato:** la struttura fisica e i collegamenti sono riportati come **già piazzati e collegati dal giocatore** (screenshot 15 novembre 2026); i **programmi minerari e la loro funzionalità** non sono ancora stati verificati. Non confondere installazione e funzionamento.
