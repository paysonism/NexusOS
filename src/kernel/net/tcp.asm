; ============================================================================
; NexusOS TCP protocol module
; ----------------------------------------------------------------------------
; Lightweight generic TCP foundation. The first exported TX path builds a
; standards-compliant SYN segment and sends it through IPv4/NIC abstractions;
; no NIC driver contains TCP knowledge.
; ============================================================================
bits 64

%include "net_driver.inc"

extern net_checksum
extern net_arp_resolve_ipv4
extern net_arp_resolved_mac_ptr
extern net_info
extern net_ipv4_tx_proto
extern net_nic_poll_rx
extern tick_count

section .text

; EDI = destination IPv4 as A.B.C.D packed, SI = destination port,
; DX = source port, R8 = pointer to next-hop destination MAC.
; Returns EAX=1 if the SYN was queued/sent.
global net_tcp_send_syn_l2
net_tcp_send_syn_l2:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    mov ebx, edi                         ; dst IPv4
    mov [rel net_tcp_connect_dst], edi
    mov [rel net_tcp_connect_dport], si
    mov [rel net_tcp_connect_sport], dx
    mov [rel net_tcp_next_hop_mac_ptr], r8

    lea rdi, [rel net_tcp_segment]
    mov ecx, 20
    xor eax, eax
    rep stosb

    mov ax, dx                           ; source port
    xchg al, ah
    mov [rel net_tcp_segment + 0], ax
    mov ax, si                           ; destination port
    xchg al, ah
    mov [rel net_tcp_segment + 2], ax
    inc dword [rel net_tcp_iss]
    mov eax, [rel net_tcp_iss]
    mov [rel net_tcp_connect_iss], eax
    bswap eax
    mov [rel net_tcp_segment + 4], eax
    mov dword [rel net_tcp_segment + 8], 0
    mov byte [rel net_tcp_segment + 12], 0x50
    mov byte [rel net_tcp_segment + 13], 0x02 ; SYN
    mov word [rel net_tcp_segment + 14], 0xF0FA
    mov word [rel net_tcp_segment + 16], 0
    mov word [rel net_tcp_segment + 18], 0

    call net_tcp_finish_send_current
    jmp .done
.done:
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

; EDI = destination IPv4 as A.B.C.D packed, SI = destination port,
; DX = source port. Resolves the current next-hop with generic ARP, then sends
; a SYN. Returns EAX=1 if the SYN was queued/sent.
global net_tcp_connect_ipv4
net_tcp_connect_ipv4:
    push rdx
    push rsi
    push rdi
    mov [rel net_tcp_connect_dst], edi
    mov [rel net_tcp_connect_dport], si
    mov [rel net_tcp_connect_sport], dx

    mov rdi, 6                           ; NI_NEXT_HOP
    call net_info
    test eax, eax
    jnz .have_hop
    mov rdi, 3                           ; NI_ROUTER
    call net_info
    test eax, eax
    jnz .have_hop
    mov eax, [rel net_tcp_connect_dst]
.have_hop:
    mov edi, eax
    call net_arp_resolve_ipv4
    test eax, eax
    jz .fail
    call net_arp_resolved_mac_ptr
    mov r8, rax
    mov edi, [rel net_tcp_connect_dst]
    mov si, [rel net_tcp_connect_dport]
    mov dx, [rel net_tcp_connect_sport]
    call net_tcp_send_syn_l2
    test eax, eax
    jz .done
    mov byte [rel net_tcp_state], 1       ; SYN_SENT
    mov rbx, [tick_count]
    add rbx, 200                         ; 2 seconds
.wait_synack:
    call net_nic_poll_rx
    cmp byte [rel net_tcp_state], 2       ; SYN_RCVD/ready to ACK
    je .send_final_ack
    mov rax, [tick_count]
    cmp rax, rbx
    jae .fail
    pause
    jmp .wait_synack
.send_final_ack:
    call net_tcp_send_final_ack
    test eax, eax
    jz .fail
    mov byte [rel net_tcp_state], 3       ; ESTABLISHED
    mov eax, 1
    jmp .done
.fail:
    xor eax, eax
.done:
    pop rdi
    pop rsi
    pop rdx
    ret

net_tcp_send_final_ack:
    push rbx
    push rcx
    push rdi
    lea rdi, [rel net_tcp_segment]
    mov ecx, 20
    xor eax, eax
    rep stosb
    mov ax, [rel net_tcp_connect_sport]
    xchg al, ah
    mov [rel net_tcp_segment + 0], ax
    mov ax, [rel net_tcp_connect_dport]
    xchg al, ah
    mov [rel net_tcp_segment + 2], ax
    mov eax, [rel net_tcp_connect_iss]
    inc eax
    bswap eax
    mov [rel net_tcp_segment + 4], eax
    mov eax, [rel net_tcp_remote_seq]
    inc eax
    bswap eax
    mov [rel net_tcp_segment + 8], eax
    mov byte [rel net_tcp_segment + 12], 0x50
    mov byte [rel net_tcp_segment + 13], 0x10 ; ACK
    mov word [rel net_tcp_segment + 14], 0xF0FA
    mov word [rel net_tcp_segment + 16], 0
    mov word [rel net_tcp_segment + 18], 0
    mov ebx, [rel net_tcp_connect_dst]
    call net_tcp_finish_send_current
    pop rdi
    pop rcx
    pop rbx
    ret

; EBX = destination IPv4, net_tcp_segment[0..19] prepared.
net_tcp_finish_send_current:
    call net_tcp_checksum_ipv4
    mov [rel net_tcp_segment + 16], ax
    lea rdi, [rel net_tcp_segment]
    mov ecx, 20
    mov esi, ebx
    mov rdx, [rel net_tcp_next_hop_mac_ptr]
    mov al, NET_IP_PROTO_TCP
    call net_ipv4_tx_proto
    ret

; Computes TCP checksum for net_tcp_segment[0..19].
; EBX = destination IPv4 as A.B.C.D packed. Returns network-order AX.
net_tcp_checksum_ipv4:
    push rcx
    push rdi
    push rsi
    lea rdi, [rel net_tcp_pseudo]
    mov ecx, 32
    xor eax, eax
    rep stosb
    mov rdi, 2                           ; NI_IP from SYS_NET_INFO
    call net_info
    bswap eax
    mov [rel net_tcp_pseudo + 0], eax
    mov eax, ebx
    bswap eax
    mov [rel net_tcp_pseudo + 4], eax
    mov byte [rel net_tcp_pseudo + 8], 0
    mov byte [rel net_tcp_pseudo + 9], NET_IP_PROTO_TCP
    mov word [rel net_tcp_pseudo + 10], 0x1400
    lea rsi, [rel net_tcp_segment]
    lea rdi, [rel net_tcp_pseudo + 12]
    mov ecx, 20
    rep movsb
    lea rdi, [rel net_tcp_pseudo]
    mov ecx, 32
    call net_checksum
    pop rsi
    pop rdi
    pop rcx
    ret

; RDI = IPv4 packet, ECX = IPv4 packet length. Returns EAX=1 if consumed.
global net_tcp_rx_ipv4
net_tcp_rx_ipv4:
    push rbx
    push rdx
    push rsi
    cmp ecx, 40
    jb .drop
    mov ebx, [rel net_tcp_connect_dst]
    bswap ebx
    cmp [rdi + 12], ebx                  ; source IP
    jne .drop
    movzx eax, byte [rdi]
    and eax, 0x0F
    shl eax, 2
    cmp eax, 20
    jb .drop
    cmp ecx, eax
    jbe .drop
    add rdi, rax
    sub ecx, eax
    cmp ecx, 20
    jb .drop
    mov ax, [rel net_tcp_connect_dport]
    xchg al, ah
    cmp [rdi + 0], ax                    ; source port
    jne .drop
    mov ax, [rel net_tcp_connect_sport]
    xchg al, ah
    cmp [rdi + 2], ax                    ; destination port
    jne .drop
    mov al, [rdi + 13]
    test al, 0x04                        ; RST
    jnz .rst
    mov dl, al
    and dl, 0x12                         ; SYN|ACK
    cmp dl, 0x12
    jne .drop
    mov eax, [rdi + 8]                   ; ACK number
    bswap eax
    mov edx, [rel net_tcp_connect_iss]
    inc edx
    cmp eax, edx
    jne .drop
    mov eax, [rdi + 4]                   ; remote sequence
    bswap eax
    mov [rel net_tcp_remote_seq], eax
    mov byte [rel net_tcp_state], 2
    mov eax, 1
    jmp .done
.rst:
    mov byte [rel net_tcp_state], 4
    xor eax, eax
    jmp .done
.drop:
    xor eax, eax
.done:
    pop rsi
    pop rdx
    pop rbx
    ret

section .bss
alignb 16
net_tcp_segment: resb 1500
net_tcp_pseudo:  resb 1536
net_tcp_iss:     resd 1
net_tcp_connect_dst:   resd 1
net_tcp_connect_dport: resw 1
net_tcp_connect_sport: resw 1
net_tcp_connect_iss:   resd 1
net_tcp_remote_seq:    resd 1
net_tcp_next_hop_mac_ptr: resq 1
net_tcp_state:         resb 1
