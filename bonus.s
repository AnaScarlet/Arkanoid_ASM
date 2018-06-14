//Code section for drawing the bonus bricks and making them "fall"
.section .text

	ObjAddr	.req	r4

//stops the falling brick when it reaches the paddle
.global StopsBrick
StopsBrick:
	ldr	r1, [r0, #12]		//load activation
	mov	r1, #-1			//mov -1 into r1
	str	r1, [r0, #12]		//store activation
	bx	lr			//return

//drawing the 1st bonus brick and making it "fall" from point (1092, 287)
.global print_moving_brick1
print_moving_brick1:
	push	{lr}
	ldr	r0, =movingBrick1	//load x, y, friction, and activation of 1st bonus brick
	ldr	r2, [r0, #4]		//load y into r2
	bl	UpdateVertLoc		//Update Vertical Location of 1st bonus brick
	
	ldr	r0, =movingBrick1	//load x, y, friction, and activation of 1st bonus brick
	ldr	r1, [r0, #4]		//load y into r2
	ldr	r2, =#850		//r2 = 850
	cmp	r1, r2			//compare y to 850
	ldrlt	r1, [r0, #0]		//load x into r1 if y < 850
	ldrlt	r2, [r0, #4]		//load y into r2 if y < 850
	bllt	print_bonus		//Draw the 1st Updated bonus brick
	pop	{lr}
	bx	lr			//return

//drawing the 2nd bonus brick and making it "fall" from point (792, 367)
.global print_moving_brick2
print_moving_brick2:	
	push	{lr}
	ldr	r0, =movingBrick2	//load x, y, friction, and activation of 2nd bonus brick
	ldr	r2, [r0, #4]		//load y into r2
	bl	UpdateVertLoc		//Update Vertical Location of 2nd bonus brick

	ldr	r0, =movingBrick2	//load x, y, friction, and activation of 2nd bonus brick
	ldr	r1, [r0, #4]		//load y into r2
	ldr	r2, =#850		//r2 = 850
	cmp	r1, r2			//compare y to 850
	ldrlt	r1, [r0, #0]		//load x into r1 if y < 850
	ldrlt	r2, [r0, #4]		//load y into r2 if y < 850
	bllt	print_bonus		//Draw 2nd Updated bonus brick
	pop	{lr}
	bx	lr			//return


//drawing the 3rd bonus brick and making it "fall" from point (1032, 447)
.global print_moving_brick3
print_moving_brick3:	
	push	{lr}
	ldr	r0, =movingBrick3	//load x, y, friction, and activation of 3rd bonus brick
	ldr	r2, [r0, #4]		//load y into r2
	bl	UpdateVertLoc		//Update Vertical Location of 3rd bonus brick
	
	ldr	r0, =movingBrick3	//load x, y, and friction of 3rd bonus brick
	ldr	r1, [r0, #4]		//load y into r2
	ldr	r2, =#850		//r2 = 850
	cmp	r1, r2			//compare y to 850
	ldrlt	r1, [r0, #0]		//load x into r1 if y < 850
	ldrlt	r2, [r0, #4]		//load y into r1 if y < 850
	bllt	print_bonus		//Draw 3rd Updated bonus brick
	pop	{lr}
	bx	lr			//return

//Updates the Vertical Location of the bonus bricks
//r0 - Object Structure Address
//this functon is copied from Tut08 main.s	
UpdateVertLoc:
	push	{r4, lr}
	mov	ObjAddr, r0		//move r0 into ObjAddr to avoid it being overwritten
	ldr	r0, [ObjAddr, #8]	//load friction into r0
	bl	delay			//delay in msec

//Update vertical coordinates by one pixel
	ldr	r2, [ObjAddr, #4]	//load y into r2
	add	r2, #1			//add 1 to y
	ldr	r3, =#850		//load 850 into r3
	cmp	r2, r3			//compare y and 850
	strlt	r2, [ObjAddr, #4]	//store y if y < 850

//Get width-1
	ldr	r0, =frameBufferInfo
	ldr	r3, [r0, #8]
	sub	r3, #1
	
//set Quit flag if drawing outside the screen

	cmp	r2, #880		//compare y with 880 (screen width)
	movge	r2, #1			//if y > 880, move 1 into y
	strge	r2, [r0]		//if y > 880, store r0 into y
	pop	{r4, lr}
	bx	lr			//return

//draws the bonus bricks
img_hi_bonus = 40			//height of bonus bricks			
print_bonus:
	push	{r4, lr}
	mov	r0, #60			//brick width
	str 	r0, [fp, #12]		//load activation
	mov 	r0, #img_hi_bonus	//brick height
	str 	r0, [fp, #16]		//address of image as 1st argument
	mov	r5, r1			//move r1 into r5 to avoid being overwritten
	mov	r4, r2			//move r2 into r4 for the same reason
	bl	get_bonus_brick		//get the pic of bonus brick as 1st argument
	mov	r1, r5			//x as 2nd argument
	mov	r2, r4			//y as 3rd argument
	mov	r3, fp			//fp as 4th argument
	bl	draw_img		//branch to draw_img
	pop	{r4, lr}
	bx	lr			//return

.global printBricks
printBricks:
	push	{lr}
	ldr	r0, =movingBrick1	//load x, y, friction, and activation of 1st bonus brick
	ldr	r1, [r0, #12]		//load activation
	cmp	r1, #1			//if activation is 1
	bleq	print_moving_brick1	//branch and link to print_moving_brick1

	ldr	r0, =movingBrick2	//load x, y, friction, and activation of 2nd bonus brick
	ldr	r1, [r0, #12]		//load activation
	cmp	r1, #1			//if activation is 1
	bleq	print_moving_brick2	//branch and link to print_moving_brick2

	ldr	r0, =movingBrick3	//load x, y, friction, and activation of 3rd bonus brick
	ldr	r1, [r0, #12]		//load activation
	cmp	r1, #1			//if activation is 1
	bleq	print_moving_brick3	//branch and link to print_moving_brick3

	pop	{lr}
	bx	lr			//return


//Data section	
.section .data
.align
.global movingBrick1
movingBrick1:
	.int	1092, 287	//x and y of 1st bonus brick
	.int	10		//friction
	.int	0		//activatation for when brick1 is hit

.global movingBrick2
movingBrick2:
	.int	792, 367	//x and y of 3rd bonus brick
	.int	10		//friction
	.int	0		//activatation for when brick2 is hit

.global movingBrick3
movingBrick3:
	.int	1032, 447	//x and y of 6th bonus brick
	.int	10		//friction
	.int	0		//activatation for when brick3 is hit


