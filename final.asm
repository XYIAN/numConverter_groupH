###########################################################################
#-->Group H (Kyle Dilbeck, Isaac Hirzel, Jennifer S Lopez, Nicole Webber)##
#-->CST237 - Class Project - Number/Base Converter#########################
#--> 3 December 2020 ######################################################
#-->
###########################################################################

.data
input_buf:	.space 129
output_buf:	.space 129

conv_vals:		.asciiz "0123456789ABCDEF"

output_msg:		.asciiz "Output: "
welcome_msg:	.asciiz "-->Group H Class Project<--\n-->Welcome to the base converter!\n\n"

enter_prompt:	.asciiz "Enter a number: "
ibase_prompt:	.asciiz "Enter the base of the input (2, 8, 10, or 16): "
obase_prompt:	.asciiz "\nEnter the desired output base (2, 8, 10, or 16) or negative number to exit: "
another_prompt:	.asciiz "\nWould you like to enter another number? (y/n): "

bad_input_err:	.asciiz "Input contains invalid digits!\n\n"
bad_base_err:	.asciiz "Invalid base!\n\n"
low_base_err:	.asciiz "Input contains digits of a higher base than specified!\n\n"


newline:		.asciiz "\n"
input_msg:		.asciiz "Input: "
lmao_str:		.asciiz "LMAO\n"
char_str:		.asciiz "Char: "
valcheck_str:	.asciiz "Val: "

.text
############################################  MAIN  #######
main:
	# cout << "Welcome to the base converter!\n\n";
	la $a0, welcome_msg
	jal print_str

	# char choice = 'y';
	li $s0, 'y'

	# while(choice == 'Y' || choice == 'y')
	main_while:

		beq $s0, 'Y', main_passthrough
		beq $s0, 'y', main_passthrough
		j main_while_break

	main_passthrough:

		# $s0: choice
		# $s1: inputBase
		# $s2: inputBase
		# $s3: i
		# $s4: min_base
		# $s5: valid_input
		# $s6: has_dec

		# int inputBase = -1;
		li $s1, -1

		# int outputBase = -1;
		li $s2, -1

		# cout << "Enter a number: ";
		la $a0, enter_prompt
		jal print_str

	main_get_input_buf:
		# cin >> input_buf;
		jal read_str
		jal endl

		# checking string length
		la $a0, input_buf
		jal strlen
		beqz $v0, main_get_input_buf

		# int len = cstr_len(input_buf);
		la $s3, input_buf

		# int min_base = 0;
		li $s4, 0

		# bool valid_input = true;
		li $s5, 1

		# if (*pos == '-')
		lb $t0, ($s3)
		bne $t0, '-', main_is_neg_pass

			# pos++;
			addiu $s3, $s3, 1

		main_is_neg_pass:

		# bool has_dec = false;
		li $s6, 0

		# while (*pos)
		main_while_pos_nez:

			lb $t0, ($s3)
			blez $t0, main_while_pos_nez_break

			# if (input_buf[i] == '.')
			bne $t0, '.', main_if_pos_ed_endif

				#la $a0, input_msg
				#jal print_str
				#jal endl

				blez $s6, main_if_has_dec_endif

					# valid_input = false;
					move $s5, $zero

					# break;
					j main_while_pos_nez_break

				main_if_has_dec_endif:
		
				# has_dec = true;
				li $s6, 1

				# pos++
				addiu $s3, $s3, 1

				# continue;
				j main_while_pos_nez
				
			main_if_pos_ed_endif:
	
			# int v = get_val(input_buf[i]);
			lb $a0, ($s3)
			jal get_val
			move $t0, $v0

			blt $t0, 16, main_if_v_gt_16_endif

				# valid_input = false;
				move $s5, $zero

				# break;
				j main_while_pos_nez_break

			main_if_v_gt_16_endif:

			# v++
			addi $t0, $t0, 1

			# if (v > min_base)
			ble $t0, $s4, main_if_vpo_gt_min_base_endif

				# min_base = v;
				move $s4, $t0

			main_if_vpo_gt_min_base_endif:

			addiu $s3, $s3, 1

			j main_while_pos_nez

		main_while_pos_nez_break:

		# if (!valid_input)
		bgtz $s5, main_if_not_valid_input_endif

			# std::cout << "Input contains invalid digits!\n\n";
			la $s0, bad_input_err
			jal print_str

			# continue;
			j main_while

		main_if_not_valid_input_endif:

	# ask_input_base
	main_ask_input_base:

		# cout << "Enter the base of the input (2, 8, 10, or 16): ";
		la $a0, ibase_prompt
		jal print_str

		# cin >> inputBase;
		jal read_int
		move $s1, $v0

		# if (!base_valid(inputBase))
		move $a0, $s1
		jal base_is_valid
		move $t0, $v0
		beq $t0, 1, main_if_not_base_valid_endif

			# cout << "Invalid base!\n\n";
			la $a0, bad_base_err
			jal print_str

			# goto ask_input_base;
			j main_ask_input_base

		main_if_not_base_valid_endif:

		# if (inputBase < min_base)
		ble $s4, $s1, main_if_ibase_lt_min_base_endif

			# cout << "Input contains digits of a higher base than specified!\n\n";
			la $a0, low_base_err
			jal print_str

			# goto ask_input_base;
			j main_ask_input_base

		main_if_ibase_lt_min_base_endif:

		# while (1)
		main_output_while:

			# cout << "\nEnter the desired output base (2, 8, 10, or 16) or negative number to exit: ";
			la $a0, obase_prompt
			jal print_str

			# cin >> outputBase;
			jal read_int
			move $s2, $v0

			# if (outputBase < 0)
			bgez $s2, main_if_obase_ltz_endif

				# break;
				j main_output_while_break

			main_if_obase_ltz_endif:


			# else if (!base_valid(outputBase))
			move $a0, $s2
			jal base_is_valid
			move $t0, $v0
			bgtz $v0, main_if_obase_is_valid_endif

				# cout << "Invalid base!\n\n";
				la $a0, bad_base_err
				jal print_str

				# continue;
				j main_output_while

			main_if_obase_is_valid_endif:


			# if (inputBase == 10 || outputBase == 10)
			beq $s1, 10, main_dec_conversion
			beq $s2, 10, main_dec_conversion
			j main_base_shift_conversion

			main_dec_conversion:

				# decimalTo(output_buf, toDecimal(input_buf, inputBase), outputBase);
				move $a0, $s1
				jal to_decimal
				mov.s $f12, $f0
				move $a0, $s2
				jal decimal_to

			j main_end_conversion
			# else
			main_base_shift_conversion:

				# toBinary(output_buf, input_buf, inputBase);
				move $a0, $s1
				jal to_binary

				# binaryTo(output_buf, output_buf, outputBase);
				move $a0, $s2
				jal binary_to

			main_end_conversion:

			# cout << "Output: " << output_buf << "\n";
			la $a0, output_buf
			jal print_str
			jal endl

			j main_output_while

		main_output_while_break:

		# cout << "\nWould you like to enter another number?(y/n) ";
		la $a0, another_prompt
		jal print_str
		
		# cin >> choice;
		jal read_char
		move $s0, $v0

		# cout << "\n";
		jal endl

		j main_while

	main_while_break:

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
	la $t0, input_buf

	read_str_while:

		lb $t1, ($t0)
		blt $t1, 33, read_str_while_break
		addiu $t0, $t0, 1

		j read_str_while

	read_str_while_break:

	sb $zero, ($t0)
	jr $ra

############################################  READ_INT  ###

read_int:

	li $v0, 5
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
		blez $t3, get_val_return

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
	s.s $f21,	0($sp)	# offset: used for indexing string

	# int base = arg0;
	move $s0, $a0

	# float output = 0;
	mtc1 $zero, $f20

	# len = 0;
	li $s2, 0

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
	
	to_decimal_sign_gez:

	#const char* p = pos;
	move $t0, $s3

	# while()
	to_decimal_while_p:

		lb $t1, ($t0)
		blez $t1, to_decimal_while_p_break
		beq $t1, '.', to_decimal_while_p_break

		# len++;
		addi $s2, $s2, 1

		# p++;
		addiu $t0, $t0, 1

		j to_decimal_while_p

	to_decimal_while_p_break:


	# float offset = to_exp(base, len - 1);
	move $a0, $s0
	move $a1, $s2
	sub $a1, $a1, 1
	jal to_exp
	mtc1 $v0, $f4
	cvt.s.w $f21, $f4

	#while (*pos)
	to_decimal_while_pos:

		lb $t0, ($s3)
		beqz $t0, to_decimal_while_pos_break

		# if (*pos != '.')
		beq $t0, '.', to_decimal_while_pid_endif
		
			# float val = get_val(*pos);
			lb $a0, ($s3)
			jal get_val
			mtc1 $v0, $f4
			cvt.s.w $f4, $f4

			# output += val * offset;
			mul.s $f4, $f4, $f21
			add.s $f20, $f20, $f4

			# offset /= base;
			mtc1 $s0, $f4
			cvt.s.w $f4, $f4
			div.s $f21, $f21, $f4

			# len--;
			sub $s2, $s2, 1

		to_decimal_while_pid_endif:

		# pos++
		addi $s3, $s3, 1
		j to_decimal_while_pos

	to_decimal_while_pos_break:

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
	s.s $f21,	0($sp)
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
	subu $sp, $sp, 16
	sw $ra,		12($sp) # return address
	sw $s0,		 8($sp) # base
	sw $s1,		 4($sp) # ipos
	sw $s2,		 0($sp) # opos
	
	# initializing variables
	move $s0, $a0
	la $s1, input_buf
	la $s2, output_buf

	# int tmp = 1;
	li $t0, 1

	# switch (base)
	beq $s0, 16, to_binary_base_16
	beq $s0, 8, to_binary_base_8
	j to_binary_base_default

	# case 16:
to_binary_base_16:

	#tmp++
	addi $t0, $t0, 1

	#case 8:
to_binary_base_8:

	#tmp += 2
	addi $t0, $t0, 2

to_binary_base_default:

	#base = tmp;
	move $s0, $t0

	# const char* ipos = in;
	la $s1, input_buf

	# char* opos = out;
	la $s2, output_buf

	# if (*ipos == '-')
	lb $t0, ($s1)
	bne $t0, '-', to_binary_if_ipos_em_break

		# *opos = '-';
		sb $t0, ($s2)

		# opos++;
		addiu $s2, $s2, 1

		# ipos++;
		addiu $s1, $s1, 1

	to_binary_if_ipos_em_break:

	# while (*ipos)
	to_binary_while_ipos_gtz:

		lb $t0, ($s1)

		# if (*ipos == '\n' || *ipos == 0) break;
		beq $t0, '\n', to_binary_while_ipos_gtz_break
		blez $t0, to_binary_while_ipos_gtz_break

		# if (*ipos == '.')
		bne $t0, '.', to_binary_if_ipos_ed_else

			# *opos = *ipos;
			sb $t0, ($s2)

			# opos++;
			addiu $s2, $s2, 1

		j to_binary_if_ipos_ed_endif
		to_binary_if_ipos_ed_else:

			# int val = get_val(*ipos);
			lb $a0, ($s1)
			jal get_val
			move $t0, $v0

			# char* p = opos + base - 1;
			addu $t1, $s2, $s0
			subu $t1, $t1, 1

			# while (val > 0)
			to_binary_while_val_gz:

				blez $t0, to_binary_while_val_gz_break

				# *p = conv_vals[val % 2];
				li $t2, 2
				div $t0, $t2
				mfhi $t2
				# val /= 2;
				mflo $t0
				la $t3, conv_vals
				addu $t2, $t2, $t3 # t2 is now conv_vals offset
				lb $t3, ($t2)
				sb $t3, ($t1)

				# p--;
				subu $t1, $t1, 1

				j to_binary_while_val_gz

			to_binary_while_val_gz_break:

			# while (p >= opos)
			to_binary_while_p_gtoet_opos:

				blt $t1, $s2, to_binary_while_p_gtoet_opos_break

				# *p = '0';
				li $t0, '0'
				sb $t0, ($t1)
				
				# p--;
				subu $t1, $t1, 1

				j to_binary_while_p_gtoet_opos

			to_binary_while_p_gtoet_opos_break:

			# opos += base;
			addu $s2, $s2, $s0


		to_binary_if_ipos_ed_endif:

		# ipos++;
		addiu $s1, $s1, 1

		j to_binary_while_ipos_gtz

	to_binary_while_ipos_gtz_break:

	# *opos = 0;
	li $t0, 0
	sb $t0, ($s2)

	# returning data to stack

	lw $ra,		12($sp) # return address
	lw $s0,		 8($sp) # base
	lw $s1,		 4($sp) # ipos
	lw $s2,		 0($sp) # opos
	addiu $sp, $sp, 16
	jr $ra

#########################################################################
#																		#
#							  BINARY_TO									#
#																		#
#########################################################################

binary_to:
	# $a0: base of conversion
	subu $sp, $sp, 156
	sw $ra,		152($sp) # return address
	sw $s0,		148($sp) # bpd
	sw $s1,		144($sp) # val
	sw $s2,		140($sp) # tpos
	sw $s3,		136($sp) # p
	sw $s4,		132($sp) # mag
	sw $s5,		128($sp) # opos

	# int bpd = 1;
	li $s0, 1

	# switch (base)
	beq $a0, 16, binary_to_base_16
	beq $a0, 8, binary_to_base_8
	j binary_to_base_default

	# case 16:
binary_to_base_16:
	addi $s0, $s0, 1

	# case 8:
binary_to_base_8:
	addi $s0, $s0, 2

binary_to_base_default:

	# char* tpos = tmp;
	move $s2, $sp

	# const char* ipos = in;
	la $t0, output_buf

	# char* opos = out;
	la $s5, output_buf

	# if (*ipos == '-')
	lb $t1, ($t0)
	bne $t1, '-', binary_to_if_ipos_em_endif

		# *opos = '-';
		sb $t1, ($s5)

		# opos++;
		addiu $s5, $s5, 1

		# ipos++;
		addiu $t0, $t0, 1


	binary_to_if_ipos_em_endif:

	# const char* p = ipos;
	move $s3, $t0

	# int ulen = 0;
	li $t1, 0

	# int llen = 0;
	li $t2, 0

	# while (*p)
	binary_to_while_p_gtoez:

		lb $t3, ($s3)
		blez $t3, binary_to_while_p_gtoez_break

		# if (*p == '.')
		bne $t3, '.', binary_to_while_if_p_ed_endif

			# p++;
			addiu $s3, $s3, 1

			# break;
			j binary_to_while_p_gtoez_break

		binary_to_while_if_p_ed_endif:

		# p++;
		addiu $s3, $s3, 1

		# ulen++;
		addi $t1, $t1, 1

		j binary_to_while_p_gtoez

	binary_to_while_p_gtoez_break:
	
	# while (*p)
	binary_to_while_p_gtoez2:

		lb $t3, ($s3)
		blez $t3, binary_to_while_p_gtoez2_break

		# p++;
		addiu $s3, $s3, 1

		# llen++;
		addi $t2, $t2, 1

		j binary_to_while_p_gtoez2

	binary_to_while_p_gtoez2_break:
#############################################################
	# offset = bpd - (ulen % bpd);
	div $t1, $s0
	mfhi $t3
	sub $t3, $s0, $t3 # $t3 is now offset

	# if (offset == bpd)
	bne $t3, $s0, binary_to_offset_neq_bpd

	#  offset = 0;
	li $t3, 0

binary_to_offset_neq_bpd:

	# while (offset > 0)
	binary_to_while_offset_gtz:

		blez $t3, binary_to_while_offset_gtz_break

		# *tpos = '0';
		li $t4, '0'
		sb $t4, ($s2)

		# tpos++;
		addiu $s2, $s2, 1

		# offset--;
		sub $t3, $t3, 1

		j binary_to_while_offset_gtz

	binary_to_while_offset_gtz_break:

	# while (*ipos)
	binary_to_while_ipos_gtz:

		lb $t4, ($t0)
		blez $t4, binary_to_while_ipos_gtz_break

		# *tpos = *ipos;
		sb $t4, ($s2)

		# tpos++;
		addiu $s2, $s2, 1

		# ipos++;
		addiu $t0, $t0, 1

		j binary_to_while_ipos_gtz

	binary_to_while_ipos_gtz_break:
###############################################################
	# offset = bpd - (llen % bpd);
	div $t2, $s0
	mfhi $t3
	sub $t3, $s0, $t3 # $t3 is now offset

	# if (offset == bpd)
	bne $t3, $s0, binary_to_offset_neq_bpd2

	#  offset = 0;
	li $t3, 0

binary_to_offset_neq_bpd2:

	# while (offset > 0)
	binary_to_while_offset_gtz2:

		blez $t3, binary_to_while_offset_gtz_break2

		# *tpos = '0';
		li $t4, '0'
		sb $t4, ($s2)

		# tpos++;
		addiu $s2, $s2, 1

		# offset--;
		sub $t3, $t3, 1

		j binary_to_while_offset_gtz2

	binary_to_while_offset_gtz_break2:

	# *tpos = 0;
	sb $zero, ($s2)

	# tpos = tmp;
	move $s2, $sp

	# while (*tpos)
	binary_to_while_tpos_gtz:

		lb $t4, ($s2)
		blez $t4, binary_to_while_tpos_gtz_break

		# if (*tpos == '.')
		bne $t4, '.', binary_to_if_tpos_ed_else

			# *opos = '.';
			sb $t4, ($s5)
	
			# tpos++;
			addiu $s2, $s2, 1

			# opos++;
			addiu $s5, $s5, 1

		j binary_to_if_tpos_ed_endif
		binary_to_if_tpos_ed_else:

			# p = tpos + bpd - 1;
			addu $s3, $s2, $s0
			subu $s3, $s3, 1

			# int mag = 1;
			li $s4, 1

			# int val = 0;
			li $s1, 0

			# while (p >= tpos)
			binary_to_while_p_gtoet_tpos:

				blt $s3, $s2, binary_to_while_p_gtoet_tpos_break

				# val += get_val(*p) * mag;
				lb $a0, ($s3)
				jal get_val
				mult $v0, $s4
				mflo $t4
				add $s1, $s1, $t4

				# mag *= 2;
				sll $s4, $s4, 1

				# p--;
				subu $s3, $s3, 1

				j binary_to_while_p_gtoet_tpos

			binary_to_while_p_gtoet_tpos_break:

			# *opos = conv_vals[val];
			la $t5, conv_vals
			addu $t5, $t5, $s1
			lb $t4, ($t5)
			sb $t4, ($s5)

			# tpos += bpd;
			addu $s2, $s2, $s0

			# opos++;
			addiu $s5, $s5, 1

		binary_to_if_tpos_ed_endif:

		j binary_to_while_tpos_gtz

	binary_to_while_tpos_gtz_break:

	# *opos = 0;
	sb $zero, ($s5)

	# restoring data to stack
	lw $ra,		152($sp) # return address
	lw $s0,		148($sp) # bpd
	lw $s1,		144($sp) # val
	lw $s2,		140($sp) # tpos
	lw $s3,		136($sp) # p
	lw $s4,		132($sp) # mag
	lw $s5,		128($sp) # opos
	addiu $sp, $sp, 156

	jr $ra
