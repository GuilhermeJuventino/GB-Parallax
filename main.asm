INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]

    jp EntryPoint

    ds $150 - @, 0 ; Make room for the header

EntryPoint:
    ; Shut down audio circuitry
    ld a, 0
    ld [rNR52], a

    ; Do not turn the LCD off outside of VBlank
    call WaitVBlank

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

    call WaitVBlank

    ld a, [wFrameCounter]
    inc a
    ld [wFrameCounter], a
    ;cp a, 1 ; Run the following code every frame
    ;jp nz, Main
    
    call UpdateBackground

    jp Main

UpdateBackground: 

ParallaxLoop:
    call ParallaxScroll

    ld hl, rLY
    ld a, $1F

    cp a, [hl]
    jp nz, ParallaxLoop

    ret

ParallaxScroll:
    ld a, [wScroll0]
    ld [hl], a
    call Multiply
WaitClouds:
    ldh a, [rLY]
    cp a, [hl]
    jp z, WaitClouds

    ld a, [rSCX]
    ld hl, wFrameCounter
    add a, [hl]
    ldh [rSCX], a

    ld a, [wScroll0]
    ld [hl], a
    call Multiply
WaitTrees:
    ldh a, [rLY]
    cp a, [hl]
    jp z, WaitTrees

    ld a, [wFrameCounter]
    ; divide wFrameCounter by 2
    srl a
    ld [hl], a

    ld a, [rSCX]
    add a, [hl]
    ldh [rSCX], a
    
    ld a, [wScroll0]
    ld [hl], a
    call Multiply
WaitGround:
    ldh a, [rLY]
    cp a, [hl]
    jp z, WaitGround

    ld a, [wFrameCounter]
    ; divide wFrameCounter by 4
    srl a
    srl a
    ld [hl], a

    ld a, [rSCX]
    add a, [hl]
    ldh [rSCX], a

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

Multiply:
    ld a, 8
    ld c, 0

MultiplyLoop:
    add hl, hl
    inc c
    cp a, c
    jp nz, MultiplyLoop
   
    ret

WaitVBlank:
    ld a, [rLY]
    cp 144
    jp c, WaitVBlank

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
