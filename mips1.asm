.data
	input:	.space 128
	prompt:	.asciiz	"\ninput> "
	msg1:	.asciiz	"\noutput> "
	
.text

.macro readln(%location)
	li $v0, 8
	la $a0, %location
	syscall
.end_macro

.macro writeln(%location)
	li $v0, 4
	la $a0, %location
	li $a1, 128
	syscall
.end_macro

.macro terminate
	li $v0, 10
	syscall
.end_macro


main:
	writeln(prompt)
	readln(input)
	
starReplace_start:
	la	$t0, input
	
	li	$t5, 'a'
	li	$t6, 'z'

starReplace_loop:
	lb	$t2, ($t0)
	beqz	$t2, starReplace_end
	
	
starReplace_replace:
	bgt	$t2, $t6, starReplace_nextIteration
	blt	$t2, $t5, starReplace_nextIteration
	addi	$t2, $0, 42
	sb	$t2, ($t0)

starReplace_nextIteration:
	addi	$t0, $t0, 1
	
	j	starReplace_loop
starReplace_end:
	
	writeln(input)
	terminate
	
readln:
	#li $v0, 8
	#la $a0, input
	#li $a1, 128
	#syscall
	
println:
	#li $v0, 4
	#la $a0, input
	#syscall
	
exit:
	li $v0, 10
	syscall