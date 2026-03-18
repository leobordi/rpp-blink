# RASPBERRY PI PICO LED BLINK

Programma in assembly che fà blinkare il led integrato nel raspberry pi pico.
Il led integrato è controllabile dal GPIO 25. 

### Inizializzazione

Dopo il boot quasi tutte le periferiche che usano il bus APB sono in reset, per usarne una bisogna de-resettarla settando a 0 il giusto bit nel registro RESET (parte da 0x4000c000) altrimenti il bus non fà passare i segnali.
Il SIO non è in reset mode perchè ha un bus dedicato ma l'IO_BANK0 (multiplexer che smista i segnali tra periferiche e gpio) sì: per deresettarlo setto a 0 il bit 5 (sesto bit) del registro RESET.
Una volta modificato il RESET bisogna aspettare qualche ciclo di clock perchè la periferica sia effettivamente pronta. Per controllare se la periferica è pronta devo leggere il registro RESET_DONE (0x8 di offset rispetto a 0x4000c000), se il bit 5, nel caso di IO_BANK0, è a 1 allora la periferica è pronta.

### GPIO FUNCSEL SIO

Ogni GPIO può avere 1 funzione selezionata alla volta, a me serve la funzione 5 del GPIO 25 che sarebbe la funzione SIO.
A quanto pare devo agire sul registro IO_BANK0 (da 0x40014000). GIPIO25_CTRL è a offset 0x0cc:
i primi 4 bit servono per selezionare la funzione, in teoria il resto non devo modificarlo perchè il default mi va già bene.
Quindi scrivo 5 (SIO è F5) nei primi 4 bit.
Ora IO_BANK0 instraderà i segnali di GPIO_25 a SIO.


### Collegamento SIO-GPIO

Per poter fare cose su un GPIO bisogna prima collegarlo in qualche modo al SIO (Single-Cyle Input Output), un blocco di periferiche che può eseguire operazioni atomiche in tempi molto veloci (1 ciclo cpu). Ognuno dei due processori ARM Cortex-M0+ ha una bus port ausiliaria (chiamata IOPORT, può fare operazioni di lettura e scrittura veloci a 32-bit) per comunicare con il SIO, il SIO a sua volta ha una bus interface dedicata per ogni processore.
I 2 processori accedono all'IOPORT con operazioni di load e store dirette al suo segmento speciale di indirizzi 0xd0000000-0xdfffffff. Nello spazio dell'IOPORT il SIO è memory-mapped perchè i suoi registri sono mappati da 0xd0000000 a 0xd000017c (da capire quanto è lunga una word perchè adesso non lo so), il rimanente spazio è riservato per uso futuro.


