; =============================================================================
; hello_syscall_diagnostic.asm — Test if syscalls work at all
; This version just exits immediately with a known exit code
; to verify the syscall mechanism itself functions
; =============================================================================

format PE64 console
entry start

SYSCALL_NtTerminateProcess = 0x002C

section '.code' code readable executable

start:
    ; Simplest possible test: just call NtTerminateProcess with exit code 42
    ; If this exits with code 42, syscalls work
    ; If it crashes, the syscall number or calling convention is wrong
    
    sub  rsp, 40
    
    mov  rcx, -1
    mov  rdx, 42
    
    mov  eax, SYSCALL_NtTerminateProcess
    syscall
    
    add  rsp, 40