; Input:  RSI = pointer to report data (after report ID if present)
;         EDI = bit offset of field
;         ESI is NOT modified (uses RSI from stack)
;         R8D = bit size of field (1-32)
; Output: EAX = extracted value (zero-extended)
; ============================================================================
; auto-wrapped (FN_BEGIN emits global): global hid_extract_field
FN_BEGIN hid_extract_field, 0, 0, FN_RET_SCALAR
    push rbx
    push rcx
    push rdx
    push rsi

    ; RSI = report data pointer (from stack, original)
    mov rsi, [rsp]              ; get original RSI from push

    ; Calculate byte offset and bit shift
    mov eax, edi
    shr eax, 3                  ; byte offset = bit_offset / 8
    add rsi, rax                ; point to starting byte

    mov ecx, edi
    and ecx, 7                  ; bit shift within byte = bit_offset % 8

    ; Read up to 4 bytes starting from this position
    xor eax, eax
    movzx edx, byte [rsi]
    mov eax, edx
    cmp r8d, 8
    jle .shift
    movzx edx, byte [rsi + 1]
    shl edx, 8
    or eax, edx
    cmp r8d, 16
    jle .shift
    movzx edx, byte [rsi + 2]
    shl edx, 16
    or eax, edx
    cmp r8d, 24
    jle .shift
    movzx edx, byte [rsi + 3]
    shl edx, 24
    or eax, edx

.shift:
    ; Shift right by bit offset within byte
    shr eax, cl

    ; Mask to field size
    mov ecx, r8d
    cmp ecx, 32
    jge .no_mask
    mov edx, 1
    shl edx, cl
    dec edx                     ; mask = (1 << size) - 1
    and eax, edx
.no_mask:

    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

; ============================================================================
; hid_extract_field_checked - Bounds-checked HID report field extraction
; Input:  RSI = pointer to report data
;         ECX = report data length in bytes
;         EDI = bit offset of field
;         R8D = bit size of field (1-32)
; Output: CF=0, EAX=value on success; CF=1, EAX=0 if invalid/out of report
; ============================================================================
; auto-wrapped (FN_BEGIN emits global): global hid_extract_field_checked
FN_BEGIN hid_extract_field_checked, 0, 0, FN_RET_SCALAR
    cmp r8d, 1
    jb .hef_fail
    cmp r8d, 32
    ja .hef_fail
    mov eax, ecx
    shl eax, 3
    mov edx, edi
    add edx, r8d
    jc .hef_fail
    cmp edx, eax
    ja .hef_fail
    call hid_extract_field
    clc
    ret
.hef_fail:
    xor eax, eax
    stc
    ret

; ============================================================================
; hid_extract_field_signed - Extract a signed field value
; Same as hid_extract_field but sign-extends the result
; ============================================================================
; auto-wrapped (FN_BEGIN emits global): global hid_extract_field_signed
FN_BEGIN hid_extract_field_signed, 0, 0, FN_RET_SCALAR
    push rcx
    call hid_extract_field

    ; Sign extend: if bit (size-1) is set, OR with upper bits
    mov ecx, r8d
    dec ecx                     ; bit position of sign bit
    bt eax, ecx
    jnc .positive
    ; Sign extend
    inc ecx                     ; back to size
    cmp ecx, 32
    jge .positive
    mov edx, 0xFFFFFFFF
    shl edx, cl
    or eax, edx
.positive:
    pop rcx
    ret

; auto-wrapped (FN_BEGIN emits global): global hid_extract_field_signed_checked
FN_BEGIN hid_extract_field_signed_checked, 0, 0, FN_RET_SCALAR
    push rcx
    call hid_extract_field_checked
    jc .signed_checked_ret

    ; Sign extend: if bit (size-1) is set, OR with upper bits
    mov ecx, r8d
    dec ecx
    bt eax, ecx
    jnc .signed_checked_ok
    inc ecx
    cmp ecx, 32
    jge .signed_checked_ok
    mov edx, 0xFFFFFFFF
    shl edx, cl
    or eax, edx
.signed_checked_ok:
    clc
.signed_checked_ret:
    pop rcx
    ret

; ============================================================================