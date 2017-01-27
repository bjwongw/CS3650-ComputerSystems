# Homework 2: Fibonacci
# CS 3650: Computer Systems
# Brendon Wong

.globl main

.text
main:
    # NOTE: I'm not allocating stack space in the main function
    # because nothing is calling this function.
    # ----
    li $v0, 5   # read integer
    syscall
    move $a0, $v0   # value of x, the input (fibonacci index)
    
    jal fib
    move $a0, $v0   # value of the output (fibonacci number)
    
    li $v0, 1   # print integer
    syscall
    
    li $v0, 10  # exit
    syscall
    
fib:
    # def fib(x):
    #   if x < 2:   // this prevents negative inputs from putting this in an infinite loop
    #       return x
    #   else:
    #       return fib(x - 1) + fib(x - 2)
    # t0 is x
    # t1 is fib(x - 1)
    # t2 is fib(x - 2)
    subi $sp, $sp, 16   # reserve 16 bytes of stack space for this function
    sw $ra, 0($sp)
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    sw $t2, 12($sp)
    
    move $t0, $a0       # move x to $t0
    slti $t3, $t0, 2    # x < 2 ? 1 : 0
    
    move $a0, $t0       # set x as the argument
    beq $t3, $zero, fib_recursive_case  # branch if x >= 2
    
    move $v0, $t0
    j fib_return

fib_recursive_case:
    move $t0, $a0       # set x to $t0

    # $t1 = fib(x - 1)
    subi $a0, $t0, 1
    jal fib
    move $t1, $v0
    
    # $t2 = fib(x - 2)
    subi $a0, $t0, 2
    jal fib
    move $t2, $v0
    
    # fib(x - 1) + fib(x - 2)
    add $v0, $t1, $t2

fib_return:
    lw $t2, 12($sp)
    lw $t1, 8($sp)
    lw $t0, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 16
    jr $ra