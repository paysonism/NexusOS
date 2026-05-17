; ============================================================================
; NexusOS XML parser - compact DOM subset
; ============================================================================
bits 64

global xml_parse
global xml_root
global xml_tag
global xml_tag_name
global xml_first_child
global xml_next_sibling
global xml_parent
global xml_attr
global xml_text
global xml_free
global xml_last_error
global xml_node_count
global xml_text_run
global xml_text_runs
global xml_namespace
global xml_node_namespace
global xml_entity_value

XML_MAX_NODES equ 8192
XML_NODE_SIZE equ 32
XML_MAX_DEPTH equ 64
XML_MAX_ENT   equ 64
XML_NIL       equ 0xFFFFFFFF

N_TAG_OFF equ 0
N_TAG_LEN equ 4
N_PARENT  equ 8
N_CHILD   equ 12
N_SIB     equ 16
N_TAG_END equ 20
N_CEND    equ 24      ; offset of '<' of this element's closing tag
N_PEND    equ 28      ; offset just past the whole element

section .bss
alignb 16
xml_nodes:    resb XML_MAX_NODES * XML_NODE_SIZE
xml_node_n:   resq 1
xml_root_idx: resd 1
xml_err:      resd 1
xml_err_off:  resq 1
xml_doc_live: resd 1
xml_base:     resq 1
xml_end:      resq 1
xml_attr_tag_end: resd 1
xml_stack:    resd XML_MAX_DEPTH
xml_stack_n:  resd 1
xml_ent_name_off: resd XML_MAX_ENT
xml_ent_name_len: resd XML_MAX_ENT
xml_ent_val_off:  resd XML_MAX_ENT
xml_ent_val_len:  resd XML_MAX_ENT
xml_ent_n:        resd 1
xml_ns_scratch:   resb 64

section .text

xml_free:
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
    mov eax, [xml_err]
    mov rdx, [xml_err_off]
    ret

xml_node_count:
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

xml_parse:
    push rbx
    push r12
    push r13
    push r14
    push r15
    call xml_free
    mov [xml_base], rdi
    lea rax, [rdi + rsi]
    mov [xml_end], rax
    mov rbx, rdi
.loop:
    cmp rbx, [xml_end]
    jae .finish
    cmp byte [rbx], '<'
    jne .next_char
    lea rsi, [rbx + 1]
    cmp rsi, [xml_end]
    jae .eof
    mov al, [rsi]
    cmp al, '/'
    je .close_tag
    cmp al, '!'
    je .bang
    cmp al, '?'
    je .pi
    jmp .open_tag
.next_char:
    cmp byte [rbx], '&'
    je .entity
    inc rbx
    jmp .loop
.entity:
    lea r12, [rbx + 1]
    mov r13, r12
.entity_find:
    cmp r13, [xml_end]
    jae .entity_err
    cmp byte [r13], ';'
    je .entity_check
    inc r13
    jmp .entity_find
.entity_check:
    cmp byte [r12], '#'
    je .entity_num
    mov r14, r13
    sub r14, r12
    cmp r14, 2
    jne .ent_not2
    cmp byte [r12], 'l'
    jne .ent_chk_gt
    cmp byte [r12 + 1], 't'
    je .entity_ok
    jmp .entity_custom
.ent_chk_gt:
    cmp byte [r12], 'g'
    jne .entity_custom
    cmp byte [r12 + 1], 't'
    je .entity_ok
    jmp .entity_custom
.ent_not2:
    cmp r14, 3
    jne .ent_not3
    cmp byte [r12], 'a'
    jne .entity_custom
    cmp byte [r12 + 1], 'm'
    jne .entity_custom
    cmp byte [r12 + 2], 'p'
    je .entity_ok
    jmp .entity_custom
.ent_not3:
    cmp r14, 4
    jne .entity_custom
    cmp byte [r12], 'q'
    je .ent_quot
    cmp byte [r12], 'a'
    je .ent_apos
    jmp .entity_custom
.ent_quot:
    cmp byte [r12 + 1], 'u'
    jne .entity_custom
    cmp byte [r12 + 2], 'o'
    jne .entity_custom
    cmp byte [r12 + 3], 't'
    je .entity_ok
    jmp .entity_custom
.ent_apos:
    cmp byte [r12 + 1], 'p'
    jne .entity_custom
    cmp byte [r12 + 2], 'o'
    jne .entity_custom
    cmp byte [r12 + 3], 's'
    je .entity_ok
    jmp .entity_custom
.entity_num:
    ; numeric character reference: &#NN; or &#xHH;
    lea r14, [r12 + 1]
    cmp r14, r13
    jae .entity_err
    mov al, [r14]
    cmp al, 'x'
    je .ent_hex
    cmp al, 'X'
    je .ent_hex
.ent_dec:
    cmp r14, r13
    jae .entity_ok
    mov al, [r14]
    cmp al, '0'
    jb .entity_err
    cmp al, '9'
    ja .entity_err
    inc r14
    jmp .ent_dec
.ent_hex:
    inc r14
    cmp r14, r13
    jae .entity_err
.ent_hex_loop:
    cmp r14, r13
    jae .entity_ok
    mov al, [r14]
    cmp al, '0'
    jb .entity_err
    cmp al, '9'
    jbe .ent_hex_ok
    cmp al, 'a'
    jb .ent_hex_upper
    cmp al, 'f'
    jbe .ent_hex_ok
    jmp .entity_err
.ent_hex_upper:
    cmp al, 'A'
    jb .entity_err
    cmp al, 'F'
    ja .entity_err
.ent_hex_ok:
    inc r14
    jmp .ent_hex_loop
.entity_custom:
    ; look up name [r12,r13) against internal-DTD entity definitions
    mov r14d, [xml_ent_n]
    test r14d, r14d
    jz .entity_err
    xor r8d, r8d
.ent_cust_loop:
    cmp r8d, r14d
    jae .entity_err
    mov r9, r13
    sub r9, r12
    lea r10, [rel xml_ent_name_len]
    mov r11d, [r10 + r8 * 4]
    cmp r9d, r11d
    jne .ent_cust_next
    lea r10, [rel xml_ent_name_off]
    mov ecx, [r10 + r8 * 4]
    mov r10, [xml_base]
    add r10, rcx
    xor ecx, ecx
.ent_cust_cmp:
    cmp ecx, r9d
    jae .entity_ok
    mov al, [r10 + rcx]
    cmp al, [r12 + rcx]
    jne .ent_cust_next
    inc ecx
    jmp .ent_cust_cmp
.ent_cust_next:
    inc r8d
    jmp .ent_cust_loop
.entity_ok:
    lea rbx, [r13 + 1]
    jmp .loop
.entity_err:
    mov edi, 8
    mov rsi, rbx
    call xml_set_error
    jmp .fail
.pi:
    add rbx, 2
.pi_loop:
    cmp rbx, [xml_end]
    jae .eof
    cmp byte [rbx], '?'
    jne .pi_next
    cmp byte [rbx + 1], '>'
    je .pi_done
.pi_next:
    inc rbx
    jmp .pi_loop
.pi_done:
    add rbx, 2
    jmp .loop
.bang:
    cmp byte [rbx + 2], '['
    je .cdata
    cmp byte [rbx + 2], 'D'
    je .doctype
    cmp byte [rbx + 2], '-'
    jne .bad_tag
    cmp byte [rbx + 3], '-'
    jne .bad_tag
    add rbx, 4
.comment_loop:
    cmp rbx, [xml_end]
    jae .comment_err
    cmp byte [rbx], '-'
    jne .comment_next
    cmp byte [rbx + 1], '-'
    jne .comment_next
    cmp byte [rbx + 2], '>'
    je .comment_done
.comment_next:
    inc rbx
    jmp .comment_loop
.comment_done:
    add rbx, 3
    jmp .loop
.cdata:
    cmp byte [rbx + 3], 'C'
    jne .bad_tag
    cmp byte [rbx + 4], 'D'
    jne .bad_tag
    cmp byte [rbx + 5], 'A'
    jne .bad_tag
    cmp byte [rbx + 6], 'T'
    jne .bad_tag
    cmp byte [rbx + 7], 'A'
    jne .bad_tag
    cmp byte [rbx + 8], '['
    jne .bad_tag
    add rbx, 9
.cdata_loop:
    cmp rbx, [xml_end]
    jae .comment_err
    cmp byte [rbx], ']'
    jne .cdata_next
    cmp byte [rbx + 1], ']'
    jne .cdata_next
    cmp byte [rbx + 2], '>'
    je .cdata_done
.cdata_next:
    inc rbx
    jmp .cdata_loop
.cdata_done:
    add rbx, 3
    jmp .loop
.doctype:
    ; <!DOCTYPE ...> - verify keyword, parse-and-skip (with internal subset)
    cmp byte [rbx + 3], 'O'
    jne .bad_tag
    cmp byte [rbx + 4], 'C'
    jne .bad_tag
    cmp byte [rbx + 5], 'T'
    jne .bad_tag
    cmp byte [rbx + 6], 'Y'
    jne .bad_tag
    cmp byte [rbx + 7], 'P'
    jne .bad_tag
    cmp byte [rbx + 8], 'E'
    jne .bad_tag
    add rbx, 9
.dt_scan:
    cmp rbx, [xml_end]
    jae .eof
    mov al, [rbx]
    cmp al, '>'
    je .dt_done
    cmp al, '['
    je .dt_subset
    inc rbx
    jmp .dt_scan
.dt_done:
    inc rbx
    jmp .loop
.dt_subset:
    inc rbx
.dt_sub:
    cmp rbx, [xml_end]
    jae .eof
    mov al, [rbx]
    cmp al, ']'
    je .dt_sub_end
    cmp al, '<'
    je .dt_markup
    inc rbx
    jmp .dt_sub
.dt_sub_end:
    inc rbx
    jmp .dt_scan
.dt_markup:
    cmp byte [rbx + 1], '?'
    je .dt_pi
    cmp byte [rbx + 1], '!'
    jne .dt_skipgt
    cmp byte [rbx + 2], '-'
    je .dt_comment
    cmp byte [rbx + 2], 'E'
    jne .dt_skipgt
    cmp byte [rbx + 3], 'N'
    jne .dt_skipgt
    cmp byte [rbx + 4], 'T'
    jne .dt_skipgt
    cmp byte [rbx + 5], 'I'
    jne .dt_skipgt
    cmp byte [rbx + 6], 'T'
    jne .dt_skipgt
    cmp byte [rbx + 7], 'Y'
    jne .dt_skipgt
    jmp .dt_entity
.dt_pi:
    add rbx, 2
.dt_pi_l:
    cmp rbx, [xml_end]
    jae .eof
    cmp byte [rbx], '?'
    jne .dt_pi_n
    cmp byte [rbx + 1], '>'
    je .dt_pi_d
.dt_pi_n:
    inc rbx
    jmp .dt_pi_l
.dt_pi_d:
    add rbx, 2
    jmp .dt_sub
.dt_comment:
    cmp byte [rbx + 3], '-'
    jne .bad_tag
    add rbx, 4
.dt_cm_l:
    cmp rbx, [xml_end]
    jae .comment_err
    cmp byte [rbx], '-'
    jne .dt_cm_n
    cmp byte [rbx + 1], '-'
    jne .dt_cm_n
    cmp byte [rbx + 2], '>'
    je .dt_cm_d
.dt_cm_n:
    inc rbx
    jmp .dt_cm_l
.dt_cm_d:
    add rbx, 3
    jmp .dt_sub
.dt_skipgt:
    cmp rbx, [xml_end]
    jae .eof
    cmp byte [rbx], '>'
    je .dt_skipgt_d
    inc rbx
    jmp .dt_skipgt
.dt_skipgt_d:
    inc rbx
    jmp .dt_sub
.dt_entity:
    ; <!ENTITY name "value"> - record into internal-DTD entity table
    lea r12, [rbx + 8]
.dte_ws1:
    cmp r12, [xml_end]
    jae .eof
    mov al, [r12]
    call xml_is_ws
    test eax, eax
    jz .dte_name
    inc r12
    jmp .dte_ws1
.dte_name:
    cmp byte [r12], '%'
    je .dte_abort
    mov r13, r12
.dte_name_l:
    cmp r13, [xml_end]
    jae .eof
    cmp byte [r13], '>'
    je .dte_abort
    mov al, [r13]
    call xml_is_ws
    test eax, eax
    jnz .dte_name_done
    inc r13
    jmp .dte_name_l
.dte_name_done:
    mov r14, r13
.dte_ws2:
    cmp r13, [xml_end]
    jae .eof
    mov al, [r13]
    call xml_is_ws
    test eax, eax
    jz .dte_val
    inc r13
    jmp .dte_ws2
.dte_val:
    mov al, [r13]
    cmp al, '"'
    je .dte_q
    cmp al, 39
    je .dte_q
    jmp .dte_abort
.dte_q:
    mov r15b, al
    inc r13
    mov r8, r13
.dte_val_l:
    cmp r13, [xml_end]
    jae .eof
    mov al, [r13]
    cmp al, r15b
    je .dte_val_done
    inc r13
    jmp .dte_val_l
.dte_val_done:
    mov ecx, [xml_ent_n]
    cmp ecx, XML_MAX_ENT
    jae .dte_store_skip
    mov r9, r12
    sub r9, [xml_base]
    lea r10, [rel xml_ent_name_off]
    mov [r10 + rcx * 4], r9d
    mov r9, r14
    sub r9, r12
    lea r10, [rel xml_ent_name_len]
    mov [r10 + rcx * 4], r9d
    mov r9, r8
    sub r9, [xml_base]
    lea r10, [rel xml_ent_val_off]
    mov [r10 + rcx * 4], r9d
    mov r9, r13
    sub r9, r8
    lea r10, [rel xml_ent_val_len]
    mov [r10 + rcx * 4], r9d
    inc dword [xml_ent_n]
.dte_store_skip:
    mov rbx, r13
.dte_abort:
    cmp rbx, [xml_end]
    jae .eof
    cmp byte [rbx], '>'
    je .dte_done
    inc rbx
    jmp .dte_abort
.dte_done:
    inc rbx
    jmp .dt_sub
.comment_err:
    mov edi, 7
    mov rsi, rbx
    call xml_set_error
    jmp .fail
.open_tag:
    lea r12, [rbx + 1]
    mov r13, r12
.tag_name:
    cmp r13, [xml_end]
    jae .eof
    mov al, [r13]
    cmp al, '>'
    je .tag_name_done
    cmp al, '/'
    je .tag_name_done
    cmp al, 32
    je .tag_name_done
    cmp al, 9
    je .tag_name_done
    cmp al, 10
    je .tag_name_done
    cmp al, 13
    je .tag_name_done
    inc r13
    jmp .tag_name
.tag_name_done:
    cmp r13, r12
    je .bad_tag
    mov r14, r13
    xor r15d, r15d
.find_gt:
    cmp r14, [xml_end]
    jae .eof
    cmp byte [r14], '>'
    je .got_gt
    inc r14
    jmp .find_gt
.got_gt:
    cmp r14, rbx
    jbe .not_self
    cmp byte [r14 - 1], '/'
    jne .not_self
    mov r15d, 1
.not_self:
    mov rax, [xml_node_n]
    cmp rax, XML_MAX_NODES
    jae .arena
    mov edi, eax
    inc qword [xml_node_n]
    push rdi
    call xml_node_ptr
    pop rdi
    mov rcx, r12
    sub rcx, [xml_base]
    mov [rax + N_TAG_OFF], ecx
    mov rcx, r13
    sub rcx, r12
    mov [rax + N_TAG_LEN], ecx
    mov dword [rax + N_CHILD], XML_NIL
    mov dword [rax + N_SIB], XML_NIL
    mov rcx, r14
    sub rcx, [xml_base]
    mov [rax + N_TAG_END], ecx
    inc ecx
    mov [rax + N_CEND], ecx
    mov [rax + N_PEND], ecx
    mov esi, XML_NIL
    mov ecx, [xml_stack_n]
    test ecx, ecx
    jz .parent_set
    mov esi, [xml_stack + rcx * 4 - 4]
.parent_set:
    mov [rax + N_PARENT], esi
    call xml_link_node
    cmp eax, 9
    je .multi_err
    test r15d, r15d
    jnz .open_done
    mov ecx, [xml_stack_n]
    cmp ecx, XML_MAX_DEPTH
    jae .arena
    mov [xml_stack + rcx * 4], edi
    inc dword [xml_stack_n]
.open_done:
    lea rbx, [r14 + 1]
    jmp .loop
.close_tag:
    lea r12, [rbx + 2]
    mov r13, r12
.close_name:
    cmp r13, [xml_end]
    jae .eof
    cmp byte [r13], '>'
    je .close_name_done
    inc r13
    jmp .close_name
.close_name_done:
    mov ecx, [xml_stack_n]
    test ecx, ecx
    jz .mismatch
    dec ecx
    mov [xml_stack_n], ecx
    mov edi, [xml_stack + rcx * 4]
    mov r15d, edi
    call xml_node_ptr
    mov edx, [rax + N_TAG_LEN]
    mov r8, r13
    sub r8, r12
    cmp edx, r8d
    jne .mismatch
    mov edi, [rax + N_TAG_OFF]
    mov rsi, r12
    sub rsi, [xml_base]
    call xml_name_eq_off
    test eax, eax
    jz .mismatch
    mov edi, r15d
    call xml_node_ptr
    mov rcx, rbx
    sub rcx, [xml_base]
    mov [rax + N_CEND], ecx
    lea rcx, [r13 + 1]
    sub rcx, [xml_base]
    mov [rax + N_PEND], ecx
    lea rbx, [r13 + 1]
    jmp .loop
.finish:
    cmp dword [xml_stack_n], 0
    jne .unclosed
    cmp dword [xml_root_idx], XML_NIL
    je .eof
    mov dword [xml_doc_live], 1
    mov eax, 1
    jmp .out
.eof:
    mov edi, 1
    mov rsi, rbx
    call xml_set_error
    jmp .fail
.bad_tag:
    mov edi, 2
    mov rsi, rbx
    call xml_set_error
    jmp .fail
.unclosed:
    mov edi, 3
    mov rsi, rbx
    call xml_set_error
    jmp .fail
.mismatch:
    mov edi, 4
    mov rsi, rbx
    call xml_set_error
    jmp .fail
.arena:
    mov edi, 5
    mov rsi, rbx
    call xml_set_error
    jmp .fail
.multi_err:
    mov edi, 9
    mov rsi, rbx
    call xml_set_error
.fail:
    xor eax, eax
.out:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

; ----------------------------------------------------------------------------
; xml_text_runs - number of text runs in an element's mixed content.
;   rdi=node -> rax = run count (childcount+1), 0 if empty, -1 if bad node.
; ----------------------------------------------------------------------------
xml_text_runs:
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
    call xml_attr
    pop r9
    cmp rax, 0
    jge .done
    mov rdi, r9
    call xml_parent
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
    call xml_namespace
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
