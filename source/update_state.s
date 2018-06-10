.global main
.section .text

tiles_minX = 612
tile0_minY = 247 
tile1_minY = 287
tile2_minY = 327
tile3_minY = 367
tile4_minY = 407
tile5_minY = 447


main:
	push {lr}

	mov r0, #2		// y
	mov r1, #2		// x
	ldr r2, =#327
	ldr r3, =#765
	bl update_tile_state

	ldr r0, =print_tile
	mov r1, #2
	ldr r2, =tile_row2
	ldr r2, [r2]		// the actual hex value of the tile row state variable 
	bl printf

	mov r0, #3
	mov r1, #1
	ldr r2, =#367
	ldr r3, =#705
	bl update_tile_state

	ldr r0, =print_tile
	mov r1, #3
	ldr r2, =tile_row3
	ldr r2, [r2]		// the actual hex value of the tile row state variable 
	bl printf

	mov r0, #2
	mov r1, #2
	ldr r2, =#327
	ldr r3, =#765
	bl update_tile_state

	ldr r0, =print_tile
	mov r1, #2
	ldr r2, =tile_row2
	ldr r2, [r2]		// the actual hex value of the tile row state variable 
	bl printf

	pop {lr}
	bx lr


// Args:
//	r0 - tile row number
//	r1 - tile number in row (countring from 0)
//	r2 - ball y coordinate
//	r3 - ball x coordinate
// Returns:
// 	Updates the state variables 
update_tile_state:
	push {r4, r5, r6, r7, r8, lr}
	mov r4, #tiles_minX
//	lsr r1, #1		// for using as the bit offset

	cmp r0, #0		// tile row 0
	beq tile0

	cmp r0, #1
	beq tile1

	cmp r0, #2
	beq tile2

	cmp r0, #3
	beq tile3

	cmp r0, #4
	beq tile4

	cmp r0, #5
	beq tile5

tile0:
	ldr r8, =tile_row0
	ldr r7, [r8]		// the current state of the tile row
	mov r0, #60		
	mul r0, r1
	add r4, r0		// tile min x
	add r6, r4, #60		// tile max x
	mov r5, #tile0_minY	// tile y
	cmp r5, r2		// if tile y  == ball y
	bne fin
	cmp r3, r6		// and if tile max x < ball x
	bgt fin
	cmp r3, r4		// and if tile min x > ball x
	blt fin	
	mov r0, #1		// then do a bit mask...
	lsl r2, r1, #1		// r1*3 because tile_row0 has 30 bits affected instead of 10
	add r1, r2, r1		// r1*3 = r1*2 + r1 = r2 + r1
	lsl r0, r1		// 1 at the tile's first number in the row...
	and r2, r7, r0
	teq r2, r0		// if the tile has already been hit (1st bit from the right is 1)
	bne skip		// if it hasn't been hit, skip next check and go to clear the bit
	lsl r0, #1		// if it has been hit, shift r0 to check the next bit 
	and r2, r7, r0		// resets r2
	teq r2, r0		// if the tile has been hit twice
	lsleq r0, #1		// shift r0 to clear the next bit (that the tile does not exist) 
skip:	bic r7, r0		// clear the bit
	orrne r7, r0		// otherwise, set the bit to 1 (that the tile has been hit)
	str r7, [r8]
	b fin

tile1:
	ldr r8, =tile_row1
	ldr r7, [r8]		// the current state of the tile row
	mov r0, #60		
	mul r0, r1
	add r4, r0		// tile min x
	add r6, r4, #60		// tile max x
	ldr r5, =#tile1_minY	// tile y
	cmp r5, r2		// if tile y  == ball y
	bne fin
	cmp r3, r6		// and if tile max x < ball x
	bgt fin
	cmp r3, r4		// and if tile min x > ball x
	blt fin	
	mov r0, #1		// then do a bit mask...
	lsl r2, r1, #1		// r1*3 because tile_row0 has 30 bits affected instead of 10
	add r1, r2, r1		// r1*3 = r1*2 + r1 = r2 + r1
	lsl r0, r1		// 1 at the tile's first number in the row...
	and r2, r7, r0
	teq r2, r0		// if the tile has already been hit (1st bit from the right is 1)
	lsleq r0, #2		// shift r0 to clear the exists bit (that the tile does not exist) 
	bic r7, r0		// clear the bit
	orrne r7, r0		// otherwise, set the bit to 1 (that the tile has been hit)
	str r7, [r8]
	b fin

tile2:
	ldr r8, =tile_row2
	ldr r7, [r8]		// the current state of the tile row
	mov r0, #60		
	mul r0, r1
	add r4, r0		// tile min x
	add r6, r4, #60		// tile max x
	ldr r5, =#tile2_minY	// tile y
	cmp r5, r2		// if tile y  == ball y
	bne fin
	cmp r3, r6		// and if tile max x < ball x
	bgt fin
	cmp r3, r4		// and if tile min x > ball x
	blt fin	
	mov r0, #1		// then do a bit mask...
	lsl r2, r1, #1		// r1*3 because tile_row0 has 30 bits affected instead of 10
	add r1, r2, r1		// r1*3 = r1*2 + r1 = r2 + r1
	lsl r0, r1		// 1 at the tile's first number in the row...
	and r2, r7, r0
	teq r2, r0		// if the tile has already been hit (1st bit from the right is 1)
	lsleq r0, #2		// shift r0 to clear the exists bit (that the tile does not exist) 
	bic r7, r0		// clear the bit
	orrne r7, r0		// otherwise, set the bit to 1 (that the tile has been hit)
	str r7, [r8]
	b fin

tile3:
	ldr r8, =tile_row3
	ldr r7, [r8]		// the current state of the tile row
	mov r0, #60		
	mul r0, r1
	add r4, r0		// tile min x
	add r6, r4, #60		// tile max x
	ldr r5, =#tile3_minY	// tile y
	cmp r5, r2		// if tile y  == ball y
	bne fin
	cmp r3, r6		// and if tile max x < ball x
	bgt fin
	cmp r3, r4		// and if tile min x > ball x
	blt fin	
	mov r0, #1		// then do a bit mask...
	lsl r2, r1, #1		// r1*3 because tile_row0 has 30 bits affected instead of 10
	add r1, r2, r1		// r1*3 = r1*2 + r1 = r2 + r1
	lsl r0, r1		// 1 at the tile's first number in the row...
	lsl r0, #2		// shift r0 to clear the exists bit (that the tile does not exist)
	bic r7, r0		// clear the bit
	str r7, [r8]
	b fin

tile4:
	ldr r8, =tile_row4
	ldr r7, [r8]		// the current state of the tile row
	mov r0, #60		
	mul r0, r1
	add r4, r0		// tile min x
	add r6, r4, #60		// tile max x
	ldr r5, =#tile4_minY	// tile y
	cmp r5, r2		// if tile y  == ball y
	bne fin
	cmp r3, r6		// and if tile max x < ball x
	bgt fin
	cmp r3, r4		// and if tile min x > ball x
	blt fin	
	mov r0, #1		// then do a bit mask...
	lsl r2, r1, #1		// r1*3 because tile_row0 has 30 bits affected instead of 10
	add r1, r2, r1		// r1*3 = r1*2 + r1 = r2 + r1
	lsl r0, r1		// 1 at the tile's first number in the row...
	lsl r0, #2		// shift r0 to clear the exists bit (that the tile does not exist)
	bic r7, r0		// clear the bit
	str r7, [r8]
	b fin

tile5:
	ldr r8, =tile_row5
	ldr r7, [r8]		// the current state of the tile row
	mov r0, #60		
	mul r0, r1
	add r4, r0		// tile min x
	add r6, r4, #60		// tile max x
	ldr r5, =#tile5_minY	// tile y
	cmp r5, r2		// if tile y  == ball y
	bne fin
	cmp r3, r6		// and if tile max x < ball x
	bgt fin
	cmp r3, r4		// and if tile min x > ball x
	blt fin	
	mov r0, #1		// then do a bit mask...
	lsl r2, r1, #1		// r1*3 because tile_row0 has 30 bits affected instead of 10
	add r1, r2, r1		// r1*3 = r1*2 + r1 = r2 + r1
	lsl r0, r1		// 1 at the tile's first number in the row...
	lsl r0, #2		// shift r0 to clear the exists bit (that the tile does not exist)
	bic r7, r0		// clear the bit
	str r7, [r8]
	b fin

fin:	pop {r4, r5, r6, r7, r8, lr}
	bx lr



.section .data

tile_row0:	.word	0b100100100100100100100100100100		// hardness level 3
tile_row1:	.word	0x24924924					// hardness level 2
tile_row2:	.word	0x24924924
tile_row3:	.word	0x24924924					// hardness level 1
tile_row4:	.word	0x24924924
tile_row5:	.word	0x24924924

print_tile: .string "Tile row %d: %#08x \n"

.end

