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
    dc.l End                                                ; End address of ROM
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
	
	jmp Main				  ; Jump to main routine

; *** GLOBALS ***
vdp_control				equ 0x00C00004 ; VDP control port global 
vdp_data				equ 0x00C00000 ; VDP data port global

vdp_write_palettes		equ 0xF0000000 ; VDP set ready to write palette. Special bit calculation. More info in sega2f doc section "6 ACCESS VDP RAM" or in tutorial 4
vdp_write_tiles			equ 0x40000000 ; VDP set ready to write tiles
vdp_write_plane_a		equ 0x40000003 ; VDP set ready to write to plane A
vdp_write_sprite_table	equ 0x60000003 ; VDP set ready to write to sprite descriptor table

; *** LOAD TILES TO VDP ROUTINE ***
LoadTiles:
	; a0 - Font address (l)
	; d0 - VRAM address (w)
	; d1 - Num chars (b)
	
	swap	d0						; VRAM addr in upper word
	add.l	#vdp_write_tiles, d0	; VRAM write cmd + VRAM destination address
	move.l	d0, vdp_control			; Send address to VDP cmd port
	
	subq.b	#0x1, d1				; Num chars - 1
	@CharCopy:
	move.w	#0x07, d2				; 8 longwords in tile
	@LongCopy:
	move.l	(a0)+, vdp_data			; Copy one line of tile to VDP data port
	dbra	d2, @LongCopy
	dbra	d1, @CharCopy
	
	rts
	
; *** LOAD SPRITE ATTRIBUTES TO TABLE ***
; Sprite attribs format (in bits)
; 000000YY YYYYYYYY 0000HHVV 0NNNNNNN DPPFFTTT TTTTTTTT 000000XX XXXXXXXX
; Y = Y coord (from -128 to screen height + 128). H/V = Sprite grid dimensions, in tiles. N = Index of next sprite attribute (a linked list next ptr). D = Draw priority. P = Palette index. F = Flip bits (vert. and horiz.). T = Index of first tile in sprite. X = X coord (from -128 to screen width + 128).
LoadSpriteTables:
	; a0 - Sprite data address
	; d0 - Number of sprites
	move.l	#vdp_write_sprite_table, vdp_control    ; Set VDP ready to write sprites attributes
	
	subq.b	#0x1, d0				                ; 2 sprites attributes
	@AttrCopy:
	move.l	(a0)+, vdp_data                         ; Two longs (64 bits) of attributes for each sprite
	move.l	(a0)+, vdp_data
	dbra	d0, @AttrCopy
	
	rts

; *** SET SPRITE Y POSITION ***
SetSpritePosY:
	; Set sprite Y position
	; d0 (b) - Sprite ID
	; d1 (w) - Y coord

    ; Prepares VDP to write only Y position to this sprite ID by setting a special value to vdp_control and then sending the coordinate to vdp_data. It is not explained in the tutorial how this works
	clr.l	d3						; Clear d3
	move.b	d0, d3					; Move sprite ID to d3
	
	mulu.w	#0x8, d3				; Sprite array offset
	swap	d3						; Move to upper word
	add.l	#vdp_write_sprite_table, d3	; Add to sprite attr table (at 0xD400)
	
	move.l	d3, vdp_control			; Set dest address
	move.w	d1, vdp_data			; Move Y pos to data port
	
	rts

; *** SET SPRITE X POSITION ***
SetSpritePosX:
	; Set sprite X position
	; d0 (b) - Sprite ID
	; d1 (w) - X coord
    ; Prepares VDP to write only X position to this sprite ID
	clr.l	d3						; Clear d3
	move.b	d0, d3					; Move sprite ID to d3
	
	mulu.w	#0x8, d3				; Sprite array offset
	add.b	#0x6, d3				; X coord offset
	swap	d3						; Move to upper word
	add.l	#vdp_write_sprite_table, d3	; Add to sprite attr table (at 0xD400)
	
	move.l	d3, vdp_control			; Set VDP ready to write sprite data position X
	move.w	d1, vdp_data			; Move X pos to data port
	
	rts


; *** MAIN ROUTINE ***
Main:
	move.w #0x8F02, vdp_control     ; Set autoincrement to 2 bytes

    ; Move palettes to CRAM
	move.l #vdp_write_palettes, vdp_control ; Set up VDP to write to CRAM address 0x0000

	lea Palettes, a0  ; Load address of Palettes into a0
	move.l #0x0F, d0  ; 64 bytes of data (2 palettes, 16 longwords, minus 1 for counter) in palettes

	@ColourLoop:
	move.l (a0)+, vdp_data ; Move data to VDP data port, and increment source address
	dbra d0, @ColourLoop

	; Load tiles for sprites
    lea      Sprite1, a0         ; Move sprite address to a0
    move.l   #Sprite1VRAM, d0    ; Move VRAM dest address to d0
    move.l   #Sprite1SizeT, d1   ; Move number of tiles to d1
	jsr      LoadTiles           ; Jump to subroutine
	
	lea      Sprite2, a0         ; Move sprite address to a0
    move.l   #Sprite2VRAM, d0    ; Move VRAM dest address to d0
    move.l   #Sprite2SizeT, d1   ; Move number of tiles to d1
	jsr      LoadTiles           ; Jump to subroutine
	
	; Load sprite descriptors
	lea     SpriteDescs, a0		; Sprite table data
	move.w  #0x2, d0			; 2 sprites
	jsr     LoadSpriteTables

	; Set sprite positions (42E)
	move.w  #0x0,  d0	  ; Sprite ID
	move.w  #0xB0, d1	  ; X coord
	jsr     SetSpritePosX ; Set X pos
	move.w  #0xB0, d1	  ; Y coord
	jsr     SetSpritePosY ; Set Y pos

	move.w  #0x1,  d0	  ; Sprite ID
	move.w  #0xA0, d1	  ; X coord
	jsr     SetSpritePosX ; Set X pos
	move.w  #0x90, d1	  ; Y coord
	jsr     SetSpritePosY ; Set Y pos

	stop #$2700 ; Halt CPU

; *** SPRITE DESCRIPTORS ***
SpriteDescs:
    dc.w 0x0000        ; Y coord (+ 128)
    dc.b %00001111     ; Width (bits 0-1) and height (bits 2-3) in tiles (4*4 tiles)
    dc.b 0x01          ; Index of next sprite (linked list)
    dc.b 0x00          ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b Sprite1TileID ; Index of first tile
    dc.w 0x0000        ; X coord (+ 128)
	
    dc.w 0x0000        ; Y coord (+ 128)
    dc.b %00001111     ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x00          ; Index of next sprite (linked list)
    dc.b 0x20          ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b Sprite2TileID ; Index of first tile
    dc.w 0x0000        ; X coord (+ 128)


; *** INCLUDE ART ASSETS AND PALETTES ***
    include 'fonts\pixelfont.asm'
    include 'sprites\sprite1.asm'
    include 'sprites\sprite2.asm'
    include 'palettes\paletteset1.asm'

HBlankInterrupt:
VBlankInterrupt:
    rte   ; Return from Interrupt
 
Exception:
    rte   ; Return from Exception
 
End       ; Very last line, end of ROM address