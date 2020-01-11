# Cheatsheet m68K opcodes
## DC
- Sintaxis: \(etiqueta opcional\) DC.\[longitud\]
- Descripción: Declare constant. Declara una constante que se almacena en la rom, la etiqueta permite referenciarla más tarde
- Ejemplos:
```
    DC.W "HELLO WORLD"
```

## MOVE
- Sintaxis: MOVE.\[longitud\] \[origen\],\[destino\]
- Descripción: Mueve el valor de longitud definida desde origen hacia destino. Origen y destino pueden ser: Valores "inmediatos" (simil hardcodeo), valores en un registro o valores en una posición de memoria (d ó a)
- Variantes:
1. MOVEM: Move multiple. Permite mover información desde/hacia múltiples registros y/o direcciones de memoria
2. MOVEA: Move address. Mueve los contenidos de origen a la dirección destino
- Ejemplos:
```
MOVE.L #$A, d0 ; Mueve el valor A en hexa (10 en decimal) al registro d0
MOVE.L #%1010, d0 ; Mueve el valor 1010 en binario (10 decimal) al registro d0
MOVE.L #10, d0 ; Mueve el valor 10 en decimal al registro d0
MOVE.L d1, d0 ; Mueve el contenido almacenado en el registro d1 a d0
MOVE.L 0x5000, d0 ; Mueve el valor guardado en dirección 0x5000 al registro d0
MOVE.L (a0), d0 ; Mueve el valor guardado en la dirección almacenada en a0 al registro d0
MOVE.L d0, (a0) ; Mueve el valor guardado en d0 sobreescribiendo el valor almacenado en la dirección que contiene el registro a0
MOVEM.L (a0), d0-d7/a1-a7 ; Mueve el valor guardado en la dirección de a0 al resto de los registros de datos y direcciones
MOVE.B (a1,d2.w), d3 ; Mueve el valor guardado en la dirección que resulta de computar a1 + d2 en d3
```

## ADD
- Sintaxis: ADD.\[longitud\] \[origen\],\[destino\]
- Descripción: Añade el valor de origen al valor en destino, almacenando el resultado en destino. Origen puede ser: Valor inmediato, contenidos de un registro (d ó a) ó valor en posición de memoria. Destino pueden ser un registro (d ó a) ó valor en posición de memoria
- Variantes:
1. ADDI: Add immediate. Añade sólo valor inmediato al registro (se supone que es más rápido que ADD)
2. ADDA: Add address. Añade el valor a una dirección (dirección en si, no el valor en esa dirección)
3. ADDQ: Add quickly. Añade pequeño valor inmediato (1 a 8) al registro destino (se supone que es el más rápido)
- Ejemplos:
```
ADD.W d1, d2 ; Añade el word almacenado en el registro d1 al valor en el registro d2
ADDQ.B #0x5, d1 ; Añade rápidamente el valor inmediato 5 (en decimal) en el valor almacenado en d1
```

## MULU
- Sintaxis: MULU.\[longitud\] \[origen\],\[destino\]
- Descripción: Unsigned multiply. Multiplica el destino por el origen, poniendo el resultado en el destino. Multiplicar dos word genera un longword
- Variantes:
1. MULS: Signed multiply
- Ejemplo:
```
    MULU.W   #$4, d1 ; Multiplica d1 por 4
```

## SUB
- Sintaxis: SUB.\[longitud\] \[origen],\[destino\]
- Descripción: Substract. Resta al destino el valor de origen y el resultado lo almacena en destino
- Variantes:
1. SUBI: Substract immediate
2. SUBQ: Substract quickly
- Ejemplo:
```
    SUB.B   #$1, d1 ; Substrae un byte de d1
```

## DIV
- Falta! (se supone que divide pero hay que ver el orden)

## CLR
- Sintaxis: CLR.\[longitud\] \[destino\]
- Descripción: Setea a 0 la información almacenada. Destino puede ser: Contenidos de un registro (d ó a) ó valor en posición de memoria
- Ejemplos:
```
CLR.L d1 ; Limpia todo el contenido del registro d1
CLR.W (a0) ; Limpia el bottom word de la información almacenada en la dirección guardada en a0
```

## JMP
- Sintaxis: JMP \[destino\]
- Descripción: Setea el PC a la posición de memoria indicada en destino. En otras palabras, salta incondicionalmente al label o posición de memoria indicado (en hex)
- Ejemplo:
```
LOOP:
    JMP LOOP ; Loop infinito
```

## JSR
- Sintaxis: JSR \[destino\]
- Descripción: Jump to subroutine. Realiza un JMP al destino indicado (label o posición de memoria), almacenando la dirección del PC previa al salto del en el stack de llamadas (registro a7). RTS (return to subroutine) vuelve a la dirección desde donde se llamó (pop del stack)
- Ejemplo:
```
    JSR Function ; Llama a la función

Function:
    <...> ; Hacer algo
    rts ; Vuelve a donde se llamó Function
```

## DBRA
- Sintaxis: DBRA \[registro\], \[destino\]
- Descripción: Decrement and branch. Decrementa 1 del registro indicado en cada iteración. Si el registro es distinto de 0 hace JMP a destino. Si es 0 sigue a la siguiente línea luego de DBRA
- Ejemplo:
```
    MOVE.B #0x4, d0 ; Loopea 5 iteraciones (incluye iteración 0)
 
Loop:
    <...> ; Hacer algo
    DBRA d0, Loop ; Decrementa 1 de d0 y si es mayor a 0 salta a Loop
```

## CMP
- Sintaxis: CMP \[valor\], \[destino\]
- Descripción: Compara si el valor es igual al que está en destino. El resultado de la comparación se almacena en el flag del cpu (por ejemplo Z es 0) para luego ser utilizado (por ejemplo por BEQ)
- Ejemplos: Ver BEQ

## BEQ
- Sintaxis: BEQ \[destino\]
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
```
    CMP.B #$0, d1 ; Prueba si d1 es 0
    BEQ.B @End ; Si la comparación da igual, salta a @End, sino sigue
    <...> ; Hacer algo

    @End:
    RTS
```

## ANDI
- Sintaxis: ANDI \[máscara\], \[destino\]
- Descripción: AND immediate. Realiza un AND con un número inmediato como máscara. Almacena el resultado en el destino
- Ejemplo:
```
    ANDI.B #$F, D0 ; AND lógico a D0 con 0xF (1111 en binario)
```

## BTST
- Sintaxis: BTST \[número de bit del destino\], \[destino\]
- Descripción: El bit especificado del operando destino es testeado y el resultado de la comparación se guarda en los flags del CPU
- Ejemplo:
```
    BTST #$0, 0x00A11100 ; Prueba el bit 0 del puerto indicado
```

## LEA
- Sintaxis: LEA \[origen\], \[destino\]
- Descripción: Load effective address. Carga la dirección o etiqueta efectiva al registro destino. Más rápido que MOVE
- Ejemplo:
```
    LEA Table, A0 ; Carga la dirección de la etiqueta Table en a0
```

## SWAP
- Sintaxis: SWAP \[registro\]
- Descripción: Intercambia el upper word con el lower word de un registro (almacena longword)
- Ejemplo:
```
    SWAP D0 ; Si tenía 2222EEEE luego pasa a tener EEEE2222
```

## STOP
- Sintaxis: STOP \[operando\]
- Descripción: Detiene el CPU M68k, copiando el operando (valor inmediato) al registro de estado y el PC queda en la siguiente instrucción
- Ejemplo:
```
    STOP #$2700
```

## EQU
- Sintaxis: \[Etiqueta\] EQU \[ecuación\]
- Descripción: Equate. Resuelve la ecuación y la asocia a una etiqueta (lo hace el preprocesador del ensamblador, a la hora de ejecutar no se ve). Útil para constantes o valores calculados
- Ejemplo:
```
PixelFontSizeB equ (PixelFontEnd-PixelFont) ; Tamaño de la fuente en bytes
```

## NOP
- Sintaxis: NOP
- Descripción: No operation. No realiza ninguna operación, útil para hacer pausas en el código. Prosigue la operación cuando todas las operaciones de bus se completaron. Sincroniza el pipeline y previene solapamiento de instrucciones

## ROR
- Sintaxis: ROR.\[longitud\] \[cantidad\] \[destino\]
- Descripción: Rotate right. Rota ("shiftea") los bits a la derecha del operando destino según la cantidad indicada. La operación es circular (si el valor se pasa del límite derecho, "loopea" desde el límite izquierdo), no se pierden datos
- Variantes:
1. ROL: Rotate left. Rota los bits a la izquierda
- Ejemplo:
```
    ROR.L    #$8, D1 ; Shiftea 8 bits a la derecha el valor en D1
```


### Documentación
- [M64K instruction set](http://wpage.unina.it/rcanonic/didattica/ce1/docs/68000.pdf)
