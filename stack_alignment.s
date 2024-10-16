
# Option 0:
                            # Assume stack pointer is aligned to 16 bytes
    call    puts            # Misaligns stack pointer
    call    printf          # Segmentation fault!

# Option 1 to fix
                            # Assume stack pointer is aligned to 16 bytes
    call    puts            # Adds 8 bytes to stack pointer by pushing the 8-byte return address to the stack
    subq    $8, %rsp        # Fixes the stack pointer by adding 8 bytes
    call    printf          # No seg fault
                            # Problem: if stack pointer was misaligned coming into this block, we have a seg fault

# Option 2 to fix
                            # Assume stack pointer is aligned to 16 bytes
    subq    $8, %rsp        # Misaligns the stack pointer
    call    puts            # Adds 8 bytes to stack pointer by pushing the 8-byte return address to the stack, realigning the stack pointer
    call    printf          # No seg fault
                            # Problem: if stack pointer was misaligned coming into this block, we have a seg fault

# Option 3 to fix
                            # No assumption about stack pointer
    call    puts            # Adds 8 bytes to stack pointer by pushing the 8-byte return address to the stack; may or may not misalign the stack pointer
    andq    $-16, %rsp      # Align %rsp to the nearest 16-byte boundary; stack pointer gets aligned regardless of the state it was in before
    call    printf          # No seg fault

# Option 3A to fix
                            # No assumption about stack pointer
    call    puts            # Adds 8 bytes to stack pointer by pushing the 8-byte return address to the stack; may or may not misalign the stack pointer
    andq    $-16, %rsp      # Align %rsp to the nearest 16-byte boundary; stack pointer gets aligned regardless of the state it was in before; do it right after call puts
    ...                     # Some code
    call    printf          # No seg fault

# Option 3B to fix
                            # No assumption about stack pointer
    call    puts            # Adds 8 bytes to stack pointer by pushing the 8-byte return address to the stack; may or may not misalign the stack pointer
    ...                     # Some code
    andq    $-16, %rsp      # Align %rsp to the nearest 16-byte boundary; stack pointer gets aligned regardless of the state it was in before; do it right before call printf
    call    printf          # No seg fault

    


    