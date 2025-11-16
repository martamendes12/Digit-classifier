# ===========================================================
# Identificacao do grupo: A21
#
# Membros
# 1.ist1114456, Joana Oliveira
# 2.ist1114497, Margarida Guedes
# 3.ist1114426, Marta Mendes
#
# ===========================================================
# Requisitos do enunciado que nao estao corretamente implementados:
# (indicar um por linha, ou responder "nenhum")
# - nenhum
#
#===========================================================
# Top-5 das otimizacoes que a vossa solucao incorpora:
# (maximo 140 caracteres por cada otimizacao)
#
#stride para utilização da dot product na matmul
# 
#
# ===========================================================.data

# ===========================================================
#Main data structures.
h_m0: .word 128
w_m0: .word 784
m0: .zero 401408                #h_m0 * w_m0 * 4 bytes 

h_m1: .word 10
w_m1: .word 128
m1: .zero 5120                  #h_m1 * w_m1 * 4 bytes

h_input: .word 784
w_input: .word 1
input: .zero 3136              #h_input * w_input * 4 bytes

h_h: .word 128
w_h: .word 1
h: .zero 512                    #h_h * w_h * 4 bytes

h_o: .word 10
w_o: .word 1
o: .zero 40                     #h_o * w_o * 4 bytes


# ===========================================================
# Here you can define any additional data structures that your program might need

file_m0:     .string "C:\Users\marta\Documents\IAC\m0.bin"
file_m1:     .string "C:\Users\marta\Documents\IAC\m1.bin"
file_input:        .string "C:\Users\marta\Documents\IAC\input0.txt"
 
# ===========================================================
.text

main:
    # Set up arguments for classify function
    la a0, file_m0
    la a1, file_m1
    la a2, file_input
    
    # Call classify function
    jal ra, classify

    li a7, 1
    ecall
    
    j exit 

# ===========================================================
# FUNCTION: abs
#   Computes absolute value of the int stored at a0
# Arguments:
#   a0, a pointer to int
# Returns:
#   Nothing (modifies value in memory)
# ===========================================================

abs:
  lw t0, 0(a0)         # Load int value
  bge t0, zero, done   # If value >= 0, skip negation
  sub t0, x0, t0       # t0 = -t0
  sw t0, 0(a0)         # Store back to memory

done:
  jr ra

# ============================================================
# FUNCTION: relu
#   Applies ReLU on each element of the array (in-place)
# Arguments:
#   a0 = pointer to int array
#   a1 = array length
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ============================================================
relu:

# In case the array is smaller than 1
ble a1, zero, exit_with_error

# Inicialize the index with 0
li t0, 0

loop_relu:
    
    # Run through all the values of the array and checks if they're negative,
    # If so, jumps to substitui, else jumps to skip
    
    bge t0, a1, loop_end_relu
    
    slli t1, t0, 2
    add t2, a0, t1
    lw t3, 0(t2)
    blt t3, zero, substitui
    addi t0,t0,1
    j loop_relu
    
substitui:
    
    # If the value is negative,substitutes it with zero
    sw zero, 0(t2)
    addi t0,t0,1
    j loop_relu


loop_end_relu:
  jr ra

# =================================================================
# FUNCTION: Given an int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the number of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 37
# =================================================================
argmax:

    # In case the array is smaller than 1
    ble a1, zero, exit_with_error

    # Inicializes the variable with the smallest possible number
    li t4, -2147483648
    li t0, 0

loop_argmax:
    
    # Checks if the number is greater than the variable, if so,
    # It jumps to substitui, else it increments the index and jumps back to the loop
    bge t0, a1, loop_end_argmax
    
    slli t1, t0, 2
    add t2, a0, t1
    lw t3, 0(t2)
    bgt t3, t4, substitui_argmax

    addi t0,t0,1
    j loop_argmax
    
substitui_argmax:
    
    # Stores the new greatest number and its index.
    # Increments the index and jumps back to the loop
    mv t4, t3
    mv t5, t0
    addi t0,t0,1
    j loop_argmax

loop_end_argmax:
    mv a0, t5
    jr ra                        # Return to the caller

# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) - Pointer to the start of arr0
#   a1 (int*) - Pointer to the start of arr1
#   a2 (int)  - Number of elements to use   
# Returns:
#   a0 (int)  - The dot product of arr0 and arr1
# Exceptions:
#   - If a2 < 1, exit with error code 38
# =======================================================
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
#    this function terminates the program with error core 39
#  - If the number of columns in matrix A is not equal to the number 
#    of rows in matrix B, it terminates with error code 40
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

    # Save return address and prepare the stack
    addi sp, sp, -16
    sw ra, 12(sp)
    sw a1, 8(sp)      # save buffer
    sw a2, 4(sp)      # save size

    # Open the file (open)
    li a7, 1024       # syscall: open
    li a1, 0          # flag: O_RDONLY
    ecall             # a0 = file descriptor
    add t0, a0, x0         # save descriptor in t0

    blt t0, x0, erro_descritor   # If a0 < 0, descriptor error (code 41)

    # Check if size is valid
    lw a2, 4(sp)
    ble a2, x0, erro_tamanho         # If a2 <= 0, size error (code 42)


    # Read from the file (read)
    add a0, t0, x0         # descriptor
    lw a1, 8(sp)      # buffer
    lw a2, 4(sp)      # size
    li a7, 63         # syscall: read
    ecall
    add t1, a0, x0         # save number of bytes read

    # Close the file (close)
    add a0, t0, x0         # descriptor
    li a7, 57         # syscall: close
    ecall

    # Return number of bytes read
    add a0, t1, x0         # function return
    lw a2, 4(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    jr ra

# Caso erro no descritor
erro_descritor:
    li a0, 41
    j exit_with_error

# Caso tamanho inv lido
erro_tamanho:
    li a0, 42
    j exit_with_error
    jr ra                    # Return to the caller


# =======================================================
# FUNCTION: Classify decimal digit from input image
#   d = classify(A, B, input)
#
# Description:
#   Loads two weight matrices (m0, m1) and an image from files,
#    performs two-layer matrix multiplication (with ReLU activation
#   in between), and returns the digit (0-9) with the highest score.
#
# Arguments:
#   a0 (string*)  - path to file containing weight matrix m0
#   a1 (string*)  - path to file containing weight matrix m1
#   a2 (string*)  - path to input image in Raw PGM format
#
# Returns:
#   a0 (int) - classified digit (0 to 9)
# =======================================================

classify:

    # Save input arguments and return address on the stack
    
    addi sp, sp, -16
    sw a1, 0(sp)     # Save m1 path
    sw a2, 4(sp)     # Save input image path
    sw a0, 8(sp)     # Save m0 path
    sw ra, 12(sp)    # Save return address

    # Load and process first weight matrix (m0)
    
    la a1, m0              # Load address of m0 buffer
    lw t0, h_m0            # Get height of m0
    lw t1, w_m0            # Get width of m0
    mul a2, t0, t1         # Calculate number of bytes to read
    jal ra, read_file      # Read matrix from file

    lw s0, 0(a1)           # Save pointer to matrix m0 in s0
    jal ra, aux_m          # Convert bytes to numeric

    # Load and process second weight matrix (m1)
    
    lw a0, 0(sp)           # Restore path to m1 file
    la a1, m1              # Load address of m1 buffer
    lw t0, h_m1            # Get height of m1
    lw t1, w_m1            # Get width of m1
    mul a2, t0, t1         # Calculate number of bytes to read
    jal ra, read_file      # Read matrix from file

    lw s1, 0(a1)           # Save pointer to matrix m1 in s1
    jal ra, aux_m          # Convert bytes to numeric

    # Load and process input image

    lw a0, 4(sp)           # Restore path to input image
    la a1, input           # Load address of input buffer
    lw t0, h_input         # Get image height
    lw t1, w_input         # Get image width
    mul a2, t0, t1         # Total pixels to read
    jal ra, read_file      # Read image from file

    lw s2, 0(a1)           # Save pointer to image data
    addi s2, s2, 12        # Skip PGM header (first 12 bytes)


    # First layer: matmul(m0, input) => h

    add a0, s0, x0         # a0 = m0 pointer
    add a1, s2, x0         # a1 = input pointer
    lw a2, h_m0            # a2 = height of m0
    lw a3, w_m0            # a3 = width of m0
    lw a4, h_input         # a4 = height of input
    lw a5, w_input         # a5 = width of input
    la a6, h               # a6 = output buffer h

    jal ra, matmul         # Perform first matrix multiplication

    # Apply Relu to intermediate result h

    lw t0, h_h             # Height of h
    lw t1, w_h             # Width of h
    mul a1, t1, t0         # Total elements in h
    add a0, a6, x0         # a0 = pointer to h
    jal ra, relu           # Apply ReLU activation function

    # Second layer: matmul(m1, h) => o

    add a0, s1, x0         # a0 = m1 pointer
    la a1, h               # a1 = h (ReLU output)
    lw a2, h_m1            # a2 = height of m1
    lw a3, w_m1            # a3 = width of m1
    lw a4, h_h             # a4 = height of h
    lw a5, w_h             # a5 = width of h
    la a6, o               # a6 = output buffer o

    jal ra, matmul         # Perform second matrix multiplication

    # Find the index of the maximum value in output (argmax)

    add a0, a6, x0         # a0 = pointer to o
    lw t0, h_o             # height of o
    lw t1, w_o             # width of o
    mul a1, t0, t1         # total elements in o
    jal ra, argmax         # Find the index of max value (digit)

    # Restore stack and return
    
    lw ra, 12(sp)          # Restore return address
    addi sp, sp, 16        # Deallocate stack
    jr ra                  # Return classified digit in a0
  

 ############################################################
# Function: aux_m
# Description:
#   Processes a byte buffer by subtracting 32 from each byte.
#
# Parameters:
#   a1 - pointer to the input buffer (byte array)
#   a2 - number of bytes to process
#
# Returns:
#   None (result is written directly to the input buffer)
############################################################

aux_m:
    li t0, 0                  # t0 = 0 

loop_aux:
    bge t0, a2, loop_aux_end  # if t0 >= length, exit loop

    lb t1, 0(a1)              # load byte from buffer
    addi t1, t1, -32          # subtract 32 
    sb t1, 0(a1)              # store result back to buffer

    addi t0, t0, 1            # t0++
    addi a1, a1, 1            # move to next byte in buffer

    j loop_aux             

loop_aux_end:
    jr ra                     # return to caller
    


# =======================================================
# Exit procedures
# =======================================================

# Exits the program (with code 0)
exit:
    li a7, 10     # Exit syscall code
    ecall         # Terminate the program

# Exits the program with an error 
# Arguments: 
# a0 (int) is the error code 
# You need to load a0 the error to a0 before to jump here
exit_with_error:
  li a7, 93            # Exit system call
  ecall                # Terminate program