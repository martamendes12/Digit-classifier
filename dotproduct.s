.data
# Sample input arrays
# You can change this array to test other values (remember to modify the dimensions in the main)

arr0: .word 1, 2, 3, 4
arr1: .word 10, 20, 30, 40

.text

main:	
    # Set up arguments for dotproduct(arr0, arr1, 4)
    la a0, arr0         # a0 = &arr0
    la a1, arr1         # a1 = &arr1
    li a2, 4            # a2 = number of elements

    jal ra, dotproduct  # Call dotproduct function

    # The result of the dot product is now in a0
    
exit:
    li a7, 10     # Exit syscall code
    ecall         # Terminate the program


# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) - Pointer to the start of arr0
#   a1 (int*) - Pointer to the start of arr1
#   a2 (int)  - Number of elements to use	
# Returns:
#   a0 (int)  - The dot product of arr0 and arr1
# Exceptions:
#   - If a2 < 1, exit with error code 36
# =======================================================
dotproduct:
    #Define the temporary registers
    li t0, 0     #index of elements
    li t1, 0     #the result
    
    #Check if the number of elementos is greater than 0  
    ble a2, x0, error_38
    
    loop_dot:
    
        #Check if the index isn't greater than the lenght of the array
        bgt t0, a2, end_dot
        
        #Transfers the values on the array and puts them in temporaries
        lw t2, 0(a0)
        
        lw t3, 0(a1)
        
        #Multiply them
        mul t2, t2, t3
        
        #Add to the result
        add t1, t1, t2
        
        #Increases the index
        addi t0, t0, 1
        
        #Increases the pointers of the arrays by add them the lenght of a word
        addi a0, a0, 4
        addi a1, a1, 4
        j loop_dot
        
    end_dot:
        
        #Tranfers the result to the argument
        add a0, t1, x0
        sw a0, 0(a0)
        
    error_38:
        li a0, 38
        j exit_with_error

# Exits the program with an error 
# Arguments: 
# a0 (int) is the error code 
# You need to load a0 the error to a0 before to jump here
exit_with_error:
  li a7, 93            # Exit system call
  ecall                # Terminate program