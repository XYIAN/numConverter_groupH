# Kyle Dilbeck , Isaac Hirzel, Jennifer S Lopez, Nicole Weber
# Group H. CST237 
# Semester Project MIPS Code
#
.data
numprompt:  .asciiz "Please enter a number: "
baseprompt: .asciiz "Enter base for conversion (maximum 16) or negative number to exit: "
prompt1: .asciiz "Would you like to convert the same number to a new base?(Y/N)"
prompt2: .asciiz "Would you like to convert a new number?(Y/N)"
digits:     .asciiz "0123456789ABCDEF"
newline:    .asciiz "\n"
buffer:     .space 65   # max size of number + 1 for null termination
.text
main:
#get user number
#get number base 
#convert to binary
#get new base desired
#output in new base 
#prompt for new base conversion y/n
#prompt for new number conversion if no new base conversion 
    	
mainOuterWhile:
	la $a0, numprompt
    	jal print_str
    	jal read_int
    	move $s4, $v0   # storing number in 
    	
    	
mainInnerWhile:
##########TO DO FUNCTIONS###############
#convert decimal to binary
decimaltobinary:
#convert octal to binary 
octaltobinary:
#convert hex to binary 
hextobinary:
#convert binary to any given base
binaryConverter:
	#read user input for base type to convert
	 
	#convert binary to decimal 
		#return result in decimal 
	#convert binary to octal
		#return result in octal
	#convert binary to hex 
		#return result in hex  	
		
#####################
read_int:
    li $v0, 5
    syscall
    jr $ra
######################
load_char:
    la $t0, digits      # loading address of digits into $t0
    addu $t0, $t0, $a0  # adding number in arg to 
    lb $v0, 0($t0)
    jr $ra
#######################
print_char:
    la $v0, 11
    syscall
    jr $ra
#######################
print_str:          # $a0: address of string
    li $v0, 4
    syscall
    jr $ra
#######################
		