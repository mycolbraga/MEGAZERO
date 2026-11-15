# MEGAZERO — Progetto base mineraria e Mining Turtle

## Stato (15 novembre 2026)
**In progettazione.** Sono state definite le coordinate dell'area destinata alla base; disposizione, numero di turtle, programmi e collegamenti non sono ancora stati stabiliti o verificati in gioco.

## Area della base — coordinate rilevate dal giocatore (15 novembre 2026)
- **Primo angolo comunicato:** **X=2099, Y=-52, Z=3015**.
- **Secondo angolo comunicato:** **X=2119, Y=-25, Z=2995**.
- **Intervallo coordinate:** **X=2099..2119**, **Y=-52..-25**, **Z=2995..3015**.
- **Differenza tra le coordinate estreme:** 20 blocchi lungo X, 27 lungo Y, 20 lungo Z.
- **Conteggio inclusivo dei blocchi:** **21 × 21 blocchi in pianta** (441 posizioni per strato) e **28 livelli Y** se le due coordinate identificano davvero i vertici opposti di un volume. La funzione dell'intervallo verticale, inclusa l'eventuale quota del pavimento, **è da confermare**: non presumere che Y=-25 sia un errore né che tutta la base debba essere scavata su 28 livelli.
- **Queste coordinate supersedono le ipotesi precedenti** di rettangoli 10×18 o 20×20; tali misure sono ormai solo cronologia, non i confini operativi.
- **Stato:** angoli comunicati dal giocatore; esatta destinazione dei livelli Y e layout interni non ancora confermati o costruiti.
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
- Si tratta dell'orientamento **visto dalla base mineraria** (coordinate attuali: X 2099..2119, Z 2995..3015, Y da -52 a -25; uso delle quote ancora da confermare), non dei confini assoluti dell'intera caverna.
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
- Prima del codice: verificare **se 32–40 postazioni con casse e RS entrano nel perimetro rilevato (X2099..2119, Z2995..3015: 21×21 blocchi inclusivi)**, ed eventualmente a quali quote Y. Il fronte dista 20 blocchi tra le coordinate estreme; il numero di turtle per settore rimane 8–10 come previsione, non una disposizione già risolta. Progettare le postazioni solo dopo aver definito numero e accessi; gestire vuoti/dislivelli, settori, rientro, rifornimento e scarico RS.

## Punti ancora da definire
- Numero definitivo di turtle per fronte (attualmente previsto 8–10); posizione e orientamento individuale, punti di uscita e percorsi protetti.
- Layout esatto di casse, importers, alimentazione/carburante e rete RS.
- Coordinate/quote/limiti dei settori minerari e percorso protetto dalla base.
- Elenco dei minerali vanilla e mod da mantenere; trattamento di tutti gli altri drop.
- Metodo sicuro per scartare gli scarti senza perdere minerali.
- Strategia effettiva di estrazione dalle pareti esposte vs gallerie nella roccia.
- Test con una turtle e galleria breve **prima** di estendere il sistema.

**Nota:** nessuna struttura fisica o automazione va considerata già realizzata soltanto perché descritta in questo registro.
