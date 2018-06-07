.global main
.balign 4

main:
	push 	{lr}
	ldr 	r0, =frameBufferInfo 		// frame buffer information structure
	bl 	initFbInfo			// from the C file
	
	bl	init_snes

//	ldr	r0, =paddle_location
//	mov	r1, #150
//	str	r1, [r0]
//	mov	r1, #164
//	str	r1, [r0, #4]
	
	bl	get_paddle
	ldr 	r2, =paddle_location
	ldr 	r1, [r2]
	ldr 	r2, [r2, #4]
	mov 	r3, #120
	mov	r4, #40
	bl 	draw_img

draw_loop:	
	mov	r0, #5000
	bl	delayMicroseconds
	
	bl	Read_SNES

	cmp	r0, #1
	ble	draw_loop
	cmp	r0, #2
	beq	A_Move
	cmp	r0, #3
	beq	Right_Move
	cmp	r0, #4
	beq	Left_Move
	cmp	r0, #5
	beq	end
	cmp	r0, #6
	beq	Select_Move
	cmp	r0, #7
	beq	B_Move
	b	draw

A_Move:
	ldr	r0, =paddle_location
	ldr	r1, [r0, #4]
	ldr	r2, =frameBufferInfo
	ldr	r2, [r2, #4]
	add	r1, r2
	str	r1, [r0, #4]
	b	draw
Right_Move:
	ldr	r0, =paddle_location
	ldr	r1, [r0]
	add	r1, #1
	str	r1, [r0]
	b	draw
Left_Move:
	ldr	r0, =paddle_location
	ldr	r1, [r0]
	sub	r1, #1
	str	r1, [r0]
	b	draw
Select_Move:
	ldr	r0, =paddle_location
	ldr	r1, [r0]
	ldr	r2, [r0, #4]
	mov	r1, #850
	mov	r2, #864
	str	r1, [r0]
	str	r2, [r0, #4]
	b	draw
B_Move:	
	ldr	r0, =paddle_location
	ldr	r1, [r0, #4]
	ldr	r2, =frameBufferInfo
	ldr	r2, [r2, #4]
	sub	r1, r2
	str	r1, [r0, #4]

draw:	
	ldr 	r0, =paddle_location
	ldr 	r1, [r0]
	ldr 	r2, [r0, #4]
	bl	get_paddle
	mov 	r3, #120
	mov	r4, #40
	bl 	draw_img

	b	draw_loop
	
end:	
	pop 	{lr}
	bx 	lr

x_axis .req r4
y_axis .req r5
width .req r6
height .req r7
fb_ptr .req r8
fb_offset .req r9
i_r .req r10
addr .req r11
j_r .req r12

s_wid: .string "%d\n"
s_hi: .string "%d\n"

// Agrs:
//	r0 = address of image
//	r1 = width (x)
//	r2 = height (y)
//	r3 = width of image in pixels
//	r4 = height of image in pixels
draw_img: 
	push 	{width, height, fb_ptr, fb_offset, i_r, addr, j_r, lr}

	mov 	addr, r0
	mov	height, r4
	mov 	width, r3
	mov	y_axis, r2
	mov	x_axis, r1

	push	{r0, r1, r2, r3, r4, r5, r6}
	ldr	r0, =printn
	ldr	r1, =paddle_location
	ldr	r1, [r1]
	bl	printf
	ldr	r0, =printn
	ldr	r1, =paddle_location
	ldr	r1, [r1, #4]
	bl	printf
	pop	{r0, r1, r2, r3, r4, r5, r6}

	
	ldr 	r0, =frameBufferInfo
	ldr 	fb_ptr, [r0]
	ldr 	r1, [r0, #4]
	ldr 	r2, [r0, #8]

// element fb_offset = (y * width) + x
	mul fb_offset, y_axis, r1
	add fb_offset, x_axis

// physical fb_offset *= 4 (each pixel is 4 bytes in size)
	lsl fb_offset, #2
	
	mov j_r, #0
	mov i_r, #0
loop:
	ldr r0, [addr]
	str r0, [fb_ptr, fb_offset]
	add i_r, #1	
	add fb_offset, #4		// increment fb horizontally (by 4 bytes ie 1 px) 
	add addr, #4			// increment address to load from to the next image pixel in img
	cmp i_r, width		// if i_r < 16*4 (image length in bytes),
	blo loop

	add fb_offset, r1, lsl #2
	sub fb_offset, width, lsl #2 
	mov i_r, #0
	add j_r, #1			// increment vertically
	cmp j_r, height
	blt loop


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

paddle_location:
	.word	850
	.word 	850

printn:
	.string	"Button: %d\n\n"
print:
	.string	"Here\n\n"

/*
	push	{r0, r1, r2, r3, r4, r5, r6}
	ldr	r0, =printn
	mov	r1, x_axis
	bl	printf
	ldr	r0, =printn
	mov	r1, y_axis
	bl	printf
	ldr	r0, =printn
	mov	r1, width
	bl	printf
	ldr	r0, =printn
	mov	r1, height
	bl	printf
	pop	{r0, r1, r2, r3, r4, r5, r6}
*/
