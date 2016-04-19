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
store_x0:
	.word	0
store_x1:
	.word	0
store_x2:
	.word	0
store_y0:
	.word	0
store_y1:
	.word	0
store_y2:
	.word	0


prompt1:
	.asciiz "triangleNum width height = \n"
prompt2:
	.asciiz "h x0 y0 x1 y1 x2 y2 = \n"
prompt3:
	.asciiz "r g b = \n"


msg_l:
	.asciiz "l\n"
msg_r:
	.asciiz "r\n"
msg_exitOK:
	.asciiz "exit OK\n"
msg_endl:
	.asciiz "\n"
msg_space:
	.asciiz " "
msg_separator:
	.asciiz "\n=========\n"


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

.macro dumpmem(%reg)
	println
	lb	$a0, (%reg)
	printint($a0)
	printspace
	lb	$a0, 1(%reg)
	printint($a0)
	printspace
	lb	$a0, 2(%reg)
	printint($a0)
	printspace
	lb	$a0, 3(%reg)
	printint($a0)
	printspace
	lb	$a0, 4(%reg)
	printint($a0)
	printspace
	lb	$a0, 5(%reg)
	printint($a0)
	printspace
	lb	$a0, 6(%reg)
	printint($a0)
	printspace
	lb	$a0, 7(%reg)
	printint($a0)
	printspace
	lb	$a0, 8(%reg)
	printint($a0)
	printspace
	lb	$a0, 9(%reg)
	printint($a0)
	printspace
	lb	$a0, 10(%reg)
	printint($a0)
	printspace
	lb	$a0, 11(%reg)
	printint($a0)
	printspace
	lb	$a0, 12(%reg)
	printint($a0)
	printspace
	lb	$a0, 12(%reg)
	printint($a0)
	printspace
	lb	$a0, 13(%reg)
	printint($a0)
	printspace
	lb	$a0, 14(%reg)
	printint($a0)
	printspace
	lb	$a0, 15(%reg)
	printint($a0)
	printspace
	lb	$a0, 16(%reg)
	printint($a0)
	printspace
	lb	$a0, 17(%reg)
	printint($a0)
	printspace
	lb	$a0, 18(%reg)
	printint($a0)
	printspace
	lb	$a0, 19(%reg)
	printint($a0)
	printspace
	lb	$a0, 20(%reg)
	printint($a0)
	printspace
	lb	$a0, 21(%reg)
	printint($a0)
	printspace
	lb	$a0, 22(%reg)
	printint($a0)
	println
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

.macro printseparator
	println_preserve(msg_separator)
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

.macro printint(%r)
	mthi	$a0
	mtlo	$v0
	move	$a0, %r
	li	$v0, 1
	syscall
	mfhi	$a0
	mflo	$v0
.end_macro

_main:
	println(prompt1)

	read_int(trianglesLeft)
.eqv	trianglesLeft $s7

	read_int($s6)	# width
	read_int($s5)	# height
.eqv	width	$s6
.eqv	height	$s5

.eqv	x0	$t0
.eqv	y0	$t1
.eqv	x1	$t2
.eqv	y1	$t3
.eqv	x2	$t4
.eqv	y2	$t5

allocBitmap:
	mulu	$s4, $s6, bpp
	addi	$s4, $s4, 31
	sra	$s4, $s4, 5
	sll	$s4, $s4, 2
.eqv	row_len	$s4


	mult	row_len, height
	mflo	$a0
	addu	$a0, $a0, $a0
	li	$v0, 9

	la	$t7, bitmap_len
	sw	$a0, ($t7)

	syscall # some error handling #maybe
	move	$s1, $v0
	li	$v0, 9
	syscall
	move	$s3, $v0
.eqv	bitmap	$s1
.eqv	zbuff	$s3

	move	$s2, $a0
	printspace
	printspace
	printspace
	printspace
	printint($s2)
	println
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
	move 	$at, %r0
	move 	%r0, %r1
	move 	%r1, $at
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
	ble $t3, $t1, drawTriangles_no12swap
	xchg($t1 $t3)
	xchg($t0 $t2)
drawTriangles_no12swap:
	ble $t5, $t3, drawTriangles_no23swap
	xchg($t3 $t5)
	xchg($t2 $t4)
	j drawTriangles_sortStart
drawTriangles_no23swap:

	println(prompt3)
	read_int($t6) # R
	read_int($t7) # G
	read_int($t8) # B

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
	subu	$t7, $t3, $t1
	subu	$t8, $t5, $t1
	j	drawTriangles_init_swap_done
drawTriangles_init_swap_right:
	subu	$t7, $t3, $t1
	subu	$t8, $t5, $t1
drawTriangles_init_swap_done:

	addu	$a0, $a2, $a2
	subu	$a0, $a0, $t7

	addu	$a1, $a3, $a3
	subu	$a1, $a1, $t8

	move	$v0, $t0
	move	$v1, $t0

	addu	$t8, $t8, $t8
	addu	$t7, $t7, $t7

	addu	$a2, $a2, $a2
	addu	$a3, $a3, $a3

	subu	$t8, $0, $t8
	subu	$t7, $0, $t7

.macro debug_dump
	printseparator
	println
	println
	println
	printspace
	printint($t6)

	println
	printint($v0)
	printspace
	printint($v1)

	println
	printint($a0)
	printspace
	printint($a1)

	println
	printint($a2)
	printspace
	printint($a3)

	println
	printint($t7)
	printspace
	printint($t8)
	println
.end_macro

.macro lD_loop
lD_loop_begin:
	blez	$a0, lD_loop_end
	addu	$v0, $v0, $s5
	subu	$a0, $a0, $t7
	println_preserve(msg_l)
	debug_dump
	j	lD_loop_begin
lD_loop_end:
.end_macro

.macro rD_loop
rD_loop_begin:
	blez	$a1, rD_loop_end
	addu	$v1, $v1, $s6
	subu	$a1, $a1, $t8
	println_preserve(msg_r)
	debug_dump
	j	rD_loop_begin
rD_loop_end:
.end_macro

	#lD_loop # DBG
	#rD_loop # DBG

drawTriangles_mainLoop1:
	move	$t6, $t1

drawTriangles_mainLoop1_begin:
	ble	$t6, $t3, drawTriangles_pivot

	printseparator
	printseparator
	debug_dump


	#rowload($t6)
	#drawline($v1 $v0)
#j drawTriangles_mainLoop2_exit # DBG

	addu	$a0, $a0, $a2
	lD_loop
	addu	$a1, $a1, $a3
	rD_loop

	addi	$t6, $t6, -1
	j	drawTriangles_mainLoop1_begin

drawTriangles_pivot:

drawTriangles_epilogue:
	printseparator
	exit
