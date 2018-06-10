@ Code section
.section .text

img_hi_aftergame = 200
img_hi_menuscreen = 800
img_hi_curser = 40

.global gameOver_screen
gameOver_screen:
	push	{lr}
	mov	r0, #600
	str 	r0, [fp, #12]
	mov 	r0, #img_hi_aftergame
	str 	r0, [fp, #16]

	bl	get_gameover_text
	mov	r1, #610		//x 
	mov 	r2, #485		//y 
	mov	r3, fp
	bl	draw_img

	pop	{lr}
	bx	lr

.global win_screen
win_screen:
	push	{lr}
	mov	r0, #600
	str	r0, [fp, #12]
	mov	r0, #img_hi_aftergame
	str	r0, [fp, #16]

	bl	get_win_text
	mov	r1, #610	
	mov 	r2, #485	
	mov	r3, fp
	bl	draw_img

	pop	{lr}
	bx	lr

.global main_menu_screen
main_menu_screen:
	push	{lr}
	mov	r0, #600
	str	r0, [fp, #12]
	mov	r0, #img_hi_menuscreen
	str	r0, [fp, #16]

	bl	get_menu_screen
	mov	r1, #610			
	mov 	r2, #125		
	mov	r3, fp
	bl	draw_img

//drawing the menu initially (curser on "Play")
	mov	r0, #60
	str	r0, [fp, #12]
	mov	r0, #img_hi_curser
	str	r0, [fp, #16]

	bl	get_curser
	mov	r1, #740	
	mov 	r2, #500	
	mov	r3, fp
	bl	draw_img

	pop	{lr}
	bx	lr


.global main_menu_quit
main_menu_quit:
	push	{lr}
	mov	r0, #600
	str	r0, [fp, #12]
	mov	r0, #img_hi_menuscreen
	str	r0, [fp, #16]

	bl	get_menu_screen
	mov	r1, #610			
	mov 	r2, #125		
	mov	r3, fp
	bl	draw_img

//curser on "Quit"
	mov	r0, #60
	str	r0, [fp, #12]
	mov	r0, #img_hi_curser
	str	r0, [fp, #16]

	bl	get_curser
	mov	r1, #740	
	mov 	r2, #590	
	mov	r3, fp
	bl	draw_img

	pop	{lr}
	bx	lr

@ Data section
.section .data

.align 2
