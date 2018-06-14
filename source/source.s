@ By Anastasiya, John, and Ummey

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

////////////////////// initial screen //////////////////////////////////////////////////////////////////
	mov r1, #0			// x coordinate of image's top left corner
	mov r2, #35			// y coordinate of image's top left corner
	mov r3, fp
	bl draw_black			// draws the whole screen black

	mov r4, #572			// image x coordinate
	mov r5, #87			// image y coordinate
	mov r0, #img_hi			// image width
	str r0, [fp, #12]		// stored as a stack variable
	mov r0, #img_hi			// image height
	str r0, [fp, #16]		// stored as a stack variable

// draws the top row of wall tiles
top_wall_loop:
	bl get_d_brick_t	// returns the hex value associated with the current image pixel in r0
	mov r1, r4		// image x coordinate (changes)
	mov r2, r5		// image y coordinate (changes)
	mov r3, fp		// pointer to stack variables
	bl draw_img
	add r4, #img_hi		// increment the x coordinate by the image width
	ldr r0, =#1212		
	cmp r4, r0		// while the current image's x coordinate is less than 1212 (end of the 'grid' - image width)
	ble top_wall_loop	// keep drawing tiles horizontally
				// otherwise, go on to drawing the side walls
	mov r4, #572		// x coordinate at the beginning of the grid
	mov r5, #127		// y coordinate 
	// image dimentions stay the same

// draws the left side wall, then the right side wall (similr to the top wall)
side_wall_loop:
	bl get_d_brick_l
	mov r1, r4
	mov r2, r5
	mov r3, fp
	bl draw_img
	add r5, #img_hi		// increment the y coordinate by the image height
	cmp r5, #888		// while y coordinate < 888 (vertical end of the grid - image height)
	ble side_wall_loop	// keep looping (drawing tiles down a line)
				// when done,
	ldr r0, =#1212
	cmp r4, r0		// if the x coordinate has not yet been set as 1212
	beq next
	movne r4, r0		// set it
	movne r5, #127
	bne side_wall_loop	// and go back to the loop to draw the right wall

next:				// otherwise, go here (exit)
	mov r0, fp
	bl controller		// the controller will draw the rest as needed

	add sp, #20
	pop {fp, lr}
	bx lr
///////////////////////////////////////////////////////////////////////////////
//	inputs: nil
//	outputs: nil
///////////////////////////////////////////////////////////////////////////////
count .req r8
row_state .req r7

draw_grid:
	push {r4, r5, r6, fp, lr}
	mov fp, r0			// same as main's fp

	mov r4, #612			// x coordinate (left side of floor)
	mov r5, #127			// y coordinate (top of floor)
	mov r0, #img_wid		// floor tile width
	str r0, [fp, #12]		// stored as a stack variable
	mov r0, #img_hi			// floor tile height
	str r0, [fp, #16]		// stored as a stack variable

// draws all the floor tiles
floor_loop:
	mov r1, r4			// x
	mov r2, r5			// y
	mov r3, fp			// pass the address of stack variables
	ldr r0, =#847			// check if currently at the 19th row
	cmp r5, r0			// where the paddle is drawn
	bl get_floor_tile		
	bleq draw_paddle_floor		// if so, call the special paddle floor subroutine
	blne draw_img			// otherwise, draw the floor tiles normally with draw_img
	add r4, #img_wid		// increment x by wimage width
	cmp r4, #1152			// if the next image's x coordinate is less than the end of the floor,
	ble floor_loop			// keep looping
					// otherwise,
	mov r4, #612			// reset the x coordinate
	add r5, #img_hi			// increment the y coordinate
	cmp r5, #207			// if the y was not 207 (where brick tiles begin),
	ble floor_loop			// keep looping
	ldr r0, =#487			// if y = 207,	 
	cmp r5, r0			// and if y was less than 487,
	movlt r5, r0			// set y = 487 (the end of brick tiles)
	cmp r5, #888			// while y < 888 (end of floor)
	ble floor_loop			// keep looping
					// otherwise, go on to draw the bricks
	mov r4, #tiles_minX		// usual arguments for draw_img
	mov r5, #tile0_minY
	mov r0, #img_wid
	str r0, [fp, #12]
	mov r0, #img_hi
	str r0, [fp, #16]
	bl get_gray_brick		// first row of bricks is gray
	ldr r7, =tile_row0		// get the row's state
	ldr row_state, [r7]
	mov r6, r0			// save the pointer to the stack variables to r6
	mov count, #0			// initialize the counter (for column of brick)

bricks_loop:
	mov r0, #1
	lsl r1, count, #1		// r1 = count * 3
	add r2, r1, count
	lsl r0, r2			// 1 at the tile's firt bit in row state
	lsl r0, #2			// 1 at the tile's third bit in row state
	and r1, row_state, r0		// row state (r7) AND bit mask (r0) = r1 (changes r1)
	teq r1, r0			// if the tile's third bit was a 1 (brick exists here)
	add count, #1			// increment counter
	beq brick			// and draw a brick tile
					// otherwise... draw a floor tile tile
floor:
	ldr r0, =get_floor_tile
	mov r1, r4
	mov r2, r5
	mov r3, fp
	bl draw_img			// draw a regular floor tile

	add r4, #img_wid		// increment x by the image width
	cmp r4, #1152			// while x < 1152 (end of floor - image width)
	ble bricks_loop			// keep drawing the current row
	bgt outer			// otherwise, go to the outer loop

brick:
	mov r0, r6			// loads the address of the current kind of brick tile
	mov r1, r4
	mov r2, r5
	mov r3, fp
	bl draw_img			// draw the current kind of brick tile

	add r4, #img_wid		// increment x by the image width
	cmp r4, #1152			// while x < 1152 (end of floor - image width)
	ble bricks_loop			// keep drawing the current row
			// otherwise, go to the outer loop
outer:	add r5, #img_hi			// increment y by the image height
	mov r4, #tiles_minX		// initialize the tiles min x to r4
	ldr r1, =#tile1_minY		// y of the 2nd row of tiles
	cmp r5, r1			// if this was the row,
	bleq get_red_brick		// get the brick image
	ldreq r7, =tile_row1		// get the row's state
	ldreq row_state, [r7]		// put the state into r7
	beq o_end			// go to the end of the case/if block
	ldr r1, =#tile2_minY		// 3rd row of bricks
	cmp r5, r1
	bleq get_purple_brick		// get the 3rd row brick image
	ldreq r7, =tile_row2		// get the row's state
	ldreq row_state, [r7]		// put the state into r7
	beq o_end
	ldr r1, =#tile3_minY		// 4th row of bricks
	cmp r5, r1
	bleq get_blue_brick		// brick image
	ldreq r7, =tile_row3		// get the row's state
	ldreq row_state, [r7]		// put the state into r7
	beq o_end
	ldr r1, =#tile4_minY		// 5th row of bricks
	cmp r5, r1
	bleq get_yellow_brick		// brick image
	ldreq r7, =tile_row4		// get the row's state
	ldreq row_state, [r7]		// put the state into r7
	beq o_end
	ldr r1, =#tile5_minY		// 6th row of bricks
	cmp r5, r1
	bleq get_green_brick		// brick image
	ldreq r7, =tile_row5		// get the row's state
	ldreq row_state, [r7]		// put the state into r7

o_end:	mov r6, r0
	ldr r1, =#tile5_minY		// if this was not the last row of tiles,
	cmp r5, r1
	movle count, #0			// reset the column count
	ble bricks_loop			// and keep looping 
					// otherwise, fo on to draw special bricks if needed
	bl printBricks

	mov r0, #680			// score/lives board width
	str r0, [fp, #12]
	mov r0, #img_hi			// score/lives board height (40)
	str r0, [fp, #16]

	bl get_score_lives_text		// get the image
	mov r1, #572			// x coordinate
	mov r2, #35			// y coordinate
	mov r3, fp			// pointer to stack variables
	bl draw_img			// draw the score/lives board

	pop {r4, r5, r6, fp, lr}
	bx lr

///////////////////////////////////////////////////////////////////////
//	inputs: nil
//	outputs: nil
//////////////////////////////////////////////////////////////////////
delay .req r4
released .req r5

controller:
	push 	{r4, r5, lr}
	mov fp, r0				// same fp as main

	bl	init_snes			// initialize snes controller
	
	mov 	r0, #120
	str 	r0, [fp, #12]
	mov 	r0, #img_hi
	str 	r0, [fp, #16]

	bl	get_paddle			// returns address of image in r0
	ldr 	r2, =paddle_location
	ldr 	r1, [r2]			// paddle location x
	ldr 	r2, [r2, #4]			// paddle location y
	mov 	r3, fp
	bl 	draw_img			// draw the paddle

	mov	r0, fp
	bl	draw_ball			// draw the ball
	b	draw				// branch to draw
	
draw_loop:					
	mov	r0, #8000
	bl	delayMicroseconds		// delay 8000 microseconds

	bl	Read_SNES			// read user input from controller

	ldr	r1, =Win_Flag			// load win flag address
	ldr	r2, [r1]			// load win flag value
	cmp	r2, #1
	beq	win_options			// if win flag is #1 branch to win_options
	
	ldr	r1, =Lose_Flag			// load lose flag address
	ldr	r2, [r1]			// load lose flag value
	cmp	r2, #1	
	beq	lose_options			// if lose flag is #1 branch to lose_options
	
	ldr	r1, =menu_flag			// load menu flag address
	ldr	r1, [r1]			// load menu flag value

	cmp	r1, #1
	bne	menu_buttons			// if flag set to 0 branch to menu_buttons
	beq	game_buttons			// if flag set to 1 branch to game_buttons
	
//checks acceptable menu input from user
menu_buttons:
	cmp	r0, #2	
	beq	A_Move				// branch to A_Move if input == 2

	cmp	r0, #10
	beq	Up_Move				// branch to Up_Move if input == 10

	cmp	r0, #11
	beq	Down_Move			// branch to Down_Move if input == 11
	b	draw				// branch to draw

game_buttons:	
	cmp	r0, #3
	moveq	r2, #10				// set move speed to 10 if input == 3
	beq	Right_Move			// branch to Right_Move if input == 3

	cmp	r0, #4
	moveq	r2, #10				// set move speed to 10 if input == 4
	beq	Left_Move			// branch to Left_Move if input == 4
					
	cmp	r0, #5
	beq	Start_Move			// branch to Start_Move if input == 5

	cmp	r0, #6
	beq	Select_Move			// branch to Select_Move if input == 6

	cmp	r0, #7
	beq	B_Move				// branch to B_Move if input == 7
	
	cmp	r0, #8
	moveq	r2, #20				// set move speed to 20 if input == 8
	beq	Left_Move			// branch to Left_Move if input == 8
	
	cmp	r0, #9
	moveq	r2, #20				// set move speed to 20 if input == 9
	beq	Right_Move			// branch to Right_Move if input == 9
	b	draw_cont			// branch to draw_cont
	
A_Move:
	ldr	r0, =menu_option		// load menu_option address
	ldr	r0, [r0]			// load menu_option value
	cmp	r0, #1
	beq	end_loop			// branch to end_loop if menu_option == 1

	ldr	r1, =menu_flag			// load menu_flag address
	mov	r2, #1
	str	r2, [r1]			// change menu_flag to 1
	b	draw				// branch to draw
	
Up_Move:
	ldr	r0, =menu_option		// load menu_option address
	ldr	r1, [r0]			// load menu_option value
	
	cmp	r1, #0				// check menu_option
	beq	draw				// draw

	mov	r1, #0
	str	r1, [r0]			// change menu_option to 0
	b	draw				// branch to draw
	
Down_Move:
	ldr	r0, =menu_option		// load menu_option address
	ldr	r1, [r0]			// load menu_option value

	cmp	r1, #0				// check menu_option
	bne	draw				// branch to draw
	
	mov	r1, #1
	str	r1, [r0]			// change menu_option to 1
	b	draw				// branch to draw

Right_Move:
	ldr	r0, =paddle_location		// load paddle_location address
	ldr	r1, [r0]			// load paddle_location value
	add	r1, r2				// increment by speed
	ldr	r3, =#1092
	cmp	r1, r3				// check right bound
	movgt	r1, #1092			// store right bound if increments past
	str	r1, [r0]			// change paddle location's x
	b	draw
Left_Move:
	ldr	r0, =paddle_location		// load paddle_location address
	ldr	r1, [r0]			// load paddle_location value
	sub	r1, r2				// decrement by speed
	ldr 	r3, =#612
	cmp	r1, r3				// check left bound
	movlt	r1, r3				// store left bound if decrements past
	str	r1, [r0]			// change paddle location's x
	b	draw				// branch to draw
Start_Move:
	bl	hard_reset			// perform reset on all game values
	mov 	released, #0			// reset b flag

	b	draw				// branch to draw
	
Select_Move:
	mov	r1, #0
	ldr	r0, =menu_flag			// load menu_flag address
	str	r1, [r0]			// change menu_flag to 0
	ldr	r0, =menu_option		// load menu_option address
	str	r1, [r0]			// change menu_flag to 0

	bl	hard_reset			// perform reset on all game values
	mov	released, #0			// set released to 0
	
	b	draw				// branch to draw
	
B_Move:	
	mov released, #1			// set released to 1
	b draw					// branch to draw

win_options:
	push	{r0}				// push user input
	bl	win_screen			// print win screen
	pop	{r0}				// pop user input
	cmp	r0, #0				
	beq	draw_loop			// loop until ther is user input

	mov	r0, #0
	ldr	r1, =Win_Flag			// load Win_Flag
	str	r0, [r1]			// change Win_flag to 0
	b	end_options			// branch to end_options

lose_options:
	push	{r0}				// push user input
	bl	gameOver_screen			// print game over screen
	pop	{r0}				// pop user input
	cmp	r0, #0
	beq	draw_loop			// loop until there is user input

	mov	r0, #0
	ldr	r1, =Lose_Flag			// load Lose_Flag
	str	r0, [r1]			// change Lose_Flag to 0
	
end_options:
	mov	r0, #40000
	bl	delayMicroseconds		// delay 40000 microseconds

	mov	r0, #0
	mov	released, r0			// set released to 0
	ldr	r1, =menu_flag
	str	r0, [r1]			// set menu_flag to 0
	ldr	r1, =menu_option
	str	r0, [r1]			// set menu_option to 0
	bl	hard_reset			// reset all game values
	b	draw				// branch to draw
	
draw:	
	ldr	r0, =menu_flag
	ldr	r0, [r0]
	cmp	r0, #0	
	bne	draw_cont			// branch to draw_cont if menu_flag /= 0

	ldr	r0, =menu_option
	ldr	r0, [r0]
	cmp	r0, #0
	beq	print_play			// branch to print_play if menu_option == 0
	bne	print_quit			// branch to print_quit if menu_option /= 0

print_play:
	bl	main_menu_screen		// print main menu (play)
	b	draw_loop			// branch to draw_loop
	
print_quit:
	bl	main_menu_quit			// print main menu (quit)
	b	draw_loop			// branch to draw_loop
	
draw_cont:	
	mov r0, fp
	bl draw_grid				// draw_grif

	mov 	r0, #120
	str 	r0, [fp, #12]
	mov 	r0, #img_hi
	str 	r0, [fp, #16]

	ldr 	r0, =paddle_location		// load paddle_location address
	ldr 	r1, [r0]			// get paddle x
	ldr 	r2, [r0, #4]			// get paddle y
	bl	get_paddle			// get paddle image address
	mov 	r3, fp
	bl 	draw_img			// print paddle


// draw numbers
	mov r0, fp
	ldr r1, =score				// load score address
	ldr r1, [r1]				// get score
	ldr r2, =#702				// load score x
	mov r3, #48				// load score y
	bl draw_number				// print score

	mov r0, fp
	ldr	r1, =lives			// load lives address
	ldr	r1, [r1]			// get lives
	ldr r2, =#1172				// load lives x
	mov r3, #48				// load lives y
	bl draw_number				// print lives

	mov	r0, fp
	mov	r1, released			// send released
	bl	move_ball			// move the ball
	mov	released, r0			// return to released
	
	mov	r0, fp
	mov	r1, released			// send released
	bl	draw_ball			// print ball
	
	b	draw_loop			// branch to draw_loop
	
end:	
	pop 	{r4, r5, lr}
	bx 	lr
/////////////////////////////////////////////////////////////////////////
//	inputs: nil
//	outputs: nil
/////////////////////////////////////////////////////////////////////////
hard_reset:	
	ldr	r0, =score
	mov	r1, #0
	str	r1, [r0]			// set score to 0
	ldr	r0, =lives
	mov	r1, #3
	str	r1, [r0]			// set lives to 3

	ldr	r0, =tile_row0
	ldr	r1, =#0x24924924
	str	r1, [r0]			// reset bottom row bricks
	ldr	r0, =tile_row1
	str	r1, [r0]			// reset 2nd row bricks
	ldr	r0, =tile_row2
	str	r1, [r0]			// reset 3rd row bricks
	ldr	r0, =tile_row3
	str	r1, [r0]			// reset 4th row bricks
	ldr	r0, =tile_row4
	str	r1, [r0]			// reset 5th row bricks
	ldr	r0, =tile_row5
	str	r1, [r0]			// reset top row bricks

/*	ldr	r0, =movingBrick1
	ldr	r1, =#1092
	str	r1, [r0]			// reset movingBrick1 x
	ldr	r1, =#287
	str	r1, [r0, #4]			// reset movingBrick1 y
	mov	r1, #0
	str	r1, [r0, #8]			// reset movingBrick1 activation bit
*/

	ldr	r0, =movingBrick2
	ldr	r1, =#792
	str	r1, [r0]			// reset movingBrick2 x
	ldr	r1, =#367
	str	r1, [r0, #4]			// reset movingBrick2 y
	mov	r1, #0
	str	r1, [r0, #8]			// reset movingBrick2 activation bit
	
	ldr	r0, =movingBrick3
	ldr	r1, =#1032
	str	r1, [r0]			// reset movingBrick3 x
	ldr	r1, =#447
	str	r1, [r0, #4]			// reset movingBrick3 y
	mov	r1, #0
	str	r1, [r0, #8]			// reset movingBrick3 activation bit
	

soft_reset:
	ldr	r0, =paddle_location		// reset paddle location
	mov	r1, #850
	str	r1, [r0]			// reset paddle x
	str	r1, [r0, #4]			// reset paddle y

	ldr	r0, =ball_location		// reset ball location
	mov	r1, #895
	str	r1, [r0]			// reset ball x
	mov	r1, #820
	str	r1, [r0, #4]			// reset ball y
	mov	r1, #5
	str	r1, [r0, #8]			// reset ball x direction
	mov	r1, #-5
	str	r1, [r0, #12]			// reset ball y direction
	
	bx	lr				// return
	
////////////////////////////////////////////////////////////////////////////
//	inputs:	nil
//	outputs: nil
////////////////////////////////////////////////////////////////////////////
move_ball:
	push	{r6, r7, fp, lr}

	paddle	.req	r6
	ball	.req	r7
	
	mov	fp, r0
	
	ldr	paddle, =paddle_location	// load paddle_location to paddle
	ldr	ball, =ball_location		// load ball_location to ball

	cmp	r1, #1
	beq	x_motion			// branch to x_motion if b has been pressed


	ldr	r0, [paddle]			// load paddle x
	add	r0, #45				// add 45 to paddle x
	str	r0, [ball]			// ball follows paddle
	b	move_ball_end			// branch to move_ball_end

x_motion:
	ldr	r0, [ball]			// load ball x
	ldr	r1, [ball, #8]			// load ball x
	add	r0, r1
	str	r0, [ball]			// add ball speed to ball x

	ldr 	r2, =#615
	cmp	r0, r2				// check left bound
	negle	r1, r1				// negate ball x direction if past left bound
	strle	r1, [ball, #8]			// store new direction
	
	ldr	r2, =#1178
	cmp	r0, r2				// check right bound
	negge	r1, r1				// negate ball x direction if past right bound
	strge	r1, [ball, #8]			// store new direction

y_motion:	
	ldr	r0, [ball, #4]			// load ball y to r0
	ldr	r1, [ball, #12]			// load ball y dir to r1
	add	r0, r1
	str	r0, [ball, #4]			// add ball speed to ball y

	cmp	r0, #130			// check upper bound
	negle	r1, r1				// negate ball y direction if past upper bound
	strle	r1, [ball, #12]			// store new direction

	ldr	r2, =#835
	cmp	r0, r2				// check if ball is below paddle
	bge	lose_life			// lose life if ball is below paddle
	ldr	r2, =#820
	cmp	r0, r2				// check if ball is at paddle
	bge	check_paddle			// check if paddle intercepts ball
	cmp	r0, #247
	ble	y_next				// branch to y_next if ball above bricks

	ldr	r1, =#487
	cmp	r0, r1				// check if ball is between top of bricks and paddle
	ble	check_brick			// check if a brick has been hit
y_next:	
	mov	r0, #1				// return 1
	b	move_ball_end			// branch to move_ball_end
	
check_paddle:
	ldr	r0, [ball]			// load ball x
	ldr	r1, [paddle]			// load paddle x
	sub	r0, r1
	cmp	r0, #-30
	ble	lose_life			// if paddle missed ball branch to lose_life
	cmp	r0, #-1
	ble	left_side_hit			// branch if ball hit left side of paddle
	cmp	r0, #120
	bgt	lose_life			// if paddle missed ball branch to lose_life
	cmp	r0, #92
	bgt	right_side_hit			// branch if ball hit right side of paddle
	
// ball hit middle of paddle
	ldr	r0, [ball, #12]
	neg	r0, r0		
	str	r0, [ball, #12]			// change ball direction after hitting paddle
	mov	r0, #1				// return 1
	b	move_ball_end			// branch to move_ball_end

left_side_hit:
	mov	r1, #-5
	str	r1, [ball, #8]			// set ball x direction to -5
	str	r1, [ball, #12]			// set ball y direction to -5
	mov	r0, #1				// return 1
	b	move_ball_end			// branch to move_ball_end

right_side_hit:
	mov	r1, #5
	str	r1, [ball, #8]			// set ball x direction to 5
	mov	r1, #-5
	str	r1, [ball, #12]			// set ball y direction to -5
	mov	r0, #1				// return 1
	b	move_ball_end			// branch to move_ball_end
	
check_brick:
	ldr	r0, [ball]
	bl	divFuncX			// col = (ball x - 612) / 60
	mov	r1, r0
	ldr	r0, [ball, #4]
	bl	divFuncY			// row = (ball y - 247) / 40
	push 	{r0, r1}			// push row and col
	bl	check_brick_state		// check if a brick was hit

	cmp	r0, #1
	beq	hit_brick			// branch if a brick was hit

	pop 	{r0, r1}			// pop row and col
	mov	r0, #1				// return 1
	b	move_ball_end			// branch to move_ball_end
	
hit_brick:
	pop 	{r0, r1}			// pop row and col
	ldr	r3, [ball]
	ldr	r2, [ball, #4]
	push	{r0, r1}			// push row and col

	bl	update_tile_state		// update hit bricks state

//	ballx = r0, bally = r1, col = r2, row = r3
check_x:
	ldr	r0, [ball]
	ldr	r1, [ball, #4]
	pop	{r2, r3}			// pop col and row
	mov	r4, #60
	mul	r4, r2, r4			// col * 60
	add	r4, #612			// brick left edge = (col * 60) + 612
	sub	r4, r0, r4			// r4 = ballx - brick left edge
	
	cmp	r4, #-30			// determine if ball hit left edge of brick
	ble	neg_x				// branch to neg_x if hit left edge
	cmpgt	r4, #60				// determine if ball hit left edge of brick
	bgt	neg_x				// branch to neg_x
	
neg_y:
	ldr	r0, [ball, #8]
	neg	r0, r0				// negate y direction
	str	r0, [ball, #8]			// store new y direction
	b	end_hit_brick			// branch to end_hit_brick
	
check_y:
	mov	r4, #40
	mul	r4, r3				// row * 40
	add	r4, #247			// brick right edge = (row * 40) + 247
	sub	r4, r1, r4			// r4 = bally - brick right edge

	cmp	r4, #-30			// determine if ball hit right edge of brick
	ble	neg_y				// branch to neg_y if hit right edge
	cmpgt	r4, #40				// determine if ball hit right edge of brick
	bgt	neg_y				// branch to neg_y

neg_x:
	ldr	r0, [ball, #12]
	neg	r0, r0				// negate x direction
	str	r0, [ball, #12]			// store new x direction

end_hit_brick:	
	b	check_win			// check if all bricks are gone
	
lose_life:
	ldr	r0, =lives
	ldr	r1, [r0]			// load number of lives
	sub	r1, #1				// subtract one life
	str	r1, [r0]			// store new lives
	cmp	r1, #0				// check if all lives lost
	ble	game_over			// branch to game_over if no lives left

	str	r1, [r0]
	bl	soft_reset			// reset paddle and ball
	b	move_ball_end			// branch to move_ball_end

check_win:
	ldr	r0, =#460175067
	ldr	r1, =tile_row0
	ldr	r1, [r1]
	cmp	r0, r1				// check if bottom row of bricks are gone
	bne	end_win				// branch to end_win if not all gone
	ldr	r0, =#153391689
	ldr	r1, =tile_row1
	ldr	r1, [r1]
	cmp	r0, r1				// check if 2nd row of bricks are gone
	bne	end_win				// branch to end_win if not all gone
	ldr	r1, =tile_row2
	ldr	r1, [r1]
	cmp	r0, r1				// check if 3rd row of bricks are gone
	bne	end_win				// branch to end_win if not all gone
	mov	r0, #0
	ldr	r1, =tile_row3
	ldr	r1, [r1]
	cmp	r0, r1				// check if 4th row of bricks are gone
	bne	end_win				// branch to end_win if not all gone
	ldr	r1, =tile_row4
	ldr	r1, [r1]
	cmp	r0, r1				// check if 5th row of bricks are gone
	bne	end_win				// branch to end_win if not all gone
	ldr	r1, =tile_row5
	ldr	r1, [r1]
	cmp	r0, r1				// check if top row of bricks are gone
	bne	end_win				// branch to end_win if not all gone

	ldr	r0, =Win_Flag
	mov	r1, #1
	str	r1, [r0]			// set win flag to 1
end_win:
	mov	r0, #1				// return 1
	b	move_ball_end			// branch to move_ball_end
	
game_over:
	ldr	r0, =Lose_Flag
	ldr	r1, [r0]
	mov	r1, #1
	str	r1, [r0]			// set lose flag
	
	mov	r0, #0				// return 0
move_ball_end:	
	pop	{r6, r7, fp, lr}
	bx	lr				// return

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


// SACTIVATE brick 3
sactivate3:
	push	{r0, r1, r2, r3, r4, r5, r6, r7}

	mov 	r5, r1			//move r1 into r5 to avoid being overwitten
	mov	r6, r0			//move r0 into r6 to avoid being overwitten
	mov 	r7, r3			//move r3 into r7 to avoid being overwitten

	cmp	r4, #5			//compare row # to 5
	bne	catch3			//if row # is not equal to 5, branch to catch3
	cmp	r5, #7			//compare colume # to 7
	bne	catch3			//if colume # is not equal to 7, branch to catch3
	teq 	r7, r6			//check if brick has been hit	
	bne	sactivate2		//if it hasn't, then branch to see if the next bonus brick has been hit
	ldr	r0, =movingBrick3	//load x, y and activation of 3rd bonus brick
	ldr	r1, [r0, #8]		//load activation
	cmp	r1, #1			//compare activation to 1
	beq	catch3			//if equal, branch to catching it
	cmp	r1, #0			//compare activation to 0
	mov	r1, #1			//move 1 into r1
	str	r1, [r0, #8]		//store activation

catch3:
	ldr	r0, =movingBrick3	//load x, y and activation of 3rd bonus brick
	ldr	r1, [r0, #8]		//load activation
	cmp	r1, #-1			//compare activation to -1
	beq	sactivate2		//if they equal, branch to dealing with the next boonus brick
	ldr	r1, [r0, #4]		//load y into r1
	ldr	r2, =#810		//load 810 into r2
	cmp	r1, r2			//compare y and 810
	blt	sactivate2		//if y < 810, branch to dealing with the next boonus brick
	ldr	r1, [r0]		//load r0 into y
	ldr	r2, =paddle_location	//load paddle's location
	ldr	r2, [r2]			
	add	r1, #60			//add 60 to y
	cmp	r1, r2			//compare paddle's location to y
	blt	sactivate2		//if paddle's location < y, branch to dealing with the next boonus brick
	sub	r1, #60			//subtract 60 from y
	add	r2, #120		//add 120 to the paddle's location
	cmp	r1, r2			//compare paddle's location to y
	bgt	sactivate2		//if paddle's location > y, branch to next3

	ldr	r0, =score		//load score
	ldr	r1, [r0]		//load it into r1
	add	r1, #5			//add 5 to it if paddle catches bonus brick
	str	r1, [r0]		//store it into r1

	ldr	r0, =movingBrick3	//load x, y and activation of 3rd bonus brick
	bl	StopsBrick		//branch and link to stopping brick3

// SACTIVATE brick 2
sactivate2:
	cmp	r4, #3			//compare row # to 3
	bne	catch2			//if row # is not equal to 3, branch to catching brick3
	cmp	r5, #3			//compare colume # to 3
	bne	catch2			//if colume # is not equal to 3, branch to catching brick3
	teq 	r7, r6			//check if brick has been hit	
	bne	catch2			//if it hasn't, go to catch2
	ldr	r0, =movingBrick2	//load x, y and activation of 2nd bonus brick
	ldr	r1, [r0, #8]		//load activation
	cmp	r1, #1			//compare activation to 1
	beq	catch2			//if they equal, branch to catch2
	cmp	r1, #0			//compare activation to 0
	mov	r1, #1			//move 1 into activation
	str	r1, [r0, #8]		//store activation
catch2:
	ldr	r0, =movingBrick2	//load x, y and activation of 2nd bonus brick
	ldr	r1, [r0, #8]		//load activation
	cmp	r1, #-1			//compare activation to -1
	beq	sactivate1		//if they equal, branch to dealing with the next boonus brick
	ldr	r1, [r0, #4]		//load y into r1
	ldr	r2, =#810		//load 810 into r2
	cmp	r1, r2			//compare y and 810
	blt	sactivate1		//if y < 810, branch to dealing with the next boonus brick
	ldr	r1, [r0]		//load r0 into y
	ldr	r2, =paddle_location	//load paddle's location
	ldr	r2, [r2]
	add	r1, #60			//add 60 to y
	cmp	r1, r2			//compare paddle's location to y
	blt	sactivate1		//if paddle's location < y, branch to dealing with the next boonus brick
	sub	r1, #60			//subtract 60 from y
	add	r2, #120		//add 120 to the paddle's location
	cmp	r1, r2			//compare paddle's location to y
	bgt	sactivate1		//if paddle's location > y, branch to dealing with the next boonus brick

	ldr	r0, =score		//load score
	ldr	r1, [r0]		//load it into r1
	add	r1, #5			//add 5 to it if paddle catches bonus brick
	str	r1, [r0]		//store into r1

	ldr	r0, =movingBrick2	//load x, y and activation of 2nd bonus brick
	bl	StopsBrick		//branch to stopping the bonus brick

sactivate1:
/*	cmp	r4, #1
	bne	catch1
	cmp	r5, #8
	bne	catch1
	teq 	r7, r6				
	bne	catch1
	ldr	r0, =movingBrick1
	ldr	r1, [r0, #8]
	cmp	r1, #1
	beq	catch1
	cmp	r1, #0
	mov	r1, #1
	str	r1, [r0, #8]
catch1:
	ldr	r0, =movingBrick1
	ldr	r1, [r0, #8]
	cmp	r1, #-1
	beq	next1
	ldr	r1, [r0, #4]
	ldr	r2, =#810
	cmp	r1, r2
	blt	next1
	ldr	r1, [r0]
	ldr	r2, =paddle_location
	ldr	r2, [r2]
	add	r1, #60
	cmp	r1, r2
	blt	next1
	sub	r1, #60
	add	r2, #120
	cmp	r1, r2
	bgt	next1

	ldr	r0, =score
	ldr	r1, [r0]
	add	r1, #5
	str	r1, [r0]

	ldr	r0, =movingBrick1
	bl	StopsBrick

next1: 
*/	pop	{r0, r1, r2, r3, r4, r5, r6, r7}

	and 	r3, row_s, r0
	teq 	r3, r0			// if the tile's third bit was a 1
	moveq	r0, #1
	movne	r0, #0
	pop	{r4, lr}		
	bx	 lr

	
/////////////////////////////////////////////////////////////////////////////
//	inputs: nil
//	outputs: nil
/////////////////////////////////////////////////////////////////////////////
draw_ball:
	push	{fp, lr}

	mov	fp, r0
	mov	r0, #30
	str	r0, [fp, #12]
	str	r0, [fp, #16]
	bl	get_soccer_ball				// get soccer ball image
	ldr	r3, =ball_location			// load ball_location address
	ldr	r1, [r3]				// load ball x
	ldr	r2, [r3, #4]				// load ball y
	mov	r3, fp					// mov fp
	bl	draw_img				// print soccer ball
	
	pop	{fp, lr}
	bx	lr					// return


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
// Same stack arguments as draw_img
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
	mov r0, #0xFF000000		// the colour is black
	str r0, [fb_ptr, fb_offset]
	add i_r, #1	
	add fb_offset, #4		// increment fb horizontally (by 4 bytes ie 1 px) 
	cmp i_r, #1824			// if i_r < 16*4 (image length in bytes),
	blt loop

	mov i_r, #0
	add j_r, #1			// increment vertically
	cmp j_r, #948
	ble loop

	pop {width, height, fb_ptr, fb_offset, i_r, j_r, lr}
	bx lr


// Same arguments as draw_img
// Draws floor tiles under the moving paddle (so that it doesn't blink)
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
//
// Stack arguments:
//	1. frame buffer pointer
//	2. screen width
//	3. screen height
//	4. image width
//	5. image height
// Note: all stack arguments are 4 bytes long

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
	cmp i_r, img_wid		// if i_r < image width,
	blt loop2			// loop inner loop
					// otherwise, go into outer loop
	add fb_offset, width
	mov i_r, #0			// reset i
	add j_r, #1			// increment vertically
	cmp j_r, img_hi			// while j < image height
	blt loop2			// loop

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

print:
	.string	"%d\n"
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
