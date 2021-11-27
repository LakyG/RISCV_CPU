mytests.s:
 .align 4
 .section .text
 .globl load_store
 load_store:
    # Register a0 holds the input value
    # Register t0-t6 are caller-save, so you may use them without saving
    # Return value need to be put in register a0
    # Your code starts here

    la x1, data

    # lbu x2, 0(x1)
    # lbu x3, 1(x1)
    lhu x2, 0(x1)
    # lb x4, 2(x1)
    # lb x5, 3(x1)
    lh x4, 2(x1)

    addi x2, x2, 0x0101
    # addi x3, x3, 1
    addi x4, x4, 0x0101
    # addi x5, x5, 1

    slli x2, x2, 0
    # slli x3, x3, 8
    slli x4, x4, 16
    # slli x5, x5, 24

    # or x2, x2, x3
    # or x4, x4, x5

    # sb x2, 0(x1)
    # sb x3, 1(x1)
    sh x2, 0(x1)
    # sb x4, 2(x1)
    # sb x5, 3(x1)
    sh x4, 2(x1)

# Infinite Loop
halt:
    beq x0, x0, halt

 .section .rodata
 data:
 .word 0x004488CC
 