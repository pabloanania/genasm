Level1Tiles:

	dc.l	$88888888
	dc.l	$88888888
	dc.l	$88888888
	dc.l	$88888888
	dc.l	$88888888
	dc.l	$88888888
	dc.l	$88888888
	dc.l	$88888888

	dc.l	$88888666
	dc.l	$88886666
	dc.l	$88856665
	dc.l	$88555555
	dc.l	$85555555
	dc.l	$55555555
	dc.l	$55555444
	dc.l	$55544444

	dc.l	$66666666
	dc.l	$66666666
	dc.l	$55555555
	dc.l	$55555555
	dc.l	$55555555
	dc.l	$55555555
	dc.l	$44444444
	dc.l	$44444444

	dc.l	$66666866
	dc.l	$66666666
	dc.l	$55555555
	dc.l	$55555555
	dc.l	$55555555
	dc.l	$54445545
	dc.l	$44444444
	dc.l	$44444444

	dc.l	$66888888
	dc.l	$66666888
	dc.l	$55556688
	dc.l	$55555558
	dc.l	$55555558
	dc.l	$54445555
	dc.l	$44444455
	dc.l	$44444455

	dc.l	$88877788
	dc.l	$88711178
	dc.l	$87112117
	dc.l	$87122217
	dc.l	$87112117
	dc.l	$88711178
	dc.l	$88877788
	dc.l	$88885888

	dc.l	$55344444
	dc.l	$54443444
	dc.l	$34343334
	dc.l	$33334443
	dc.l	$83333333
	dc.l	$83333333
	dc.l	$03333333
	dc.l	$00333333

	dc.l	$44444444
	dc.l	$44444444
	dc.l	$44444444
	dc.l	$33333333
	dc.l	$33333333
	dc.l	$33333333
	dc.l	$33333333
	dc.l	$33333333

	dc.l	$44444444
	dc.l	$44433333
	dc.l	$43434433
	dc.l	$34333334
	dc.l	$33333333
	dc.l	$33333333
	dc.l	$33333333
	dc.l	$33333333

	dc.l	$44444455
	dc.l	$43333445
	dc.l	$33343333
	dc.l	$33434444
	dc.l	$33333334
	dc.l	$33333333
	dc.l	$33333330
	dc.l	$33333300

	dc.l	$88885888
	dc.l	$88885858
	dc.l	$88885588
	dc.l	$88885888
	dc.l	$88855888
	dc.l	$85858888
	dc.l	$88558888
	dc.l	$88858888

	dc.l	$00333333
	dc.l	$00333333
	dc.l	$00333333
	dc.l	$00333333
	dc.l	$00333333
	dc.l	$00333333
	dc.l	$00333333
	dc.l	$00333333

	dc.l	$33333333
	dc.l	$33333333
	dc.l	$33333333
	dc.l	$33333333
	dc.l	$33333333
	dc.l	$33333333
	dc.l	$33333333
	dc.l	$33333333

	dc.l	$33333333
	dc.l	$34433334
	dc.l	$33333343
	dc.l	$33334433
	dc.l	$34333333
	dc.l	$33333343
	dc.l	$34344433
	dc.l	$33333333

	dc.l	$33333300
	dc.l	$33333300
	dc.l	$33333300
	dc.l	$33333300
	dc.l	$33333300
	dc.l	$33333300
	dc.l	$33333300
	dc.l	$33333300

	dc.l	$88858888
	dc.l	$88858588
	dc.l	$88855888
	dc.l	$88858888
	dc.l	$85858888
	dc.l	$88558588
	dc.l	$88855888
	dc.l	$88858888

	dc.l	$00333333
	dc.l	$00333333
	dc.l	$00333333
	dc.l	$80003333
	dc.l	$88300003
	dc.l	$88800030
	dc.l	$88880000
	dc.l	$88888800

	dc.l	$33333333
	dc.l	$33333333
	dc.l	$33333333
	dc.l	$33333333
	dc.l	$33333333
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000

	dc.l	$33333333
	dc.l	$33333333
	dc.l	$33333333
	dc.l	$33333333
	dc.l	$30033030
	dc.l	$00003000
	dc.l	$00000000
	dc.l	$00000000

	dc.l	$33333300
	dc.l	$33333300
	dc.l	$33333303
	dc.l	$33333308
	dc.l	$33003308
	dc.l	$00030088
	dc.l	$00000888
	dc.l	$08888888

Level1TilesEnd										; Tiles end address
Level1TilesSizeB: equ (Level1TilesEnd-Level1Tiles)  ; Tiles size in bytes
Level1TilesSizeW: equ (Level1TilesSizeB/SizeWord)   ; Tiles size in words
Level1TilesSizeL: equ (Level1TilesSizeB/SizeLong)   ; Tiles size in longs
Level1TilesSizeT: equ (Level1TilesSizeB/SizeTile)   ; Tiles size in tiles
Level1TilesTileID: equ (Level1TilesVRAM/SizeTile)   ; ID of first tile