mytests.s:
 .align 4
 .section .text
 .globl mytests
 mytests:
    # Register a0 holds the input value
    # Register t0-t6 are caller-save, so you may use them without saving
    # Return value need to be put in register a0
    # Your code starts here

    la  x1,  data
    lw  x2,  0(x1)
    lw  x3,  4(x1)
    lw  x4,  8(x1)
    lw  x5, 12(x1)
    lw  x6, 16(x1)

    addi x2, x2, -1
    addi x3, x3, -1
    addi x4, x4, -1
    addi x5, x5, -1
    addi x6, x6, -1

    sw  x2,  0(x1)
    sw  x3,  4(x1)
    sw  x4,  8(x1)
    sw  x5, 12(x1)
    sw  x6, 16(x1)

# Infinite Loop
halt:
    beq x0, x0, halt

 .section .rodata
 data:
 .word 0xFFFF
 .word 0x0B0B
 .word 0x5555
 .word 0x1111
 .word 0xAAAA
 