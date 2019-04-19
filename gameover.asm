# sac295
# Stephen Cheney
#Enemies file - houses the info and functions for the enemy objects
.include "convenience.asm"

#Exposed functions
.globl game_over
#Exposed variables


.data
	
	str_game: .asciiz "Game"
	str_over: .asciiz "Over!"
	str_score: .asciiz "Score: "

.text

game_over:
	enter
	
	print_string str_game
	print_string newline
	print_string str_over
	print_string newline
	print_string str_score
	lw v0, score
	print_int v0
	#	a0 = top-left corner x
	#	a1 = top-left corner y
	#	a2 = width
	#	a3 = height
	#	v1 = color (use one of the constants above)
	li a0, 0
	li a1, 0
	li a2, 64
	li a3, 64
	li v1, 0
	jal display_fill_rect
	
	#a0 = top-left x
	#a1 = top-left y
	#a2 = pointer to string to print
	li a0, 18
	li a1, 10
	la a2, str_game
	jal display_draw_text
	
	li a0, 17
	li a1, 17
	la a2, str_over
	jal display_draw_text

	li a0, 2
	li a1, 30
	la a2, str_score
	jal display_draw_text
	
	li a0, 37
	li a1, 30
	lw a2, score
	jal display_draw_int
	
	leave
