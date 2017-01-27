# Homework 2: 4-Function Calculator
# CS 3650: Computer Systems
# Brendon Wong
.globl main

.data
    select_operation: .asciiz "Select operation (+, -, *, or /): "
    plus: .asciiz "+"
    minus: .asciiz "-"
    asterisk: .asciiz "*"
    forward_slash: .asciiz "/"
    operator: .space 3  # space to hold operator
    
    first_number: .asciiz "First number: "
    second_number: .asciiz "Second number: "

.text
main:
    # NOTE: I'm not allocating stack space in the main function
    # because nothing is calling this function.
    # ----
    # $t0 is the operator
    # $t1 is the plus char
    # $t2 is the minus char
    # $t3 is the asterisk char (multiplication)
    # $t4 is the forward_slash char (division)
    # $t5 is the result
    # $t6 is the first operand
    # $t7 is the second operand
    
    la $a0, select_operation    
    li $v0, 4   # print string
    syscall

    la $a0, operator    # load the operator label into $a0
    li $a1, 3   # buffer space for input (padded with null byte)
    li $v0, 8   # read string
    syscall
    
    lb $t0, operator    # loads the first byte (the operator character)
    lb $t1, plus        # loads the plus character
    lb $t2, minus       # loads the minus character
    lb $t3, asterisk    # loads the asterisk character
    lb $t4, forward_slash   # loads the forward slash character
    
    beq $t0, $t1, addition_case
    beq $t0, $t2, subtraction_case
    beq $t0, $t3, multiplication_case
    beq $t0, $t4, division_case
    
    j main_done     # jump to the end in case there were no matches

addition_case:
    jal addition
    move $t5, $v0   # store the result in $t5
    j main_done
    
subtraction_case:
    jal subtraction
    move $t5, $v0   # store the result in $t5
    j main_done
    
multiplication_case:
    jal multiplication
    move $t5, $v0   # store the result in $t5
    j main_done
    
division_case:
    jal division
    move $t5, $v0   # store the result in $t5
    j main_done
    
main_done:  
    move $a0, $t5
    li $v0, 1   # print integer
    syscall

    li $v0, 10  # exit
    syscall

read_two_nums:
    # NOTE: not allocating stack space for $ra because this function
    # does not call any other functions (doesn't override $ra)
    # ----
    # returns the two numbers in the $v0 and $v1 registers
    # $t6 is the first operand
    # $t7 is the second operand
    subi $sp, $sp, 8
    sw $t6, 0($sp)
    sw $t7, 4($sp)
    
    la $a0, first_number
    li $v0, 4   # print string  
    syscall
    
    li $v0, 5   # read integer
    syscall 
    move $t6, $v0   # store the first int in $t6
    
    la $a0, second_number
    li $v0, 4   # print string  
    syscall
    
    li $v0, 5   # read integer
    syscall 
    move $t7, $v0   # store the second int in $t7
    
    move $v0, $t6
    move $v1, $t7
    
    lw $t7, 4($sp)
    lw $t6, 0($sp)
    addi $sp, $sp, 8
    jr $ra
    
addition:
    # save the return register
    subi $sp, $sp, 4
    sw $ra, 0($sp)
    
    jal read_two_nums
    add $v0, $v0, $v1   # add

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

subtraction:
    # save the return register
    subi $sp, $sp, 4
    sw $ra, 0($sp)
    
    jal read_two_nums
    sub $v0, $v0, $v1   # subtract

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

multiplication:
    # save the return register
    subi $sp, $sp, 4
    sw $ra, 0($sp)
    
    jal read_two_nums
    mul $v0, $v0, $v1   # multiply

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

division:
    # save the return register
    subi $sp, $sp, 4
    sw $ra, 0($sp)
    
    jal read_two_nums
    div $v0, $v0, $v1   # divide
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra