; =============================================================================
; hello_msgbox.asm — Hello World using Win32 MessageBox instead of raw syscalls
; This uses the import table to verify the PE structure is correct
; =============================================================================

format PE64 GUI
entry start

section '.idata' import data readable writeable

    library kernel32,'KERNEL32.DLL',\
            user32,'USER32.DLL'

    import kernel32,\
           ExitProcess,'ExitProcess'

    import user32,\
           MessageBoxA,'MessageBoxA'

section '.data' data readable writeable
    msg        db 'Hello, World!',0
    caption    db 'Raw Assembly',0

section '.code' code readable executable

start:
    sub  rsp, 40
    
    xor  rcx, rcx
    lea  rdx, [msg]
    lea  r8,  [caption]
    xor  r9,  r9
    
    call [MessageBoxA]
    
    xor  rcx, rcx
    call [ExitProcess]