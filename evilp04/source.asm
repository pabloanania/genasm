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
; *** RESET CHECK ***
ResetCheck:
    tst.w 0x00A10008  ; Test unknown reset (expansion port reset?). Addresses starting from 0x00A00000 are not from RAM, but are the system I/O areas, points to ports or memory of other coprocessors within the Megadrive
    bne Main          ; Branch if Not Equal (to zero) - to Main
    tst.w 0x00A1000C  ; Test reset button
    bne Main          ; Branch if Not Equal (to zero) - to Main

; *** RAM CLEAR ***
RAMClear:
    move.l #0x00000000, d0     ; Place a 0 into d0, ready to copy to each longword of RAM (for clearing it)
    move.l #0x00000000, a0     ; Starting from address 0x0, clearing backwards
    move.l #0x00003FFF, d1     ; Clearing 64k's worth of longwords (minus 1, for the loop to be correct)
    @Clear:
    move.l d0, -(a0)           ; Decrement the address at a1 by 1 longword, before moving the zero from d0 to it
    dbra d1, @Clear            ; Decrement d0, repeat until depleted

; *** ANTI PIRACY CHECK ***
AntiPiracyCheck:
    move.b 0x00A10001, d0      ; Move Megadrive hardware version to d0
    andi.b #0x0F, d0           ; The version is stored in last four bits, so mask it with 0F (01111 binary)
    beq @Skip                  ; If version is equal to 0, skip TMSS signature
    move.l #'SEGA', 0x00A14000 ; Move the string "SEGA" to 0xA14000
    @Skip:

; *** Z80 INIT ***
Z80Init:
    move.w #0x0100, 0x00A11100 ; Request access to the Z80 bus, by writing 0x0100 into the BUSREQ port
    move.w #0x0100, 0x00A11200 ; Hold the Z80 in a reset state, by writing 0x0100 into the RESET port
    @Wait:
    btst #0x0, 0x00A11100      ; Test bit 0 of A11100 to see if the 68k has access to the Z80 bus yet
    bne @Wait                  ; If we don't yet have control, branch back up to Wait
    move.l #Z80Data, a0        ; Load address of data into a0
    move.l #0x00A00000, a1     ; Copy Z80 RAM address to a1
    move.l #0x29, d0           ; 42 bytes of init data (minus 1 for counter)
    @Copy:
    move.b (a0)+, (a1)+        ; Copy data from a0 address (data origin) to a1 address (data dest), and increment the source/dest addresses
    dbra d0, @Copy
    move.w #0x0000, 0x00A11200 ; Release reset state
    move.w #0x0000, 0x00A11100 ; Release control of bus
    jmp PSGInit                ; Jumps to PSG Initialization

Z80Data:                       ; Data for Z80 initialization purposes
    dc.w 0xaf01, 0xd91f
    dc.w 0x1127, 0x0021
    dc.w 0x2600, 0xf977
    dc.w 0xedb0, 0xdde1
    dc.w 0xfde1, 0xed47
    dc.w 0xed4f, 0xd1e1
    dc.w 0xf108, 0xd9c1
    dc.w 0xd1e1, 0xf1f9
    dc.w 0xf3ed, 0x5636
    dc.w 0xe9e9, 0x8104
    dc.w 0x8f01

; *** PSG INIT ***
PSGInit:
    move.l #PSGData, a0      ; Load address of PSG data into a0
    move.l #0x03, d0         ; 4 bytes of data
    @Copy:
    move.b (a0)+, 0x00C00011 ; Copy data from PSGData address to PSG RAM and increments one address
    dbra d0, @Copy
    jmp VDPInit              ; Jumps to VDP initialization
 
PSGData:
   dc.w 0x9fbf, 0xdfff

; *** VDP INIT ***
; !!! IMPORTANT: AFTER DEBUGGING I THINK THAT IS NOT INITIALIZING CORRECTLY !!!
VDPInit:
    move.l #VDPRegisters, a0 ; Load address of register table into a0
    move.l #0x18, d0         ; 24 registers to write
    move.l #0x00008000, d1   ; 'Set register 0' command (and clear the rest of d1). The top nybble (hexa digit, 4 bits, half byte) is the command – 0x8XXX means set register value. Second nybble is the register number – 0x81XX = set register 1, etc. Last byte is the data - 0x82FF writes FF into register 2

    @Copy:
    move.b (a0)+, d1         ; Move register value to lower byte of d1 (first iteration = 8020 and then moves one byte to next data in register table)
    move.w d1, 0x00C00004    ; Write command and value to VDP control port
    add.w #0x0100, d1        ; Increment register # (adds 1 to second nybble)
    dbra d0, @Copy
    jmp ControllersInit      ; Jumps to controllers initialization

VDPRegisters:
    dc.b 0x20 ; 0: Horiz. interrupt on, plus bit 2 (unknown, but docs say it needs to be on)
    dc.b 0x74 ; 1: Vert. interrupt on, display on, DMA on, V28 mode (28 cells vertically), + bit 2
    dc.b 0x30 ; 2: Pattern table for Scroll Plane A at 0xC000 (bits 3-5)
    dc.b 0x40 ; 3: Pattern table for Window Plane at 0x10000 (bits 1-5)
    dc.b 0x05 ; 4: Pattern table for Scroll Plane B at 0xA000 (bits 0-2)
    dc.b 0x70 ; 5: Sprite table at 0xE000 (bits 0-6)
    dc.b 0x00 ; 6: Unused
    dc.b 0x00 ; 7: Background colour - bits 0-3 = colour, bits 4-5 = palette
    dc.b 0x00 ; 8: Unused
    dc.b 0x00 ; 9: Unused
    dc.b 0x00 ; 10: Frequency of Horiz. interrupt in Rasters (number of lines travelled by the beam)
    dc.b 0x08 ; 11: External interrupts on, V/H scrolling on
    dc.b 0x81 ; 12: Shadows and highlights off, interlace off, H40 mode (40 cells horizontally)
    dc.b 0x34 ; 13: Horiz. scroll table at 0xD000 (bits 0-5)
    dc.b 0x00 ; 14: Unused
    dc.b 0x00 ; 15: Autoincrement off
    dc.b 0x01 ; 16: Vert. scroll 32, Horiz. scroll 64
    dc.b 0x00 ; 17: Window Plane X pos 0 left (pos in bits 0-4, left/right in bit 7)
    dc.b 0x00 ; 18: Window Plane Y pos 0 up (pos in bits 0-4, up/down in bit 7)
    dc.b 0x00 ; 19: DMA length lo byte
    dc.b 0x00 ; 20: DMA length hi byte
    dc.b 0x00 ; 21: DMA source address lo byte
    dc.b 0x00 ; 22: DMA source address mid byte
    dc.b 0x00 ; 23: DMA source address hi byte, memory-to-VRAM mode (bits 6-7)

; *** CONTROLLERS INIT ***
ControllersInit:
    ; Set IN I/O direction, interrupts off, on all ports
    move.b #0x00, 0x000A10009 ; Controller port 1 CTRL
    move.b #0x00, 0x000A1000B ; Controller port 2 CTRL
    move.b #0x00, 0x000A1000D ; EXP port CTRL (Genesis 1 backport)

; *** REGISTERS CLEAR ***
RegistersClear:
    move.l #0x00FF0000, a0    ; Moves first ram data address (containing 0) to a0
    movem.l (a0), d1-d7/a0-a7 ; Multiple move value at a0 (0) to all registers
    move #0x2700, sr          ; Init status register (no trace, A7 is Interrupt Stack Pointer, no interrupts, clear condition code bits)


; *** MAIN ***
Main:
    move.w #0x8F02, 0x00C00004      ; Set VDP autoincrement to 2 bytes (1 word) so we can send "streaming" data. We send that word (parameter) to the VDP control port (x00C00004)
    move.l #0xC0000003, 0x00C00004  ; Set up VDP to write palette data to CRAM address 0x0000. The calculation of the 0xC0000003 follows a special bit structure. Writes to control port
    lea Palette, a0                 ; Load address of Palette into a0
    move.l #0x07, d0                ; 32 bytes (8 longwords) of palette data
 
    @PaletteLoop:
    move.l (a0)+, 0x00C00000        ; Move palette data to VDP data port, and increment source address
    dbra d0, @PaletteLoop

    move.w #0x8702, 0x00C00004      ; Set background colour to palette 0, colour 2

    move.l #0x40200000, 0x00C00004  ; Set up VDP to write tile data (characters) to VRAM address 0x0020
    lea Characters, a0              ; Load address of Characters into a0
    move.l #0x37, d0                ; 56 longwords of character data
 
    @CharacterLoop:
    move.l (a0)+, 0x00C00000        ; Move character data to VDP data port, and increment source address
    dbra d0, @CharacterLoop

    move.l #0x40000003, 0x00C00004 ; Set up VDP to write "tile positioning" to VRAM address 0xC000 (Plane A)
 
    ; Low plane, palette 0, no flipping, plus tile ID...
    move.w #0x0001, 0x00C00000     ; Tile ID 1 - H
    move.w #0x0002, 0x00C00000     ; Tile ID 2 - E
    move.w #0x0003, 0x00C00000     ; Tile ID 3 - L
    move.w #0x0003, 0x00C00000     ; Tile ID 3 - L
    move.w #0x0004, 0x00C00000     ; Tile ID 4 - O
    move.w #0x0000, 0x00C00000     ; Tile ID 0 - Blank space
    move.w #0x0005, 0x00C00000     ; Tile ID 5 - W
    move.w #0x0004, 0x00C00000     ; Tile ID 4 - O
    move.w #0x0006, 0x00C00000     ; Tile ID 6 - R
    move.w #0x0003, 0x00C00000     ; Tile ID 3 - L
    move.w #0x0007, 0x00C00000     ; Tile ID 7 - D

; *** MAIN LOOP ***
MainLoop:
    jmp mainLoop                    ; Infinite loop for now


Palette:        ; Main palette to load
    dc.w 0x0000 ; Colour 0 - Transparent
    dc.w 0x000E ; Colour 1 - Red
    dc.w 0x00E0 ; Colour 2 - Green
    dc.w 0x0E00 ; Colour 3 - Blue
    dc.w 0x0000 ; Colour 4 - Black
    dc.w 0x0EEE ; Colour 5 - White
    dc.w 0x00EE ; Colour 6 - Yellow
    dc.w 0x008E ; Colour 7 - Orange
    dc.w 0x0E0E ; Colour 8 - Pink
    dc.w 0x0808 ; Colour 9 - Purple
    dc.w 0x0444 ; Colour A - Dark grey
    dc.w 0x0888 ; Colour B - Light grey
    dc.w 0x0EE0 ; Colour C - Turquoise
    dc.w 0x000A ; Colour D - Maroon
    dc.w 0x0600 ; Colour E - Navy blue
    dc.w 0x0060 ; Colour F - Dark green

Characters:         ; Character data
   dc.l 0x11000110  ; Character 0 - H
   dc.l 0x11000110
   dc.l 0x11000110
   dc.l 0x11111110
   dc.l 0x11000110
   dc.l 0x11000110
   dc.l 0x11000110
   dc.l 0x00000000
 
   dc.l 0x11111110  ; Character 1 - E
   dc.l 0x11000000
   dc.l 0x11000000
   dc.l 0x11111110
   dc.l 0x11000000
   dc.l 0x11000000
   dc.l 0x11111110
   dc.l 0x00000000
 
   dc.l 0x11000000  ; Character 2 - L
   dc.l 0x11000000
   dc.l 0x11000000
   dc.l 0x11000000
   dc.l 0x11000000
   dc.l 0x11111110
   dc.l 0x11111110
   dc.l 0x00000000
 
   dc.l 0x01111100  ; Character 3 - O
   dc.l 0x11101110
   dc.l 0x11000110
   dc.l 0x11000110
   dc.l 0x11000110
   dc.l 0x11101110
   dc.l 0x01111100
   dc.l 0x00000000
 
   dc.l 0x11000110  ; Character 4 - W
   dc.l 0x11000110
   dc.l 0x11000110
   dc.l 0x11000110
   dc.l 0x11010110
   dc.l 0x11101110
   dc.l 0x11000110
   dc.l 0x00000000
 
   dc.l 0x11111100  ; Character 5 - R
   dc.l 0x11000110
   dc.l 0x11001100
   dc.l 0x11111100
   dc.l 0x11001110
   dc.l 0x11000110
   dc.l 0x11000110
   dc.l 0x00000000
 
   dc.l 0x11111000  ; Character 6 - D
   dc.l 0x11001110
   dc.l 0x11000110
   dc.l 0x11000110
   dc.l 0x11000110
   dc.l 0x11001110
   dc.l 0x11111000
   dc.l 0x00000000


HBlankInterrupt:
VBlankInterrupt:
    rte   ; Return from Interrupt
 
Exception:
    rte   ; Return from Exception
 
__end    ; Very last line, end of ROM address