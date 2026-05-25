; ============================================================================
; NexusOS network Ethernet/IP helpers
; ============================================================================
bits 64

section .text

; RDI = buffer, ECX = byte count. Returns network-order checksum in AX.
global net_checksum
net_checksum:
    push rbx
    push rcx
    push rdx
    push rdi
    xor ebx, ebx
.sum:
    cmp ecx, 1
    jb .fold
    movzx eax, byte [rdi]
    shl eax, 8
    movzx edx, byte [rdi + 1]
    or eax, edx
    add ebx, eax
    add rdi, 2
    sub ecx, 2
    jmp .sum
.fold:
    mov eax, ebx
    shr eax, 16
    and ebx, 0xFFFF
    add ebx, eax
    mov eax, ebx
    shr eax, 16
    add bx, ax
    not bx
    mov ax, bx
    xchg al, ah
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    ret
