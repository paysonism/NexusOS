; --- DEBUG: append a new xhci_init log entry derived from xhci_pci_addr ---
xhci_dbg_initlog_new:
    push rax
    push rbx
    push rdx
    movzx ebx, byte [xhci_initlog_n]
    cmp ebx, 8
    jae .d
    mov eax, ebx
    shl eax, 2
    lea rbx, [xhci_initlog]
    add rbx, rax
    mov eax, [xhci_pci_addr]
    mov edx, eax
    shr edx, 16
    and edx, 0xFF
    mov [rbx + 0], dl                ; bus
    mov edx, eax
    shr edx, 11
    and edx, 0x1F
    mov [rbx + 1], dl                ; dev
    mov edx, eax
    shr edx, 8
    and edx, 0x07
    mov [rbx + 2], dl                ; fn
    mov byte [rbx + 3], 1            ; stage = pciFound
    mov [xhci_initlog_cur], rbx
    inc byte [xhci_initlog_n]
.d:
    pop rdx
    pop rbx
    pop rax
    ret

; --- DEBUG: set stage byte of current log entry (AL = stage) ---
xhci_dbg_initlog_stage:
    push rbx
    mov rbx, [xhci_initlog_cur]
    test rbx, rbx
    jz .d
    mov [rbx + 3], al
.d:
    pop rbx
    ret

; --- DEBUG: snapshot what xhci_find_port sees (op base, ports, PORTSC map) ---
xhci_dbg_fp_snapshot:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    mov qword [xhci_dbg_fp_cur], 0
    ; Rotating buffer: keep the LAST 4 calls (slot = call# mod 4) so retries
    ; overwrite stale boot-time records instead of being dropped.
    movzx ecx, byte [xhci_dbg_fp_n]
    mov eax, ecx
    and eax, 3
    shl eax, 4
    lea rdi, [xhci_dbg_fp]
    add rdi, rax
    mov [xhci_dbg_fp_cur], rdi
    mov rax, [xhci_op_base]
    mov [rdi + 0], eax
    movzx edx, byte [xhci_max_ports]
    mov [rdi + 4], dl
    mov byte [rdi + 5], 0xFF          ; result pending
    mov rsi, [xhci_op_base]
    XHCI_MMIO_ASSERT rsi, MMIO_XHCI_WINDOW
    add rsi, 0x400
    xor ebx, ebx
.loop:
    cmp ebx, 10
    jge .done_inc
    cmp ebx, edx
    jge .pad
    mov eax, ebx
    shl eax, 4
    mov eax, [rsi + rax]              ; PORTSC
    xor r8d, r8d
    test eax, XHCI_PORTSC_CCS
    jz .store
    mov r8d, eax
    shr r8d, XHCI_PORTSC_SPEED_SHIFT
    and r8d, 0x0F
    jmp .store
.pad:
    xor r8d, r8d
.store:
    mov [rdi + rbx + 6], r8b
    inc ebx
    jmp .loop
.done_inc:
    inc byte [xhci_dbg_fp_n]
.done:
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; --- DEBUG: record xhci_find_port result (AL = 0/1) ---
xhci_dbg_fp_result:
    push rbx
    mov rbx, [xhci_dbg_fp_cur]
    test rbx, rbx
    jz .d
    mov [rbx + 5], al
.d:
    pop rbx
    ret

; ============================================================================
; xhci_init - Find and initialize XHCI controller
; Returns: EAX = 1 on success, 0 on failure
; ============================================================================
global xhci_init