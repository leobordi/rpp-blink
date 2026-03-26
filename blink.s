.global _start

_start
	// Deresetto l'IO_BANK0 settando a 0 il bit 5 del registro RESET 
	mov r0, #32
	mov r1, 0x4000f000
	str r0, [r1, #0]
	
	// Controllo che il RESET sia avvenuto (ci vuole qualche clock cycle)
_reset_done:
	ldr r0, [0x4000c008]	// Carico in r0 il valore del registro RESET_DONE
	mov r1, #32	// Carico in r1 la bitmask per leggere il bit 5
	ands r0, r1	// Faccio il bitwise tra r0 e r1 salvando il risultato in r0
	beq _reset_done	// Se r0 == 0 allora ricontrollo RESET_DONE

	// Seleziono la funzione giusta nel GPIO_25
	ldr r0, [0x400140cc]	// Carico in r0 il contenuto del registro GPIO25_CTRL
	mov r1, #5		// Carico in r1 il numero che rappresenta la funzione del GPIO che voglio attivare (SIO)
	str r1, [r0]		// Salvo nel registro GPIO25_CTRL il nuovo valore
	
	// Abilito l'output per il GPIO_25
	mov r0, 0xd0000024	// Metto l'indirizzo del registro GPIO_OE_SET in r0
	mov r1, #1		// Metto 1 in r1
	lsl, r1, r1, #25	// Shifto a sinistra di 25 bit r1 e il risultato và in r1
	str r1, [r0]		// Scrivo nel registro GPIO_OE_SET il contenuto di r1 (ho settato il bit 25 perchè voglio abilitare GPIO_25)

	mov r3, 0x40060020
	mov r4, #20

_blink_loop:
	// Setto HI GPIO_25
	mov r0, 0xd0000014 	
	str r1, [r0]
	
	str r4, [r3]
	bl _delay

	// Setto LOW GPIO_25
	mov r0, 0xd0000018
	str r1, [r0]
	
	str r4, [r3]
	bl _delay

	// Rifaccio il ciclo
	b _blink_loop
	
_delay:
	ldr r5, [r3]
	cmp r5, #0
	bne _delay
