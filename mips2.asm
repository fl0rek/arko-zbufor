.eqv	zbuff_len 307200
.eqv	scene_len 230400

.eqv	in_buff_len 128

.data
	in_fname:	.asciiz	"opis.txt"
	
	in_buff:	.space in_buff_len
	
	test_buff:	.space in_buff_len
	
	scene:	.space scene_len
	zbuff:	.space zbuff_len
	
.text
j main

.macro writeln(%location)
	li 	$v0, 4
	la 	$a0, %location
	li 	$a1, 128
	syscall
.end_macro

.macro terminate
	li 	$v0, 10
	syscall
.end_macro

.macro atoi_nextChar
	addiu	$a0, $a0, 1
	subiu	$a1, $a1, 1
.end_macro

#	a0 src_from
#	a1 src_len
atoi:
	move	$v0, $0
	
atoi_iter:
	lb 	$t1, ($a0)
	beq	$t1, ' ', atoi_epilogue
	
	subi	$t1, $t1, '0'
	mulou	$v0, $v0, 10 # TODO: fix costly mul
	addu	$v0, $v0, $t1
	
	atoi_nextChar
	
	j atoi_iter
atoi_epilogue:
	jr $ra
	
	

#	byte by byte copy
#	a0 - src_from
#	a1 - src_to
#	a3 - dest

memcpy:
	bge	$a0, $a1, memcpy_epilogue
	
	lb	$t1, ($a0)
	sb	$t1, ($a3)
	
	addi	$a0, $a0, 1
	addi	$a3, $a3, 1
	j	memcpy
	
memcpy_epilogue:
	jr $ra
	
#	a0 - x0
#	a1 - y0 = y
#	a2 - x1
#	a3 - y1
plotLine:
	subu	$t0, $a2, $a0	# dx
	subu	$t1, $a1, $a3	# dy
	
	addu	$t2, $t1, $t1	# 2*dy
	sub	$t3, $t2, $t0	# D
	addu	$t4, $t0, $t0	# 2*dx
	

	#+ plot x0,y0
	.macro plotLine_maybeNextY
	blez	$t2, plotLine_loop
	
	add	$a1, $a1, 1
	sub	$t2, $t2, $t4
	.end_macro
	
	plotLine_maybeNextY

plotLine_loop:
	addi	$a0, $a0, 1 # x	
	
	#+ plot x,y
	
	addu	$t3, $t3, $t2
	
	plotLine_maybeNextY
	
	ble	$a0, $a2, plotLine_loop

plotLine_epilogue:
	jr	$ra


#	a0	x0
#	a1	y0
#	a2	x1
#	a3	x2
#	t0	y1 = y2	
plotHalfTriangle:
	# 
	
	
# main =============================
main:
openInput:
	addi	$v0, $zero, 13
	la	$a0, in_fname
	addi	$a1, $zero, 0
	addi	$a2, $zero, 0
	syscall
	move	$s0, $v0
	

read:
	addi	$v0, $zero, 14
	move	$a0, $s0
	la	$a1, in_buff
	addi	$a2, $zero, 128
	syscall
	
	la	$a0, in_buff
	move	$a1, $v0
	jal	atoi
	
	atoi_nextChar
	
	#writeln(test_buff)
	
	la	$a0, in_buff
	addi	$a1, $a0, in_buff_len
	la	$a3, test_buff
	jal	memcpy
	

	
	writeln(test_buff)

closeInput:
	addi	$v0, $zero, 16
	move	$s0, $a0
	syscall

	terminate