# Diving into C and Assembly on Macos and Debian

I was curious about how C compiles into Assembly and wanted to do some basic investigation.

## The C Program

[This program](factorial.c) was compiled on macos with **gcc** as well as Debian via a docker container. *gcc* on macos wraps **clang** so there are some differences.

```
#include <stdio.h>

int main() {
    printf("Hello from Factorial!\n");
    int number = 10;
    int total = 1;
    for (int i=0; i < number; i++) {
        total = total * (i + 1);
    }
    printf("%d factorial is %d\n",number,total);
    return 0;
}
```

The program just uses a for loop to calculate 10 factorial and print it out.

## Macos

### Compiling

I can easily use
```
gcc factorial.c -o factorial_macos
```
to create an executable binary. 

### Executing

Simple as
```
➜  see git:(main) ./factorial_macos
Hello from Factorial!
10 factorial is 3628800
```

### Assembling

I can also create the assembly with
```
gcc -S factorial.c factorial_macos.s
```
[factorial_macos.s](factorial_macos.s)

### Deassembling

I can also create a listing file, sort of, with 
```
objdump -d -h factorial_macos  > factorial_macos.lst
```
[factorial_macos.lst](factorial_macos.lst)

## Debian

**gcc** on Debian is not wrapped, and can produce a more interesting listing file. To do that, I wanted to use a docker container to operate on my files somewhat locally.

### Docker

I have docker desktop installed and started, so the docker daemon is running. 

```
git:(main) docker --version
Docker version 20.10.10, build b485636
```

I am using a container provided by gcc [https://hub.docker.com/_/gcc](https://hub.docker.com/_/gcc). I can enter bash within the container, mounting my project directory to `code` with
```
docker run -it -v /Users/csamp/projects/see:/code gcc bash
```
or execute commands and exit with
```
docker run --rm -t -v /Users/csamp/projects/see:/code -w /code gcc:latest [command with arguments]
```
### Compiling

I can easily use
```
docker run --rm -t -v /Users/csamp/projects/see:/code -w /code gcc:latest gcc factorial.c -o factorial_debian
```
to create an executable binary. 

### Executing

The structure of Debian executables is different than macos executables.
```
➜  see git:(main) docker run --rm -t -v /Users/csamp/projects/see:/code -w /code gcc:latest ./factorial_debian
Hello from Factorial!
10 factorial is 3628800
```

### Assembling

Here I again use **gcc** to create the assembly, but this one does not wrap another tool.
```
docker run --rm -v /Users/csamp/projects/see:/code -w /code gcc:latest gcc -S factorial.c -o factorial_debian.s 
```
[factorial_debian.s](factorial_debian.s)

### Object file

While I could let **gcc** compile and link the .c file into an executable, like on macos, I can also take the manual step of using **as** to create the object file. This .o file is machine code that can be viewed with a hex editor.
```
docker run --rm -v /Users/csamp/projects/see:/code -w /code gcc:latest as -o factorial_debian.o factorial_debian.s
```

### Linking

Linking takes the object file, combines it with other libraries on the target platform, such as the *printf* function, and makes the binary executable.

```
docker run --rm -v /Users/csamp/projects/see:/code -w /code gcc:latest ld -o factorial_debian factorial_debian.o /lib/x86_64-linux-gnu/libc.so.6 -dynamic-linker /lib64/ld-linux-x86-64.so.2
```

### Deassembling / Listing

While I can use **objdump** to disassemble the binary, I can get a better listing out of gcc on Debian:
```
docker run --rm -t -v /Users/csamp/projects/see:/code -w /code gcc:latest gcc -g -Wa,-adhln -o factorial_debian factorial.c > factorial_debian.lst 
```
[factorial_debian.lst](factorial_debian.lst)

## The Assembly

Here I have removed some assembler directives and commented on each assembler instruction. See also [factorial_debian.s](factorial_debian.s) for this content.

```
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

```

## Wrap up

I plan to do this on my M1 Mac and see what the ARM assembly looks like!