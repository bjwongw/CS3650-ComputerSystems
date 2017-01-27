# Brendon Wong
# CS 3650 - Computer Systems
# Insertion Sort

.globl main

.data
how_many: .asciiz "How many ints?\n"
enter_ints: .asciiz "Enter that many ints, one per line\n"
your_array: .asciiz "Your array:\n"
sorted_array: .asciiz "Sorted array:\n"
space: .asciiz " "
newline: .asciiz "\n"

.text
main:
	# Note: not saving any registers because this is the main function
	# $t0 = n
	# $t1 = xs (address of the input array)
	# $t2 = ys (address of the sorted array)

	li $v0, 4	# print string
	la $a0, how_many
	syscall
	
	li $v0, 5	# read int
	syscall
	move $t0, $v0	# n
	
	li $v0, 4	# print string
	la $a0, enter_ints
	syscall
	
	# read in n ints
	move $a0, $t0
	jal read_ints
	move $t1, $v0	# xs (address of the input array)
	
	# insertion sort
	move $a0, $t0	# n
	move $a1, $t1	# xs (address of the input array)
	jal isort
	move $t2, $v0	# ys (address of the sorted array)
	
	# print the input array
	li $v0, 4	# print string
	la $a0, your_array
	syscall
	
	move $a0, $t0	# n
	move $a1, $t1	# xs (address of the input array)
	jal print_ints
	
	# print the sorted array
	li $v0, 4	# print string
	la $a0, sorted_array
	syscall
	
	move $a0, $t0	# n
	move $a1, $t2	# ys (address of the sorted array)
	jal print_ints
	
	li $v0, 10	# exit
	syscall

read_ints:
	subi $sp, $sp, 32
	sw $ra, 0($sp)
	sw $t0, 4($sp)	# n (amount of ints to read in)
	sw $t1, 8($sp)	# 4 (size of a word)
	sw $t2, 12($sp)	# bytes to allocate on the heap
	sw $t3, 16($sp)	# xs (address of the allocated space)
	sw $t4, 20($sp)	# ii
	sw $t5, 24($sp)	# xx (input element)
	sw $t6, 28($sp)	# xs[ii]
	
	move $t0, $a0
	li $t1, 4	# size of a word is 4
	
	# allocate space on the heap for the input array
	mul $t2, $t0, $t1	# bytes to allocate on the heap
	li $v0, 9	# allocate memory on the heap
	move $a0, $t2
	syscall
	move $t3, $v0	# xs (address of the allocated space)
	
	li $t4, 0	# ii = 0

read_ints_loop:
	bge $t4, $t0, read_ints_done

	li $v0, 5	# read int
	syscall
	move $t5, $v0	# xx
	
	# xs[ii] (calculated by: xs + 4 * ii)
	mul $t6, $t1, $t4	# 4 * ii
	add $t6, $t3, $t6	# xs + (4 * ii)
	
	sw $t5, 0($t6)	# xs[ii] = xx
	
	addi $t4, $t4, 1	# ii += 1
	j read_ints_loop
	
read_ints_done:	
	move $v0, $t3

	lw $t6, 28($sp)
	lw $t5, 24($sp)
	lw $t4, 20($sp)
	lw $t3, 16($sp)
	lw $t2, 12($sp)
	lw $t1, 8($sp)
	lw $t0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 32
	jr $ra

isort:
	subi $sp, $sp, 36
	sw $ra, 0($sp)
	sw $t0, 4($sp)	# n (size of the array)
	sw $t1, 8($sp)	# xs (address of the array to sort)
	sw $t2, 12($sp)	# 4 (size of a word)
	sw $t3, 16($sp)	# bytes to allocate on the heap
	sw $t4, 20($sp)	# ys (address of the sorted array)
	sw $t5, 24($sp)	# ii
	sw $t6, 28($sp)	# xs[ii]
	sw $t7, 32($sp)	# xx (element to insert)

	move $t0, $a0	# n
	move $t1, $a1	# xs
	li $t2, 4		# size of a word
	
	# allocate space on the heap for the sorted array
	mul $t3, $t0, $t2	# bytes to allocate on the heap
	li $v0, 9	# allocate memory on the heap
	move $a0, $t3
	syscall
	move $t4, $v0	# address of ys
	
	li $t5, 0		# ii = 0
	
isort_loop:
	bge $t5, $t0, isort_done

	# xs[ii] (calculated by: xs + 4 * ii)
	mul $t6, $t2, $t5	# 4 * ii
	add $t6, $t1, $t6	# $xs + (4 * ii)
	
	lw $t7, 0($t6)	# xx = xs[ii]
	
	move $a0, $t5	# size of the array that's been sorted
	move $a1, $t4	# ys (address of the sorted array)
	move $a2, $t7	# xx
	jal insert
	
	addi $t5, $t5, 1	# ii += 1	
	j isort_loop
	
isort_done:
	move $v0, $t4

	lw $t7, 32($sp)
	lw $t6, 28($sp)
	lw $t5, 24($sp)
	lw $t4, 20($sp)
	lw $t3, 16($sp)
	lw $t2, 12($sp)
	lw $t1, 8($sp)
	lw $t0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 36
	jr $ra

insert:
	# insert a number into an array where the first nn
	# elements are already sorted
	subi $sp, $sp, 32
	sw $ra, 0($sp)
	sw $t0, 4($sp)	# nn (number of elements that have been sorted)
	sw $t1, 8($sp)	# xs (address of the array)
	sw $t2, 12($sp)	# xx (element to insert)
	sw $t3, 16($sp)	# 4 (size of a word)
	sw $t4, 20($sp)	# ii
	sw $t5, 24($sp)	# xs[ii]
	sw $t6, 28($sp)	# yy
	
	move $t0, $a0	# nn
	move $t1, $a1	# xs
	move $t2, $a2	# xx
	
	li $t3, 4		# size of a word
	li $t4, 0		# ii = 0

insert_loop:
	bge $t4, $t0, insert_done
	
	# xs[ii] (calculated by: xs + 4 * ii)
	mul $t5, $t3, $t4	# 4 * ii
	add $t5, $t1, $t5	# xs + (4 * ii)
	
	lw $t6, 0($t5)		# yy = xs[ii]
	addi $t4, $t4, 1	# ii += 1
	blt $t2, $t6, insert_element_case # xx < yy
	
	j insert_loop
	
insert_element_case:
	sw $t2, 0($t5)		# xs[ii] = xx
	move $t2, $t6		# xx = yy
	
	j insert_loop

insert_done:
	# xs[ii] (calculated by: xs + 4 * ii)
	mul $t5, $t3, $t4	# 4 * ii
	add $t5, $t1, $t5	# xs + (4 * ii)
	
	sw $t2, 0($t5)		# xs[ii] = xx

	lw $t6, 28($sp)
	lw $t5, 24($sp)
	lw $t4, 20($sp)
	lw $t3, 16($sp)
	lw $t2, 12($sp)
	lw $t1, 8($sp)
	lw $t0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 32
	jr $ra
	
print_ints:
	subi $sp, $sp, 28
	sw $ra, 0($sp)
	sw $t0, 4($sp)	# n (number of ints to print)
	sw $t1, 8($sp)	# xs (address of the array of ints)
	sw $t2, 12($sp)	# 4 (size of a word)
	sw $t3, 16($sp)	# ii
	sw $t4, 20($sp)	# xs[ii]
	sw $t5, 24($sp)	# xx (element to print)
	
	move $t0, $a0	# n
	move $t1, $a1	# xs
	li $t2, 4		# size of a word is 4
	li $t3, 0		# ii = 0
	
print_ints_loop:
	bge $t3, $t0, print_ints_done

	# xs[ii] (calculated by: xs + 4 * ii)
	mul $t4, $t2, $t3	# 4 * ii
	add $t4, $t1, $t4	# xs + (4 * ii)
	
	lw $t5, 0($t4)	# xx = xs[ii]
	
	li $v0, 1	# print int
	move $a0, $t5
	syscall
	
	li $v0, 4	# print string
	la $a0, space
	syscall
	
	addi $t3, $t3, 1	# ii += 1
	j print_ints_loop
	
print_ints_done:
	li $v0, 4	# print string
	la $a0, newline
	syscall

	lw $t5, 24($sp)
	lw $t4, 20($sp)
	lw $t3, 16($sp)
	lw $t2, 12($sp)
	lw $t1, 8($sp)
	lw $t0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 28
	jr $ra
