
; ----------------------------------------------------------------------------
; xml_text_runs - number of text runs in an element's mixed content.
;   rdi=node -> rax = run count (childcount+1), 0 if empty, -1 if bad node.
; ----------------------------------------------------------------------------
xml_text_runs:
    call xml_switch_to
    call xml_chk_node
    jc .bad
    call xml_node_ptr
    mov ecx, [rax + N_TAG_END]
    inc ecx
    mov edx, [rax + N_CEND]
    cmp edx, ecx
    jbe .zero
    mov edx, [rax + N_CHILD]
    mov eax, 1
.l:
    cmp edx, XML_NIL
    je .done
    push rdi
    push rax
    mov edi, edx
    call xml_node_ptr
    mov edx, [rax + N_SIB]
    pop rax
    pop rdi
    inc eax
    jmp .l
.done:
    ret
.zero:
    xor eax, eax
    ret
.bad:
    mov rax, -1
    ret

; ----------------------------------------------------------------------------
; xml_text_run - copy the Nth text run of an element's mixed content.
;   rdi=node, esi=run index, rcx=out, r8=max -> rax = bytes copied, -1 if bad.
;   A run is the text between consecutive child elements (or the boundaries).
;   A run that is a single CDATA section is returned unwrapped.
; ----------------------------------------------------------------------------
xml_text_run:
    call xml_switch_to
    push rbx
    push r12
    push r13
    push r14
    push r15
    push rbp
    mov r12d, esi
    mov r13, rcx
    mov r14, r8
    call xml_chk_node
    jc .bad
    call xml_node_ptr
    mov ebp, [rax + N_TAG_END]
    inc ebp                   ; content start
    mov r9d, [rax + N_CEND]   ; content end
    cmp r9d, ebp
    jbe .bad
    mov ebx, ebp              ; left  = content start (default)
    mov r15d, r9d             ; right = content end   (default)
    mov r10d, [rax + N_CHILD]
    xor r11d, r11d            ; child position counter
.walk:
    cmp r10d, XML_NIL
    je .bounds
    cmp r11d, r12d
    jne .chk_left
    mov edi, r10d
    call xml_node_ptr
    mov r15d, [rax + N_TAG_OFF]
    dec r15d                  ; '<' of child at run index -> right bound
.chk_left:
    mov ecx, r12d
    dec ecx
    cmp r11d, ecx
    jne .adv
    mov edi, r10d
    call xml_node_ptr
    mov ebx, [rax + N_PEND]   ; end of preceding child -> left bound
.adv:
    mov edi, r10d
    call xml_node_ptr
    mov r10d, [rax + N_SIB]
    inc r11d
    jmp .walk
.bounds:
    cmp r12d, r11d
    ja .bad                   ; run index past last gap
    mov edx, r15d
    sub edx, ebx
    js .bad
    mov rsi, [xml_base]
    add rsi, rbx
    cmp edx, 9
    jb .copy
    cmp byte [rsi + 0], '<'
    jne .copy
    cmp byte [rsi + 1], '!'
    jne .copy
    cmp byte [rsi + 2], '['
    jne .copy
    cmp byte [rsi + 3], 'C'
    jne .copy
    cmp byte [rsi + 4], 'D'
    jne .copy
    cmp byte [rsi + 5], 'A'
    jne .copy
    cmp byte [rsi + 6], 'T'
    jne .copy
    cmp byte [rsi + 7], 'A'
    jne .copy
    cmp byte [rsi + 8], '['
    jne .copy
    add rsi, 9
    sub edx, 9
    xor ecx, ecx
.cd_find:
    cmp ecx, edx
    jae .copy
    lea rax, [rsi + rcx]
    cmp byte [rax], ']'
    jne .cd_n
    lea r8d, [ecx + 2]
    cmp r8d, edx
    ja .cd_n
    cmp byte [rax + 1], ']'
    jne .cd_n
    cmp byte [rax + 2], '>'
    je .cd_done
.cd_n:
    inc ecx
    jmp .cd_find
.cd_done:
    mov edx, ecx
.copy:
    cmp r14, rdx
    jae .cl
    mov edx, r14d
.cl:
    mov rdi, r13
    mov ecx, edx
    cld
    rep movsb
    mov eax, edx
    jmp .done
.bad:
    mov rax, -1
.done:
    pop rbp
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

; ----------------------------------------------------------------------------
; xml_namespace - resolve a namespace prefix to its URI on a node or ancestor.
;   rdi=node, rsi=prefix ptr, rdx=prefix len (0 = default xmlns), rcx=out,
;   r8=omax -> rax = URI length, -1 if unbound.
; ----------------------------------------------------------------------------
xml_namespace:
    call xml_switch_to
xml_namespace_inner:             ; internal callers (already on the right slot)
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12, rdi
    mov r13, rcx
    mov r14, r8
    lea r15, [rel xml_ns_scratch]
    mov byte [r15 + 0], 'x'
    mov byte [r15 + 1], 'm'
    mov byte [r15 + 2], 'l'
    mov byte [r15 + 3], 'n'
    mov byte [r15 + 4], 's'
    mov ebx, 5
    test rdx, rdx
    jz .built
    mov byte [r15 + 5], ':'
    mov ebx, 6
    cmp rdx, 56
    jbe .pcap
    mov edx, 56
.pcap:
    xor ecx, ecx
.pcopy:
    cmp ecx, edx
    jae .built
    mov al, [rsi + rcx]
    mov [r15 + rbx], al
    inc ebx
    inc ecx
    jmp .pcopy
.built:
    mov r9, r12
.nwalk:
    cmp r9, 0
    jl .nf
    mov rdi, r9
    lea rsi, [rel xml_ns_scratch]
    mov edx, ebx
    mov rcx, r13
    mov r8, r14
    push r9
    call xml_attr_inner
    pop r9
    cmp rax, 0
    jge .done
    mov rdi, r9
    call xml_parent_inner
    mov r9, rax
    jmp .nwalk
.nf:
    mov rax, -1
.done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

; ----------------------------------------------------------------------------
; xml_node_namespace - resolve the namespace URI of a node's own tag prefix.
;   rdi=node, rcx=out, r8=omax -> rax = URI length, -1 if unbound/bad.
; ----------------------------------------------------------------------------
xml_node_namespace:
    call xml_switch_to
    push rbx
    push r12
    push r13
    push r14
    mov r12, rdi
    mov r13, rcx
    mov r14, r8
    call xml_chk_node
    jc .bad
    call xml_node_ptr
    mov r8d, [rax + N_TAG_OFF]
    mov r9d, [rax + N_TAG_LEN]
    mov r10, [xml_base]
    add r10, r8
    xor ebx, ebx
.find_colon:
    cmp ebx, r9d
    jae .no_colon
    cmp byte [r10 + rbx], ':'
    je .have_colon
    inc ebx
    jmp .find_colon
.no_colon:
    xor edx, edx
    xor esi, esi
    jmp .resolve
.have_colon:
    mov rsi, r10
    mov edx, ebx
.resolve:
    mov rdi, r12
    mov rcx, r13
    mov r8, r14
    call xml_namespace_inner
    jmp .done
.bad:
    mov rax, -1
.done:
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

; ----------------------------------------------------------------------------
; xml_entity_value - copy the replacement text of an internal-DTD entity.
;   rsi=name ptr, rdx=name len, rcx=out, r8=omax -> rax = bytes copied,
;   -1 if no such entity.
; ----------------------------------------------------------------------------
xml_entity_value:
    call xml_switch_to
    push rbx
    push r12
    push r13
    mov r12, rcx
    mov r13, r8
    xor ebx, ebx
.l:
    cmp ebx, [xml_ent_n]
    jae .nf
    lea rax, [rel xml_ent_name_len]
    mov eax, [rax + rbx * 4]
    cmp eax, edx
    jne .n
    lea rax, [rel xml_ent_name_off]
    mov eax, [rax + rbx * 4]
    mov r10, [xml_base]
    add r10, rax
    xor ecx, ecx
.c:
    cmp ecx, edx
    jae .match
    mov al, [r10 + rcx]
    cmp al, [rsi + rcx]
    jne .n
    inc ecx
    jmp .c
.n:
    inc ebx
    jmp .l
.match:
    lea rax, [rel xml_ent_val_len]
    mov ecx, [rax + rbx * 4]
    lea rax, [rel xml_ent_val_off]
    mov eax, [rax + rbx * 4]
    mov r10, [xml_base]
    add r10, rax
    mov edx, ecx
    cmp r13, rdx
    jae .cl
    mov edx, r13d
.cl:
    mov rsi, r10
    mov rdi, r12
    mov ecx, edx
    cld
    rep movsb
    mov eax, edx
    jmp .done
.nf:
    mov rax, -1
.done:
    pop r13
    pop r12
    pop rbx
    ret

%include "src/kernel/lib/xml_selftest.inc"


