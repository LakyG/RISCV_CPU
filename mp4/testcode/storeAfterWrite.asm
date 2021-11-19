#  mp4-cp1.s version 4.0
.align 4
.section .text
.globl _start
_start:

la x1, DATA
addi x2, x0, 5
sw x2, 0(x1)

.section .rodata
DATA:
.word 0x0