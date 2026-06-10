section .text

; ----------------------------------------------------------------------------
; xml_switch_to ??? make the live parser state belong to the calling slot (r15).
; If the live context already belongs to r15, no-op. Otherwise the live block
; is saved back to the previous owner's pool entry and the target slot's saved
; context is loaded in. Preserves ALL caller registers (called as the first
; instruction of every public entry, before args in rdi/rsi are touched).
; ----------------------------------------------------------------------------
xml_switch_to:
    push rax
    push rcx
    push rsi
    push rdi
    push r8
    movzx r8d, r15b
    cmp r8d, APP_SLOT_COUNT
    jb .ok
    xor r8d, r8d                 ; out-of-range -> slot 0 (fail-safe)
.ok:
    mov eax, [rel xml_active_slot]
    cmp eax, r8d
    je .ret                      ; already live for this slot
    ; Save current live block back to the previous owner's pool entry.
    mov ecx, eax
    imul ecx, ecx, XML_STATE_SIZE
    lea rdi, [rel xml_state_pool]
    add rdi, rcx
    lea rsi, [rel xml_state_begin]
    mov ecx, XML_STATE_SIZE
    rep movsb
.load:
    mov ecx, r8d
    imul ecx, ecx, XML_STATE_SIZE
    lea rsi, [rel xml_state_pool]
    add rsi, rcx
    lea rdi, [rel xml_state_begin]
    mov ecx, XML_STATE_SIZE
    rep movsb
    mov [rel xml_active_slot], r8d
.ret:
    pop r8
    pop rdi
    pop rsi
    pop rcx
    pop rax
    ret

xml_free:
    call xml_switch_to
xml_free_inner:                  ; internal callers (already on the right slot)
    xor eax, eax
    mov [xml_node_n], rax
    mov [xml_err], eax
    mov [xml_err_off], rax
    mov [xml_doc_live], eax
    mov [xml_stack_n], eax
    mov [xml_ent_n], eax
    mov dword [xml_root_idx], XML_NIL
    ret

xml_last_error:
    call xml_switch_to
    mov eax, [xml_err]
    mov rdx, [xml_err_off]
    ret

xml_node_count:
    call xml_switch_to
    mov rax, [xml_node_n]
    ret

xml_set_error:
    ; edi=code, rsi=input pointer
    mov [xml_err], edi
    mov rax, rsi
    sub rax, [xml_base]
    mov [xml_err_off], rax
    xor eax, eax
    ret

xml_root:
    call xml_switch_to
    cmp dword [xml_doc_live], 0
    je .none
    mov eax, [xml_root_idx]
    cmp eax, XML_NIL
    je .none
    ret
.none:
    mov rax, -1
    ret

xml_chk_node:
    mov rcx, [xml_node_n]
    cmp rdi, rcx
    jae .bad
    clc
    ret
.bad:
    stc
    ret

xml_node_ptr:
    mov rax, rdi
    imul rax, XML_NODE_SIZE
    lea rcx, [rel xml_nodes]
    add rax, rcx
    ret

xml_tag:
    call xml_switch_to
    call xml_chk_node
    jc .bad
    ; Stable enough for in-document comparisons: first matching node index + 1.
    push rbx
    push r12
    call xml_node_ptr
    mov r11d, [rax + N_TAG_OFF]
    mov r12d, [rax + N_TAG_LEN]
    xor ebx, ebx
.scan:
    cmp rbx, [xml_node_n]
    jae .self
    mov rdi, rbx
    call xml_node_ptr
    cmp [rax + N_TAG_LEN], r12d
    jne .next
    mov esi, [rax + N_TAG_OFF]
    mov edi, r11d
    mov edx, r12d
    call xml_name_eq_off
    test eax, eax
    jnz .found
.next:
    inc ebx
    jmp .scan
.found:
    lea eax, [rbx + 1]
    pop r12
    pop rbx
    ret
.self:
    mov eax, r11d
    inc eax
    pop r12
    pop rbx
    ret
.bad:
    xor eax, eax
    ret

xml_first_child:
    call xml_switch_to
    call xml_chk_node
    jc .bad
    call xml_node_ptr
    mov eax, [rax + N_CHILD]
    cmp eax, XML_NIL
    je .bad
    ret
.bad:
    mov rax, -1
    ret

xml_next_sibling:
    call xml_switch_to
    call xml_chk_node
    jc .bad
    call xml_node_ptr
    mov eax, [rax + N_SIB]
    cmp eax, XML_NIL
    je .bad
    ret
.bad:
    mov rax, -1
    ret

xml_parent:
    call xml_switch_to
xml_parent_inner:                ; internal callers (already on the right slot)
    call xml_chk_node
    jc .bad
    call xml_node_ptr
    mov eax, [rax + N_PARENT]
    cmp eax, XML_NIL
    je .bad
    ret
.bad:
    mov rax, -1
    ret

xml_tag_name:
    call xml_switch_to
    push rbx
    push r12
    push r13
    mov rbx, rsi
    mov r12, rdx
    call xml_chk_node
    jc .bad
    call xml_node_ptr
    mov r8d, [rax + N_TAG_OFF]
    mov r9d, [rax + N_TAG_LEN]
    mov r13d, r9d
    cmp r12, r9
    jae .copy
    mov r13d, r12d
.copy:
    mov rsi, [xml_base]
    add rsi, r8
    mov rdi, rbx
    mov ecx, r13d
    cld
    rep movsb
    mov eax, r13d
    pop r13
    pop r12
    pop rbx
    ret
.bad:
    mov rax, -1
    pop r13
    pop r12
    pop rbx
    ret

xml_text:
    ; rdi=node, rsi=out, rdx=max
    call xml_switch_to
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12, rsi
    mov r13, rdx
    call xml_chk_node
    jc .bad
    call xml_node_ptr
    mov ebx, [rax + N_TAG_END]
    inc ebx
    mov r14, [xml_base]
    add r14, rbx
    cmp r14, [xml_end]
    jae .empty
    cmp byte [r14], '<'
    je .maybe_cdata
    xor r15d, r15d
.text_loop:
    cmp r14, [xml_end]
    jae .copy_text
    cmp byte [r14], '<'
    je .copy_text
    inc r14
    inc r15d
    jmp .text_loop
.maybe_cdata:
    cmp byte [r14 + 1], '!'
    jne .empty
    cmp byte [r14 + 2], '['
    jne .empty
    cmp byte [r14 + 3], 'C'
    jne .empty
    cmp byte [r14 + 4], 'D'
    jne .empty
    cmp byte [r14 + 5], 'A'
    jne .empty
    cmp byte [r14 + 6], 'T'
    jne .empty
    cmp byte [r14 + 7], 'A'
    jne .empty
    cmp byte [r14 + 8], '['
    jne .empty
    add r14, 9
    mov rbx, r14
    sub rbx, [xml_base]
    xor r15d, r15d
.cdata_loop:
    cmp r14, [xml_end]
    jae .copy_cdata
    cmp byte [r14], ']'
    jne .cdata_next
    cmp byte [r14 + 1], ']'
    jne .cdata_next
    cmp byte [r14 + 2], '>'
    je .copy_cdata
.cdata_next:
    inc r14
    inc r15d
    jmp .cdata_loop
.copy_cdata:
    jmp .copy_from_rbx
.copy_text:
    mov rbx, [xml_base]
    add rbx, [rax + N_TAG_END]
    inc rbx
    sub rbx, [xml_base]
.copy_from_rbx:
    mov edx, r15d
    cmp r13, rdx
    jae .copy_len
    mov edx, r13d
.copy_len:
    mov rsi, [xml_base]
    add rsi, rbx
    mov rdi, r12
    mov ecx, edx
    cld
    rep movsb
    mov eax, edx
    jmp .done
.empty:
    xor eax, eax
    jmp .done
.bad:
    mov rax, -1
.done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

xml_is_ws:
    cmp al, 32
    je .yes
    cmp al, 9
    je .yes
    cmp al, 10
    je .yes
    cmp al, 13
    je .yes
    xor eax, eax
    ret
.yes:
    mov eax, 1
    ret

xml_name_eq_off:
    ; edi=offset a, esi=offset b, edx=len
    push rbx
    mov r8, [xml_base]
    mov ebx, edx
.loop:
    test ebx, ebx
    jz .yes
    mov al, [r8 + rdi]
    cmp al, [r8 + rsi]
    jne .no
    inc edi
    inc esi
    dec ebx
    jmp .loop
.yes:
    mov eax, 1
    pop rbx
    ret
.no:
    xor eax, eax
    pop rbx
    ret

xml_user_name_eq:
    ; r8=input offset, r9=input len, rsi=user name, rdx=user len
    cmp r9, rdx
    jne .no
    push rbx
    xor ebx, ebx
    mov r10, [xml_base]
    add r10, r8
.loop:
    cmp rbx, rdx
    jae .yes
    mov al, [r10 + rbx]
    cmp al, [rsi + rbx]
    jne .pop_no
    inc ebx
    jmp .loop
.yes:
    mov eax, 1
    pop rbx
    ret
.pop_no:
    pop rbx
.no:
    xor eax, eax
    ret

xml_attr:
    ; rdi=node, rsi=name, rdx=nlen, rcx=out, r8=omax
    call xml_switch_to
xml_attr_inner:                  ; internal callers (already on the right slot)
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12, rsi
    mov r13, rdx
    mov r14, rcx
    mov r15, r8
    call xml_chk_node
    jc .not_found
    call xml_node_ptr
    mov ebx, [rax + N_TAG_OFF]
    add ebx, [rax + N_TAG_LEN]
    mov r11d, [rax + N_TAG_END]
    mov [xml_attr_tag_end], r11d
    mov r10, [xml_base]
.attr_loop:
    cmp ebx, [xml_attr_tag_end]
    jae .not_found
    mov al, [r10 + rbx]
    call xml_is_ws
    test eax, eax
    jz .attr_start
    inc ebx
    jmp .attr_loop
.attr_start:
    mov al, [r10 + rbx]
    cmp al, '/'
    je .not_found
    cmp al, '>'
    je .not_found
    mov r8d, ebx
.name_loop:
    cmp ebx, [xml_attr_tag_end]
    jae .not_found
    mov al, [r10 + rbx]
    cmp al, '='
    je .name_done
    cmp al, 32
    je .name_done
    cmp al, 9
    je .name_done
    inc ebx
    jmp .name_loop
.name_done:
    mov r9d, ebx
    sub r9d, r8d
.skip_eq_ws:
    cmp ebx, [xml_attr_tag_end]
    jae .not_found
    mov al, [r10 + rbx]
    cmp al, '='
    je .have_eq
    cmp al, 32
    je .skip_one
    cmp al, 9
    je .skip_one
    jmp .not_found
.skip_one:
    inc ebx
    jmp .skip_eq_ws
.have_eq:
    inc ebx
.skip_val_ws:
    cmp ebx, [xml_attr_tag_end]
    jae .not_found
    mov al, [r10 + rbx]
    cmp al, 32
    je .skip_val_one
    cmp al, 9
    je .skip_val_one
    jmp .quote
.skip_val_one:
    inc ebx
    jmp .skip_val_ws
.quote:
    mov al, [r10 + rbx]
    cmp al, '"'
    je .quoted
    cmp al, 39
    jne .not_found
.quoted:
    mov r11b, al
    inc ebx
    mov ecx, ebx
.value_loop:
    mov r10, [xml_base]
    add r10, rbx
    cmp r10, [xml_end]
    jae .not_found
    mov r10, [xml_base]
    mov al, [r10 + rbx]
    cmp al, r11b
    je .value_done
    inc ebx
    jmp .value_loop
.value_done:
    push r10
    push r11
    mov rsi, r12
    mov rdx, r13
    call xml_user_name_eq
    pop r11
    pop r10
    test eax, eax
    jnz .copy_value
    inc ebx
    mov r10, [xml_base]
    jmp .attr_loop
.copy_value:
    mov eax, ebx
    sub eax, ecx
    mov edx, eax
    cmp r15, rdx
    jae .copy_len
    mov edx, r15d
.copy_len:
    lea rsi, [r10 + rcx]
    mov rdi, r14
    mov ecx, edx
    cld
    rep movsb
    mov eax, edx
    jmp .done
.not_found:
    mov rax, -1
.done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

xml_link_node:
    ; edi=new idx, esi=parent or XML_NIL
    cmp esi, XML_NIL
    je .root
    push rdi
    mov edi, esi
    call xml_node_ptr
    pop rdi
    cmp dword [rax + N_CHILD], XML_NIL
    jne .sib
    mov [rax + N_CHILD], edi
    ret
.sib:
    mov ecx, [rax + N_CHILD]
.sib_loop:
    push rdi
    mov edi, ecx
    call xml_node_ptr
    pop rdi
    mov edx, [rax + N_SIB]
    cmp edx, XML_NIL
    je .sib_set
    mov ecx, edx
    jmp .sib_loop
.sib_set:
    mov [rax + N_SIB], edi
    ret
.root:
    cmp dword [xml_root_idx], XML_NIL
    jne .multi
    mov [xml_root_idx], edi
    xor eax, eax
    ret
.multi:
    mov eax, 9
    ret
