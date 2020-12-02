.data
input_buf:	.space 129
output_buf:	.space 129
newline:	.asciiz "\n"

conv_vals:		.asciiz "0123456789ABCDEF"

enter_prompt:	.asciiz "Enter a number: "
input_msg:		.asciiz "Input: "
output_msg:		.asciiz "Output: "
lmao_str:		.asciiz "LMAO\n"
valcheck_str:	.asciiz "Val: "

.text
############################################  MAIN  #######
main:
	la $a0, enter_prompt
	jal print_str
	jal read_str
	jal to_decimal
	move $s0, $v0
	la $a0, output_msg
	jal print_str
	move $a0, $s0
	jal print_int
	jal endl

	j exit
############################################  EXIT  #######

exit:
	li $v0, 10
	syscall

############################################  PRINT_STR  ##

print_str:
	# a0: address of buffer to print
	li $v0, 4
	syscall
	jr $ra

############################################  PRINT_INT  ##

print_int:
	# a0: int to print
	li $v0, 1
	syscall
	jr $ra

############################################  PRINT_FLOAT #

print_float:
	# $f12: float to print
	li $v0, 2
	syscall
	jr $ra

############################################  PRINT_CHAR  #

print_char:
	# a0: char to print
	li $v0, 11
	syscall
	jr $ra

############################################  READ_STR  ###

read_str:
	la $a0, input_buf
	li $a1, 128
	li $v0, 8
	syscall
	jr $ra

############################################  READ_CHAR  ##

read_char:
	li $v0, 12
	syscall
	jr $ra

############################################  STRLEN  #####

strlen:		# confirmed working correctly
	# $a0: address of the input buffer
	# $v0: length of the string

	li $t0, 0		# len
	move $t2, $a0	# storing return address on the stack
	sub $sp, $sp, 4
	sw $ra, ($sp)

	strlen_while:
		lb $t1, ($t2)
		beqz $t1, strlen_while_break
		beq $t1, 0xA, strlen_while_break
		addi $t0, $t0, 1
		addi $t2, $t2, 1
		j strlen_while

strlen_while_break:
	lw $ra, ($sp)
	addiu $sp, $sp, 4
	move $v0, $t0
	jr $ra

############################################  GET_VAL  ####

get_val:	# confirmed working correctly
	# a0: char to get value of
	# v0: return value
	move $t0, $a0		# storing value for comparisons
	la $t1, conv_vals	# storing array in $t1
	li $t2, 0			# counter
	get_val_while:
		lb $t3, ($t1)
		beq $t3, 0, get_val_return
		beq $t3, $t0, get_val_return
		addiu $t1, $t1, 1
		addiu $t2, $t2, 1
		j get_val_while
get_val_return:
	move $v0, $t2
	jr $ra

############################################  TO_EXP  #####

to_exp:		# confirmed working correctly
	# $a0: base number
	# $a1: exponent
	move $t0, $a0
	move $t1, $a1
	li $t2, 1

	to_exp_while:
		beqz $t1, to_exp_return
		mult $t0, $t2
		mflo $t2
		sub $t1, $t1, 1
		j to_exp_while

to_exp_return:
	move $v0, $t2
	jr $ra

############################################  VALCHECK  ###

valcheck:
	# $a0: integer to print the value of
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

############################################  VALID_BASE  #

base_is_valid:
	# $a0: base of num
	beq $a0, 2, base_is_valid_true
	beq $a0, 8, base_is_valid_true
	beq $a0, 10, base_is_valid_true
	beq $a0, 16, base_is_valid_true

	li $v0, 0	# setting return value to false
	jr $ra
    
base_is_valid_true:
	li $v0, 1
	#the base is valid return to the loop
	jr $ra

############################################  LMAO  #######

lmao:
	la $a0, lmao_str
	li $v0, 4
	syscall
	jr $ra

############################################  ENDL  #######

endl:
	la $a0, newline
	li $v0, 4
	syscall
	jr $ra

#########################################################################
#																		#
#						  CONVERSION FUNCTIONS							#
#																		#
#########################################################################

############################################  TO_DECIMAL  ##
to_decimal:
	# $s0 <- $a0: base: base converting from
	# $s1: dec_spaces: decimal spaces of input
	# $s2: len: length of input_buf
	# $s3: pos: address of current char
	# $s4: sign: sign of input/output value
	# $s5: val: value of char
	# $f0: output: return value

	# storing data on stack
	subu $sp, $sp, 32
	sw $ra,		28($sp)	# return address
	s.s $f20,	24($sp) # output: value of output
	sw $s0,		20($sp)	# base: base converting from
	sw $s1,		16($sp)	# dec_spaces: decimal spaces of input
	sw $s2,		12($sp)	# len: length of input_buf
	sw $s3,		8($sp)	# pos: address of current char
	sw $s4,		4($sp)	# sign: sign of input/output value
	sw $s5,		0($sp)	# val: value of char

	# int base = arg0;
	move $s0, $a0

	# int dec_spaces = 0;
	li $s1, 0

	# float output = 0;
	mtc1 $zero, $f20

	# len = strlen(input);
	la $a0, input_buf
	jal strlen
	move $s2, $v0

	# const char* pos = input;
	la $s3, input_buf

	#int sign = (*pos != '-') * 2 - 1
	lb $s6, ($s3)
	xori $s4, $s6, '-'
	beqz $s4, to_decimal_is_zero
	li $s4, 1
to_decimal_is_zero:
	li $s6, 2
	mult $s4, $s6
	mflo $s4
	sub $s4, $s4, 1

	# if (sign < 0)
	bgez $s4, to_decimal_sign_gez

	# pos++;
	addiu $s3, $s3, 1

	# len--;
	sub $s2, $s2, 1

to_decimal_sign_gez:

	#while (*pos)
	to_decimal_while_pos:
		lb $t0, ($s3)
		beqz $t0, to_decimal_while_pos_break

		# if (*pos == '.')
		bne $t0, '.', to_decimal_while_if_pid_break
		# dec_spaces = len - 1;
		move $s1, $s2
		sub $s1, $s1, 1
		# output /= to_exp(base, len);
	to_decimal_while_if_pid_break:


		# pos++
		addiu $s3, $s3, 1
		j to_decimal_while_pos

to_decimal_while_pos_break:

	# returning data to stack
	lw $ra,		28($sp)
	l.s $f20,	24($sp)
	lw $s0,		20($sp)
	lw $s1,		16($sp)
	lw $s2,		12($sp)
	lw $s3,		8($sp)
	lw $s4,		4($sp)
	lw $s5,		0($sp)
	addiu $sp, $sp, 32
	jr $ra

############################################  DECIMAL_TO  ##
decimal_to:
	# $a0: base of conversion

	sub $sp, $sp, 4
	sw $ra, ($sp)
	lw $ra, ($sp)
	addiu $sp, $sp, 4
	jr $ra

############################################  TO_BINARY  ###
to_binary:
	# $a0: base of conversion
	# $a1: address of temp buffer
	sub $sp, $sp, 4
	sw $ra, ($sp)
	lw $ra, ($sp)
	addiu $sp, $sp, 4
	jr $ra

############################################  BINARY_TO  ###
binary_to:
	# $a0: base of conversion
	# $a1: address of temp buffer
	sub $sp, $sp, 4
	sw $ra, ($sp)
	lw $ra, ($sp)
	addiu $sp, $sp, 4
	jr $ra
