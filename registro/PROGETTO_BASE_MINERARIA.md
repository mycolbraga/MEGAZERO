# MEGAZERO — Progetto base mineraria e Mining Turtle

## Stato (15 novembre 2026)
**In progettazione.** Sono state definite le coordinate dell'area destinata alla base; disposizione, numero di turtle, programmi e collegamenti non sono ancora stati stabiliti o verificati in gioco.

## Area della base — ampliamento previsto verso EST (15 novembre 2026)
- **Confine OVEST invariato:** X=2108.
- **Nuovo confine EST calcolato:** X=2127 (10 blocchi aggiunti all'area precedente che terminava a X=2117).
- **Confini NORD/SUD invariati:** Z=2995..3012; quota Y=-52.
- **Nuovi angoli opposti di progetto:** (2108, -52, 3012) e (2127, -52, 2995).
- **Nuova estensione inclusiva:** X 2108..2127 (**20 blocchi**), Z 2995..3012 (**18 blocchi**) = **360 blocchi** alla quota Y=-52.
- **Motivo del dimensionamento:** 10 turtle affiancate, con 2 blocchi per turtle, richiedono 20 blocchi di fronte. Si allunga dunque l'asse X da 10 a 20 blocchi (non si aggiungono 20 blocchi ai 10 esistenti).
- **Attenzione:** l'asse Z resta di 18 blocchi; per un fronte EST/OVEST con 10 postazioni da 2 blocchi ne mancherebbero 2, senza contare eventuali margini e passaggi. Nessun ampliamento Z deciso, per ora.
- **Stato:** ampliamento progettato/calcolato, non dichiarato già costruito.
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
- Si tratta dell'orientamento **visto dalla base mineraria** (area ampliata prevista: X 2108..2127, Z 2995..3012, Y=-52), non dei confini assoluti dell'intera caverna.
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
- Prima del codice: verificare **se 32–40 postazioni con casse e RS entrano nell'area ampliata prevista 20×18** o se servono più livelli / ulteriori espansioni. L'asse Z misura solo 18 blocchi contro i 20 necessari per 10 turtle distanziate 2 blocchi. Progettare le postazioni solo dopo aver definito numero e accessi; gestire vuoti/dislivelli, settori, rientro, rifornimento e scarico RS.

## Punti ancora da definire
- Numero definitivo di turtle per fronte (attualmente previsto 8–10); posizione e orientamento individuale, punti di uscita e percorsi protetti.
- Layout esatto di casse, importers, alimentazione/carburante e rete RS.
- Coordinate/quote/limiti dei settori minerari e percorso protetto dalla base.
- Elenco dei minerali vanilla e mod da mantenere; trattamento di tutti gli altri drop.
- Metodo sicuro per scartare gli scarti senza perdere minerali.
- Strategia effettiva di estrazione dalle pareti esposte vs gallerie nella roccia.
- Test con una turtle e galleria breve **prima** di estendere il sistema.

**Nota:** nessuna struttura fisica o automazione va considerata già realizzata soltanto perché descritta in questo registro.
