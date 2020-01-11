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
	jmp Main

; *** GLOBALS ***
vdp_control				equ 0x00C00004
vdp_data				equ 0x00C00000

vdp_write_palettes		equ 0xF0000000
vdp_write_tiles			equ 0x40000000
vdp_write_plane_a		equ 0x40000003
vdp_write_sprite_tiles	equ 0x60000000
vdp_write_sprite_table	equ 0x60000003

; *** ASCII LOOKUP TABLE ***
ASCIIStart: equ 0x20 ; First ASCII code in table

ASCIIMap:
	dc.b 0x00	; SPACE (ASCII code 0x20)
	dc.b 0x28   ; ! Exclamation mark
	dc.b 0x2B   ; " Double quotes
	dc.b 0x2E   ; # Hash
	dc.b 0x00	; UNUSED
	dc.b 0x00	; UNUSED
	dc.b 0x00	; UNUSED
	dc.b 0x2C   ; ' Single quote
	dc.b 0x29   ; ( Open parenthesis
	dc.b 0x2A   ; ) Close parenthesis
	dc.b 0x00	; UNUSED
	dc.b 0x2F   ; + Plus
	dc.b 0x26   ; , Comma
	dc.b 0x30   ; - Minus
	dc.b 0x25   ; . Full stop
	dc.b 0x31   ; / Slash or divide
	dc.b 0x1B   ; 0 Zero
	dc.b 0x1C   ; 1 One
	dc.b 0x1D   ; 2 Two
	dc.b 0x1E   ; 3 Three
	dc.b 0x1F   ; 4 Four
	dc.b 0x20   ; 5 Five
	dc.b 0x21   ; 6 Six
	dc.b 0x22   ; 7 Seven
	dc.b 0x23   ; 8 Eight
	dc.b 0x24   ; 9 Nine
	dc.b 0x2D   ; : Colon
	dc.b 0x00	; UNUSED
	dc.b 0x00	; UNUSED
	dc.b 0x00	; UNUSED
	dc.b 0x00	; UNUSED
	dc.b 0x27   ; ? Question mark
	dc.b 0x00	; UNUSED
	dc.b 0x01	; A
	dc.b 0x02   ; B
	dc.b 0x03	; C
	dc.b 0x04   ; D
	dc.b 0x05	; E
	dc.b 0x06	; F
	dc.b 0x07	; G
	dc.b 0x08	; H
	dc.b 0x09	; I
	dc.b 0x0A	; J
	dc.b 0x0B	; K
	dc.b 0x0C	; L
	dc.b 0x0D	; M
	dc.b 0x0E	; N
	dc.b 0x0F	; O
	dc.b 0x10	; P
	dc.b 0x11	; Q
	dc.b 0x12	; R
	dc.b 0x13	; S
	dc.b 0x14	; T
	dc.b 0x15	; U
	dc.b 0x16	; V
	dc.b 0x17	; W
	dc.b 0x18	; X
	dc.b 0x19	; Y
	dc.b 0x1A	; Z (ASCII code 0x5A)

; *** !!! DON'T KNOW WHY !!! ***
	nop 0,8		; Align 8 bytes

; *** LOAD FONT SUBROUTINE ***
LoadFont:
   ; a0 (l) - Font address
   ; d0 (w) - VRAM address
   ; d1 (w) - Num chars

   swap     d0                   ; Shift VRAM addr to upper word
   add.l    #vdp_write_tiles, d0 ; VRAM write cmd + VRAM destination address
   move.l   d0, vdp_control      ; Send address to VDP cmd port

   subq.b   #0x1, d1             ; Num chars - 1
   @CharCopy:
   move.w   #0x07, d2            ; 8 longwords in tile
   @LongCopy:
   move.l   (a0)+, vdp_data      ; Copy one line of tile to VDP data port
   dbra     d2, @LongCopy
   dbra     d1, @CharCopy

   rts

; *** DRAW TEXT IN PLANE A SUBROUTINE ***
DrawTextPlaneA:
	; a0 (l) - String address
	; d0 (w) - First tile ID of font
	; d1 (bb)- XY coord (in tiles)
	; d2 (b) - Palette

	clr.l    d3                     ; Clear d3 ready to work with
	move.b   d1, d3                 ; Move Y coord (lower byte of d1) to d3
	mulu.w   #0x0040, d3            ; Multiply Y by line width (H40 mode - 64 lines horizontally) to get Y offset
	ror.l    #0x8, d1               ; Shift X coord from upper to lower byte of d1
	add.b    d1, d3                 ; Add X coord to offset
	mulu.w   #0x2, d3               ; Convert to words
	swap     d3                     ; Shift address offset to upper word
	add.l    #vdp_write_plane_a, d3 ; Add PlaneA write cmd + address
	move.l   d3, vdp_control        ; Send to VDP control port

	clr.l    d3                     ; Clear d3 ready to work with again
	move.b   d2, d3                 ; Move palette ID (lower byte of d2) to d3
	rol.l    #0x8, d3               ; Shift palette ID to bits 14 and 15 of d3
	rol.l    #0x5, d3               ; Can only rol bits up to 8 places in one instruction

	lea      ASCIIMap, a1           ; Load address of ASCII map into a1

	@CharCopy:
	move.b   (a0)+, d2              ; Move ASCII byte to lower byte of d2
	cmp.b    #0x0, d2               ; Test if byte is zero (string terminator)
	beq.b    @End                   ; If byte was zero, branch to end

	sub.b    #ASCIIStart, d2        ; Subtract first ASCII code to get table entry index
	move.b   (a1,d2.w), d3          ; Move tile ID from table (index in lower word of d2) to lower byte of d3
	add.w    d0, d3                 ; Offset tile ID by first tile ID in font
	move.w   d3, vdp_data           ; Move palette and pattern IDs to VDP data port
	jmp      @CharCopy              ; Next character

	@End:
	rts

; *** MAIN PROGRAM ***
Main:
	move.w #0x8F02, vdp_control     ; Set autoincrement to 2 bytes

; *** MOVE PALETTES TO CRAM ***
	move.l #vdp_write_palettes, vdp_control ; Set up VDP to write to CRAM address 0x0000

	lea Palettes, a0  ; Load address of Palettes into a0
	move.l #0x1F, d0  ; 128 bytes of data (4 palettes, 32 longwords, minus 1 for counter) in palettes

	@ColourLoop:
	move.l (a0)+, vdp_data ; Move data to VDP data port, and increment source address
	dbra d0, @ColourLoop

; *** LOAD FONT ***
    lea        PixelFont, a0       ; Move font address to a0
    move.l    #PixelFontVRAM, d0   ; Move VRAM dest address to d0
    move.l    #PixelFontSizeT, d1  ; Move number of characters (font size in tiles) to d1
    jsr        LoadFont            ; Jump to subroutine

; *** DRAW TEXT ***
	lea		String1, a0		     ; String address
	move.l	#PixelFontTileID, d0 ; First tile id
	move.w	#0x0501, d1			 ; XY (5, 1)
	move.l	#0x0, d2			 ; Palette 0
	jsr		DrawTextPlaneA       ; Call draw text subroutine

	lea		String2, a0		     ; String address
	move.l	#PixelFontTileID, d0 ; First tile id
	move.w	#0x0502, d1			 ; XY (5, 2)
	move.l	#0x1, d2			 ; Palette 1
	jsr		DrawTextPlaneA       ; Call draw text subroutine

	lea		String3, a0		     ; String address
	move.l	#PixelFontTileID, d0 ; First tile id
	move.w	#0x0503, d1			 ; XY (5, 3)
	move.l	#0x2, d2			 ; Palette 2
	jsr		DrawTextPlaneA       ; Call draw text subroutine

	lea		String4, a0		     ; String address
	move.l	#PixelFontTileID, d0 ; First tile id
	move.w	#0x0504, d1			 ; XY (5, 4)
	move.l	#0x3, d2			 ; Palette 3
	jsr		DrawTextPlaneA       ; Call draw text subroutine

	lea		String5, a0		     ; String address
	move.l	#PixelFontTileID, d0 ; First tile id
	move.w	#0x0106, d1			 ; XY (1, 6)
	move.l	#0x3, d2			 ; Palette 3
	jsr		DrawTextPlaneA       ; Call draw text subroutine

	stop #$2700 ; Halt CPU

Palettes:
	dc.w 0x0000 ; Colour 0 - Transparent
	dc.w 0x000E ; Colour 1 - Red
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000

	dc.w 0x0000 ; Colour 0 - Transparent
	dc.w 0x00E0 ; Colour 1 - Green
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000

	dc.w 0x0000 ; Colour 0 - Transparent
	dc.w 0x0E00 ; Colour 1 - Blue
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000

	dc.w 0x0000 ; Colour 0 - Transparent
	dc.w 0x0EEE ; Colour 1 - White
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000
	dc.w 0x0000

; *** TEXT STRINGS *** (zero terminated, because we need an end indicator character)
String1:
	dc.b "ABCDEFGHIJKLM",0
String2:
	dc.b "NOPQRSTUVWXYZ",0
String3:
	dc.b "0123456789",0
String4:
	dc.b ",.?!()""':#+-/",0
String5:
	dc.b "HELLO WORLD BUT BETTER",0

; *** INCLUDE ART ASSETS ***
	include 'fonts\pixelfont.asm'

HBlankInterrupt:
VBlankInterrupt:
    rte   ; Return from Interrupt
 
Exception:
    rte   ; Return from Exception
 
__end    ; Very last line, end of ROM address