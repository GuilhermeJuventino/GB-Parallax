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

    ld a, $00
    ld [wScroll0], a
    ld a, $0D
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
    
    call UpdateBackground

    jp Main

UpdateBackground: 

ParallaxLoop:
    ; Scrolling the background
    call ParallaxScroll
    ld a, [rSCX]
    add a, c
    ldh [rSCX], a

    ld hl, rLY
    ld a, $1F

    cp a, [hl]
    jp nz, ParallaxLoop

    ret

ParallaxScroll:
    ld de, rLY
    ld hl, wScroll0

    ld a, [de]

    ldh a, [rLYC]
    ld hl, wScroll0
    cp a, [hl]
    jp z, ScrollClouds

    ld hl, wScroll1
    cp a, [hl]
    jp z, ScrollTrees

    ld hl, wScroll2
    cp a, [hl]
    jp z, ScrollGround

    jp ParallaxEnd

ScrollClouds:
    ld c, 1

    jp ParallaxEnd

ScrollTrees:
    ld c, 2

    jp ParallaxEnd

ScrollGround:
    ld c, 3

    jp ParallaxEnd

ParallaxEnd:
    ret

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
