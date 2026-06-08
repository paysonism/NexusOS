; ============================================================================
; NexusOS v3.0 - RTL8139 Ethernet + minimal ARP/ICMP probe
; ----------------------------------------------------------------------------
; QEMU user-net default: guest 10.0.2.15, gateway 10.0.2.2.
; Provides a serial-triggered ICMP echo request path for basic network bring-up.
; ============================================================================
bits 64

%include "constants.inc"
%include "net_driver.inc"

extern pci_read_conf_dword
extern pci_write_conf_dword
extern tick_count
extern debug_print
extern net_rx_frame

section .text

RTL_VENDOR      equ 0x10EC
RTL_DEVICE      equ 0x8139

RTL_IDR0        equ 0x00
RTL_TSD0        equ 0x10
RTL_TSAD0       equ 0x20
RTL_RBSTART     equ 0x30
RTL_CR          equ 0x37
RTL_CAPR        equ 0x38
RTL_CBR         equ 0x3A
RTL_IMR         equ 0x3C
RTL_ISR         equ 0x3E
RTL_TCR         equ 0x40
RTL_RCR         equ 0x44
RTL_CONFIG1     equ 0x52
RTL_MSR         equ 0x58       ; Media Status Register
RTL_BMCR        equ 0x62       ; MII Basic Mode Control
RTL_BMSR        equ 0x64       ; MII Basic Mode Status

RTL_MSR_LINKB   equ 0x04       ; 0 = link up (active-low)
RTL_BMCR_ANE    equ 0x1000     ; auto-negotiation enable
RTL_BMCR_RAN    equ 0x0200     ; restart auto-neg
RTL_BMSR_ANC    equ 0x0020     ; auto-neg complete
RTL_BMSR_LINK   equ 0x0004     ; link status

RTL_CR_BUFE     equ 0x01
RTL_CR_TE       equ 0x04
RTL_CR_RE       equ 0x08
RTL_CR_RST      equ 0x10

RTL_RX_BUF_ADDR equ 0x01B00000
RTL_TX_BUF_ADDR equ 0x01B04000
RTL_RX_BUF_LEN  equ 8192

; ============================================================================
; rtl8139_init - Locate and start a QEMU RTL8139 NIC.
; Returns EAX=1 if active, EAX=0 otherwise.
; ============================================================================
global rtl8139_init
rtl8139_init:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r12
    push r13
    push r14

    mov rsi, sz_net_start
    call debug_print
    lea rsi, [rel ser_net_init]
    call rtl_ser_puts

    call rtl8139_find
    test eax, eax
    jz .fail

    ; Power on, reset, and enable RX/TX.
    mov dx, [rtl_io_base]
    add dx, RTL_CONFIG1
    xor al, al
    out dx, al

    mov dx, [rtl_io_base]
    add dx, RTL_CR
    mov al, RTL_CR_RST
    out dx, al
    mov rbx, [tick_count]
    add rbx, 100
.rst_wait:
    in al, dx
    test al, RTL_CR_RST
    jz .rst_done
    mov rax, [tick_count]
    cmp rax, rbx
    jae .fail
    pause
    jmp .rst_wait
.rst_done:

    ; Read MAC address from IDR0..5.
    mov dx, [rtl_io_base]
    add dx, RTL_IDR0
    lea rdi, [rtl_mac]
    mov ecx, 6
.mac_loop:
    in al, dx
    mov [rdi], al
    inc dx
    inc rdi
    loop .mac_loop

    ; Clear DMA buffers.
    mov rdi, RTL_RX_BUF_ADDR
    mov ecx, (RTL_RX_BUF_LEN + 16 + 1500) / 8
    xor rax, rax
    rep stosq
    mov rdi, RTL_TX_BUF_ADDR
    mov ecx, 2048 / 8
    rep stosq

    ; RX buffer base.
    mov dx, [rtl_io_base]
    add dx, RTL_RBSTART
    mov eax, RTL_RX_BUF_ADDR
    out dx, eax

    ; Disable interrupts; this driver polls.
    mov dx, [rtl_io_base]
    add dx, RTL_IMR
    xor ax, ax
    out dx, ax
    mov dx, [rtl_io_base]
    add dx, RTL_ISR
    mov ax, 0xFFFF
    out dx, ax

    ; RCR: accept broadcast + physical-match packets, 8K ring, wrap.
    mov dx, [rtl_io_base]
    add dx, RTL_RCR
    mov eax, 0x0000F00E
    out dx, eax

    ; TCR: QEMU default-safe transmit config.
    mov dx, [rtl_io_base]
    add dx, RTL_TCR
    mov eax, 0x03000700
    out dx, eax

    mov dx, [rtl_io_base]
    add dx, RTL_CR
    mov al, RTL_CR_RE | RTL_CR_TE
    out dx, al

    ; Kick PHY auto-negotiation and wait for link.
    mov dx, [rtl_io_base]
    add dx, RTL_BMCR
    mov ax, RTL_BMCR_ANE | RTL_BMCR_RAN
    out dx, ax

    lea rsi, [rel ser_link_wait]
    call rtl_ser_puts
    mov rbx, [tick_count]
    add rbx, 500                         ; up to 5 s for link
.link_wait:
    mov dx, [rtl_io_base]
    add dx, RTL_MSR
    in al, dx
    test al, RTL_MSR_LINKB
    jz .link_up
    mov rax, [tick_count]
    cmp rax, rbx
    jae .link_timeout
    pause
    jmp .link_wait
.link_timeout:
    lea rsi, [rel ser_link_timeout]
    call rtl_ser_puts
    jmp .link_done
.link_up:
    lea rsi, [rel ser_link_up]
    call rtl_ser_puts
    ; Wait briefly for auto-neg complete bit too (best-effort).
    mov rbx, [tick_count]
    add rbx, 100
.anc_wait:
    mov dx, [rtl_io_base]
    add dx, RTL_BMSR
    in ax, dx
    test ax, RTL_BMSR_ANC
    jnz .link_done
    mov rax, [tick_count]
    cmp rax, rbx
    jae .link_done
    pause
    jmp .anc_wait
.link_done:

    mov word [rtl_rx_off], 0
    mov byte [rtl_active], 1
    mov rsi, sz_net_ready
    call debug_print
    lea rsi, [rel ser_net_ready]
    call rtl_ser_puts
    mov eax, 1
    jmp .done

.fail:
    mov byte [rtl_active], 0
    mov rsi, sz_net_fail
    call debug_print
    lea rsi, [rel ser_net_init_fail]
    call rtl_ser_puts
    xor eax, eax
.done:
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

; ============================================================================
; rtl8139_icmp_ping_gateway - ARP 10.0.2.2 then send ICMP echo.
; Returns EAX=1 on echo reply, EAX=0 on failure/timeout.
; ============================================================================
global rtl8139_icmp_ping_gateway
rtl8139_icmp_ping_gateway:
    mov dword [rtl_guest_ip], 0x0F02000A       ; 10.0.2.15
    mov dword [rtl_next_hop_ip], 0x0202000A    ; 10.0.2.2
    mov dword [rtl_target_ip], 0x0202000A      ; 10.0.2.2
    jmp rtl8139_icmp_ping_current

global rtl8139_icmp_ping_ics
rtl8139_icmp_ping_ics:
    mov dword [rtl_guest_ip], 0x3289A8C0       ; 192.168.137.50
    mov dword [rtl_next_hop_ip], 0x0189A8C0    ; 192.168.137.1
    mov dword [rtl_target_ip], 0x0189A8C0      ; 192.168.137.1
    jmp rtl8139_icmp_ping_current

; EDI = IPv4 address in host-order dotted-quad packing (A.B.C.D = 0xAABBCCDD).
; Runs DHCP first to obtain a real lease (works on QEMU user-net and any real
; DHCP-capable network); falls back to QEMU-static config if DHCP fails.
global rtl8139_icmp_ping_ipv4
rtl8139_icmp_ping_ipv4:
    push rdi
    cmp byte [rtl_active], 1
    je .have_nic
    call rtl8139_init
    test eax, eax
    jz .skip_dhcp
.have_nic:
    cmp byte [rtl_dhcp_bound], 1
    je .skip_dhcp
    call rtl8139_dhcp_configure
.skip_dhcp:
    pop rdi
    cmp byte [rtl_dhcp_bound], 1
    jne .static_cfg
    mov eax, [rtl_dhcp_ip]
    mov [rtl_guest_ip], eax
    mov eax, [rtl_dhcp_router]
    test eax, eax
    jnz .gw_ok
    mov eax, [rtl_dhcp_server]
.gw_ok:
    mov [rtl_next_hop_ip], eax
    jmp .set_target
.static_cfg:
    mov dword [rtl_guest_ip], 0x0F02000A       ; 10.0.2.15
    mov dword [rtl_next_hop_ip], 0x0202000A    ; 10.0.2.2
.set_target:
    mov eax, edi
    bswap eax
    mov [rtl_target_ip], eax
    jmp rtl8139_icmp_ping_current

rtl8139_icmp_ping_current:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r12

    cmp byte [rtl_active], 1
    je .active
    call rtl8139_init
    test eax, eax
    jz .fail
.active:
    mov rax, [tick_count]
    mov [rtl_ping_start_tick], rax
    mov byte [rtl_have_gw_mac], 0
    lea rsi, [rel ser_arp_send]
    call rtl_ser_puts
    call rtl8139_send_arp_gateway
    mov rbx, [tick_count]
    add rbx, 200
.arp_wait:
    call rtl8139_poll_rx
    cmp byte [rtl_have_gw_mac], 1
    je .got_arp
    mov rax, [tick_count]
    cmp rax, rbx
    jae .fail
    pause
    jmp .arp_wait
.got_arp:
    mov byte [rtl_ping_reply], 0
    lea rsi, [rel ser_icmp_send]
    call rtl_ser_puts
    call rtl8139_send_icmp_gateway
    mov rbx, [tick_count]
    add rbx, 200
.icmp_wait:
    call rtl8139_poll_rx
    cmp byte [rtl_ping_reply], 1
    je .ok
    mov rax, [tick_count]
    cmp rax, rbx
    jae .fail
    pause
    jmp .icmp_wait
.ok:
    mov rsi, sz_ping_ok
    call debug_print
    lea rsi, [rel ser_icmp_ok]
    call rtl_ser_puts
    mov eax, 1
    jmp .done
.fail:
    mov rsi, sz_ping_fail
    call debug_print
    lea rsi, [rel ser_icmp_fail]
    call rtl_ser_puts
    xor eax, eax
.done:
    pop r12
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

rtl8139_find:
    push rbx
    push rcx
    push rdx
    push r12
    push r13
    push r14
    xor r12d, r12d
.bus:
    cmp r12d, 256
    jae .nf
    xor r13d, r13d
.dev:
    cmp r13d, 32
    jae .next_bus
    xor r14d, r14d
.fn:
    cmp r14d, 8
    jae .next_dev
    mov eax, r12d
    shl eax, 16
    mov ebx, r13d
    shl ebx, 11
    or eax, ebx
    mov ebx, r14d
    shl ebx, 8
    or eax, ebx
    mov [rtl_pci_addr], eax
    call pci_read_conf_dword
    cmp ax, RTL_VENDOR
    jne .next_fn
    shr eax, 16
    cmp ax, RTL_DEVICE
    jne .next_fn

    ; Enable I/O space + bus mastering.
    mov eax, [rtl_pci_addr]
    or eax, 0x04
    call pci_read_conf_dword
    or eax, 0x0005
    mov ecx, eax
    mov eax, [rtl_pci_addr]
    or eax, 0x04
    call pci_write_conf_dword

    ; BAR0 is I/O space for rtl8139.
    mov eax, [rtl_pci_addr]
    or eax, 0x10
    call pci_read_conf_dword
    and eax, 0xFFFFFFFC
    mov [rtl_io_base], ax
    mov eax, 1
    jmp .done
.next_fn:
    inc r14d
    jmp .fn
.next_dev:
    inc r13d
    jmp .dev
.next_bus:
    inc r12d
    jmp .bus
.nf:
    xor eax, eax
.done:
    pop r14
    pop r13
    pop r12
    pop rdx
    pop rcx
    pop rbx
    ret

rtl8139_send_arp_gateway:
    push rax
    push rcx
    push rsi
    push rdi
    mov rdi, RTL_TX_BUF_ADDR
    mov ecx, 60
    xor eax, eax
    rep stosb
    mov rdi, RTL_TX_BUF_ADDR
    mov ecx, 6
    mov al, 0xFF
    rep stosb
    lea rsi, [rtl_mac]
    mov ecx, 6
    rep movsb
    mov word [rdi], 0x0608             ; ethertype ARP
    add rdi, 2
    mov word [rdi], 0x0100             ; Ethernet
    mov word [rdi + 2], 0x0008         ; IPv4
    mov byte [rdi + 4], 6
    mov byte [rdi + 5], 4
    mov word [rdi + 6], 0x0100         ; request
    lea rsi, [rtl_mac]
    mov rdi, RTL_TX_BUF_ADDR + 22
    mov ecx, 6
    rep movsb
    mov eax, [rtl_guest_ip]
    mov dword [abs RTL_TX_BUF_ADDR + 28], eax
    mov qword [abs RTL_TX_BUF_ADDR + 32], 0
    mov eax, [rtl_next_hop_ip]
    mov dword [abs RTL_TX_BUF_ADDR + 38], eax
    mov ecx, 60
    call rtl8139_tx
    pop rdi
    pop rsi
    pop rcx
    pop rax
    ret

rtl8139_send_icmp_gateway:
    push rax
    push rbx
    push rcx
    push rsi
    push rdi
    mov rdi, RTL_TX_BUF_ADDR
    mov ecx, 60
    xor eax, eax
    rep stosb
    mov rdi, RTL_TX_BUF_ADDR
    lea rsi, [rtl_gw_mac]
    mov ecx, 6
    rep movsb
    lea rsi, [rtl_mac]
    mov ecx, 6
    rep movsb
    mov word [rdi], 0x0008             ; ethertype IPv4
    add rdi, 2
    ; IPv4 header at +14
    mov byte [abs RTL_TX_BUF_ADDR + 14], 0x45
    mov byte [abs RTL_TX_BUF_ADDR + 15], 0
    mov word [abs RTL_TX_BUF_ADDR + 16], 0x1C00 ; 28 bytes
    mov word [abs RTL_TX_BUF_ADDR + 18], 0x3412
    mov word [abs RTL_TX_BUF_ADDR + 20], 0
    mov byte [abs RTL_TX_BUF_ADDR + 22], 64
    mov byte [abs RTL_TX_BUF_ADDR + 23], 1      ; ICMP
    mov word [abs RTL_TX_BUF_ADDR + 24], 0
    mov eax, [rtl_guest_ip]
    mov dword [abs RTL_TX_BUF_ADDR + 26], eax
    mov eax, [rtl_target_ip]
    mov dword [abs RTL_TX_BUF_ADDR + 30], eax
    mov rdi, RTL_TX_BUF_ADDR + 14
    mov ecx, 20
    call net_checksum
    mov [abs RTL_TX_BUF_ADDR + 24], ax
    ; ICMP header at +34
    mov byte [abs RTL_TX_BUF_ADDR + 34], 8
    mov byte [abs RTL_TX_BUF_ADDR + 35], 0
    mov word [abs RTL_TX_BUF_ADDR + 36], 0
    mov word [abs RTL_TX_BUF_ADDR + 38], 0xBEEF
    inc word [rtl_ping_seq]
    mov ax, [rtl_ping_seq]
    xchg al, ah
    mov [abs RTL_TX_BUF_ADDR + 40], ax
    mov rdi, RTL_TX_BUF_ADDR + 34
    mov ecx, 8
    call net_checksum
    mov [abs RTL_TX_BUF_ADDR + 36], ax
    mov ecx, 60
    call rtl8139_tx
    pop rdi
    pop rsi
    pop rcx
    pop rbx
    pop rax
    ret

; ECX = frame length, frame at RTL_TX_BUF_ADDR.
rtl8139_tx:
    push rax
    push rbx
    push rdx
    mov dx, [rtl_io_base]
    add dx, RTL_TSAD0
    mov eax, RTL_TX_BUF_ADDR
    out dx, eax
    mov dx, [rtl_io_base]
    add dx, RTL_TSD0
    mov eax, ecx
    out dx, eax
    mov rbx, [tick_count]
    add rbx, 100
.wait:
    in eax, dx
    test eax, 0x00008000
    jnz .done
    mov rax, [tick_count]
    cmp rax, rbx
    jae .done
    pause
    jmp .wait
.done:
    pop rdx
    pop rbx
    pop rax
    ret

; Generic NIC ABI wrapper. RDI = complete Ethernet frame, ECX = length.
global rtl8139_net_tx_frame
rtl8139_net_tx_frame:
    push rcx
    push rsi
    push rdi
    push r8
    cmp byte [rtl_active], 1
    je .active
    call rtl8139_init
    test eax, eax
    jz .fail
.active:
    mov r8d, ecx
    mov rsi, rdi
    mov rdi, RTL_TX_BUF_ADDR
    cld
    rep movsb
    mov ecx, r8d
    call rtl8139_tx
    mov eax, 1
    jmp .done
.fail:
    xor eax, eax
.done:
    pop r8
    pop rdi
    pop rsi
    pop rcx
    ret

global rtl8139_net_poll_rx
rtl8139_net_poll_rx:
    cmp byte [rtl_active], 1
    jne .no_work
    call rtl8139_poll_rx
    mov eax, 1
    ret
.no_work:
    xor eax, eax
    ret

rtl8139_poll_rx:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    cmp byte [rtl_active], 1
    jne .done
.loop:
    mov dx, [rtl_io_base]
    add dx, RTL_CR
    in al, dx
    test al, RTL_CR_BUFE
    jnz .done
    movzx ebx, word [rtl_rx_off]
    lea rsi, [RTL_RX_BUF_ADDR + rbx]
    mov ax, [rsi]
    test ax, 1
    jz .advance
    movzx ecx, word [rsi + 2]
    cmp ecx, 14
    jb .advance
    lea rdi, [rsi + 4]
    call rtl8139_handle_frame
.advance:
    movzx eax, word [rsi + 2]
    add eax, 4
    add eax, 3
    and eax, 0xFFFFFFFC
    add ax, [rtl_rx_off]
    and ax, RTL_RX_BUF_LEN - 1
    mov [rtl_rx_off], ax
    mov dx, [rtl_io_base]
    add dx, RTL_CAPR
    sub ax, 16
    out dx, ax
    jmp .loop
.done:
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; RDI = Ethernet frame, ECX = frame length.
rtl8139_handle_frame:
    push rax
    push rcx
    push rsi
    push rdi
    push rcx
    call net_rx_frame
    pop rcx
    pop rdi
    cmp word [rdi + 12], 0x0608
    je .arp
    cmp word [rdi + 12], 0x0008
    je .ip
    jmp .done
.arp:
    cmp ecx, 42
    jb .done
    cmp word [rdi + 20], 0x0200        ; reply
    jne .done
    mov eax, [rtl_next_hop_ip]
    cmp dword [rdi + 28], eax
    jne .done
    lea rsi, [rdi + 22]
    lea rdi, [rtl_gw_mac]
    mov ecx, 6
    rep movsb
    mov byte [rtl_have_gw_mac], 1
    mov rsi, sz_arp_ok
    call debug_print
    lea rsi, [rel ser_arp_ok]
    call rtl_ser_puts
    jmp .done
.ip:
    cmp ecx, 42
    jb .done
    cmp byte [rdi + 23], 1             ; ICMP
    je .icmp
    cmp byte [rdi + 23], 17            ; UDP
    je .udp
    jmp .done
.icmp:
    mov eax, [rtl_target_ip]
    cmp dword [rdi + 26], eax
    jne .done
    mov eax, [rtl_guest_ip]
    cmp dword [rdi + 30], eax
    jne .done
    cmp byte [rdi + 34], 0             ; echo reply
    jne .done
    ; Capture TTL (IPv4 header offset 8 == frame+22) for net_info(NI_PING_LAST_TTL).
    mov al, [rdi + 22]
    mov [rtl_ping_last_ttl], al
    mov byte [rtl_ping_reply], 1
    jmp .done
.udp:
    call rtl8139_handle_udp
.done:
    pop rsi
    pop rcx
    pop rax
    ret

; ============================================================================
; DHCP client
; ============================================================================
global rtl8139_dhcp_configure
rtl8139_dhcp_configure:
    push rbx
    push rcx
    push rdx
    push rsi
    lea rsi, [rel ser_dhcp_start_8139]
    call rtl_ser_puts
    mov byte [rtl_dhcp_bound], 0
    mov byte [rtl_dhcp_state], 1
    mov byte [rtl_dhcp_offer_seen], 0
    mov byte [rtl_dhcp_ack_seen], 0
    inc dword [rtl_dhcp_xid]
    cmp dword [rtl_dhcp_xid], 0
    jne .xid_ok
    mov dword [rtl_dhcp_xid], 0x4E584448
.xid_ok:
    call rtl8139_send_dhcp_discover
    mov rbx, [tick_count]
    add rbx, 300
.offer_wait:
    call rtl8139_poll_rx
    cmp byte [rtl_dhcp_offer_seen], 1
    je .request
    mov rax, [tick_count]
    cmp rax, rbx
    jae .fail
    pause
    jmp .offer_wait
.request:
    lea rsi, [rel ser_dhcp_offer_8139]
    call rtl_ser_puts
    mov byte [rtl_dhcp_state], 2
    call rtl8139_send_dhcp_request
    mov rbx, [tick_count]
    add rbx, 200
.ack_wait:
    call rtl8139_poll_rx
    cmp byte [rtl_dhcp_ack_seen], 1
    je .ok
    mov rax, [tick_count]
    cmp rax, rbx
    jae .ack_timeout
    pause
    jmp .ack_wait
.ack_timeout:
    ; QEMU slirp sometimes does not ACK; treat OFFER as binding.
    cmp byte [rtl_dhcp_offer_seen], 1
    jne .fail
.ok:
    lea rsi, [rel ser_dhcp_ack_8139]
    call rtl_ser_puts
    mov byte [rtl_dhcp_bound], 1
    mov byte [rtl_dhcp_state], 3
    mov eax, 1
    jmp .done
.fail:
    lea rsi, [rel ser_dhcp_fail_8139]
    call rtl_ser_puts
    mov byte [rtl_dhcp_state], 4
    xor eax, eax
.done:
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

global rtl8139_send_dhcp_discover
rtl8139_send_dhcp_discover:
    push rax
    push rcx
    push rdi
    call rtl8139_build_dhcp_base
    mov rdi, RTL_TX_BUF_ADDR + 14 + 20 + 8 + 240
    mov byte [rdi + 0], 53
    mov byte [rdi + 1], 1
    mov byte [rdi + 2], 1                ; DISCOVER
    add rdi, 3
    mov byte [rdi + 0], 55
    mov byte [rdi + 1], 3
    mov byte [rdi + 2], 1
    mov byte [rdi + 3], 3
    mov byte [rdi + 4], 6
    add rdi, 5
    mov byte [rdi], 255
    mov rcx, rdi
    sub rcx, (RTL_TX_BUF_ADDR + 14 + 20 + 8)
    inc ecx
    call rtl8139_finish_dhcp_udp
    pop rdi
    pop rcx
    pop rax
    ret

global rtl8139_send_dhcp_request
rtl8139_send_dhcp_request:
    push rax
    push rcx
    push rdi
    call rtl8139_build_dhcp_base
    mov rdi, RTL_TX_BUF_ADDR + 14 + 20 + 8 + 240
    mov byte [rdi + 0], 53
    mov byte [rdi + 1], 1
    mov byte [rdi + 2], 3                ; REQUEST
    add rdi, 3
    mov byte [rdi + 0], 50
    mov byte [rdi + 1], 4
    mov eax, [rtl_dhcp_ip]
    mov [rdi + 2], eax
    add rdi, 6
    mov byte [rdi + 0], 54
    mov byte [rdi + 1], 4
    mov eax, [rtl_dhcp_server]
    mov [rdi + 2], eax
    add rdi, 6
    mov byte [rdi + 0], 55
    mov byte [rdi + 1], 3
    mov byte [rdi + 2], 1
    mov byte [rdi + 3], 3
    mov byte [rdi + 4], 6
    add rdi, 5
    mov byte [rdi], 255
    mov rcx, rdi
    sub rcx, (RTL_TX_BUF_ADDR + 14 + 20 + 8)
    inc ecx
    call rtl8139_finish_dhcp_udp
    pop rdi
    pop rcx
    pop rax
    ret

rtl8139_build_dhcp_base:
    push rax
    push rcx
    push rsi
    push rdi
    mov rdi, RTL_TX_BUF_ADDR
    mov ecx, 342
    xor eax, eax
    rep stosb
    mov rdi, RTL_TX_BUF_ADDR
    mov ecx, 6
    mov al, 0xFF
    rep stosb
    lea rsi, [rtl_mac]
    mov ecx, 6
    rep movsb
    mov word [rdi], 0x0008
    ; IPv4 header @ +14
    mov byte [abs RTL_TX_BUF_ADDR + 14], 0x45
    mov byte [abs RTL_TX_BUF_ADDR + 15], 0
    mov word [abs RTL_TX_BUF_ADDR + 18], 0x7856
    mov word [abs RTL_TX_BUF_ADDR + 20], 0
    mov byte [abs RTL_TX_BUF_ADDR + 22], 64
    mov byte [abs RTL_TX_BUF_ADDR + 23], 17
    mov word [abs RTL_TX_BUF_ADDR + 24], 0
    mov dword [abs RTL_TX_BUF_ADDR + 26], 0
    mov dword [abs RTL_TX_BUF_ADDR + 30], 0xFFFFFFFF
    ; UDP header @ +34
    mov word [abs RTL_TX_BUF_ADDR + 34], 0x4400  ; src 68
    mov word [abs RTL_TX_BUF_ADDR + 36], 0x4300  ; dst 67
    mov word [abs RTL_TX_BUF_ADDR + 40], 0       ; checksum 0 (optional)
    ; BOOTP @ +42
    mov rdi, RTL_TX_BUF_ADDR + 42
    mov byte [rdi + 0], 1
    mov byte [rdi + 1], 1
    mov byte [rdi + 2], 6
    mov byte [rdi + 3], 0
    mov eax, [rtl_dhcp_xid]
    mov [rdi + 4], eax
    mov word [rdi + 10], 0x0080              ; broadcast flag
    lea rsi, [rtl_mac]
    lea rdi, [rdi + 28]
    mov ecx, 6
    rep movsb
    mov dword [abs RTL_TX_BUF_ADDR + 42 + 236], 0x63538263 ; magic cookie
    pop rdi
    pop rsi
    pop rcx
    pop rax
    ret

; ECX = UDP payload length (DHCP message length from BOOTP start).
rtl8139_finish_dhcp_udp:
    push rax
    push rcx
    push rdi
    mov eax, ecx
    add eax, 8
    xchg al, ah
    mov [abs RTL_TX_BUF_ADDR + 38], ax       ; UDP length
    mov eax, ecx
    add eax, 8 + 20
    xchg al, ah
    mov [abs RTL_TX_BUF_ADDR + 16], ax       ; IP total length
    mov rdi, RTL_TX_BUF_ADDR + 14
    mov ecx, 20
    call net_checksum
    mov [abs RTL_TX_BUF_ADDR + 24], ax
    movzx ecx, word [abs RTL_TX_BUF_ADDR + 16]
    xchg cl, ch
    add ecx, 14
    cmp ecx, 60
    jae .len_ok
    mov ecx, 60
.len_ok:
    call rtl8139_tx
    pop rdi
    pop rcx
    pop rax
    ret

; RDI = Ethernet frame, ECX = len.
rtl8139_handle_udp:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push r8
    push r9
    cmp ecx, 282
    jb .done
    cmp word [rdi + 34], 0x4300              ; src port 67
    jne .done
    cmp word [rdi + 36], 0x4400              ; dst port 68
    jne .done
    mov eax, [rtl_dhcp_xid]
    cmp [rdi + 46], eax
    jne .done
    cmp dword [rdi + 278], 0x63538263
    jne .done
    mov eax, [rdi + 58]                      ; yiaddr
    mov [rtl_dhcp_candidate_ip], eax
    mov byte [rtl_dhcp_msg_type], 0
    mov dword [rtl_dhcp_candidate_server], 0
    mov dword [rtl_dhcp_candidate_router], 0
    mov dword [rtl_dhcp_candidate_dns], 0
    lea rsi, [rdi + 282]
    mov r8, rdi
    add r8, rcx
.opt_loop:
    cmp rsi, r8
    jae .classify
    mov al, [rsi]
    cmp al, 255
    je .classify
    cmp al, 0
    je .opt_pad
    movzx edx, byte [rsi + 1]
    lea r9, [rsi + rdx + 2]
    cmp r9, r8
    ja .classify
    cmp al, 53
    je .msg_type
    cmp al, 54
    je .server_id
    cmp al, 3
    je .router
    cmp al, 6
    je .dns_server
    jmp .next_opt
.msg_type:
    cmp edx, 1
    jb .next_opt
    mov al, [rsi + 2]
    mov [rtl_dhcp_msg_type], al
    jmp .next_opt
.server_id:
    cmp edx, 4
    jb .next_opt
    mov eax, [rsi + 2]
    mov [rtl_dhcp_candidate_server], eax
    jmp .next_opt
.router:
    cmp edx, 4
    jb .next_opt
    mov eax, [rsi + 2]
    mov [rtl_dhcp_candidate_router], eax
    jmp .next_opt
.dns_server:
    cmp edx, 4
    jb .next_opt
    mov eax, [rsi + 2]
    mov [rtl_dhcp_candidate_dns], eax
.next_opt:
    mov rsi, r9
    jmp .opt_loop
.opt_pad:
    inc rsi
    jmp .opt_loop
.classify:
    cmp byte [rtl_dhcp_msg_type], 2
    je .offer
    cmp byte [rtl_dhcp_msg_type], 5
    je .ack
    jmp .done
.offer:
    mov eax, [rtl_dhcp_candidate_ip]
    test eax, eax
    jz .done
    mov [rtl_dhcp_ip], eax
    mov eax, [rtl_dhcp_candidate_server]
    mov [rtl_dhcp_server], eax
    mov eax, [rtl_dhcp_candidate_router]
    mov [rtl_dhcp_router], eax
    mov eax, [rtl_dhcp_candidate_dns]
    mov [rtl_dhcp_dns], eax
    mov byte [rtl_dhcp_offer_seen], 1
    jmp .done
.ack:
    mov eax, [rtl_dhcp_candidate_ip]
    test eax, eax
    jz .done
    mov [rtl_dhcp_ip], eax
    mov eax, [rtl_dhcp_candidate_server]
    test eax, eax
    jz .keep_server
    mov [rtl_dhcp_server], eax
.keep_server:
    mov eax, [rtl_dhcp_candidate_router]
    test eax, eax
    jz .keep_router
    mov [rtl_dhcp_router], eax
.keep_router:
    mov eax, [rtl_dhcp_candidate_dns]
    test eax, eax
    jz .keep_dns
    mov [rtl_dhcp_dns], eax
.keep_dns:
    mov byte [rtl_dhcp_ack_seen], 1
.done:
    pop r9
    pop r8
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

rtl_ser_putc:
    push rax
    push rdx
    mov dx, 0x3F8
    out dx, al
    pop rdx
    pop rax
    ret

rtl_ser_puts:
    push rax
    push rsi
.loop:
    mov al, [rsi]
    test al, al
    jz .done
    call rtl_ser_putc
    inc rsi
    jmp .loop
.done:
    pop rsi
    pop rax
    ret

section .data
sz_net_start db "NET: RTL8139 init", 0
sz_net_ready db "NET: RTL8139 ready", 0
sz_net_fail  db "NET: RTL8139 unavailable", 0
sz_arp_ok    db "NET: ARP gateway resolved", 0
sz_ping_ok   db "NET: ICMP echo reply from 10.0.2.2", 0
sz_ping_fail db "NET: ICMP ping failed", 0
ser_net_init db "[RTL INIT]", 10, 0
ser_net_ready db "[RTL READY]", 10, 0
ser_net_init_fail db "[RTL INIT FAIL]", 10, 0
ser_link_wait db "[LINK WAIT]", 10, 0
ser_link_up db "[LINK UP]", 10, 0
ser_link_timeout db "[LINK TIMEOUT]", 10, 0
ser_arp_send db "[ARP SEND]", 10, 0
ser_arp_ok db "[ARP OK]", 10, 0
ser_icmp_send db "[ICMP SEND]", 10, 0
ser_icmp_ok db "[ICMP OK]", 10, 0
ser_icmp_fail db "[ICMP FAIL]", 10, 0
ser_dhcp_start_8139 db "[DHCP DISC]", 10, 0
ser_dhcp_offer_8139 db "[DHCP OFFER]", 10, 0
ser_dhcp_ack_8139 db "[DHCP ACK]", 10, 0
ser_dhcp_fail_8139 db "[DHCP FAIL]", 10, 0
ser_dhcp_udp_hit db "[UDP]", 10, 0

section .bss
global rtl_active
global rtl_dhcp_bound
global rtl_dhcp_state
global rtl_dhcp_ip
global rtl_dhcp_router
global rtl_dhcp_server
global rtl_dhcp_dns
global rtl_guest_ip
global rtl_next_hop_ip
rtl_active:       resb 1
rtl_io_base:      resw 1
rtl_rx_off:       resw 1
rtl_pci_addr:     resd 1
global rtl8139_net_mac
rtl8139_net_mac:
rtl_mac:          resb 6
rtl_gw_mac:       resb 6
rtl_have_gw_mac:  resb 1
rtl_ping_reply:   resb 1
global rtl_ping_last_ttl
rtl_ping_last_ttl: resb 1
rtl_ping_seq:     resw 1
rtl_guest_ip:     resd 1
rtl_next_hop_ip:  resd 1
rtl_target_ip:    resd 1
global rtl_ping_start_tick
rtl_ping_start_tick: resq 1
rtl_dhcp_bound:          resb 1
global rtl_dhcp_offer_seen
rtl_dhcp_offer_seen:     resb 1
global rtl_dhcp_ack_seen
rtl_dhcp_ack_seen:       resb 1
rtl_dhcp_msg_type:       resb 1
global rtl_dhcp_xid
rtl_dhcp_xid:            resd 1
rtl_dhcp_state:          resb 1
rtl_dhcp_ip:             resd 1
rtl_dhcp_server:         resd 1
rtl_dhcp_router:         resd 1
rtl_dhcp_dns:            resd 1
rtl_dhcp_candidate_ip:   resd 1
rtl_dhcp_candidate_server: resd 1
rtl_dhcp_candidate_router: resd 1
rtl_dhcp_candidate_dns:  resd 1
global rtl8139_net_info
rtl8139_net_info:
    resb NET_NIC_INFO_SIZE
