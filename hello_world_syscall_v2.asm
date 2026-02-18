; =============================================================================
; hello_syscall_fixed.asm — Hello World with CORRECT syscall ABI
; The issue: syscall instruction clobbers RCX, so kernel expects arg1 in R10
; =============================================================================

format PE64 console
entry start

SYSCALL_NtWriteFile        = 0x0008
SYSCALL_NtTerminateProcess = 0x002C

STD_OUTPUT_HANDLE = 7

section '.data' data readable writeable

    msg        db "Hello, World!", 0x0D, 0x0A
    msg_len    = $ - msg
    io_status  dq 0, 0

section '.code' code readable executable

start:
    sub  rsp, 72

    ; Arguments for NtWriteFile
    mov  rcx, STD_OUTPUT_HANDLE
    xor  rdx, rdx
    xor  r8,  r8
    xor  r9,  r9

    lea  rax, [io_status]
    mov  [rsp+32], rax

    lea  rax, [msg]
    mov  [rsp+40], rax

    mov  dword [rsp+48], msg_len
    mov  qword [rsp+56], 0
    mov  qword [rsp+64], 0

    ; CRITICAL: Copy RCX to R10 before syscall
    mov  r10, rcx
    mov  eax, SYSCALL_NtWriteFile
    syscall

    mov  rsi, rax

    add  rsp, 72

    ; NtTerminateProcess
    sub  rsp, 40

    mov  rcx, -1
    mov  rdx, rsi
    
    ; CRITICAL: Copy RCX to R10 before syscall
    mov  r10, rcx
    mov  eax, SYSCALL_NtTerminateProcess
    syscall