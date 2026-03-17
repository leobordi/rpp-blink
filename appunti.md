# RASPBERRY PI PICO LED BLINK

Programma in assembly che fà blinkare il led integrato nel raspberry pi pico.
Il led integrato è controllabile dal GPIO 25. 

### SIO-GPIO

Per poter fare cose su un GPIO bisogna prima collegarlo al SIO (Single-Cyle Input Output), un blocco di periferiche che può eseguire operazioni atomiche in tempi molto veloci (1 ciclo cpu). Ognuno dei due processori ARM Cortex-M0+ ha una bus port ausiliaria (chiamata IOPORT, può fare operazioni di lettura e scrittura veloci a 32-bit) per comunicare con il SIO, il SIO a sua volta ha una bus interface dedicata per ogni processore.
I 2 processori accedono all'IOPORT con operazioni di load e store dirette al suo segmento speciale di indirizzi 0xd0000000-0xdfffffff. Nello spazio dell'IOPORT il SIO è memory-mapped perchè i suoi registri sono mappati da 0xd0000000 a 0xd000017c (da capire quanto è lunga una word perchè adesso non lo so), il rimanente spazio è riservato per uso futuro.
