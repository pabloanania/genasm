# Cheatsheet m68K opcodes
## MOVE
- Sintaxis: MOVE.<longitud> <origen>,<destino>
- Descripción: Mueve el valor de longitud definida desde origen hacia destino. Origen y destino pueden ser: Valores "inmediatos" (simil hardcodeo), valores en un registro o valores en una posición de memoria (d ó a)
- Ejemplos:
1. MOVE.L #$A, d0 ; Mueve el valor A en hexa (10 en decimal) al registro d0
2. MOVE.L #%1010, d0 ; Mueve el valor 1010 en binario (10 decimal) al registro d0
3. MOVE.L #10, d0 ; Mueve el valor 10 en decimal al registro d0
4. MOVE.L d1, d0 ; Mueve el contenido almacenado en el registro d1 a d0
4. MOVE.L 0x5000, d0 ; Mueve el valor guardado en dirección 0x5000 al registro d0
5. MOVE.L (a0), d0 ; Mueve el valor guardado en la dirección almacenada en a0 al registro d0
6. MOVE.L d0, (a0) ; Mueve el valor guardado en d0 sobreescribiendo el valor almacenado en la dirección que contiene el registro a0

## ADD
- Sintaxis: ADD.<longitud> <origen>,<destino>
- Descripción: Añade el valor de origen al valor en destino, almacenando el resultado en destino. Origen puede ser: Valor inmediato o contenidos de un registro (d ó a) (posición de memoria no?). Destino pueden ser un registro (d ó a)
- Variantes:
1. ADDI: Add immediate. Añade sólo valor inmediato al registro (se supone que es más rápido que ADD)
2. ADDA: Add address. Añade el valor a una dirección (dirección en si, no el valor en esa dirección)
3. ADDQ: Add quickly. Añade pequeño valor inmediato (1 a 8) al registro destino (se supone que es el más rápido)
4. ADDX: Ver (?)
- Ejemplos:
1. ADD.W d1, d2 ; Añade el word almacenado en el registro d1 al valor en el registro d2
2. ADDQ.B #0x5, d1 ; Añade rápidamente el valor inmediato 5 (en decimal) en el valor almacenado en d1

## MUL
- Falta! (se supone que multiplica el valor de origen al registro destino)

## SUB
- Falta! (se supone que sustrae pero hay que ver el orden)

## DIV
- Falta! (se supone que divide pero hay que ver el orden)

## CLR
- Sintaxis: CLR.<longitud> <destino>
- Descripción: Setea a 0 la información almacenada. Destino puede ser: Contenidos de un registro (d ó a) (posición de memoria no?)
- Ejemplos:
1. CLR.L d1 ; Limpia todo el contenido del registro d1
2. CLR.W (a0) ; Limpia el bottom word de la información almacenada en la dirección guardada en a0

## JMP
- Sintaxis: JMP <destino>
- Descripción: Setea el PC a la posición de memoria indicada en destino. En otras palabras, salta incondicionalmente al label o posición de memoria indicado (en hex)
- Ejemplo:
LOOP:
    JMP LOOP ; Loop infinito

## JSR
- Sintaxis: JSR <destino>
- Descripción: Jump to subroutine. Realiza un JMP al destino indicado (label o posición de memoria), almacenando la dirección del PC previa al salto del en el stack de llamadas (registro a7). RTS (return to subroutine) vuelve a la dirección desde donde se llamó (pop del stack)
- Ejemplo:
    JSR Function ; Llama a la función

Function:
    <...> ; Hacer algo
    rts ; Vuelve a donde se llamó Function

## DBRA
- Sintaxis: DBRA <registro>, <destino>
- Descripción: Decrement and branch. Decrementa 1 del registro indicado en cada iteración. Si el registro es distinto de 0 hace JMP a destino. Si es 0 sigue a la siguiente línea luego de DBRA
- Ejemplo:
    MOVE.B #0x4, d0 ; Loopea 5 iteraciones (incluye iteración 0)
 
Loop:
    <...> ; Hacer algo
    DBRA d0, Loop ; Decrementa 1 de d0 y si es mayor a 0 salta a Loop

## CMP
- Sintaxis: CMP <valor>, <destino>
- Descripción: Compara si el valor es igual al que está en destino. El resultado de la comparación se almacena en el registro status (ver?) para luego ser utilizado (por ejemplo por BEQ)
- Ejemplos: Ver BEQ

## BEQ
- Sintaxis: BEQ <destino>
- Descripción: Si se cumple la condición probada por CMP y da una igualdad (ejemplo se comparan dos numeros y dan igual), salta a la etiqueta o dirección destino, sino sigue a la siguiente línea luego de BEQ
- Variantes:
1. BGT: Branch on greather than
2. BGE: Branch on greater or equal
3. BLE: Branch on less or equal
4. BLT: Branch on less than
5. BNE: Branch on not equal
6. BMI: Branch on minus (por ejemplo dio negativo)
7. BPL: Branch on plus (por ejemplo dio positivo)
- Ejemplo:
    CMP.B #$0, d1 ; Prueba si d1 es 0
    BEQ.B @End ; Si la comparación da igual, salta a @End, sino sigue
    <...> ; Hacer algo

    @End:
    RTS

### Documentación
- [M64K instruction set](http://wpage.unina.it/rcanonic/didattica/ce1/docs/68000.pdf)
