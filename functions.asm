# sac295
# Stephen Cheney
# Functions file - houses variables and functions to control the game
.include "convenience.asm"

#Exposed functions
.globl func_begin
.globl draw_player
.globl draw_lives
.globl draw_score
.globl draw_ammo

#Exposed Vars
.globl player_image
.globl player_x
.globl player_y
.globl score
.globl lives
.globl ammo
.globl str_begin_press
.globl str_begin_key
.globl str_begin_to_start
.globl newline

.data
#Strings
str_begin_press: .asciiz "Press"
str_begin_key: .asciiz "Any Key"
str_begin_to_start: .asciiz "to start"
newline: .asciiz "\n"

#Coordinates
player_x: .word 31 #player x coord initiated to 31
player_y: .word 50 #player y coord initiated to 50

#Scores/Lives
score: .word 0000
lives: .word 3
ammo: .word 99


#Sptites
player_image: .byte #The player's ship
	
	0  0  7  0  0
	0  7  4  7  0
	7  4  4  4  7
	0  7  5  7  0
	7  1  2  1  7
	
heart: .byte #Heart for lives
	
	0  1  0  1  0
	1  1  1  1  1
	1  1  1  1  1
	0  1  1  1  0
	0  0  1  0  0	

coin: .byte #Coin to demonstrate score
	
	0  0  3  0  0
	0  3  0  3  0
	3  0  3  0  3
	0  3  0  3  0
	0  0  3  0  0	
	
bullet: .byte #Coin to demonstrate score	
	0  0  0  0  0
	0  2  2  2  0
	0  2  2  2  0
	0  2  2  2  0
	0  0  0  0  0	

#	0  0  0  0  0
#	0  0  0  0  0
#	0  0  0  0  0
#	0  0  0  0  0
#	0  0  0  0  0		
.text
#display_begin() displays "Press Space to Start"
func_begin:
	enter a0, a1, a2
	#a0 = top-left x
	#a1 = top-left y
	#a2 = pointer to string to print
	li a0, 17
	li a1, 10
	la a2, str_begin_press
	jal display_draw_text
	
	
	li a0, 11
	li a1, 17
	la a2, str_begin_key
	jal display_draw_text
	
	li a0, 8
	li a1, 24
	la a2, str_begin_to_start
	jal display_draw_text
	
	leave a0, a1, a2

#Draws our player sprite	
draw_player:
	enter a0, a1, a2
	lw	a0, player_x
	lw	a1, player_y
	la	a2, player_image # pointer to the image
	jal	display_blit_5x5

	leave a0, a1, a2

#Draws the lives we have
draw_lives:
	enter a0, a1, a2
	#Draw lives counter
	#	a0 = top-left x,
	#	a1 = top-left y
	#	a2 = integer to display (can be negative)
	li a0, 9
	li a1, 57
	lw a2, lives
	jal display_draw_int
	#Draw heart
	li a0, 2
	li a1, 57
	la a2, heart # pointer to the image
	jal display_blit_5x5
	leave a0, a1, a2

#Draws the ammo we have
draw_ammo:
	enter a0, a1, a2
	#Draw ammo counter
	#	a0 = top-left x,
	#	a1 = top-left y
	#	a2 = integer to display (can be negative)
	li a0, 20
	li a1, 57
	lw a2, ammo
	jal display_draw_int
	#Draw Bullet
	li a0, 15
	li a1, 57
	la a2, bullet # pointer to the image
	jal display_blit_5x5
	leave a0, a1, a2

#Draws the current score, starting at 0
draw_score:
	enter a0, a1, a2
	#	a0 = top-left x,
	#	a1 = top-left y
	#	a2 = integer to display (can be negative)
	li a0, 40
	li a1, 57
	lw a2, score
	jal display_draw_int
	#Draw coin
	li a0, 33
	li a1, 57
	la a2, coin # pointer to the image
	jal display_blit_5x5

	leave a0, a1, a2
