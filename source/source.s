.global main
.balign 4

img_wid = 60
img_hi = 40

main:
	push {r4, r5, r6, fp, lr}
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
	mov r3, fp		// pass the address of stack variables
//ov r3, #img_wid
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
//	mov r3, #img_hi
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
//	mov r3, #img_hi
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

next:	mov r4, #612
	mov r5, #247
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
//	mov r3, #img_wid
	bl draw_img
	add r4, #img_wid
	cmp r4, #1152
	ble bricks_loop	

	add r5, #40
	mov r4, #612
	ldr r1, =#287
	cmp r5, r1
	bleq get_red_brick
	ldr r1, =#327
	cmp r5, r1
	bleq get_purple_brick
	ldr r1, =#367
	cmp r5, r1
	bleq get_blue_brick
	ldr r1, =#407
	cmp r5, r1
	bleq get_yellow_brick
	ldr r1, =#447
	cmp r5, r1
	bleq get_green_brick

	mov r6, r0
	ldr r1, =#447
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
//	mov r3, #680
	bl draw_img

	mov r0, #14
	str r0, [fp, #12]
	mov r0, #20
	str r0, [fp, #16]

	bl get_0
	mov r1, #702
	mov r2, #48
	mov r3, fp
//	mov r3, #14
	bl draw_img
	
	bl get_3
	mov r1, #1172
	mov r2, #48
	// image dimentions stay the same
	mov r3, fp
//	mov r3, #14
	bl draw_img

	add sp, #20
	pop {r4, r5, r6, lr}
	bx lr


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


@ Data section
.section .data

.align 2
//.globl frameBufferInfo

frameBufferInfo:
	.word	0		@ frame buffer pointer
	.word	0		@ screen width
	.word	0		@ screen height


