# sac295
# Stephen Cheney

.include "convenience.asm"
.include "game.asm"


#	Defines the number of frames per second: 16ms -> 60fps
.eqv	GAME_TICK_MS		16
.data
# don't get rid of these, they're used by wait_for_next_frame.
last_frame_time:  .word 0
frame_counter:    .word 0


#Coordinates
player_init_x: .word 31 # Start the player at x = 32
player_init_y: .word 50 # Start the player at t = 50

#Strings




.text
# --------------------------------------------------------------------------------------------------

# Print everything to the console as well as displaying it

.globl main
main:
	print_string str_begin_press
	print_string newline
	print_string str_begin_key
	print_string newline
	print_string str_begin_to_start
	print_string newline
	
_loop_begin:
	# set up anything you need to here,
	# and wait for the user to press a key to start.
	jal	func_begin
	jal	handle_input

	
	#Draws initial player sprite
	lw	a0, player_init_x
	lw	a1, player_init_y
	la	a2, player_image # pointer to the image
	jal	display_blit_5x5
	
	

	#Checks if any key is pressed to continue

	lw 	s1, action_pressed
	or	s0, s1, s0
	lw	s1, up_pressed
	or	s0, s1, s0
	lw	s1, down_pressed
	or	s0, s1, s0
	lw	s1, left_pressed
	or	s0, s1, s0
	lw	s1, right_pressed
	or	s0, s1, s0
	
	jal	display_update
	bnez 	s0, _main_loop
	j _loop_begin

_main_loop:
	# check for input, this function sets the following variables (check display.asm):
	#	left_pressed
	#	right_pressed
	#	up_pressed
	#	down_pressed
	#	action_pressed
	jal     handle_input
	# update everything, then draw everything
	
	lw 	v0, action_pressed
	beq 	v0, 0, _no_shot
	jal shoot
	_no_shot:
	lw 	s0, up_pressed
	beq 	s0, 1, player_up	
	lw 	s0, down_pressed
	beq 	s0, 1, player_down
	lw 	s0, left_pressed
	beq 	s0, 1, player_left
	lw 	s0, right_pressed
	beq 	s0, 1, player_right
	j _main_move_cont


	
	#Movement of player sprite
	player_up:
	lw s0, player_y
	beq s0, 3, _main_move_cont #collision detection
	subi s0, s0, 1
	sw s0, player_y
	j _main_move_cont
	
	player_down:
	lw s0, player_y
	beq s0, 50, _main_move_cont #collision detection
	addi s0, s0, 1
	sw s0, player_y
	j _main_move_cont
		
	player_left:
	lw s0, player_x
	beqz s0, _main_move_cont #collision detection
	subi s0, s0, 1
	sw s0, player_x
	j _main_move_cont
	
	player_right:
	lw s0, player_x
	beq s0, 59, _main_move_cont #collision detection
	addi s0, s0, 1
	sw s0, player_x
	j _main_move_cont
	
	
	
_main_move_cont:

	jal draw_lives
	jal draw_score
	jal draw_ammo
	jal draw_player
	jal spawn_enemy
	jal draw_all_enemies
	jal update_enemies
	jal missle_update
	jal collision
	
	
	jal	display_update_and_clear
	
	push s0
	push s1
	#if lives = 0, game over
	lw s0, lives
	ble s0, 0, _main_game_over
	#if ammo = 0, game over
	lw s1, ammo
	ble s1, 0, _main_game_over
	
	
	## This function will block waiting for the next frame!
	jal	wait_for_next_frame
	b	_main_loop

_main_game_over:
	jal	display_update_and_clear
	jal game_over
	jal	display_update
	exit



# --------------------------------------------------------------------------------------------------
# call once per main loop to keep the game running at 60FPS.
# if your code is too slow (longer than 16ms per frame), the framerate will drop.
# otherwise, this will account for different lengths of processing per frame.

wait_for_next_frame:
	enter	s0
	lw	s0, last_frame_time
_wait_next_frame_loop:
	# while (sys_time() - last_frame_time) < GAME_TICK_MS {}
	li	v0, 30
	syscall # why does this return a value in a0 instead of v0????????????
	sub	t1, a0, s0
	bltu	t1, GAME_TICK_MS, _wait_next_frame_loop

	# save the time
	sw	a0, last_frame_time

	# frame_counter++
	lw	t0, frame_counter
	inc	t0
	sw	t0, frame_counter
	leave	s0

# --------------------------------------------------------------------------------------------------
