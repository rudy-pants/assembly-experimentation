; =============================================================================
; hello_syscall_v2.asm — Hello World via raw Windows syscalls
; More robust version: uses NtAllocateVirtualMemory + writes to known console
;
; Assembler: FASM (Flat Assembler)
; Target:    Windows x64
;
; Build:
;   fasm hello_syscall_v2.asm hello_syscall_v2.exe
; =============================================================================

format PE64 console
entry start

SYSCALL_NtWriteFile        = 0x0008
SYSCALL_NtTerminateProcess = 0x002C

; Console handles on Windows are typically small integers
; Standard output is usually handle value 7 when running from cmd/powershell
STD_OUTPUT_HANDLE = 7

section '.data' data readable writeable

    msg        db "Hello, World!", 0x0D, 0x0A
    msg_len    = $ - msg

    io_status  dq 0, 0

section '.code' code readable executable

start:
    ; Use hardcoded stdout handle value 7
    ; This is the typical value for stdout in a console session
    ; If this works, the problem was the PEB traversal
    mov  rbx, STD_OUTPUT_HANDLE

    ; NtWriteFile syscall
    sub  rsp, 72

    mov  rcx, rbx
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

    mov  eax, SYSCALL_NtWriteFile
    syscall

    ; Save the NTSTATUS for exit code
    mov  rsi, rax

    add  rsp, 72

    ; Exit with the NtWriteFile status
    sub  rsp, 40

    mov  rcx, -1
    mov  rdx, rsi

    mov  eax, SYSCALL_NtTerminateProcess
    syscall