;
; MD201604
;

; Code and graphics by T.M.R/Cosine
; Music by Odie/Cosine


; Select an output filename
		!to "md201604.prg",cbm


; Yank in binary data

		* = $3800
char_data	!binary "data/6px.chr"

		* = $3c00
		!binary "data/starbucks.fli",,2

		* = $8000
music		!binary "data/eotw.prg",,2


; Constants: raster split positions
rstr1p		= $00
rstr2p		= $2c


; Labels
rn		= $b7

scroll_cols	= $b8		; $06 bytes
scroll_cnt	= $bf
char_buffer	= $c0		; $30 bytes

sprite_data	= $3c00


; Add a BASIC startline
		* = $0801
		!word entry-2
		!byte $00,$00,$9e
		!text "2066"
		!byte $00,$00,$00


; Entry point at $0812
		* = $0812
entry		sei

		lda #$35
		sta $01

		lda #<nmi
		sta $fffa
		lda #>nmi
		sta $fffb

		lda #<int
		sta $fffe
		lda #>int
		sta $ffff

		lda #$7f
		sta $dc0d
		sta $dd0d

		lda $dc0d
		lda $dd0d

		lda #rstr1p
		sta $d012

		lda #$3b
		sta $d011
		lda #$01
		sta $d019
		sta $d01a

; Clear zero page workspaces
		ldx #$50
		lda #$00
nuke_zp		sta $00,x
		inx
		bne nuke_zp

; FLI colour RAM inits
		ldx #$00
set_colour	lda $3c00,x
		sta $d800,x
		lda $3d00,x
		sta $d900,x
		lda $3e00,x
		sta $da00,x
		lda $3ec0,x
		sta $dac0,x
		inx
		bne set_colour

; FLI colour masks for bottom character line of the screen
		ldx #$00
		txa
mask_colour	sta $07c0,x
		sta $43c0,x
		sta $47c0,x
		sta $4bc0,x
		sta $4fc0,x
		sta $53c0,x
		sta $57c0,x
		sta $5bc0,x
		sta $5fc0,x
		sta $dbc0,x
		inx
		cpx #$28
		bne mask_colour

; Wipe the last character line of the FLI just to be safe...
		ldx #$00
		txa
bmp_clear	sta $7e00,x
		sta $7f00,x
		inx
		bne bmp_clear

; Set sprite data pointers
		lda #$fe
bank1_sdp_set	sta $5ff8,x
		inx
		cpx #$08
		bne bank1_sdp_set

; Clear ROL scroller's work memory
		ldx #$00
		txa
scroll_clr	sta sprite_data+$000,x
		sta sprite_data+$100,x
		sta sprite_data+$200,x
		sta sprite_data+$300,x
		inx
		bne scroll_clr

; Reset the scrolltext
		jsr reset

; Reset scroll colours to default
		ldx #$00
scroll_col_rst	lda scroll_col_data,x
		sta scroll_cols,x
		inx
		cpx #$06
		bne scroll_col_rst

; Initialise some labels
		lda #$01
		sta rn

; Initialise the music
		lda #$00
		jsr music+$00

		cli

; Runtime loop - nothing to see here, people!
		jmp *


; IRQ interrupt
int		pha
		txa
		pha
		tya
		pha

		lda $d019
		and #$01
		sta $d019
		bne ya
		jmp ea31

ya		lda rn
		cmp #$02
		bne *+$05
		jmp rout2


; Raster split 1
rout1		lda #$00
		sta $d020
		sta $d021

		lda #$3b
		sta $d011
		lda #$18
		sta $d016
		lda #$08
		sta $d018

		lda #$c6
		sta $dd00

; Set up the hardware sprites
		lda #$ff
		sta $d015
		sta $d01d

		ldx #$00
		ldy #$00
set_sprx_1	lda sprite_x,x
		sta $d000,y
		lda #$f2
		sta $d001,y
		lda sprite_dp,x
		sta $07f8,x
		iny
		iny
		inx
		cpx #$08
		bne set_sprx_1
		lda sprite_x+$08
		sta $d010

; Play the music
;		lda #$02
;		sta $d020
		jsr music+$03
;		lda #$00
;		sta $d020

; Setup for the next interrupt
		lda #$02
		sta rn
		lda #rstr2p
		sta $d012

		jmp ea31


		* = ((*/$100)+1)*$100

; Raster split 2
rout2		nop
		nop
		nop
		nop
		nop
		bit $ea

		lda $d012
		cmp #rstr2p+$01
		bne *+$02
;		sta $d020

		ldx #$0a
		dex
		bne *-$01
		nop
		nop
		lda $d012
		cmp #rstr2p+$02
		bne *+$02
;		sta $d020

		ldx #$0a
		dex
		bne *-$01
		nop
		lda $d012
		cmp #rstr2p+$03
		bne *+$02
;		sta $d020

		ldx #$0a
		dex
		bne *-$01
		nop
		lda $d012
		cmp #rstr2p+$04
		bne *+$02
;		sta $d020

		ldx #$0a
		dex
		bne *-$01
		bit $ea
		nop
		lda $d012
		cmp #rstr2p+$05
		bne *+$02
;		sta $d020

		nop
		nop
		nop

		ldx #$09
		dex
		bne *-$01
		nop
		lda $d012
		cmp #rstr2p+$06
		bne *+$02
;		sta $d020


; FLI - first character line
		ldx #$0e
		dex
		bne *-$01
		bit $ea

		ldx #$3c
		ldy #$18
		nop
		nop
		nop
		sty $d018
		stx $d011

		bit $ea
		nop

		ldx #$3d
		ldy #$28
		nop
		nop
		nop
		sty $d018
		stx $d011

		bit $ea
		nop

		ldx #$3e
		ldy #$38
		nop
		nop
		nop
		sty $d018
		stx $d011

		bit $ea
		nop

		ldx #$3f
		ldy #$48
		nop
		nop
		nop
		sty $d018
		stx $d011

		bit $ea
		nop

		ldx #$38
		ldy #$58
		nop
		nop
		nop
		sty $d018
		stx $d011

		bit $ea
		nop

		ldx #$39
		ldy #$68
		nop
		nop
		nop
		sty $d018
		stx $d011

		bit $ea
		nop

		ldx #$3a
		ldy #$78
		nop
		nop
		nop
		sty $d018
		stx $d011

		bit $ea
		nop


; FLI - second character line onwards
!set line_cnt=$00
!do {
		ldx #$3b
		ldy #$08
		nop
		nop
		nop
		sty $d018
		stx $d011

		bit $ea
		nop

		ldx #$3c
		ldy #$18
		nop
		nop
		nop
		sty $d018
		stx $d011

		bit $ea
		nop

		ldx #$3d
		ldy #$28
		nop
		nop
		nop
		sty $d018
		stx $d011

		bit $ea
		nop

		ldx #$3e
		ldy #$38
		nop
		nop
		nop
		sty $d018
		stx $d011

		bit $ea
		nop

		ldx #$3f
		ldy #$48
		nop
		nop
		nop
		sty $d018
		stx $d011

		bit $ea
		nop

		ldx #$38
		ldy #$58
		nop
		nop
		nop
		sty $d018
		stx $d011

		bit $ea
		nop

		ldx #$39
		ldy #$68
		nop
		nop
		nop
		sty $d018
		stx $d011

		bit $ea
		nop

		ldx #$3a
		ldy #$78
		nop
		nop
		nop
		sty $d018
		stx $d011

		bit $ea
		nop

		!set line_cnt=line_cnt+$01
} until line_cnt=$17

		lda #$c7
		ldx #$1f
		ldy #$3b
		sta $dd00
		stx $d018
		sty $d011

; Here goes for the lower border
		lda #$34
		sta $d011
		nop
		nop
		nop

; Scroll scanline $00
		lda #$6f
		sta $d000

		nop
		nop
		nop
		bit $ea
		ldy scroll_cols+$00
		sty $d028
		sty $d029
		sty $d02a
		sty $d02b

		dec $d016
		inc $d016

; Scroll scanline $01
		lda #$e7
		sta $d000

		nop
		nop
		nop
		nop
		nop
		sty $d02c
		sty $d02d
		sty $d02e
		sty $d027

		ldx #$0b
		dec $d016
		stx $d021
		inc $d016

; Scroll scanline $02
		lda #$6f
		sta $d000

		bit $ea
		ldy scroll_cols+$01
		sty $d028
		sty $d029
		sty $d02a
		sty $d02b

		ldx #$00
		dec $d016
		stx $d021
		inc $d016

; Scroll scanline $03
		lda #$e7
		sta $d000

		nop
		nop
		nop
		sty $d02c
		sty $d02d
		sty $d02e
		sty $d027

		ldx #$0b
		dec $d016
		stx $d021
		inc $d016

; Scroll scanline $04
		lda #$6f
		sta $d000

		bit $ea
		ldy scroll_cols+$02
		sty $d028
		sty $d029
		sty $d02a
		sty $d02b

		ldx #$00
		dec $d016
		stx $d021
		inc $d016

; Scroll scanline $05
		lda #$e7
		sta $d000

		nop
		nop
		nop
		sty $d02c
		sty $d02d
		sty $d02e
		sty $d027

		ldx #$0b
		dec $d016
		stx $d021
		inc $d016

; Scroll scanline $06
		lda #$6f
		sta $d000

		bit $ea
		ldy scroll_cols+$03
		sty $d028
		sty $d029
		sty $d02a
		sty $d02b

		ldx #$00
		dec $d016
		stx $d021
		inc $d016

; Scroll scanline $07
		lda #$e7
		sta $d000

		nop
		nop
		nop
		sty $d02c
		sty $d02d
		sty $d02e
		sty $d027

		ldx #$0b
		dec $d016
		stx $d021
		inc $d016

; Scroll scanline $08
		lda #$6f
		sta $d000

		bit $ea
		ldy scroll_cols+$04
		sty $d028
		sty $d029
		sty $d02a
		sty $d02b

		ldx #$00
		dec $d016
		stx $d021
		inc $d016

; Scroll scanline $09
		lda #$e7
		sta $d000

		nop
		nop
		nop
		sty $d02c
		sty $d02d
		sty $d02e
		sty $d027

		ldx #$0b
		dec $d016
		stx $d021
		inc $d016

; Scroll scanline $0a
		lda #$6f
		sta $d000

		bit $ea
		ldy scroll_cols+$05
		sty $d028
		sty $d029
		sty $d02a
		sty $d02b

		ldx #$00
		dec $d016
		stx $d021
		inc $d016

; Scroll scanline $0b
		lda #$e7
		sta $d000

		nop
		nop
		nop
		sty $d02c
		sty $d02d
		sty $d02e
		sty $d027

		ldx #$0b
		dec $d016
		stx $d021
		inc $d016

; Scroll scanline $0c
		lda #$6f
		sta $d000

		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop

		ldx #$00
		dec $d016
		stx $d021
		inc $d016

; Scroll scanline $0d
		lda #$e7
		sta $d000

		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop

		dec $d016
		inc $d016

; Scroll scanline $0e
		lda #$6f
		sta $d000
		lda #$00
		sta $d020
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop

		dec $d016
		inc $d016

		ldx #$06
		dex
		bne *-$01
		bit $ea
		lda #$00
		sta $d020


; Update the scroller
		ldx #$00
mover		asl char_buffer,x

		rol sprite_data+$00f,x

		rol sprite_data+$1ce,x
		rol sprite_data+$1cd,x
		rol sprite_data+$1cc,x

		rol sprite_data+$18e,x
		rol sprite_data+$18d,x
		rol sprite_data+$18c,x

		rol sprite_data+$14e,x
		rol sprite_data+$14d,x
		rol sprite_data+$14c,x

		rol sprite_data+$10e,x
		rol sprite_data+$10d,x
		rol sprite_data+$10c,x

		rol sprite_data+$0ce,x
		rol sprite_data+$0cd,x
		rol sprite_data+$0cc,x

		rol sprite_data+$08e,x
		rol sprite_data+$08d,x
		rol sprite_data+$08c,x

		rol sprite_data+$04e,x
		rol sprite_data+$04d,x
		rol sprite_data+$04c,x

		rol sprite_data+$00e,x
		rol sprite_data+$00d,x
		rol sprite_data+$00c,x

		inx
		inx
		inx
		inx
		inx
		inx
		cpx #$24
		beq *+$05
		jmp mover

; Fetch a new character
		ldx scroll_cnt
		inx
		cpx #$08
		bne sclb_xb

mread		lda scroll_text
		bne okay
		jsr reset
		jmp mread

okay		cmp #$40
		bcc okay_2
		and #$0f
		asl
		asl
		asl
		tay
		ldx #$00
scr_col_fetch	lda scroll_col_data,y
		sta scroll_cols,x
		iny
		inx
		cpx #$06
		bne scr_col_fetch

		lda #$20

okay_2		sta def_copy+$01
		lda #$00
		asl def_copy+$01
		rol
		asl def_copy+$01
		rol
		asl def_copy+$01
		rol
		clc
		adc #>char_data
		sta def_copy+$02

		ldx #$00
		ldy #$00
def_copy	lda $6464,x
;		eor #$ff
		sta char_buffer,y
		iny
		iny
		iny
		iny
		iny
		iny
		inx
		cpx #$08
		bne def_copy

		inc mread+$01
		bne *+$05
		inc mread+$02


		ldx #$00
sclb_xb		stx scroll_cnt

; Setup for the next interrupt
		lda #$01
		sta rn
		lda #rstr1p
		sta $d012

; Exit interrupt
ea31		pla
		tay
		pla
		tax
		pla
nmi		rti


; Reset the scroller
reset		lda #<scroll_text
		sta mread+$01
		lda #>scroll_text
		sta mread+$02
		rts


; Sprite co-ordinates for the scroller
sprite_x	!byte $6f,$1f,$4f,$7f,$af,$df,$0f,$3f
		!byte $c1
sprite_dp	!byte $f0,$f1,$f2,$f3,$f4,$f5,$f6,$f7

; The good ol' scrolling message - values $40 to $47 select colour tables
scroll_text	!scr $41,"'lo all, it's t.m.r writing to start with and "
		!scr "welcoming you all to   --- md201604 ---   which could "
		!scr "have been subtitled   --- we love caffeine ---   since "
		!scr "much of the linking and text writing took place during "
		!scr "a little cosine meeting held at a starbucks in "
		!scr "canterbury yesterday!      "

		!scr "i turned up with some code, odie brought along music "
		!scr "for the occasion and he and enigma wrote text and "
		!scr "posed for the picture above - kryten joined us as well "
		!scr "but couldn't stay long enough to pitch in some text "
		!scr "and the picture of all four of us didn't survive the "
		!scr "conversion to fli!      "

		!scr "now...   since there are actually other members of "
		!scr "cosine poised to delight and entertain for a change, "
		!scr "i'm going to stop waffling on and hand the keys over "
		!scr "to enigma..."
		!scr "                         "

		!scr $42,"well - it's been a while since i last did a scroll, "
		!scr "about 20 years to be precise!   sad to think also that "
		!scr "my first contribution to cosine is also just text, so "
		!scr "i need to pull out my finger and do some artwork once "
		!scr "things quieten down.   games that weren't takes up a "
		!scr "significant amount of free time, and then there is my new "
		!scr "'top secret' project which i hope to reveal "
		!scr "later this year after about 3 years of blood, sweat and "
		!scr "tears.   at some point, i am hoping to get involved with "
		!scr "another new c64 game.   last year i started up again with "
		!scr "the graphics i did for real speed we need to translate "
		!scr "into a new game called endurance, which hopefully t.m.r "
		!scr "will be developing at a later date.   about two level "
		!scr "maps are complete, the status panel and most of the "
		!scr "sprites, so once the previously mentioned project is "
		!scr "done - then hopefully i can get back to finishing the "
		!scr "artwork and maps.   well, i'd better wrap things up, "
		!scr "as there is a bus to catch from what has been a great "
		!scr "catch up with t.m.r, odie and kryten.   catcha later!"
		!scr "                         "

		!scr $43,"howdy, so you've got odie prodding on the keys now, "
		!scr "but this certainly isn't my first ever scrolltext.   my "
		!scr "contribution to this demo was t.m.r pointing the camera "
		!scr "and going click, oh and the music too.   its a cover of "
		!scr "pet shop boys the end of the world which i managed to "
		!scr "complete in a single day before scooting down to visit "
		!scr "the other cosiners.   we've spent a day chatting, reminiscing "
		!scr "and also drinking coffee and eating burger king meals, plus "
		!scr "a visit to a local retro computer shop, so it has been a "
		!scr "lot of fun.   we do like the gossip what's going on in the "
		!scr "computing world, if it's on facebook, we've certainly been "
		!scr "talking about it (such as the coleco chameleon - ha ha)!   "
		!scr "it'll be another 4 months before we get to meet up again, "
		!scr "so we will most likely have another 4 demos out in that "
		!scr "time too! recently i opened a soundcloud account to host "
		!scr "my music from the pc - "
		!scr "https://soundcloud.com/sean-connolly-860101367/ - "
		!scr "there are only a couple of tunes in there at the moment, "
		!scr "but i will be adding more of my stuff as time goes on.   "
		!scr "in the meantime, i should sign off because without a "
		!scr "caffeine injection, t.m.r will probably nod off as it has "
		!scr "been quite a long day for us all and i've still got "
		!scr "over an hour drive home to do still!   c'ya later!"

		!scr "                         "

		!scr $40,"time for some greetings and the usual, alpha-sorted "
		!scr "handshakes connect with:    "

		!scr "abyss connection + "
		!scr "arkanix labs + "
		!scr "artstate + "
		!scr "ate bit + "
		!scr "atlantis and f4cg + "
		!scr "booze design + "
		!scr "camelot + "
		!scr "chorus + "
		!scr "chrome + "
		!scr "cncd + "
		!scr "cpu + "
		!scr "crescent + "
		!scr "crest + "
		!scr "covert bitops + "
		!scr "defence force + "
		!scr "dekadence + "
		!scr "desire + "
		!scr "dac + "
		!scr "dmagic + "
		!scr "dualcrew + "
		!scr "exclusive on + "
		!scr "fairlight + "
		!scr "fire + "
		!scr "focus + "
		!scr "french touch + "
		!scr "funkscientist productions + "
		!scr "genesis project + "
		!scr "gheymaid inc. + "
		!scr "hitmen + "
		!scr "hokuto force + "
		!scr "level64 + "
		!scr "maniacs of noise + "
		!scr "mayday + "
		!scr "meanteam + "
		!scr "metalvotze + "
		!scr "noname + "
		!scr "nostalgia + "
		!scr "nuance + "
		!scr "offence + "
		!scr "onslaught + "
		!scr "orb + "
		!scr "oxyron + "
		!scr "padua + "
		!scr "plush + "
		!scr "psytronik + "
		!scr "reptilia + "
		!scr "resource + "
		!scr "rgcd + "
		!scr "secure + "
		!scr "shape + "
		!scr "side b + "
		!scr "singular + "
		!scr "slash + "
		!scr "slipstream + "
		!scr "success and trc + "
		!scr "style + "
		!scr "suicyco industries + "
		!scr "taquart + "
		!scr "tempest + "
		!scr "tek + "
		!scr "triad + "
		!scr "trsi + "
		!scr "viruz + "
		!scr "vision + "
		!scr "wow + "
		!scr "wrath + "
		!scr "xenon + "
		!scr "and whoever else is still reading at this point!"
		!scr "                         "

		!scr $41,"and it's t.m.r back again because all we've got "
		!scr "left to do now is plug the cosine website at "
		!scr "http://cosine.org.uk/ before disappearing into the "
		!scr "night... .. .  .   ."
		!scr "                         "
		!byte $00

; Scroll colour tables
scroll_col_data	!byte $0c,$0f,$07,$01,$07,$0f,$00,$00		; $40 - greetings

		!byte $0d,$01,$0d,$03,$0e,$04,$00,$00		; $41 - T.M.R's colours
		!byte $0d,$0f,$05,$03,$0d,$01,$00,$00		; $42 - enigma's colours
		!byte $08,$0a,$0f,$07,$01,$07,$00,$00		; $43 - odie's colours
