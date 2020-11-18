# Kyle Dilbeck , Isaac Hirzel, Jennifer S Lopez, Nicole Weber
# Group H. CST237 
# Semester Project MIPS Code
#
.data
numprompt:  .asciiz "Please enter a number: "
baseprompt: .asciiz "Enter base for conversion (maximum 16) or negative number to exit: "
digits:     .asciiz "0123456789ABCDEF"
newline:    .asciiz "\n"
buffer:     .space 65   # max size of number + 1 for null termination
.text
main:
    la $a0, numprompt
    jal print_str
    jal read_int
    move $s4, $v0   # storing number in s4
main_while:
    la $a0, baseprompt
    jal print_str
    jal read_int
    move $a0, $s4
    move $a1, $v0
    blez $a1, exit
    jal print_baseconv
    la $a0, newline
    jal print_str
    j main_while
exit:
    li $v0, 10
    syscall
#########################
print_baseconv:         # args: $a0: num to be converted, $a1: base of conversion, 
    # $s0   :   num
    # $s1   :   base
    # $s2   :   index of string/ size of output str
    # $s3   :   pos
    # $s7   :   return adddresw
    move $s7, $ra   # loading return address
    move $s0, $a0   # loading num
    move $s1, $a1   # loading base
    li $s2, 0
    
    
    print_baseconv_while:
        div $s0, $s1        # this stores num / base in lo and num % base in hi
        mflo $s0        # num /= base
        mfhi $a0        # $a0 = num % base
        jal load_char       # $v0 = digits[num % base]
        la $t0, buffer      # char *buffer = buffer;
        addu $t0, $t0, $s2  # buffer += index;
        sb $v0, 0($t0)      # buffer[index] = $v0;
        beqz $s0, end   # if(num == 0) goto end
        addi $s2, $s2, 1    # index++
        j print_baseconv_while
end:
    la $t0, buffer
    addu $t0, $t0, $s2  #going to last char in array
    
print_loop:
    lb $a0, 0($t0)
    beqz $a0, end_print_loop
    subi $t0, $t0, 1
    jal print_char
    j print_loop
end_print_loop:
    jr $s7
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
