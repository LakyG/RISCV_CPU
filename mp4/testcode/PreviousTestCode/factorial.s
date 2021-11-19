factorial.s:
.align 4
.section .text
.globl factorial
main:
    li a0, 5
    jal factorial
halt:
    beq zero, zero, halt
factorial:
    # Register a0 holds the input value
    # Register t0-t6 are caller-save, so you may use them without saving
    # Return value need to be put in register a0
    # Your code starts here

    addi sp, sp, -12
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw ra, 8(sp)

    mv s0, a0   # Copy the input argument; loop iterator
    li s1, 1    # Product; initialized to 1

loop_start:
    ble s0, zero, loop_exit

    mv a0, s0
    mv a1, s1
    jal multiply
    mv s1, a0       # Copy result

    addi s0, s0, -1
    j loop_start

loop_exit:
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw ra, 8(sp)
    addi sp, sp, 12
    jr ra

#### Multiplication Subroutine ####
multiply:
    # a0 and a1 hold the input arguments
    # a0 is the return value
    mv t0, a0   # copy multiplicand
    li t1, 0    # loop iterator
    addi a1, a1, -1
mult_loop_start:
    bge t1, a1, mult_loop_end
    add a0, a0, t0
    addi t1, t1, 1
    j mult_loop_start

mult_loop_end:
    jr ra
###################################
