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

	mov r1, #0			// x coordinate of image's top left corner
	mov r2, #35			// y coordinate of image's top left corner
	mov r3, fp
	bl draw_black

// draw initial numbers
	mov r0, fp
	mov r1, #0
	ldr r2, =#702
	mov r3, #48
	bl draw_number

	mov r0, fp
	mov r1, #3
	ldr r2, =#1172
	mov r3, #48
	bl draw_number

	mov r0, fp
	bl controller

	add sp, #20
	pop {fp, lr}
	bx lr


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
	bl get_floor_tile
	mov r1, r4
	mov r2, r5
	mov r3, fp			// pass the address of stack variables
	bl draw_img
	add r4, #img_wid
	cmp r4, #1152
	ble floor_loop

	mov r4, #612
	add r5, #img_hi
	cmp r5, #888
	ble floor_loop

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

next:	mov r4, #tiles_minX
	mov r5, #tile0_minY
	mov r0, #img_wid
	str r0, [fp, #12]
	mov r0, #img_hi
	str r0, [fp, #16]
	bl get_gray_brick
	mov r6, r0

bricks_loop:
	mov r0, r6
	mov r1, r4
	mov r2, r5
	mov r3, fp
	bl draw_img
	add r4, #img_wid
	cmp r4, #1152
	ble bricks_loop	

	add r5, #40
	mov r4, #tiles_minX
	ldr r1, =#tile1_minY
	cmp r5, r1
	bleq get_red_brick
	ldr r1, =#tile2_minY
	cmp r5, r1
	bleq get_purple_brick
	ldr r1, =#tile3_minY
	cmp r5, r1
	bleq get_blue_brick
	ldr r1, =#tile4_minY
	cmp r5, r1
	bleq get_yellow_brick
	ldr r1, =#tile5_minY
	cmp r5, r1
	bleq get_green_brick

	mov r6, r0
	ldr r1, =#tile5_minY
	cmp r5, r1
	ble bricks_loop

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
//	bl	init_draw
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
	ldr	r3, =#1098
	cmp	r1, r3
	movgt	r1, #1098
	strle	r1, [r0]			// change paddle location's x
	b	draw
Left_Move:
	ldr	r0, =paddle_location
	ldr	r1, [r0]
	sub	r1, r2
	cmp	r1, #608
	movlt	r1, #608
	strge	r1, [r0]			// change paddle location's x
	b	draw
Start_Move:
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

	mov 	released, #0			// reset b flag

	b	draw
	
Select_Move:
	mov	r1, #0
	ldr	r0, =menu_flag
	str	r1, [r0]
	ldr	r0, =menu_option
	str	r1, [r0]

	mov	released, #0
	mov	r0, fp
	
//	bl	init_draw
	b	draw
	
B_Move:	
	mov released, #1
	b draw

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
	mov r1, #1
	ldr r2, =#702
	mov r3, #48
	bl draw_number

	mov r0, fp
	mov r1, #3
	ldr r2, =#1172
	mov r3, #48
	bl draw_number

	mov	r0, fp
	mov	r1, released
	bl	move_ball
	
	mov	r0, fp
	mov	r1, released
	bl	draw_ball
	
	b	draw_loop
	
end:	
	pop 	{r4, r5, lr}
	bx 	lr
/////////////////////////////////////////////////////////////////////////
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

	cmp	r0, #608		// check left bound
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

	cmp	r0, #127
	negle	r1, r1
	strle	r1, [ball, #12]

	ldr	r2, =#835
	cmp	r0, r2
	bge	lose_life
	ldr	r2, =#820
	cmp	r0, r2
	bge	check_paddle
	b	move_ball_end
	
check_paddle:
	ldr	r0, [ball]		// r0 = ball x
	ldr	r1, [paddle]		// r1 = paddle x
	sub	r0, r1
	cmp	r0, #-30
	ble	lose_life
	cmp	r0, #-1
	ble	left_side_hit
	cmp	r0, #92
	bge	right_side_hit
	cmp	r0, #120
	bge	lose_life
// ball hit paddle
	ldr	r0, [ball, #12]
	neg	r0, r0
	str	r0, [ball, #12]
	b	move_ball_end

left_side_hit:
	mov	r1, #-5
	str	r1, [ball, #8]
	str	r1, [ball, #12]
	b	move_ball_end

right_side_hit:
	mov	r1, #5
	str	r1, [ball, #8]
	mov	r1, #-5
	str	r1, [ball, #12]
	b	move_ball_end
	
check_bricks:
	
lose_life:
	ldr	r0, =lives
	ldr	r1, [r0]
	cmp	r1, #0
	ble	game_over
	
	sub	r1, #1
	b	move_ball_end

game_over:
	ldr	r0, =Lose_Flag
	ldr	r1, [r0]
	mov	r1, #1
	str	r1, [r0]
	mov	r0, #30000
	bl	delayMicroseconds
	ldr	r0, =menu_flag
	mov	r1, #0
	str	r1, [r0]

move_ball_end:	
	pop	{r6, r7, fp, lr}
	bx	lr

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
	
// Args:
//	r0 - tile row number
//	r1 - tile number in row
//	r2 - ball x coordinate
//	r3 - ball y coordinate
/*
update_tile_state:
	push {r4, lr}
	mov r4, 

	cmp r0, #0		// tile row 0
	moveq r4, #tiles_minX
	


	pop {r4, lr}
	bx lr
*/

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

loop1:
	ldr r0, [addr]
	str r0, [fb_ptr, fb_offset]
	add i_r, #1	
	add fb_offset, #4		// increment fb horizontally (by 4 bytes ie 1 px) 
	add addr, #4			// increment address to load from to the next image pixel in img
	cmp i_r, img_wid			// if i_r < image width,
	blt loop1			// loop inner loop
				// otherwise, go into outer loop
	add fb_offset, width
	mov i_r, #0
	add j_r, #1			// increment vertically
	cmp j_r, img_hi
	blt loop1

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
//.globl frameBufferInfo

print:
	.string	"%d	%d\n\n"
here:
	.string	"Here\n"
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
	
tile_row0:	.word	0b10101010101010101010
tile_row1:	.word	0x3ff
tile_row2:	.word	0x3ff
tile_row3:	.word	0x3ff
tile_row4:	.word	0x3ff
tile_row5:	.word	0x3ff

menu_flag:	.word	0
menu_option:	.word	0

score:		.word	0
lives:		.word	3

Lose_Flag:	.word	0
Win_Flag:	.word	0

//drawin: .string "Drawing. Delay = %d\n"

.end
