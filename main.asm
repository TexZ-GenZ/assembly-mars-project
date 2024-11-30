.data
    welcome_msg:    .asciiz "\n=== Multiplication Match Game ===\n"
    menu_msg:       .asciiz "\n1. Start Game\n2. How to Play\n3. Exit\nEnter your choice: "
    how_to_play:    .asciiz "\nHow to Play:\n- Match multiplication problems with their answers\n- Enter numbers between 1-16 to select cards\n- Find all matching pairs to win!\n"
    invalid_msg:    .asciiz "\nInvalid choice. Please try again.\n"
    
    # Sound effects - make them global
    .globl match_sound
    .globl error_sound
    .globl win_sound
    match_sound:    .word 60    # Middle C (C4)
    error_sound:    .word 48    # C3 (lower C)
    win_sound:      .word 72    # C5 (higher C)

.text
.globl main

main:
    # Display welcome message
    li $v0, 4
    la $a0, welcome_msg
    syscall
    
menu_loop:
    # Display menu
    li $v0, 4
    la $a0, menu_msg
    syscall
    
    # Get user choice
    li $v0, 5
    syscall
    
    # Check for invalid input
    blt $v0, 1, invalid_choice    # If input < 1, invalid
    bgt $v0, 3, invalid_choice    # If input > 3, invalid
    
    move $t0, $v0
    
    # Menu selection
    beq $t0, 1, start_game
    beq $t0, 2, show_help
    beq $t0, 3, exit_game
    
invalid_choice:
    li $v0, 4
    la $a0, invalid_msg
    syscall
    j menu_loop

start_game:
    # Initialize board first
    jal init_board
    # Then initialize game state
    jal init_game
    j menu_loop

show_help:
    li $v0, 4
    la $a0, how_to_play
    syscall
    j menu_loop

exit_game:
    li $v0, 10
    syscall
