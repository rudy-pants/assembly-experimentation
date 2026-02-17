; =============================================================================
; hello_syscall.asm — Hello World via raw Windows syscalls
; No import table. No DLLs. No Win32 API. Pure NT native interface.
;
; Assembler: FASM (Flat Assembler) — https://flatassembler.net/
; Target:    Windows x64 (tested on Windows 10/11)
;
; Build:
;   fasm hello_syscall.asm hello_syscall.exe
;
; WARNING: Raw syscall numbers are NOT stable across Windows versions.
;   The numbers below target Windows 10/11 (NT 10.0).
;   They WILL differ on Windows 7/8/8.1 and may differ on future builds.
;   See: https://j00ru.vexillium.org/syscalls/nt/64/
; =============================================================================

format PE64 console
entry start

SYSCALL_NtWriteFile        = 0x0008
SYSCALL_NtTerminateProcess = 0x002C

section '.data' data readable writeable

    msg        db "Hello, World!", 0x0D, 0x0A
    msg_len    = $ - msg

    io_status  dq 0, 0

section '.code' code readable executable

start:
    ; Step 1: Get stdout HANDLE from the PEB via GS segment register
    ; gs:[0x60] = PEB*, PEB+0x20 = ProcessParameters, +0x30 = StandardOutput
    mov  rax, gs:[0x60]
    mov  rax, [rax + 0x20]
    mov  rbx, [rax + 0x30]

    ; Step 2: NtWriteFile
    ; Stack layout: 32 bytes shadow space + 40 bytes for args 5-9 = 72 total
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

    add  rsp, 72

    ; Step 3: NtTerminateProcess
    sub  rsp, 40

    mov  rcx, -1
    xor  rdx, rdx

    mov  eax, SYSCALL_NtTerminateProcess
    syscall