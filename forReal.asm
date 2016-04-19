
.eqv	bpp	24
.eqv	bypp	3

.data
.byte 0
.byte 0
bmpHeader:
bmpHeader_id:
	.byte	0x42
	.byte	0x4D
bmpHeader_size:
	.word	54 # + actual data 0x
bmpHeader_reserved:
	.half	0
	.half	0
bmpHeader_dataOffset:
	.word	54 # 14+40
bmpHeader_end:

bmpInfoHeader:
bmpInfoHeader_headerSize:
	.word	40
bmpInfoHeader_bitmapPixWidth:
	.word	0
bmpInfoHeader_bitmapPixHeight:
	.word	0
bmpInfoHeader_colourPlanesCount:
	.half	1 # wiki said 1
bmpInfoHeader_colourDepth:
	.half	bpp
bmpInfoHeader_compression:
	.word	0 # no compression
bmpInfoHeader_bitmapSize:
	.word	0 # using no compression
		  # so no need to specify
bmpInfoHeader_horizontalResolution:
	.word	2835 # seems fine - 72 dpi
bmpInfoHeader_verticalResolution:
	.word	2835 # same here
bmpInfoHeader_coloursInPalette:
	.word	0 # ???
bmpInfoHeader_importantColours:
	.word	0 # ???!
bmpInfoHeader_end:

bitmap_len:
	.word	0

output_filename:
	.asciiz	"out.bmp"

prompt1:
	.asciiz "triangleNum width height = \n"
prompt2:
	.asciiz "h x0 y0 x1 y1 x2 y2 = \n"
prompt3:
	.asciiz "r g b = \n"

errorMsg_opening:
	.asciiz "Error opening file.\n"
errorMsg_writing:
	.asciiz "Error writing to file.\n"
errorMsg_io:
	.asciiz "IO Error\n"
errorMsg_sbrk:
	.asciiz "Memory alloc Error\n"

msg_exitOK:
	.asciiz "exit OK\n"

msg_endl:
	.asciiz "\n"
msg_space:
	.asciiz " "
msg_separator:
	.asciiz "\n=========\n"


a0_store:
	.word 0
a1_store:
	.word 0
a2_store:
	.word 0
a3_store:
	.word 0

trianglesLeft_store:
	.word 0

.text
	j _main

.macro read_int(%register)
	li	$v0, 5
	syscall
	move	%register, $v0
.end_macro

.macro	exit
	println(msg_exitOK)
	li	$v0, 10
	syscall
.end_macro
.macro exit(%status)
	li	$v0, 17
	li	$a0, %status
	syscall
.end_macro

.macro println_preserve(%str)
	mthi	$at
	mtlo	$a0
	la	$a0, %str
	mfhi	$at
	mthi	$v0
	addi	$v0, $0, 4
	syscall
	mflo	$a0
	mfhi	$v0
.end_macro

.macro	println(%str)
	println_preserve(%str)
.end_macro
.macro println
	println_preserve(msg_endl)
.end_macro

.macro printspace
	println_preserve(msg_space)
.end_macro

.macro printseparator
	println_preserve(msg_separator)
.end_macro

.macro printint(%r)
	mthi	$a0
	mtlo	$v0
	move	$a0, %r
	addi	$v0, $0, 1
	syscall
	mfhi	$a0
	mflo	$v0
.end_macro

.macro openfile(%filename)
	li	$v0, 13
	la	$a0, %filename
	li	$a1, 1
	li	$a2, 0
	syscall
	bltz	$v0, abort_ioError
	move	$s3, $v0
.end_macro

.macro closefile
	li	$v0, 16
	move	$a0, $s3
	syscall
.end_macro

.macro writefile(%len)
	li	$v0, 15
	move	$a0, $s3
	#la	$a1, %src
	move	$a2, %len
	syscall
	bltz	$v0, abort_ioError
.end_macro

.macro xchg(%r0 %r1)
	move 	$at, %r0
	move 	%r0, %r1
	move 	%r1, $at
.end_macro

.macro store(%what %where)
	la	$k1, %where
	sw	%what, ($k1)
.end_macro

.macro restore(%what %from)
	la	$k1, %from
	lw	%what, ($k1)
.end_macro

abort_ioError:
	la	$a0, errorMsg_io
	j 	abort_print
abort_sbrkError:
	la 	$a0, errorMsg_sbrk
	j	abort_print

abort_print:
	li	$v0, 4
	syscall
abort_abort:
	exit(-1)

_main:
	println(prompt1)

.eqv	trianglesLeft $s7
	read_int(trianglesLeft)
	store(trianglesLeft trianglesLeft_store)

	read_int($s6)	# width
	read_int($s5)	# height
	move 	$31, $s6
.eqv	width	$31

prepHeader:
	la	$t0, bmpInfoHeader_bitmapPixWidth
	sw	$s6, 0($t0)
	sw	$s5, 4($t0)
	#both width and height in header

.macro memset(%start %end %val)
	add	$s7, $0, %start
memset_begin:
	bgt	$s7, %end, memset_end	# if $t7 >= %end then memset_end
	sb	%val, ($s7)
	addi	$s7, $s7, 1			# $s7 = $s7 + 1
	j	memset_begin
memset_end:
.end_macro


allocBitmap:
#calculate row byte length
	mulu	$s4, $s6, bpp
	addi	$s4, $s4, 31
	sra	$s4, $s4, 5
	sll	$s4, $s4, 2
.eqv	row_len	$s4

	mult	row_len, $s5
	mflo	$a0
	addu	$a0, $a0, $a0
	li	$v0, 9

	la	$t7, bitmap_len
	sw	$a0, ($t7)

	syscall # some error handling #maybe
	move	$s1, $v0
	add	$v0, $a0, $v0
	addi	$a3, $0, 255			# $a0 = $0 + 255
	memset($s1 $v0 $a3)


	li	$v0, 9
	mulu	$a0, $s5, $s6
	syscall
	move	$s3, $v0

	add	$v0, $a0, $v0
	addi	$a3, $0, 255			# $a0 = $0 + 255
	memset($s3 $v0 $a3)
.eqv	bitmap	$s1
.eqv	zbuff	$s3


drawTriangles_preamble:
drawTriangles_anyLeft:
	restore(trianglesLeft trianglesLeft_store)
	beqz	trianglesLeft, drawTriangles_epilogue
	addi	trianglesLeft, trianglesLeft, -1
	store(trianglesLeft trianglesLeft_store)
drawTriangles_read:
	println(prompt2)
	read_int($t9)
.eqv	h	$t9

	read_int($t0) #x0
	read_int($t1) #y0
.eqv	x0	$t0
.eqv	y0	$t1

	read_int($t2) #x1
	read_int($t3) #y1
.eqv	x1	$t2
.eqv	y1	$t3

	read_int($t4) #x2
	read_int($t5) #x2
.eqv	x2	$t4
.eqv	y2	$t5
#maybe something more fancy than (f)unrolled bubble sort?
drawTriangles_sortStart:
	ble y1, y0, drawTriangles_no12swap
	xchg(x0 x1)
	xchg(y0 y1)
drawTriangles_no12swap:
	ble y2, y1, drawTriangles_no23swap
	xchg(y1 y2)
	xchg(x1 x2)
	j drawTriangles_sortStart
drawTriangles_no23swap:

#triangle points sorted



# width no longer in s6
	bge	x1, x0, drawTriangles_ld_one
	li	$s6, -1
	subu	$a2, x0, x1 #
	j	drawTriangles_ld_ldx_done
drawTriangles_ld_one:
	li	$s6, 1
	subu	$a2, x1, x0
drawTriangles_ld_ldx_done:
.eqv	ld_	$s6
.eqv	ldx	$a2

	bge	x2, x0, drawTriangles_rd_rdx_one
	li	$s5, -1
	subu	$a3, x0, x2
	j	drawTriangles_rd_rdx_done
drawTriangles_rd_rdx_one:
	li	$s5, 1
	subu	$a3, x2, x0
drawTriangles_rd_rdx_done:
.eqv	rd_	$s5
.eqv	rdx	$a3


.eqv	ldy	$t7
.eqv	rdy	$t8

	#TODO: check for  ldy, rdy == 0
.eqv	swap_left	$k0

	xor	$28, $28, $28
	xor	$30, $30, $30
	beqz	ldy, drawTriangles_lxCheck_ldyZero

	div	ldx, ldy		# ldx / rdx
	mflo	$28			# $28 = floor(ldx / rdx)
	mfhi	$29			# $29 = ldx mod rdx
drawTriangles_lxCheck_ldyZero:

	beqz	rdy, drawTriangles_rxCheck_rdyZero

	div	rdx, rdy		# rdx / rdy
	mflo	$30			# $30 = floor(rdx / rdy)
	mfhi	$k1			# $k1 = rdx mod rdy
drawTriangles_rxCheck_rdyZero:

	sle	swap_left, $30, $28

	println(prompt3)
	read_int($28) # R
	read_int($29) # G
	read_int($30) # B

	beqz	swap_left, drawTriangles_init_swap_right
	subu	rdy, y2, y0 #TODO: this still may be fishy
	subu	ldy, y1, y0
	j	drawTriangles_init_swap_done
drawTriangles_init_swap_right:
	subu	rdy, y1, y0
	subu	ldy, y2, y0
	#xchg(ldy rdy)
	#xchg(ldx rdx)
drawTriangles_init_swap_done:

.macro absMyWay(%v)
	sra	$at, %v, 31
	xor	%v, %v, $at
	subu	%v, %v, $at
.end_macro

	absMyWay(ldy)
	absMyWay(rdy)

	absMyWay(ldx)
	absMyWay(rdx)

.eqv	lD_	$a0
.eqv	rD_	$a1

	addu	lD_, ldx, ldx
	subu	lD_, lD_, ldy
	#addu	lD_, ldy, ldy
	#subu	lD_, lD_, ldx

	addu	rD_, rdx, rdx
	subu	rD_, rD_, rdy
	#addu	rD_, rdy, rdy
	#subu	rD_, rD_, rdx

.eqv	rx	$v0
.eqv	lx	$v1
	or	rx, $0, x0
	or	lx, $0, x0

	addu	rdy, rdy, rdy
	addu	ldy, ldy, ldy
.eqv	ldy2	$t7
.eqv	rdy2	$t8

	addu	ldx, ldx, ldx
	addu	rdx, rdx, rdx
.eqv	ldx2	$a2
.eqv	rdx2	$a3
# lD, rD, ldx, dy ready


.eqv	cur_y	$t6

.macro lD_loop
lD_loop_begin:
	blez	lD_, lD_loop_end
	debug_dump
	addu	lx, lx, ld_
	subu	lD_, lD_, ldy2
	j	lD_loop_begin
lD_loop_end:
.end_macro

.macro rD_loop
rD_loop_begin:
	blez	rD_, rD_loop_end
	debug_dump
	addu	rx, rx, rd_
	subu	rD_, rD_, rdy2
	j	rD_loop_begin
rD_loop_end:
.end_macro

.macro drawline(%y %xstart %xend)
drawline_prologue:
	store($a0 a0_store)
	store($a1 a1_store)
	store($a2 a2_store)
	store($a3 a3_store)

	# a0, a1 free
	# s5, s6 free
	xor	$a3, $a3, $a3
	blt	%xstart, %xend, drawline_noswap
	addi	$a3, $0, 1
	xchg	(%xstart %xend)
drawline_noswap:

	mulu	$s2, row_len, %y
.eqv	y_offset	$s2

	mulu	$s7, width, %y
	addu	$s7, $s7, %xstart
	addu	$s7, $s7, zbuff
.eqv	zbuff_ptr	$s7


	addu	y_offset, y_offset, bitmap
	addu	$a0, %xstart, %xstart
	addu	$a0, $a0, %xstart
	addu	$a0, $a0, y_offset

	addu	$a1, %xend, %xend
	addu	$a1, $a1, %xend
	addu	$a1, $a1, y_offset

.eqv	cur_x	$a0
.eqv	end_x	$a1

drawline_draw:
	bgt	cur_x, end_x, drawline_epilogue
	lb	$a2, (zbuff_ptr)
	bgt	$a2, h, drawline_nextPix	# if $a2 > h then drawline_nextPix

	sb	$28, 2(cur_x)
	sb	$29, 1(cur_x)
	sb	$30, 0(cur_x)

	sb	h, (zbuff_ptr)

drawline_nextPix:
	addiu	zbuff_ptr, zbuff_ptr, 1
	addiu	cur_x, cur_x, 3
	j	drawline_draw

drawline_epilogue:
	beqz	$a3, drawline_epilogue_noswap
	xchg(%xstart %xend)
drawline_epilogue_noswap:
	restore($a0 a0_store)
	restore($a1 a1_store)
	restore($a2 a2_store)
	restore($a3 a3_store)
.end_macro

drawTriangles_mainLoop1:
	or	cur_y, $0, y0

.macro printcoords
	println
	printint(x0)
	printspace
	printint(y0)
	println
	printint(x1)
	printspace
	printint(y1)
	println
	printint(x2)
	printspace
	printint(y2)
	println
.end_macro
	printcoords
.macro debug_dump
	println
	printint(cur_y)
	println
	printint(lx)
	printspace
	printint(rx)
	println
	println
	printint(lD_)
	printspace
	printint(rD_)
	println
	println
.end_macro

	#plot
	#debug_dump
	#printseparator
#xor	lD_, lD_, lD_
#xor	rD_, rD_, rD_

	beq		cur_y, y1, drawTriangles_pivot	# if cur_y == y1 then drawTriangles_pivot


	drawline(cur_y lx rx)
	lD_loop
	rD_loop
	addi	cur_y, cur_y, -1

.macro rdxdebug
	printint(rdx)
	printspace
	printint(rdx)
	printspace
	printint(rdx)
	printspace
	printint(rdx)
	printspace
	printint(rdx)
	printspace
	printint(ldx)
	printspace
.end_macro

drawTriangles_mainLoop1_begin:
	ble	cur_y, y1, drawTriangles_pivot

	#debug_dump
	drawline(cur_y lx rx)
	rdxdebug
	#printseparator

	addu	lD_, lD_, ldx2
	lD_loop

	addu	rD_, rD_, rdx2
	rD_loop

	addi	cur_y, cur_y, -1


	j drawTriangles_mainLoop1_begin

drawTriangles_pivot:
#printseparator
#printseparator
	beq	y2, y1, drawTriangles_mainLoop2_onlyOneLine

#j drawTriangles_pivot_swapLeft
	beqz	swap_left, drawTriangles_pivot_swapRight
printseparator
printseparator
	subu	ldy, y1, y2

	bge	x1, x2, drawTriangles_pivot_swapLeft_minusOne
drawTriangles_pivot_swapLeft:
	ori	ld_, $0, 1
	subu	ldx, x2, x1
	addu	lx, $0, x1
	j	drawTriangles_pivot_swapLeft_done

drawTriangles_pivot_swapLeft_minusOne:
	ori	ld_, $0, -1
	subu	ldx, x1, x2
	addu	lx, $0, x1
drawTriangles_pivot_swapLeft_done:
	addu 	lD_, ldx, ldx
	addu 	lD_, lD_, ldy
	xor	lD_, lD_, lD_

	addu	ldy2, ldy, ldy
	addu	ldx2, ldx, ldx
	#absMyWay(ldx)
	j	drawTriangles_pivot_done

drawTriangles_pivot_swapRight:
printseparator
	subu	rdy, y1, y2

	bge	x1, x2, drawTriangles_pivot_swapRight_miniusOne
	ori	rd_, $0, 1
	subu	rdx, x2, x1
	addu	rx, $0, x1
	j	drawTriangles_pivot_swapRight_done

drawTriangles_pivot_swapRight_miniusOne:
	ori	rd_, $0, -1
	subu	rdx, x1, x2
	add	rx, $0, x1
drawTriangles_pivot_swapRight_done:
	addu 	rD_, rdx, rdx
	addu 	rD_, rD_, rdy
	xor	rD_, rD_, rD_

	addu	rdy2, rdy, rdy
	addu	rdx2, rdx, rdx

drawTriangles_pivot_done:
	absMyWay(rdy2)
	absMyWay(rdx2)
drawTriangles_pivot_epilogue:

drawTriangles_mainLoop2:
drawTriangles_mainLoop2_begin:
	ble	cur_y, y2, drawTriangles_mainLoop2_exit

	debug_dump
	drawline(cur_y lx rx)
	rdxdebug
	printseparator

	addu	lD_, lD_, ldx2
	lD_loop

	addu	rD_, rD_, rdx2
	rD_loop

	addi	cur_y, cur_y, -1

	j	drawTriangles_mainLoop2_begin
drawTriangles_mainLoop2_onlyOneLine:
	drawline(cur_y x1 x2)
drawTriangles_mainLoop2_exit:
drawTriangles_currentTriangleDone:
	xor	$28, $28, $28
	xor	$29, $29, $29
	xor	$30, $30, $30

	ori	h, $0, 999
	drawline(y0, x0, x0)
	drawline(y1, x1, x1)
	drawline(y2, x2, x2)

	j drawTriangles_anyLeft
drawTriangles_epilogue:


writeEverything:
writeEverything_actualWriting:
	openfile(output_filename)
	la	$t0, bmpInfoHeader_end
	la	$t1, bmpHeader
	subu	$t0, $t0, $t1

	la	$a1, bmpHeader
	writefile($t0)

	la	$a1, bitmap_len
	lw	$s2, ($a1)

	move	$a1, bitmap
	writefile($s2)

	closefile

writeEverything_end:
	exit
