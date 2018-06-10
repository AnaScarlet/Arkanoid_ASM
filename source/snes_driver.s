///////////////////////////////////////////////////////////////////////////////
//			      SNES Controller Driver			     //
//									     //
//	Student: 	John Strachan					     //
//	UCID:		30041469					     //
//	Course:		CPSC 359					     //
//	FileName:	snes_driver.s					     //
//									     //
//	This program is a driver for a SNES controller. When run, this       //
//	program reads input from the snes controller and returns the 	     //
//	appropriate value to the caller.				     //
//									     //
///////////////////////////////////////////////////////////////////////////////
	gBase	.req	r6
	stream	.req	r7

	.section .text
	.global	init_snes
	.global Read_SNES

init_snes:
	push	{lr}
	ldr	r0, =GpioPtr			// load GpioPtr location to r0
 	bl	initGpioPtr			// call initGpioPtr
	ldr	r0, =GpioPtr			// load GpioPtr location to r0
	ldr	gBase, [r0]			// load gBase register from GpioPtr	

	bl	Init_GPIO			// call to Init_GPIO
	
	pop	{lr}
	bx	lr
///////////////////////////////////////////////////////////////////////////////
	
///////////////////////////////////////////////////////////////////////////////
//				 Init_GPIO				     //
//									     //
//	This subroutine initializes GPIO line 9 to output, GPIO line 10 to   //
//	input, and GPIO line 11 to output.				     //
//									     //
//	input:	nil							     //
//	output: nil							     //
//									     //
///////////////////////////////////////////////////////////////////////////////
Init_GPIO:
	push	{lr}				// push lr to stack
//set latch (line 9) to output	
	mov	r0, gBase			// set GPFSEL to 0
	mov	r1, #27				// set line to #27
	mov	r2, #1				// set function code to output
	bl	Set_Code			// call Set_Code

//set data (line 10) to input
	add	r0, gBase, #0x04		// set GPFSEL to 1
	mov	r1, #0				// set line to #0
	mov	r2, #0				// set function code to input
	bl	Set_Code			// call Set_Code

//set clock (line 11) to output
	add	r0, gBase, #0x04		// set GPFSEL to 1
	mov	r1, #3				// set line to #3
	mov	r2, #1				// set function code to output
	bl	Set_Code			// call Set_Code

	pop	{lr}				// pop lr from stack
	bx	lr				// return
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
//				Set_Code				     //
//									     //
//	This subroutine sets the provided function code to the provided      //
//	line.								     //
//									     //
//	REFERENCE: ARM 6 - SNES lecture slide 11			     //
//									     //
//	input:	r0:	GPFSEL#						     //
//		r1:	1st bit for line				     //
//		r2:	function code					     //
//	output: nil							     //
//									     //
///////////////////////////////////////////////////////////////////////////////
Set_Code:
	push	{r4, r5}			// push r4 and r5 to stack
	ldr	r4, [r0]			// copy GPFSEL0 into r4
	mov	r5, #7				// b0111
	bic	r4, r5, lsl r1			// clear line09 bits
	orr	r4, r2, lsl r1			// set line09 function in r1
	str	r4, [r0]			// write back to GPFSEL0
	pop	{r4, r5}			// pop r4 and r5 from stack
	bx	lr				// return
///////////////////////////////////////////////////////////////////////////////
	
///////////////////////////////////////////////////////////////////////////////
//				Write_Latch				     //
//									     //
//	This subroutine writes to the Latch line.			     //
//									     //
//	REFERENCE: ARM 6 - SNES lecture slide 20			     //
//									     //
//	input:	r0 = value to write					     //
//	output: nil							     //
//									     //
///////////////////////////////////////////////////////////////////////////////
Write_Latch:
	mov	r1, #1				// set r1 to #1
	lsl	r1, #9				// shift left to Latch line
	teq	r0, #0				// teq value to write with #0
	streq	r1, [gBase, #40]		// GPCLR0 if value = 0
	strne	r1, [gBase, #28]		// GPSET0 if vlaue = 1
	bx	lr				// return
///////////////////////////////////////////////////////////////////////////////
	
///////////////////////////////////////////////////////////////////////////////
//				Write_Clock				     //
//									     //
//	This subroutine writes to the Clock line.			     //
//									     //
//	REFERENCE: ARM 6 - SNES lecture slide 20			     //
//									     //
//	input:	r0 = value to write					     //
//	output: nil							     //
//									     //
///////////////////////////////////////////////////////////////////////////////
Write_Clock:
	mov	r1, #1				// set r1 to #1
	lsl	r1, #11				// shift left to Clock line
	teq	r0, #0				// teq value to write with #0
	streq	r1, [gBase, #40]		// GPCLR0 if value = 0
	strne	r1, [gBase, #28]		// GPSET0 if value = 1
	bx	lr				// return
///////////////////////////////////////////////////////////////////////////////
	
///////////////////////////////////////////////////////////////////////////////
//				Read_Data				     //
//									     //
//	This subroutine reads from the Data line.			     //
//									     //
//	REFERENCE: ARM 6 - SNES lecture slide 21			     //
//									     //
//	input:	nil							     //
//	output: r0 = value that was read from Data line			     //
//									     //
///////////////////////////////////////////////////////////////////////////////
Read_Data:
	ldr	r0, [gBase, #52]		// load GPLEV0 to t0
	mov	r1, #1				// set r1 ro #1
	lsl	r1, #10				// shift left to Data line
	and	r0, r1				// r0 = GPLEV0 AND #1
	teq	r0, #0				// teq r0 and #0
	moveq	r0, #0				// return #0 if equal
	movne	r0, #1				// return #1 if not equal
	bx	lr				// return
///////////////////////////////////////////////////////////////////////////////
	
///////////////////////////////////////////////////////////////////////////////
//				Read_SNES				     //
//									     //
//	This subroutine reads user input from the SNES Controller.	     //
//									     //
//	REFERENCE: ARM 6 - SNES lecture slide 21			     //
//									     //
//	input:	nil							     //
//	output: Input and Quit flags stored in memory 			     //
//									     //
///////////////////////////////////////////////////////////////////////////////
Read_SNES:
	push	{r4, r5, lr}			// push r4, r5 and lr to stack

	mov	r0, #1				// set r0 to #1
	bl	Write_Clock			// call Write_Clock

	mov	r0, #1				// set r0 to #1
	bl	Write_Latch			// call Write_Latch

	mov	r0, #12				// set r0 to #12
	bl	delayMicroseconds		// call delayMicroseconds
	
	mov	r0, #0				// set r0 to #0
	bl	Write_Latch			// call Write_Latch

	mov	r5, #0				// init loop counter to 0
	mov	stream, #0			// init stream to 0
pulse:
	mov	r0, #6				// set r0 to #6
	bl	delayMicroseconds		// call delayMicroseconds

	mov	r0, #0				// set r0 to #0
	bl	Write_Clock			// call Write_Clock

	mov	r0, #6				// set r0 to #6
	bl	delayMicroseconds		// call delayMicroseconds

	bl	Read_Data			// call Read_Data
	lsl	stream, #1			// shift stream left by 1
	add	stream, r0			// add read bit to stream

	mov	r0, #1				// set #1 to #1
	bl	Write_Clock			// call Write_Clock

	add	r5, #1				// increment loop counter
	cmp	r5, #16				// compare to #16
	blt	pulse				// branch to pulse if r5 < #16

	ldr	r0, =NoBtns			// load NoBtns location to r0
	ldr	r0, [r0]			// load #0xFFFF to r0
	cmp	stream, r0			// check if a button was pressed
	beq	no_input			// branch to no_input if no button pressed
	
	mov	r4, #11				// initialize loop counter
	mov	r5, #0b10000			// initialize r6 to 0b10000
	b	test
feedback:
// bit clear stream except for the bit being checked, then check if it was pressed
	ldr	r0, =NoBtns			// load NoBtns location to r0
	ldr	r0, [r0]			// load NoBtns value to r0
	bic	r0, r0, r5			// bic NoBtns with r5 into r0
	bic	r0, stream, r0			// bic stream with r0 into r0
	cmp	r0, #0				// compare r0 to #0
	beq	right
// skip if button was not pressed
	sub	r4, #1				// decrement loop counter
	lsl	r5, #1				// shift r5 left by 1
test:
	cmp	r4, #0				// compare loop counter to #0
	blt	stop				// branch to stop if < #0	
	b	feedback			// branch to feedback
right:
	cmp	r4, #11
	bne	left
	mov	r0, #Other
	b	stop
left:
	cmp	r4, #10
	bne	x
	mov	r0, #Other
	b	stop
x:
	cmp	r4, #9
	bne	a
	mov	r0, #Other
	b	stop
a:
	cmp	r4, #8
	bne	j_right
	b 	a_left
j_right:
	cmp	r4, #7
	bne	j_left
	mov	r0, #J_right
	b	stop
j_left:
	cmp	r4, #6
	bne	j_down
	mov	r0, #J_left
	b	stop
j_down:
	cmp	r4, #5
	bne	j_up
	mov	r0, #J_down
	b	stop
j_up:
	cmp	r4, #4
	bne	start
	mov	r0, #J_up
	b	stop
start:
	cmp	r4, #3
	bne	select
	mov	r0, #Start
	b	stop
select:
	cmp	r4, #2
	bne	y
	mov	r0, #Select
	b	stop
y:
	cmp	r4, #1
	bne	b
	mov	r0, #Other
	b	stop
b:
	mov	r0, #Bee
	b	stop
a_left:
// bit clear stream except for the bit being checked, then check if it was pressed
	ldr	r0, =#0xFDFF			// load NoBtns value to r0
	bic	r0, stream, r0			// bic stream with r0 into r0
	cmp	r0, #0				// compare r0 to #0
	moveq	r0, #A_Left
	bne	a_right
	b	stop
a_right:
// bit clear stream except for the bit being checked, then check if it was pressed
	ldr	r0, =#0xFEFF			// load NoBtns value to r0
	bic	r0, stream, r0			// bic stream with r0 into r0
	cmp	r0, #0				// compare r0 to #0
	movne	r0, #A
	moveq	r0, #A_Right
	b	stop
no_input:
	mov	r0, #No_btn
stop:	
	pop	{r4, r5, lr}			// pop r4, r5 and lr from stack
	bx	lr				// return
///////////////////////////////////////////////////////////////////////////////

	

	.section .data
	.align 2	
	.global	GpioPtr

GpioPtr:
	.int	0
NoBtns:
	.int	0xFFFF
print:
	.string	"%d\n\n"

	No_btn	= 0
	Other	= 1
	A 	= 2
	J_right	= 3
	J_left	= 4
	Start	= 5
	Select	= 6
	Bee	= 7
	A_Left	= 8
	A_Right	= 9
	J_up	= 10
	J_down	= 11
