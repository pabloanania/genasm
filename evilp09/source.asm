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
    dc.b 0x14 ; 0: Horiz. interrupt on, display on
    dc.b 0x74 ; 1: Vert. interrupt on, screen blank off, DMA on, V28 mode (40 cells vertically), Genesis mode on
    dc.b 0x30 ; 2: Pattern table for Scroll Plane A at 0xC000 (bits 3-5)
    dc.b 0x40 ; 3: Pattern table for Window Plane at 0x10000 (bits 1-5)
    dc.b 0x05 ; 4: Pattern table for Scroll Plane B at 0xA000 (bits 0-2)
    dc.b 0x70 ; 5: Sprite table at 0xE000 (bits 0-6)
    dc.b 0x00 ; 6: Unused
    dc.b 0x00 ; 7: Background colour - bits 0-3 = colour, bits 4-5 = palette
    dc.b 0x00 ; 8: Unused
    dc.b 0x00 ; 9: Unused
    dc.b 0x00 ; 10: Frequency of Horiz. interrupt in Rasters (number of lines travelled by the beam)
    dc.b 0x00 ; 11: External interrupts off, V scroll fullscreen, H scroll fullscreen
    dc.b 0x81 ; 12: Shadows and highlights off, interlace off, H40 mode (64 cells horizontally)
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
    move.l #0x00000000, a0    ; Clear a0
    move #0x2000, sr          ; Init status register (no trace, supervisor mode, all interrupt levels enabled, clear condition code bits). Without this interrupts callbacks aren't called!
	
	jmp Main				  ; Jump to main routine

; *** GLOBALS ***
vdp_control				equ 0x00C00004 ; VDP control port global 
vdp_data				equ 0x00C00000 ; VDP data port global
vdp_write_palettes		equ 0xF0000000 ; VDP set ready to write palette. Special bit calculation. More info in sega2f doc section "6 ACCESS VDP RAM" or in tutorial 4
vdp_write_tiles			equ 0x40000000 ; VDP set ready to write tiles
vdp_write_plane_a		equ 0x40000003 ; VDP set ready to write to plane A
vdp_write_sprite_table	equ 0x60000003 ; VDP set ready to write to sprite descriptor table
vdp_write_hscroll       equ 0x50000003 ; VDP set ready to write horizontal scroll data
vdp_write_vscroll       equ 0x40000010 ; VDP set ready to write vertical scroll data

pad_data_a				equ 0x00A10003 ; Port A data port global (Joystick 1)
pad_data_b				equ 0x00A10005 ; Port B data port global (Joystick 2)
pad_data_c				equ 0x00A10007 ; Port C data port global (EXT backport Genesis Model 1)
pad_ctrl_a				equ 0x00A10009 ; Port A control port global
pad_ctrl_b				equ 0x00A1000B ; Port B control port global
pad_ctrl_c				equ 0x00A1000D ; Port C control port global
pad_button_up           equ 0x0        ; Global for bit check each button of the gamepad
pad_button_down         equ 0x1
pad_button_left         equ 0x2
pad_button_right        equ 0x3
pad_button_a            equ 0xC
pad_button_b            equ 0x4
pad_button_c            equ 0x5
pad_button_start        equ 0xD

SizeByte                equ 0x01        ; Globals for different data sizes in order to make calculations with these references
SizeWord                equ 0x02
SizeLong                equ 0x04
SizeSpriteDesc          equ 0x08
SizeTile                equ 0x20
SizePalette             equ 0x40

; *** MEMORY MAP (GLOBALS) ***
hblank_counter		equ 0x00FF0000                ; HBlank counter at Start of RAM
vblank_counter		equ (hblank_counter+SizeLong) ; VBlank counter comes next
segalogo_anim_frame	equ (vblank_counter+SizeByte) ; Current sega logo animation frame comes next

; *** VRAM MAP (GLOBALS) ***
PixelFontVRAM   equ 0x0100                        ; Start address for PixelFont in VRAM
Sprite1VRAM     equ PixelFontVRAM+PixelFontSizeB  ; Sprite 1 VRAM Address 
Sprite2VRAM     equ Sprite1VRAM+Sprite1SizeB      ; Sprite 2 VRAM Address 
SegaLogoVRAM    equ Sprite2VRAM+Sprite2SizeB      ; Sprite 3 (SEGA logo) VRAM Address. Only one frame at a time loaded at this address
Level1TilesVRAM equ SegaLogoVRAM+SegaLogoOneFrameB ; Level 1 VRAM Address
RunningManVRAM  equ Level1TilesVRAM+Level1TilesSizeB ; Unused


; *** READ JOYPAD 1 ROUTINE ***
ReadPad1:
	; d0 (w) - Return result
    ; Bits format: 00SA0000 00CBRLDU. Only one byte by each read (two reads have to be made)
	move.b  pad_data_a, d0     ; Read upper byte from data port
	rol.w   #0x8, d0           ; Move to upper byte of d0
	move.b  #0x40, pad_data_a  ; Write bit 7 to data port
	move.b  pad_data_a, d0     ; Read lower byte from data port
	move.b  #0x00, pad_data_a  ; Put data port back to normal

	rts

; *** TIMING ROUTINES ***
WaitVBlankStart:
	move.w  vdp_control, d0	; Move VDP status word to d0
	andi.w  #0x0008, d0     ; AND with bit 4 (vblank), result in status register
	bne     WaitVBlankStart ; Branch if not equal (to zero)
	rts

WaitVBlankEnd:
	move.w  vdp_control, d0	; Move VDP status word to d0
	andi.w  #0x0008, d0     ; AND with bit 4 (vblank), result in status register
	beq     WaitVBlankEnd   ; Branch if equal (to zero)
	rts

WaitFrames:
	; d0 - Number of frames to wait

	move.l  vblank_counter, d1 ; Get start vblank count

	@Wait:
	move.l  vblank_counter, d2 ; Get end vblank count
	subx.l  d1, d2             ; Calc delta, result in d2
	cmp.l   d0, d2             ; Compare with num frames
	bge     @End               ; Branch to end if greater or equal to num frames
	jmp     @Wait              ; Try again
	
	@End:
	rts

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

    ; Prepares VDP to write only Y position to this sprite ID
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

; *** ANIMATE SPRITE ONE FRAME (428) ***
AnimateSpriteFwd:
	; Advance sprite to next frame
	; d0 (w) Sprite address (VRAM)
	; d1 (w) Size of one sprite frame (in bytes)
	; d2 (w) Number of anim frames
	; a0 --- Address of sprite data (ROM)
	; a1 --- Address of animation data (ROM)
	; a2 --- Address of animation frame number (RAM, writeable)

	clr.l  d3              ; Clear d3
	move.b (a2), d3        ; Read current anim frame number (d3)
	addi.b #0x1, (a2)      ; Advance frame number (write in RAM)
	cmp.b  d3, d2          ; Check current frame number (register d3) with anim frames qty
	bne    @NotAtEnd       ; Branch if we haven't reached the end of anim
	move.b #0x0, (a2)      ; At end of anim, wrap frame number back to zero
	@NotAtEnd:

	move.b (a1,d3.w), d4   ; Get current frame index from anim data array (array position in ROM + current frame offset) and store it in d4
	move.b (a2), d2        ; Read next anim frame number and store in d2
	move.b (a1,d3.w), d5   ; Get next frame index from anim data array and store in d5

	cmp.b  d3, d4          ; Has anim frame index changed?
	beq    @NoChange       ; If not, there's nothing more to do

	; Formula: spriteDataAddr = spriteDataAddr + (sizeOfFrame * newTileID)
	move.l a0, d2          ; Move sprite data ROM address to d2 (can't do maths on address registers)
	move.w d1, d4          ; Move size of one sprite frame to d4 (can't trash d1, it's needed later)
	mulu.w d5, d4          ; Multiply with new frame index to get new ROM offset (result in d4)
	add.w  d4, d2          ; Add to sprite data address
	move.l d2, a0          ; Back to address register

	jsr LoadTiles          ; New tile address is in a0, VRAM address already in d0, num tiles already in d1 - jump straight to load tiles

	@NoChange:
	rts

LoadMapPlaneA:
    ; a0 (l) - Map address (ROM)
	; d0 (b) - Size in words
	; d1 (b) - Y offset
	; d2 (w) - First tile ID
	; d3 (b) - Palette ID

	mulu.w  #0x0040, d1            ; Multiply Y offset by line width (in words)
	swap    d1                     ; Shift to upper word
	add.l   #vdp_write_plane_a, d1 ; Add PlaneA write cmd + address (set ready to write plane A data + Y offset)
	move.l  d1, vdp_control        ; Move dest address to VDP control port

	rol.l   #0x08, d3              ; Shift palette ID to bits 14-15 (8 bits max rol)
	rol.l   #0x05, d3

	subq.b  #0x01, d0              ; Num words in d0, minus 1 for counter
	
	@Copy:
	move.w  (a0)+, d4              ; Move tile ID from map data to lower d4
	and.l   #%0011111111111111, d4 ; Mask out original palette ID
	or.l    d3, d4                 ; Replace with our own
	add.w   d2, d4                 ; Add first tile ID (offset) to d4
	move.w  d4, vdp_data           ; Move to VRAM
	dbra    d0, @Copy              ; Loop

    rts

LoadPalette;
    ; d0 (b) Palette index
	; a0 --- Palette ROM address

	mulu.w #SizePalette, d0        ; Palette index in CRAM destination address
	swap   d0                      ; Move index to upper word
	add.l  #vdp_write_palettes, d0 ; Add CRAM write command
	move.l d0, vdp_control         ; Set VDP ready to write color data

	move.l #(SizePalette/SizeLong), d0 ; Size of palette
	@PaletteCopy:
	move.l (a0)+, vdp_data         ; Move longword to CRAM
	dbra   d0, @PaletteCopy

	rts


; *** MAIN ROUTINE ***
Main:
	move.w #0x8F02, vdp_control     ; Set autoincrement to 2 bytes
    move.w #0x8708, vdp_control     ; Set background colour light blue (palette 0, colour 8)

    ; Move palettes to CRAM
	lea Level1Palette, a0
	move.l #0x0, d0
	jsr LoadPalette

    ; Load map tiles
    lea      Level1Tiles, a0       ; Move sprite address to a0
    move.l   #Level1TilesVRAM, d0  ; Move VRAM dest address to d0
    move.l   #Level1TilesSizeT, d1 ; Move number of tiles to d1
	jsr      LoadTiles             ; Jump to subroutine

    ; Load map
    lea      Level1Map, a0           ; Map data in a0
	move.w   #Level1MapSizeW, d0     ; Size (words) in d0
	move.l   #0x18, d1               ; Y offset in d1
	move.w   #Level1TilesTileID, d2  ; First tile ID in d2
	move.l   #0x0, d3                ; Palette ID in d3
	jsr      LoadMapPlaneA           ; Jump to subroutine

	move.l #0x0, d6                  ; HScroll value in d6


; *** MAIN GAME LOOP ***
GameLoop:
    ; Read gamepad input
    jsr ReadPad1 ; Read pad 1 state, result in d0

    btst   #pad_button_right, d0 ; Check right button
    bne    @NoRight              ; Branch if button off
    subi   #0x1, d6              ; Update H scroll value
    @NoRight:

    btst   #pad_button_left, d0  ; Check left button
    bne    @NoLeft               ; Branch if button off
    addi   #0x1, d6              ; Update H scroll value
    @NoLeft:

    ; Update sprites during VBlank
	jsr WaitVBlankStart   ; Wait for start of vblank

	move.l  #vdp_write_hscroll, vdp_control ; VDP set ready to write hscroll data
	move.w  d6, vdp_data                    ; Write hscroll value

	jsr     WaitVBlankEnd ; Wait for end of vblank

	jmp     GameLoop      ; Back to the top


; *** CALLBACKS ***
HBlankInterrupt:
   addi.l #0x1, hblank_counter    ; Increment hinterrupt counter
   rte

VBlankInterrupt:
   addi.l #0x1, vblank_counter    ; Increment vinterrupt counter
   rte

Exception:
   stop #$2700 ; Halt CPU


; *** SPRITE DESCRIPTORS ***
SpriteDescs:
    dc.w 0x0000            ; Y coord (+ 128)
    dc.b Sprite1Dimentions ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x01              ; Index of next sprite (linked list)
    dc.b 0x00              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b Sprite1TileID     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)
	
    dc.w 0x0000            ; Y coord (+ 128)
    dc.b Sprite1Dimentions ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x02              ; Index of next sprite (linked list)
    dc.b 0x20              ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b Sprite2TileID     ; Index of first tile
    dc.w 0x0000            ; X coord (+ 128)

	dc.w 0x0000             ; Y coord (+ 128)
    dc.b SegaLogoDimentions ; Width (bits 0-1) and height (bits 2-3) in tiles
    dc.b 0x00               ; Index of next sprite (linked list)
    dc.b 0x40               ; H/V flipping (bits 3/4), palette index (bits 5-6), priority (bit 7)
    dc.b SegaLogoTileID     ; Index of first tile
    dc.w 0x0000             ; X coord (+ 128)


    ; *** INCLUDE ART ASSETS AND PALETTES ***
    include 'fonts\pixelfont.asm'
    include 'sprites\sprite1.asm'
    include 'sprites\sprite2.asm'
	include 'sprites\testanim.asm'
	include 'tiles\level1_tiles.asm'
	include 'maps\level1_map.asm'
	include 'sprites\runningman.asm'
    include 'palettes\paletteset1.asm'
	include 'palettes\level1_palette.asm'
	include 'palettes\runningman_palette.asm'

 
End       ; Very last line, end of ROM address