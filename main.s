.syntax unified
.cpu cortex-m0plus
.thumb

.global _start
.thumb_func

_start:
	// Deresetto l'IO_BANK0 settando a 0 il bit 5 del registro RESET 
	movs r0, #32
	ldr r1, =0x4000f000
	str r0, [r1, #0]
	
	// Controllo che il RESET sia avvenuto (ci vuole qualche clock cycle)
_reset_done:
    ldr r2, =0x4000c008
	ldr r0, [r2] // Carico in r0 il valore del registro RESET_DONE
	movs r1, #32	// Carico in r1 la bitmask per leggere il bit 5
	ands r0, r1	// Faccio il bitwise tra r0 e r1 salvando il risultato in r0
	beq _reset_done	// Se r0 == 0 allora ricontrollo RESET_DONE

	// Seleziono la funzione giusta nel GPIO_25
    ldr r0, =0x400140cc     // registro GPIO25_CTRL
	movs r1, #5		// Carico in r1 il numero che rappresenta la funzione del GPIO che voglio attivare (SIO)
	str r1, [r0]		// Salvo nel registro GPIO25_CTRL il nuovo valore
	
	// Abilito l'output per il GPIO_25
	ldr r0, =0xd0000024	// Metto l'indirizzo del registro GPIO_OE_SET in r0
	movs r1, #1		// Metto 1 in r1
	lsls r1, r1, #25	// Shifto a sinistra di 25 bit r1 e il risultato và in r1
	str r1, [r0]		// Scrivo nel registro GPIO_OE_SET il contenuto di r1 (ho settato il bit 25 perchè voglio abilitare GPIO_25)

_blink_loop:
	// Setto HI GPIO_25
	ldr r0, =0xd0000014 	
	str r1, [r0]
	
    // carico in r3 un numero grosso per il delay e salto alla routine di delay
    ldr r3, =0x00500000
	bl _delay

	// Setto LOW GPIO_25
	ldr r0, =0xd0000018
	str r1, [r0]
	
    ldr r3, =0x00500000
	bl _delay

	// Rifaccio il ciclo
	b _blink_loop
	
_delay:     // sottraggo 1 al numero in r3 finchè non arriva a 0
    subs r3, #1
	bne _delay
    bx lr

