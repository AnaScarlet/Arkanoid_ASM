.global main
.global draw_img
.balign 4

img_wid = 60
img_hi = 40
tiles_minX = 612
tile0_minY = 247 
tile1_minY = 287
tile2_minY = 327
tile3_minY = 367
tile4_minY = 407
tile5_minY = 447

tile0_maxY = 287 
tile1_maxY = 327
tile2_maxY = 367
tile3_maxY = 407
tile4_maxY = 447
tile5_maxY = 487


main:
	push {fp, lr}
	sub sp, #20
	mov fp, sp

	ldr r0, =frameBufferInfo 	// frame buffer information structure
	bl initFbInfo			// from the C file

	ldr r0, =frameBufferInfo
	ldr r1, [r0]
	ldr r2, [r0, #4]
	ldr r3, [r0, #8]

	str r1, [fp]			// frame buffer pointer
	str r2, [fp, #4]		// screen width
	str r3, [fp, #8]		// screen height

////////////////////// initial screen ////////////////////////////////////////////
	mov r1, #0			// x coordinate of image's top left corner
	mov r2, #35			// y coordinate of image's top left corner
	mov r3, fp
	bl draw_black

	mov r4, #572
	mov r5, #87
	mov r0, #img_hi
	str r0, [fp, #12]
	mov r0, #img_hi
	str r0, [fp, #16]

top_wall_loop:
	bl get_d_brick_t
	mov r1, r4
	mov r2, r5
	mov r3, fp
	bl draw_img
	add r4, #img_hi
	ldr r0, =#1212
	cmp r4, r0
	ble top_wall_loop

	mov r4, #572
	mov r5, #127
	// image dimentions stay the same

side_wall_loop:
	bl get_d_brick_l
	mov r1, r4
	mov r2, r5
	mov r3, fp
	bl draw_img
	add r5, #img_hi
	cmp r5, #888
	ble side_wall_loop

	ldr r0, =#1212
	cmp r4, r0
	beq next
	movne r4, r0
	movne r5, #127
	bne side_wall_loop

next:
	mov r0, fp
	bl controller

	add sp, #20
	pop {fp, lr}
	bx lr

count .req r8
row_state .req r7

draw_grid:
	push {r4, r5, r6, fp, lr}
	mov fp, r0			// same as main's fp

	mov r4, #612
	mov r5, #127
	mov r0, #img_wid
	str r0, [fp, #12]
	mov r0, #img_hi
	str r0, [fp, #16]


floor_loop:
	mov r1, r4
	mov r2, r5
	mov r3, fp			// pass the address of stack variables
	ldr r0, =#847
	cmp r5, r0
	bl get_floor_tile
	bleq draw_paddle_floor
	blne draw_img
	add r4, #img_wid
	cmp r4, #1152
	ble floor_loop

	mov r4, #612
	add r5, #img_hi
	cmp r5, #207
	ble floor_loop
	ldr r0, =#487
	cmp r5, r0
	movlt r5, r0
	cmp r5, #888
	ble floor_loop

	mov r4, #tiles_minX
	mov r5, #tile0_minY
	mov r0, #img_wid
	str r0, [fp, #12]
	mov r0, #img_hi
	str r0, [fp, #16]
	bl get_gray_brick
	ldr r7, =tile_row0		// get the row's state
	ldr row_state, [r7]
	mov r6, r0
	mov count, #0

bricks_loop:
	mov r0, #1
	lsl r1, count, #1		// r1 = count * 3
	add r2, r1, count
	lsl r0, r2			// 1 at the tile's firt bit in row state
	lsl r0, #2			// 1 at the tile's third bit in row state
	and r1, row_state, r0		// row state (r7) AND bit mask (r0) = r1 (changes r1)
	teq r1, r0			// if the tile's third bit was a 1
	add count, #1			// increment counter
	beq brick			// and go on to the next tile
					// otherwise... draw the tile
floor:
	ldr r0, =get_floor_tile
	mov r1, r4
	mov r2, r5
	mov r3, fp
	bl draw_img

//	ldr	r0, =score
//	ldr	r1, [r0]
//	add	r1, #1
//	str	r1, [r0]
//	bl	check_win

	add r4, #img_wid
	cmp r4, #1152
	ble bricks_loop	
	bgt outer

brick:
	mov r0, r6
	mov r1, r4
	mov r2, r5
	mov r3, fp
	bl draw_img
	add r4, #img_wid
	cmp r4, #1152
	ble bricks_loop	

outer:	add r5, #40
	mov r4, #tiles_minX
	ldr r1, =#tile1_minY
	cmp r5, r1
	bleq get_red_brick
	ldreq r7, =tile_row1		// get the row's state
	ldreq row_state, [r7]
	beq o_end
	ldr r1, =#tile2_minY
	cmp r5, r1
	bleq get_purple_brick
	ldreq r7, =tile_row2		// get the row's state
	ldreq row_state, [r7]
	beq o_end
	ldr r1, =#tile3_minY
	cmp r5, r1
	bleq get_blue_brick
	ldreq r7, =tile_row3		// get the row's state
	ldreq row_state, [r7]
	beq o_end
	ldr r1, =#tile4_minY
	cmp r5, r1
	bleq get_yellow_brick
	ldreq r7, =tile_row4		// get the row's state
	ldreq row_state, [r7]
	beq o_end
	ldr r1, =#tile5_minY
	cmp r5, r1
	bleq get_green_brick
	ldreq r7, =tile_row5		// get the row's state
	ldreq row_state, [r7]

o_end:	mov r6, r0
	ldr r1, =#tile5_minY
	cmp r5, r1
	movle count, #0
	ble bricks_loop

	bl printBricks

	mov r0, #680
	str r0, [fp, #12]
	mov r0, #img_hi
	str r0, [fp, #16]

	bl get_score_lives_text
	mov r1, #572
	mov r2, #35
	mov r3, fp
	bl draw_img

	pop {r4, r5, r6, fp, lr}
	bx lr


delay .req r4
released .req r5

controller:
	push 	{r4, r5, lr}
	mov fp, r0				// same fp as main

	bl	init_snes
	
	mov 	r0, #120
	str 	r0, [fp, #12]
	mov 	r0, #img_hi
	str 	r0, [fp, #16]

	bl	get_paddle			// returns address of image in r0
	ldr 	r2, =paddle_location
	ldr 	r1, [r2]			// paddle location x
	ldr 	r2, [r2, #4]			// paddle location y
	mov 	r3, fp
	bl 	draw_img

	mov	r0, fp
	bl	draw_ball
	b	draw
	
draw_loop:					// infinite loop
	mov	r0, #8000
	bl	delayMicroseconds

	bl	Read_SNES

	ldr	r1, =Win_Flag
	ldr	r2, [r1]
	cmp	r2, #1
	beq	win_options
	
	ldr	r1, =Lose_Flag
	ldr	r2, [r1]
	cmp	r2, #1
	beq	lose_options
	
	ldr	r1, =menu_flag
	ldr	r1, [r1]

	cmp	r1, #1
	bne	menu_buttons
	beq	game_buttons
	
menu_buttons:
	cmp	r0, #2
	beq	A_Move

	cmp	r0, #10
	beq	Up_Move

	cmp	r0, #11
	beq	Down_Move
	b	draw

game_buttons:	
	cmp	r0, #3
	moveq	r2, #10
	beq	Right_Move

	cmp	r0, #4
	moveq	r2, #10
	beq	Left_Move
	
	cmp	r1, #1
	cmpeq	r0, #5
	beq	Start_Move

	cmp	r0, #6
	beq	Select_Move

	cmp	r0, #7
	beq	B_Move
	
	cmp	r0, #8
	moveq	r2, #20
	beq	Left_Move
	
	cmp	r0, #9
	moveq	r2, #20
	beq	Right_Move
	b	draw_cont
	
A_Move:
	ldr	r0, =menu_option
	ldr	r0, [r0]
	cmp	r0, #1
	beq	end_loop

	ldr	r1, =menu_flag
	mov	r2, #1
	str	r2, [r1]
	b	draw
	
Up_Move:
	ldr	r0, =menu_option
	ldr	r1, [r0]
	
	cmp	r1, #0				// check menu_option
	beq	draw				// draw

	mov	r1, #0
	str	r1, [r0]			// change menu_option up
	b	draw
	
Down_Move:
	ldr	r0, =menu_option
	ldr	r1, [r0]

	cmp	r1, #0				// check menu_option
	bne	draw				// draw
	
	mov	r1, #1
	str	r1, [r0]	
	b	draw

Right_Move:
	ldr	r0, =paddle_location
	ldr	r1, [r0]
	add	r1, r2
	ldr	r3, =#1092
	cmp	r1, r3
	movgt	r1, #1092
	str	r1, [r0]			// change paddle location's x
	b	draw
Left_Move:
	ldr	r0, =paddle_location
	ldr	r1, [r0]
	sub	r1, r2
	ldr 	r3, =#612
	cmp	r1, r3
	movlt	r1, r3
	str	r1, [r0]
	b	draw
Start_Move:
	bl	hard_reset
	mov 	released, #0			// reset b flag

	b	draw
	
Select_Move:
	mov	r1, #0
	ldr	r0, =menu_flag
	str	r1, [r0]
	ldr	r0, =menu_option
	str	r1, [r0]

	bl	hard_reset
	mov	released, #0
	
	b	draw
	
B_Move:	
	mov released, #1
	b draw

win_options:
	push	{r0}
	bl	win_screen
	pop	{r0}
	cmp	r0, #0
	beq	draw_loop

	mov	r0, #0
	ldr	r1, =Win_Flag
	str	r0, [r1]
	b	end_options

lose_options:
	push	{r0}
	bl	gameOver_screen
	pop	{r0}
	cmp	r0, #0
	beq	draw_loop

	mov	r0, #0
	ldr	r1, =Lose_Flag
	str	r0, [r1]
	
end_options:
	mov	r0, #40000
	bl	delayMicroseconds

	mov	r0, #0
	mov	released, r0
	ldr	r1, =menu_flag
	str	r0, [r1]
	ldr	r1, =menu_option
	str	r0, [r1]
	bl	hard_reset
	b	draw
	
draw:	
	ldr	r0, =menu_flag
	ldr	r0, [r0]
	cmp	r0, #0
	bne	draw_cont

	ldr	r0, =menu_option
	ldr	r0, [r0]
	cmp	r0, #0
	beq	print_play
	bne	print_quit

print_play:
	bl	main_menu_screen
	b	draw_loop
	
print_quit:
	bl	main_menu_quit
	b	draw_loop	
	
draw_cont:	
	mov r0, fp
	bl draw_grid

	mov 	r0, #120
	str 	r0, [fp, #12]
	mov 	r0, #img_hi
	str 	r0, [fp, #16]

	ldr 	r0, =paddle_location
	ldr 	r1, [r0]		// get x
	ldr 	r2, [r0, #4]		// get y
	bl	get_paddle		// get image address
	mov 	r3, fp
	bl 	draw_img


// draw numbers
	mov r0, fp
	ldr r1, =score
	ldr r1, [r1]
	ldr r2, =#702
	mov r3, #48
	bl draw_number

	mov r0, fp
	ldr	r1, =lives
	ldr	r1, [r1]
	ldr r2, =#1172
	mov r3, #48
	bl draw_number

	mov	r0, fp
	mov	r1, released
	bl	move_ball
	mov	released, r0
	
	mov	r0, fp
	mov	r1, released
	bl	draw_ball
	
	b	draw_loop
	
end:	
	pop 	{r4, r5, lr}
	bx 	lr
/////////////////////////////////////////////////////////////////////////
hard_reset:	
	ldr	r0, =score
	mov	r1, #0
	str	r1, [r0]
	ldr	r0, =lives
	mov	r1, #3
	str	r1, [r0]

	ldr	r0, =tile_row0
	ldr	r1, =0x24924924
	str	r1, [r0]
	ldr	r0, =tile_row1
	str	r1, [r0]
	ldr	r0, =tile_row2
	str	r1, [r0]
	ldr	r0, =tile_row3
	str	r1, [r0]
	ldr	r0, =tile_row4
	str	r1, [r0]
	ldr	r0, =tile_row5
	str	r1, [r0]

	ldr	r0, =movingBrick2		//load x, y, friction, and activation of 2nd bonus brick
	ldr	r1, =#792			//load 792 (x) into r1
	str	r1, [r0]			//store it into r1
	ldr	r1, =#367			//load 367 (y) into 1
	str	r1, [r0, #4]			//store y into r1
	mov	r1, #0				//move 0 into r1
	str	r1, [r0, #12]			//store activation into r1
	
	ldr	r0, =movingBrick3		//load x, y, friction, and activation of 3rd bonus brick
	ldr	r1, =#1032			//load 1032 (x) into r1
	str	r1, [r0]			//store it into r1
	ldr	r1, =#447			//load 367 (y) into 1
	str	r1, [r0, #4]			//store y into r1
	mov	r1, #0				//move 0 into r1
	str	r1, [r0, #12]			//store activation into r1
	

soft_reset:
	ldr	r0, =paddle_location		// reset paddle location
	mov	r1, #850
	str	r1, [r0]
	str	r1, [r0, #4]

	ldr	r0, =ball_location		// reset ball location
	mov	r1, #895
	str	r1, [r0]
	mov	r1, #820
	str	r1, [r0, #4]
	mov	r1, #5
	str	r1, [r0, #8]
	mov	r1, #-5
	str	r1, [r0, #12]
	
	bx	lr
	
////////////////////////////////////////////////////////////////////////////	
move_ball:
	push	{r6, r7, fp, lr}

	paddle	.req	r6
	ball	.req	r7
	
	mov	fp, r0
	
	ldr	paddle, =paddle_location
	ldr	ball, =ball_location

	cmp	r1, #1
	beq	x_motion


	ldr	r0, [paddle]
	add	r0, #45
	str	r0, [ball]
	b	move_ball_end

x_motion:
	ldr	r0, [ball]		// load ball x to r0
	ldr	r1, [ball, #8]		// load ball x dir to r1
	add	r0, r1
	str	r0, [ball]

	ldr 	r2, =#615
	cmp	r0, r2		// check left bound
	negle	r1, r1
	strle	r1, [ball, #8]
	
	ldr	r2, =#1178
	cmp	r0, r2			// check right bound
	negge	r1, r1
	strge	r1, [ball, #8]

y_motion:	
	ldr	r0, [ball, #4]		// load ball y to r0
	ldr	r1, [ball, #12]		// load ball y dir to r1
	add	r0, r1
	str	r0, [ball, #4]

	cmp	r0, #130
	negle	r1, r1
	strle	r1, [ball, #12]

	ldr	r2, =#835
	cmp	r0, r2
	bge	lose_life
	ldr	r2, =#820
	cmp	r0, r2
	bge	check_paddle
	cmp	r0, #247
	ble	y_next

	ldr	r1, =#487
	cmp	r0, r1
	ble	check_brick
y_next:	
	mov	r0, #1
	b	move_ball_end
	
check_paddle:
	ldr	r0, [ball]		// r0 = ball x
	ldr	r1, [paddle]		// r1 = paddle x
	sub	r0, r1
	cmp	r0, #-30
	ble	lose_life
	cmp	r0, #-1
	ble	left_side_hit
	cmp	r0, #120
	bgt	lose_life
	cmp	r0, #92
	bgt	right_side_hit
	
// ball hit middle of paddle
	ldr	r0, [ball, #12]
	neg	r0, r0
	str	r0, [ball, #12]
	mov	r0, #1			// return #1
	b	move_ball_end

left_side_hit:
	mov	r1, #-5
	str	r1, [ball, #8]
	str	r1, [ball, #12]
	mov	r0, #1			// return #1
	b	move_ball_end

right_side_hit:
	mov	r1, #5
	str	r1, [ball, #8]
	mov	r1, #-5
	str	r1, [ball, #12]
	mov	r0, #1			// return #1
	b	move_ball_end
	
check_brick:
	ldr	r0, [ball]
	bl	divFuncX
	mov	r1, r0
	ldr	r0, [ball, #4]
	bl	divFuncY
	push 	{r0, r1}
	bl	check_brick_state

	cmp	r0, #1
	beq	hit_brick

	pop 	{r0, r1}
	mov	r0, #1
	b	move_ball_end
	
hit_brick:
	pop 	{r0, r1}
	ldr	r3, [ball]
	ldr	r2, [ball, #4]
	push	{r0, r1}

	bl	update_tile_state

	push	{r0, r1, r2, r3}
	ldr	r0, =printx
	ldr	r1, =tile_row1
	ldr	r1, [r1]
//	bl	printf
	pop	{r0, r1, r2, r3}

//	ballx = r0, bally = r1, col = r2, row = r3
check_x:
	ldr	r0, [ball]
	ldr	r1, [ball, #4]
	pop	{r2, r3}
	mov	r4, #60
	mul	r4, r2, r4
	add	r4, #612
	sub	r4, r0, r4		// r4 = ballx - brick left edge
	
	cmp	r4, #-30
	ble	neg_x
	cmpgt	r4, #60
	bgt	neg_x
	
neg_y:
	ldr	r0, [ball, #8]
	neg	r0, r0
	str	r0, [ball, #8]
	b	end_hit_brick
	
check_y:
	mov	r4, #40
	mul	r4, r3
	add	r4, #247
	sub	r4, r1, r4

	cmp	r4, #-30
	ble	neg_y
	cmpgt	r4, #40
	bgt	neg_y

neg_x:
	ldr	r0, [ball, #12]
	neg	r0, r0
	str	r0, [ball, #12]

end_hit_brick:	
//	ldr	r0, =score
//	ldr	r1, [r0]
//	add	r1, #1
//	str	r1, [r0]

	b	check_win
	
lose_life:
	ldr	r0, =lives
	ldr	r1, [r0]
	sub	r1, #1	
	str	r1, [r0]
	cmp	r1, #0
	ble	game_over

	str	r1, [r0]
	bl	soft_reset
	b	move_ball_end

check_win:
	ldr	r0, =#460175067
	ldr	r1, =tile_row0
	ldr	r1, [r1]
	cmp	r0, r1
	bne	end_win
	ldr	r0, =#153391689
	ldr	r1, =tile_row1
	ldr	r1, [r1]
	cmp	r0, r1
	bne	end_win
	ldr	r1, =tile_row2
	ldr	r1, [r1]
	cmp	r0, r1
	bne	end_win
	mov	r0, #0
	ldr	r1, =tile_row3
	ldr	r1, [r1]
	cmp	r0, r1
	bne	end_win
	ldr	r1, =tile_row4
	ldr	r1, [r1]
	cmp	r0, r1
	bne	end_win
	ldr	r1, =tile_row5
	ldr	r1, [r1]
	cmp	r0, r1
	bne	end_win

	ldr	r0, =Win_Flag
	mov	r1, #1
	str	r1, [r0]
end_win:
	mov	r0, #1
	b	move_ball_end
	
game_over:
//	mov	r0, fp
//	ldr r2, =#1172
//	mov r3, #48
//	bl draw_number	

	ldr	r0, =Lose_Flag
	ldr	r1, [r0]
	mov	r1, #1
	str	r1, [r0]

//	bl	gameOver_screen
	
	mov	r0, #0
move_ball_end:	
	pop	{r6, r7, fp, lr}
	bx	lr

////////////////////////////////////////////////////////////////////////////
//	args:	r0 = row num
//		r1 = column num
//	return:	r0 = 1 if tile exists, 0 is tile does not
/////////////////////////////////////////////////////////////////////////	
check_brick_state:
	row	.req	r0
	column	.req	r1
	row_s	.req	r2
	push	{r4, lr}	
	mov	r4, r0			//move r0 into r4 to avoid being overwitten

	cmp 	row, #0			// tile row 0
	ldreq	row_s, =tile_row0
	ldreq	row_s, [row_s]
	cmp 	row, #1
	ldreq	row_s, =tile_row1
	ldreq	row_s, [row_s]
	cmp	row, #2
	ldreq	row_s, =tile_row2
	ldreq	row_s, [row_s]
	cmp 	row, #3
	ldreq	row_s, =tile_row3
	ldreq	row_s, [row_s]
	cmp 	row, #4
	ldreq	row_s, =tile_row4
	ldreq	row_s, [row_s]
	cmp 	row, #5
	ldreq	row_s, =tile_row5
	ldreq	row_s, [row_s]

	mov	r3, #3
	mul	r3, column, r3		// r3 = column * 3
	mov	r0, #1			// r0 = 
	lsl 	r0, r3			// 1 at the tile's first bit in row state
	lsl	r0, #2			// 1 at the tile's third bit in row state

	and 	r3, row_s, r0		// row state (row_s) AND bit mask (r0) = r3 (changes r3)


//this subroutines checks if brick 3 is activated (aka been hit)
sactivate3:
	push	{r0, r1, r2, r3, r4, r5}
	cmp	r4, #5			//compare row # to 5
	bne	catch3			//if row # is not equal to 5, branch to catch3
	cmp	r1, #7			//compare colume # to 7
	bne	catch3			//if colume # is not equal to 7, branch to catch3
	teq 	r3, r0			//check if brick has been hit
	ldr	r0, =movingBrick3	//load x, y, friction, and activation of 3rd bonus brick
	ldr	r1, [r0, #12]		//load activation
	cmp	r1, #1			//compare activation to 1
	beq	catch3			//if they equal, branch to catch3
	cmp	r1, #0			//compare activation to 0
	mov	r1, #1			//move 1 into r1
	str	r1, [r0, #12]		//store activation into r1

catch3:
	ldr	r0, =movingBrick3	//load x, y, friction, and activation of 3rd bonus brick
	ldr	r1, [r0, #12]		//load activation
	cmp	r1, #-1			//compare activation to -1
	beq	next3			//if they equal, go to next3
	ldr	r1, [r0, #4]		//load y into r1
	ldr	r2, =#810		//load 810 into r2
	cmp	r1, r2			//compare y and 810
	blt	next3			//if y < 810, branch to next3
	ldr	r1, [r0]		//load r0 into y
	ldr	r2, =paddle_location	//load paddle's location
	ldr	r2, [r2]		
	add	r1, #60			//add 60 to y
	cmp	r1, r2			//compare paddle's location to y
	blt	next3			//if paddle's location < y, branch to next3
	sub	r1, #60			//subtract 60 from y
	add	r2, #120		//add 120 to the paddle's location
	cmp	r1, r2			//compare paddle's location to y
	bgt	next3			//if paddle's location > y, branch to next3

	ldr	r0, =score		//load score
	ldr	r1, [r0]		//load it into r1
	add	r1, #5			//add 5 to it if paddle catches bonus brick
	str	r1, [r0]		//store into r1

	ldr	r0, =movingBrick3	//load x, y, friction, and activation of 3rd bonus brick
	bl	StopsBrick		//branch and link to StopsBrick
next3:
	pop	{r0, r1, r2, r3, r4, r5}

	and 	r3, row_s, r0
	teq 	r3, r0			// if the tile's third bit was a 1
	moveq	r0, #1
	movne	r0, #0

	pop	{r4, lr}		
	bx	 lr			//returns

// SACTIVATE brick 2
sactivate2:
//	push	{r0, r1, r2, r3, r4, r5}
	cmp	r4, #3
	bne	catch2
	cmp	r1, #3
	bne	catch2
	teq 	r3, r0				
	bne	catch2
	ldr	r0, =movingBrick2
	ldr	r1, [r0, #12]
	cmp	r1, #1
	beq	catch2
	cmp	r1, #0
	mov	r1, #1
	str	r1, [r0, #12]
catch2:
	ldr	r0, =movingBrick2
	ldr	r1, [r0, #12]
	cmp	r1, #-1
	beq	next2
	ldr	r1, [r0, #4]
	ldr	r2, =#810
	cmp	r1, r2
	blt	next2
	ldr	r1, [r0]
	ldr	r2, =paddle_location
	ldr	r2, [r2]
	add	r1, #60
	cmp	r1, r2
	blt	next2
	sub	r1, #60
	add	r2, #120
	cmp	r1, r2
	bgt	next3

	ldr	r0, =score
	ldr	r1, [r0]
	add	r1, #5
	str	r1, [r0]

	ldr	r0, =movingBrick2
	bl	StopsBrick

next2:
	pop	{r0, r1, r2, r3, r4, r5}

	and 	r3, row_s, r0
	teq 	r3, r0			// if the tile's third bit was a 1
	moveq	r0, #1
	movne	r0, #0
	pop	{r4, lr}		
	bx	 lr

	
/////////////////////////////////////////////////////////////////////////////
draw_ball:
	push	{fp, lr}

	mov	fp, r0
	mov	r0, #30
	str	r0, [fp, #12]
	str	r0, [fp, #16]
	bl	get_soccer_ball
	ldr	r3, =ball_location
	ldr	r1, [r3]
	ldr	r2, [r3, #4]
	mov	r3, fp
	bl	draw_img
	
	pop	{fp, lr}
	bx	lr


width .req r4
height .req r5
fb_ptr .req r6
fb_offset .req r7
i_r .req r8
img_wid .req r9
img_hi .req r10
addr .req r11
j_r .req r12

s_wid: .string "%d\n"
s_hi: .string "%d\n"

// Agrs:
//	r0 = address of image
//	r1 = width (x)
//	r2 = height (y)
//	r3 = pointer to stack arguments

draw_black: 
	push {width, height, fb_ptr, fb_offset, i_r, j_r, lr}

	ldr fb_ptr, [r3]
	ldr width, [r3, #4]
	ldr height, [r3, #8]

// element fb_offset = (y * width) + x
	mul fb_offset, r2, width
	add fb_offset, r1

// physical fb_offset *= 4 (each pixel is 4 bytes in size)
	lsl fb_offset, #2

	mov j_r, #0
	mov i_r, #0

loop:
	mov r0, #0xFF000000
	str r0, [fb_ptr, fb_offset]
	add i_r, #1	
	add fb_offset, #4		// increment fb horizontally (by 4 bytes ie 1 px) 
	cmp i_r, #1824		// if i_r < 16*4 (image length in bytes),
	blt loop

	mov i_r, #0
	add j_r, #1			// increment vertically
	cmp j_r, #948
	ble loop

	pop {width, height, fb_ptr, fb_offset, i_r, j_r, lr}
	bx lr


draw_paddle_floor: 
	push {width, height, fb_ptr, fb_offset, i_r, addr, j_r, lr}

	mov addr, r0
	ldr fb_ptr, [r3]
	ldr width, [r3, #4]
	ldr height, [r3, #8]
	ldr img_wid, [r3, #12]
	ldr img_hi, [r3, #16] 

// element fb_offset = (y * width) + x
	mul fb_offset, r2, width
	add fb_offset, r1

// physical fb_offset *= 4 (each pixel is 4 bytes in size)
	lsl fb_offset, #2

// calculate the width to shift the offet by to go to the next line
	lsl width, #2
	mov j_r, #0
	mov i_r, #0

loop1:
	add r2, r1, i_r			// r2 = tile min x + i = current x
	add r3, r1, img_wid		// r3 = tile max x
	ldr r0, =paddle_location
	ldr r0, [r0]			// paddle min x

	cmp r1, r0			// is tile min > paddle min? (on right side of paddle)
	bgt right_of	
	cmp r2, r0			// if current x < paddle min x
	blt nxt				// draw the pixel
	cmp i_r, img_wid
	bge skip
	b skip_px			// and skip drawing the pixel

right_of:
	add r0, #120			// get paddle max x
	cmp r2, r0			// if curren x > paddle max x
	bge nxt				// draw the pixel
	cmple i_r, img_wid		// otherwise, check that you're not at the end of the row
	blt skip_px			// and skip drawing pixel
	b skip				// if at the end of the row, go to the next row

nxt:	cmp i_r, img_wid		// if i_r >= image width,
	bge skip			// go to outer loop
					// otherwise, draw the pixel and loop back
	ldr r3, [addr]			// get the hex colour value of the current pixel
	str r3, [fb_ptr, fb_offset]	// store it in the frame buffer (draw the pixel)
skip_px:
	add i_r, #1	
	add fb_offset, #4		// increment fb horizontally (by 4 bytes ie 1 px) 
	add addr, #4			// increment address to load from to the next image pixel in img
	b loop1
				
skip:	add fb_offset, width
	sub fb_offset, i_r, lsl #2	// change frame buffer offset to point to the beginning of the next row
	mov i_r, #0			// reset i
	add j_r, #1			// increment vertically
	cmp j_r, img_hi			// if vertical height drawn < image height
	blt loop1			// loop back

	pop {width, height, fb_ptr, fb_offset, i_r, addr, j_r, lr}
	bx lr


// Agrs:
//	r0 = address of image
//	r1 = x coordinate
//	r2 = y coordinate
//	r3 = pointer to stack arguments

draw_img: 
	push {width, height, fb_ptr, fb_offset, i_r, addr, j_r, lr}

	mov addr, r0
	ldr fb_ptr, [r3]
	ldr width, [r3, #4]
	ldr height, [r3, #8]
	ldr img_wid, [r3, #12]
	ldr img_hi, [r3, #16] 

// element fb_offset = (y * width) + x
	mul fb_offset, r2, width
	add fb_offset, r1

// physical fb_offset *= 4 (each pixel is 4 bytes in size)
	lsl fb_offset, #2

// calculate the width to shift the offet by to go to the next line
	sub width, img_wid
	lsl width, #2

	mov j_r, #0
	mov i_r, #0

loop2:
	ldr r0, [addr]
	str r0, [fb_ptr, fb_offset]
	add i_r, #1	
	add fb_offset, #4		// increment fb horizontally (by 4 bytes ie 1 px) 
	add addr, #4			// increment address to load from to the next image pixel in img
	cmp i_r, img_wid			// if i_r < image width,
	blt loop2			// loop inner loop
				// otherwise, go into outer loop
	add fb_offset, width
	mov i_r, #0
	add j_r, #1			// increment vertically
	cmp j_r, img_hi
	blt loop2

	pop {width, height, fb_ptr, fb_offset, i_r, addr, j_r, lr}
	bx lr

end_loop:
	mov r1, #0			// x coordinate of image's top left corner
	mov r2, #35			// y coordinate of image's top left corner
	mov r3, fp
	bl draw_black
halt:	b	halt
	
@ Data section
.section .data

.align 2
.global frameBufferInfo

printn:
	.string	"%d	%d\n"
printx:
	.string	"state: %#08x\n"

frameBufferInfo:
	.word	0		@ frame buffer pointer
	.word	0		@ screen width
	.word	0		@ screen height

paddle_location:
	.word	850		// x
	.word 	850		// y

ball_location:
	.word	895		// x
	.word	820		// y
	.word	5		// x dir
	.word	-5		// y dir

menu_flag:	.word	0
menu_option:	.word	0

//score:		.word	0
lives:		.word	3

Lose_Flag:	.word	0
Win_Flag:	.word	0

//drawin: .string "Drawing. Delay = %d\n"

.end
