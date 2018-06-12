//Code section for drawing the main menu
.section .text

img_hi_aftergame = 200		//image height after game is over (win/lose)
img_hi_menuscreen = 800		//image height of main menu
img_hi_curser = 40			//image height of visual indicator/curser

.global gameOver_screen
gameOver_screen:
//drawing the "Game Over" screen
	push	{lr}
	mov	r0, #600		//"Game Over" text screen width
	str 	r0, [fp, #12]
	mov 	r0, #img_hi_aftergame	
	str 	r0, [fp, #16]		//address of image as 1st argument
	bl	get_gameover_text	//get the "Game Over" text picture
	mov	r1, #610		//x as 2nd argument 
	mov 	r2, #485		//y as 3rd argument
	mov	r3, fp			//fp as 4th argument
	bl	draw_img		//branch to draw_img
	pop	{lr}
	bx	lr

.global win_screen
win_screen:
//drawing the "Winner" screen
	push	{lr}
	mov	r0, #600		//"Winner" text screen width
	str	r0, [fp, #12]
	mov	r0, #img_hi_aftergame
	str	r0, [fp, #16]		//address of image as 1st argument
	bl	get_win_text		//get the "Winner" text picture
	mov	r1, #610		//x as 2nd argument 
	mov 	r2, #485		//y as 3rd argument
	mov	r3, fp			//fp as 4th argument
	bl	draw_img		//branch to draw_img
	pop	{lr}
	bx	lr

.global main_menu_screen
main_menu_screen:
//drawing the main menu	
	push	{lr}
	mov	r0, #600		//the main menu screen width
	str	r0, [fp, #12]
	mov	r0, #img_hi_menuscreen
	str	r0, [fp, #16]		//address of image as 1st argument
	bl	get_menu_screen		//get the main menu screen picture
	mov	r1, #610		//x as 2nd argument 			
	mov 	r2, #125		//y as 3rd argument
	mov	r3, fp			//fp as 4th argument
	bl	draw_img		//branch to draw_img

//drawing the visual indicator/curser on "Play"
	mov	r0, #60			//visual indicator/curser width
	str	r0, [fp, #12]
	mov	r0, #img_hi_curser
	str	r0, [fp, #16]		//address of image as 1st argument
	bl	get_curser		//get the visual indicator/curser picture
	mov	r1, #740		//x as 2nd argument 
	mov 	r2, #500		//y as 3rd argument 
	mov	r3, fp			//fp as 4th argument
	bl	draw_img		//branch to draw_img
	pop	{lr}
	bx	lr


.global main_menu_quit
main_menu_quit:
//drawing the main menu	
	push	{lr}
	mov	r0, #600		//the main menu screen width
	str	r0, [fp, #12]
	mov	r0, #img_hi_menuscreen
	str	r0, [fp, #16]		//address of image as 1st argument
	bl	get_menu_screen		//get the main menu screen picture
	mov	r1, #610		//x as 2nd argument 
	mov 	r2, #125		//y as 3rd argument
	mov	r3, fp			//fp as 4th argument
	bl	draw_img		//branch to draw_img

//drawing the visual indicator/curser on "Quit"
	mov	r0, #60			//visual indicator/curser width
	str	r0, [fp, #12]
	mov	r0, #img_hi_curser
	str	r0, [fp, #16]		//address of image as 1st argument
	bl	get_curser		//get the visual indicator/curser picture
	mov	r1, #740		//x as 2nd argument	
	mov 	r2, #590		//y as 3rd argument
	mov	r3, fp			//fp as 4th argument
	bl	draw_img		//branch to draw_img
	pop	{lr}
	bx	lr


//Data section	
.section .data
.align 2
