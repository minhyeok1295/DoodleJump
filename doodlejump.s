#####################################################################
#
# CSC258H5S Winter 2021 Assembly Programming Project
# University of Toronto Mississauga
#
# Group members:
# - Student 1: Min Hyeok Lee, 1004940273
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8					     
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 4
# 
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. Display the score on screen. The score should be constantly update as the game progresses. 
#  The final score is displayed on the game-over screen
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################

.data
	#newline: .asciiz "newline\n"
	sc: .asciiz "score is: "
	rc: .asciiz "remainder is: "
	qc: .asciiz "quotient is: "
	dc: .asciiz "divide by: "
	newline2: .asciiz "\n"
	displayAddress:	.word	0x10008000
	screenSize: .word 1024
	platformPos: .word  896, 1920, 2944, 3968 #7, 15, 23, 31
	
	#Colours
	backgroundColor: .word	0xfcfcdc #beige
	platformColor: .word  0xc1cc89 #green
	doodleColor: .word 0x0000ff #blue
	ggColor: .word 0x8B008B #purple
	
	#Platform
	doodle: .word, 13, 30, displayAddress, 0 #|maximum vertical movement | initial position| location of doodle | 0 for move up 1 for move down
	platforms: .space 8
	
	#Score
	score: .word 0
.text
	#global registers
	lw $s0, displayAddress
	la $s1, doodle
	la $s2, platforms
	lw $s4, score
	
	
main:	
	jal DrawBackground
	jal DrawInit
	InitGame:
		lw $t0, 0xffff0000
		bne $t0, 1, InitGame
		jal InitLocation
		jal DrawBackground
		jal InitDoodlePosition
		jal GameLoop
	
GameLoop:
	jal IsGameOver
	proceed:
	lw $t0, 8($s1) #store current
	#constantly move one row up
	jal VerticalMove
	jal DrawDoodle
	jal EraseDoodle
	#Move to left or right Check
	jal CheckMove
	jal DrawPlatform
	jal DrawDoodle
	jal EraseDoodle
	jal eraseScore
	jal DrawScore
	#
	li $v0, 32  #delay
	li $t0, 100
	move $a0,$t0
	syscall 
	j GameLoop

eraseScore:
	lw $t1, backgroundColor
	lw $t0, displayAddress
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 128($t0)
	sw $t1, 136($t0)
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 384($t0)
	sw $t1, 392($t0)
	sw $t1, 512($t0)
	sw $t1, 516($t0)
	sw $t1, 520($t0)
	addi $t0,$t0, 16
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 128($t0)
	sw $t1, 136($t0)
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 384($t0)
	sw $t1, 392($t0)
	sw $t1, 512($t0)
	sw $t1, 516($t0)
	sw $t1, 520($t0)
	addi $t0,$t0, 16
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 128($t0)
	sw $t1, 136($t0)
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 384($t0)
	sw $t1, 392($t0)
	sw $t1, 512($t0)
	sw $t1, 516($t0)
	sw $t1, 520($t0)
	jr $ra


IsGameOver: #check if doodle fell
	lw $t0, 4($s1)
	bgt $t0, 31, gover
	j proceed
	jr $ra
	gover:
		j GameOver
	jr $ra

GameOver:
	jal DrawBackground
	jal DrawGG
	checkRestart: 
		addi $sp, $sp, -4
		sw $ra, 0($sp)
	
		lw $t3, 0xffff0000
		beq $t3, 1, restartInput
		restartInput:
			lw $t2, 0xffff0004
			beq $t2, 115, Spressed
			j checkRestart
			Spressed:
				li $t1, 13
				sw $t1, 0($s1)
				li $t1, 30
				sw $t1, 4($s1)
				sw $s0, 8($s1)
				li $t1, 0
				sw $t1, 12($s1)
				sub $s4, $s4, $s4
				j main
		j CRend
		CRend:
		j checkRestart

#Checks keyboard input to move left or right (j or k)
CheckMove: 
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t3, 0xffff0000
	beq $t3, 1, input
	j CMend
	
	input: 
		lw $t1, 0xffff0004
		beq $t1, 0x6a, moveLeft
		beq $t1, 0x6b, moveRight
		j CMend
	moveLeft:
		lw $t0,8($s1)
		addi $t2, $t0, -4
		sw $t2, 8($s1)
		j CMend
	moveRight:
		lw $t0,8($s1)
		addi $t2, $t0, 4
		sw $t2, 8($s1)
		j CMend
	CMend:
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	jr $t1

VerticalMove:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t4, 0($s1) #can go upto 10pixel #4
	lw $s5, 4($s1) #ycoordinate
	lw $s6, 8($s1) 
	lw $s7, 12($s1)
	
	beqz $s7, MoveUp
	MoveDown:
		addi $t4, $t4, 1
		sw $t4, 0($s1)
		addi $s5, $s5, 1
		sw $s5, 4($s1)
		addi $s6, $s6, 128
		sw $s6, 8($s1)
		#beq $s7, $t4, sub1
		
		j MoveEnd
	MoveUp:
		addi $t4, $t4,-1
		sw $t4, 0($s1)
		addi $s5, $s5, -1
		sw $s5, 4($s1)
		addi $s6, $s6, -128
		sw $s6, 8($s1)
		lw $t1, 0($s1)
		beq $s7, $t4, add1
		j MoveEnd
	add1:
		addi $s7, $s7, 13
		sw $s7, 12($s1)
		j MoveEnd
	sub1:
		addi $s7, $s7, -13
		sw $s7, 12($s1)
		j MoveEnd
	MoveEnd:
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4	
		
	jr $ra
	
	
MoveDoodle:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal DrawDoodle
	
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	jr $t1
EraseDoodle: 
	lw $t9, backgroundColor
	sw $t9, 0($t0)
	jr $ra	
DrawDoodle:
	lw $t9, doodleColor
	lw $t2, 8($s1)
	sw $t9, 0($t2)
	jr $ra	
	
DrawBackground: #Create Background
	lw $t1, backgroundColor	# $t1 store the background Color for game.
	li $t4, 0
	lw $t5, screenSize
	lw $t0, displayAddress
	dbwhile:
		sw $t1, 0($t0) #color the first pixel
		add $t0, $t0, 4 #move to next pixel
		addi $t4, $t4, 1 #increment the number of colored pixel
		bge $t4, $t5 DBend
		j dbwhile
	DBend:
	jr $ra
	
InitLocation:
	add $t0, $zero, $zero
	addi $t1, $zero, 16
	la $t8, platformPos
	li $t2, 4 #for multiplication
	li $t6, 3 #count
	initLocationWhile:
		li $v0, 42
		li $a1, 24 
		syscall #Generate random nubmer
		add $t4, $t8, $t0
		lw $t4, 0($t4)
		
		mult $a0, $t2 #rand * 4
		mflo $t3
		add $t3, $t3, $t4
		add $t3, $t3, $s0 #location randomly generated
		
		#Add to new platform array
		mult $t6, $t2
		mflo $t7 #id
		add $t7, $t7, $s2
		sw $t3, 0($t7)
		
		#Add to old platform array
		add $t7, $t6, 4 
		mult $t7, $t2
		mflo $t7
		add $t7, $t7, $s2
		sw $t3, 0($t7)
		
		
		addi $t0, $t0, 4
		addi $t6, $t6, -1
		bne $t0, $t1, initLocationWhile
	loopEnd:
	jr $ra

InitDoodlePosition:
	li $t0, 4 #for multiplication
	li $t1, 4 #count
	mult $t1, $t0
	mflo $t2
	add $t2, $t2, $s2
	lw $t3, 0($t2)
	
	addi $t3, $t3, -120 #initialize doodle position right above the 4th platform
	
	sw $t3, 8($s1)
	jr $ra
	
DrawPlatform:
	li $t6, 3 #counter #draw platform 
	li $t2, 4 #multiplier
	
	
	drawplatformWhile:
		mult $t6,$t2
		mflo $t4
		add $t4, $t4, $s2 #index of platform array
		
		lw $t7, 8($s1) #call back the current position of doodle
		lw $t4, 0($t4)
		lw $t5, platformColor
		#Width 9
		sw $t5, 0($t4)
		sw $t5, 4($t4)
		sw $t5, 8($t4)
		sw $t5, 12($t4)
		sw $t5, 16($t4)
		sw $t5, 20($t4)
		sw $t5, 24($t4)
		sw $t5, 28($t4)
		
		sub $t7, $t4, $t7
		#abs $t7, $t7 #absolute 104~128
		
		addi $t8, $zero, 100
		addi $t9, $zero, 128
		
		ble $t8, $t7, check128 #greater than 100 go to check128
		j dontBounce #don't bounce
		check128:
			ble $t7, $t9, bounceUp #Bounced?
			j dontBounce #didnt bounce
		bounceUp: #bounce
			li $t8, 13
			sw $t8, 0($s1)
			add $t8, $zero, $zero
			sw $t8, 12($s1)
			li $t8, 1 #when doodle moves up 1 platform scroll the screen
			beq $t8, $t6, ScrollScreen
		dontBounce:
		
		beqz $t6, dpEnd
		addi $t6, $t6, -1
		j drawplatformWhile
	dpEnd:
	jr $ra

ScrollScreen:
	li $t8, 10
	sw $t8, 0($s1)
	lw $t1, 4($s1) #ycoord
	lw $t2, 8($s1) #location
	lw $t9, backgroundColor
	sw $t9, 0($t2)
	addi $t1,$t1, 8
	sw $t1, 4($s1)
	addi $t2, $t2,1024
	sw $t2, 8($s1) #Move doodle to lowest platform
	li $t1, 0
	add $t2, $t1, $s2
	lw $t3, 0($t2) #index 1
	sw $t9, 0($t3)
	sw $t9, 4($t3)
	sw $t9, 8($t3)
	sw $t9, 12($t3)
	sw $t9, 16($t3)
	sw $t9, 20($t3)
	sw $t9, 24($t3)
	sw $t9, 28($t3)
	
	#1->0
	li $t1, 4
	add $t2, $t1, $s2
	lw $t3, 0($t2) #index 1
	sw $t9, 0($t3)
	sw $t9, 4($t3)
	sw $t9, 8($t3)
	sw $t9, 12($t3)
	sw $t9, 16($t3)
	sw $t9, 20($t3)
	sw $t9, 24($t3)
	sw $t9, 28($t3)
	addi $t3, $t3, 1024
	sw $t3, -4($t2)
	#2->1
	li $t1, 8
	add $t2, $t1, $s2
	lw $t3, 0($t2) #index 1
	sw $t9, 0($t3)
	sw $t9, 4($t3)
	sw $t9, 8($t3)
	sw $t9, 12($t3)
	sw $t9, 16($t3)
	sw $t9, 20($t3)
	sw $t9, 24($t3)
	sw $t9, 28($t3)
	addi $t3, $t3, 1024
	sw $t3, -4($t2)
	#3->2
	li $t1, 12
	add $t2, $t1, $s2
	lw $t3, 0($t2) #index 1
	sw $t9, 0($t3)
	sw $t9, 4($t3)
	sw $t9, 8($t3)
	sw $t9, 12($t3)
	sw $t9, 16($t3)
	sw $t9, 20($t3)
	sw $t9, 24($t3)
	sw $t9, 28($t3)
	addi $t3, $t3, 1024
	sw $t3, -4($t2)
	
	#update the score
	addi $s4, $s4, 1
	
	
	
	#Generate random nubmer
	li $v0, 42
	li $a1, 24 
	syscall #Generate random nubmer
	li $t2, 4
	
	mult $a0, $t2 #rand * 4
	mflo $t3
	addi $t3, $t3, 896
	add $t3, $t3, $s0 #location randomly generated
	
	
	
	add $t1, $t1, $s2
	sw $t3, 0($t1)
	j dpEnd
	
DrawScore:
	lw $t1, ggColor
	#add $s4, $s4, $zero
	move $t5, $s4
	li $v0, 4
	la $a0, qc
	syscall
	
	li $v0, 1
	move $a0, $t5
	syscall
	li $v0, 4
	la $a0, newline2
	syscall
	
	
	li $t6, 2 #counter 
	li $t2, 100 #multiplier
	li $t3, 16 #for position
	li $t8, 0
	drawScoreWhile:
		div $t5, $t2
		mflo $t4 #quotient
		mfhi $t5 #remainder
		
	
		mult $t3, $t8
		mflo $t9 #pos
		add $t9, $s0, $t9
		
		beq $t4, 0, zero
		beq $t4, 1, one
		beq $t4, 2, two
		beq $t4, 3, three
		beq $t4, 4, four
		beq $t4, 5, five
		beq $t4, 6, six
		beq $t4, 7, seven
		beq $t4, 8, eight
		beq $t4, 9, nine
		drawEnd:
		beq $t6, 0, dsEnd
		li $t7, 10
		div $t2, $t7
		mflo $t2
		addi $t6, $t6, -1
		addi $t8, $t8, 1
		j drawScoreWhile
	zero:
		sw $t1, 0($t9)
		sw $t1, 4($t9)
		sw $t1, 8($t9)
		sw $t1, 128($t9)
		sw $t1, 136($t9)
		sw $t1, 256($t9)
		sw $t1, 264($t9)
		sw $t1, 384($t9)
		sw $t1, 392($t9)
		sw $t1, 512($t9)
		sw $t1, 516($t9)
		sw $t1, 520($t9)
		j drawEnd	
	one: 
		sw $t1, 8($t9)
		sw $t1, 136($t9)
		sw $t1, 264($t9)
		sw $t1, 392($t9)
		sw $t1, 520($t9)
		j drawEnd
	two: 
		sw $t1, 0($t9)
		sw $t1, 4($t9)
		sw $t1, 8($t9)
		sw $t1, 136($t9)
		sw $t1, 256($t9)
		sw $t1, 260($t9)
		sw $t1, 264($t9)
		sw $t1, 384($t9)
		sw $t1, 512($t9)
		sw $t1, 516($t9)
		sw $t1, 520($t9)
		j drawEnd
	three:
		sw $t1, 0($t9)
		sw $t1, 4($t9)
		sw $t1, 8($t9)
		sw $t1, 136($t9)
		sw $t1, 256($t9)
		sw $t1, 260($t9)
		sw $t1, 264($t9)
		sw $t1, 392($t9)
		sw $t1, 512($t9)
		sw $t1, 516($t9)
		sw $t1, 520($t9)
		j drawEnd
	four: 
		sw $t1, 0($t9)
		sw $t1, 8($t9)
		sw $t1, 128($t9)
		sw $t1, 136($t9)
		sw $t1, 256($t9)
		sw $t1, 260($t9)
		sw $t1, 264($t9)
		sw $t1, 392($t9)
		sw $t1, 520($t9)
		j drawEnd
	five: 
		sw $t1, 0($t9)
		sw $t1, 4($t9)
		sw $t1, 8($t9)
		sw $t1, 128($t9)
		sw $t1, 256($t9)
		sw $t1, 260($t9)
		sw $t1, 264($t9)
		sw $t1, 392($t9)
		sw $t1, 512($t9)
		sw $t1, 516($t9)
		sw $t1, 520($t9)
		j drawEnd
	six: 
		sw $t1, 0($t9)
		sw $t1, 4($t9)
		sw $t1, 8($t9)
		sw $t1, 128($t9)
		sw $t1, 256($t9)
		sw $t1, 260($t9)
		sw $t1, 264($t9)
		sw $t1, 384($t9)
		sw $t1, 392($t9)
		sw $t1, 512($t9)
		sw $t1, 516($t9)
		sw $t1, 520($t9)
		j drawEnd
	seven: 
		sw $t1, 0($t9)
		sw $t1, 4($t9)
		sw $t1, 8($t9)
		sw $t1, 128($t9)
		sw $t1, 136($t9)
		sw $t1, 264($t9)
		sw $t1, 392($t9)
		sw $t1, 520($t9)	
		j drawEnd
	eight: 
		sw $t1, 0($t9)
		sw $t1, 4($t9)
		sw $t1, 8($t9)
		sw $t1, 128($t9)
		sw $t1, 136($t9)
		sw $t1, 256($t9)
		sw $t1, 260($t9)
		sw $t1, 264($t9)
		sw $t1, 384($t9)
		sw $t1, 392($t9)
		sw $t1, 512($t9)
		sw $t1, 516($t9)
		sw $t1, 520($t9)	
		j drawEnd
	nine: 
		sw $t1, 0($t9)
		sw $t1, 4($t9)
		sw $t1, 8($t9)
		sw $t1, 128($t9)
		sw $t1, 136($t9)
		sw $t1, 256($t9)
		sw $t1, 260($t9)
		sw $t1, 264($t9)
		sw $t1, 392($t9)
		sw $t1, 512($t9)
		sw $t1, 516($t9)
		sw $t1, 520($t9)	
		j drawEnd
	dsEnd:
		
    	jr $ra 
	


	
	

DrawInit:
	lw $t1, ggColor	# $t1 store the background Color for game.
	#D
	lw $t0, displayAddress		
	addi $t0, $t0, 520
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 12($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 12($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 12($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 12($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	#O
	lw $t0, displayAddress		
	addi $t0, $t0, 540
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	#O
	lw $t0, displayAddress		
	addi $t0, $t0, 556
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	#D
	lw $t0, displayAddress		
	addi $t0, $t0, 572
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 12($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 12($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 12($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 12($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	#L
	lw $t0, displayAddress
	addi $t0, $t0, 592
	sw $t1, 0($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	#E
	lw $t0, displayAddress
	addi $t0, $t0, 608
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	#J
	lw $t0, displayAddress		
	addi $t0, $t0, 1440
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	addi $t0, $t0, 128
	sw $t1, 8($t0)
	addi $t0, $t0, 128
	sw $t1, 8($t0)
	addi $t0, $t0, 128
	sw $t1, 8($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	#U
	lw $t0, displayAddress		
	addi $t0, $t0, 1460
	sw $t1, 0($t0)
	sw $t1, 12($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 12($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 12($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 12($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 12($t0)
	addi $t0, $t0, 128
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	#M
	lw $t0, displayAddress		
	addi $t0, $t0, 1480
	sw $t1, 0($t0)
	sw $t1, 20($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 16($t0)
	sw $t1, 20($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 20($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 20($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 20($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 20($t0)
	
	#P
	lw $t0, displayAddress		
	addi $t0, $t0, 1508
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 12($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	#P
	lw $t0, displayAddress		
	addi $t0, $t0, 2824
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 12($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	#r
	lw $t0, displayAddress		
	addi $t0, $t0, 2844
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	#e
	lw $t0, displayAddress		
	addi $t0, $t0, 2860
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	#s
	lw $t0, displayAddress		
	addi $t0, $t0, 2876
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128
	sw $t1, 8($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	#s
	lw $t0, displayAddress		
	addi $t0, $t0, 2892
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128
	sw $t1, 8($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	#S
	lw $t0, displayAddress		
	addi $t0, $t0, 2916
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	addi $t0, $t0, 128
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, 128
	sw $t1, 12($t0)
	addi $t0, $t0, 128
	sw $t1, 12($t0)
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	
	
	jr $ra
						
												
																								
DrawGG: 
	lw $t1, ggColor	# $t1 store the background Color for game.
	lw $t0, displayAddress
	
	addi $t0, $t0, 1300
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 20($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 128($t0)
	sw $t1, 256($t0)
	sw $t1, 384($t0)
	sw $t1, 512($t0)
	sw $t1, 528($t0)
	sw $t1, 532($t0)
	sw $t1, 536($t0)
	sw $t1, 540($t0)
	sw $t1, 640($t0)
	sw $t1, 668($t0)
	sw $t1, 768($t0)
	sw $t1, 796($t0)
	sw $t1, 896($t0)
	sw $t1, 924($t0)
	sw $t1, 1024($t0)
	
	
	addi $t0, $t0, 1024
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 20($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	lw $t0, displayAddress
	
	addi $t0, $t0, 1340
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 20($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	sw $t1, 128($t0)
	sw $t1, 256($t0)
	sw $t1, 384($t0)
	sw $t1, 512($t0)
	sw $t1, 528($t0)
	sw $t1, 532($t0)
	sw $t1, 536($t0)
	sw $t1, 540($t0)
	sw $t1, 640($t0)
	sw $t1, 668($t0)
	sw $t1, 768($t0)
	sw $t1, 796($t0)
	sw $t1, 896($t0)
	sw $t1, 924($t0)
	sw $t1, 1024($t0)
	
	
	addi $t0, $t0, 1024
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 20($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	lw $t0, displayAddress
	
	addi $t0, $t0, 1384
	sw $t1, 0($t0)
	sw $t1, 128($t0)
	sw $t1, 256($t0)
	sw $t1, 384($t0)
	sw $t1, 512($t0)
	sw $t1, 640($t0)
	sw $t1, 768($t0)
	sw $t1, 896($t0)
	sw $t1, 1152($t0)
	
	
	jr $ra
	
		
Exit:
	li $v0, 10 # terminate the program gracefully
	syscall
