Sprite1:

	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000012
	dc.l	0x00000234
	dc.l	0x000014AC
	dc.l	0x00002942

	dc.l	0x00002812
	dc.l	0x00002802
	dc.l	0x00000202
	dc.l	0x00000002
	dc.l	0x00000002
	dc.l	0x00000001
	dc.l	0x00000001
	dc.l	0x00000000

	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000022
	dc.l	0x000003AE
	dc.l	0x00003AE8
	dc.l	0x00004E83
	dc.l	0x00004A82

	dc.l	0x00003A88
	dc.l	0x000004AA
	dc.l	0x00000032
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000

	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x01112444
	dc.l	0x2249A9A9
	dc.l	0x49AA8ADA
	dc.l	0xC9C89DED
	dc.l	0x8CC89CDC

	dc.l	0x49C89AC9
	dc.l	0x44DA89C9
	dc.l	0x48ADA8D8
	dc.l	0x488ADAD9
	dc.l	0x3888AEEE
	dc.l	0x38842333
	dc.l	0x38927222
	dc.l	0x2493FF60

	dc.l	0x13A4FFB0
	dc.l	0x028A4FFB
	dc.l	0x1248A444
	dc.l	0x349A9844
	dc.l	0xEEA98888
	dc.l	0x98843222
	dc.l	0x10110000
	dc.l	0x03830000

	dc.l	0x88310000
	dc.l	0xA2100000
	dc.l	0x20000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000

	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x42200000
	dc.l	0x59842222
	dc.l	0x95984234
	dc.l	0x958944AA
	dc.l	0x959C8AA4

	dc.l	0x95ACAA84
	dc.l	0x89ACA843
	dc.l	0x9ADA8884
	dc.l	0xAD848888
	dc.l	0xD8434984
	dc.l	0x33224A84
	dc.l	0x22724A83
	dc.l	0xF6734A43

	dc.l	0x06439A42
	dc.l	0xB844AA31
	dc.l	0x4448A831
	dc.l	0x4489A432
	dc.l	0x9AAE8443
	dc.l	0x234AEE84
	dc.l	0x002348AA
	dc.l	0x00002248

	dc.l	0x00000033
	dc.l	0x00000000
	dc.l	0x00000224
	dc.l	0x000028AA
	dc.l	0x00001111
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000

	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x22000000
	dc.l	0x43200000
	dc.l	0xA8420000
	dc.l	0x33842000

	dc.l	0x11282000
	dc.l	0x31282000
	dc.l	0x31020000
	dc.l	0x31000000
	dc.l	0x31000000
	dc.l	0x31000000
	dc.l	0x21000000
	dc.l	0x10000000

	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x10000000
	dc.l	0x11000000
	dc.l	0x31000000
	dc.l	0x83100000
	dc.l	0xAA410000

	dc.l	0x4A830000
	dc.l	0x3A840000
	dc.l	0xA8410000
	dc.l	0x41100000
	dc.l	0x10000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000

Sprite1End								 ; Sprite end address
Sprite1SizeB: equ (Sprite1End-Sprite1)	 ; Sprite size in bytes
Sprite1SizeW: equ (Sprite1SizeB/2)		 ; Sprite size in words
Sprite1SizeL: equ (Sprite1SizeB/4)		 ; Sprite size in longs
Sprite1SizeT: equ (Sprite1SizeB/32)		 ; Sprite size in tiles
Sprite1TileID: equ (Sprite1VRAM/32)		 ; ID of first tile
Sprite1Dimentions: equ (%00001111)       ; Sprite dimentions (4x4)