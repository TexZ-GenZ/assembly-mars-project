.data
    board:          .word 0:16         # Game board array (4x4)
    multiply_symbol: .asciiz "x"
    space:          .asciiz " "
    newline:        .asciiz "\n"
    numbers:        .word 1, 2, 3, 4   # Numbers for multiplication problems
    is_equation:    .word 0:16         # 1 if position shows equation, 0 if answer
    debug_msg:      .asciiz "Board value at index "
    debug_msg2:     .asciiz ": "

.text
.globl board
.globl init_board_values
.globl shuffle_board
.globl init_board
.globl is_equation

# Initialize the board
init_board:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Call init_board_values to set up multiplication problems
    jal init_board_values
    
    # Call shuffle_board to randomize positions
    jal shuffle_board
    
    # Restore return address and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Initialize board with multiplication problems and their answers
init_board_values:
    # Save return address and $s registers
    addi $sp, $sp, -24
    sw $ra, 20($sp)
    sw $s4, 16($sp)
    sw $s3, 12($sp)
    sw $s2, 8($sp)
    sw $s1, 4($sp)
    sw $s0, 0($sp)
    
    # Initialize board index
    li $s0, 0    # board array index
    
    # Create exactly 8 pairs of equations and answers
    li $s1, 2    # first number (2-5)
    li $s2, 2    # second number (2-5)
    li $s4, 0    # pair counter (0-7)
    
create_pairs:
    # Calculate product
    mul $s3, $s1, $s2
    
    # Store equation first (2 positions)
    mul $t0, $s4, 2      # Each pair takes 2 positions
    mul $t1, $t0, 4      # Convert to byte offset
    
    # Pack equation (first number in upper 16 bits, second in lower)
    sll $t2, $s1, 16     # Shift first number to upper bits
    or $t2, $t2, $s2     # Combine with second number
    
    # Store equation and answer
    sw $t2, board($t1)        # Store equation
    li $t3, 1
    sw $t3, is_equation($t1)  # Mark as equation
    
    addi $t1, $t1, 4         # Next position
    sw $s3, board($t1)       # Store answer
    sw $zero, is_equation($t1) # Mark as answer
    
    # Update numbers for next pair
    addi $s2, $s2, 1     # Increment second number
    bgt $s2, 5, next_first_number
    j continue_pairs
    
next_first_number:
    li $s2, 2           # Reset second number
    addi $s1, $s1, 1    # Increment first number
    
continue_pairs:
    # Move to next pair
    addi $s4, $s4, 1     # Increment pair counter
    blt $s4, 8, create_pairs
    
    # Restore registers and return
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    lw $ra, 20($sp)
    addi $sp, $sp, 24
    jr $ra

# Shuffle the board array using Fisher-Yates algorithm
shuffle_board:
    # Save return address and $s registers
    addi $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s2, 8($sp)
    sw $s1, 4($sp)
    sw $s0, 0($sp)
    
    # Initialize random seed using system time
    li $v0, 30           # Get system time
    syscall              # Time in $a0, $a1
    
    # Use both parts of time for better randomization
    xor $t0, $a0, $a1    # Combine both parts
    li $v0, 40           # Random seed
    li $a0, 1            # Generator ID
    move $a1, $t0        # Seed from combined time
    syscall
    
    # Shuffle all 16 positions
    li $s0, 15           # Start from last position
    
shuffle_loop:
    # Generate random index between 0 and current
    li $v0, 42           # Random int range
    li $a0, 1            # Generator ID
    addi $a1, $s0, 1     # Upper bound (exclusive)
    syscall
    move $t0, $a0        # Random index in $t0
    
    # Calculate byte offsets
    mul $t1, $s0, 4      # Current position offset
    mul $t2, $t0, 4      # Random position offset
    
    # Swap board values
    lw $t3, board($t1)       # Load current value
    lw $t4, board($t2)       # Load random value
    sw $t4, board($t1)       # Store random value at current
    sw $t3, board($t2)       # Store current value at random
    
    # Swap is_equation values
    lw $t3, is_equation($t1)
    lw $t4, is_equation($t2)
    sw $t4, is_equation($t1)
    sw $t3, is_equation($t2)
    
    # Move to next position
    addi $s0, $s0, -1
    bgez $s0, shuffle_loop
    
    # Restore registers and return
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16
    jr $ra
