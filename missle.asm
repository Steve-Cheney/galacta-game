# sac295
# Stephen Cheney
#Missle file - houses the info and functions for the missle object
.include "convenience.asm"

#Exposed functions
.globl shoot
.globl missle_update

#Exposed variables
.globl active_missle
.globl missle_x
.globl missle_y

.data
active_missle: .word 0 #Flag to determine if missle is blown up or not. 0 is not shot, 1 is shot
missle_x: .word 0 #missle will init to 0
missle_y: .word 0 #missle will init to 
missle_speed: .word 2
str_ammo: .asciiz " Ammo Remaining"

.text

#Initilizes missle to be active if it is not alreadty.
shoot:
	enter
	lw v0, active_missle
	beq v0, 1, _shoot_end
	li v0, 1
	sw v0, active_missle
	lw t0, player_x
	lw t1, player_y
	add t0, t0, 2 #put missle in thetop middle of the ship sprite
	
	sw t0, missle_x
	sw t1, missle_y
	
	#Update the ammo count
	lw v0, ammo
	sub v0, v0, 1
	sw v0, ammo
	
	
	print_int v0
	print_string str_ammo
	print_string newline
	_shoot_end:
	leave

#Update the missle's position	
missle_update:
	enter
	lw v0, active_missle #If missle is not active, do nothing.
	beq v0, 0, _shoot_end
	
	#	a0 is x,
	#	a1 is y,
	#	a2 is the color
	lw a0, missle_x
	lw a1, missle_y
	lw a3, missle_speed
	sub a1, a1, a3
	li a2, 2
	beq a1, 0, _collision

	blt a1, 0, _clean_value #sometimes the missle y-coord will become negative, causing issues

	jal display_set_pixel
	sw a1, missle_y
	j _update_end
	
	_clean_value:
	li a1, 0
	jal display_set_pixel
	sw a1, missle_y

	#collision occurs with top of screen, missle explodes, no longer active
	_collision:
	li v0, 0
	sw v0, active_missle
	
	_update_end:
	leave
