.data
input_buffer:	.space 129
output_buffer:	.space 129
newline:	.asciiz "\n"

enter_prompt:	.asciiz "Enter a number: "
lmao_str:		.asciiz "LMAO\n"
valcheck_str:	.asciiz "Val: "

.text
############################################  MAIN #######
main:
	la $a0, enter_prompt
	jal print_str

	jal read_str
	jal strlen

	move $a0, $v0
	jal valcheck

	la $a0, enter_prompt
	jal print_str

	jal read_str
	jal strlen

	move $a0, $v0
	jal valcheck

############################################  EXIT #######
exit:
	li $v0, 10
	syscall

############################################  PRINT_STR ##
print_str:
	# a0: address of buffer to print
	li $v0, 4
	syscall
	jr $ra

############################################  PRINT_INT ##
print_int:
	# a0: int to print
	li $v0, 1
	syscall
	jr $ra

############################################  PRINT_CHAR #
print_char:
	# a0: char to print
	li $v0, 11
	syscall
	jr $ra

############################################  READ_STR ###
read_str:
	la $a0, input_buffer
	li $a1, 128
	li $v0, 8
	syscall
	jr $ra

############################################  READ_CHAR ##
read_char:
	li $v0, 12
	syscall
	jr $ra

############################################  STRLEN #####
strlen:
	# $a0: address of the input buffer
	# $v0: length of the string
	li $t0, 0	# len
	move $t2, $a0	# storing return address on the stack
	sub $sp, $sp, 4
	sw $ra, ($sp)
	li $t3, 0xA	# line feed

	strlen_while:
		lb $t1, ($t2)
		beqz $t1, strlen_while_break
		beq $t1, $t3, strlen_while_break
		addi $t0, $t0, 1
		addi $t2, $t2, 1
		j strlen_while

strlen_while_break:
	lw $ra, ($sp)
	addiu $sp, $sp, 4
	move $v0, $t0
	jr $ra

############################################  VALCHECK ###
valcheck:
	move $t0, $a0
	la $a0, valcheck_str
	li $v0, 4
	syscall
	move $a0, $t0
	li $v0, 1
	syscall
	la $a0, newline
	li $v0, 4
	syscall
	jr $ra

############################################  LMAO #######
lmao:
	la $a0, lmao_str
	li $v0, 4
	syscall
	jr $ra

############################################  ENDL #######
endl:
	la $a0, newline
	li $v0, 4
	syscall
	jr $ra