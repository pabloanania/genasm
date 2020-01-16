Level1Map:

	; Include data from .bin file
	incbin	"maps\level1_map.bin"

Level1MapEnd
Level1MapSizeB: equ (Level1MapEnd-Level1Map) ; Map size in bytes
Level1MapSizeW: equ (Level1MapSizeB/2)       ; Map size in words
Level1MapSizeL: equ (Level1MapSizeB/4)       ; Map size in longs

Level1MapDimentions: equ 0x4010              ; Dimentions (W/H) = 64 x 16 tiles