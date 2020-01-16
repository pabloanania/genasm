Sprite2:

	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000008
	dc.l	0x00000008
	dc.l	0x00000008
	dc.l	0x00000009

	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000003
	dc.l	0x0000000A
	dc.l	0x0000000B
	dc.l	0x0000000B

	dc.l	0x0000003B
	dc.l	0x0000006B
	dc.l	0x000000AB
	dc.l	0x000006AB
	dc.l	0x000036BA
	dc.l	0x000036B9
	dc.l	0x000003BA
	dc.l	0x000000AB

	dc.l	0x0000000A
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000

	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x88800000
	dc.l	0x9A980000
	dc.l	0xC4C80000
	dc.l	0xA8A00999

	dc.l	0xA98A9888
	dc.l	0x9A89A888
	dc.l	0x3B889998
	dc.l	0xBA89AB88
	dc.l	0xB98AB878
	dc.l	0xB9869667
	dc.l	0xA8648666
	dc.l	0x98634643

	dc.l	0x98642332
	dc.l	0x99643223
	dc.l	0x9A964336
	dc.l	0xAB876468
	dc.l	0xBB998785
	dc.l	0x99BBB955
	dc.l	0x88777555
	dc.l	0xA8888775

	dc.l	0xBBBA9888
	dc.l	0x00ABBBAA
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000

	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000888
	dc.l	0x000089A9
	dc.l	0x00008C4C
	dc.l	0x99981988

	dc.l	0x88899988
	dc.l	0x88888989
	dc.l	0x88788890
	dc.l	0x88878898
	dc.l	0x88688899
	dc.l	0x8744789A
	dc.l	0x7434789A
	dc.l	0x6434488A

	dc.l	0x6333489A
	dc.l	0x22637899
	dc.l	0x44748999
	dc.l	0x74848898
	dc.l	0x88588889
	dc.l	0x65788899
	dc.l	0x55578889
	dc.l	0x578889AA

	dc.l	0x8899AA90
	dc.l	0xAAAA6600
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000

	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x80000000
	dc.l	0x80000000
	dc.l	0x80000000
	dc.l	0x00000000

	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x80000000
	dc.l	0x80000000

	dc.l	0x80000000
	dc.l	0x83000000
	dc.l	0x98000000
	dc.l	0x99600000
	dc.l	0x99630000
	dc.l	0x99630000
	dc.l	0xA9600000
	dc.l	0x90000000

	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000
	dc.l	0x00000000

Sprite2End								 ; Sprite end address
Sprite2SizeB: equ (Sprite2End-Sprite2)	 ; Sprite size in bytes
Sprite2SizeW: equ (Sprite2SizeB/2)		 ; Sprite size in words
Sprite2SizeL: equ (Sprite2SizeB/4)		 ; Sprite size in longs
Sprite2SizeT: equ (Sprite2SizeB/32)		 ; Sprite size in tiles
Sprite2TileID: equ (Sprite2VRAM/32)		 ; ID of first tile
Sprite2Dimentions: equ (%00001111)       ; Sprite dimentions (4x4)