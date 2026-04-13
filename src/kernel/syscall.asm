; ============================================================================
; NexusOS v3.0 - System Call Handler (64-bit Long Mode)
; ============================================================================
bits 64

%include "constants.inc"
%include "macros.inc"

; MSR Addresses for Syscall
IA32_EFER           equ 0xC0000080
IA32_STAR           equ 0xC0000081
IA32_LSTAR          equ 0xC0000082
IA32_FMASK          equ 0xC0000084
IA32_KERNEL_GS_BASE equ 0xC0000102

section .data
global syscall_count
syscall_count: dq 0
user_rsp_save: dq 0

extern debug_print
extern fat16_change_dir
extern fat16_read_file
extern fat16_format_name
extern fat16_write_file
extern fat16_sync_root
extern wm_create_window_ex
extern wm_close_window
extern app_launch
extern display_set_mode
extern cursor_init
extern szUsermodeIn ; repurposed or new string

section .text

; --- Initialize System Call mechanism ---
global syscall_init
syscall_init:
    push rax
    push rcx
    push rdx

    ; 1. Enable SCE (System Call Extensions) in EFER
    mov ecx, IA32_EFER
    rdmsr
    or eax, 1               ; bit 0 = SCE
    wrmsr

    ; 2. Configure STAR: [47:32]=KCode, [63:48]=UCode32Base
    ; KCode = 0x08 (KData=0x10)
    ; UCode32Base = 0x18 (UData=0x20, UCode64=0x28)
    ; Layout in STAR: [63:48] = 0x18 | 3 = 0x1B, [47:32] = 0x08
    mov ecx, IA32_STAR
    xor eax, eax
    mov edx, 0x001B0008     ; Star[63:48]=0x1B, Star[47:32]=0x08
    wrmsr

    ; 3. Configure LSTAR (Target RIP for 64-bit syscall)
    mov ecx, IA32_LSTAR
    lea rax, [syscall_entry]
    
    ; Debug: Print the address we are setting in LSTAR
    push rax
    push rdi
    SER 'L' ; L = LSTAR entry point
    mov rdi, rax
    call ser_print_hex64
    SER 13
    SER 10
    pop rdi
    pop rax

    mov rdx, rax
    shr rdx, 32             ; EDX = high 32 bits
                            ; EAX = low 32 bits (lower half of rax)
    wrmsr                   ; WRMSR: EDX:EAX written to LSTAR

    ; 4. Configure FMASK (Flags to clear on syscall)
    mov ecx, IA32_FMASK
    ; Clear Interrupt Flag (0x200), Direction (0x400), Trap (0x100)
    mov eax, 0x00000700     ; Clear IF, DF, TF
    xor edx, edx
    wrmsr

    pop rdx
    pop rcx
    pop rax
    ret

; --- System Call Entry Point ---
; RCX = User RIP
; R11 = User RFLAGS
; RAX = Syscall Number
; Arguments in: RDI, RSI, RDX, R10, R8, R9 (follows System V ABI for user mode mostly)
global syscall_entry
syscall_entry:
    cld                     ; ALWAYS clear direction flag on entry!
    ; CPU does NOT switch stack for syscall! We must do it IMMEDIATELY
    ; before any pushes (like those in SER macros) occur.
    mov [user_rsp_save], rsp
    mov rsp, 0x1FF000       ; SYSCALL_STACK_TOP

    PUSH_ALL                ; Save all user registers on kernel stack
    ; (Note: r12 on stack is original user stack pointer saved above)
    ; wait, PUSH_ALL pushed r12? yes.

    ; Increment counter
    inc qword [syscall_count]

    ; Handle Syscall by Number (RAX)
    cmp rax, 0
    je .sc_print
    cmp rax, 1
    je .sc_exit
    cmp rax, 2
    je .sc_gui_rect
    cmp rax, 3
    je .sc_gui_text
    cmp rax, 4
    je .sc_fs_count
    cmp rax, 5
    je .sc_fs_entry
    cmp rax, 6
    je .sc_fs_chdir
    cmp rax, 7
    je .sc_wm_create
    cmp rax, 8
    je .sc_fs_read
    cmp rax, 9
    je .sc_wm_handlers
    cmp rax, 10
    je .sc_app_done
    cmp rax, 11
    je .sc_fs_format_name
    cmp rax, 12
    je .sc_app_launch
    cmp rax, 13
    je .sc_fs_write
    cmp rax, 14
    je .sc_fs_sync_root
    cmp rax, 15
    je .sc_wm_close
    cmp rax, 16
    je .sc_display_set_mode
    cmp rax, 17
    je .sc_cursor_init

.sc_fs_count:
    ; RAX 4: fat16_file_count
    call fat16_file_count
    mov [rsp + ALL_RAX], rax ; Save return value to RAX on stack
    jmp .done

.sc_fs_entry:
    ; RAX 5: fat16_get_entry (index=rdi)
    call fat16_get_entry
    mov [rsp + ALL_RAX], rax ; Return entry pointer in RAX
    jmp .done

.sc_fs_chdir:
    ; RAX 6: fat16_change_dir (cluster=rdi)
    mov rax, rdi
    call fat16_change_dir
    jmp .done

.sc_wm_create:
    ; RAX 7: wm_create_window_ex (title=rdi, x=rsi, y=rdx, w=r10, h=r8, draw=r9)
    ; In syscall, r10 is used for the 4th arg
    mov rcx, r10
    call wm_create_window_ex
    mov [rsp + ALL_RAX], rax ; Return window ID
    jmp .done

.sc_fs_read:
    ; RAX 8: fat16_read_file (entry=rdi, dest=rsi, size=rdx)
    call fat16_read_file
    mov [rsp + ALL_RAX], rax ; Return bytes read
    jmp .done

.sc_wm_handlers:
    ; RAX 9: wm_set_handlers (win_id=rdi, click=rsi, key=rdx)
    ; Get window pointer from ID
    mov rax, rdi
    imul rax, WINDOW_STRUCT_SIZE
    add rax, WINDOW_POOL_ADDR
    mov [rax + WIN_OFF_CLICKFN], rsi
    mov [rax + WIN_OFF_KEYFN], rdx
    jmp .done

.sc_fs_format_name:
    ; RAX 11: fat16_format_name (entry=rdi, dest=rsi)
    ; fat16_format_name takes rsi=entry, rdi=dest
    push rdi
    push rsi
    mov r8, rsi ; dest
    mov rsi, rdi ; entry
    mov rdi, r8  ; dest
    call fat16_format_name
    pop rsi
    pop rdi
    jmp .done

.sc_app_launch:
    ; RAX 12: app_launch(app_id=rdi)
    call app_launch
    mov [rsp + ALL_RAX], rax ; Return window ID
    jmp .done

.sc_fs_write:
    ; RAX 13: fat16_write_file(name=rdi, src=rsi, size=rdx)
    call fat16_write_file
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_fs_sync_root:
    ; RAX 14: fat16_sync_root()
    call fat16_sync_root
    jmp .done

.sc_wm_close:
    ; RAX 15: wm_close_window(win_id=rdi)
    call wm_close_window
    jmp .done

.sc_display_set_mode:
    ; RAX 16: display_set_mode(w=rdi, h=rsi, bpp=rdx)
    call display_set_mode
    mov [rsp + ALL_RAX], rax
    jmp .done

.sc_cursor_init:
    ; RAX 17: cursor_init()
    call cursor_init
    jmp .done

.sc_app_done:
    ; RAX 10: App callback finished.
    ; We need to return to the KERNEL code that called the app.
    ; Since we are in the syscall handler, we can't just 'ret'.
    ; We need to restore the kernel stack precisely.
    jmp .done_to_kernel

.sc_gui_rect:
    ; RAX 2: Render Rect (x=rdi, y=rsi, w=rdx, h=rcx, col=r8)
    ; In syscall, R10 is used instead of RCX for the 4th argument
    mov rcx, r10            ; r10 -> rcx (height)
    call render_rect
    jmp .done

.sc_gui_text:
    ; RAX 3: Render Text (x=rdi, y=rsi, str=rdx, col=rcx, bg=r8)
    ; In syscall, R10 is used instead of RCX for the 4th argument
    mov rcx, r10            ; r10 -> rcx (color)
    call render_text
    jmp .done

.sc_print:
    ; SYSCALL 0: Print Serial Debug Message
    ; RDI = string pointer (must be reachable by kernel)
    ; (Note: currently we use identity paging, so kernel can see all)
    
    ; For safety, we should validate RDI is in user range.
    ; But for now:
    mov rsi, rdi
    call debug_print
    jmp .done

.sc_exit:
    ; SYSCALL 1: Exit process (re-entry to usermode loop)
    ; For now, just jump back to test_usermode_proc forever
    ; (Not a real exit yet)
    jmp .done

.done:
    POP_ALL
    ; Use iretq for return to Ring 3 (more robust than sysret)
    push qword GDT64_USER_DATA ; SS
    push qword [user_rsp_save] ; RSP
    push r11                   ; RFLAGS
    push qword GDT64_USER_CODE ; CS
    push rcx                   ; RIP
    iretq

.done_to_kernel:
    ; We are in the syscall handler. Kernel stack is active.
    ; We already did PUSH_ALL in syscall_entry?
    ; No, we are about to POP them.
    POP_ALL
    ; Instead of sysret, we just go to the kernel return point.
    ; We need to be careful: the syscall_entry saved r12 as the user RSP.
    ; For sc_app_done, we don't care about the user RSP anymore.
    
    extern call_app_l3_return
    jmp call_app_l3_return

global test_syscall_proc
test_syscall_proc:
    ; We are in Ring 3
    ; Let's try to print something!
    mov rax, 0              ; syscall_print
    lea rdi, [szHelloUser]
    syscall
    
    ; Loop forever
.loop:
    mov rcx, 0x1000000       ; Delay
.delay:
    pause
    dec rcx
    jnz .delay
    
    mov rax, 0              ; syscall_print
    lea rdi, [szHelloUser]
    syscall
    
    jmp .loop

section .data
szHelloUser: db "-> Hello from RING 3 (via SYSCALL)!", 0

section .text
