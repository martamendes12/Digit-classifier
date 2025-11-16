.data

buffer_input:  .zero 14
null:          .string ""

file_input:     .string "output0.pgm"

.text

main:
    # Read both input files
    # read the image inputs

    la  a0, file_input       # a0 = pointer to filename
    la  a1, buffer_input     # a1 = pointer to buffer
    li  a2, 14               # a2 = number of bytes to read
    jal ra, read_file        # call read_file
    
   
    la a0, buffer_input
    li a7, 4                 # PrintString call
    ecall

    # Exit program
    li a7, 10                # syscall: exit
    ecall


######################################################################
# Function: read_file(char* filename, byte* buffer, int length)
# Input:
#   a0: pointer to null-terminated filename string
#   a1: destination buffer
#   a2: number of bytes to read
# Output:
#   a0: number of bytes read (return value from syscall)
# Exceptions:
#   - Error code 41 if error in the file descriptor
#   - Error code 42 If the length of the bytes to read is less than 1
######################################################################

read_file:

    # Save return address and arguments to the stack
    addi sp, sp, -16        # Allocate space on stack
    sw ra, 12(sp)           # Save return address
    sw a1, 8(sp)            # Save buffer pointer
    sw a2, 4(sp)            # Save read size


    # Open the file
    
    li a7, 1024             # syscall number for open
    li a1, 0                # read flag 
    ecall                   # Perform syscall: a0 = file descriptor
    add t0, a0, x0          # Save file descriptor in t0
    blt t0, x0, error_descriptor  # If descriptor < 0, jump to error


    # Validate read size

    lw a2, 4(sp)            # Load saved read size
    ble a2, x0, error_length  # If size <= 0, jump to error


    # Read from the file

    add a0, t0, x0          # a0 = file descriptor
    lw a1, 8(sp)            # a1 = buffer pointer
    lw a2, 4(sp)            # a2 = size to read
    li a7, 63               # syscall number for read
    ecall                   # Perform syscall: a0 = bytes read
    add t1, a0, x0          # Save bytes read in t1



    # Close the file

    add a0, t0, x0          # a0 = file descriptor
    li a7, 57               # syscall number for close
    ecall                   # Close file



    # Return number of bytes read

    add a0, t1, x0          # Set return value to bytes read
    lw a2, 4(sp)            # Restore for consistency
    lw ra, 12(sp)           # Restore return address
    addi sp, sp, 16         # Restore stack
    jr ra                   # Return to caller


# File descriptor error handler
error_descriptor:
    li a0, 41               # Set error code 41
    j exit_with_error       # Jump to error handler

# Invalid read size error handler
error_length:
    li a0, 42               # Set error code 42
    j exit_with_error       # Jump to error handler
    jr ra                


# Exits the program with an error 
# Arguments: 
# a0 (int) is the error code 
# You need to load a0 the error to a0 before to jump here
exit_with_error:
  li a7, 93            # Exi system call
  ecall                # Terminate program