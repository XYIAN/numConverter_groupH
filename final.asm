.data
input_buf:	.space 129
output_buf:	.space 129
newline:	.asciiz "\n"

conv_vals:		.asciiz "0123456789ABCDEF"

enter_prompt:	.asciiz "Enter a number: "
input_msg:		.asciiz "Input: "
output_msg:		.asciiz "Output: "
lmao_str:		.asciiz "LMAO\n"
char_str:		.asciiz "Char: "
valcheck_str:	.asciiz "Val: "

.text
############################################  MAIN  #######
main:
	# printing prompt for input
	la $a0, enter_prompt
	jal print_str
	jal read_str
	
	# calculating float for base 8 input
	li $a0, 16
	jal to_decimal
	mov.s $f20, $f0

	# printing output in decimal
	la $a0, output_msg
	jal print_str
	mov.s $f12, $f20
	jal print_float
	jal endl

	# converting output to decimal string
	li $a0, 2
	mov.s $f12, $f20
	jal decimal_to

	# printing output
	la $a0, output_msg
	jal print_str
	jal print_str
	la $a0, output_buf
	jal print_str
	jal endl

	# exiting
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
	move $t9, $a0
	la $a0, valcheck_str
	li $v0, 4
	syscall
	move $a0, $t9
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
#						  		TO_DECIMAL								#
#																		#
#########################################################################

to_decimal:
	# storing data on stack
	subu $sp, $sp, 32
	sw $ra,		28($sp)	# return address
	s.s $f20,	24($sp) # output: value of output
	sw $s0,		20($sp)	# base: base converting from
	sw $s1,		16($sp)	# dec_spaces: decimal spaces of input
	sw $s2,		12($sp)	# len: length of input_buf
	sw $s3,		8($sp)	# pos: address of current char
	sw $s4,		4($sp)	# sign: sign of input/output value
	sw $s5,		0($sp)	# offset: used for indexing string

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
	lb $t0, ($s3)
	xori $s4, $t0, '-'
	beqz $s4, to_decimal_is_zero
	li $s4, 1
to_decimal_is_zero:
	li $t0, 2
	mult $s4, $t0
	mflo $s4
	sub $s4, $s4, 1

	# if (sign < 0)
	bgez $s4, to_decimal_sign_gez
	# pos++;
	addiu $s3, $s3, 1
	# len--;
	sub $s2, $s2, 1
to_decimal_sign_gez:

	# int offset = to_exp(base, len - 1);
	move $a0, $s0
	move $a1, $s2
	sub $a1, $a1, 1
	jal to_exp
	move $s5, $v0

	#while (*pos)
	to_decimal_while_pos:
		lb $t0, ($s3)
		beqz $t0, to_decimal_while_pos_break

		# if (*pos == '.')
		bne $t0, '.', to_decimal_while_if_pid_else
		# dec_spaces = len;
		move $s1, $s2
		j to_decimal_while_pid_endif

		# else
	to_decimal_while_if_pid_else:
		
		# float val = get_val(*pos);
		lb $a0, ($s3)
		jal get_val
		mtc1 $v0, $f4
		cvt.s.w $f4, $f4

		# output += val * offset;
		mtc1 $s5, $f5
		cvt.s.w $f5, $f5
		mul.s $f4, $f4, $f5
		add.s $f20, $f20, $f4

		# offset /= base;
		div $s5, $s0
		mflo $s5

		# len--;
		sub $s2, $s2, 1

	to_decimal_while_pid_endif:

		# pos++
		addi $s3, $s3, 1
		j to_decimal_while_pos

to_decimal_while_pos_break:

	#offset = to_exp(base, dec_spaces);
	move $a0, $s0
	move $a1, $s1
	jal to_exp
	move $s5, $v0

	#output /= offset;
	mtc1 $s5, $f4
	cvt.s.w $f4, $f4
	div.s $f20, $f20, $f4

	#output *= sign;
	mtc1 $s4, $f4
	cvt.s.w $f4, $f4
	mul.s $f20,  $f20, $f4

	#return output;
	mov.s $f0, $f20

	# returning space to stack
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

#########################################################################
#																		#
#							  DECIMAL_TO								#
#																		#
#########################################################################

decimal_to:
	# $a0: base of conversion
	# $f12: number to convert
	subu $sp, $sp, 32
	sw $ra,		28($sp)	# return address
	s.s $f20,	24($sp)	# dec
	sw $s0,		20($sp)	# base
	sw $s1,		16($sp)	# dec_spaces
	sw $s2,		12($sp)	# len
	sw $s3,		8($sp)	# pos
	sw $s4,		4($sp)	# sign
	sw $s5,		0($sp)	# offset

	# initializing variables
	move $s0, $a0
	mov.s $f20, $f12

	#if (dec == 0.0)
	mtc1 $zero, $f4
	c.eq.s $f20, $f4
	bc1f decimal_to_dec_nez
	la $t0, output_buf

	#	out[0] = '0';
	li $t1, '0'
	sb $t1, 0($t0)

	#	out[1] = 0;
	li $t1, 0
	sb $t1, 1($t0)

	# return;
	j decimal_to_return

decimal_to_dec_nez:

	#int sign = (dec >= 0) * 2 - 1;
	mtc1 $zero, $f4
	c.le.s $f4, $f20
	li $s4, 0
	bc1t decimal_to_dec_gez
	j decimal_to_sign_calc

	decimal_to_dec_gez:

		li $s4, 1

	decimal_to_sign_calc:

	sll $s4, $s4, 1
	sub $s4, $s4, 1

	#char* pos = out;
	la $s3, output_buf

	#if (sign < 0)
	bgez $s4, decimal_to_sign_nltz
	
		# *pos = '-';
		li $t0, '-'
		sb $t0, ($s3)

		#	pos++;
		addi $s3, $s3, 1

	decimal_to_sign_nltz:

	# dec *= sign;
	mtc1 $s4, $f4
	cvt.s.w $f4, $f4
	mul.s $f20, $f20, $f4

	# int dec_spaces = 0;
	li $s1, 0

	# while (dec - (int)dec > 0)
	decimal_to_while_dmugz:

		cvt.w.s $f4, $f20
		cvt.s.w $f4, $f4
	
		sub.s $f4, $f20, $f4
		mtc1 $zero, $f5
		c.le.s $f4, $f5
		bc1t decimal_to_while_dmugz_break

		# dec *= base;
		mtc1 $s0, $f4
		cvt.s.w $f4, $f4
		mul.s $f20, $f20, $f4

		# dec_spaces++;
		addi $s1, $s1, 1

		j decimal_to_while_dmugz

	decimal_to_while_dmugz_break:

	# unsigned val = dec;
	cvt.w.s $f4, $f20
	mfc1 $t0, $f4

	#int len = 0;
	li $s2, 0

	#while (val > 0)
	decimal_to_while_val_gz:

		blez $t0, decimal_to_while_val_gz_break

		# val /= base;
		div $t0, $s0
		mflo $t0

		# len++;
		addi $s2, $s2, 1

		j decimal_to_while_val_gz

	decimal_to_while_val_gz_break:

	# int offset = to_exp(base, len - 1);
	move $a0, $s0
	sub $a1, $s2, 1
	jal to_exp
	move $s5, $v0

	# val = dec;
	cvt.w.s $f4, $f20
	mfc1 $t0, $f4

	# while (len > 0)
	decimal_to_while_len_gz:

		blez $s2, decimal_to_while_len_gz_break

		# if (len == dec_spaces)
		bne $s2, $s1, decimal_to_wlgz_endif

			# *pos = '.';
			li $t1, '.'
			sb $t1, ($s3)

			# pos++;
			addiu $s3, $s3, 1

		decimal_to_wlgz_endif:
		
		# *pos = conv_vals[(val / offset) % base];
		div $t0, $s5
		mflo $t1
		div $t1, $s0
		mfhi $t1
		la $t2, conv_vals
		addu $t1, $t2, $t1
		lb $t1, ($t1)
		sb $t1, ($s3)

		# offset /= base;
		div $s5, $s0
		mflo $s5

		# pos++;
		addiu $s3, $s3, 1

		# len--;
		sub $s2, $s2, 1

		j decimal_to_while_len_gz

	decimal_to_while_len_gz_break:

	# *pos = 0;
	li $t0, 0
	sb $t0, ($s3)

decimal_to_return:

	lw $ra,		28($sp)	# return address
	l.s $f20,	24($sp)	# dec
	lw $s0,		20($sp)	# base
	lw $s1,		16($sp)	# dec_spaces
	lw $s2,		12($sp)	# len
	lw $s3,		8($sp)	# pos
	lw $s4,		4($sp)	# sign
	lw $s5,		0($sp)	# offset
	addiu $sp, $sp, 32
	jr $ra

#########################################################################
#																		#
#							  TO_BINARY									#
#																		#
#########################################################################

to_binary:
	# $a0: base of conversion
	# $a1: address of temp buffer
	# vars: outpos, base, bitsPerDigit, is_neg, len, oi, val, counter
	subu $sp, $sp, 32
	sw $ra,		($sp)
	#int bitsPerDigit = 1;
	#switch (base)
	#{
	#case 16:
	#	bitsPerDigit++;
	#case 8:
	#	bitsPerDigit += 2;
	#}

	#bool is_neg = false;
	#if (in[0] == '-')
	#{
	#	is_neg = true;
	#	out[0] = '-';
	#	out++;
	#	in++;
	#}

	#int len = cstr_len(in);
	#int outputLength = len * bitsPerDigit;
	#int oi = outputLength;
	#out[oi--] = 0;

	#for (const char *c = in + len - 1; c >= in; c--)
	#{
	#	int val = get_val(*c);
	#	int count = 0;
	#	while (val > 0)
	#	{
	#		out[oi] = conv_vals[val % 2];
	#		val /= 2;
	#		oi--;
	#		count++;
	#	}
	#	for (int i = 0; i < (bitsPerDigit - count); i++)
	#	{
	#		out[oi--] = '0';
	#	}
	#}
	#if (is_neg) out--;

	sub $sp, $sp, 4
	sw $ra, ($sp)
	lw $ra, ($sp)
	addiu $sp, $sp, 4
	jr $ra

#########################################################################
#																		#
#							  BINARY_TO									#
#																		#
#########################################################################

binary_to:
	# $a0: base of conversion
	# $a1: address of temp buffer

	# int bitsPerDigit = 1;
	# // janky optimized code that relies on jump table fallthrough so it will be easy to write in mips
	# switch (base)
	# {
	# case 16:
	# 	bitsPerDigit++;
	# case 8:
	# 	bitsPerDigit += 2;
	# }

	# bool is_neg = false;
	# if (in[0] == '-')
	# {
	# 	is_neg = true;
	# 	out[0] = '-';
	# 	out++;
	# 	in++;
	# }

	# // getting length of output string
	# int len = cstr_len(in);
	# int outputLength = len / bitsPerDigit;
	# // if there is a remainder digit, add 1 to output length
	# int mod = len % bitsPerDigit;
	# if (mod > 0) outputLength++;
	
	# // adding zero to end of string for termination
	# int oi = outputLength;
	# out[oi--] = 0;
	# int val = 0;
	# int counter = 0;
	# // looping through input
	# for (int i = len - 1; i >= 0; i--)
	# {
	# 	// grouping the bits of the binary string together to find value of char
	# 	int bbi = counter % bitsPerDigit;
	# 	val += get_val(in[i]) << bbi;
	# 	// if loop is finished or finished with most recent group of bits
	# 	if (bbi == bitsPerDigit - 1 || i == 0)
	# 	{
	# 		// adding char to string and incrementing
	# 		out[oi] = conv_vals[val];
	# 		oi--;
	# 		val = 0;
	# 	}
	# 	counter++;
	# }
	# if (is_neg) out--;

	sub $sp, $sp, 4
	sw $ra, ($sp)
	lw $ra, ($sp)
	addiu $sp, $sp, 4
	jr $ra
