#  mp4-cp1.s version 4.0
.align 4
.section .text
.globl _start
_start:

la x1, DATA
addi x2, x0, 5
sw x2, 0(x1)

nop
nop
nop
nop
nop

lw x3, DATA

HALT:
    beq x0, x0, HALT

.section .rodata
DATA:
.word 0x0