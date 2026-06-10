xml_parse:
    call xml_switch_to
    push rbx
    push r12
    push r13
    push r14
    push r15
    call xml_free_inner
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