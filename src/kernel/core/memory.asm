; ============================================================================
; NexusOS v3.0 - Physical Page Allocator
; Bitmap-based, 4KB pages, initialized from E820 memory map
; ============================================================================
bits 64

%include "constants.inc"

; SMP work-queue spinlock API - lets work-queue jobs running on an AP allocate
; or free physical pages concurrently with the BSP. Both sides take the same
; lock, so page_alloc / page_free are safe to call from a job (see workqueue.asm
; "SHARED STATE").
extern wq_lock
extern wq_unlock
extern wq_alloc_lock

section .text

; --- Initialize page allocator from E820 map ---
; auto-wrapped (FN_BEGIN emits global): global memory_init
FN_BEGIN memory_init, 0, 0, FN_RET_SCALAR
    push rbx
    push r12
    push r13
    push r14

    ; Clear the entire bitmap (mark all pages as USED initially)
    mov rdi, PAGE_BITMAP_ADDR
    mov al, 0xFF             ; All bits set = all pages used
    mov rcx, PAGE_BITMAP_SIZE
    rep stosb


    test r12, r12
    jz .done

.entry_loop:
    ; Read entry
    mov rax, [r13]            ; Base address
    mov rbx, [r13 + 8]       ; Length
    mov ecx, [r13 + 16]      ; Type

    ; Only process type 1 (usable memory)
    cmp ecx, 1
    jne .next_entry

    ; Skip memory below the kernel load floor.
    cmp rax, KERNEL_LOAD_ADDR
    jge .process_range
    ; Adjust: if range extends above 1MB, clip it
    mov rdx, rax
    add rdx, rbx             ; End address
    cmp rdx, KERNEL_LOAD_ADDR
    jle .next_entry
    ; Clip start to 1MB
    sub rdx, KERNEL_LOAD_ADDR
    mov rbx, rdx             ; New length
    mov rax, KERNEL_LOAD_ADDR

.process_range:
    ; Skip pages used by kernel and fixed system structures.
    cmp rax, SYSTEM_RESERVED_END
    jge .mark_free
    mov rdx, rax
    add rdx, rbx
    cmp rdx, SYSTEM_RESERVED_END
    jle .next_entry
    ; Clip
    sub rdx, SYSTEM_RESERVED_END
    mov rbx, rdx
    mov rax, SYSTEM_RESERVED_END

.mark_free:
    ; Mark pages in this range as free
    ; RAX = base (page-aligned), RBX = length
    shr rax, 12              ; Convert to page number
    mov rdx, rbx
    shr rdx, 12              ; Convert to page count
    test rdx, rdx
    jz .next_entry

.free_loop:
    ; Clear bit in bitmap to mark page as free
    mov rcx, rax
    shr rcx, 3               ; Byte index (saved in RCX)
    mov r14, rax
    and r14, 7               ; Bit index (in R14)
    push rcx                 ; Save byte index
    mov r8b, 1
    mov cl, r14b             ; Shift count
    shl r8b, cl
    not r8b
    pop rcx                  ; Restore byte index
    and [PAGE_BITMAP_ADDR + rcx], r8b

    inc rax                  ; Next page
    dec rdx
    jnz .free_loop

    ; Note: free_page_count is recounted properly in count_free_pages below

.next_entry:
    add r13, 24              ; Next E820 entry (24 bytes each)
    dec r12
    jnz .entry_loop

.done:
    ; Recount free pages properly
    call count_free_pages
    ; Snapshot the post-init free total as the allocator's manageable RAM
    ; ceiling. Task Manager reports "used" as (boot total - free now).
    mov rax, [free_page_count]
    mov [boot_free_pages], rax

    pop r14
    pop r13
    pop r12
    pop rbx
    ret

; --- Allocate one physical page ---
; Returns: RAX = physical address of 4KB page, or 0 if out of memory
; auto-wrapped (FN_BEGIN emits global): global page_alloc
FN_BEGIN page_alloc, 0, 0, FN_RET_SCALAR
    push rbx
    push rcx
    push rdx

    ; Serialise against any other core (BSP or an AP job) touching the bitmap.
    mov rdi, wq_alloc_lock
    call wq_lock

    ; Scan bitmap for first free bit (0 = free)
    mov rdi, PAGE_BITMAP_ADDR
    mov rcx, PAGE_BITMAP_SIZE

.scan:
    cmp byte [rdi], 0xFF     ; All used?
    jne .found_byte
    inc rdi
    dec rcx
    jnz .scan
    ; Out of memory
    xor rax, rax
    jmp .alloc_done

.found_byte:
    ; Find which bit is 0 in this byte
    mov al, [rdi]
    mov rbx, rdi
    sub rbx, PAGE_BITMAP_ADDR  ; Byte offset
    shl rbx, 3                 ; * 8 = base page number for this byte

    xor ecx, ecx
.find_bit:
    bt eax, ecx
    jnc .got_bit
    inc ecx
    cmp ecx, 8
    jl .find_bit
    ; Shouldn't reach here
    xor rax, rax
    jmp .alloc_done

.got_bit:
    ; Mark as used
    bts dword [rdi], ecx

    ; Calculate physical address
    add rbx, rcx              ; Page number
    shl rbx, 12               ; * 4096 = physical address
    mov rax, rbx

    dec qword [free_page_count]

.alloc_done:
    ; RAX holds the result; wq_unlock preserves it.
    mov rdi, wq_alloc_lock
    call wq_unlock
    pop rdx
    pop rcx
    pop rbx
    ret

; --- Free a physical page ---
; RDI = physical address
; auto-wrapped (FN_BEGIN emits global): global page_free
FN_BEGIN page_free, 0, 0, FN_RET_SCALAR
    push rax
    push rcx

    ; Serialise against any other core touching the bitmap. RDI is the page
    ; address argument, so save it across the lock acquire.
    push rdi
    mov rdi, wq_alloc_lock
    call wq_lock
    pop rdi

    shr rdi, 12              ; Convert to page number
    mov rax, rdi
    shr rax, 3               ; Byte index
    mov rcx, rdi
    and rcx, 7               ; Bit index

    ; Clear the bit (mark as free)
    ; RAX = byte index, CL = bit index (from and rcx, 7 above)
    mov r8b, 1
    shl r8b, cl
    not r8b
    and [PAGE_BITMAP_ADDR + rax], r8b

    inc qword [free_page_count]

    mov rdi, wq_alloc_lock
    call wq_unlock
    pop rcx
    pop rax
    ret

; --- Count free pages ---
count_free_pages:
    push rbx
    push rcx

    xor rax, rax             ; Counter
    mov rdi, PAGE_BITMAP_ADDR
    mov rcx, PAGE_BITMAP_SIZE

.count_loop:
    mov bl, [rdi]
    not bl                   ; Invert: 1 = free
    ; Count set bits (popcount)
    xor edx, edx
.popcount:
    test bl, bl
    jz .next_byte
    mov r8b, bl
    dec r8b
    and bl, r8b              ; Clear lowest set bit
    inc rax
    jmp .popcount

.next_byte:
    inc rdi
    dec rcx
    jnz .count_loop

    mov [free_page_count], rax

    pop rcx
    pop rbx
    ret

; --- Get free page count ---
; auto-wrapped (FN_BEGIN emits global): global memory_get_free
FN_BEGIN memory_get_free, 0, 0, FN_RET_SCALAR
    mov rax, [free_page_count]
    ret

section .data
global free_page_count
free_page_count: dq 0
global boot_free_pages
boot_free_pages: dq 0
