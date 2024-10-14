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
