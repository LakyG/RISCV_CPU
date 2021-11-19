mytests.s:
 .align 4
 .section .text
 .globl cacheWrites
 cacheWrites:
    # Register a0 holds the input value
    # Register t0-t6 are caller-save, so you may use them without saving
    # Return value need to be put in register a0
    # Your code starts here

    # SET 3
    la x1, data00
    la x2, data10
    la x3, data20

    # Fill data into cache set 5, block 0
    lw x4, 0(x1)
    # Fill data into cache set 5, block 1
    lw x5, 0(x2)

    ##### Cache Set 5 should now be full with data, both blocks ####

    # SET 4
    addi x4, x4, -0xE
    addi x5, x5,  0xE
    addi x6, x0, 0xCC
    sw x4, 0(x1)    # Makes block 0 dirty (block 1 is now LRU, so it should now be replaced/overwritten)
    sw x5, 4(x2)    # Makes block 1 dirty (block 0 is now LRU, so it should now be replaced/overwritten)

    sh x6, 2(x3)    # Makes block 0 get written back and replaced by new cacheline, new Block 0 is dirty (block 1 is now LRU)

    lh x4, 2(x1)    # Makes Block 1 get written back and replaced by new cacheline, (block 0 is now LRU)

    # Add 'nop' instructions to fill the current set with just instructions, and so that the loaded data goes to a different set

# Infinite Loop
halt:
    beq x0, x0, halt

 .section .rodata
 ########################## TAG 0 ###########################
 data00:
 .word 0xFFFFFFFF
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 data01:
 .word 0xEEEEEEEE
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 restOfTag0:
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
########################## TAG 1 ###########################
 data10:
 .word 0x11111111
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 data11:
 .word 0x22222222
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 restOfTag1:
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0

 ########################## TAG 2 ###########################
 data20:
 .word 0xAAAAAAAA
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 data21:
 .word 0xBBBBBBBB
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 restOfTag2:
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0
 .word 0x0