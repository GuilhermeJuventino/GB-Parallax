INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]

    jp EntryPoint

    ds $150 - @, 0 ; Make room for the header

EntryPoint:
    ; Shut down audio circuitry
    ld a, 0
    ld [rNR52], a

    ; Do not turn the LCD off outside of VBlank
WaitVBlank:
    ld a, [rLY]
    cp 144
    jp c, WaitVBlank

    ; Turn the LCD off
    ld a, 0
    ld [rLCDC], a

    ; Copy the tile data
    ld de, Tiles
    ld hl, $9000
    ld bc, TilesEnd - Tiles
    call Memcpy

    ; Copy the tilemap
    ld de, Tilemap
    ld hl, $9800
    ld bc, TilemapEnd - Tilemap
    call Memcpy

    ; Initializing global variables
    ld a, 0
    ld [wFrameCounter], a

    ld a, $7
    ld [wScroll0], a
    ld a, $0E
    ld [wScroll1], a
    ld a, $0F
    ld [wScroll2], a

    ; Turn the LCD on
    ld a, LCDCF_ON | LCDCF_BGON
    ld [rLCDC], a

    ; During the first (blank) frame, initialize display registers
    ld a, %11100100
    ld [rBGP], a

    xor a
    ld [rSCX], a


Main:
    ; Wait untill it's NOT VBlank
    ld a, [rLY]
    cp 144
    jp nc, Main

WaitVBlank2:
    ld a, [rLY]
    cp 144
    jp c, WaitVBlank2

    ld a, [wFrameCounter]
    inc a
    ld [wFrameCounter], a
    cp a, 1 ; Run the following code every frame
    jp nz, Main

    ; Set frame counter back to zero
    ld a, 0
    ld [wFrameCounter], a
    
    ; Scrolling the background
    ld a, [rSCX]
    inc a
    ldh [rSCX], a

    jp Main

; Memcpy
; Copies memory from source address to destination address
; source de, destination hl, length bc
Memcpy:
    ld a, [de]
    ld [hli], a

    inc de
    dec bc
    ld a, b
    or a, c
    jp nz, Memcpy

    ret

Tiles: INCBIN "assets/background.2bpp"
TilesEnd:


Tilemap: INCBIN "assets/background.tilemap"
TilemapEnd:

SECTION "Backgrond Scroll", WRAM0

wScroll0: db
wScroll1: db
wScroll2: db

SECTION "Counter", WRAM0

wFrameCounter: db
