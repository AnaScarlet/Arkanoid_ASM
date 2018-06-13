.global draw_number


// Args:
//	r0 - main's fp
//	r1 - number to draw
//	r2 - x position of image
//	r3 - y position of image

draw_number:
	push {r4, r5, fp, lr}
	mov fp, r0		// same as main's fp

// set image dimentions
	mov r0, #14
	str r0, [fp, #12]
	mov r0, #20
	str r0, [fp, #16]

	mov r4, r2		// x position
	mov r5, r3		// y position

// Finding out the number to draw
	teq r1, #0
	bleq draw_0

	teq r1, #1
	bleq draw_1

	teq r1, #2
	bleq draw_2

	teq r1, #3
	bleq draw_3

	teq r1, #4
	bleq draw_4

	teq r1, #5
	bleq draw_5

	teq r1, #6
	bleq draw_6

	teq r1, #7
	bleq draw_7

	teq r1, #8
	bleq draw_8

	teq r1, #9
	bleq draw_9

	teq r1, #10
	bleq draw_1
	addeq r4, #19
	bleq draw_0

	teq r1, #11
	bleq draw_1
	addeq r4, #19
	bleq draw_1

	teq r1, #12
	bleq draw_1
	addeq r4, #19
	bleq draw_2

	teq r1, #13
	bleq draw_1
	addeq r4, #19
	bleq draw_3

	teq r1, #14
	bleq draw_1
	addeq r4, #19
	bleq draw_4

	teq r1, #15
	bleq draw_1
	addeq r4, #19
	bleq draw_5

	teq r1, #16
	bleq draw_1
	addeq r4, #19
	bleq draw_6

	teq r1, #17
	bleq draw_1
	addeq r4, #19
	bleq draw_7

	teq r1, #18
	bleq draw_1
	addeq r4, #19
	bleq draw_8

	teq r1, #19
	bleq draw_1
	addeq r4, #19
	bleq draw_9

	teq r1, #20
	bleq draw_2
	addeq r4, #19
	bleq draw_0

	teq r1, #21
	bleq draw_2
	addeq r4, #19
	bleq draw_1

	teq r1, #22
	bleq draw_2
	addeq r4, #19
	bleq draw_2

	teq r1, #23
	bleq draw_2
	addeq r4, #19
	bleq draw_3

	teq r1, #24
	bleq draw_2
	addeq r4, #19
	bleq draw_4

	teq r1, #25
	bleq draw_2
	addeq r4, #19
	bleq draw_5

	teq r1, #26
	bleq draw_2
	addeq r4, #19
	bleq draw_6

	teq r1, #27
	bleq draw_2
	addeq r4, #19
	bleq draw_7

	teq r1, #28
	bleq draw_2
	addeq r4, #19
	bleq draw_8

	teq r1, #29
	bleq draw_2
	addeq r4, #19
	bleq draw_9

	teq r1, #30
	bleq draw_3
	addeq r4, #19
	bleq draw_0

	teq r1, #31
	bleq draw_3
	addeq r4, #19
	bleq draw_1

	teq r1, #32
	bleq draw_3
	addeq r4, #19
	bleq draw_2

	teq r1, #33
	bleq draw_3
	addeq r4, #19
	bleq draw_3

	teq r1, #34
	bleq draw_3
	addeq r4, #19
	bleq draw_4

	teq r1, #35
	bleq draw_3
	addeq r4, #19
	bleq draw_5

	teq r1, #36
	bleq draw_3
	addeq r4, #19
	bleq draw_6

	teq r1, #37
	bleq draw_3
	addeq r4, #19
	bleq draw_7

	teq r1, #38
	bleq draw_3
	addeq r4, #19
	bleq draw_8

	teq r1, #39
	bleq draw_3
	addeq r4, #19
	bleq draw_9

	teq r1, #40
	bleq draw_4
	addeq r4, #19
	bleq draw_0

	teq r1, #41
	bleq draw_4
	addeq r4, #19
	bleq draw_1

	teq r1, #42
	bleq draw_4
	addeq r4, #19
	bleq draw_2

	teq r1, #43
	bleq draw_4
	addeq r4, #19
	bleq draw_3

	teq r1, #44
	bleq draw_4
	addeq r4, #19
	bleq draw_4

	teq r1, #45
	bleq draw_4
	addeq r4, #19
	bleq draw_5

	teq r1, #46
	bleq draw_4
	addeq r4, #19
	bleq draw_6

	teq r1, #47
	bleq draw_4
	addeq r4, #19
	bleq draw_7

	teq r1, #48
	bleq draw_4
	addeq r4, #19
	bleq draw_8

	teq r1, #49
	bleq draw_3
	addeq r4, #19
	bleq draw_9

	teq r1, #50
	bleq draw_5
	addeq r4, #19
	bleq draw_0

	teq r1, #51
	bleq draw_5
	addeq r4, #19
	bleq draw_1

	teq r1, #52
	bleq draw_5
	addeq r4, #19
	bleq draw_2

	teq r1, #53
	bleq draw_5
	addeq r4, #19
	bleq draw_3

	teq r1, #54
	bleq draw_5
	addeq r4, #19
	bleq draw_4

	teq r1, #55
	bleq draw_5
	addeq r4, #19
	bleq draw_5

	teq r1, #56
	bleq draw_5
	addeq r4, #19
	bleq draw_6

	teq r1, #57
	bleq draw_5
	addeq r4, #19
	bleq draw_7

	teq r1, #58
	bleq draw_5
	addeq r4, #19
	bleq draw_8

	teq r1, #59
	bleq draw_5
	addeq r4, #19
	bleq draw_9

	teq r1, #60
	bleq draw_6
	addeq r4, #19
	bleq draw_0

	teq r1, #61
	bleq draw_6
	addeq r4, #19
	bleq draw_1

	teq r1, #62
	bleq draw_6
	addeq r4, #19
	bleq draw_2

	teq r1, #63
	bleq draw_6
	addeq r4, #19
	bleq draw_3

	teq r1, #64
	bleq draw_6
	addeq r4, #19
	bleq draw_4

	teq r1, #65
	bleq draw_6
	addeq r4, #19
	bleq draw_5

	teq r1, #66
	bleq draw_6
	addeq r4, #19
	bleq draw_6

	teq r1, #67
	bleq draw_6
	addeq r4, #19
	bleq draw_7

	teq r1, #68
	bleq draw_6
	addeq r4, #19
	bleq draw_8

	teq r1, #69
	bleq draw_6
	addeq r4, #19
	bleq draw_9

	teq r1, #70
	bleq draw_7
	addeq r4, #19
	bleq draw_0

	teq r1, #71
	bleq draw_7
	addeq r4, #19
	bleq draw_1

	teq r1, #72
	bleq draw_7
	addeq r4, #19
	bleq draw_2

	teq r1, #73
	bleq draw_7
	addeq r4, #19
	bleq draw_3

	teq r1, #74
	bleq draw_7
	addeq r4, #19
	bleq draw_4

	teq r1, #75
	bleq draw_7
	addeq r4, #19
	bleq draw_5

	teq r1, #76
	bleq draw_7
	addeq r4, #19
	bleq draw_6

	teq r1, #77
	bleq draw_7
	addeq r4, #19
	bleq draw_7

	teq r1, #78
	bleq draw_7
	addeq r4, #19
	bleq draw_8

	teq r1, #79
	bleq draw_7
	addeq r4, #19
	bleq draw_9

	teq r1, #80
	bleq draw_8
	addeq r4, #19
	bleq draw_0

	teq r1, #81
	bleq draw_8
	addeq r4, #19
	bleq draw_1

	teq r1, #82
	bleq draw_8
	addeq r4, #19
	bleq draw_2

	teq r1, #83
	bleq draw_8
	addeq r4, #19
	bleq draw_3

	teq r1, #84
	bleq draw_8
	addeq r4, #19
	bleq draw_4

	teq r1, #85
	bleq draw_8
	addeq r4, #19
	bleq draw_5

	teq r1, #86
	bleq draw_8
	addeq r4, #19
	bleq draw_6

	teq r1, #87
	bleq draw_8
	addeq r4, #19
	bleq draw_7

	teq r1, #88
	bleq draw_8
	addeq r4, #19
	bleq draw_8

	teq r1, #89
	bleq draw_8
	addeq r4, #19
	bleq draw_9

	teq r1, #90
	bleq draw_9
	addeq r4, #19
	bleq draw_0


	pop {r4, r5, fp, lr}
	bx lr

draw_0:
	push {lr}
	bl get_0
	mov r1, r4
	mov r2, r5		// 48
	mov r3, fp
	bl draw_img
	pop {lr}
	bx lr

draw_1:
	push {lr}
	bl get_1
	mov r1, r4
	mov r2, r5		// 48
	mov r3, fp
	bl draw_img
	pop {lr}
	bx lr

draw_2:
	push {lr}
	bl get_2
	mov r1, r4
	mov r2, r5		// 48
	mov r3, fp
	bl draw_img
	pop {lr}
	bx lr

draw_3:
	push {lr}
	bl get_3
	mov r1, r4
	mov r2, r5
	mov r3, fp
	bl draw_img
	pop {lr}
	bx lr

draw_4:
	push {lr}
	bl get_4
	mov r1, r4
	mov r2, r5		// 48
	mov r3, fp
	bl draw_img
	pop {lr}
	bx lr

draw_5: 
	push {lr}
	bl get_5
	mov r1, r4
	mov r2, r5		// 48
	mov r3, fp
	bl draw_img
	pop {lr}
	bx lr

draw_6:
	push {lr}
	bl get_6
	mov r1, r4
	mov r2, r5		// 48
	mov r3, fp
	bl draw_img
	pop {lr}
	bx lr

draw_7:
	push {lr}
	bl get_7
	mov r1, r4
	mov r2, r5		// 48
	mov r3, fp
	bl draw_img
	pop {lr}
	bx lr

draw_8:
	push {lr}
	bl get_8
	mov r1, r4
	mov r2, r5		// 48
	mov r3, fp
	bl draw_img
	pop {lr}
	bx lr

draw_9:
	push {lr}
	bl get_9
	mov r1, r4
	mov r2, r5		// 48
	mov r3, fp
	bl draw_img
	pop {lr}
	bx lr


	
