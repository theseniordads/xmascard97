* Senior Dads "Xmas Card 96... er 97" demo (Atari Falcon 030)


FINAL_VERSION		; < Comment for labels and faster assembly

	include	includes\xmas_mac.s	; Vital macros

	IFD	FINAL_VERSION
	jmp	start

	dc.b	'You damn ripper!!! Well, It''s your problem because '
	dc.b	'in attempting to rip this great demo '
	dc.b	'you have released the SENIOR SAD RIPPERS VIRUS on your '
	dc.b	'system! It''s a virus which infects your keyboard chip '
	dc.b	'and waits until the year 2000 and then DELETES YOUR '
	dc.b	'HARD DRIVE!!!! This also recognises Richard Karsmakkers '
	dc.b	'virus killer and DELETES THAT AS WELL! '
	dc.b	'It also infects email and spreads itself to your friends!!! '
	dc.b	'And it adds the string "I am a twat and I tried to mess with '
	dc.b	'the coding genii that are the SENIOR DADS niavely thinking '
	dc.b	'I could somehow equal their unequalable coding feats!" '
	dc.b	'to every email you send!!!   '
	dc.b	'It can also jump computer species like BSE and INFECT YOUR PC AS WELL!!! '
	dc.b	'The only way to reverse this stealth polymorphic virus '
	dc.b	'from the keyboard ram is to type the string "I am '
	dc.b	'really sorry SENIOR DADS for being so base as to think '
	dc.b	'I could rip your brilliant work off for my own nefarious '
	dc.b	'purposes. I am a very low piece of human garbage indeed!" '
	dc.b	'forty two times! '
	even

	opt	d-
	ENDC

start	init_prog

	save_old_stack
	lea	new_stack,sp
	bsr	save_ints
	bsr	set_ints
	bsr	main_demo
	bsr	ret_ints
	restore_old_stack
	rts

* SAVE INTERRUPTS

save_ints
	jsr	save_keyints
	getphys		oldphys		{
	getlog		oldlog		{ - Save screen details
	getrez_falc	oldrez		{
	movem.l	c16regs.w,d0-d7		; Save ST colours
	movem.l	d0-d7,old_c16cols	;
	move.w	#256-1,d0		{ Save Falcon colours
	lea	c256regs.w,a0		{
	lea	old_c256cols,a1		{
.loop	move.l	(a0)+,(a1)+		{
	dbf	d0,.loop		{
	move.l	vbl.w,old_vbl		; Save old vbl counter
	rts

* SETUP VARIABLES AND INTERRUPTS

set_ints
	bsr	days_until_xmas
	keyclick_off			; Switch off key click
;	bsr	speaker_ask		; Ask viewer about speaker on/off
	jsr	set_keyints		; Set up keyboard interrupts
	sf	abort_demo		; Set abort demo variables!
	sf	prime_abort_sequence
	movem.l	front,d0-d1		{
	clr.b	d0			{-- Set up screen defaults
	clr.b	d1			{
	movem.l	d0-d1,front		{
	bsr	prepare_vga		; Check for VGA monitors
	jsr	get_8x8_font		; "Precalc" 8X8 font
	jsr	convert_8x8_font	; "Precalc" trucol 8X8 font
	bsr	conv_bomb		; "Precalc" trucol "bomb"
	bsr	conv_main_font		; "Precalc" trucol main font
	lea	main_module,a0		; depack main module
	jsr	depack_module
	move.l	#vbl_timer,vbl.w	; Slot in custom vbl
	wait_vbl			; Wait a vbl..
	bsr	swap_screens
	rts

* RESTORE INTERRUPTS AND OTHER STUFF.

ret_ints
	jsr	ret_keyints			; Restore keyboard
      	module_off				; Module off (If on already)
	move.l	old_vbl,vbl.w			; Restore old vbl
	setrez_falc	oldrez,oldphys,oldlog	; restore screen
	movem.l	old_c16cols,d0-d7		; Restore ST colours
	movem.l	d0-d7,c16regs.w			;
	move.w	#256-1,d0			{ Restore Falcon colours
	lea	old_c256cols,a0			{
	lea	c256regs.w,a1			{
.loop	move.l	(a0)+,(a1)+			{
	dbf	d0,.loop			{
	keyclick_on
	rts

* Check if VGA monitor is running, and alter mode change
; data accordingly.

prepare_vga
	if_not_monitor.s	#vga_monitor,.exit	; If RGB, no change needed
	lea	trucol_inf,a1				; ... otherwise copy over VGA data
	lea	trucol_vga_inf,a0
	move.w	#((end_infs-trucol_inf)/2)-1,d0
.loop1	move.w	(a0)+,(a1)+
	dbf	d0,.loop1
.exit	rts

* MAIN DEMO.

main_demo
	demo_part	do_days_until		; "XX days till..."
	demo_part	do_presents		; Initial pic and "presents" flashing bit.
	demo_part	do_title_pic		; Show "Xmas Card 96" pic.	
	demo_part	do_santa_bit		; Show "Santa story".	
	demo_part	do_jingle_bells		; Show "Jingle Bells".
	demo_part	do_greets		; Show greets.
	demo_part	do_frosty		; "Frosty the snowman!".
	demo_part	do_wish_xmas		; "Wish it could be Xmas every day".
	demo_part	do_rudolf		; Rudolf cull.
	demo_part	do_endpart		; end bit
	demo_part	do_hidden		; Hidden screen
.abort_exit
	rts


do_days_until
	bsr	st_lorez		; Go ST low rez (just in  case)
	bsr	fadeoff_16col 		; Special Senior Dads fade!
	lea	xmas_message,a0
	if_false.s	xmas_today,.no_xmas
	lea	xmas_greeting,a0
.no_xmas
	move.l	front,a1
	moveq	#0,d0
	moveq	#60,d1
	moveq	#0,d2
	move.l	#$777,d3
	bsr	do_titles 		; Special Senior Dads text displayer!
	wait_for	#100
	module_on	#main_module	; Switch module player on
	rts

days_until_xmas:
	sf	xmas_today
	move.w	#$2a,-(sp)
	trap	#1
	addq.l	#2,sp
	move.l	d0,d1
	andi.w	#%0000000000011111,d0		; Get date
	andi.w	#%0000000111100000,d1		; Get month
	lsr.w	#5,d1
	subq.l	#1,d1
	moveq	#0,d2
	lea	.month_table,a0
.loop	tst.w	d1
	beq.s	.endloop
	add.w	(a0)+,d2
	subq.l	#1,d1
	bra.s	.loop
.endloop
	add.l	d0,d2	
	move.l	#31+28+31+30+31+30+31+31+30+31+30+25,d3
	sub.w	d2,d3
	bgt.s	.no_minus
	beq.s	.xmas_today
	add.w	#365,d3
	bra.s	.no_minus
.xmas_today
	st	xmas_today
.no_minus
	lea	xmas_digits+3,a0
	moveq	#3-1,d0
.dloop	divu	#10,d3
	swap	d3
	moveq	#0,d1
	move.b	.leading,d1
	tst.w	d3
	beq.s	.dblank
	move.b	#' ',.leading
	move.w	#'0',d1
	add.w	d3,d1
.dblank
	move.b	d1,-(a0)
	clr.w	d3
	swap	d3
	dbf	d0,.dloop
	rts
.month_table
	dc.w	31		; Jan
	dc.w	28		; Feb
	dc.w	31		; Mar
	dc.w	30		; Apr
	dc.w	31		; May
	dc.w	30		; Jun
	dc.w	31		; Jul
	dc.w	31		; Aug
	dc.w	30		; Sep
	dc.w	31		; Oct
	dc.w	30		; Nov
.leading	dc.b	'0'
	even

xmas_today	ds.b	1
	even
xmas_message	dc.b	'Onely',13
xmas_digits	dc.b	'000 days',13
		dc.b	' untill..',0
	even
xmas_greeting	dc.b	'Merry Xmas',13
		dc.b	'demo fans!',0
	even

* Show "Senior Dads present.." pic, then do flashing "presents.." bit.

do_presents
	bsr	st_lorez		; Go ST low rez (just in  case)
	lea	presents,a6		; Show "Senior dads piccy"
	bsr	disp_16col_pic 		; Special Senior Dads pic display method!
	wait_until_mod_pos	#1,#0	; Wait until the beat kicks in....
	bsr	fadeoff_16col 		; Special Senior Dads fade!
	lea	t_presents,a0
	move.l	front,a1
	moveq	#4,d0
	moveq	#120,d1
	moveq	#0,d2
	move	#$700,d3
	bsr	do_titles 		; Special Senior Dads text displayer!
	wait_until_mod_pos	#2,#0	; Wait until the "Move your ass to the Senior Dads!" bit.
.abort_exit
	rts

* DO "XMAS CARD 96" TITLE PIC- if it looks simple, that's because the
; subroutine that displays the trucolour picture used to be a part of
; this bit!

do_title_pic
	set_asavmode	#trucol_inf 	; Zap into trucol lores using hardware regs
	set_vidaddr	front		; Now you see a load of rubbish where the lo-res screen used to be!
	lea	title_pic,a6		; Show "Air Dirt Demo
	bsr	show_trucol 		; Special Senior Dads Trucol pic displayer!
	wait_until_mod_pos	#4,#0	; Wait until next bit of that chunky choon!
.abort_exit
	rts

* Do Santa story.

do_santa_bit:
	bsr	st_lorez		; Go ST low rez (just in  case)
	lea	snowfall_pic,a6		; Show Snowfall scene
	bsr	disp_16col_pic 		; Special Senior Dads pic display method!
.loop1	moveq	#4,d0
	bsr	snowfall
	set_mod_breakpoint	#2
	wait_until_mod_breakpoint
	if_not_at_mod_pos.s	#5,#0,.loop1
	lea	t_birdplane,a0
	move.l	front,a1
	moveq	#0,d0
	moveq	#50,d1
	moveq	#0,d2
	move	#$70,d3
	bsr	do_titles 		; Special Senior Dads text displayer!
	wait_until_mod_pos	#5,#32
	lea	santa1,a6		; Show "Santa"
	bsr	disp_16col_pic 		; Special Senior Dads pic display method!
.loop2	moveq	#4,d0
	bsr	snowfall
	set_mod_breakpoint	#2
	wait_until_mod_breakpoint
	if_not_at_mod_pos.s	#6,#48,.loop2
	lea	t_crump,a0
	move.l	front,a1
	moveq	#0,d0
	move.l	#140,d1
	moveq	#0,d2
	move	#$77,d3
	bsr	do_titles 		; Special Senior Dads text displayer!
	wait_until_mod_pos	#7,#16
	lea	santa2,a6		; Show "Santa" pt 2
	bsr	disp_16col_pic 		; Special Senior Dads pic display method!
.loop3	moveq	#4,d0
	bsr	snowfall
	set_mod_breakpoint	#2
	wait_until_mod_breakpoint
	if_not_at_mod_pos.s	#8,#16,.loop3
	lea	t_hohoho,a0
	move.l	front,a1
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move	#$704,d3
	bsr	do_titles 		; Special Senior Dads text displayer!
	wait_until_mod_pos	#8,#50
.abort_exit
	rts

snowfall:
	lea	c16regs,a0
	lea	(a0,d0.w*2),a0
	move.l	(a0),d7
	swap	d7
	move.l	d7,(a0)
.abort_exit
	rts

t_birdplane
	dc.b	'  Is it a ',13
	dc.b	'bird?  Is ',13
	dc.b	'it a ',13
	dc.b	'PLAIN?',0

t_crump
	dc.b	'NO! ',13
	dc.b	'It''s...',13
	dc.b	' CRUMP!',0

t_hohoho
	dc.b	'"HO HO',13
	dc.b	'  HO!"',0
	even

* The Jingle bells bit.

do_jingle_bells:
	set_asavmode	#trucol_inf 	; Zap into trucol lores using hardware regs
	set_vidaddr	front		; Now you see a load of rubbish where the lo-res screen used to be!
	lea	ehoh_pic,a6		; Show "Telegrumpies"
	bsr	show_trucol 		; Special Senior Dads Trucol pic displayer!
	clr.l	c256regs.w		; Do black border
	wait_until_mod_pos	#9,#42	; Wait a bit!
	move.l	#-1,c256regs.w		; Do white border
	moveq	#0,d0
	moveq	#0,d1
	move.l	front,a1
	lea	t_noborder,a0
	bsr	trucol_print
	wait_until_mod_pos	#9,#50	; Wait until next bit of that chunky choon!
	bsr	.prepare_animate_bells	; Prepare the animation!
	lea	jingle1,a6		; Show Jingle Bells "Precalculating" picture.
	bsr	disp_16col_pic 		; Special Senior Dads pic display method!
.loop1	bsr	.animate_bells
	if_not_at_mod_pos.s	#11,#36,.loop1
	lea	jingle2,a6		; Show Jingle Bells "Sleigh" picture.
	bsr	disp_16col_pic 		; Special Senior Dads pic display method!
.loop2	moveq	#1,d0
	bsr	snowfall
	set_mod_breakpoint	#2
	wait_until_mod_breakpoint
	if_not_at_mod_pos.s	#11,#60,.loop2
.loop3	moveq	#1,d0
	bsr	snowfall
	bsr	scroll_landscape
	set_mod_breakpoint	#2
	sf	.bombs
.loop3a	move.l	front,a6
	adda.l	#(180*160)+6,a6
	bsr	draw_scroller
	wait_for	#0
	if_not_at_mod_pos.s	#14,#20,.no_bombs
	if_true.s	.bombs,.no_bombs
	moveq	#9,d0
	bsr	do_bombs
	move.w	#9-1,d0
	move.l	front,a0
	lea	jingle2+34,a1
	adda.l	#160*100,a0
	adda.l	#(160*100)+6,a1
.cb1	move.l	a0,a2
	move.l	a1,a3
	move.w	#16-1,d1
.cb2	move.w	(a2),(a3)
	lea	160(a2),a2
	lea	160(a3),a3
	dbf	d1,.cb2
	addq.l	#2,a0
	addq.l	#2,a1
	dbf	d0,.cb1
	st	.bombs
.no_bombs
	if_not_at_mod_breakpoint	.loop3a
	if_not_at_mod_pos	#15,#20,.loop3
.abort_exit
	rts
.bombs	ds.b	1
	even

.prepare_animate_bells:
	lea	.abcol1+(8*2),a6
	move.l	a6,a0
	move	#3-1,d0
.pab1	move	#8-1,d1
.pab2	moveq	#0,d2
	btst	d0,d1
	beq.s	.pab_miss
	move.w	#$770,d2
.pab_miss
	move.w	d2,-(a0)
	dbf	d1,.pab2
	lea	(16*2)(a0),a0
	dbf	d0,.pab1
	move	#8-1,d1
.pab3	move	(a6),2*8*2(a6)
	addq.l	#2,a6
	dbf	d1,.pab3
	moveq	#0,d4
	rts

.animate_bells
	set_mod_breakpoint	#2
	wait_until_mod_breakpoint
	move.w	d4,d0
	add.w	d0,d0
	lea	.abcol1(pc,d0.w*8),a0
	movem.l	(a0),d0-d3
	movem.l	d0-d3,c16regs.w
	addq.l	#1,d4
	andi.w	#%11,d4
	rts
.abcol1	ds.w	8
	ds.w	8
	ds.w	8
	ds.w	8

t_noborder
	dc.b	'n0 b0RdeRz!!11!',0
	even

* Scroll Santa landscape

scroll_landscape:
	move.l	front,a0
	lea	jingle2+34,a1
	moveq	#0,d0
	addq.l	#6,a0
	move.b	.scroll_cnt,d0
	lea	6(a1,d0.w*8),a1
	subq.l	#1,d0
	tst.w	d0
	bgt.s	.no_reset
	move.l	#20-1,d0
.no_reset
	move.b	d0,.scroll_cnt
	move.w	#(20*200)-1,d0
.loop	move.w	(a1)+,(a0)+
	addq.l	#6,a0
	addq.l	#6,a1
	dbf	d0,.loop
	rts

.scroll_cnt	dc.b	20-1
	even

* The greets bit

do_greets:
	lea	t_greets,a0
	move.l	front,a1
	moveq	#3,d0
	moveq	#100,d1
	moveq	#0,d2
	move	#$407,d3
	bsr	do_titles 		; Special Senior Dads text displayer!
	wait_until_mod_pos	#16,#32
	set_asavmode	#trucol_inf 	; Zap into trucol lores using hardware regs
	lea	greets_pic,a6		; Show "Greets"
	bsr	show_trucol 		; Special Senior Dads Trucol pic displayer!
	wait_until_mod_pos	#17,#0
.loop	bsr	disp_greets
	set_mod_breakpoint	#16
	wait_until_mod_breakpoint
	if_not_at_mod_pos.s	#20,#48,.loop
	move.l	#$ff000000,c256regs.w
	move.l	front,a0
	moveq	#7,d7
	bsr	do_bombs_tru
	wait_until_mod_pos	#21,#4
	move.l	front,a0
	moveq	#9,d7
	bsr	do_bombs_tru
	wait_until_mod_pos	#23,#0
.abort_exit
	rts

t_greets
	dc.b	'gR33TsZX!',0
	even

* Display greets!

disp_greets:
	move.l	greets_ptr,a6
	move.l	(a6)+,d0
	tst.l	d0
	beq.s	.abort
	move.l	a6,greets_ptr
	move.l	d0,a0
	moveq	#0,d0
	moveq	#0,d1
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	move.l	front,a1
	bsr	trucol_print
.abort	rts

greets_tab	dc.l	g_go2,g_wrc,g_rg,g_conf
		dc.l	g_mbyt,g_sin,g_arch1,g_arch2
		dc.l	g_avn,g_ntw,g_eff,g_bg
		dc.l	g_ac,g_and
		dc.l	0

greets_ptr	dc.l	greets_tab

g_go2	dc.w	180,0
	dc.b	'fah la la la 2:',0
	even
g_wrc	dc.w	220,180
	dc.b	'wRc!1',0
	even
g_rg	dc.w	190,40
	dc.b	'resrvior gods!',0
	even
g_conf	dc.w	210,100
	dc.b	'C0NFUZIONS!',0
	even
g_mbyt	dc.w	203,80
	dc.b	'Magicbytes!',0
	even
g_sin	dc.w	224,160
	dc.b	'sin-BAD!!!',0
	even
g_arch1	dc.w	230,50
	dc.b	'archie-',0
	even
g_arch2	dc.w	220,60
	dc.b	'opterix!!',0
	even
g_avn	dc.w	240,110
	dc.b	'AVENNA!!',0
	even
g_ntw	dc.w	200,150
	dc.b	'n3Tw0Rk!!1!1',0
	even
g_eff	dc.w	216,174
	dc.b	'33f3Ct11!!!',0
	even
g_bg	dc.w	202,70
	dc.b	'Bill Gates!',0
	even
g_ac	dc.w	190,20
	dc.b	'Atarri Computing!',0
	even
g_and	dc.w	198,120
	dc.b	'And all the...',0
	even

* DO "FROSTY" SEQUENCE!

do_frosty:
	bsr	st_lorez		; Go ST low rez (just in  case)
	lea	t_frosty,a0
	move.l	front,a1
	moveq	#0,d0
	moveq	#30,d1
	moveq	#0,d2
	move	#$77,d3
	bsr	do_titles 		; Special Senior Dads text displayer!
	set_mod_breakpoint	#8
	wait_until_mod_breakpoint
	move.w	#-1,c16regs.w
	clr.w	c16regs+2.w
	wait_until_mod_pos	#23,#40
.loop	bsr	frosty_frame
	set_mod_breakpoint	#1
	wait_until_mod_breakpoint
	if_not_at_mod_pos.s	#27,#48,.loop
	move.l	back,a1
	move.l	a1,a2
	moveq	#0,d6
	move.w	#(32000/4)-1,d7
.loop1	move.l	d6,(a2)+
	dbf	d7,.loop1
	lea	frosty_boot,a0
	move.w	#(176-1),d2
.loopx	move.w	#20-1,d3
.loopy	move.w	(a0)+,(a1)+
	addq.l	#6,a1
	dbf	d3,.loopy
	dbf	d2,.loopx
	bsr	swap_screens
	wait_until_mod_pos.s	#27,#56,.loop
.abort_exit
	rts


do_wish_xmas:
	set_asavmode	#trucol_inf 	; Zap into trucol lores using hardware regs
	lea	card_pic,a6		; Show "Dadmas"
	bsr	show_trucol 		; Special Senior Dads Trucol pic displayer!
	wait_until_mod_pos	#28,#48
;	wait_until_mod_pos	#0,#32
	bsr	st_lorez		; Go ST low rez (just in  case)
	lea	t_blobby1,a0
	move.l	front,a1
	moveq	#0,d0
	moveq	#30,d1
	moveq	#0,d2
	move	#$470,d3
	bsr	do_titles 		; Special Senior Dads text displayer!
	wait_until_mod_pos	#28,#58
	lea	t_blobby2,a0
	move.l	front,a1
	moveq	#1,d0
	moveq	#70,d1
	moveq	#0,d2
	move	#$740,d3
	bsr	do_titles 		; Special Senior Dads text displayer!
	wait_until_mod_pos	#29,#8
	lea	t_blobby3,a0
	move.l	front,a1
	moveq	#2,d0
	moveq	#120,d1
	moveq	#0,d2
	move	#$f33,d3
	bsr	do_titles 		; Special Senior Dads text displayer!
	wait_until_mod_pos	#29,#16
	bsr	setup_blob
.loop 	bsr	do_blob
	set_mod_breakpoint	#1
	wait_until_mod_breakpoint
	if_not_at_mod_pos.s	#30,#32,.loop
	lea	t_ascii1,a0
	move.l	front,a1
	moveq	#0,d0
	moveq	#100,d1
	moveq	#0,d2
	move	#$f00,d3
	bsr	do_titles 		; Special Senior Dads text displayer!
	wait_until_mod_pos	#30,#48
	lea	t_ascii2,a0
	move.l	front,a1
	moveq	#0,d0
	moveq	#20,d1
	moveq	#0,d2
	move	#$f00,d3
	bsr	do_titles 		; Special Senior Dads text displayer!
	move.l	#$fff0fff,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	movem.l	d0-d3,c16regs+(8*2).w
	wait_until_mod_pos	#31,#0
.loop2	moveq	#0,d0
	bsr	vert_scroller
	set_mod_breakpoint	#2
	wait_until_mod_breakpoint
	if_not_at_mod_pos.s	#32,#0,.loop2
.abort_exit
	rts

t_blobby1
	dc.b	'dont eat',13
	dc.b	'too much!',0
t_blobby2
	dc.b	' Or you',13
	dc.b	'will be...',0
t_blobby3
	dc.b	'BLOBBY!!',0
	even
t_ascii1
	dc.b	'Hey Resr',13
	dc.b	'vyor Godz!',0
	even
t_ascii2
	dc.b	'Check dis',13
	dc.b	'ASCII art!',0
	even

* THE BLOBBY BIT!

* Set up

setup_blob:
	lea	blobs,a6		; Show blobs
	bsr	disp_16col_pic 		; Special Senior Dads pic display method!
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	movem.l	d0-d7,c16regs.w
	rts

* Actual blobby stuff

do_blob:
	lea	.blob_pal,a0
	moveq	#0,d0
	move.b	.blob_cnt,d0
	lea	(a0,d0.w*2),a0
	add.b	.blob_coeff,d0
	tst.b	d0
	blt.s	.change
	cmpi.b	#32,d0
	ble.s	.no_change
.change
	neg.b	.blob_coeff
.no_change
	move.b	d0,.blob_cnt
	movem.l	(a0),d0-d7
	swap	d0
	clr.w	d0
	swap	d0
	movem.l	d0-d7,c16regs.w

	move.l	front,a0
	moveq	#0,d0
	move.b	.jmp_cnt,d0
	move.l	d0,d1
	add.b	.jmp_coeff,d0
	tst.b	d0
	blt.s	.change2
	cmpi.b	#10,d0
	ble.s	.no_change2
.change2
	neg.b	.jmp_coeff
.no_change2
	move.b	d0,.jmp_cnt
	mulu	#160,d1
	adda.l	d1,a0
	set_vidaddr	a0
	rts
.blob_cnt	dc.b	0
.blob_coeff	dc.b	1
.jmp_cnt	dc.b	0
.jmp_coeff	dc.b	1
.blob_pal
	REPT	16
	dc.w	0
	ENDR
i	set	0
j	set	$888
	REPT	8
	dc.w	i,j
i	set	i+$111
j	set	j+$111
	ENDR
	REPT	16
	dc.w	$fff
	ENDR

* RUDOLF

do_rudolf:
	bsr	rudolf_init
	lea	t_rudolf1,a0
	move.l	front,a1
	moveq	#0,d0
	moveq	#20,d1
	moveq	#0,d2
	move	#$f4f,d3
	bsr	do_titles 		; Special Senior Dads text displayer!
	wait_until_mod_pos.s	#32,#40
	lea	t_rudolf2,a0
	move.l	front,a1
	moveq	#0,d0
	moveq	#120,d1
	moveq	#0,d2
	move	#$4f5,d3
	bsr	do_titles 		; Special Senior Dads text displayer!
	bsr	copy_to_back
	move.l	#$f000f00,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	movem.l	d0-d3,c16regs+(8*2).w
	lea	santa_gun1,a6
	bsr	plot_santa
	bsr	swap_screens
	lea	santa_gun2,a6
	bsr	plot_santa
	set_mod_breakpoint	#16
	wait_until_mod_breakpoint
	
.gun_loop
	bsr	swap_screens
	set_mod_breakpoint	#1
	wait_until_mod_breakpoint
	if_not_at_mod_pos.s	#33,#0,.gun_loop
	bsr	do_main_rudolf
.abort_exit
	rts

* Initial Rudolf bit

rudolf_init:
	move.l	front,a6
	bsr	clear_16col_screen
	move.l	#(10*8),d0
.loop	tst.w	d0
	beq.s	.abort_exit
	move.l	back,a0
	bsr	clear_back
	move.l	back,a0
	lea	(60*160)(a0),a0
	adda.l	d0,a0
	bsr	plot_rudolf_alive
	bsr	swap_screens
	set_mod_breakpoint	#1
	wait_until_mod_breakpoint
	subq.l	#8,d0
	bra.s	.loop
.abort_exit
	rts

* Main Rudolf bit!

do_main_rudolf:
	bsr	.get_next_shot
.loop	moveq	#0,d0
	move.b	.next_shot,d0
	set_mod_breakpoint	d0
	move.l	.rudolf_coords,d0
	move.l	back,a0
	bsr	clear_back
	move.l	back,a0
	adda.l	d0,a0
	bsr	plot_rudolf_dead
	bsr	swap_screens
	bsr.s	.get_next_shot
	wait_for	#10
	if_at_mod_breakpoint.s	.loop
	move.l	.rudolf_coords,d0
	move.l	back,a0
	bsr	clear_back
	move.l	back,a0
	adda.l	d0,a0
	bsr	plot_rudolf_alive
	bsr	swap_screens
	wait_until_mod_breakpoint
	if_not_at_mod_pos	#38,#0,.loop
.abort_exit
	rts
.get_next_shot
	move.l	.shot_ptr,a6
	move.b	(a6)+,d7
	cmpi.b	#-1,d7
	bne.s	.nowrap
	lea	.shots,a6
	move.b	(a6)+,d7
.nowrap	move.l	a6,.shot_ptr
	move.b	d7,.next_shot
	stack_save	d0-d3/a0-a3		; d0-d3/a0-a3 affected by XBIOS calls
	move	#17,-(sp)			{
	trap	#14				{ - Get random number
	addq.l	#2,sp				{
	move.w	d0,d6
	move.w	d1,d7
	stack_restore	d0-d3/a0-a3		; d0-d3/a0-a3 affected by XBIOS calls
	divu	#10,d6
	divu	#140,d7
	swap	d6
	swap	d7
	ext.l	d6
	ext.l	d7
	mulu	#160,d7
	lsl	#3,d6
	add	d6,d7
	ext.l	d7
	move.l	d7,.rudolf_coords
	rts

.rudolf_coords
	dc.l	0
.next_shot
	dc.b	0
	even
.shot_ptr
	dc.l	.shots
.shots
	dc.b	3,4,3,5,5,4
	dc.b	8,2,2,2,2,6,5,13
	dc.b	-1
	even

; a6 = santa
plot_santa:
	stack_save	d0-a6
	move.l	back,a0
	lea	80+6(a0),a0
	move.w	#138-1,d0
.loop1	move.w	#10-1,d1
	move.l	a0,a1
.loop2	move.w	(a6)+,(a1)+
	addq.l	#6,a1
	dbf	d1,.loop2
	lea	160(a0),a0
	dbf	d0,.loop1
	stack_restore	d0-a6
	rts

clear_back:
	stack_save	d0/d1
	move.w	#(32000/4)-1,d1
	moveq	#0,d0
.loop	move.l	d0,(a0)+
	dbf	d1,.loop
	stack_restore	d0/d1
	rts

plot_rudolf_alive:
	move.w	#$70,c16regs+2.w
	lea	rudolf_alive,a6
	bsr	plot_rudolf
	rts

plot_rudolf_dead:
	move.w	#$700,c16regs+2.w
	lea	rudolf_dead,a6
	bsr	plot_rudolf
	rts

plot_rudolf:
	stack_save	d0-a6
	move.w	#60-1,d0
.loop1	move.w	#10-1,d1
	move.l	a0,a1
.loop2	move.w	(a6)+,(a1)+
	addq.l	#6,a1
	dbf	d1,.loop2
	lea	160(a0),a0
	dbf	d0,.loop1
	stack_restore	d0-a6
	rts

t_rudolf1
	dc.b	'Beef has',13
	dc.b	'been ',13
	dc.b	' BANNED!',0
t_rudolf2
	dc.b	'Bad',13
	dc.b	'news for',13
	dc.b	' Rudolpf!',0
	even

* END PART!

do_endpart:
	lea	tv,a6			; end pic
	bsr	disp_16col_pic 		; Special Senior Dads pic display method!
	bsr	copy_to_back
	move.l	#v_text2,v_text_base
	move.l	#v_text2,v_text_ptr
.loop	moveq	#0,d0
	bsr	vert_scroller
	set_mod_breakpoint	#2
	wait_until_mod_breakpoint
	bsr	do_spice_dads
	if_not_at_mod_pos.s	#47,#48,.loop
	lea	noddy,a6		; noddy pic
	bsr	disp_16col_pic 		; Special Senior Dads pic display method!
	wait_until_mod_pos.s	#49,#32
	lea	end_pic,a6		; (c) pic
	bsr	disp_16col_pic 		; Special Senior Dads pic display method!
	wait_until_mod_pos.s	#50,#18
	bsr	clear_16col_screen
	set_mod_breakpoint	#3
	wait_until_mod_breakpoint
.abort_exit
	rts

* Spice Dads

do_spice_dads:
	tst.w	.curtime
	bne.s	.exit
	move.l	.timeptr,a0
	move.w	(a0)+,d0
	cmpi.w	#-1,d0
	bne.s	.no_loop
	move.l	#.timelist,a0
	move.w	(a0)+,d0
	move.l	#.dadlist,.dadptr
.no_loop
	move.w	d0,.curtime
	move.l	a0,.timeptr
	move.l	.dadptr,a0
	move.l	(a0)+,a1
	move.l	a0,.dadptr
	move.l	front,a0
	move.l	back,a3
	adda.l	#(11*8)+(10*160)+4,a0
	adda.l	#(11*8)+(10*160)+4,a3
	move.w	#100-1,d0
.loop1	move.w	#8-1,d1
	move.l	a0,a2
	move.l	a3,a4
.loop2	move.w	(a1),(a2)
	move.w	(a1)+,(a4)
	addq.l	#8,a2
	addq.l	#8,a4
	dbf	d1,.loop2
	lea	160(a0),a0
	lea	160(a3),a3
	addq.l	#2,a1
	dbf	d0,.loop1
.exit	subi.w	#1,.curtime
	rts

.curtime
	dc.w	32

.timeptr
	dc.l	.timelist
.timelist
	dc.w	32,32,32,32,32,32,32
	dc.w	-1

.dadptr	dc.l	.dadlist
.dadlist
	dc.l	s_intro,s_wacky,s_scene,s_arty,s_grumpy,s_amiga,s_dadpower


* HIDDEN SCREEN!

do_hidden:
	set_asavmode	#trucol_inf 	; Zap into trucol lores using hardware regs
	lea	who,a0
	bsr	quick_trucol_pic
	move.l	#hidden_text,tru_scr_ptr
	bsr	do_hidden_scroller
.abort_exit
	rts

do_hidden_scroller
.loop
	move.l	front,a0
	adda.l	#(200-16)*(320*2),a0
	bsr	trucol_scroll
	if_true.s	tru_scr_resetted,.abort_exit
	wait_for	#1
	check_demo_abort
	bra.s	.loop
.abort_exit
	sf	abort_demo
	jsr	Stop_Music_IT
	moveq	#5,d7
	move.l	front,a0
	bsr	do_bombs_tru
	wait_for	#300
	st	abort_demo
	if_false.s	continue,.bye
	sf	abort_demo
	sf	continue
	jsr	Init_Music_IT
	move.b	#1,tru_scr_cnt
	lea	who,a0
	bsr	quick_trucol_pic
	bra	.loop
.bye	rts

t_frosty
	dc.b	'Say helo',13
	dc.b	'2 FROSTY!',0
	even

* Draw Frosty

frosty_frame:
	movem.w	.frosty_coords,d0-d3
	add	d2,d0
	cmpi.w	#9,d0
	bge.s	.rx
	tst	d0
	bge.s	.okx
.rx	neg	d2
	add	d2,d0
.okx	add	d3,d1	
	cmpi.w	#42,d1
	bge.s	.ry
	tst	d1
	bge.s	.oky
.ry	neg	d3
	add	d3,d1
.oky	addq.l	#2,d3
	movem.w	d0-d3,.frosty_coords
	move.l	back,a1
	move.l	a1,a2
	moveq	#0,d6
	move.w	#(32000/4)-1,d7
.loop1	move.l	d6,(a2)+
	dbf	d7,.loop1
	lea	frosty,a0
	mulu	#160,d1
	lea	(a1,d0.w*8),a1
	lea	(a1,d1.w),a1
	move.w	#(157-1),d2
.loopx	move.w	#((176/16)-1),d3
.loopy	move.w	(a0)+,(a1)+
	addq.l	#6,a1
	dbf	d3,.loopy
	lea	((20*8)-((176/16)*8))(a1),a1
	dbf	d2,.loopx
	bsr	swap_screens
	rts
.frosty_coords
.fx	dc.w	0
.fy	dc.w	0
.fxi	dc.w	1
.fyi	dc.w	1


* Trucol print string:

trucol_print:
	mulu	#320*2,d1
	adda.l	d1,a1
	lea	(a1,d0.w*2),a1
	lea	trucol_font,a6
.letter	moveq	#0,d0
	move.b	(a0)+,d0
	tst.b	d0
	beq.s	.finished
	subi.b	#' ',d0
	lsl.l	#7,d0
	lea	(a6,d0.l),a5
	move.l	a1,a2
	moveq	#8-1,d1
.loop1	moveq	#8-1,d2
.loop2	move.w	(a5)+,(a2)+
	dbf	d2,.loop2
	lea	((320*2)-(8*2))(a2),a2
	dbf	d1,.loop1
	add.l	#8*2,a1
	bra.s	.letter
.finished
	rts

* ============================================

* Whiteout- changes all the colours to white. Easy, huh!

whiteout
	move.l	#$fff0fff,d0		; Colours 0-1 = white
	move.l	d0,d1			;         2-3 
	move.l	d0,d2			;         : :
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6			;         : :
	move.l	d0,d7			;        14-15
	movem.l	d0-d7,c16regs.w		; Display them.
	rts

* Vertical scroller- This actually scrolls in 8 pixel jumps!!!!
; d0 = start position of scroller

vert_scroller:
	move.l	back,a0			; Get back screen
	addq.l	#6,a0			; Go to plane 3
	move.l	a0,a1			; Save start of plane
	lea	(a0,d0.w),a0		; Go to starting position of scroller
	move.w	#8000-1,d1		{
.loop1	clr.w	(a1)+			{ - clear plane 3
	addq.l	#6,a1			{
	dbf	d1,.loop1		{
	move.l	front,a1		; We're copying from the front screen...
	adda.l	#6+(8*160),a1		; ... from plane 3 eight lines down.
	add.l	.start,a1		; Add saved starting position of front screen
	move.l	d0,.start		; Now we can save current starting position on back screen
	move.l	a0,a2			; Get starting position of scroller on back screen
	move.w	#((200-16)*(160/4))-1,d1	; Do for 184 lines
.loop2	move.w	(a1)+,(a2)+		{ - Copy scroller from front screen
	addq.l	#6,a1			{
	addq.l	#6,a2			{
	dbf	d1,.loop2		{
	move.l	v_text_ptr,a6		; Get scrolltext pointer
	cmpi.b	#-1,(a6)		; If at end of scrolltext
	bne.s	.no_reset		
	move.l	v_text_base,a6		;  ...send pointer back the start of the scrolltext
.no_reset
	lea	small_font,a2		; Get the "small font"
	adda.l	#192*160,a0		; Go down to line 192 of back screen to start writing the scrolltext
	moveq	#1,d2			; Set byte counter 1 = ON
	moveq	#0,d3			; Set byte counter 2 = OFF
	move	#20-1,d0		; For 20 characters do...
.loop3	moveq	#0,d1
	move.b	(a6)+,d1		;   Get a scrolltext character
	subi.b	#' ',d1			;   Subtract base character of font
	lsl.w	#3,d1			;   multiply by length (8 bytes) of single font character
	lea	(a2,d1.w),a3		;   now a3 = font representation of scrolltext character
i	set	0
	REPT	8			{
	move.b	(a3)+,i(a0)		{-- Write character on screen
i	set	i+160			{
	ENDR				{
	add.l	d2,a0			;   Add byte counter 1 or 2
	add.l	d3,a0			;     (Only one of the two is on at any time)
	eori.b	#1,d2			;   Toggle byte counter 1 on/off
	eori.b	#7,d3			;   Toggle byte counter 2 on/off
	dbf	d0,.loop3		; Next character please
	move.l	a6,v_text_ptr		; Save scrolltext pointer
	bsr	swap_screens		; flip between back & front screens.
	rts
.start	ds.l	1

v_text_base	dc.l	v_text1		; Contains position of scrolltext
v_text_ptr	dc.l	v_text1		; Contains position of scrolltext

	include	includes\vscroll.s	; Scrolltext (20 chars wide per line)

* Cycle16- It actually only cycles the top 8 of the 16 colours.

cycle16
	stack_save	d0-d7		; d0-d7 are used
	movem.l	c16cols+(2*8),d1-d4	; Get colours 8-14
	move.w	c16cols+(2*15),d0	; Get colour 15 by itself
	movem.l	d1-d4,c16cols+(2*9)	; move colours 8-14 -> 9-15	}- ie cycle palette upwards.
	move.w	d0,c16cols+(2*8)	; move (former) colour 15 -> 8	} 
	movem.l	c16cols,d0-d7		; Get custom palette
	movem.l	d0-d7,c16regs.w		; ...And display it.
	wait_for	#1		; Wait a couple of frames
	stack_restore	d0-d7		; restore data registers
	rts

* Do bombs. Plots the old system bomb bitmap to the screen. Converted
; from a similar procedure in "Colonic Irrigation". Assumes ST lo-res
; screen. d0= no of bombs

do_bombs:
	move.l	front,a1		; Get to front of screen
	adda.l	#100*160,a1		; Go halfway down it.
	lea	bomb_dat,a0		; Get bomb bitmap ready
.loop					; For d0 bombs do...
i	set	0
j	set	0
	REPT	16			 
	move.w	i(a0),j(a1)		{
	move.w	i(a0),j+2(a1)		{ --- Copy bomb bitmap to screen
	move.w	i(a0),j+4(a1)		{     (all planes ie colour 15)
	move.w	i(a0),j+6(a1)		{
i	set	i+2
j	set	j+160
	ENDR
	addq.l	#8,a1			;   Go to position of next bomb
	dbf	d0,.loop		; Next bomb.
	rts

* "or" bob- Ors a 96 X 144 bob on an ST lo-res screen from a 
; 4 plane source Degas pic.
; a5 = where to plot bob.
; a4 = source to copy bob from.

or_bob:	move.w	#144-1,d0		; For 144 lines do...
.bob2
i	set	0
	REPT	6			;   For 6 words do...
	move.w	i(a4),d1		;     Get bitmap data
	or.w	d1,i(a5)		;     ... And OR it on screen
i	set	i+8
	ENDR
	lea	160(a4),a4		;   Go down a line in source
	lea	160(a5),a5		;   Go down a screen line.
	dbf	d0,.bob2		; Next line of bob
	wait_for	#1		; Wait 2 frames
	rts

* Trucolour bomb routs =========================================

* Convert bitmap bomb to trucol

conv_bomb:
	lea	bomb_dat,a0
	lea	bomb_tru,a1
	moveq	#16-1,d0
	bsr	conv_to_trucol
	rts

* Convert main font to trucolour

conv_main_font:
	lea	main_font,a0
	lea	trucol_main_font,a1
	move.l	#((end_main_font-main_font)/2)-1,d0
	bsr	conv_to_trucol
	lea	trucol_main_font,a0
	move.l	#(trucol_main_font_end-trucol_main_font)-1,d0	
	moveq	#-1,d2
.loop	tst.l	d0
	beq.s	.end
	moveq	#0,d1
	tst.w	(a0)
	bne.s	.blank
	move.w	d2,d1
	subq	#1,d2
	cmp.w	#%1111100000000000,d2
	bne.s	.no_reset
	moveq	#-1,d2
.no_reset
.blank	move.w	d1,(a0)+
	subq	#1,d0
	bra.s	.loop
.end	rts

do_bombs_tru:			; d7 = number of bombs, a0 = screen
	subq.l	#1,d7
	move.l	a0,a2
	adda.l	#(((200-16)/2)*320*2),a2
.loop	move.l	a2,a0
	bsr	plot_bomb_tru
	lea	16*2(a2),a2
	dbf	d7,.loop
	rts

plot_bomb_tru:			; a0 = area of screen
	lea	bomb_tru,a1
	moveq	#16-1,d0
.loop1	moveq	#8-1,d1
.loop2	move.l	(a1)+,(a0)+
	dbf	d1,.loop2
	lea	((320-16)*2)(a0),a0
	dbf	d0,.loop1
	rts



* Show trucolour pic. Takes a lot fiddling around to show a trucolour
; pic this way! a6 = the (320X200) trucol pic.
	
show_trucol:
	move.l	back,a0			; Get back screen
	move	#(320*200)-1,d0		; For the whole (320X200) screen do.
.loop1	movem.w	.rand1,d1-d2		{
	eor.w	d2,d1			{
	neg.w	d1			{ - Faff about to get "random" numbers
	move.w	d1,.rand1		{
	move.w	timer.w,.rand2		{
	move.w	d1,c256regs.w		; - Stick it in the border colour register
	move.w	d3,c256regs+2.w		;
	move.w	d1,d3
	move.w	d1,(a0)+		;   Put	it on the screen.
	dbf	d0,.loop1		; Next pixel.
	bsr	swap_screens		; Swap screens to show this beautiful random painting!
	move.l	back,a0			; Get back screen	
	lea	$100.w,a1		{ - zap down to bottom of memory
	suba.l	a1,a1			{
	move	#(320*200)-1,d0		; For the whole (320X200) screen do.
.loop2	move.w	(a1)+,d2		;   Get a bit of low memory
	move.w	d2,c256regs.w		;   Stick it in the border colour
	move.w	d1,c256regs+2.w		;   Add the previous bit in as well!
	move.w	d2,d1			;   Save new bit
	move.w	d2,(a0)+		;   Plot on back screen.
	dbf	d0,.loop2		; Next pixel.
	wait_for	#20		; Wait a bit
	bsr	swap_screens		; Show the beauty of low memory on the screen!
	wait_for	#5		; Wait another bit.
	move.l	a6,a0			; Now get the actual picture ready.
	move.l	front,a1		; Get the FRONT screen ready
	move	#(320*200)-1,d0		; For half of it....
.loop3	move.b	(a0)+,(a1)+		;   Plot very slowly!
	dbf	d0,.loop3		; Next slow plot
	wait_for	#5		; Wait a bit.
	move	#(320*200)-1,d0		; For rest of it....
.loop3a	move.b	(a0)+,(a1)+		;   Plot very slowly!
	dbf	d0,.loop3a		; Next slow plot
	rts
.rand1	dc.w	$3f3f		{ - The "random" bits!
.rand2	dc.w	$7171		{

* Quick trucol pic display
; a0 = pic

quick_trucol_pic:
	stack_save	d0/a1
	move.l	#-1,c256regs.w
	move.l	#((320*200)/2)-1,d0
	move.l	back,a1
.loop	move.l	(a0)+,(a1)+
	dbf	d0,.loop
	bsr	swap_screens
	clr.l	c256regs.w
	stack_restore	d0/a1
	rts

* Display Degas pic. Well, it does more than that- it also craps on
; the screen and negates the palette beforehand!
; a6 = Degas pic

disp_16col_pic:
	bsr	st_lorez			; Go to ST-lores (Defaults palette)
	move.l	back,a5				; Do crap of back screen
	move.l	#32000/2,d7			; Do 32K worth
	bsr	crap_on_screen			; Special Senior Dads crap generator!
	move.l	front,a1			; Go to front screen
	bsr	copy_16col_pic_to_screen	; ... and copy the picture onto it.
	wait_for	#10			; Wait a bit
	movem.l	2(a6),d0-d7			; Display proper palette!
	movem.l	d0-d7,c16regs.w
	rts

* Scroller. Draws a single frame of a 32X16 one-plane scroller.
; a6 = where to draw scroller to.

draw_scroller:
	stack_save	d0-a6		; Save all the registers
	subq.b	#1,scr_cnt		; Build a new letter?
	beq	.build
.scr	lea	scr_build,a1		; Get scroller buffer
	lea	scr_ltr_build,a2	; Get letter to scroll
	move.w	#16-1,d0		; For 16 lines do
.loop1	
i	set	0
	REPT	40-1			;   For 39 bytes do
	move.b	i+1(a1),i(a1)		;     Scroll bytes along (Yes, it's a byte scroller!)
i	set	i+1
	ENDR
	move.b	(a2),i(a1)		;   Put letter part into scroller buffer
	move.w	1(a2),(a2)		{ - scroll line of letter data buffer  
	move.b	3(a2),2(a2)		{
	clr.b	3(a2)			{
	adda.l	#20*2,a1		;   Go to next line in the scroller buffer
	addq.l	#4,a2			;   Go to next line in letter buffer
	dbf	d0,.loop1		; Next line

	lea	scr_build,a1		; Get scroller buffer
	move.w	#16-1,d0		; For 16 lines do...
.loop2
i	set	0
j	set	0
	REPT	20			{
	move.w	i(a1),j(a6)		{ - copy a line to the screen
i	set	i+2			{
j	set	j+8
	ENDR
	lea	i(a1),a1		{ - prepare for next line
	lea	j(a6),a6		{
	dbf	d0,.loop2		; Next line

	stack_restore	d0-a6		; Restore all the registers
	rts

; Build new scrolltext letter

.build	move.l	scr_ptr,a2		; Get scrolltext pointer
	moveq	#0,d0
	move.b	(a2)+,d0		; Get next character
	cmp.b	#-1,d0			; At end of scrolltext?
	bne.s	.b2			; If yes...
	st	scr_resetted		;   Set the reset flag.
	move.l	scr_strt,a2		;   Reset the pointer to the start of the scrolltext
	move.b	(a2)+,d0		;   Get character at start of scrolltext
.b2	move.l	a2,scr_ptr		; Save scrolltext pointer
	subi.b	#' ',d0			; Subtract base of font
	lsl.w	#6,d0			; Multiply by length (32 bytes) of single character in font.
	lea	main_font,a2		; Get this font.
	lea	(a2,d0.w),a2		; Now a2 = start of font representation of character.
	lea	scr_ltr_build,a3	; Get letter buffer
	REPT	16			{
	move.l	(a2)+,(a3)+		{ - copy font char into buffer
	ENDR				{
	move.b	#4,scr_cnt		; Can be scrolled 4 times before new letter is needed.
	bra	.scr			; Go back to scroller.

scr_ltr_build	ds.l	16		; Single letter buffer
scr_build	ds.w	16*20		; Scroller buffer
scr_strt	dc.l	scr_text1	; This points to the restart position of the scrolltext- can be changed.
scr_ptr		dc.l	scr_text1	; This points to the current position of the scrolltext
scr_cnt		dc.b	1		; When this reaches 0, a new letter is read from the scrolltext.
scr_resetted	ds.b	1		; Set to TRUE if scrolltext wraps.
	even

* Trucol Scroller. Draws a single frame of a 32X16 one-plane scroller.
; a0 = where to draw scroller to.

trucol_scroll:
	stack_save	d0-a6		; Save all the registers
	subq.b	#1,tru_scr_cnt		; Build a new letter?
	beq	.build
.scr	lea	tru_scr_build,a1		; Get scroller buffer
	lea	tru_scr_ltr_build,a2	; Get letter to scroll
	move.w	#16-1,d0		; For 16 lines do
.loop1	
	move.l	a1,a3
	lea	(8*2)(a3),a4
	move.l	#((320-8)/2)-1,d1
.loop1a	move.l	(a4)+,(a3)+			;   Scroll 8 pixels to the left (same speed as the bitmap scroll)
	dbf	d1,.loop1a
	
	move.l	a2,a4
	move.w	#(8/2)-1,d1
.loop1b	move.l	(a2)+,(a3)+			;   Put letter part into scroller buffer
	dbf	d1,.loop1b

	move.w	#((32-8)/2)-1,d1
.loop1c	move.l	(a2)+,(a4)+		{ - scroll line of letter data buffer  
	dbf	d1,.loop1c

	move.w	#(8/2)-1,d1
.loop1d	clr.l	(a4)+			{ - Clear end bit
	dbf	d1,.loop1d
	adda.l	#320*2,a1		;   Go to next line in the scroller buffer
	adda.l	#32*2,a2			;   Go to next line in letter buffer
	dbf	d0,.loop1		; Next line

	lea	tru_scr_build,a1		; Get scroller buffer
	move.w	#16-1,d0		; For 16 lines do...
.loop2	move.w	#(320/2)-1,d1
.loop2a	move.l	(a1)+,(a0)+		{ - copy a line to the screen
	dbf	d1,.loop2a
	dbf	d0,.loop2		; Next line

	stack_restore	d0-a6		; Restore all the registers
	rts

; Build new scrolltext letter

.build	move.l	tru_scr_ptr,a2		; Get scrolltext pointer
	moveq	#0,d0
.again	move.b	(a2)+,d0		; Get next character
	cmp.b	#1,d0			; Bombalot
	beq	.xmas_abort
	cmp.b	#2,d0
	beq	.oldfart
	cmp.b	#3,d0
	beq	.dodgit
	cmp.b	#4,d0
	beq	.damevera
	cmp.b	#5,d0
	beq	.jackpol
	cmp.b	#6,d0
	beq	.cbag
	cmp.b	#7,d0
	beq	.who
	cmp.b	#-1,d0			; At end of scrolltext?
	bne	.b2			; If yes...
	st	tru_scr_resetted		;   Set the reset flag.
	move.l	tru_scr_strt,a2		;   Reset the pointer to the start of the scrolltext
	move.b	(a2)+,d0		;   Get character at start of scrolltext
.b2	move.l	a2,tru_scr_ptr		; Save scrolltext pointer
	subi.b	#' ',d0			; Subtract base of font
	lsl.l	#8,d0
	lsl.l	#2,d0			; Multiply by length of single character in font.
	lea	trucol_main_font,a2	; Get this font.
	lea	(a2,d0.l),a2		; Now a2 = start of font representation of character.
	lea	tru_scr_ltr_build,a3	; Get letter buffer
	move.w	#((16*32)/2)-1,d1
.loop3a	move.l	(a2)+,(a3)+		{ - copy font char into buffer
	dbf	d1,.loop3a				{
	move.b	#4,tru_scr_cnt		; Can be scrolled 4 times before new letter is needed.
	bra	.scr			; Go back to scroller.
.xmas_abort
	if_true	xmas_today,.again
	st	abort_demo
	move.l	a2,tru_scr_ptr		; Save scrolltext pointer
	stack_restore	d0-a6		; Restore all the registers
	rts
.oldfart
	stack_save	a0
	lea	oldfart+(16*320*2),a0
	bsr	quick_trucol_pic
	stack_restore	a0
	bra	.again
.dodgit
	stack_save	a0
	lea	dodgit+(16*320*2),a0
	bsr	quick_trucol_pic
	stack_restore	a0
	bra	.again
.damevera
	stack_save	a0
	lea	damevera+(16*320*2),a0
	bsr	quick_trucol_pic
	stack_restore	a0
	bra	.again
.jackpol
	stack_save	a0
	lea	jackpol,a0
	bsr	quick_trucol_pic
	stack_restore	a0
	bra	.again
.cbag
	stack_save	a0
	lea	cbag+(16*320*2),a0
	bsr	quick_trucol_pic
	stack_restore	a0
	bra	.again
.who	stack_save	a0
	lea	who,a0
	bsr	quick_trucol_pic
	stack_restore	a0
	bra	.again


tru_scr_ltr_build	ds.w	16*32*2		; Single letter buffer
tru_scr_build		ds.w	320*16		; Scroller buffer
tru_scr_strt		dc.l	hidden_text	; This points to the restart position of the scrolltext- can be changed.
tru_scr_ptr		dc.l	hidden_text	; This points to the current position of the scrolltext
tru_scr_cnt		dc.b	1		; When this reaches 0, a new letter is read from the scrolltext.
tru_scr_resetted	ds.b	1		; Set to TRUE if scrolltext wraps.
	even

hidden_text	dc.b	'THE HIDDEN SCREEN!'
		dc.b	1
		dc.b	' DAMN, WE CAN''T USE LOWERCASE- DUNNO WHHY!!! LOOK WHAT HAPPENS WHEN WE TRY... see what we mean    STILL.... '
		dc.b	'IF U CAN SEE THIS-  MERRY XMAS!   THIS IS A SPECIALL MESSAGEE FOR XMAS DAY-  A BIT LIKE THE QEENS MESSG AR 3PM , BUT IT''S A BIT MORE IMPORTSNT!               '
		dc.b	'ANYWAYS....  WHO ARE THE         S        D      ?                '
		dc.b	'THE QUESTION THAT HAS PLAGUED THE PHILSOFERS THROUGHOUT THE MILLIONS OF YEARS ......               '
		dc.b	'IN THIRD PLACE -    IS THERE A GOD?                          '
		dc.b	'IN SECOND PLAICE-               WHAT IS THE MEANING OF LIFE??????                   '
		dc.b	'B UT THE OVERIDDING ONE IS./......        W-H-O -A-R-E- -T-H-E-     -SE-N-I-O-R-   -D-D-A-Z-?????               '
		dc.b	'WELL, WE CAN DO BETTER THAN THE BEST PHILOSOFERS BECAUSE WE ARE SO BLODDY BRIALLIANT!  SORRY NEICTCHES, SORRY HEGGY, SORRY KUNT, SORRY ARISTOOL, BUT WE''Z GOTS THA ANSWERS PEEPS HAVE BEEN SEARCHING FOR!!! SO GO AND DIE!!!!    '
		dc.b	'    WHAT YOU   R  GOIN   2   C   IS    A GLIMPSE OF THE REAL LIFVES OF THE   SENIOR DADIES!!!           STAY   CHOOONED!!!                            '

		dc.b	2,'HI OLD FART HERE!!! AS YOU CAN SEE I''M DOING SOMETHING REALLY WACKY AT A RAVE CALLED ''V97''!!!!     '
		dc.b	'I GOT MY RATHER SEVEREER HAIRCUT A COUPLE OF MONTHS AGO FORRRA LAFF!!! IT''S LIKE ... ''I BET YOU WOULDN''T GET YOU BEAUTIFUL BRITPOP LOCKS SHORN FOR A BET!''     ''YOU''RE ON!!!''    AND SO THE REST IS HISTORY!!!!  '
		dc.b	'I SAW PLACEBO MSP AND RASIOHED WITH A SECVERELY FOCIALLY CHALLENGED HEAD!!!!    BUT   IT''S COOLL THOGUH... I MEAN, THE BLOKE OUT OF ''TAXI DRIVER'' GOT IT SHORT- WELL '
		dc.b	'IT WAS ACTUALLY A MOHEICAN BUT THAT WOULD LOOK REALLY STUPID!!!!    SO WAIT TILL I GROW MY HAIR BACK!!!!!!!!!!      SEE YOU LATER!!!!!              '

		dc.b	3,'D0D G1T 1N DA PLA1C3!11!!      K00L P1X K00L ASM K00L GFX KOOL MUS1XC - W3 AR3 M3GAM1GHTY!!!!11!!      GR8T P1C 0F M3 1SNT 1T !??2?    FUK ALL LAM3RS!!!111!   BY3!!!11!! !!1         '

		dc.b	4,'YO! DA DAME IS HEREZ!!!          THIS IS A REAL PAIN IN THE ASS HAVING TO EXPRESS MY COMPLEX SELF IN CAPITALS!  THIS IS ME DOING MY DJ NIGHT AT KRUSTY IN THE MILTON CENTRAL UNI. I''M DOING THE '
		dc.b	'EASY LISTENING NIGHT "DEPARTMENT S", BUT I''LL SOON CONVICE THOSE PHILLISTINEZ AT THE STUDENT UNION THAT WHAT THEY REALLY WANT IS SOME GOOD PUMPING TECHNO CHUNEZ!!!               '
		dc.b	'IT WAS A REAL CHALLENGE DOING A TECHNO XMAS MEDLY, BUT YOU HAVE TO ADMIT I PASSED THE TEST WITH FLYING COLOURS!!! AND IF YOU DON''T, I''M GONNA SEND THE BOYS ROUND TO DUFF YOU UP.   '
		dc.b	'TALKING OF WHICH, SOME IDIOT HAS HAD THE NERVE TO CRITICISE MY MUSIC... YES, I KNOW, HOW ANYONE COULD BE SO STUPID, BUT THIS GUY WAS DEFINATELY TWO BEATS SHORT OF A BAR. PEEP DIS: '
		dc.b	'APPARENTLY THE AIRDIRT MUSIC WAS A "CATWAUL"!!!   YOU WOT, MR MUSIC CRITIC?  EVERYONE KNOWS I''M THE BEST MUSICIAN IN THE WORLD, AND IT''S OBVIOUS YOU''RE JUST A JEALOUS TONE-DEAF LITTLE SHIT. '
		dc.b	'DON''T TEST ME OR I''LL SMASH YOUR TEETH SO FAR DOWN YOUR THROAT YOU''LL NEED TO STICK A TOOTHBRUSH UP YOUR ASS TO CLEAN THEM!! '
		dc.b	'THEN I''LL WRITE A SONG ABOUT IT, AND IT WILL GO TO NUMBER 1 BECAUSE THAT''S HOW FUCKING GOOD I AM!!!!            LATER DUDES...........     '

		dc.b	5,'MINGLE-MANGLE, MINGLE-MANGLE!!!!!   (MYSTERIOUS MUSIC) JACKSON POLLOCK THE ONE MAN ART MUSEUM HAS APPEARED!!   '
		dc.b	'YOU SEE ME ASTRIDE ONE OF MY ART INSTALLATIONS!!! NO SHIT DEMO FANS, THIS IS A PART OF MY EXHIBITION ''SUPER ART MAN'', WHICH IS CONCERNED WITH THE ROLE OF ARTIST AS CULTURAL SAVIOUR IN SOCIETY. I USED THE METAPHOR OF ARTISTS '
		dc.b	'COMIC BOOK HEROES, SAVING SOCIETY AGAINST THE ARCHTYPE OF ANTI-CULTURE AS THE VILLIAN. IN THIS PARTICULAR PIECE CALLED ''YOU GO HERE'', I AM EMPHASISING THE ROLE OF THE ORDINARY MEMBER OF SOCIETY TO TAKE PART IN THE CULTURAL '
		dc.b	'RENAISSANCE OF HIS/HER OWN SOCIETY. IN A SENSE, EVERYONE CAN BE ''SUPER ART MAN/WOMAN'' .       DEEP, HUH?                       TA-RA AS THEY SAY IN TELETUBBIE LAND!!!         '

		dc.b	6,'WOW THIS WORK!!! KOOL!!! C BAG IS ALONG FOR THE RIDE!!!!!!!!!!!!!!!!!        YES, IT''S TRUE, I''M AN AMIGA CODER, BUT THE BEST ONE THERE IS!!   I CAN PROGRAM IN AREXX IN MY SLEEP, AND OFTEN DO! I GOT TO SLEEP HAVE A '
		dc.b	'FANTASTIC DREAM, AND THEN I WAKE UP, AND I''VE DONE IT AS A DEMO IN AREXX!!!!     DON''T BE FOOLED BY MY TYPICAL "WACKY" PICTURE (HEY, YOU DID ASK FOR THIS, OLD FART!), I AM IN FACT A GENIUS OF THE CODING ART, AND '
		dc.b	'IF YOU SEE AN AMIGA DEMO BY THE SENIOR DADS, THAT''LL BE ME!!! HI TO ALL MY FRIENDS AT MILTON CENTRAL UNI, EXCEPT BRIAN BECAUSE HE''S A TWAT.    GOODBYE!           '

		dc.b	7,'SO NOW YOU KNOW! WE HOPE YOU ENJOYED THIS DEMO. IF YOU DIDN''T, YOU MUST HAVE REALLY LOW SELF-ESTEEM, AND YOU NEED TO SEEK COUNSELLING!!!     '
		dc.b	'GOODBYE FROM THE SENIOR DA'

		dc.b	-1
	even

; Scrolltexts

scr_text1	dc.b	'Riding on tha snoww , on a 1 horse open sliegh  blah de blah de blah I don''t know the words  '
		dc.b	'Riding on tha snoww , on a 1 horse open slioegh  can somebody tell me the words!    '
		dc.b	'OH jingle belz jingle belz, jingle all the way... '
		dc.b	'O wot fun it is 2 ride on a one horse open sliegh  OH'
		dc.b	-1	; <- End char
	even

* Copies the actual picture data from a Degas pic (in a6). This subroutine
; copies it in bits, and waits a frame inbetween each bit.
	
copy_16col_pic_to_screen
	lea	34(a6),a0			; Get picture data
	move	#(((320/2)/16)-1),d0		; Do blah blah times...
.loop1	move.l	#((100*16)-1),d1		;   Do blah blah times...
.loop2	move.b	(a0),(a1)+			;     Copy pic data very slowly to screen.
	move.b	1(a0),(a1)+			;     Copy pic data very slowly to screen.
	move.w	(a0)+,c16regs.w			;     Copy pic data very slowly to palette.
	dbf	d1,.loop2			;   Do more blah blah
	wait_vbl				;   Wait a frame.
	dbf	d0,.loop1			; Do this blah blah times.
	rts

* The faithful old ST lo-rez calling subroutine. Before calling it,
; we replace the old vbl, since it seems to default the palette for
; some reason. Who cares, it looks good!

st_lorez:
	move.l	old_vbl,vbl.w			; Restore old vbl
	wait_vbl				; Wait until it kicks in
	setrez_falc	lores_inf,#-1,#-1	; Set the lo-res
	move.l	#vbl_timer,vbl.w		; Back to custom vbl
	rts

* Erm this calls the generate_crap bit, swaps the screen then waits a
; bit!!! This must be one of the procedures written early on!

crap_on_screen
	bsr	generate_crap 			; Special Senior Dads crap generator!
	bsr	swap_screens			; Show crap on screen
	wait_for	#10			; Wait a bit.
	rts

* GENERATE CRAP! This is probably the most important procedure in the
; entire demo. This writes random values to d7 words starting from the
; address in a5.

generate_crap:
	stack_save	d0-d3/a0-a3		; d0-d3/a0-a3 affected by XBIOS calls
	subq.l	#1,d7				; Get ready for dbf loop...
.loop	move	#17,-(sp)			{
	trap	#14				{ - Get random number
	addq.l	#2,sp				{
	move.w	d0,(a5)+			; Put it in memory location.
	dbf	d7,.loop			; Do next word...
	stack_restore	d0-d3/a0-a3		; Restore old registers.
	rts

* SPECIAL FADEOFF ROUTINE. 

fadeoff_16col:
	stack_save	d0-d7			; All data registers are used here.
	lea	c16regs.w,a0			; Get the palette ready...
	move.w	timer.w,d2			; save timer counter
	moveq	#16-1,d0			; For 16 times do...	
.loop1	move	d0,d1
.loop2	eori.w	#$777,(a0,d1.w*2)
	dbf	d1,.loop2
	cmp.w	timer.w,d2
	beq.s	.loop1
	move.w	timer.w,d2			; save timer counter
	dbf	d0,.loop1			; Next frame
	clear_registers				; clear d0-d7
	movem.l	d0-d7,c16regs.w			; Turn everything to black to complete "fade"
	wait_for	#10			; Wait a few frames
	stack_restore	d0-d7			; Restore all the data registers.
	rts

* SWAP SCREENS: this swaps between front and back screen pointers, and
; displays new "front" screen.

swap_screens:
	stack_save	d0			; d0 is used
	move.l	back,d0				{
	move.l	front,back			{ - swap "front" and "back" screens.
	move.l	d0,front			{
	set_vidaddr	d0			; Display new "front" screen.
	wait_vbl				; Wait one frame
	stack_restore	d0			; Restore d0
	rts

* GET SMALL FONT: The font at the end bit looks a bit like the system
; font you're using, doesn't it? Well, guess what- it is! However, we're
; not using the system method of printing it on the screen, after the 
; problems we had using this technique in "Colonic Irrigation". We've
; decided to use our own routine and grab the system font, which is what
; this procedure does. This prints a list of characters, which are
; grabbed and stored in the font buffer. If you're really quick you
; might see it happening at in the top left corner of the screen during
; the start of the demo.

get_8x8_font:
	bsr	st_lorez			; Make sure we're in lo-res
	wait_for	#1			; Wait a frame.
	bsr	whiteout			; Blank colours
	print_string	#.setcol		; Set system font pen
	move.l	#' ',d6				; Start font with ' ' (Space)
	move.l	$44e.w,a5			; Get screen ready as source
	lea	small_font,a6			; Get font buffer ready as dest
	move.w	#('~'-' ')-1,d7			; For loads of characters do....
.loop	move.b	d6,.char			;   Set character to print.
	addq.l	#1,d6				;   Get next char ready for next time.
	print_string	#.char_print		;   Print char on screen. 
i	set	0
	REPT	8				{
	move.b	i(a5),(a6)+			{ - Copy bitmap data from
i	set	i+160				{   screen to font buffer.
	ENDR
	dbf	d7,.loop			; Do next character.
	rts

.setcol		dc.b	27,'b1',0		; This appears to work  for pen colour
.char_print	dc.b	27,'H'			; ESC code to move to top-left
.char		dc.b	0,0			; Char + null end code.
	even

* Convert small font to trucolour format

convert_8x8_font:
	lea	small_font,a0			; Get bitmap font buffer for reading
	lea	trucol_font,a1			; Get trucol font buffer for writing
	move.l	#((small_font_end-small_font)/2)-1,d0
	bsr	conv_to_trucol
	rts

* Convert Bitmap to trucolour format
; a0 = source bitmap
; a1 = dest trucol data
; d0 = no of words

conv_to_trucol:
.loop	move.w	#16-1,d1
	move.w	(a0),d2
.loop2	lsl.w	d2
	roxl	(a1)
	neg	(a1)
	not	(a1)
	addq.l	#2,a1	
	dbf	d1,.loop2
	addq.l	#2,a0	
	dbf	d0,.loop
	rts


* TITLES SUBROUTINE!
; a0 = text (ends with 0)
; a1 = screen
; d0,d1 = x (1-20), y (1-200)
; d2 = plane (0-3)
; d3 = colour ($rgb)

do_titles:
	stack_save	d0-a6
	move.l	a1,a6
	bsr	clear_16col_screen		; First clear the screen.
	lea	c16regs.w,a2			; Get the colour palette
	moveq	#0,d4
	bset	d2,d4				; Go to the colour of the plane defined in d2
	add	d4,d4				{
	move.w	d3,(a2,d4.w)			{- Set it to the colour defined in d3
	bsr	font_string			; Call print string subroutine
	stack_restore	d0-a6
	rts

* Print text using a 32X32 font
; a0 = string
; a1 = screen
; d0,d1 = x,y
; d2 = plane

font_string
	add	d2,d2				{ - move to plane in screen 
	lea	(a1,d2.w),a1			{
	lsl.w	#3,d0				; Move to..
	lea	(a1,d0.w),a1			; ..X-position
	mulu	#160,d1				; Move to..
	lea	(a1,d1.w),a1			; ..Y-position
	move.l	a1,a4				; Get starting position
.loop	lea	main_font,a2			; Get font ready
	moveq	#0,d0
.ag	move.b	(a0)+,d0			; Get character
	beq	.exit				; Until at end of string...
	cmp.b	#13,d0				;   If c/r detected...
	bne.s	.fn
	adda.l	#160*16,a1			;     Go down a line.
	move.l	a1,a4				;     Update starting position
	bra.s	.ag				;     Get another character
.fn	subi.b	#' ',d0				;   Subtract base of font
	lsl.l	#6,d0				;   Multiply by length (64 bytes) of single char
	lea	(a2,d0.w),a3			;   Now a3 = bitmap representation of char
i	set	0
	REPT	16				{
	move	(a3)+,i(a4)			{ - Copy letter bitmap to screen
	move	(a3)+,i+8(a4)			{
i	set	i+160				{
	ENDR
	adda.l	#16,a4				;   Move forward to next char position on screen
	bra	.loop				; Do next character
.exit	rts

* CLEAR 16COL SCREEN - This, erm, clears an ST-lores screen! BTW It also
; sets all the colours to black.
; a6 = start of screen

clear_16col_screen
	move.w	#32000-1,d7			; For 32000 bytes...
.loop	clr.b	(a6)+				;   Clear rather slowly
	dbf	d7,.loop			; Next byte please.
	wait_for	#10			; Wait a few frames
	lea	c16regs.w,a6			; Get palette regs ready
i	set	0
	REPT	16				{
	clr	i(a6)				{ - clear them slowly too
i	set	i+2				{
	ENDR
	rts

* COPY FRONT SCREEN TO BACK SCREEN - Quite self explanatory, I think!

copy_to_back
	movem.l	front,a0-a1			; Get the front and back screens
	move	#(32000/4)-1,d0			; For the 32000 bytes do...
.loop	move.l	(a0)+,(a1)+			;   Copy "front" onto "back"
	dbf	d0,.loop			; Next longword please
	rts

* CUSTOM VBL - Doesn't really do much does it? It's only really there to
; provide a vbl timer for the demo routines. The system also alters
; timer.w ($468), so this is only really for the routines where we need to
; countdown a specific number of vbls. The other main reason of course is
; to switch off the system vbl in case it does something styoopid that our
; demo didn't expect! (eg the screensaver in NVDI, which switched off the
; display near the end of a test-run of the demo!!)

vbl_timer
	subq.w	#1,timer.w			; Count-down progressing...
	rte

* INCLUDED SOURCE CODE

	include	includes\genbin.s		; Code used by some of the macros.
	include	includes\key_mid.s		; Keyboard routines
	include	sound\nmdepack.s		; Noisepakker module depack code.
	include	sound\tracker.s			; DSP Tracker code.

	section data

t_presents	dc.b	'proundly',13
		dc.b	'PRESENTS',0

* Frosty sequence sprites- all single plane

frosty_dat	incbin	graphics\frosty.fnt	; Frosty (176 X 157)
frosty	equ	frosty_dat+50
frosty_boot_dat	incbin	graphics\frosty2.fnt	; boot (320 x 176)
frosty_boot	equ	frosty_boot_dat+50

* Rudolf sprites- single plane
rudolf_dat1	incbin	graphics\rudolf.fnt	; Rudolf (160 X 60)
rudolf1	equ	rudolf_dat1+50
rudolf_alive	equ	rudolf1
rudolf_dead	equ	rudolf1+(10*2*60)
rudolf_dat2	incbin	graphics\rudolf2.fnt	; Santa_gun (160 X 160)
rudolf2	equ	rudolf_dat2+50
santa_gun1	equ	rudolf2
santa_gun2	equ	rudolf2+(10*2*138)

* Spice dad sprites (129X101)
spice_dat1	incbin	graphics\spice1.fnt
spice_dat2	incbin	graphics\spice2.fnt

s_size	equ	(9*2*101)

s_intro		equ	spice_dat1+50
s_wacky		equ	s_intro+s_size
s_scene		equ	s_wacky+s_size
s_arty		equ	s_scene+s_size
s_grumpy	equ	spice_dat2+50
s_amiga		equ	s_grumpy+s_size
s_dadpower	equ	s_amiga+s_size

* 16 colour pictures - All 320 X 200 and Degas format

presents	incbin	graphics\xmas_sad.pi1		; "Senior Dads presents..."
snowfall_pic	incbin	graphics\snowfall.pi1		; Snowfall scene by itself
santa1		incbin	graphics\santa1.pi1		; "Is it a bird? Is it a plane? etc"
santa2		incbin	graphics\santa2.pi1		; "CRUMP! Ho ho ho! etc"
jingle1		incbin	graphics\jingle1.pi1		; Jingle bells piccy
jingle2		incbin	graphics\sleigh.pi1		; Santa on Sleigh
blobs		incbin	graphics\blobs.pi1		; Blobs!
tv		incbin	graphics\tv.pi1			; end pic
noddy		incbin	graphics\slade.pi1		; noddy pic
end_pic		incbin	graphics\end.pi1		; end pic

* Trucolour pictures - 320 X 200, and in raw headerless format.

title_pic	incbin	graphics\xmas97.tru		; main title pic
ehoh_pic	incbin	graphics\ehoh.tru		; "Telegrumpies" pic
greets_pic	incbin	graphics\dadmas.tru		; "Happy Dadmas" pic
card_pic	incbin	graphics\dadcard.tru		; "Dadcard" pic

who		incbin	graphics\who.tru		; Who are the SD?
oldfart		incbin	graphics\oldfart.tru		
dodgit		incbin	graphics\dodgit.tru		
damevera	incbin	graphics\vera.tru		
jackpol		incbin	graphics\jp.tru		
cbag		incbin	graphics\cbag.tru		

* Font

main_font:	incbin	graphics\crapfont.dat
	even
end_main_font:

* Mode data for RGB and VGA monitors
; There's hardware data for Trucolour mode, and a mode number for
; a TOS call into ST-lores. This appears to work on all TOS versions
; on both RGB and VGA displays.

trucol_inf	incbin	graphics\tru_rgb.asa		{- RGB data
lores_inf	dc.w	$a2				{
end_infs

trucol_vga_inf	incbin	graphics\tru_vga.asa		{- VGA data
lores_vga_inf	dc.w	$1b2				{

* Bitmap pattern for "bomb". Copied out of ST Internals BIOS listing.

bomb_dat
	dc.w	%0000011000000000
	dc.w	%0010100100000000
	dc.w	%0000000010000000
	dc.w	%0100100001000000
	dc.w	%0001000111110000
	dc.w	%0000000111110000
	dc.w	%0000011111111100
	dc.w	%0000111111111110
	dc.w	%0000111111111110
	dc.w	%0001111111111111
	dc.w	%0001111111101111
	dc.w	%0000111111101110
	dc.w	%0000111111011110
	dc.w	%0000011111111100
	dc.w	%0000001111111000
	dc.w	%0000000011100000

* Pointers to front and back screens. These two pointers are assumed to
; be next to each other, so don't go seperating them!

front	dc.l	end_code+(256*2)
back	dc.l	end_code+(320*220*2)+(256*3)

m_s
main_module	incbin	sound\xmas96.mop
main_module_end 
	ds.b	115384-(main_module_end-main_module)
m_e

* Now the bss variables. Note that a "section bss" was already called in
; the tracker code included before here, so the first bss variable is
; actually the workspace for the module player.

	section	bss

abort_demo		ds.b	1	; True if UNDO or CTRL-ALT-DEL pressed
prime_abort_sequence	ds.b	1	; True if CTRL-ALT pressed (Waiting for DEL)

oldphys			ds.l	1	; Old physical screen base
oldlog			ds.l	1	; Old logical screen base
oldrez			ds.w	1	; Old screen resolution
oldwidth		ds.w	1	; Old screen width
old_vbl			ds.l	1	; Old VBL routine

c16cols	ds.w	18			; Custom colour palette

old_c16cols	
	ds.w	16			; Old 16 colour palette
old_c256cols
	ds.l	256			; Old 256 colour palette

bomb_tru				; Trucol bomb
	ds.w	16*16

small_font
	ds.b	(8*('~'-' '))		; Store for 8X8 font.
small_font_end

trucol_font
	ds.w	((8*8)*('~'-' '))	; Store for trucol 8X8 font

trucol_main_font
	ds.w	320*100
trucol_main_font_end

* THE END! *

end_code

