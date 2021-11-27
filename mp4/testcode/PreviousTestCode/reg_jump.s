mytests.s:
 .align 4
 .section .text
 .globl reg_jump
 reg_jump:
    # Register a0 holds the input value
    # Register t0-t6 are caller-save, so you may use them without saving
    # Return value need to be put in register a0
    # Your code starts here

    addi x1, x0, 10
    addi x2, x0, 5

    add  x3, x0, x0 #Initalize to 0

    add  x3, x3, x1 #10
    sub  x3, x3, x2 #5

    slt  x3, x3, x1 #1

    sub  x3, x3, x1 #-9
    sltu x3, x3, x2 #0

    ###
    addi x3, x0, 9  #9
    xor  x3, x3, x2 #12

    ###
    addi x3, x0, 3  #3
    sll  x3, x3, x2 #96 (3 << 5)
    srl  x3, x3, x2 #3 (96 >> 5)

    ###
    addi x3, x0, -2 #-2
    srl  x4, x3, x2 #2047
    sra  x3, x3, x2 #-1

    ###
    addi x3, x0, 1  #1
    or   x3, x3, x1 #11
    and  x3, x3, x2 #1

    ###
    jal x3, halt
    addi x5, x0, 0xAA #Should not occur
    addi x6, x0, 0xBB #Should not occur

# Infinite Loop
halt:
    beq x0, x0, halt
