; Disassembly of "Dottori-Kun" arcade, New Version
; by Chris Covell (www.chrismcovell.com)

; RAM Area:
; 8600          Checksum failed flags in bits 0,1.
; 8601		Random Seed L
; 8602		Random Seed H
; 8603		Palette
; 8604		Joy Press:    7   6  5   4   3  2  1  0
; 8605		Joy Trigger: COIN ST BT2 BT1 R  L  D  U
; 8606		Joy Release
; 8607		VBlank_Pass (FF = VBlank code has passed.)

; 8608		ingame mode
; 8609		Paused
; 860A		Message number
; 860B		Dot Count
; 860C - 86CB	wall/dot map in RAM
; 86CC		Level Number
; 86CD		Level Display
; 86CE		Player has HIT Enemies?
; 86CF-DO	Wait_Counter

; 86f0		Program MODE number (0,2,4,6...)
; 86f1		Cursor value
; 86f2		Temporary palette storage

; 8700-1	Player X-position (8.8)
; 8702-3	Player Y-position (8.8)

; Map data from $0795-0854
			;Wall/dot format in dot_wall_map+: 	76543210
			;(walls use bit CLEAR=wall)		??drRLDU
			;d = dot, r = redirect player

; 0855-087C are player/monster starting positions
; 087d-08dc are player/monster speeds / presence
; $0bbe-  are text strings
; $0c6a-$0d61 are FONT tiles


;Reset
0000 f3        di
0001 310088    ld      sp,$8800
0004 ed56      im      1
0006 1833      jr      $003b

;------- Return (HL+A) ------------
0008 d5        push    de
0009 5f        ld      e,a
000a 1600      ld      d,$00
000c 19        add     hl,de
000d 7e        ld      a,(hl)
000e d1        pop     de
000f c9        ret

;--------- Get Random Value & shuffle Rand Seed
0010 e5        push    hl
0011 2a0186    ld      hl,(RandSeed)
0014 7c        ld      a,h
0015 0f        rrca
0016 0f        rrca
0017 ac        xor     h
0018 0f        rrca
0019 ad        xor     l
001a 0f        rrca
001b 0f        rrca
001c 0f        rrca
001d 0f        rrca
001e ad        xor     l
001f 1f        rra
0020 ed6a      adc     hl,hl
0022 2003      jr      nz,+
0024 213c73    ld      hl,$733c
+:
     ed5f      ld      a,r
0029 ad        xor     l
002a 220186    ld      (RandSeed),hl
002d e1        pop     hl
002e c9        ret
;=========================================
;...
0036 f7        rst     $30		;Checksum bytes?
0037 a9        xor     c

0038 c30001    jp      $0100		;Interrupt Routine


;Init continues here
003b 210080    ld      hl,$8000		;Clear screen RAM
003e 110180    ld      de,$8001
0041 01ff07    ld      bc,$07ff
0044 3600      ld      (hl),$00
0046 edb0      ldir
0048 3eb8      ld      a,$b8		;%10_111_000	;white BG, black chars
004a d300      out     (Pal_Register),a          ;the only port in this HW, apparently.

;----------------- Test Screen Mem ------------------------------
004c 0600      ld      b,$00		;b = loop 256 times
--:
004e 210080    ld      hl,$8000
0051 110008    ld      de,$0800
-:
     34        inc     (hl)		;Cycle all bits in screen memory
0055 23        inc     hl
0056 1b        dec     de
0057 7b        ld      a,e
0058 b2        or      d
0059 20f9      jr      nz,-
005b 10f1      djnz    --
;-------------------------------------
005d 210080    ld      hl,$8000
0060 110008    ld      de,$0800
-:
     7e        ld      a,(hl)		;Now test that all bits in memory are Zero
0064 a7        and     a
0065 2008      jr      nz,+
0067 23        inc     hl
0068 1b        dec     de
0069 7b        ld      a,e
006a b2        or      d
006b 20f6      jr      nz,-
006d 1805      jr      ++
+:
006f 3e01      ld      a,$01		;Error flag
0071 320086    ld      ($8600),a
;-------------------------------------

++:
0074 210000    ld      hl,$0000
0077 010010    ld      bc,$1000
007a cd1801    call    $0118		;Do the weirdest checksum routine ever???
007d 2a3600    ld      hl,($0036)
0080 a7        and     a
0081 ed52      sbc     hl,de            ;Ignore the results of the ROM check anyway...
0083 1805      jr      $008a		;jr      z,$008a in Ver.1
					;(I think they knew their checksum was just busywork.)
; UNUSED Instructions?
0085 210086    ld      hl,$8600
0088 cbce      set     1,(hl)

008a 210206    ld      hl,$0602		;"RAM"
008d cd7f02    call    Copy_Blocks_Dest_Rows_027f
0090 211b06    ld      hl,$061b		;"ROM"
0093 cd7f02    call    Copy_Blocks_Dest_Rows_027f
0096 3a0086    ld      a,($8600)
0099 118882    ld      de,$8288
009c 213406    ld      hl,$0634
009f cb47      bit     0,a		;Aha, was the RAM test GOOD or BAD?
00a1 2803      jr      z,+
00a3 215206    ld      hl,$0652
+:
00a6 f5        push    af
00a7 cd8302    call    Copy_Blocks_Rows_0283
00aa f1        pop     af
00ab 118883    ld      de,$8388
00ae 213406    ld      hl,$0634
00b1 cb4f      bit     1,a		;Check the Checksum result
00b3 2803      jr      z,+
00b5 215206    ld      hl,$0652		;Write either good or bad
+:
00b8 f5        push    af
00b9 cd8302    call    Copy_Blocks_Rows_0283
00bc f1        pop     af
00bd a7        and     a
00be 20fe      jr      nz,$00be		;LOOP INFINITELY HERE!
;----------------------------------

00c0 3e87      ld      a,$87		;10_000_111	;Black BG, White Chars
00c2 320386    ld      (Palette),a
00c5 218082    ld      hl,$8280
00c8 118182    ld      de,$8281
00cb 010003    ld      bc,$0300
00ce 3600      ld      (hl),$00
00d0 edb0      ldir            		;Zero-out lower part of screen
00d2 cd4701    call    Read_Joy_0147
;----- attract mode restarts here
00d5 af        xor     a
00d6 320886    ld      (ingame_mode),a
00d9 32cc86    ld      (LevelNum),a
00dc 3c        inc     a
00dd 32cd86    ld      (Level_Disp),a
00e0 3e80      ld      a,$80
00e2 32cf86    ld      (wait_counter),a	;Set a waiting time

;Main Program Loop
-:
00e5 fb        ei
00e6 310088    ld      sp,$8800		;Reset the stack
00e9 cd1602    call    Wait_VB_0216
00ec cd4701    call    Read_Joy_0147
00ef cd4509    call    $0945		;Tests COIN, changes program modes.
00f2 cd2d02    call    $022d            ;Print Stage #, Pause text.
00f5 cdd102    call    Ingame_Handler_02d1	;4 routines based on ingame_mode
00f8 cd5a04    call    Player_Movement_045a
00fb cd5205    call    Enemy_Movement_0552	;Moves enemies, handles hit detection
00fe 18e5      jr      -
;//////////////////////////////////////////



;========================== Interrupt Routine =============
0100 f5        push    af
0101 c5        push    bc
0102 d5        push    de
0103 e5        push    hl
0104 dde5      push    ix
0106 fde5      push    iy	;A little different here from V1
0108 cd5b01    call    Set_Palette_015b		;See if palette needs changing, & do it!
010b cdac0a    call    $0aac	;Go to a Mode Jump Table!
010e fde1      pop     iy
0110 dde1      pop     ix
0112 e1        pop     hl
0113 d1        pop     de
0114 c1        pop     bc
0115 f1        pop     af
0116 fb        ei
0117 c9        ret
;=========================================================


;First checksum routine
0118 110000    ld      de,$0000
-:
011b e5        push    hl
011c d5        push    de
011d 113600    ld      de,$0036
0120 a7        and     a
0121 ed52      sbc     hl,de
0123 d1        pop     de
0124 e1        pop     hl		;Basically, this is all bullshit, I think.
0125 2004      jr      nz,+
0127 23        inc     hl
0128 23        inc     hl
0129 1816      jr      ++
+:
012b 7b        ld      a,e
012c ae        xor     (hl)
012d 5f        ld      e,a
012e 7a        ld      a,d
012f 23        inc     hl
0130 ae        xor     (hl)
0131 57        ld      d,a
0132 23        inc     hl
0133 cb3a      srl     d
0135 cb1b      rr      e
0137 3008      jr      nc,++
0139 7a        ld      a,d
013a ee88      xor     $88
013c 57        ld      d,a
013d 7b        ld      a,e
013e ee10      xor     $10
0140 5f        ld      e,a
++:
0141 0b        dec     bc
0142 78        ld      a,b
0143 b1        or      c
0144 20d5      jr      nz,-
0146 c9        ret
;-------------------------

;=================================================
Read_Joy_0147:
     210486    ld      hl,Joy_Press		;Old joy button press
014a db00      in      a,($00)		;Get joystick buttons from port
014c 2f        cpl
014d 56        ld      d,(hl)		;load old
014e 77        ld      (hl),a		;replace with new
014f aa        xor     d                ;get difference with old
0150 5f        ld      e,a
0151 7a        ld      a,d
0152 2f        cpl                      ;now "unpressed" in old are 1
0153 a3        and     e                ;mask out "new presses"
0154 23        inc     hl
0155 77        ld      (hl),a		;save joy trigger in Joy_Trig
0156 7a        ld      a,d              ;"pressed" in old are 1
0157 a3        and     e                ;mask out "newly released"
0158 23        inc     hl
0159 77        ld      (hl),a		;save joy release in Joy_Release
015a c9        ret     

;------------ Set Palette Routine
Set_Palette_015b:
     210386    ld      hl,Palette	;Check if high bit set as a palette trigger.
015e 7e        ld      a,(hl)
015f cb7f      bit     7,a
0161 c8        ret     z
0162 cbbf      res     7,a
0164 d300      out     (Pal_Register),a		;Output palette
0166 77        ld      (hl),a
0167 c9        ret
;-----------------------------------------------

; in-game, in-VBlank code, I think
0168 3a0886    ld      a,(ingame_mode)
016b a7        and     a
016c 2804      jr      z,+
016e d603      sub     $03
0170 3805      jr      c,++	;If DEAD or Attract mode on, do nothing.
+:
0172 0600      ld      b,$00	;Kill time only....?
-:
     10fe      djnz    -
0176 c9        ret
++:
0177 dd210087  ld      ix,$8700
017b 112000    ld      de,$0020
017e 0604      ld      b,$04		;Potentially 4 characters on-screen....
--:
0180 c5        push    bc
0181 d5        push    de
0182 0605      ld      b,$05
0184 21fb08    ld      hl,$08fb		;Player / Enemy graphic MASKS
-:
     dd7e07    ld      a,(ix+$07)	;(I think this erases player/enemy's old position.)
018a 86        add     a,(hl)
018b fec0      cp      $c0
018d c5        push    bc
018e e5        push    hl
018f dde5      push    ix
0191 dcae03    call    c,$03ae		;If within boundaries, draw tile character
0194 dde1      pop     ix
0196 e1        pop     hl
0197 c1        pop     bc
0198 23        inc     hl
0199 10ec      djnz    -
019b d1        pop     de
019c c1        pop     bc
019d dd19      add     ix,de
019f 10df      djnz    --
01a1 dd210087  ld      ix,$8700
01a5 fd21dd08  ld      iy,$08dd		;Player direction graphics
01a9 dd7e06    ld      a,(ix+$06)
01ac 110600    ld      de,$0006
-:
01af 0f        rrca
01b0 3804      jr      c,+
01b2 fd19      add     iy,de
01b4 18f9      jr      -		;Wow, if A ever were blank, infinite loop!
+:
01b6 cdd401    call    Shift_Char_To_Screen_01d4
01b9 112000    ld      de,$0020
01bc 0603      ld      b,$03		;Do for 3 enemies
01be fd21f508  ld      iy,$08f5		;Enemy graphic
01c2 dd19      add     ix,de
01c4 dd7e08    ld      a,(ix+$08)
01c7 ddb609    or      (ix+$09)
01ca c5        push    bc
01cb d5        push    de
01cc c4d401    call    nz,Shift_Char_To_Screen_01d4
01cf d1        pop     de
01d0 c1        pop     bc
01d1 10eb      djnz    $01be
01d3 c9        ret
;=======================================

Shift_Char_To_Screen_01d4:
     dd7e01    ld      a,(ix+$01)
01d7 d603      sub     $03
01d9 47        ld      b,a		;Separate character # and pixel pos.
01da cb38      srl     b
01dc cb38      srl     b
01de cb38      srl     b
01e0 e607      and     $07
01e2 4f        ld      c,a
01e3 dd7e03    ld      a,(ix+$03)
01e6 d603      sub     $03
01e8 6f        ld      l,a
01e9 2600      ld      h,$00
01eb 29        add     hl,hl		;Calculate vertical offset
01ec 29        add     hl,hl
01ed 29        add     hl,hl
01ee 29        add     hl,hl
01ef 110080    ld      de,$8000		;Point to right place on screen
01f2 58        ld      e,b
01f3 19        add     hl,de
01f4 0606      ld      b,$06		;Loop for 6 pixels' height
--:
01f6 fd5e00    ld      e,(iy+$00)
01f9 1600      ld      d,$00
01fb 79        ld      a,c
01fc a7        and     a		;Position back in A
01fd 2807      jr      z,+		;Do nothing if it's zero (offscreen?)
-:
01ff cb3b      srl     e		;Shift source graphic based on position
0201 cb1a      rr      d
0203 3d        dec     a
0204 20f9      jr      nz,-
+:
0206 7e        ld      a,(hl)
0207 b3        or      e
0208 77        ld      (hl),a
0209 23        inc     hl
020a 7e        ld      a,(hl)
020b b2        or      d
020c 77        ld      (hl),a
020d fd23      inc     iy
020f 110f00    ld      de,$000f
0212 19        add     hl,de
0213 10e1      djnz    --
0215 c9        ret

;======================================
;Wait for VBlank to pass
Wait_VB_0216:
     210786    ld      hl,VBlank_Pass
-:
0219 cb7e      bit     7,(hl)
021b 28fc      jr      z,-
021d 3600      ld      (hl),$00
021f c9        ret
;----------------------------


;This code is now unused in the NEW version of Dottori
0220 3a0586    ld      a,(Joy_Trig)
0223 cb7f      bit     7,a
0225 c8        ret     z
;---
0226 210386    ld      hl,Palette
0229 34        inc     (hl)		;Cycle through all palettes when Coin pressed
022a cbfe      set     7,(hl)
022c c9        ret
;--------------------------------------


;------------------- another routine during VBlank -------
022d 3a0586    ld      a,(Joy_Trig)
0230 cb6f      bit     5,a		;Check button 2 pressed and reverse PAUSE
0232 2009      jr      nz,+
0234 210986    ld      hl,Paused
0237 cb46      bit     0,(hl)
0239 c8        ret     z
;----
023a c3e500    jp      $00e5		;RETURN to main loop!
+:
023d 210986    ld      hl,Paused
0240 34        inc     (hl)
0241 cb46      bit     0,(hl)
0243 ca4e02    jp      z,+
0246 3e01      ld      a,$01
0248 cd5602    call    ++		;Clear 6x20 row routine
024b c3e500    jp      $00e5		;RETURN to main loop!
+:
024e cd6302    call    $0263		;Clear 6x20 rows.
0251 3a0a86    ld      a,(msg_num)
0254 1805      jr      +
++:
0256 f5        push    af
0257 cd6302    call    $0263		;Clear 6x20 rows.
025a f1        pop     af
+:
     a7        and     a
025c c47702    call    nz,Copy_Block_APtr_0277
025f cd9d02    call    $029d		;Print Level # 1/2 digits?
0262 c9        ret


; 6x20 screen clearing routine
0263 21c582    ld      hl,$82c5		;Clear 6 bytes x 20 rows on-screen
0266 110a00    ld      de,$000a
0269 0e14      ld      c,$14
--:
026b 0606      ld      b,$06
-:
026d 3600      ld      (hl),$00
026f 23        inc     hl
0270 10fb      djnz    -
0272 19        add     hl,de
0273 0d        dec     c
0274 20f5      jr      nz,--
0276 c9        ret
;-----------------------------------


Copy_Block_APtr_0277:
     216906    ld      hl,$0669		;Point to short table...
027a 87        add     a,a
027b cf        rst     08_Get_HL+A	;Add A offset & get word pointer there
027c 23        inc     hl
027d 66        ld      h,(hl)		;Table points to: 673, 6A1, 6FF, 733 only.
027e 6f        ld      l,a              ;4 graphic strings "Go", "Pause" etc.

; Data header has Destination(W), NumRows(B), ByteLength(B)
Copy_Blocks_Dest_Rows_027f:
     5e        ld      e,(hl)
0280 23        inc     hl
0281 56        ld      d,(hl)
0282 23        inc     hl

Copy_Blocks_Rows_0283:
     4e        ld      c,(hl)
0284 23        inc     hl
0285 7e        ld      a,(hl)
0286 23        inc     hl
0287 eb        ex      de,hl
--:
0288 e5        push    hl
0289 47        ld      b,a
-:
028a f5        push    af
028b 1a        ld      a,(de)
028c 77        ld      (hl),a
028d f1        pop     af
028e 13        inc     de
028f 23        inc     hl
0290 10f8      djnz    -
0292 e1        pop     hl
0293 d5        push    de
0294 111000    ld      de,$0010
0297 19        add     hl,de
0298 d1        pop     de
0299 0d        dec     c
029a 20ec      jr      nz,--
029c c9        ret
;============================================


029d 3a0886    ld      a,(ingame_mode)	;If this flag is zero, print nothing
02a0 a7        and     a
02a1 c8        ret     z
;--------
02a2 3acd86    ld      a,(Level_Disp)	;Print upper nybble
02a5 e6f0      and     $f0
02a7 2807      jr      z,+
02a9 0f        rrca
02aa 118983    ld      de,$8389
02ad cdbb02    call    $02bb
+:
02b0 3acd86    ld      a,(Level_Disp)	;Print lower nybble
02b3 e60f      and     $0f
02b5 87        add     a,a		;Multiply by 8 (8x8 pixels)
02b6 87        add     a,a
02b7 87        add     a,a
02b8 118a83    ld      de,$838a
;--------
02bb 4f        ld      c,a
02bc 0600      ld      b,$00
02be 214507    ld      hl,$0745		;ROM location for 0-9 Font
02c1 09        add     hl,bc
02c2 eb        ex      de,hl
02c3 0608      ld      b,$08
-:
02c5 c5        push    bc
02c6 1a        ld      a,(de)
02c7 77        ld      (hl),a
02c8 13        inc     de
02c9 011000    ld      bc,$0010
02cc 09        add     hl,bc
02cd c1        pop     bc
02ce 10f5      djnz    -
02d0 c9        ret
;--------------------------------------


;--- another routine in VBlank -----------
Ingame_Handler_02d1:
     3a0886    ld      a,(ingame_mode)	;another "game" mode
02d4 21dd02    ld      hl,$02dd
02d7 87        add     a,a
02d8 cf        rst     08_Get_HL+A
02d9 23        inc     hl
02da 66        ld      h,(hl)
02db 6f        ld      l,a
02dc e9        jp      (hl)		;Jump off from here!


;a Jump table!
02dd: 2e5,322,339,36e

; if ingame_mode is 0...   ... possibly "dead" or "attract" mode.
02e5 3a0486    ld      a,(Joy_Press)	;Read (continuous) joystick presses
02e8 cb77      bit     6,a		;Start button?
02ea 201b      jr      nz,_start_game_0307		;if pressed, jump!
02ec 21cf86    ld      hl,wait_counter
02ef 7e        ld      a,(hl)
02f0 c604      add     a,$04
02f2 77        ld      (hl),a
02f3 0e00      ld      c,$00
02f5 f2fa02    jp      p,+		;(If (HL)+A was positive...)
02f8 0e02      ld      c,$02
+:
02fa 210a86    ld      hl,msg_num         ;This probably flashes "Press Start"
02fd 7e        ld      a,(hl)
02fe b9        cp      c
02ff c8        ret     z
;------
0300 71        ld      (hl),c
0301 cd4e02    call    $024e		;clear 6x20 rows...
0304 c3e500    jp      $00e5		;Return to main loop
;----------------------------------

_start_game_0307:
     f3        di
0308 cd7e03    call    Put_Map_On_Screen_037e
030b cd0c04    call    Fill_PlayerMonster_Defs_040c
030e fb        ei
030f 3e01      ld      a,$01		;set ingame 0 -> 1 (playing)
0311 320886    ld      (ingame_mode),a
0314 3e3c      ld      a,$3c		;I think this is a delay value
0316 32cf86    ld      (wait_counter),a
0319 3e03      ld      a,$03		;I think this says "READY" or sth.
031b 320a86    ld      (msg_num),a
031e cd4e02    call    $024e		;Print text message (level number too?)
0321 c9        ret
;--------------------------


; if ingame_mode is 1... wait only(?)
0322 21cf86    ld      hl,wait_counter
0325 35        dec     (hl)
0326 c0        ret     nz
;-----
0327 3e02      ld      a,$02		;OK, now ingame mode 2.
0329 320886    ld      (ingame_mode),a
032c af        xor     a
032d 32ce86    ld      (player_collided),a	;NOT HIT!
0330 3e04      ld      a,$04
0332 320a86    ld      (msg_num),a		;Print a message ("GO")
0335 cd4e02    call    $024e
0338 c9        ret
;-------------------------------


; if ingame_mode is 2...
0339 3a0b86    ld      a,(DotCount)	;It's like clockwork from here.  Check # of dots
033c a7        and     a
033d 2016      jr      nz,+
;---
033f 21cc86    ld      hl,LevelNum	;If dots are Zero, next level
0342 7e        ld      a,(hl)
0343 3c        inc     a
0344 fe0b      cp      $0b
0346 3001      jr      nc,++		;Don't increase internal game level if past $0B
0348 77        ld      (hl),a
++:
0349 23        inc     hl		;to "Level Display"
034a 3e01      ld      a,$01
034c 86        add     a,(hl)
034d 27        daa			;...stored in BCD
034e ca0703    jp      z,_start_game_0307 ;(max is 99, I guess)
0351 77        ld      (hl),a
0352 c30703    jp      _start_game_0307		;Restart from next level!
;------
+:
0355 3ace86    ld      a,(player_collided)	;Check if we hit an enemy
0358 a7        and     a
0359 c8        ret     z
;-----
035a 3e03      ld      a,$03			;If so, mode is now "DEAD" or flashing.
035c 320886    ld      (ingame_mode),a
035f 210109    ld      hl,$0901
0362 22cf86    ld      (wait_counter),hl	;"01" in counter, "09" in next byte.
0365 3e00      ld      a,$00			;Clear messages
0367 320a86    ld      (msg_num),a
036a cd4e02    call    $024e
036d c9        ret
;===========================================

; if ingame_mode is 3...
036e 21cf86    ld      hl,wait_counter
0371 35        dec     (hl)
0372 c0        ret     nz

0373 3610      ld      (hl),$10		;Wait counter & flash runs for 9 times, I reckon
0375 23        inc     hl
0376 35        dec     (hl)
0377 cad500    jp      z,$00d5		;Go back to attract mode if flashes all finished.
037a cd4a04    call    Flash_Screen_044a
037d c9        ret
;----------------------------------------


Put_Map_On_Screen_037e:
     3ea8      ld      a,$a8	;Dot count initialized!
0380 110b86    ld      de,DotCount
0383 12        ld      (de),a
0384 13        inc     de
0385 219507    ld      hl,$0795	;0795- (screen layout) gets written to RAM.
0388 01c000    ld      bc,$00c0 ;16 x 12 chars = $C0.
038b edb0      ldir
038d dd210c86  ld      ix,dot_wall_map	;Start at RAM dot map
0391 210080    ld      hl,$8000	;Start at screen RAM
0394 0e0c      ld      c,$0c	;96 pixel lines / 8 characters = 12 ($0C) char lines.
--:
0396 e5        push    hl
0397 0610      ld      b,$10	;Do a line of 16 8x8 screen characters
-:
0399 c5        push    bc
039a e5        push    hl
039b cdc003    call    _decode_1_map_tile_03c0
039e e1        pop     hl
039f c1        pop     bc
03a0 23        inc     hl
03a1 dd23      inc     ix
03a3 10f4      djnz    -
03a5 e1        pop     hl
03a6 118000    ld      de,$0080	;Go down 8 lines (1 character)
03a9 19        add     hl,de
03aa 0d        dec     c
03ab 20e9      jr      nz,--
03ad c9        ret
;=================================


;Routines used in Player/Enemy graphic masking.
03ae fe79      cp      $79		;This is the YX coord of player/enemy in 1 byte!
03b0 c8        ret     z
;---
03b1 fe7a      cp      $7a 		;If not at a certain position, drop down!
03b3 c8        ret     z                ;$79/$7A are where the Level number is printed.

03b4 dd210c86  ld      ix,dot_wall_map	;Point to map
03b8 5f        ld      e,a		;store our enemy/graphic position(?)
03b9 1600      ld      d,$00
03bb dd19      add     ix,de		;1 byte per tile on the map, so just add A to map addr.
03bd cdfa03    call    Point_Screen_YX_03fa
;------
_decode_1_map_tile_03c0:		;This decodes the map from ROM/RAM (in IX)
					;Wall/dot format in dot_wall_map+: 	76543210
					;(walls use bit CLEAR=wall)		??drRLDU
					;d=1 = dot, r=0 = redirect player
     111000    ld      de,$0010
03c3 dd4600    ld      b,(ix+$00)
03c6 0e00      ld      c,$00
03c8 cb58      bit     3,b		;if bit 3 cleared, there's a wall?
03ca 2002      jr      nz,+
03cc 0e01      ld      c,$01		;Rightmost pixel
+:
03ce cb50      bit     2,b		;bit 2 cleared, another wall...?
03d0 2002      jr      nz,+
03d2 cbf9      set     7,c		;Leftmost pixel
+:
03d4 af        xor     a
03d5 cb40      bit     0,b		;Bit 0 cleared...
03d7 2001      jr      nz,+
03d9 3d        dec     a		;makes a $FF, so entire (top?) row of pixels set.
+:
03da b1        or      c
03db 77        ld      (hl),a		;Do top wall, plus contiguous L,R walls.
03dc 19        add     hl,de            ;Go down 1 line
03dd 71        ld      (hl),c		;put in L/R walls
03de 19        add     hl,de
03df 71        ld      (hl),c
03e0 19        add     hl,de
03e1 af        xor     a
03e2 cb68      bit     5,b   		;Now check if dot is present
03e4 2802      jr      z,+
03e6 3e18      ld      a,$18		;if bit set, dot is present, so do pixel value
+:
03e8 b1        or      c		;OR with walls
03e9 77        ld      (hl),a           ; one
03ea 19        add     hl,de
03eb 77        ld      (hl),a   	; two lines tall
03ec 19        add     hl,de
03ed 71        ld      (hl),c
03ee 19        add     hl,de
03ef 71        ld      (hl),c
03f0 19        add     hl,de
03f1 af        xor     a
03f2 cb48      bit     1,b		;if bit 1 cleared, bottom wall
03f4 2001      jr      nz,$03f7
03f6 3d        dec     a
03f7 b1        or      c
03f8 77        ld      (hl),a		;Save that finally.
03f9 c9        ret
;======================================

Point_Screen_YX_03fa:
     f5        push    af
03fb e6f0      and     $f0		;Isolate Y-Value
03fd 6f        ld      l,a
03fe 2600      ld      h,$00
0400 29        add     hl,hl
0401 29        add     hl,hl
0402 29        add     hl,hl		;Multiply by 8
0403 f1        pop     af
0404 e60f      and     $0f              ;Isolate X-value
0406 110080    ld      de,$8000
0409 5f        ld      e,a
040a 19        add     hl,de		;combine them
040b c9        ret
;---------------------------------------------


Fill_PlayerMonster_Defs_040c:
     dd215508  ld      ix,$0855 ;get 4 pointers from here: 85D, 865, 86D, 875
0410 110087    ld      de,$8700	;Starting positions for player, monsters.
0413 0604      ld      b,$04
-:
0415 c5        push    bc
0416 dd6e00    ld      l,(ix+$00)
0419 dd6601    ld      h,(ix+$01)
041c 012000    ld      bc,$0020		;$085d -> $8700 x $20 bytes
041f edb0      ldir
0421 c1        pop     bc
0422 dd23      inc     ix
0424 dd23      inc     ix
0426 10ed      djnz    -
0428 3acc86    ld      a,(LevelNum)	;Levels 0..$B only supported
042b 87        add     a,a
042c 87        add     a,a
042d 87        add     a,a
042e 217d08    ld      hl,$087d		;Load blocks of monster speed & existence bytes...
0431 cf        rst     08_Get_HL+A
0432 dd210887  ld      ix,$8708
0436 112000    ld      de,$0020
0439 0604      ld      b,$04
-:
043b 7e        ld      a,(hl)
043c dd7700    ld      (ix+$00),a	;Save speed for character(?) and up to 3 monsters.
043f 23        inc     hl
0440 7e        ld      a,(hl)
0441 dd7701    ld      (ix+$01),a
0444 23        inc     hl
0445 dd19      add     ix,de
0447 10f2      djnz    -
0449 c9        ret
;=====================================


Flash_Screen_044a:
     210080    ld      hl,$8000
044d 010006    ld      bc,$0600
-:
0450 7e        ld      a,(hl)
0451 2f        cpl		;Complement all bytes on-screen.  Simple.
0452 77        ld      (hl),a
0453 23        inc     hl
0454 0b        dec     bc
0455 78        ld      a,b
0456 b1        or      c
0457 20f7      jr      nz,-
0459 c9        ret
;----------------------



Player_Movement_045a:
     3a0886    ld      a,(ingame_mode)
045d fe02      cp      $02		;If game's not running, exit.
045f c0        ret     nz
;----
0460 dd210087  ld      ix,$8700
0464 dd7e01    ld      a,(ix+$01)	;Check if player's X or Y position is at the edge
0467 e607      and     $07
0469 fe04      cp      $04
046b 2058      jr      nz,+
046d dd7e03    ld      a,(ix+$03)
0470 e607      and     $07
0472 fe04      cp      $04
0474 204f      jr      nz,+
0476 dd7e00    ld      a,(ix+$00)	;$8700/2 are X/Y movement/constraint flags?
0479 ddb602    or      (ix+$02)
047c 2047      jr      nz,+
047e dd7e07    ld      a,(ix+$07)
0481 219507    ld      hl,$0795		;Point to MAP data
0484 cf        rst     08_Get_HL+A
0485 3a0486    ld      a,(Joy_Press)
0488 4f        ld      c,a
0489 dd7e06    ld      a,(ix+$06)	;$8706 is player's direction, I think
048c 47        ld      b,a
048d e603      and     $03		;Test U/D direction
048f 3e03      ld      a,$03
0491 2802      jr      z,++		;and react HERE
0493 3e0c      ld      a,$0c
++:
0495 a6        and     (hl)		;MASK with map
0496 a1        and     c		;And MASK with Joypad presses, clever!
0497 2021      jr      nz,++		;If possible joy presses remain, jump down
0499 78        ld      a,b		;Direction back in A
049a a6        and     (hl)		;Mask out map impossibilities
049b a1        and     c		;This may or may not be zero
049c 2027      jr      nz,+		;if something remains, jump down
049e 78        ld      a,b		;Direction again
049f a6        and     (hl)		;Mask out ONLY with map
04a0 2023      jr      nz,+		;Jump down again if something remains
04a2 cb66      bit     4,(hl)		;Hmm... bit 4 is.... auto player redirection (Right?)
04a4 280a      jr      z,+++
04a6 dd360400  ld      (ix+$04),$00     ;If bit 4 is set, player can STOP there...(?)
04aa dd360500  ld      (ix+$05),$00
04ae 181b      jr      _skip_new_posn
+++:
04b0 78        ld      a,b		;Direction again
04b1 e603      and     $03		;Up/Down only
04b3 3e03      ld      a,$03
04b5 2802      jr      z,++++		;If not going U/D, then default to L/R.
04b7 3e0c      ld      a,$0c
++++:
04b9 a6        and     (hl)		;Mask out with map directions
++:
04ba dd7706    ld      (ix+$06),a	;New direction set.
04bd dd360000  ld      (ix+$00),$00	;Clear partial positions
04c1 dd360200  ld      (ix+$02),$00	;"	"	"
+:
04c5 cdcf04    call    Player_Speed_04cf
04c8 cdeb04    call    Plr_or_Enemy_New_Posn_04eb
_skip_new_posn:
04cb cd3705    call    Check_Dot_Eaten_0537
04ce c9        ret
;===========================


Player_Speed_04cf:
     218000    ld      hl,$0080		;Usual player speed
04d2 dd7e00    ld      a,(ix+$00)	;is player moving/constrained?
04d5 ddb602    or      (ix+$02)
04d8 200a      jr      nz,+
04da 3a0486    ld      a,(Joy_Press)
04dd cb67      bit     4,a		;Button 1 (Speed)
04df 2803      jr      z,+
04e1 210001    ld      hl,$0100         ;Make player move twice as fast if button 1 pressed
+:
04e4 dd7504    ld      (ix+$04),l	;Save current player speed temporarily (?)
04e7 dd7405    ld      (ix+$05),h
04ea c9        ret
;------------------------


Plr_or_Enemy_New_Posn_04eb:
     dd6e04    ld      l,(ix+$04)
04ee dd6605    ld      h,(ix+$05)	;Player speed
04f1 dd7e06    ld      a,(ix+$06)	;Direction we're facing
04f4 4f        ld      c,a
04f5 e605      and     $05              ;if either Up or Left facing, reverse speed
04f7 2807      jr      z,+
04f9 7d        ld      a,l
04fa 2f        cpl
04fb 6f        ld      l,a
04fc 7c        ld      a,h
04fd 2f        cpl
04fe 67        ld      h,a
04ff 23        inc     hl
+:
0500 110000    ld      de,$0000
0503 79        ld      a,c
0504 e60c      and     $0c		;Any Right or Left movement?
0506 2003      jr      nz,+
0508 110200    ld      de,$0002		;If Y-movement only, do that.
+:
050b dde5      push    ix
050d dd19      add     ix,de		;Point to EITHER X or Y position
050f dd5e00    ld      e,(ix+$00)
0512 dd5601    ld      d,(ix+$01)
0515 19        add     hl,de
0516 dd7500    ld      (ix+$00),l
0519 dd7401    ld      (ix+$01),h	;Set new position after adding speed.
051c dde1      pop     ix
051e cd2205    call    Obj_New_Char_Posn_0522
0521 c9        ret
;----------------------------
Obj_New_Char_Posn_0522:
     dd7e01    ld      a,(ix+$01)	;Get X-pos
0525 cb3f      srl     a
0527 cb3f      srl     a
0529 cb3f      srl     a		;*8
052b 4f        ld      c,a
052c dd7e03    ld      a,(ix+$03)	;Get coarse Y-pos
052f e6f8      and     $f8
0531 87        add     a,a
0532 81        add     a,c		;Combine them
0533 dd7707    ld      (ix+$07),a	;This is the objects' Character Position.
0536 c9        ret
;=================================


Check_Dot_Eaten_0537:
     dd7e01    ld      a,(ix+$01)	;Get X-pos
053a d602      sub     $02
053c e607      and     $07
053e fe05      cp      $05		;Check if right OVER dot.
0540 d0        ret     nc
;--------
0541 dd7e07    ld      a,(ix+$07)	;Get character position
0544 210c86    ld      hl,dot_wall_map
0547 cf        rst     08_Get_HL+A
0548 cb6e      bit     5,(hl)		;Check if dot is under player
054a c8        ret     z
;------
054b cbae      res     5,(hl)		;Delete that dot.
054d 210b86    ld      hl,DotCount
0550 35        dec     (hl)		;Decrease dot count too!
0551 c9        ret
;==========================



Enemy_Movement_0552:
     dd212087  ld      ix,$8720		;Up to 3 enemies at $8720/40/60
0556 0603      ld      b,$03		;Do 3 loops of this movement
-:
0558 c5        push    bc
0559 cd6505    call    _enemy_movement_0565
055c c1        pop     bc
055d 112000    ld      de,$0020
0560 dd19      add     ix,de
0562 10f4      djnz    -
0564 c9        ret
;-------------------

_enemy_movement_0565:
     3a0886    ld      a,(ingame_mode)
0568 fe02      cp      $02
056a c0        ret     nz
;-----------
056b dd6e08    ld      l,(ix+$08)	;Load Enemy's Speed
056e dd6609    ld      h,(ix+$09)	;if Zero, enemy doesn't exist!
0571 7d        ld      a,l
0572 b4        or      h
0573 c8        ret     z
;------------------------
0574 dd7e01    ld      a,(ix+$01)
0577 e607      and     $07
0579 fe04      cp      $04              ;If position is in centre of a row/column...
057b 2034      jr      nz,+
057d dd7e03    ld      a,(ix+$03)
0580 e607      and     $07
0582 fe04      cp      $04
0584 202b      jr      nz,+
0586 dd7e00    ld      a,(ix+$00)	;*exactly* in centre....
0589 ddb602    or      (ix+$02)
058c 2023      jr      nz,+
058e dd7e07    ld      a,(ix+$07)	;then pick another random direction for the enemy.
0591 219507    ld      hl,$0795		;Get Char position, point to Map,
0594 cf        rst     08_Get_HL+A	;Get possible movements from map.
0595 4f        ld      c,a
0596 210009    ld      hl,$0900
0599 111000    ld      de,$0010
059c dd7e06    ld      a,(ix+$06)	;Get enemy Direction
-:
059f 0f        rrca
05a0 3803      jr      c,++		;direction will always be 01/02/04/08
05a2 19        add     hl,de		;$0900,$0910,$0920,$0930
05a3 18fa      jr      -
++:
05a5 d7        rst     $10	;Get Random Value in A and Rand Seed
05a6 e60b      and     $0b      ;limit it in some weird way
05a8 cf        rst     08_Get_HL+A
-:
05a9 7e        ld      a,(hl)
05aa a1        and     c	;mask out movement from map and random result
05ab 23        inc     hl
05ac 28fb      jr      z,-	;if no possible movements, get following byte...
05ae dd7706    ld      (ix+$06),a	;And save as new direction
+:
05b1 cdbb05    call    $05bb	;Duplicate enemy's speed variable
05b4 cdeb04    call    Plr_or_Enemy_New_Posn_04eb
05b7 cdc805    call    Check_Collision_05c8
05ba c9        ret


;Duplicate enemy's speed variable
05bb dd6e08    ld      l,(ix+$08)
05be dd6609    ld      h,(ix+$09)
05c1 dd7504    ld      (ix+$04),l
05c4 dd7405    ld      (ix+$05),h
05c7 c9        ret
;-------------------------

Check_Collision_05c8:
     2a0087    ld      hl,($8700)	;Get PLAYER'S X-Position
05cb dd5e00    ld      e,(ix+$00)	;Get Enemy's X-Position
05ce dd5601    ld      d,(ix+$01)
05d1 a7        and     a
05d2 ed52      sbc     hl,de		;PX - EX  (range $-7800..$7800)
05d4 110006    ld      de,$0600         ;offset it?
05d7 19        add     hl,de
05d8 7c        ld      a,h              ;If (PX-EX)+$600 = 0, quit!
05d9 b5        or      l
05da c8        ret     z
;----
05db 11000c    ld      de,$0c00		;IF |(PX-EX)| > $600, quit (I think)
05de a7        and     a
05df ed52      sbc     hl,de
05e1 d0        ret     nc
;--------
05e2 2a0287    ld      hl,($8702)	;Get PLAYER'S Y-Pos.
05e5 dd5e02    ld      e,(ix+$02)	;And enemy's too
05e8 dd5603    ld      d,(ix+$03)
05eb a7        and     a
05ec ed52      sbc     hl,de
05ee 110006    ld      de,$0600		;Same math
05f1 19        add     hl,de
05f2 7c        ld      a,h
05f3 b5        or      l
05f4 c8        ret     z
;---------
05f5 11000c    ld      de,$0c00
05f8 a7        and     a
05f9 ed52      sbc     hl,de
05fb d0        ret     nc	;At this point Player and Enemy overlap by ^6 pixels...
;----
05fc 3e01      ld      a,$01		;This counts as a collision!
05fe 32ce86    ld      (player_collided),a
0601 c9        ret
;------------------------------



;0602-06xx 	;RAM/ROM chars
;0795~0942 ;Screen and other data
;0900-093F ; "random?" direction data

0943 d67c      		;This may be the 2nd CHECKSUM byte


; Check MODE, init TEST MODE...  Called by the main loop.
0945 3af086    ld      a,(MODE_Num)	;Check status of demo mode / test modes?
0948 a7        and     a
0949 c28109    jp      nz,Jump_to_Table1_0981         ;if not in test mode (??), check coin button...
094c 3a0586    ld      a,(Joy_Trig)
094f cb7f      bit     7,a		;Check COIN Button pressed!
0951 c8        ret     z                ;If pressed, continue
;--------
0952 21f186    ld      hl,Cursor_val
0955 3603      ld      (hl),$03		;bottommost cursor pos.
0957 23        inc     hl
0958 3a0386    ld      a,(Palette)	;Store the current palette (probably not needed?)
095b f680      or      $80
095d 77        ld      (hl),a           ;Put it in $86f2
;--
095e 21f086    ld      hl,MODE_Num
0961 3602      ld      (hl),$02         ;increase mode
0963 af        xor     a
0964 320886    ld      (ingame_mode),a
0967 3e87      ld      a,$87            ;Black BG, White chars
0969 320386    ld      (Palette),a
096c 110000    ld      de,$0000		;Zero out $85FF-- in the fastest way possible (?)
096f cd9d0b    call    Fast_Clear_Screen_0b9d		;Pushes DE many times!
0972 dd21be0b  ld      ix,$0bbe		;Text location for test mode screen
0976 010306    ld      bc,$0603
0979 3e09      ld      a,$09
097b cd440b    call    Print_Text_Lines_xB_0b44
097e c3e500    jp      $00e5		;Return to main loop
;================================


;/////////  Mode Jump Table! ////////////
Jump_to_Table1_0981:
     21500c    ld      hl,$0c50		;jump table locations
0984 3af086    ld      a,(MODE_Num)
0987 cf        rst     08_Get_HL+A	;Get byte at HL+A
0988 23        inc     hl
0989 66        ld      h,(hl)		;Read what's at the table & jump to it!
098a 6f        ld      l,a
098b e9        jp      (hl)


;Jump table at $0C50, based on MODE:
; 0  $0040	;Impossible; maybe data used in preceding table?
; 2  $098c      ;TEST menu
; 4  $09aa
; 6  $09b6
; 8  $0a65
; A  $0a7a
; C  $0a83
; E  $0a99 (x3)
; 14 $0aeb
; 16 $0b19
; 18 $0af0
;/////////////////////////////////////////


; MODE 2 - TEST Menu
098c 210586    ld      hl,Joy_Trig
098f cb76      bit     6,(hl)		;Start pressed?
0991 c43a0b    call    nz,$0b3a		;Increase cursor pos
0994 cb7e      bit     7,(hl)		;Coin pressed?
0996 cae500    jp      z,$00e5		;If not, loop
0999 3e04      ld      a,$04
099b 32f086    ld      (MODE_Num),a	;mode 4, but...
099e 21560c    ld      hl,$0c56
09a1 3af186    ld      a,(Cursor_val)   ;get cursor, add to $C56, JUMP!
09a4 87        add     a,a
09a5 cf        rst     08_Get_HL+A
09a6 23        inc     hl
09a7 66        ld      h,(hl)
09a8 6f        ld      l,a
09a9 e9        jp      (hl)	;jump to 9b6, a65, a7a, or a83.
;-----------

; MODE 4		;The main TEST cores...
09aa 215e0c    ld      hl,$0c5e
09ad 3af186    ld      a,(Cursor_val)
09b0 87        add     a,a
09b1 cf        rst     08_Get_HL+A
09b2 23        inc     hl
09b3 66        ld      h,(hl)
09b4 6f        ld      l,a
09b5 e9        jp      (hl)	;$0a99 x 3 (??)
;---------------------------

; MODE 6 / TEST menu-> RAMTEST
09b6 3af286    ld      a,($86f2)	;Temp palette storage.
09b9 08        ex      af,af'
09ba 0640      ld      b,$40
09bc 210000    ld      hl,$0000
09bf f3        di                       ;Interrupts off for this!
09c0 310088    ld      sp,$8800		;Clear ALL RAM.
-:
09c3 e5        push    hl
09c4 e5        push    hl
09c5 e5        push    hl
09c6 e5        push    hl
09c7 e5        push    hl
09c8 e5        push    hl
09c9 e5        push    hl
09ca e5        push    hl
09cb e5        push    hl
09cc e5        push    hl
09cd e5        push    hl
09ce e5        push    hl
09cf e5        push    hl
09d0 e5        push    hl
09d1 e5        push    hl
09d2 e5        push    hl
09d3 10ee      djnz    -
09d5 0600      ld      b,$00
--:
09d7 210080    ld      hl,$8000
09da 110008    ld      de,$0800
-:
09dd 34        inc     (hl)		;Fill all RAM with all values 0-$ff
09de 23        inc     hl
09df 1b        dec     de
09e0 7a        ld      a,d
09e1 b3        or      e
09e2 20f9      jr      nz,-
09e4 10f1      djnz    --
09e6 210080    ld      hl,$8000
09e9 110008    ld      de,$0800
-:
09ec af        xor     a
09ed b6        or      (hl)
09ee c2f909    jp      nz,_RAMfail		;Test ALL RAM for a nonzero value
09f1 23        inc     hl
09f2 1b        dec     de
09f3 7a        ld      a,d
09f4 b3        or      e
09f5 20f5      jr      nz,-
09f7 1805      jr      _RAMpass
_RAMfail:
09f9 3e01      ld      a,$01    	;If RAM had failed, how would putting a flag in RAM help?
09fb 320086    ld      ($8600),a	;Yeah, I'm being anal, but if this were an important prog...
_RAMpass:
09fe 310000    ld      sp,$0000		;Stack will start at ROM $0 and move up
0a01 210000    ld      hl,$0000		;Checksum storage
0a04 01a004    ld      bc,$04a0		;$940 bytes to sum
-:
0a07 d1        pop     de
0a08 19        add     hl,de
0a09 0b        dec     bc
0a0a 78        ld      a,b
0a0b b1        or      c
0a0c 20f9      jr      nz,-
0a0e ed5b4309  ld      de,($0943)
0a12 ed52      sbc     hl,de
0a14 08        ex      af,af'			;This seems to be a nonsensical sequence?
0a15 19        add     hl,de
0a16 08        ex      af,af'			;Somebody tell me otherwise
0a17 2805      jr      z,_ROM_pass
0a19 210086    ld      hl,$8600
0a1c cbce      set     1,(hl)
_ROM_pass:
0a1e 21f086    ld      hl,MODE_Num
0a21 3604      ld      (hl),$04
0a23 23        inc     hl
0a24 3600      ld      (hl),$00			;Set cursor back to 0
0a26 23        inc     hl
0a27 08        ex      af,af'			;restore palette?
0a28 77        ld      (hl),a
0a29 310088    ld      sp,$8800
0a2c dd212b0c  ld      ix,$0c2b			;"MEMORY TEST"
0a30 010207    ld      bc,$0702                 ;7 lines, column 2
0a33 3e09      ld      a,$09			;row 2 (7+2)
0a35 cd440b    call    Print_Text_Lines_xB_0b44
0a38 dd21450c  ld      ix,$0c45			;"GOOD"
0a3c 3a0086    ld      a,($8600)
0a3f cb47      bit     0,a
0a41 2804      jr      z,+
0a43 dd214a0c  ld      ix,$0c4a			;"BAD"
+:
0a47 110908    ld      de,$0809			;Row 8, Col 9
0a4a cd530b    call    Print_1_Text_Line_0b53
0a4d dd21450c  ld      ix,$0c45			;"GOOD"
0a51 3a0086    ld      a,($8600)
0a54 cb4f      bit     1,a
0a56 2800      jr      z,+			;BAD never printed!!!
+:
0a58 110905    ld      de,$0509
0a5b cd530b    call    Print_1_Text_Line_0b53
0a5e cd4701    call    Read_Joy_0147
0a61 fb        ei
0a62 c3e500    jp      $00e5
;-------------------------------------------



; MODE 8 / TEST menu -> Joytest
0a65 110000    ld      de,$0000
0a68 cd9d0b    call    Fast_Clear_Screen_0b9d
0a6b dd21f10b  ld      ix,$0bf1			;"INPUT TEST"...
0a6f 01020a    ld      bc,$0a02
0a72 3e0b      ld      a,$0b
0a74 cd440b    call    Print_Text_Lines_xB_0b44
0a77 c3e500    jp      $00e5			;Return to main loop

; MODE A
0a7a 11ffff    ld      de,$ffff			;Turn screen all white
0a7d cd9d0b    call    Fast_Clear_Screen_0b9d
0a80 c3e500    jp      $00e5


; MODE C / TEST Menu->EXIT
0a83 21f086    ld      hl,MODE_Num
0a86 3600      ld      (hl),$00		;Back to MODE 0
0a88 23        inc     hl
0a89 3600      ld      (hl),$00		;Menu num 0
0a8b 23        inc     hl
0a8c 7e        ld      a,(hl)		;Restore ingame palette
0a8d 320386    ld      (Palette),a
0a90 110000    ld      de,$0000
0a93 cd9d0b    call    Fast_Clear_Screen_0b9d
0a96 c3e500    jp      $00e5		;jump to main loop
;----------------------------------


; MODE E, 10, 12
0a99 3a0586    ld      a,(Joy_Trig)
0a9c cb7f      bit     7,a
0a9e cae500    jp      z,$00e5		;If no COIN button pressed, just loop around
0aa1 3e02      ld      a,$02
0aa3 32f086    ld      (MODE_Num),a     ;Back to mode 2.
0aa6 cd3a0b    call    $0b3a		;Increase cursor pos.
0aa9 c35e09    jp      $095e            ;Return to INIT test mode...
;=========================================



;VBlank routine, continued.
0aac 210786    ld      hl,VBlank_Pass
0aaf 35        dec     (hl)
0ab0 3af086    ld      a,(MODE_Num)
0ab3 a7        and     a
0ab4 ca6801    jp      z,$0168		;If not in-game, drop down...
;----
0ab7 fe02      cp      $02
0ab9 cac80a    jp      z,+
0abc 21640c    ld      hl,$0c64
0abf 3af186    ld      a,(Cursor_val)	;Test mode depending on cursor...
0ac2 87        add     a,a
0ac3 cf        rst     08_Get_HL+A
0ac4 23        inc     hl
0ac5 66        ld      h,(hl)
0ac6 6f        ld      l,a
0ac7 e9        jp      (hl)
;-------

+:
;MODE 2 TEST menu
0ac8 0604      ld      b,$04
-:
0aca dd214e0c  ld      ix,$0c4e		;">" possibly
0ace 3af186    ld      a,(Cursor_val)
0ad1 4f        ld      c,a
0ad2 3e04      ld      a,$04
0ad4 90        sub     b
0ad5 b9        cp      c    		;If loop # matches cursor val, keep ">"
0ad6 cadd0a    jp      z,+
0ad9 dd21500c  ld      ix,$0c50		;" " space
+:
0add c5        push    bc
0ade 3e09      ld      a,$09
0ae0 90        sub     b
0ae1 57        ld      d,a
0ae2 1e02      ld      e,$02
0ae4 cd530b    call    Print_1_Text_Line_0b53
0ae7 c1        pop     bc
0ae8 10e0      djnz    -
0aea c9        ret
;======================================

; MODE 14 (RAM test, waste time)
0aeb 0600      ld      b,$00
-:
     10fe      djnz    -
0aef c9        ret
;---------------------

; MODE 18 (Colour test - part of VBlank routine, hmmm)
0af0 3abc0b    ld      a,($0bbc)
0af3 cd900b    call    Delay_xA_0b90
0af6 3e01      ld      a,$01		;RED
0af8 d300      out     (Pal_Register),a
0afa 3abd0b    ld      a,($0bbd)
0afd cd900b    call    Delay_xA_0b90
0b00 3e02      ld      a,$02		;GREEN
0b02 d300      out     (Pal_Register),a
0b04 3abd0b    ld      a,($0bbd)
0b07 cd900b    call    Delay_xA_0b90
0b0a 3e04      ld      a,$04		;BLUE
0b0c d300      out     (Pal_Register),a
0b0e 3abd0b    ld      a,($0bbd)
0b11 cd900b    call    Delay_xA_0b90
0b14 3e07      ld      a,$07		;WHITE
0b16 d300      out     (Pal_Register),a
0b18 c9        ret


; MODE 16 - Joystick Test
0b19 0608      ld      b,$08            ;8 buttons in a loop
0b1b 3a0486    ld      a,(Joy_Press)
-:
0b1e dd21230c  ld      ix,$0c23		;"ON "
0b22 07        rlca
0b23 da2a0b    jp      c,+
0b26 dd21270c  ld      ix,$0c27		;"OFF"
+:
0b2a f5        push    af
0b2b c5        push    bc
0b2c 3e0b      ld      a,$0b		;B-1..8
0b2e 90        sub     b
0b2f 57        ld      d,a		;Change Line num.
0b30 1e0a      ld      e,$0a
0b32 cd530b    call    Print_1_Text_Line_0b53
0b35 c1        pop     bc
0b36 f1        pop     af
0b37 10e5      djnz    -
0b39 c9        ret
;=========================


;Increase Cursor Pos.
0b3a 3af186    ld      a,(Cursor_val)
0b3d 3c        inc     a
0b3e e603      and     $03
0b40 32f186    ld      (Cursor_val),a
0b43 c9        ret
;--------------


; Prints multiple text strings pointed to in IX
; INPUTS: B= # lines/strings to print, C= starting column #, A = starting row + #lines.
Print_Text_Lines_xB_0b44:
-:
0b44 f5        push    af
0b45 c5        push    bc
0b46 90        sub     b		;Why they need to do it this way, who knows?
0b47 57        ld      d,a              ;Auto math, I guess.
0b48 59        ld      e,c
0b49 cd530b    call    Print_1_Text_Line_0b53
0b4c dd23      inc     ix		;above just quit pointing at Zero terminator
0b4e c1        pop     bc
0b4f f1        pop     af
0b50 10f2      djnz    -		;Loop for # of text strings
0b52 c9        ret
;--------


; Prints single text string pointed to in IX
; INPUTS: E= starting column #, D = starting row.
Print_1_Text_Line_0b53:
     2600      ld      h,$00		;Point to correct screen memory address
0b55 6a        ld      l,d
0b56 1600      ld      d,$00
0b58 29        add     hl,hl
0b59 29        add     hl,hl
0b5a 29        add     hl,hl
0b5b 29        add     hl,hl
0b5c 29        add     hl,hl
0b5d 29        add     hl,hl
0b5e 29        add     hl,hl
0b5f 19        add     hl,de
0b60 110080    ld      de,$8000
0b63 19        add     hl,de
0b64 e5        push    hl
0b65 fde1      pop     iy
--:
0b67 dd7e00    ld      a,(ix+$00)	;Get text char from (IX)
0b6a a7        and     a		;If it's Zero, just quit!
0b6b c8        ret     z
;----
0b6c c6c1      add     a,$c1		;Change ASCII offset
0b6e 07        rlca
0b6f 07        rlca
0b70 07        rlca 			;Multiply by 8
0b71 5f        ld      e,a
0b72 1600      ld      d,$00
0b74 216a0c    ld      hl,$0c6a		;Start of FONT data
0b77 19        add     hl,de
0b78 eb        ex      de,hl
0b79 fde5      push    iy
0b7b e1        pop     hl		;Screen address back in HL
0b7c 0608      ld      b,$08
-:
0b7e c5        push    bc
0b7f 1a        ld      a,(de)		;Get font data for 1 chr
0b80 13        inc     de
0b81 77        ld      (hl),a
0b82 011000    ld      bc,$0010         ;Point 1 pixel line downwards
0b85 09        add     hl,bc
0b86 c1        pop     bc
0b87 10f5      djnz    -
0b89 fd23      inc     iy		;Next screen column!
0b8b dd23      inc     ix		;Next text char!
0b8d c3670b    jp      --
;==========================================



Delay_xA_0b90:			;A delay based on A register
     47        ld      b,a
--:
0b91 210200    ld      hl,$0002		;A fixed internal delay time
-:
0b94 2b        dec     hl
0b95 7d        ld      a,l
0b96 b4        or      h
0b97 c2940b    jp      nz,-
0b9a 10f5      djnz    --
0b9c c9        ret



Fast_Clear_Screen_0b9d:
     0630      ld      b,$30		;48 times 16 pushes x 2 bytes = 1536 ($600) bytes written
0b9f 210000    ld      hl,$0000
0ba2 39        add     hl,sp		;Copy current stack pointer to HL
0ba3 f3        di			;so interrupts off is necessary!
0ba4 310086    ld      sp,$8600		;Start at end of screen mem and work backwards.
0ba7 d5        push    de
0ba8 d5        push    de
0ba9 d5        push    de
0baa d5        push    de
0bab d5        push    de
0bac d5        push    de
0bad d5        push    de
0bae d5        push    de
0baf d5        push    de
0bb0 d5        push    de
0bb1 d5        push    de
0bb2 d5        push    de
0bb3 d5        push    de
0bb4 d5        push    de
0bb5 d5        push    de
0bb6 d5        push    de
0bb7 10ee      djnz    $0ba7
0bb9 f9        ld      sp,hl		;Restore stack
0bba fb        ei
0bbb c9        ret
;=================================


0bbc e0		;Delay for top bar
0bbd 94		;Delay for bottom 3 bars

0bbe... ;text strings from here

0c4e 5d		;Cursor "> "
0c4f 00


0c50:				;A routine jump table
; $0040, $098c, $09aa, $09b6, $0a65, $0a7a, $0a83, $0a99 (x3), $0aeb, $0b19. $0af0

; FONT tiles to end the program