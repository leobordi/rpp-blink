# RASPBERRY PI PICO LED BLINK

Programma in assembly che fà blinkare il led integrato nel raspberry pi pico.
Il led integrato è controllabile dal GPIO 25. 

### Inizializzazione

Dopo il boot quasi tutte le periferiche che usano il bus APB sono in reset, per usarne una bisogna de-resettarla settando a 0 il giusto bit nel registro RESET (parte da 0x4000c000) altrimenti il bus non fà passare i segnali.
Il SIO non è in reset mode perchè ha un bus dedicato ma l'IO_BANK0 (multiplexer che smista i segnali tra periferiche e gpio) sì: per deresettarlo setto a 0 il bit 5 (sesto bit) del registro RESET.
Una volta modificato il RESET bisogna aspettare qualche ciclo di clock perchè la periferica sia effettivamente pronta. Per controllare se la periferica è pronta devo leggere il registro RESET_DONE (0x8 di offset rispetto a 0x4000c000), se il bit 5, nel caso di IO_BANK0, è a 1 allora la periferica è pronta.
Update: ogni registro delle periferiche può essere acceduto usando 4 modalità 2.1.2 rp2040 datasheet; a me interessa la modalità atomic bitmask clear on write (addr + 0x3000), che mette a 0 i bit che io metto a 1 dentro il registro, funziona proprio come un bitwise and tra una bitmask e il numero che voglio modificare, per modificare solo determinati bit nel numero originale. Meglio usare questa modalità perchè, oltre ad essere atomica, è meglio in sistemi multi core o interrupt

Processo:
	scrivo #32 in 0x4000f000


### GPIO FUNCSEL SIO

Ogni GPIO può avere 1 funzione selezionata alla volta, a me serve la funzione 5 del GPIO 25 che sarebbe la funzione SIO.
A quanto pare devo agire su IO_BANK0 (da 0x40014000). GIPIO25_CTRL è a offset 0x0cc:
i primi 4 bit servono per selezionare la funzione, in teoria il resto non devo modificarlo perchè il default mi va già bene.
Quindi scrivo 5 (SIO è F5) nei primi 4 bit.
Ora IO_BANK0 instraderà i segnali di GPIO_25 a SIO.

### Scrittura su GPIO25

Ora devo implementare il ciclo per blinkare il led.
Avrò bisogno dei registri GPIO_OUT e GPIO_OE (questi registri contengono i valori di tutti i GPIO, dal momento che voglio modificare solo il GPIO25 userò i registri atomici GPIO_OUT_SET, GPIO_OUT_CLEAR e GPIO_OE_SET).
Tutti i registri GPIO partono da 0xd0000000 (SIO_BASE):
* GPIO_OUT_SET 0xd0000000 + 0x014
* GPIO_OUT_CLEAR 0xd0000000 + 0x018
* GPIO_OE_SET 0xd0000000 + 0x024

### Delay blink

Per implementare il delay posso usare il ring oscillator integrato nell'rp2040.
I suoi registri partono da 0x40060000; posso usare il registro COUNT (offset +0x28), se ci scrivo dentro un numero non-zero lui lo decrementa fino a 0 e poi si ferma.
La frequenza con cui gira è proprio sua quindi può essere anche impostata tramite altri registri.

Quella sopra era l'idea iniziale, peccato che nel registro COUNT del ring oscillator, ci posso scrivere solo numeri a 8 bit che è troppo poco per un delay.
Devo usare quindi un semplice ciclo di decremento di un numero elevato.

### Compilazione

Per compilare il file assembly ho dovuto usare l'SDK con cmake e make.
