//Code section for drawing the bonus bricks as they "fall"
.section .text

	ObjAddr	.req	r4

//drawing the 1st bonus brick	
.global print_moving_brick1
print_moving_brick1:
	push	{lr}
	ldr	r0, =movingBrick1	//load x, y, and friction of 1st bonus brick
	ldr	r2, [r0, #4]		//load y into r2
	bl	UpdateVertLoc		//Update Vertical Location of 1st bonus brick

	ldr	r0, =movingBrick1	//load x, y, and friction of 1st bonus brick
	ldr	r2, [r0, #4]		//load y into r2
	bl	print_bonus1		//draw 1st Updated bonus brick
	pop	{lr}
	bx	lr

//drawing the 2nd bonus brick		
.global print_moving_brick2
print_moving_brick2:	
	push	{lr}
	ldr	r0, =movingBrick2	//load x, y, and friction of 2nd bonus brick
	ldr	r2, [r0, #4]		//load y into r2
	bl	UpdateVertLoc		//Update Vertical Location of 2nd bonus brick

	ldr	r0, =movingBrick2	//load x, y, and frictio of 2nd bonus brickn
	ldr	r2, [r0, #4]		//load y into r2
	bl	print_bonus2		//Draw 2nd Updated bonus brick
	pop	{lr}
	bx	lr

//drawing the 3rd bonus brick
.global print_moving_brick3
print_moving_brick3:	
	push	{lr}
	ldr	r0, =movingBrick3	//load x, y, and friction of 3rd bonus brick
	ldr	r2, [r0, #4]		//load y into r2
	bl	UpdateVertLoc		//Update Vertical Location of 3rd bonus brick

	ldr	r0, =movingBrick3	//load x, y, and friction of 3rd bonus brick
	ldr	r2, [r0, #4]		//load y into r2
	bl	print_bonus3		//Draw 3rd Updated bonus brick
	pop	{lr}
	bx	lr

//drawing the 4th bonus brick		
.global print_moving_brick4
print_moving_brick4:	
	push	{lr}
	ldr	r0, =movingBrick4	//load x, y, and friction of 4th bonus brick
	ldr	r2, [r0, #4]		//load y into r2
	bl	UpdateVertLoc		//Update Vertical Location of 4th bonus brick

	ldr	r0, =movingBrick4	//load x, y, and friction of 4th bonus brick
	ldr	r2, [r0, #4]		//load y into r2
	bl	print_bonus4		//Draw 4th Updated bonus brick
	pop	{lr}
	bx	lr

//drawing the 5th bonus brick		
.global print_moving_brick5
print_moving_brick5:	
	push	{lr}
	ldr	r0, =movingBrick5	//load x, y, and friction of 5th bonus brick
	ldr	r2, [r0, #4]		//load y into r2
	bl	UpdateVertLoc		//Update Vertical Location of 5th bonus brick

	ldr	r0, =movingBrick5	//load x, y, and friction of 5th bonus brick
	ldr	r2, [r0, #4]		//load y into r2
	bl	print_bonus5		//Draw 5th Updated bonus brick
	pop	{lr}
	bx	lr

//drawing the 6th bonus brick		
.global print_moving_brick6
print_moving_brick6:	
	push	{lr}
	ldr	r0, =movingBrick6	//load x, y, and friction of 6th bonus brick
	ldr	r2, [r0, #4]		//load y into r2
	bl	UpdateVertLoc		//Update Vertical Location of 6th bonus brick
	
	ldr	r0, =movingBrick6	//load x, y, and friction of 6th bonus brick
	ldr	r2, [r0, #4]		//load y into r2
	bl	print_bonus6		//Draw 6th Updated bonus brick
	pop	{lr}
	bx	lr
	
DrawLoop:
//Draw Updated Object	
	ldr	r0, =movingBrick1
	ldr	r2, [r0, #4]
	bl	print_bonus1

//Check for a Quit condition
	ldr	r0, =Quit
	ldr	r0, [r0]
	cmp	r0, #0
	beq	DrawLoop

//Stop
haltLoop$:
	b	haltLoop$

//Updates the Vertical Location of the bonus bricks
//r0 - Object Structure Address
//this functon is copied from Tut08 main.s	
UpdateVertLoc:
	push	{r4, lr}
	mov	ObjAddr, r0		//r4 = r0
	ldr	r0, [ObjAddr, #8]	//friction
	bl	delay			//delay in msec

//Update vertical coordinates by one pixel
	ldr	r2, [ObjAddr, #4]
	add	r2, #1
	str	r2, [ObjAddr, #4]

//Get width-1
	ldr	r0, =frameBufferInfo
	ldr	r3, [r0, #8]
	sub	r3, #1
	
//set Quit flag if drawing outside the screen
	ldr	r0, =Quit
	cmp	r2, #880		//compare r2 with screen width (880)
	movge	r2, #1
	strge	r2, [r0]		
	pop	{r4, pc}
	bx	lr

//draws the 1st bonus brick	
img_hi_bonus = 40			//height of bonus bricks			
print_bonus1:
	push	{r4, lr}
	mov	r0, #60			//brick width
	str 	r0, [fp, #12]
	mov 	r0, #img_hi_bonus	//brick height
	str 	r0, [fp, #16]		//address of image as 1st argument
	mov	r4, r2			//r4 = r2
	bl	get_bonus_brick		//get the pic of bonus brick
	mov	r1, #1092		//x as 2nd argument
	mov	r2, r4			//y as 3rd argument
	mov	r3, fp			//fp as 4th argument
	bl	draw_img		//branch to draw_img
	pop	{r4, lr}
	bx	lr

//draws the 2nd bonus brick	
print_bonus2:
	push	{r4, lr}
	mov	r0, #60			//brick width
	str 	r0, [fp, #12]
	mov 	r0, #img_hi_bonus	//brick height
	str 	r0, [fp, #16]		//address of image as 1st argument
	mov	r4, r2			//r4 = r2
	bl	get_bonus_brick		//get the pic of bonus brick
	mov	r1, #1032		//x as 2nd argument
	mov	r2, r4			//y as 3rd argument
	mov	r3, fp			//fp as 4th argument
	bl	draw_img		//branch to draw_img
	pop	{r4, lr}
	bx	lr

//draws the 3rd bonus brick
print_bonus3:
	push	{r4, lr}
	mov	r0, #60			//brick width
	str 	r0, [fp, #12]
	mov 	r0, #img_hi_bonus	//brick height
	str 	r0, [fp, #16]		//address of image as 1st argument
	mov	r4, r2			//r4 = r2	
	bl	get_bonus_brick		//get the pic of bonus brick
	mov	r1, #792		//x as 2nd argument
	mov	r2, r4			//y as 3rd argument
	mov	r3, fp			//fp as 4th argument
	bl	draw_img		//branch to draw_img
	pop	{r4, lr}
	bx	lr

//draws the 4th bonus brick	
print_bonus4:
	push	{r4, lr}
	mov	r0, #60			//brick width
	str 	r0, [fp, #12]
	mov 	r0, #img_hi_bonus	//brick height
	str 	r0, [fp, #16]		//address of image as 1st argument
	mov	r4, r2			//r4 = r2	
	bl	get_bonus_brick		//get the pic of bonus brick
	mov	r1, #912		//x as 2nd argument
	mov	r2, r4			//y as 3rd argument
	mov	r3, fp			//fp as 4th argument
	bl	draw_img		//branch to draw_img
	pop	{r4, lr}
	bx	lr

//draws the 5th bonus brick	
print_bonus5:
	push	{r4, lr}
	mov	r0, #60			//brick width
	str 	r0, [fp, #12]
	mov 	r0, #img_hi_bonus	//brick height
	str 	r0, [fp, #16]		//address of image as 1st argument
	mov	r4, r2			//r4 = r2	
	bl	get_bonus_brick		//get the pic of bonus brick
	mov	r1, #672		//x as 2nd argument
	mov	r2, r4			//y as 3rd argument
	mov	r3, fp			//fp as 4th argument
	bl	draw_img		//branch to draw_img
	pop	{r4, lr}
	bx	lr

//draws the 6th bonus brick	
print_bonus6:
	push	{r4, lr}
	mov	r0, #60			//brick width
	str 	r0, [fp, #12]
	mov 	r0, #img_hi_bonus	//brick height
	str 	r0, [fp, #16]		//address of image as 1st argument
	mov	r4, r2			//r4 = r2	
	bl	get_bonus_brick		//get the pic of bonus brick
	mov	r1, #1032		//x as 2nd argument
	mov	r2, r4			//y as 3rd argument
	mov	r3, fp			//fp as 4th argument
	bl	draw_img		//branch to draw_img
	pop	{r4, lr}
	bx	lr


//Data section	
.section .data
.align

//frameBufferInfo:
movingBrick1:
	.int	1092, 287	//x and y of 1st bonus brick
	.int	10		//friction

movingBrick2:
	.int	1032, 327	//x and y of 2nd bonus brick
	.int	10		//friction

movingBrick3:
	.int	792, 367	//x and y of 3rd bonus brick
	.int	10		//friction

movingBrick4:
	.int	912, 407	//x and y of 4th bonus brick
	.int	10		//friction

movingBrick5:
	.int	672, 447	//x and y of 5th bonus brick
	.int	10		//friction

movingBrick6:
	.int	1032, 447	//x and y of 6th bonus brick
	.int	10		//friction
	
Quit:
	.int	0		//Quit flag
