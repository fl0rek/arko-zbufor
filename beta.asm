.data

.eqv	bpp	24
.eqv	bypp	3

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

prompt1:
	.asciiz "triangleNum width height = \n"
prompt2:
	.asciiz "h x0 y0 x1 y1 x2 y2 = \n"
prompt3:
	.asciiz "r g b = \n"
	
msg_exitOK:
	.asciiz "exit OK\n"
msg_endl:
	.asciiz "\n"
msg_space:
	.asciiz " "

errorMsg_opening:
	.asciiz "Error opening file.\n"
errorMsg_writing:
	.asciiz "Error writing to file.\n"
errorMsg_io:
	.asciiz "IO Error\n"
	
output_filename:
	.asciiz	"out.bmp"
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

.macro	println(%str)
	li	$v0, 4
	la	$a0, %str
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

.macro println
	println_preserve(msg_endl)
.end_macro

.macro printspace
	println_preserve(msg_space)
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

#pay no regard to preserving registers, 
#we're bailing out anyway
abort_ioError:
	la	$a0, errorMsg_io
	j abort_print
abort_print:
	li	$v0, 4
	syscall
abort_abort:
	exit(-1)
	
_main:
	println(prompt1)
	
	read_int(trianglesLeft)
.eqv	trianglesLeft $s7

	read_int($s6)	# width
	read_int($s5)	# height
.eqv	width	$s6
.eqv	height	$s5

allocBitmap:
	mulu	$s4, $s6, bpp
	addi	$s4, $s4, 31
	sra	$s4, $s4, 5
	sll	$s4, $s4, 2
.eqv	row_len	$s4


	mult	row_len, $s5
	mflo	$a0
	li	$v0, 9
	syscall # some error handling #maybe
	move	$s1, $v0
	li	$v0, 9
	syscall
	move	$s3, $v0
.eqv	bitmap	$s1
.eqv	zbuff	$s3

	move	$s2, $a0
	la	$t0, bmpHeader_size
	li	$t1, 54
	addu	$a0, $a0, $t1
	sw	$a0, ($t0)

.eqv	bitmapSize	$s2

prepHeader:
	la	$t0, bmpInfoHeader_bitmapPixWidth
	sw	$s6, 0($t0)
	sw	$s5, 4($t0)
.macro xchg(%r0 %r1) 
	move $at, %r0
	move %r0, %r1
	move %r1, $at
.end_macro 


drawTriangles_preamble:
drawTriangles_anyLeft:
	beqz	trianglesLeft, drawTriangles_epilogue
	addi	trianglesLeft, trianglesLeft, -1
drawTriangles_read:
	println(prompt2)
	read_int($t9)
	
	read_int($t0) #x0
	read_int($t1) #y0
	
	read_int($t2) #x1
	read_int($t3) #y1
	
	read_int($t4) #x2
	read_int($t5) #x2
#maybe something more fancy than (f)unrolled bubble sort?
drawTriangles_sortStart:
	bge $t3, $t1, drawTriangles_no12swap
	xchg($t1 $t3)
	xchg($t0 $t2)
drawTriangles_no12swap:
	bge $t5, $t3, drawTriangles_no23swap
	xchg($t3 $t5)
	xchg($t2 $t4)
	j drawTriangles_sortStart
drawTriangles_no23swap:
	
	println(prompt3)
	read_int($t6) # R
	read_int($t7) # G
	read_int($t8) # B
	
	sll	$t8, $t8, 8
	or	$t7, $t7, $t8
	sll	$t7, $t7, 8
	or	$t6, $t6, $t6
	sra	$t7, $t7, 8
	sra	$t8, $t8, 8
	
	# t6 = RG
	# t7 = GB
	# t8 = B

.macro printint(%r) 
	mthi	$a0
	mtlo	$v0
	move	$a0, %r
	li	$v0, 1
	syscall
	mfhi	$a0
	mflo	$v0
.end_macro

	println
	printint($t0)
	printspace
	printint($t1)
	println
	printint($t2)
	printspace
	printint($t3)
	println
	printint($t4)
	printspace
	printint($t5)

	
.macro rowload(%row)
	mult	%row, $s4
	mflo	$s2
.end_macro

.macro drawline(%from %to)
drawline_prologue:
	mthi	%from
	mtlo	%to
	
drawline_begin:
	addu	$s2, $s2, bitmap
	addu	%from, %from, $s2
	addu	%to, %to, $s2
	subu	$s2, $s2, bitmap

drawline_beginDraw:	
	bgt	%from, %to, drawline_epilogue

	andi	$at, %from, 1
	bnez	$at, drawline_unaligned
		
	sh	$t6, (%from)
	sb	$t8, 2(%from)
	j 	drawline_nextPix	
drawline_unaligned:
	sb	$t6, (%from)
	sh	$t7, 1(%from)
drawline_nextPix:
	addi	%from, %from, 3
	j	drawline_beginDraw

drawline_epilogue:
	mfhi	%from
	mflo	%to
.end_macro	
	li	$k0, 1 # swap left
	
	bge	$t2, $t0, drawTriangles_ld_one
	li	$s6, -1
	subu	$a2, $t0, $t2
	j	drawTriangles_ld_ldx_done
drawTriangles_ld_one:
	li	$s6, 1
	subu	$a2, $t2, $t0
drawTriangles_ld_ldx_done:

	bge	$t4, $t0, drawTriangles_rd_rdx_one
	li	$s5, -1
	subu	$a3, $t0, $t4
	j	drawTriangles_rd_rdx_done
drawTriangles_rd_rdx_one:
	li	$s5, 1
	subu	$a3, $t4, $t0
drawTriangles_rd_rdx_done:
	
	
	beqz	$k0, drawTriangles_init_swap_right
	subu	$ra, $t3, $t1
	subu	$fp, $t5, $t1
	j	drawTriangles_init_swap_done
drawTriangles_init_swap_right:
	subu	$ra, $t3, $t1
	subu	$fp, $t5, $t1
drawTriangles_init_swap_done:

	addu	$a0, $a2, $a2
	subu	$a0, $a0, $ra
	
	addu	$a1, $a3, $a3
	subu	$a1, $a1, $fp
	
	move	$v0, $t0
	move	$v1, $t0
	
	addu	$fp, $fp, $fp
	addu	$ra, $ra, $ra
	addu	$a2, $a2, $a2
	addu	$a3, $a3, $a3
	
.macro lD_loop
lD_loop_begin:
	blez	$a0, lD_loop_end
	println
	printspace
	printint($a1)
	printspace
	printint($a2)
	addu	$v0, $v0, $s5
	subu	$a0, $a0, $ra
	j	lD_loop_begin
lD_loop_end:
.end_macro

.macro rD_loop
rD_loop_begin:
	blez	$a1, rD_loop_end
	println
	printspace
	printint($a1)
	addu	$v1, $v1, $s6
	subu	$a1, $a1, $fp
	j	rD_loop_begin
rD_loop_end:
.end_macro

	lD_loop
	rD_loop
drawTriangles_mainLoop1:
	move	$k1, $t1
drawTriangles_mainLoop1_begin:
	bge	$k1, $t3, drawTriangles_pivot
	rowload($k1)

	println
	printint($k1)
	printspace
	printint($s2)
	println
	printint($v0)
	printspace
	printint($v1)

	
	drawline($v1 $v0)

	addu	$a0, $a0, $a2
	lD_loop
	addu	$a1, $a1, $a3
	rD_loop

	addi	$k1, $k1, 1
	j	drawTriangles_mainLoop1_begin

drawTriangles_pivot:
	beqz	$k0, drawTriangles_pivot_swapRight

	subu	$ra, $t5, $t3
	bge	$t4, $t2, drawTriangles_pivot_swapLeft_miniusOne
	li	$s6, 1
	subu	$a2, $t2, $t4
	j	drawTriangles_pivot_swapLeft_done
drawTriangles_pivot_swapLeft_miniusOne:
	li	$s6, -1
	subu	$a2, $t4, $t2
drawTriangles_pivot_swapLeft_done:
	j	drawTriangles_pivot_done

drawTriangles_pivot_swapRight:
	subu	$fp, $t5, $t3
	bge	$t4, $t2, drawTriangles_pivot_swapRight_miniusOne
	li	$s5, -1
	subu	$a3, $t2, $t4
	j	drawTriangles_pivot_swapRight_done
drawTriangles_pivot_swapRight_miniusOne:
	li	$s5, 1
	subu	$a3, $t2, $t4
drawTriangles_pivot_swapRight_done:
drawTriangles_pivot_done:
	println
drawTriangles_mainLoop2:
drawTriangles_mainLoop2_begin:
	bge	$k1, $t5, drawTriangles_mainLoop2_exit
	rowload($k1)

	println
	printint($k1)
	printspace
	printint($s2)
	println
	printint($v0)
	printspace
	printint($v1)

	
	drawline($v1 $v0)

	addu	$a0, $a0, $a2
	lD_loop
	addu	$a1, $a1, $a3
	rD_loop

	addi	$k1, $k1, 1
	j	drawTriangles_mainLoop2_begin
drawTriangles_mainLoop2_exit:



drawTriangles_epilogue:
	
writeEverything:
writeEverything_actualWriting:
	openfile(output_filename)
	la	$t0, bmpInfoHeader_end
	la	$t1, bmpHeader
	subu	$t0, $t0, $t1
	
	la	$a1, bmpHeader
	writefile($t0)
	
	move	$a1, bitmap
	writefile(bitmapSize)
	
	closefile
	
writeEverything_end:
	exit
