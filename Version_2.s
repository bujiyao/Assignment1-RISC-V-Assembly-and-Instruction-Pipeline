.data
mask1: .word 0x5555
mask2: .word 0x3333
mask3: .word 0x0F0F
mask4: .word 0x00FF
str_valid: .string "Valid times for %d LEDs turned on:\n"
str_colon: .string ":"
str_leading_zero: .string "0"
str_newline: .string "\n"
input_turned_on: .word 1

.text
main:
    addi sp, sp, -16          # Prologue: allocate stack space
    sw ra, 12(sp)             # Save return address
    sw s0, 8(sp)              # Save register s0
    sw s1, 4(sp)              # Save register s1

    lw s0, input_turned_on    # Load LED turned on count into s0
    jal ra, readBinaryWatch   # Call readBinaryWatch function

    # Print result message
    la a0, str_valid          # Load result message string
    li a7, 4                  # Syscall: print string
    ecall

    mv a0, s0                 # Load LED turned on count
    li a7, 1                  # Syscall: print integer
    ecall

    # Restore registers and exit
    lw s1, 4(sp)              # Restore register s1
    lw s0, 8(sp)              # Restore register s0
    lw ra, 12(sp)             # Restore return address
    addi sp, sp, 16           # Epilogue: restore stack space
    li a7, 10                 # Syscall: exit
    ecall

# hammingWeight function
hammingWeight:
    addi sp, sp, -12        # Prologue: allocate stack space
    sw ra, 8(sp)            # Save return address
    sw s0, 4(sp)            # Save register s0
    sw s1, 0(sp)            # Save register s1

    # Load input n into s0
    mv s0, a0               # s0 = n

    # Step 1: n = (n & 0x5555) + ((n >> 1) & 0x5555)
    lw t0, mask1            # Load mask1 (0x5555) into t0
    and t1, s0, t0          # t1 = s0 & 0x5555
    srai t2, s0, 1          # t2 = s0 >> 1
    and t2, t2, t0          # t2 = (s0 >> 1) & 0x5555
    add s0, t1, t2          # s0 = t1 + t2

    # Step 2: n = (n & 0x3333) + ((n >> 2) & 0x3333)
    lw t0, mask2            # Load mask2 (0x3333) into t0
    and t1, s0, t0          # t1 = s0 & 0x3333
    srai t2, s0, 2          # t2 = s0 >> 2
    and t2, t2, t0          # t2 = (s0 >> 2) & 0x3333
    add s0, t1, t2          # s0 = t1 + t2

    # Step 3: n = (n & 0x0F0F) + ((n >> 4) & 0x0F0F)
    lw t0, mask3            # Load mask3 (0x0F0F) into t0
    and t1, s0, t0          # t1 = s0 & 0x0F0F
    srai t2, s0, 4          # t2 = s0 >> 4
    and t2, t2, t0          # t2 = (s0 >> 4) & 0x0F0F
    add s0, t1, t2          # s0 = t1 + t2

    # Step 4: n = (n & 0x00FF) + ((n >> 8) & 0x00FF)
    lw t0, mask4            # Load mask4 (0x00FF) into t0
    and t1, s0, t0          # t1 = s0 & 0x00FF
    srai t2, s0, 8          # t2 = s0 >> 8
    and t2, t2, t0          # t2 = (s0 >> 8) & 0x00FF
    add s0, t1, t2          # s0 = t1 + t2

    # Return result
    mv a0, s0               # a0 = s0 (result)
    lw s1, 0(sp)            # Restore register s1
    lw s0, 4(sp)            # Restore register s0
    lw ra, 8(sp)            # Restore return address
    addi sp, sp, 12         # Epilogue: restore stack space
    ret                     # Return from function

# readBinaryWatch function
readBinaryWatch:
    addi sp, sp, -16          # Prologue: allocate stack space
    sw ra, 12(sp)             # Save return address
    sw s0, 8(sp)              # Save register s0
    sw s1, 4(sp)              # Save register s1

    li s0, 0                  # s0 = returnSize = 0
    li s1, 1024               # Loop upper bound, iterate 10-bit combinations

loop_watch:
    beq s0, s1, end_readBinaryWatch  # If s0 == s1, end loop
    mv a0, s0                        # a0 = current value
    jal ra, hammingWeight            # Call hammingWeight function

    # Check conditions: hammingWeight(i) == turnedOn && hour < 12 && minute < 60
    lw t1, input_turned_on           # Load turned on LED count
    bne a0, t1, next_iteration       # If bit count != LED turned on count, skip
    srli t2, s0, 6                   # Extract hour (first 4 bits)
    andi t3, s0, 0x3F                # Extract minute (last 6 bits)
    li t4, 12                        # Load value 12 into t4
    bge t2, t4, next_iteration       # If hour >= 12, skip

    li t4, 60                        # Load value 60 into t4
    bge t3, t4, next_iteration       # If minute >= 60, skip

    # Print valid time
    mv a0, t2                        # Load hour value
    li a7, 1                         # Syscall: print integer
    ecall

    la a0, str_colon                 # Load colon string
    li a7, 4                         # Syscall: print string
    ecall

    # Print minute with leading zero if needed
    li t4, 10                        # Load value 10 into t4
    blt t3, t4, print_leading_zero

print_minute:
    mv a0, t3                        # Load minute value
    li a7, 1                         # Syscall: print integer
    ecall
    j end_print_time

print_leading_zero:
    la a0, str_leading_zero          # Load leading zero string
    li a7, 4                         # Syscall: print string
    ecall
    j print_minute

end_print_time:
    la a0, str_newline               # Load newline string
    li a7, 4                         # Syscall: print string
    ecall

next_iteration:
    addi s0, s0, 1                   # Increment loop counter
    j loop_watch                     # Loop

end_readBinaryWatch:
    lw s0, 8(sp)                     # Restore register s0
    lw s1, 4(sp)                     # Restore register s1
    lw ra, 12(sp)                    # Restore return address
    addi sp, sp, 16                  # Epilogue
    ret
