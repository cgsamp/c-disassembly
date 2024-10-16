	.section	.rodata		# Program section for read-only data
.LC0:						# Storing a null-terminated string at memory location .LC0
	.string	"Hello from Factorial!"
.LC1:						# Storing a null-terminated string at memory location .LC1
	.string	"%d factorial is %d\n"

	.text					# Beginning the text of the program instructions
	.globl	_start			# Defines the memory location of the entry point
_start:						# Location of the entry point
	pushq	%rbp			# Push the quadword (64-bit, 8-byte) current stack base pointer onto the stack.
	movq	%rsp, %rbp		# Move the current stack pointer into the base pointer register
	subq	$16, %rsp		# Subtract 16 bytes from the current stack pointer to make room for two 8-byte variables
	movl	$.LC0, %edi		# Put the memory location referenced by .LC0 into edi register
	call	puts			# Call function puts, put-string, that puts the string pointed at by the edi register to stdout

	movl	$10, -12(%rbp)	# Put the value 10 into the memory location starting at 12 bytes below the stack base pointer
	movl	$1, -4(%rbp)	# Put the value 1 into the memory location 4 bytes below the base stack pointer
	movl	$0, -8(%rbp)	# Put the value 0 into the memory location 8 bytes below the base stack pointer
	jmp	.L2					# Move the instruction pointer to the memory location symbolized by .L2

.L3:						# Loop contents
	movl	-8(%rbp), %eax	# Move the 4-byte long integer to at memory location 8 bytes below the stack pointer into register eax
	leal	1(%eax), %edx	# Uses the pointer arithmetic operator LEA, usually used to increment memory locations, to increment the value in eax. Memory locations are just integers this works.
	movl	-4(%rbp), %eax	# Move the long value stored 4 bytes below the base stack pointer into the eax register
	imull	%edx, %eax		# Multiplies the signed long value in edx by the signed long value in eax and stores the result in eax.
	movl	%eax, -4(%rbp)	# Moves the value in eax to the location four bytes below the base pointer.
	addl	$1, -8(%rbp)	# Add one to the long value 8 bytes below the base pointer/

.L2:						# Loop test
	movl	-8(%rbp), %eax	# Moves the long value 8 bytes below the base pointer into eax
	cmpl	-12(%rbp), %eax # Compares long value 12 bytes below base pointer to the value in eax
	jl	.L3					# Jumps if less than; looks at the sign flag and overflow flag. Jumps to the loop contents.

	movl	-4(%rbp), %edx	# Puts the long 4 below base pointer into edx
	movl	-12(%rbp), %eax	# Puts the long value 12 below base pointer into eax
	movl	%eax, %esi		# Puts the value of eax into esi
	movl	$.LC1, %edi		# Puts the memory location symbolized by .LC1 into edi
	movl	$0, %eax		# Puts 0 into eax
	call	printf			# Calls printf, which uses edi, edx and esi to do string substituion and print to stdout 

    movl    $60, %eax       # Syscall number for exit (60 on Linux)
    xorq    %rdi, %rdi      # Exit code 0
    syscall                 # Invoke system call to exit
