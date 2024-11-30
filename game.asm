.data
    # Game state arrays
    revealed:       .word 0:16        # Track revealed cards
    matched:        .word 0:16        # Track matched cards
    moves:          .word 0           # Number of moves
    first_pick:     .word -1          # First card picked
    second_pick:    .word -1          # Second card picked
    
    # Board display strings
    board_top:      .asciiz "\n    +-------+-------+-------+-------+\n"
    board_middle:   .asciiz "    +-------+-------+-------+-------+\n"
    board_bottom:   .asciiz "    +-------+-------+-------+-------+\n"
    board_row:      .asciiz "    |"
    board_hidden:   .asciiz "   *   "
    board_cell:     .asciiz "   %d   "
    newline:        .asciiz "\n"
    space:          .asciiz " "
    multiply_symbol:.asciiz "x"
    board_separator:.asciiz "+-------+-------+-------+-------+\n"
    
    # Game messages
    title1:         .asciiz "\n    +---------------------------------+\n"
    title2:         .asciiz "    |   Multiplication Match Game!     |\n"
    title3:         .asciiz "    +---------------------------------+\n\n"
    
    pick_msg:       .asciiz "\nEnter position (1-16): "
    match_msg:      .asciiz "\nMatch found! *\n"
    no_match_msg:   .asciiz "\nNo match. Try again!\n"
    moves_msg:      .asciiz "\nMoves made: "
    win_msg:        .asciiz "\nCongratulations! You've won!\n"
    invalid_input:  .asciiz "\nInvalid input! Please enter a number between 1 and 16.\n"
    already_picked: .asciiz "\nThat card is already revealed! Try another one.\n"
    
    # Sound settings
    match_sound:    .word 60  # Middle C note
    error_sound:    .word 45  # Lower note
    win_sound:      .word 72  # Higher note

.text
# Global variables
.globl revealed
.globl matched
.globl moves
.globl first_pick
.globl second_pick
.globl board_top
.globl board_middle
.globl board_bottom
.globl board_row
.globl board_hidden
.globl board_cell

# Global functions
.globl init_game
.globl display_board
.globl get_pick
.globl check_match
.globl check_win
.globl display_title
.globl play_sound

# Initialize the game
init_game:
    # Save return address
    sw $ra, ($sp)
    addi $sp, $sp, -4
    
    # Initialize revealed and matched arrays
    li $t0, 0    # Array index
init_arrays:
    mul $t1, $t0, 4
    sw $zero, revealed($t1)
    sw $zero, matched($t1)
    addi $t0, $t0, 1
    blt $t0, 16, init_arrays
    
    # Initialize moves counter
    sw $zero, moves
    
    # Display title
    jal display_title
    
game_loop:
    # Display board
    jal display_board
    
    # Get first pick
    jal get_pick
    sw $v0, first_pick
    
    # Display board with first pick
    jal display_board
    
    # Get second pick
    jal get_pick
    sw $v0, second_pick
    
    # Update moves counter
    lw $t0, moves
    addi $t0, $t0, 1
    sw $t0, moves
    
    # Check if match
    jal check_match
    
    # Check if game is won
    jal check_win
    beq $v0, 1, game_won
    
    j game_loop

game_won:
    # Display final board and win message
    jal display_board
    li $v0, 4
    la $a0, win_msg
    syscall
    
    # Play win sound
    la $a0, win_sound
    li $a1, 1000       # 1 second duration
    jal play_sound
    
    # Return
    lw $ra, 4($sp)
    addi $sp, $sp, 4
    jr $ra

# Display the game board
display_board:
    # Save return address and $s registers
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s0, 0($sp)
    
    # Print newline for spacing
    li $v0, 11
    li $a0, '\n'
    syscall
    
    li $s0, 0          # Board index counter
    
board_loop:
    # Check if we need a newline (every 4 cells)
    li $t0, 4
    div $s0, $t0
    mfhi $t0           # Get remainder
    bnez $t0, skip_newline
    
    # Print newline and board separator
    li $v0, 11
    li $a0, '\n'
    syscall
    
    # Print board separator
    li $v0, 4
    la $a0, board_separator
    syscall
    
skip_newline:
    # Print cell separator
    li $v0, 11
    li $a0, '|'
    syscall
    li $a0, ' '
    syscall
    
    # Load card info
    sll $t0, $s0, 2    # Multiply index by 4 for word alignment
    
    # Load board value
    la $t1, board
    add $t1, $t1, $t0
    lw $a0, ($t1)      # First argument: value
    
    # Load is_equation flag
    la $t1, is_equation
    add $t1, $t1, $t0
    lw $a1, ($t1)      # Second argument: is_equation
    
    # Load revealed flag
    la $t1, revealed
    add $t1, $t1, $t0
    lw $a2, ($t1)      # Third argument: is_revealed
    
    # Call display_cell
    jal display_cell
    
    # Print space after cell
    li $v0, 11
    li $a0, ' '
    syscall
    
    # Check if we need to print end-of-row vertical bar
    li $t0, 4
    div $s0, $t0
    mfhi $t0           # Get remainder
    li $t1, 3          # Check if it's the last cell in row
    beq $t0, $t1, print_end_bar
    j continue_loop
    
print_end_bar:
    li $v0, 11
    li $a0, '|'
    syscall
    
continue_loop:
    # Increment counter and continue if not done
    addi $s0, $s0, 1
    li $t0, 16
    blt $s0, $t0, board_loop
    
    # Print final newline and board separator
    li $v0, 11
    li $a0, '\n'
    syscall
    li $v0, 4
    la $a0, board_separator
    syscall
    li $v0, 11
    li $a0, '\n'
    syscall
    
    # Restore registers and return
    lw $s0, 0($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 8
    jr $ra

# Custom delay loop (approximately 0.5 seconds)
delay_loop:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Simple counter-based delay
    li $t0, 0           # Counter
delay_count:
    addi $t0, $t0, 1
    li $t1, 2000000     # Reduced delay amount
    blt $t0, $t1, delay_count
    
    # Restore and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Debug function to print revealed array state
print_revealed_debug:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    li $t0, 0           # Counter
debug_loop:
    mul $t1, $t0, 4     # Calculate offset
    lw $a0, revealed($t1)
    li $v0, 1           # Print integer
    syscall
    
    la $a0, space       # Print space
    li $v0, 4
    syscall
    
    addi $t0, $t0, 1
    blt $t0, 16, debug_loop
    
    la $a0, newline     # Print newline
    li $v0, 4
    syscall
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Get player's card pick with input validation
get_pick:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)

input_loop:
    # Print prompt
    li $v0, 4
    la $a0, pick_msg
    syscall
    
    # Get input
    li $v0, 5        # Read integer
    syscall
    
    # Check for syscall error (invalid input)
    blt $v0, 1, invalid_input_error   # If input < 1, invalid
    bgt $v0, 16, invalid_input_error  # If input > 16, invalid
    
    # Input is valid, convert to 0-based index
    addi $v0, $v0, -1
    move $t0, $v0
    
    # Check if card is already revealed or matched
    mul $t1, $t0, 4
    lw $t2, revealed($t1)
    lw $t3, matched($t1)
    or $t4, $t2, $t3
    bnez $t4, already_revealed_error
    
    # Valid input, mark as revealed
    li $t2, 1
    sw $t2, revealed($t1)
    
    # Return the validated pick
    move $v0, $t0
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

invalid_input_error:
    li $v0, 4
    la $a0, invalid_input
    syscall
    j input_loop

already_revealed_error:
    li $v0, 4
    la $a0, already_picked
    syscall
    j input_loop

# Check if picked cards match
check_match:
    # Save return address and $s registers
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s1, 4($sp)
    sw $s0, 0($sp)
    
    # Load picks
    lw $s0, first_pick     # First pick index
    lw $s1, second_pick    # Second pick index
    
    # Validate indices
    li $t0, 16            # Board size
    bgeu $s0, $t0, no_match  # If first pick >= 16, no match
    bgeu $s1, $t0, no_match  # If second pick >= 16, no match
    
    # Get board values and types
    sll $t0, $s0, 2       # Multiply by 4 for word alignment
    sll $t1, $s1, 2       # Multiply by 4 for word alignment
    
    # Load board values safely
    la $t2, board         # Load board base address
    add $t3, $t2, $t0     # Add offset for first pick
    add $t4, $t2, $t1     # Add offset for second pick
    lw $t5, ($t3)         # Load first card value
    lw $t6, ($t4)         # Load second card value
    
    # Load is_equation values safely
    la $t2, is_equation   # Load is_equation base address
    add $t3, $t2, $t0     # Add offset for first pick
    add $t4, $t2, $t1     # Add offset for second pick
    lw $t7, ($t3)         # Load first card type
    lw $t8, ($t4)         # Load second card type
    
    # Check if one is equation and other is answer
    beq $t7, $t8, no_match    # Both same type, no match
    
    # If first is equation, keep it first. Otherwise swap
    bnez $t7, check_equation
    # Swap values and continue
    move $t9, $t5
    move $t5, $t6
    move $t6, $t9
    
check_equation:
    # t5 now has equation (packed numbers), t6 has answer
    # Extract numbers from equation
    srl $t7, $t5, 16      # Get first number
    andi $t8, $t5, 0xFFFF # Get second number
    
    # Calculate product
    mul $t9, $t7, $t8
    
    # Compare with answer
    bne $t9, $t6, no_match
    
    # Cards match - mark both as matched
    li $t7, 1
    la $t2, matched       # Load matched base address
    add $t3, $t2, $t0     # Add offset for first pick
    add $t4, $t2, $t1     # Add offset for second pick
    sw $t7, ($t3)         # Mark first card as matched
    sw $t7, ($t4)         # Mark second card as matched
    
    la $t2, revealed      # Load revealed base address
    add $t3, $t2, $t0     # Add offset for first pick
    add $t4, $t2, $t1     # Add offset for second pick
    sw $t7, ($t3)         # Keep first card revealed
    sw $t7, ($t4)         # Keep second card revealed
    
    # Play match sound
    la $a0, match_sound
    li $a1, 500        # 500ms duration
    jal play_sound
    
    # Display match message
    li $v0, 4
    la $a0, match_msg
    syscall
    
    # Show updated board
    jal display_board
    
    li $v0, 1              # Return true
    j check_match_end

no_match:
    # Show mismatched cards briefly
    jal display_board
    
    # Delay to show cards
    jal delay_loop
    
    # Clear revealed status for both cards
    la $t2, revealed
    
    # Hide first card
    sll $t0, $s0, 2       # Calculate offset for first pick
    add $t3, $t2, $t0
    sw $zero, ($t3)       # Hide first card
    
    # Hide second card
    sll $t1, $s1, 2       # Calculate offset for second pick
    add $t4, $t2, $t1
    sw $zero, ($t4)       # Hide second card
    
    # Reset first and second picks
    sw $zero, first_pick
    sw $zero, second_pick
    
    # Play error sound
    la $a0, error_sound
    li $a1, 300        # 300ms duration
    jal play_sound
    
    # Display no match message
    li $v0, 4
    la $a0, no_match_msg
    syscall
    
    # Show updated board with both cards hidden
    jal display_board
    
    li $v0, 0              # Return false

check_match_end:
    # Update moves counter
    lw $t0, moves
    addi $t0, $t0, 1
    sw $t0, moves
    
    # Restore registers and return
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $ra, 8($sp)
    addi $sp, $sp, 12
    jr $ra

# Check if all pairs are matched
check_win:
    li $t0, 0    # Counter
    li $t1, 0    # Matched pairs counter
    
check_win_loop:
    mul $t2, $t0, 4
    lw $t3, matched($t2)
    add $t1, $t1, $t3
    
    addi $t0, $t0, 1
    blt $t0, 16, check_win_loop
    
    # Return 1 if all matched, 0 otherwise
    li $v0, 0
    beq $t1, 16, win_found
    jr $ra
    
win_found:
    li $v0, 1
    jr $ra

# Display title
display_title:
    li $v0, 4
    la $a0, title1
    syscall
    la $a0, title2
    syscall
    la $a0, title3
    syscall
    jr $ra

# Play a sound effect with specified parameters
play_sound:
    # Parameters:
    # $a0 = address of sound constant to play
    # $a1 = duration (ms)
    
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Load the actual sound value
    lw $t0, ($a0)        # Load the sound value from the address
    
    # Play sound using MIDI out
    li $v0, 31           # MIDI out syscall
    move $a0, $t0        # Sound pitch
    move $t1, $a1        # Save duration
    li $a1, 1000        # Duration in milliseconds
    li $a2, 1           # Instrument (1 = piano)
    li $a3, 100         # Volume (100 out of 127)
    syscall
    
    # Delay to let sound play
    li $v0, 32          # Sleep syscall
    move $a0, $t1       # Use original duration for sleep
    syscall
    
    # Restore and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Display a single cell value
display_cell:
    # Save return address and $s registers
    addi $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)
    sw $s2, 0($sp)
    
    move $s0, $a0    # Cell value
    move $s1, $a1    # Is equation flag
    move $s2, $a2    # Is revealed flag
    
    # If not revealed, print "*"
    beqz $s2, print_hidden
    
    # If equation, display as "NxM"
    beqz $s1, print_number
    
    # Extract numbers from packed value
    srl $t0, $s0, 16      # First number
    andi $t1, $s0, 0xFFFF # Second number
    
    # Print first number
    li $v0, 1
    move $a0, $t0
    syscall
    
    # Print "x"
    li $v0, 11
    li $a0, 'x'
    syscall
    
    # Print second number
    li $v0, 1
    move $a0, $t1
    syscall
    
    # Print padding spaces to align
    li $v0, 11
    li $a0, ' '
    syscall
    syscall
    j display_cell_end
    
print_number:
    # Print the number with padding
    li $v0, 1
    move $a0, $s0
    syscall
    
    # Add padding spaces based on number of digits
    move $t0, $s0
    li $t1, 0       # Counter for digits
    
count_digits:
    beqz $t0, print_spaces
    div $t0, $t0, 10
    addi $t1, $t1, 1
    j count_digits
    
print_spaces:
    # Calculate needed spaces (5 - digits)
    li $t0, 5       # Total cell width
    sub $t0, $t0, $t1
    
print_space_loop:
    beqz $t0, display_cell_end
    li $v0, 11
    li $a0, ' '
    syscall
    addi $t0, $t0, -1
    j print_space_loop
    
print_hidden:
    # Print "*" with consistent spacing
    li $v0, 11
    li $a0, '*'
    syscall
    
    # Print padding spaces
    li $v0, 11
    li $a0, ' '
    syscall
    syscall
    syscall
    syscall
    
display_cell_end:
    # Restore registers and return
    lw $s2, 0($sp)
    lw $s1, 4($sp)
    lw $s0, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16
    jr $ra
