; ******************************************************************
; Sega Megadrive ROM header
; ******************************************************************
    dc.l   0x00FFE000      ; Initial stack pointer value
    dc.l   EntryPoint      ; Start of program
    dc.l   Exception       ; Bus error
    dc.l   Exception       ; Address error
    dc.l   Exception       ; Illegal instruction
    dc.l   Exception       ; Division by zero
    dc.l   Exception       ; CHK exception
    dc.l   Exception       ; TRAPV exception
    dc.l   Exception       ; Privilege violation
    dc.l   Exception       ; TRACE exception
    dc.l   Exception       ; Line-A emulator
    dc.l   Exception       ; Line-F emulator
    dc.l   Exception       ; Unused (reserved)
    dc.l   Exception       ; Unused (reserved)
    dc.l   Exception       ; Unused (reserved)
    dc.l   Exception       ; Unused (reserved)
    dc.l   Exception       ; Unused (reserved)
    dc.l   Exception       ; Unused (reserved)
    dc.l   Exception       ; Unused (reserved)
    dc.l   Exception       ; Unused (reserved)
    dc.l   Exception       ; Unused (reserved)
    dc.l   Exception       ; Unused (reserved)
    dc.l   Exception       ; Unused (reserved)
    dc.l   Exception       ; Unused (reserved)
    dc.l   Exception       ; Spurious exception
    dc.l   Exception       ; IRQ level 1
    dc.l   Exception       ; IRQ level 2
    dc.l   Exception       ; IRQ level 3
    dc.l   HBlankInterrupt ; IRQ level 4 (horizontal retrace interrupt)
    dc.l   Exception       ; IRQ level 5
    dc.l   VBlankInterrupt ; IRQ level 6 (vertical retrace interrupt)
    dc.l   Exception       ; IRQ level 7
    dc.l   Exception       ; TRAP #00 exception
    dc.l   Exception       ; TRAP #01 exception
    dc.l   Exception       ; TRAP #02 exception
    dc.l   Exception       ; TRAP #03 exception
    dc.l   Exception       ; TRAP #04 exception
    dc.l   Exception       ; TRAP #05 exception
    dc.l   Exception       ; TRAP #06 exception
    dc.l   Exception       ; TRAP #07 exception
    dc.l   Exception       ; TRAP #08 exception
    dc.l   Exception       ; TRAP #09 exception
    dc.l   Exception       ; TRAP #10 exception
    dc.l   Exception       ; TRAP #11 exception
    dc.l   Exception       ; TRAP #12 exception
    dc.l   Exception       ; TRAP #13 exception
    dc.l   Exception       ; TRAP #14 exception
    dc.l   Exception       ; TRAP #15 exception
    dc.l   Exception       ; Unused (reserved)
    dc.l   Exception       ; Unused (reserved)
    dc.l   Exception       ; Unused (reserved)
    dc.l   Exception       ; Unused (reserved)
    dc.l   Exception       ; Unused (reserved)
    dc.l   Exception       ; Unused (reserved)
    dc.l   Exception       ; Unused (reserved)
    dc.l   Exception       ; Unused (reserved)
    dc.l   Exception       ; Unused (reserved)
    dc.l   Exception       ; Unused (reserved)
    dc.l   Exception       ; Unused (reserved)
    dc.l   Exception       ; Unused (reserved)
    dc.l   Exception       ; Unused (reserved)
    dc.l   Exception       ; Unused (reserved)
    dc.l   Exception       ; Unused (reserved)
    dc.l   Exception       ; Unused (reserved)
    
    dc.b "SEGA GENESIS    "                                 ; Console name
    dc.b "(C)SEGA 1992.SEP"                                 ; Copyright holder and release date
    dc.b "YOUR GAME HERE                                  " ; Domestic name
    dc.b "YOUR GAME HERE                                  " ; International name
    dc.b "GM XXXXXXXX-XX"                                   ; Version number
    dc.w 0x0000                                             ; Checksum
    dc.b "J               "                                 ; I/O support
    dc.l 0x00000000                                         ; Start address of ROM
    dc.l __end                                              ; End address of ROM
    dc.l 0x00FF0000                                         ; Start address of RAM
    dc.l 0x00FFFFFF                                         ; End address of RAM
    dc.l 0x00000000                                         ; SRAM enabled
    dc.l 0x00000000                                         ; Unused
    dc.l 0x00000000                                         ; Start address of SRAM
    dc.l 0x00000000                                         ; End address of SRAM
    dc.l 0x00000000                                         ; Unused
    dc.l 0x00000000                                         ; Unused
    dc.b "                                        "         ; Notes (unused)
    dc.b "JUE             "                                 ; Country codes

EntryPoint:
Loop:
    jsr MOVExample
    jsr ADDExample
    jsr CLRExample
    jsr DBRAExample
    jsr BEQExample
    jmp Loop

MOVExample:
    move.l #$10, d0   ; Moves the hex value 0x10 (decimal 16) to register d0
    move.l #%0101, d0 ; Moves the binary value 0101 (decimal 5) to register d0
    move.l #12, d0    ; Moves the decimal value 12 to register d0
    move.l d1, d0     ; Moves the value stored in register d1 to register d0
    move.l 0x8000, d0 ; Moves the value stored at address 0x8000 to register d0
    move.l d0, 0x8000 ; Moves the value stored in register d0 to address 0x8000
    move.l (a0), d0   ; Moves the value stored at the address in a0 to register d0
    move.l d0, (a0)   ; Moves the value stored in register d0 to the address stored in register a0
    rts

ADDExample:
    move.l #$2, d0
    move.l #$4, d1
    move.l #$6, 0xFF8000
    add.l #$1, d0           ; Adds 9 hexa to d1 register
    add.l d0, d1            ; Adds d0 content to d1
    add.l 0xFF8000, d0      ; Adds content at memory address FF8000 (currently 6 in hexa) to d0
    add.l d0, 0xFF8000      ; Test
    rts

CLRExample:
    clr.l d0
    clr.l d1
    clr.l 0xFF8000
    rts

DBRAExample:
    move.b #$4, d0  ; Looping 5 iterations (includes the 0th iteration)
    @Label:         ; Local Label
    add.l #$1, d1   ; Add 1 do register d1
    dbra d0, @Label ; Test to see if d0 is zero yet, and if not decrement it and jump to Label
    clr.l d1        ; Loop has finished, clear d1
    rts

BEQExample:
    move.l #String, a0      ; Move address of string to a0
    jsr GetStringLength     ; Jump to the GetStringLength subroutine
    rts
String:
    dc.b "HELLO WORLD", 0   ; A zero-terminated string (after the text inserts a zero, used in compare)
GetStringLength:
    clr.l d0                ; Clear d0, ready to begin counting
    @FindTerm:
    move.b (a0)+, d1        ; Move byte from address in a0 to d1, and then increment the address of a0 by 1 byte
    cmp.b #$0, d1           ; Test if byte is zero
    beq.b @End              ; If byte was zero, branch to end
    addq.l #$1, d0          ; Increment counter
    jmp @FindTerm           ; Jump back to FindTerm to loop again
    @End:
    rts                     ; End of search, return back. Result is in d0

 
HBlankInterrupt:
VBlankInterrupt:
    rte   ; Return from Interrupt
 
Exception:
    rte   ; Return from Exception
 
__end    ; Very last line, end of ROM address