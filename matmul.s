.data

# You can change this array to test other values (remember to modify the dimentions in the main)
m0: .word 1, 2, 3, 4, 5, 6        # Matrix A (2x3) in row-major order
m1: .word 7, 8, 9, 10, 11, 12     # Matrix B (3x2) in row-major order
d:  .word 0, 0, 0, 0              # Output matrix C (2x2), initialized to 0

.text
main:
  # Load pointers to matrices
  la a0, m0                     # a0 = address of matrix A
  la a1, m1                     # a1 = address of matrix B
  la a6, d                      # a6 = address of output matrix C

  # Load matrix dimensions
  li a2, 2                      # a2 = rows of A = 2
  li a3, 3                      # a3 = cols of A = 3
  li a4, 3                      # a4 = rows of B = 3
  li a5, 2                      # a5 = cols of B = 2
  
  # Load input type 
  jal ra, matmul                # Call matrix multiplication function

  # The contents of matrix d now have the result of matmul(m0,m1)

exit:
  li a7, 10              # Exit syscall code
  ecall                  # Terminate the program

# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
#
# Arguments:
#   a0 (int*)  - pointer to the start of m0     (Matrix A)
#   a1 (int*)  - pointer to the start of m1     (Matrix B)
#   a2 (int)   - number of rows in m0 (A)             [rows_A]
#   a3 (int)   - number of columns in m0 (A)          [cols_A]
#   a4 (int)   - number of rows in m1 (B)             [rows_B]
#   a5 (int)   - number of columns in m1 (B)          [cols_B]
#   a6 (int*)  - pointer to the start of d            (Matrix C = A x B)
#
# Returns:
#   None (void); result is stored in memory pointed to by a6 (d)
#
# Exceptions:
#  - If the height or width of any of the matrices is less than 1, 
#    this function terminates the program with error core 38
#  - If the number of columns in matrix A is not equal to the number 
#    of rows in matrix B, it terminates with error code 38
# =======================================================
matmul:

    # Error checks
    ble a2, x0, err39         # if rows_A <= 0, error 39
    ble a4, x0, err39         # if rows_B <= 0, error 39
    bne a3, a4, err40         # if cols_A != rows_B, error 40

    # Initialization
    li t0, 0                  # i = 0 (row index for A)
    li t1, 0                  # j = 0 (column index for B)
    li t6, 0                  # linear index for result matrix C

    # Save necessary registers to the stack
    addi sp, sp, -16
    sw ra, 0(sp)
    sw a0, 4(sp)              # save pointer to matrix A
    sw a1, 8(sp)              # save pointer to matrix B
    sw a6, 12(sp)             # save pointer to matrix C

# Outer loop over rows of A
loop_row:
    bge t0, a2, exit_matmul   # if i >= rows_A, exit

    li t1, 0                  # reset j = 0 (start new row in C)

# Inner loop over columns of B
loop_col:
    bge t1, a5, next_row      # if j >= cols_B, move to next row

    # Compute address of row i in A
    mul t3, t0, a3            # offset = i * cols_A
    slli t3, t3, 2            # convert to byte offset (word = 4 bytes)
    lw a0, 4(sp)              # load pointer to A
    add a0, a0, t3            # a0 points to A[i]

    # Compute address of column j in B
    slli t4, t1, 2            # offset = j * 4
    lw a1, 8(sp)              # load pointer to B
    add a1, a1, t4            # a1 points to B[0][j] (start of column)

    add s2, a2, x0            # save rows_A in s2 for later

    # Set up parameters for dotproduct
    add a2, a3, x0            # a2 = cols_A = number of elements in dot product
                              # a5 = stride of B = cols_B (already set)
                              
    add s3, t1, x0            # save current column index j
    add s4, t0, x0            # save current row index i

    jal dotproduct            # call dotproduct; result returned in a0

    # Restore saved values after call
    lw ra, 0(sp)
    lw a6, 12(sp)             # restore pointer to matrix C

    add t1, s3, x0            # restore j
    add t0, s4, x0            # restore i
    add a2, s2, x0            # restore rows_A

    # Store result in C[i][j]
    slli t3, t6, 2            # compute offset = (i * cols_B + j) * 4
    add a6, a6, t3            # a6 points to C[i][j]
    sw a0, 0(a6)              # store result

    addi t1, t1, 1            # j++
    addi t6, t6, 1            # increment linear index for C
    j loop_col                # go to next column
    

# Move to next row in A
next_row:
    addi t0, t0, 1            # i++
    j loop_row                # repeat outer loop

# Function exit
exit_matmul:
    lw ra, 0(sp)              # restore return address
    addi sp, sp, 16           # restore stack pointer
    jr ra                     # return

# Error handling
err39:
    li a0, 39                 # set error code 39
    j exit_with_error

err40:
    li a0, 40                 # set error code 40
    j exit_with_error
    
dotproduct:

    li t0, 0                 # i = 0 (loop counter)
    li t1, 0                 # accumulator = 0 (for the final dot product result)

loop_dot:
    bge t0, a2, end_dot      # If i >= n, exit loop

    lw t2, 0(a0)             # Load array0[i]
    lw t3, 0(a1)             # Load array1[i * stride]
    mul t2, t2, t3           # Multiply array0[i] * array1[i * stride]
    add t1, t1, t2           # Accumulate result in t1

    addi a0, a0, 4           # Move to next element in array0 (4 bytes ahead)

    slli t5, a5, 2           # Convert stride from elements to bytes
    add a1, a1, t5           # Move to next strided element in array1

    addi t0, t0, 1           # i++
    j loop_dot               

end_dot:
    add a0, t1, x0           # Move final result to return register (a0)
    jr ra                    # Return to caller

# Error handling
error_38:
    li a0, 38                # Error code 38
    j exit_with_error


# Exits the program with an error 
# Arguments: 
# a0 (int) is the error code 
# You need to load a0 the error to a0 before to jump here
exit_with_error:
  li a7, 93            # Exit system call
  ecall                # Terminate program

