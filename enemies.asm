# sac295
# Stephen Cheney
#Enemies file - houses the info and functions for the enemy objects
.include "convenience.asm"

#Exposed functions
.globl spawn_enemy
.globl draw_all_enemies
.globl update_enemies
.globl collision
#Exposed variables
.globl	enemy_x
.globl	enemy_y
.globl 	enemy
.globl enemy_total

.data

	enemy_x:	.word 0 0 0 0 0 #Each value corresponds to enemy i
	enemy_y:	.word 0 0 0 0 0 #Each value corresponds to enemy i
	active_enemy:	.word 0 0 0 0 0 #[Length] number of enemies
	ticker:		.word 0
	lastran:	.word 0
	
	enemy_total:	.word 5 #corresponds to total enemy (active_enemy length)
	str_set_check:	.asciiz "Setting enemy "
	str_draw_check:	.asciiz "Drawing enemy "
	str_lives_counter: .asciiz "Minus a life"
	str_score: .asciiz "Score: "
enemy: .byte #enemy sprite	
	6  6  6  6  6
	6  1  6  1  6
	6  6  6  6  6
	0  0  6  0  0
	0  6  6  6  0	


.text

#This method will spawn an enemy in a random location at the top of the screen if it was destroyed

spawn_enemy:
	enter s0 s1, s2, s3, s4
	push s5
	push s6
	push s7
	#for(int i = 0; i<enemy_total; i++){
	li s0, 0 #i = 0

	lw s1, enemy_total #i<enemy_total
	sub s1, s1, 1
	
	spawn_loop:
    	bgt s0, s1, spawn_exit
  	la s2, active_enemy #load array address
  	mul s3, s0, 4	#s4 = 4*i i
  	add s4, s2, s3 #address of active_enemy[i]
  	
  	lw s5, 0(s4) #s5 stores the value of active_enemy[i]
  	beq s5, 0, spawn_enemy_set
	j _spawn_check_end
	
	spawn_enemy_set: #set the location of the enemy
  		#print_string str_set_check
  		#print_int s0
  		#print_string newline
  		
  		li v0, 1
  		sw v0, 0(s4) #sets enemy of active_enemy[i] to active
  		
  		rand_gen:
  		#set a0 to a random int
  		li a1, 12  #Here you set $a1 to the max bound of 12
   		li v0, 42  #generates the random number.
    		syscall
    		mul a0, a0, 5 #multiply to get the enemies into columns
    		#check if last enemy spawned on that position
    		lw a1, lastran
    		beq a0, a1, rand_gen
    		
    		sw a0, lastran
		#set x and y of enemy[i]
		
		la s6, enemy_y #load array address
  		#sll s3, s0, 2 #s3 = 4*i  -- s3 is already set
  		add s7, s6, s3 #address of enemy_y[i]
  		li v0, 0 #set y value to 0 (top of screen)
  		sw v0, 0(s7)
  		
  		la t0, enemy_x #load array address
  		#sll s3, s0, 2 #s3 = 4*i  -- s3 is already set
  		add t1, t0, s3 #address of enemy_x[i]
  		sw a0, 0(t1)
  		  		   	   	  		   	   	  		   	   	  		   	   	
  	_spawn_check_end:
	
	
  	addi s0, s0, 1
   	j spawn_loop
	
	spawn_exit:
	pop s7
	pop s6
	pop s5
	leave s0, s1, s2, s3, s4

#loop through and draw all enemies based on their x and y coordinates within the arrays
draw_all_enemies:
	enter s0 s1, s2, s3, s4
	push s5
	push s6
	
	#for(int i = 0; i<enemy_total; i++){
	li s0, 0 #i = 0
	
	lw s1, enemy_total #i<enemy_total
	sub s1, s1, 1
	
	la s2, enemy_x #load array address
	la s3, enemy_y #load array address
	
	draw_loop:
    	bgt s0, s1, draw_loop_exit
    	mul s4, s0, 4	#s4 = 4*i 
	
  	add s5, s2, s4 #address of enemy_x[i]
  	add s6, s3, s4 #address of enemy_y[i]
  	
  	#print_string str_draw_check
  	#print_int s0
  	#print_string newline
  	#Draw Enemy
	lw a0, 0(s5)
	lw a1, 0(s6)
	la a2, enemy # pointer to the image
	jal display_blit_5x5
	
	
    	add s0, s0, 1
	j draw_loop
	
	draw_loop_exit:
	pop s6
	pop s5
	leave s0, s1, s2, s3, s4

#Update the enemy movement using a predetermined enemy speed; once the ticker hits 20, move the enemy and reset the ticker
update_enemies:
	enter s0 s1, s2, s3, s4
	push s5
	push s6
	push s7

	#check a ticker to see if 
	lw s0, ticker
	add s0, s0, 1
	sw s0, ticker
	
	bne s0, 10, update_loop_exit #second value here will determine speed of enemies
	
	lw s0, ticker
	li s0, 0
	sw s0, ticker
	
	#for(int i = 0; i<enemy_total; i++){
	li s0, 0 #i = 0
	
	lw s1, enemy_total #i<enemy_total
	sub s1, s1, 1
	
	la s2, enemy_y #load array address
	
	update_loop:
    	bgt s0, s1, update_loop_exit
    	mul s3, s0, 4	#s4 = 4*i 
	
  	add s4, s2, s3 #address of enemy_Y[i]

  	
  	lw s5, 0(s4) #value of enemy_y[i]
  	beq s5, 50, reached_bottom
  	add s5, s5, 1 #move the enemy down
	sw s5, 0(s4)
	j loop_func_end
	
	reached_bottom:
		la s6, active_enemy #load array address
  		mul s7, s0, 4	#s4 = 4*i i
  		add a0, s7, s6 #address of active_enemy[i]
  	
  		lw a1, 0(a0) #s5 stores the value of active_enemy[i]
		move a1, zero
		sw a1, 0(a0)
		
		#Minus one life
		push s0
		lw s0, lives
		sub s0, s0, 1
		sw s0, lives
		pop s0
		
		print_string str_lives_counter
		print_string newline
	loop_func_end:
    	add s0, s0, 1
	j update_loop
	
	update_loop_exit:

	pop s7
	pop s6
	pop s5
	leave s0, s1, s2, s3, s4

#This method will detect if a missle has hit an enemy, or if the player has run into an enemy		
collision:
	enter s0, s1, s2, s3, s4
	push s5
	push s6
	push s7
	
	#for(int i = 0; i<enemy_total; i++){
	li s0, 0 #i = 0
	
	lw s1, enemy_total #i<enemy_total
	sub s1, s1, 1
	
	la s2, enemy_x #load array address
	la s3, enemy_y #load array address
	
	collision_loop:
 
	
    	bgt s0, s1, collision_loop_exit
    	mul s4, s0, 4	#s4 = 4*i 
	
  	add s5, s2, s4 #address of enemy_x[i]
  	add s6, s3, s4 #address of enemy_y[i]
  	
  	push s2 #push s registers that are being used to calc box coords
  	push s3
  	push s5
  	push s6
  	
  	lw s2, 0(s6)	#s2 stores top of enemy-y coord
  	lw s3, 0(s5)	#s3 stores left most enemy x coord	
	
	lw s6, missle_y #s6 stores missle_y
	lw s7, missle_x #s7 stores missle_x

	#s0 stores i in for loop
	
	#s2 stores top of enemy-y coord
  	#s3 stores left most enemy x coord
  	#s4 stores missle_y
  	#s5 stores missle_x
  	lw s4, missle_y
  	lw s5, missle_x
	
	#if (rect1.x < rect2.x + rect2.width 
	#&& (rect1.x + rect1.width > rect2.x) 
	#&& (rect1.y < rect2.y + rect2.height) 
	#&& (rect1.y + rect1.height > rect2.y))
	#// collision detected!
	#player = rect 1
	#missle = rect 2
	
	m_part_a:
	move s7, zero
	add s7, s3, 5 #rect 2 x + rext 2 width
	blt s5, s7, m_part_b
	j end_missle_check
	
	m_part_b:
	move s7, zero
	add s7, s5, 1 #rect 1 x + rext 1 width
	bgt s7, s3, m_part_c
	j end_missle_check
	
	m_part_c:
	move s7, zero
	add s7, s2, 5 #rect 2 y + rext 2 height
	blt s4, s7, m_part_d
	j end_missle_check
	
	m_part_d:
	move s7, zero
	add s7, s4, 1 #rect 1 y + rext 1 height
	bgt s7, s2, check_pass_missle
	j end_missle_check
	
	check_pass_missle:
		push s2
		push s3
		push s5
		push s6
	#print_string str_collision
	
		#Enemy hit, set missle to no longer be active
		li s2, 0
		sw s2, active_missle 
		
		la s3, active_enemy
		mul s5, s0, 4
		add s6, s3, s5 #s6 is the active_enemy[i] address
		
		lw a1, 0(s6) #s5 stores the value of active_enemy[i]
		move a1, zero
		sw a1, 0(s6)
		
		lw s3, score
		add s3, s3, 10
		sw s3, score
		
		print_string str_score
		print_int s3
		print_string newline
	
		pop s6
		pop s5
		pop s3
		pop s2
	
	end_missle_check:

	
	check_player:
	#s0 stores i in for loop
	la s2, enemy_x #load array address
	la s3, enemy_y #load array address
	mul s4, s0, 4	#s4 = 4*i
  	add s5, s2, s4 #address of enemy_x[i]
  	add s6, s3, s4 #address of enemy_y[i]
  	
  	lw s5, 0(s5)
  	lw s6, 0(s6)
  	#s2 stores player_x
  	#s3 stores player_y
  	lw s2, player_x
  	lw s3, player_y
 	#s5 stores enemy_x
 	#s6 stores enemy_y
 	
	#if (rect1.x < rect2.x + rect2.width 
	#&& (rect1.x + rect1.width > rect2.x) 
	#&& (rect1.y < rect2.y + rect2.height) 
	#&& (rect1.y + rect1.height > rect2.y))
	#// collision detected!
	#player = rect 1
	#enemy = rect 2
	
	p_part_a:
	move s7, zero
	add s7, s5, 5 #rect 2 x + rext 2 width
	blt s2, s7, p_part_b
	j end_player_collision
	
	p_part_b:
	move s7, zero
	add s7, s2, 5 #rect 1 x + rext 1 width
	bgt s7, s5, p_part_c
	j end_player_collision
	
	p_part_c:
	move s7, zero
	add s7, s6, 5 #rect 2 y + rext 2 height
	blt s3, s7, p_part_d
	j end_player_collision
	
	p_part_d:
	move s7, zero
	add s7, s3, 5 #rect 1 y + rext 1 height
	bgt s7, s6, player_collision
	j end_player_collision
	
	player_collision:
	
	#set player to original location (31, 50)
	#s3 stores player_y
  	#s5 stores player_x
  	
  	li s3, 50
  	li s5, 31
  	
  	sw s3, player_y
  	sw s5, player_x
	
	#set enemy to be destroyed
	la s3, active_enemy
	mul s5, s0, 4
	add s6, s3, s5 #s6 is the active_enemy[i] address
		
	lw a1, 0(s6) #s5 stores the value of active_enemy[i]
	move a1, zero
	sw a1, 0(s6)
	
	#Minus a life
	lw a0, lives
	sub a0, a0, 1
	sw a0, lives
	print_string str_lives_counter
	print_string newline
	
	end_player_collision:
	#pop those pushed coords
	pop s6
	pop s5
	pop s3
	pop s2
	
    	add s0, s0, 1
	j collision_loop
	
	collision_loop_exit:
	pop s7
	pop s6
	pop s5
	leave s0, s1, s2, s3, s4
