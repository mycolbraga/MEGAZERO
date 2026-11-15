# MEGAZERO — Progetto base mineraria e Mining Turtle

## Stato (15 novembre 2026)
**In progettazione.** Sono state definite le coordinate dell'area destinata alla base; disposizione, numero di turtle, programmi e collegamenti non sono ancora stati stabiliti o verificati in gioco.

## Area della base — confermata dal giocatore
- Angolo 1: **X=2117, Y=-52, Z=2995**
- Angolo 2: **X=2108, Y=-52, Z=3012**
- Estensione inclusiva: **X 2108..2117 (10 blocchi), Z 2995..3012 (18 blocchi)**, superficie **10 × 18 = 180 blocchi** alla quota **Y=-52**.
- Destinazione: **Mining Turtle, casse di ingresso/uscita e rifornimento, collegamenti Refined Storage e componenti necessari**.
- La precedente Z=3995 era un errore di trascrizione **corretto dal giocatore in Z=2995**; non usarla.

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
- Si tratta dell'orientamento **visto dalla base mineraria** (X 2108..2117, Z 2995..3012, Y=-52), non dei confini assoluti dell'intera caverna.
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
- **Quattro scavi principali contemporanei** nelle direzioni **NORD (-Z), SUD (+Z), EST (+X), OVEST (-X)**. **Il numero di Mining Turtle per ciascuno scavo NON è ancora definito**: quattro scavi non significa quattro turtle.
- **NORD/SUD:** pareti di roccia già indicate vicino alla base; possibili gallerie nella roccia.
- **EST:** inizio della mineshaft; tracciato da verificare per evitare di trattare i vuoti della miniera come roccia piena.
- **OVEST:** la caverna continua; percorso in spazio aperto da pianificare.
- Le **quattro direzioni di scavo** sono la proposta del giocatore; numero e disposizione delle turtle, percorsi e dimensioni dei tunnel restano da definire. Non presumere una turtle per direzione.
- Prima del codice: progettare postazioni e accessi in base al numero effettivo di turtle da scegliere, all'interno della base 10×18; gestire vuoti/dislivelli, dimensione dei settori, rientro, rifornimento e scarico RS.

## Punti ancora da definire
- Numero di turtle per ciascuno dei quattro scavi; posizione e orientamento individuale nell'area 10×18; punti di uscita e percorsi protetti.
- Layout esatto di casse, importers, alimentazione/carburante e rete RS.
- Coordinate/quote/limiti dei settori minerari e percorso protetto dalla base.
- Elenco dei minerali vanilla e mod da mantenere; trattamento di tutti gli altri drop.
- Metodo sicuro per scartare gli scarti senza perdere minerali.
- Strategia effettiva di estrazione dalle pareti esposte vs gallerie nella roccia.
- Test con una turtle e galleria breve **prima** di estendere il sistema.

**Nota:** nessuna struttura fisica o automazione va considerata già realizzata soltanto perché descritta in questo registro.
