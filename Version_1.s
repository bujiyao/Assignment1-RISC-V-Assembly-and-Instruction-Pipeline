.data
str_valid: .string "LEDs turned on:"
str_colon: .string ":"
str_leading_zero: .string "0"
str_newline: .string "\n"
input_turned_on: .word 1

.text
.globl main

main:
    addi sp, sp, -4
    sw ra, 0(sp)

    lw a0, input_turned_on    # Load LED turned on count into a0
    jal ra, readBinaryWatch   # Call readBinaryWatch function

    # Print result message
    la a0, str_valid          # Load result message string
    li a7, 4                  # Syscall: print string
    ecall

    lw a0, input_turned_on    # Load LED turned on count
    li a7, 1                  # Syscall: print integer
    ecall

    la a0, str_newline        # Print newline
    li a7, 4
    ecall

    # Exit program
    lw ra, 0(sp)
    addi sp, sp, 4
    li a7, 10                 # Syscall: exit
    ecall

# hammingWeight function
hammingWeight:
    li t0, 0                  # Initialize count to 0
hammingWeight_loop:
    beqz a0, hammingWeight_end  # If n == 0, exit loop
    addi t1, a0, -1           # t1 = n - 1
    and a0, a0, t1            # n = n & (n - 1)
    addi t0, t0, 1            # Increment count
    j hammingWeight_loop
hammingWeight_end:
    mv a0, t0                 # Move count to return register
    ret

# readBinaryWatch function
readBinaryWatch:
    addi sp, sp, -28
    sw ra, 24(sp)
    sw s0, 20(sp)
    sw s1, 16(sp)
    sw s2, 12(sp)
    sw s3, 8(sp)
    sw s4, 4(sp)
    sw s5, 0(sp)

    mv s5, a0                 # s5 = turnedOn (input parameter)
    li s0, 0                  # s0 = counter
    li s1, 1024               # s1 = upper bound
    li s3, 0                  # s3 = number of valid times found

loop_watch:
    beq s0, s1, end_readBinaryWatch
    mv a0, s0
    jal ra, hammingWeight
    bne a0, s5, next_iteration

    # Extract hour and minute
    srli t0, s0, 6
    andi t0, t0, 0xF          # t0 = hour
    andi t1, s0, 0x3F         # t1 = minute

    # Check hour < 12 and minute < 60
    li t2, 12
    bge t0, t2, next_iteration
    li t2, 60
    bge t1, t2, next_iteration

    # Print hour
    mv a0, t0
    li a7, 1                  # Syscall: print integer
    ecall

    # Print colon
    la a0, str_colon
    li a7, 4                  # Syscall: print string
    ecall

    # Print minute with leading zero if needed
    li t2, 10
    bge t1, t2, print_minute

    la a0, str_leading_zero
    li a7, 4                  # Syscall: print string
    ecall

print_minute:
    mv a0, t1
    li a7, 1                  # Syscall: print integer
    ecall

    # Print newline
    la a0, str_newline
    li a7, 4                  # Syscall: print string
    ecall

    addi s3, s3, 1            # Increment valid times counter

next_iteration:
    addi s0, s0, 1
    j loop_watch

end_readBinaryWatch:
    mv a0, s3                 # Return number of valid times found

    # Restore saved registers and return
    lw ra, 24(sp)
    lw s0, 20(sp)
    lw s1, 16(sp)
    lw s2, 12(sp)
    lw s3, 8(sp)
    lw s4, 4(sp)
    lw s5, 0(sp)
    addi sp, sp, 28
    ret


