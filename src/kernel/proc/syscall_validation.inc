sc_get_slot_bounds:
    mov eax, r15d
    cmp eax, MAX_WINDOWS
    jb .slot_ok
    xor eax, eax
.slot_ok:
    imul rax, APP_SLOT_SIZE
    add rax, [rel l3_app_arena_base_v]
    mov r8, rax
    lea r9, [r8 + APP_SLOT_SIZE]
    ret

; RDI=ptr, RSI=len, R8=start, R9=end -> EAX=1 if fully inside [start,end)
sc_range_in_bounds:
    mov rax, rdi
    cmp rax, r8
    jb .range_fail
    mov rdx, rdi
    add rdx, rsi
    jc .range_fail
    cmp rdx, r9
    ja .range_fail
    mov eax, 1
    ret
.range_fail:
    xor eax, eax
    ret

; RDI=ptr, RSI=len -> EAX=1 if range is inside the current app slot or the
; built-in user blob.
sc_validate_user_range:
    push rdi
    push rsi
    push r8
    push r9
    push r11
    call sc_get_slot_bounds
    call sc_range_in_bounds
    mov r11d, eax
    test r11d, r11d
    jnz .uvr_done
    mov r8, [rel app_blob_base_v]
    mov r9, [rel app_blob_end_v]
    call sc_range_in_bounds
    mov r11d, eax
.uvr_done:
    mov eax, r11d
    pop r11
    pop r9
    pop r8
    pop rsi
    pop rdi
    ret

; RDI=ptr, RSI=len -> EAX=1 if the range is inside user-owned memory.
sc_validate_user_io_range:
    call sc_validate_user_range
    ret

; RDI=ptr, RSI=max_len -> EAX=1 if a NUL-terminated string lives entirely in
; the current app slot or the built-in user blob.
sc_validate_user_cstring:
    push rdi
    push rsi
    push rcx
    push r9
    push r10
    push r11
    mov r10, rdi
    mov r11, rsi
    xor r9d, r9d
    xor rcx, rcx
.uvc_loop:
    cmp rcx, r11
    jae .uvc_done
    lea rdi, [r10 + rcx]
    mov rsi, 1
    call sc_validate_user_range
    test eax, eax
    jz .uvc_done
    cmp byte [rdi], 0
    je .uvc_match
    inc rcx
    jmp .uvc_loop
.uvc_match:
    mov r9d, 1
.uvc_done:
    mov eax, r9d
    pop r11
    pop r10
    pop r9
    pop rcx
    pop rsi
    pop rdi
    ret

; RDI=opaque FAT16 entry handle -> EAX=1 if it points at an aligned entry in
; the current root/subdirectory cache or in the per-slot dir-entry cache.
; Both ranges are checked independently because, in default builds, the
; kernel root cache (~13MB) sits BELOW the L3 app arena (16MB+), so the old
; jnc-chained layout sent every slot pointer down the kernel-cache branch
; where it failed.
sc_validate_dir_entry_handle:
    ; --- kernel root-cache range ---
    mov rax, rdi
    sub rax, FAT16_ROOT_CACHE
    jc .vdeh_try_slot
    cmp rax, FAT16_ROOT_CACHE_SZ - DIR_ENTRY_SIZE
    ja .vdeh_try_slot
    test eax, DIR_ENTRY_SIZE - 1
    jnz .vdeh_try_slot
    mov eax, 1
    ret
.vdeh_try_slot:
    ; --- per-slot L3 dir-entry cache range ---
    mov rax, rdi
    sub rax, [rel l3_app_arena_base_v]
    jc .vdeh_fail
    cmp rax, [rel l3_app_arena_size_v]
    jae .vdeh_fail
    mov edx, eax
    and edx, APP_SLOT_SIZE - 1
    sub edx, L3_DIR_ENTRY_CACHE_OFF
    jc .vdeh_fail
    cmp edx, L3_DIR_ENTRY_CACHE_SZ - DIR_ENTRY_SIZE
    ja .vdeh_fail
    test edx, DIR_ENTRY_SIZE - 1
    jnz .vdeh_fail
    mov eax, 1
    ret
.vdeh_fail:
    xor eax, eax
    ret

; RDI=callback target -> EAX=1 if null or inside user-owned code/data.
sc_validate_callback_target:
    test rdi, rdi
    jz .vct_ok
    mov rsi, 16
    call sc_validate_user_range
    ret
.vct_ok:
    mov eax, 1
    ret
