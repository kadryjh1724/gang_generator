.section .data
    input_buffer: .space 256
    
    output_buffer: .space 2048
    
    suffix1: .ascii "ang"
    suffix2: .ascii "ogga"
    suffix3: .ascii "loppa"
    
    prompt: .ascii "Enter a string: "
    prompt_len = . - prompt
    
    result_msg: .ascii "Result: "
    result_msg_len = . - result_msg
    
    newline: .ascii "\n"
    
    rand_seed: .quad 1

.section .text
.globl _start

_start:
    movq $1, %rax
    movq $1, %rdi
    movq $prompt, %rsi
    movq $prompt_len, %rdx
    syscall
    
    movq $0, %rax
    movq $0, %rdi
    movq $input_buffer, %rsi
    movq $255, %rdx
    syscall
    
    movq %rax, %r15
    decq %r15
    
    call transform_string
    
    movq $1, %rax
    movq $1, %rdi
    movq $result_msg, %rsi
    movq $result_msg_len, %rdx
    syscall
    
    movq $1, %rax
    movq $1, %rdi
    movq $output_buffer, %rsi
    movq output_length(%rip), %rdx
    syscall
    
    movq $1, %rax
    movq $1, %rdi
    movq $newline, %rsi
    movq $1, %rdx
    syscall
    
    movq $60, %rax 
    movq $0, %rdi
    syscall

.section .bss
output_length: .space 8

.section .text

transform_string:
    pushq %rbp
    movq %rsp, %rbp
    pushq %rbx
    pushq %rcx
    pushq %rdx
    pushq %rsi
    pushq %r12
    pushq %r13
    pushq %r14
    
    movq $0, %r12
    movq $0, %r13
    
transform_loop:
    cmpq %r15, %r12
    jge transform_done
    
    movb input_buffer(%r12), %r14b
    
    movb %r14b, output_buffer(%r13)
    incq %r13
    
    movb %r14b, %dil
    call is_alnum
    
    testq %rax, %rax
    jz skip_suffix
    
    call get_random_suffix
    movq %rax, %rdi
    movq %r13, %rsi
    call append_suffix
    addq %rax, %r13
    
skip_suffix:
    incq %r12
    jmp transform_loop
    
transform_done:
    movq %r13, output_length(%rip)
    
    popq %r14
    popq %r13
    popq %r12
    popq %rsi
    popq %rdx
    popq %rcx
    popq %rbx
    popq %rbp
    ret

is_alnum:
    pushq %rbp
    movq %rsp, %rbp
    
    cmpb $65, %dil
    jl check_lowercase
    cmpb $90, %dil
    jle is_alpha
    
check_lowercase:
    cmpb $97, %dil
    jl check_digit
    cmpb $122, %dil
    jle is_alpha
    
check_digit:
    cmpb $48, %dil
    jl not_alnum
    cmpb $57, %dil
    jle is_alpha
    
not_alnum:
    movq $0, %rax
    jmp is_alnum_done
    
is_alpha:
    movq $1, %rax
    
is_alnum_done:
    popq %rbp
    ret

get_random_suffix:
    pushq %rbp
    movq %rsp, %rbp
    pushq %rdx
    
    movq rand_seed(%rip), %rax
    imulq $1103515245, %rax
    addq $12345, %rax
    movq $0x7fffffff, %rcx
    andq %rcx, %rax
    movq %rax, rand_seed(%rip)
    
    movq $0, %rdx
    movq $3, %rcx
    divq %rcx
    movq %rdx, %rax
    
    popq %rdx
    popq %rbp
    ret

append_suffix:
    pushq %rbp
    movq %rsp, %rbp
    pushq %rbx
    pushq %rcx
    pushq %rdx
    pushq %r8
    
    cmpq $0, %rdi
    je append_ang
    cmpq $1, %rdi
    je append_ogga
    jmp append_loppa
    
append_ang:
    movq $suffix1, %rbx
    movq $3, %rcx
    jmp do_append
    
append_ogga:
    movq $suffix2, %rbx
    movq $4, %rcx
    jmp do_append
    
append_loppa:
    movq $suffix3, %rbx
    movq $5, %rcx
    
do_append:
    movq $0, %r8
    
append_loop:
    cmpq %rcx, %r8
    jge append_done
    
    movb (%rbx,%r8,1), %dl
    movb %dl, output_buffer(%rsi,%r8,1)
    incq %r8
    jmp append_loop
    
append_done:
    movq %rcx, %rax
    
    popq %r8
    popq %rdx
    popq %rcx
    popq %rbx
    popq %rbp
    ret
