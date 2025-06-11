INCLUDE "hardware.inc"


def TreesStart EQU 104
def GroundStart EQU 120

def CloudsSpeed EQU 1
def TreesSpeed EQU 2
def GroundSpeed EQU 3

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
    
    ; Initial scroll position of background segments
    xor a
    ld [wCloudsPosition], a
    ld [wTreesPosition], a
    ld [wGroundPosition], a

    ; Turn the LCD on
    ld a, LCDCF_ON | LCDCF_BGON
    ld [rLCDC], a

    ; During the first (blank) frame, initialize display registers
    ld a, %11100100
    ld [rBGP], a

    xor a
    ld [rSCX], a


Main:    
    call UpdateBackground

    ;jp Main

UpdateBackground: 

WaitForTrees:
    ldh a, [rLY]
    cp a, TreesStart - 1
    jp nz, WaitForTrees

    REPT 80
        nop
    ENDR

    ld a, [wTreesPosition]
    ldh [rSCX], a

WaitForGround:
    ldh a, [rLY]
    cp a, GroundStart - 1
    jp nz, WaitForGround

    REPT 80
        nop
    ENDR

    ld a, [wGroundPosition]
    ldh [rSCX], a

    call WaitVBlank

    ld a, [wCloudsPosition]
    ldh [rSCX], a

    ld a, [wFrameCounter]
    inc a

    ; reset every 3 frames
    cp a, 3
    jr nz, SaveFrame

    xor a

SaveFrame:
    ld [wFrameCounter], a
    jp nz, Main

    ld a, [wTreesPosition]
    add a, TreesSpeed
    ld [wTreesPosition], a

    ld a, [wGroundPosition]
    add a, GroundSpeed
    ld [wGroundPosition], a

    ld a, [wCloudsPosition]
    add a, CloudsSpeed
    ld [wCloudsPosition], a

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

wCloudsPosition: db
wTreesPosition: db
wGroundPosition: db

SECTION "Counter", WRAM0

wFrameCounter: db
