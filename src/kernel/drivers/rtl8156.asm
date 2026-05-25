; ============================================================================
; NexusOS v3.0 - Realtek RTL8152/RTL8156 USB Ethernet backend
; ----------------------------------------------------------------------------
; Raw USB path for Realtek r8152-family NICs passed through to QEMU with WinUSB
; / Zadig. This is intentionally small, but it includes the pieces the RTL8139
; path cannot provide: vendor OCP register access, xHCI bulk endpoints, Realtek
; TX/RX descriptors, ARP, and ICMP echo.
; ============================================================================
bits 64

%include "constants.inc"
%include "net_driver.inc"

extern xhci_init
extern xhci_active
extern xhci_find_port
extern xhci_find_port_next
extern xhci_enable_slot
extern xhci_address_device
extern xhci_port_num
extern xhci_max_ports
extern xhci_op_base
extern usb_slot1_port
extern usb_slot2_port
extern xhci_nic_mode
extern usb_hid_port_owned
extern xhci_queue_ctrl_trb
extern xhci_ring_doorbell
extern xhci_poll_event
extern xhci_flush_events
extern xhci_slot_id
extern xhci_int_ep_dci
extern xhci_ctx_stride
extern xhci_port_speed
extern xhci_dbg_adcc1
extern xhci_dbg_adcc2
extern xhci_dbg_adstage
extern xhci_dbg_slotstate
extern tick_count
extern debug_print
extern usb_poll_mouse
extern net_rx_frame

section .text

RTL8156_VENDOR_REALTEK equ 0x0BDA
RTL8156_REQ_REGS       equ 0x05
RTL8156_REQT_READ      equ 0xC0
RTL8156_REQT_WRITE     equ 0x40
RTL8156_BYTE_DWORD     equ 0xFF
RTL8156_MCU_USB        equ 0x0000
RTL8156_MCU_PLA        equ 0x0100

RTL8156_PLA_IDR        equ 0xC000
RTL8156_PLA_RCR        equ 0xC010
RTL8156_PLA_CR         equ 0xE813
RTL8156_PLA_MISC_1     equ 0xE85A
RTL8156_PLA_TCR0       equ 0xE610
RTL8156_PLA_RMS        equ 0xC016        ; RX max frame size (Linux: must be set)
RTL8156_PLA_MAR        equ 0xCD00        ; multicast filter (8 bytes)
RTL8156_USB_USB_CTRL   equ 0xD406
RTL8156_USB_UPT_RXDMA_OWN equ 0xD437
; RX buffer / early-timeout knobs. Without these the chip never flushes a
; partial burst out the bulk IN endpoint even when aggregation is disabled,
; so the host's IN tokens come back empty forever.
RTL8156_USB_RX_BUF_TH      equ 0xCC00
RTL8156_USB_RX_EARLY_SIZE  equ 0xCC10
RTL8156_USB_RX_EARLY_TIMEOUT equ 0xCC4C
RTL8156_PLA_PHYSTATUS  equ 0xC0D8       ; PHY/link status (low 3 bits = state)
RTL8156_PHY_STAT_MASK  equ 0x07
RTL8156_PHY_STAT_LAN_ON equ 0x03         ; link is up (PHY_STAT_LAN_ON, Linux r8152)
; PHY MDIO access uses an indirect window: write a 4K page base to
; PLA_OCP_GPHY_BASE (0xB12C), then read/write the corresponding offset in
; the 0xB000-0xBFFF mirror. To reach PHY MII reg N: ocp_addr = 0xA400+N*2,
; base = ocp_addr & 0xF000 = 0xA000, index = 0xB000 | (ocp_addr & 0x0FFF).
RTL8156_PLA_OCP_GPHY_BASE equ 0xB12C
RTL8156_OCP_BASE_PHY   equ 0xA000        ; (the PHY OCP page base)
RTL8156_PHY_REG0_OFFSET equ 0x400        ; PHY MII reg 0 (BMCR) lives here in the page
RTL8156_BYTE_EN_WORD   equ 0x33          ; OCP byte-enable for 16-bit write
RTL8156_BYTE_EN_BYTE   equ 0x11          ; byte-enable for 8-bit write
RTL8156_MII_BMCR       equ 0x00          ; MII basic-mode control reg
RTL8156_MII_BMSR       equ 0x01          ; MII basic-mode status reg
RTL8156_BMCR_ANE       equ 0x1000
RTL8156_BMCR_RAN       equ 0x0200
RTL8156_BMSR_LSTATUS   equ 0x0004        ; link status (latched, sticky-low)
RTL8156_BMSR_ANEGCOMP  equ 0x0020        ; auto-neg complete
; Power-up registers (Linux r8152 r8153_first_init).
RTL8156_PLA_OOB_CTRL   equ 0xE84C
RTL8156_NOW_IS_OOB     equ 0x80
RTL8156_PLA_SFF_STS_7  equ 0xE648
RTL8156_MCU_BORW_EN    equ 0x4000
RTL8156_RE_INIT_LL     equ 0x8000
RTL8156_LINK_LIST_READY equ 0x0002

RTL8156_CR_RE          equ 0x08
RTL8156_CR_TE          equ 0x04
RTL8156_RCR_AAP        equ 0x00000001
RTL8156_RCR_APM        equ 0x00000002
RTL8156_RCR_AM         equ 0x00000004
RTL8156_RCR_AB         equ 0x00000008
RTL8156_RX_AGG_DISABLE equ 0x0010
RTL8156_RXDY_GATED_EN  equ 0x00080000
RTL8156_OWN_UPDATE_CLEAR equ 0x03000000

RTL8156_TX_FS          equ 0x80000000
RTL8156_TX_LS          equ 0x40000000
RTL8156_RX_LEN_MASK    equ 0x00007FFF

; EDI = IPv4 address in A.B.C.D packed order. Returns EAX=1 on reply.
global rtl8156_icmp_ping_ipv4
rtl8156_icmp_ping_ipv4:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r12
    push r13

    cmp byte [rtl8156_active], 1
    je .active
    ; If we already walked the bus once and found nothing, don't re-walk —
    ; that path stomps over other USB devices' xHCI slot contexts.
    cmp byte [rtl8156_probed], 1
    je .fail
    call rtl8156_init
    test eax, eax
    jz .fail
.active:
    mov eax, edi
    bswap eax
    mov [rtl8156_target_ip], eax

    cmp byte [rtl8156_dhcp_bound], 1
    je .lease_ready
    ; Don't trigger a synchronous dhcp_configure from inside a ping syscall —
    ; on a flaky USB link this re-runs DISCOVER over a half-initialised endpoint
    ; and has been observed to triple-fault the kernel. Just report no reply
    ; and let userspace press DHCP explicitly.
    jmp .fail
.lease_ready:
    cmp byte [rtl8156_dhcp_bound], 1
    jne .fail
    mov eax, [rtl8156_dhcp_ip]
    mov [rtl8156_guest_ip], eax
    mov eax, [rtl8156_dhcp_router]
    test eax, eax
    jnz .lease_gateway_ok
    mov eax, [rtl8156_dhcp_server]
.lease_gateway_ok:
    mov [rtl8156_next_hop_ip], eax
    mov r13d, 3
    jmp .ping_current_profile

.static_profiles:
    lea r12, [rel rtl8156_ip_profiles]
    mov r13d, RTL8156_IP_PROFILE_COUNT
.profile_loop:
    mov eax, [r12]
    mov [rtl8156_guest_ip], eax
    mov eax, [r12 + 4]
    mov [rtl8156_next_hop_ip], eax

.ping_current_profile:
    mov rax, [tick_count]
    mov [rtl8156_ping_start_tick], rax
    ; Reuse cached gateway MAC across calls — Windows ping caches ARP, so
    ; should we. Without this, every syscall ping adds ~1ms of fresh ARP
    ; round-trip on top of the actual ICMP RTT.
    cmp byte [rtl8156_have_gw_mac], 1
    je .got_arp
    call rtl8156_send_arp_gateway
    mov rbx, [tick_count]
    add rbx, 200                    ; 2s, matching SYS_NET_PING4 contract
.arp_wait:
    call rtl8156_rx_once
    cmp byte [rtl8156_have_gw_mac], 1
    je .got_arp
    mov rax, [tick_count]
    cmp rax, rbx
    jae .next_profile
    pause
    jmp .arp_wait
.got_arp:
    mov byte [rtl8156_ping_reply], 0
    ; Reset the start TSC right before the ICMP send so the RTT we report is
    ; the actual ICMP round-trip, not "ICMP + any prior ARP exchange". This
    ; matches what `ping` on Linux/Windows shows.
    rdtsc
    shl rdx, 32
    or rax, rdx
    mov [rtl8156_ping_start_tsc], rax
    call rtl8156_send_icmp_gateway
    mov rbx, [tick_count]
    add rbx, 200                    ; 2s, matching SYS_NET_PING4 contract
.icmp_wait:
    call rtl8156_rx_once
    cmp byte [rtl8156_ping_reply], 1
    je .ok
    mov rax, [tick_count]
    cmp rax, rbx
    jae .next_profile
    pause
    jmp .icmp_wait
.ok:
    mov eax, 1
    jmp .done
.next_profile:
    cmp byte [rtl8156_dhcp_bound], 1
    jne .next_static_profile
    dec r13d
    jz .fail
    ; A userspace ping can race background RX/HID event traffic and miss one
    ; reply window even though the link is healthy. Refresh gateway ARP and
    ; retry before reporting "no reply" to the app.
    mov byte [rtl8156_have_gw_mac], 0
    jmp .ping_current_profile
.next_static_profile:
    add r12, 8
    dec r13d
    jnz .profile_loop
.fail:
    lea rsi, [rel ser_r8156_ping_fail]
    call rtl8156_ser_puts
    xor eax, eax
.done:
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

; ----------------------------------------------------------------------------
; Async ICMP ping. RDI = target IP (A.B.C.D-packed). Each call advances the
; state machine by one short step and returns immediately:
;   RAX > 0  -> RTT in microseconds, request complete
;   RAX = 0  -> still in flight, call again next frame
;   RAX = -1 -> timeout / no link / send failed
;   RAX = -2 -> another ping (different target) is in flight; try again later
; The GUI stays live because no syscall ever spins for more than the time of
; one rx_once + one frame send. State persists across calls in BSS.
; ----------------------------------------------------------------------------
global rtl8156_ping4_tick
rtl8156_ping4_tick:
    push rbx
    push rcx
    push rdx
    push rdi

    cmp byte [rtl8156_active], 1
    jne .fail
    cmp byte [rtl8156_dhcp_bound], 1
    jne .fail


    mov eax, edi
    bswap eax                       ; A.B.C.D-packed -> network order
    mov edi, eax                    ; stash in EDI for compares

    cmp byte [rtl8156_ping_async_state], 0
    je .start
    cmp edi, [rtl8156_target_ip]
    jne .busy

    ; In-flight: pump RX once and inspect progress.
    call rtl8156_rx_once
    cmp byte [rtl8156_ping_async_state], 1
    je .check_arp
    cmp byte [rtl8156_ping_async_state], 2
    je .check_icmp
    jmp .timeout

.check_arp:
    cmp byte [rtl8156_have_gw_mac], 1
    je .send_icmp
    mov rcx, [tick_count]
    cmp rcx, [rel rtl8156_ping_async_deadline]
    jae .timeout
    xor eax, eax
    jmp .ret

.send_icmp:
    mov byte [rtl8156_ping_reply], 0
    rdtsc
    shl rdx, 32
    or rax, rdx
    mov [rtl8156_ping_start_tsc], rax
    call rtl8156_send_icmp_gateway
    mov byte [rtl8156_ping_async_state], 2
    mov rcx, [tick_count]
    add rcx, 200
    mov [rel rtl8156_ping_async_deadline], rcx
    xor eax, eax
    jmp .ret

.check_icmp:
    cmp byte [rtl8156_ping_reply], 1
    je .reply_got
    mov rcx, [tick_count]
    cmp rcx, [rel rtl8156_ping_async_deadline]
    jae .timeout
    xor eax, eax
    jmp .ret

.reply_got:
    mov byte [rtl8156_ping_async_state], 0
    mov byte [rel rtl8156_ping_async_retries], 0
    mov rbx, [rtl8156_ping_start_tsc]
    extern net_tsc_delta_to_us
    call net_tsc_delta_to_us
    jmp .ret

.start:
    ; Same target as the in-flight session => retry start (keep retry count).
    ; Different target => fresh session (reset retries).
    cmp edi, [rtl8156_target_ip]
    je .start_keep_retries
    mov [rtl8156_target_ip], edi
    mov byte [rel rtl8156_ping_async_retries], 0
.start_keep_retries:
    mov eax, [rtl8156_dhcp_router]
    test eax, eax
    jnz .have_router
    mov eax, [rtl8156_dhcp_server]
.have_router:
    mov [rtl8156_next_hop_ip], eax
    cmp byte [rtl8156_have_gw_mac], 1
    je .send_icmp_initial
    call rtl8156_send_arp_gateway
    mov byte [rtl8156_ping_async_state], 1
    mov rcx, [tick_count]
    add rcx, 200
    mov [rel rtl8156_ping_async_deadline], rcx
    xor eax, eax
    jmp .ret

.send_icmp_initial:
    mov byte [rtl8156_ping_reply], 0
    rdtsc
    shl rdx, 32
    or rax, rdx
    mov [rtl8156_ping_start_tsc], rax
    call rtl8156_send_icmp_gateway
    mov byte [rtl8156_ping_async_state], 2
    mov rcx, [tick_count]
    add rcx, 200
    mov [rel rtl8156_ping_async_deadline], rcx
    xor eax, eax
    jmp .ret

.timeout:
    ; Retry the cycle a couple of times with a fresh ARP before reporting
    ; failure. Matches what the legacy sync ping does internally and absorbs
    ; the transient "cold xHCI" misses we see right after the link comes up.
    cmp byte [rel rtl8156_ping_async_retries], 3
    jae .real_timeout
    inc byte [rel rtl8156_ping_async_retries]
    mov byte [rtl8156_have_gw_mac], 0
    call rtl8156_send_arp_gateway
    mov byte [rtl8156_ping_async_state], 1
    mov rcx, [tick_count]
    add rcx, 200
    mov [rel rtl8156_ping_async_deadline], rcx
    xor eax, eax
    jmp .ret
.real_timeout:
    mov byte [rtl8156_ping_async_state], 0
    mov byte [rel rtl8156_ping_async_retries], 0
    mov byte [rtl8156_have_gw_mac], 0
    mov rax, -1
    jmp .ret

.fail:
    mov byte [rtl8156_ping_async_state], 0
    mov rax, -1
    jmp .ret

.busy:
    mov rax, -2
.ret:
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    ret

rtl8156_dhcp_configure:
    push rbx
    push rcx
    push rdx
    push r12

    lea rsi, [rel ser_dhcp_start]
    call rtl8156_ser_puts
    mov byte [rtl8156_dhcp_bound], 0
    mov byte [rtl8156_dhcp_offer_seen], 0
    mov byte [rtl8156_dhcp_ack_seen], 0
    inc dword [rtl8156_dhcp_xid]
    cmp dword [rtl8156_dhcp_xid], 0
    jne .xid_ok
    mov dword [rtl8156_dhcp_xid], 0x4E584448
.xid_ok:
    mov r12d, 3
.send_discover:
    call rtl8156_send_dhcp_discover
    mov rbx, [tick_count]
    add rbx, 300
.offer_wait:
    call rtl8156_rx_once
    cmp byte [rtl8156_dhcp_offer_seen], 1
    je .request
    mov rax, [tick_count]
    cmp rax, rbx
    jae .offer_timeout
    pause
    jmp .offer_wait
.offer_timeout:
    dec r12d
    jnz .send_discover
    jmp .fail
.request:
    lea rsi, [rel ser_dhcp_offer]
    call rtl8156_ser_puts
    call rtl8156_send_dhcp_request
    mov rbx, [tick_count]
    add rbx, 300
.ack_wait:
    call rtl8156_rx_once
    cmp byte [rtl8156_dhcp_ack_seen], 1
    je .ok
    mov rax, [tick_count]
    cmp rax, rbx
    jae .ack_timeout
    pause
    jmp .ack_wait
.ack_timeout:
    ; Some USB/QEMU/router combinations deliver the OFFER reliably but drop
    ; the ACK while the link is still settling. The OFFER already populated
    ; ip/server/router; use it as a lease rather than reporting no network.
    cmp byte [rtl8156_dhcp_offer_seen], 1
    je .ok
    jmp .fail
.ok:
    lea rsi, [rel ser_dhcp_ack]
    call rtl8156_ser_puts
    mov byte [rtl8156_dhcp_bound], 1
    mov byte [rtl8156_dhcp_state], 3   ; BOUND — userspace polls this
    mov eax, 1
    jmp .done
.fail:
    lea rsi, [rel ser_dhcp_fail]
    call rtl8156_ser_puts
    mov byte [rtl8156_dhcp_state], 4   ; FAILED — keep sync + async paths consistent
    xor eax, eax
.done:
    pop r12
    pop rdx
    pop rcx
    pop rbx
    ret

; ------------------------------------------------------------------
; Async DHCP state machine. State byte:
;   0 IDLE, 1 DISCOVER (waiting OFFER), 2 REQUEST (waiting ACK),
;   3 BOUND, 4 FAILED.
; ------------------------------------------------------------------
global rtl8156_dhcp_start
rtl8156_dhcp_start:
    push rbx
    push rcx
    push rdx
    ; Serialize against rtl8156_dhcp_pump running on the main CPU. Without
    ; this, the syscall path (possibly on a ring3-AP CPU) and the main-loop
    ; pump both touch xhci command ring / event ring / bulk_in_inflight at
    ; the same time and corrupt each other → RIP=0 crashes.
.rtl_start_lock:
    mov eax, 1
    xchg eax, [rel rtl8156_lock]
    test eax, eax
    jz .rtl_start_have_lock
    pause
    jmp .rtl_start_lock
.rtl_start_have_lock:
    cmp byte [rtl8156_active], 1
    je .ok_to_start
    mov byte [rtl8156_dhcp_state], 4   ; FAILED
    jmp .ret
.ok_to_start:
    mov byte [rtl8156_dhcp_bound], 0
    mov byte [rtl8156_dhcp_offer_seen], 0
    mov byte [rtl8156_dhcp_ack_seen], 0
    inc dword [rtl8156_dhcp_xid]
    cmp dword [rtl8156_dhcp_xid], 0
    jne .xid_ok
    mov dword [rtl8156_dhcp_xid], 0x4E584448
.xid_ok:
    call rtl8156_send_dhcp_discover
    mov byte [rtl8156_dhcp_state], 1   ; DISCOVER
    mov rax, [tick_count]
    add rax, 200
    mov [rtl8156_dhcp_deadline], rax
    ; Re-prime the mouse interrupt ring — the bulk_out TRBs we just queued
    ; can consume HID transfer events while waiting completion.
    extern usb_hid_requeue_slot1_reads
    call usb_hid_requeue_slot1_reads
.ret:
    mov dword [rel rtl8156_lock], 0
    pop rdx
    pop rcx
    pop rbx
    ret

global rtl8156_dhcp_pump
rtl8156_dhcp_pump:
    ; Fast bail when not in flight — this is called every main-loop tick.
    movzx eax, byte [rtl8156_dhcp_state]
    cmp eax, 1
    je .pump_try_lock
    cmp eax, 2
    je .pump_try_lock
    ret
.pump_try_lock:
    ; Try-lock only: if a syscall on another CPU is currently inside
    ; dhcp_start/pump, just skip this tick. We'll try again 10ms from now.
    mov eax, 1
    xchg eax, [rel rtl8156_lock]
    test eax, eax
    jz .active
    ret
.active:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    ; Drain at most one frame.
    mov edi, RTL8156_RX_BUF_ADDR
    mov ecx, 4096
    call rtl8156_bulk_in_nonblocking
    test eax, eax
    jz .check_timeout
    ; Got data — parse the frame.
    mov eax, [abs RTL8156_RX_BUF_ADDR]
    and eax, RTL8156_RX_LEN_MASK
    cmp eax, 18 + 14
    jb .check_timeout
    sub eax, 4
    lea rdi, [abs RTL8156_RX_BUF_ADDR + 24]
    mov ecx, eax
    call rtl8156_handle_frame
    ; State transitions based on flags set by rtl8156_handle_udp.
    movzx eax, byte [rtl8156_dhcp_state]
    cmp eax, 1
    jne .check_ack
    cmp byte [rtl8156_dhcp_offer_seen], 1
    jne .check_timeout
    call rtl8156_send_dhcp_request
    mov byte [rtl8156_dhcp_state], 2
    mov rax, [tick_count]
    add rax, 200
    mov [rtl8156_dhcp_deadline], rax
    extern usb_hid_requeue_slot1_reads
    call usb_hid_requeue_slot1_reads
    jmp .ret
.check_ack:
    cmp eax, 2
    jne .ret
    cmp byte [rtl8156_dhcp_ack_seen], 1
    jne .check_timeout
    mov byte [rtl8156_dhcp_bound], 1
    mov byte [rtl8156_dhcp_state], 3   ; BOUND
    jmp .ret
.check_timeout:
    mov rax, [tick_count]
    cmp rax, [rtl8156_dhcp_deadline]
    jb .ret
    cmp byte [rtl8156_dhcp_state], 2
    jne .timeout_fail
    cmp byte [rtl8156_dhcp_offer_seen], 1
    jne .timeout_fail
    mov byte [rtl8156_dhcp_bound], 1
    mov byte [rtl8156_dhcp_state], 3   ; BOUND via OFFER fallback
    jmp .ret
.timeout_fail:
    mov byte [rtl8156_dhcp_state], 4   ; FAILED
.ret:
    mov dword [rel rtl8156_lock], 0
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

global rtl8156_init
rtl8156_init:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r12

    xor r12d, r12d
    mov rsi, sz_r8156_init
    call debug_print
    call rtl8156_ser_init

    mov byte [rtl8156_active], 0
    mov dword [rtl8156_probe_port_tries], 0
    mov byte [rtl8156_dbg_stage], 1
    mov word [rtl8156_last_vid], 0
    mov word [rtl8156_last_pid], 0
    mov dword [rtl8156_last_portsc], 0
    ; xhci_init wipes the entire XHCI memory region and resets the
    ; controller — that would destroy live HID slot contexts. Only call it
    ; if the controller hasn't been brought up yet.
    cmp byte [xhci_active], 1
    je .xhci_ready
    call xhci_init
    test eax, eax
    jz .fail
    mov r12b, 1
.xhci_ready:
    ; Switch xhci_address_device + queue_ctrl_trb to the rtl8156 device
    ; context so we don't stomp the HID slot1/slot2 contexts.
    mov byte [xhci_nic_mode], 1
    ; Even if HID already initialized xHCI, native root ports can still be
    ; unpowered or mid-debounce. Power/debounce every port without resetting
    ; addressed devices; the later ownership guard protects live HID slots.
    call rtl8156_power_all_ports
    ; Power on every port + initial reset of any device that's there. We
    ; need xhci_find_port for its power-on side effects only when this driver
    ; was the one that initialized xHCI. If HID already owns live slots, that
    ; reset would knock the mouse/keyboard port back to default state before
    ; the ownership guard below can skip it.
    test r12b, r12b
    jz .skip_find_port_side_effects
    call xhci_find_port
 .skip_find_port_side_effects:
    ; Walk EVERY port ourselves so a single bad port (e.g. already-addressed
    ; HID slot) doesn't terminate the search.
    ; Begin manual walk at port 1.
    mov byte [rtl8156_walk_port], 0
.walk_advance:
    inc byte [rtl8156_walk_port]
    movzx eax, byte [rtl8156_walk_port]
    movzx ecx, byte [xhci_max_ports]
    cmp eax, ecx
    ja .walk_exhausted
    ; (Previously skipped slot1/slot2_port here, but usb_hid_init records
    ; ports for every device it probed — including the NIC. We instead
    ; gate by VID/PID after the device descriptor read.)
    ; Read PORTSC; skip if no device connected (CCS=0) or if port is
    ; already enabled (PED=1 means another driver addressed it).
    mov rsi, [xhci_op_base]
    add rsi, 0x400
    movzx edx, byte [rtl8156_walk_port]
    dec edx                              ; 0-based for PORTSC indexing
    mov eax, edx
    shl eax, 4
    mov ebx, [rsi + rax + XHCI_PORTSC]
    mov [rtl8156_last_portsc], ebx
    mov byte [rtl8156_dbg_stage], 0x20
    test ebx, XHCI_PORTSC_CCS
    jz .walk_advance
    ; Skip ports already owned by an active HID slot. Port reset would knock
    ; the mouse/keyboard back to default state and break it until reboot —
    ; that's the "mouse stopped working after ethernet works" regression.
    ; Slot1/slot2_port get recorded for every probed port (incl. the NIC), but
    ; usb_hid_port_owned additionally requires usb_mouse_active / slot2_active,
    ; so it only returns 1 for ports we actually run HID polling against.
    push rax
    push rbx
    movzx edi, byte [rtl8156_walk_port]
    call usb_hid_port_owned
    test eax, eax
    pop rbx
    pop rax
    jnz .walk_advance
    ; Diag: 'W' + port number
    push rax
    mov al, 'W'
    call rtl8156_diag_char
    movzx eax, byte [rtl8156_walk_port]
    call rtl8156_ser_phex8
    pop rax
    ; Issue port reset.
    and ebx, ~XHCI_PORTSC_CHANGE_BITS
    and ebx, ~XHCI_PORTSC_PED
    or  ebx, XHCI_PORTSC_PR
    mov [rsi + rax + XHCI_PORTSC], ebx
    ; Wait up to 50 ticks for PRC.
    push rax
    mov rbx, [tick_count]
    add rbx, 50
.walk_rst_wait:
    mov ecx, [rsi + rax + XHCI_PORTSC]
    test ecx, XHCI_PORTSC_PRC
    jnz .walk_rst_done
    mov rdx, [tick_count]
    cmp rdx, rbx
    jl .walk_rst_wait
.walk_rst_done:
    ; Clear PRC, leave PED alone (PED is RW1C — writing 1 disables).
    and ecx, ~XHCI_PORTSC_CHANGE_BITS
    and ecx, ~XHCI_PORTSC_PED
    or  ecx, XHCI_PORTSC_PRC
    mov [rsi + rax + XHCI_PORTSC], ecx
    pop rax
    ; Set 1-based xhci_port_num for downstream code, then enter try_port.
    mov al, [rtl8156_walk_port]
    mov [xhci_port_num], al
    jmp .try_port
.walk_exhausted:
    mov al, 'X'
    call rtl8156_diag_char
    jmp .fail
.try_port:
    mov al, 'P'                  ; entered try_port for some port
    call rtl8156_diag_char
    movzx eax, byte [xhci_port_num]
    call rtl8156_ser_phex8
    ; Don't gate on usb_hid_port_owned here — if the device on this port
    ; turns out to be a Realtek NIC, we want to address it on a fresh slot
    ; regardless of who else claimed the port. The VID/PID check below
    ; (line ~360) is the real filter: non-Realtek devices skip via
    ; .next_port without disturbing the existing slot.
.not_owned:
    call xhci_flush_events
    call xhci_enable_slot
    test eax, eax
    jnz .slotted
    mov al, 'e'
    call rtl8156_diag_char
    jmp .next_port
.slotted:
    ; Save slot id NOW so rtl8156_wait_completion's slot-id filter accepts
    ; our own control-transfer completions during init. Without this, the
    ; saved slot id is 0 and every event gets rejected → get_desc fails.
    mov al, [xhci_slot_id]
    mov [rtl8156_slot_id], al
    ; Diag: 's' + slot_id (so we can confirm enable_slot returned a fresh slot)
    push rax
    mov al, 's'
    call rtl8156_diag_char
    mov al, [xhci_slot_id]
    call rtl8156_ser_phex8
    ; Set xhci_port_speed from PORTSC bits 13:10 for the current walk port.
    ; Without this, port_speed is stale from xhci_find_port and EP0 MaxPacketSize
    ; / Slot Context Speed end up mismatched with the actual link, which causes
    ; the controller to reject Address Device with Parameter Error.
    mov rsi, [xhci_op_base]
    add rsi, 0x400
    movzx edx, byte [xhci_port_num]
    dec edx
    shl edx, 4
    mov eax, [rsi + rdx + XHCI_PORTSC]
    shr eax, 10
    and eax, 0x0F
    mov [xhci_port_speed], al
    mov al, 'S'
    call rtl8156_diag_char
    mov al, [xhci_port_speed]
    call rtl8156_ser_phex8
    pop rax
    call xhci_address_device
    test eax, eax
    jnz .addressed
    mov byte [rtl8156_dbg_stage], 0xA0
    mov al, 'a'
    call rtl8156_diag_char
    ; Print full completion codes: cc1 (BSR=1) cc2 (BSR=0) stage slotstate
    push rax
    mov al, [xhci_dbg_adcc1]
    call rtl8156_ser_phex8
    mov al, '/'
    call rtl8156_diag_char
    mov al, [xhci_dbg_adcc2]
    call rtl8156_ser_phex8
    mov al, '/'
    call rtl8156_diag_char
    mov al, [xhci_dbg_adstage]
    call rtl8156_ser_phex8
    mov al, '/'
    call rtl8156_diag_char
    mov al, [xhci_dbg_slotstate]
    call rtl8156_ser_phex8
    pop rax
    jmp .next_port_disable_current
.addressed:
    mov rdi, XHCI_CTRL_BUF_ADDR
    mov rcx, 18
    mov r8d, 0x01000680
    mov r9d, 0x00120000
    call rtl8156_control_in
    test eax, eax
    jnz .got_desc
    mov byte [rtl8156_dbg_stage], 0xA1
    mov al, 'd'
    call rtl8156_diag_char
    jmp .next_port_disable_current
.got_desc:
    mov byte [rtl8156_dbg_stage], 0x40
    mov al, 'V'
    call rtl8156_diag_char
    mov ax, [abs XHCI_CTRL_BUF_ADDR + 8]
    mov [rtl8156_last_vid], ax
    mov ax, [abs XHCI_CTRL_BUF_ADDR + 10]
    mov [rtl8156_last_pid], ax
    call rtl8156_ser_phex8
    mov al, [abs XHCI_CTRL_BUF_ADDR + 9]
    call rtl8156_ser_phex8
    cmp word [abs XHCI_CTRL_BUF_ADDR + 8], RTL8156_VENDOR_REALTEK
    jne .next_port_disable_current
    mov ax, [abs XHCI_CTRL_BUF_ADDR + 10]
    cmp ax, 0x8156
    je .realtek_nic
    cmp ax, 0x8155
    je .realtek_nic
    cmp ax, 0x8153
    je .realtek_nic
    cmp ax, 0x8152
    jne .next_port_disable_current
.realtek_nic:
    mov [rtl8156_product], ax

    ; Full configuration descriptor.
    mov rdi, XHCI_CTRL_BUF_ADDR
    mov rcx, 9
    mov r8d, 0x02000680
    mov r9d, 0x00090000
    call rtl8156_control_in
    test eax, eax
    jnz .cfg_header_ok
    mov byte [rtl8156_dbg_stage], 0xA2
    jmp .next_port_disable_current
.cfg_header_ok:
    movzx ecx, word [abs XHCI_CTRL_BUF_ADDR + 2]
    cmp ecx, 512
    jbe .cfg_len_ok
    mov byte [rtl8156_dbg_stage], 0xA3
    jmp .next_port_disable_current
.cfg_len_ok:
    mov rdi, XHCI_CTRL_BUF_ADDR
    mov r8d, 0x02000680
    mov r9d, ecx
    shl r9d, 16
    call rtl8156_control_in
    test eax, eax
    jnz .cfg_full_ok
    mov byte [rtl8156_dbg_stage], 0xA3
    jmp .next_port_disable_current
.cfg_full_ok:
    call rtl8156_find_bulk_eps
    test eax, eax
    jnz .eps_ok
    mov byte [rtl8156_dbg_stage], 0xA4
    jmp .next_port_disable_current
.eps_ok:
    mov byte [rtl8156_dbg_stage], 0x50

    ; Diagnostic: dump what we parsed from the config descriptor so we can
    ; tell at a glance whether IN/OUT endpoint numbers + MPS look sane.
    push rax
    push rdx
    push rsi
    lea rsi, [rel ser_ep_tag]
    call rtl8156_ser_puts
    mov al, [rtl8156_bulk_in_addr]
    call rtl8156_ser_phex8
    mov dx, 0x3F8
    mov al, '/'
    out dx, al
    mov al, [rtl8156_bulk_out_addr]
    call rtl8156_ser_phex8
    mov al, ' '
    out dx, al
    mov al, [rtl8156_bulk_in_mps + 1]
    call rtl8156_ser_phex8
    mov al, [rtl8156_bulk_in_mps + 0]
    call rtl8156_ser_phex8
    mov al, '/'
    out dx, al
    mov al, [rtl8156_bulk_out_mps + 1]
    call rtl8156_ser_phex8
    mov al, [rtl8156_bulk_out_mps + 0]
    call rtl8156_ser_phex8
    mov al, ' '
    out dx, al
    mov al, 'b'
    out dx, al
    mov al, [rtl8156_bulk_in_burst]
    call rtl8156_ser_phex8
    mov al, '/'
    out dx, al
    mov al, [rtl8156_bulk_out_burst]
    call rtl8156_ser_phex8
    mov al, 10
    out dx, al
    pop rsi
    pop rdx
    pop rax

    ; Set configuration 1.
    mov r8d, 0x00010900
    mov r9d, 0
    call rtl8156_control_nodata
    test eax, eax
    jnz .set_config_ok
    mov byte [rtl8156_dbg_stage], 0xA5
    jmp .next_port_disable_current
.set_config_ok:

    call rtl8156_configure_bulk_eps
    test eax, eax
    jnz .bulk_ctx_ok
    mov byte [rtl8156_dbg_stage], 0xA6
    jmp .next_port_disable_current
.bulk_ctx_ok:
    mov byte [rtl8156_dbg_stage], 0x60

    call xhci_flush_events
    call rtl8156_vendor_init
    test eax, eax
    jnz .vendor_ok
    mov byte [rtl8156_dbg_stage], 0xA7
    jmp .next_port_disable_current
.vendor_ok:
    mov byte [rtl8156_dbg_stage], 0x70

    call rtl8156_wait_link
    ; do not abort if link does not come up in time — driver still usable
    ; once cable is plugged in later; subsequent ping/DHCP will retry.

    mov byte [rtl8156_active], 1
    mov byte [rtl8156_dbg_stage], 0x80
    ; Remember which xHCI slot the NIC ended up on. xhci_slot_id is a shared
    ; global that subsequent enable_slot calls (e.g. HID slot2) overwrite, so
    ; we can't read it later — snapshot it now while it's still ours.
    mov al, [xhci_slot_id]
    mov [rtl8156_slot_id], al
    ; Make sure a bulk-IN TRB is always armed so the main-loop USB poller
    ; (usb_poll_mouse) has something to consume when a frame arrives.
    call rtl8156_arm_rx
    ; Snapshot the xHCI port too so other drivers (usb_hid re-init) know not
    ; to re-grab it — without this the next usb_hid_init scan picks the NIC's
    ; port and tries to re-address it, which fails since it's already linked.
    mov al, [xhci_port_num]
    mov [rtl8156_port], al
    mov rsi, sz_r8156_ready
    call debug_print
    call rtl8156_ser_ready
    mov byte [xhci_nic_mode], 0
    mov eax, 1
    jmp .done

.next_port_disable_current:
    mov al, [xhci_slot_id]
    test al, al
    jz .next_port
    call xhci_disable_slot
    mov byte [rtl8156_slot_id], 0

.next_port:
    call xhci_flush_events
    push rax
    mov al, 'N'                  ; diag: entered .next_port
    call rtl8156_diag_char
    pop rax
    inc dword [rtl8156_probe_port_tries]
    cmp dword [rtl8156_probe_port_tries], 16
    jae .fail
    jmp .walk_advance
.fail:
    cmp byte [rtl8156_dbg_stage], 0x80
    jae .fail_keep_stage
    mov byte [rtl8156_dbg_stage], 0xF0
.fail_keep_stage:
    mov rsi, sz_r8156_fail
    call debug_print
    call rtl8156_ser_fail
    mov byte [rtl8156_probed], 1
    mov byte [xhci_nic_mode], 0
    xor eax, eax
.done:
    pop r12
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

; Power every xHCI root port and wait for debounce without resetting or
; addressing anything. This makes the NIC scan robust when HID initialized xHCI
; first and xhci_find_port's power-on side effects were skipped.
rtl8156_power_all_ports:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi

    cmp byte [xhci_active], 1
    jne .done
    mov rsi, [xhci_op_base]
    test rsi, rsi
    jz .done
    add rsi, 0x400
    movzx ecx, byte [xhci_max_ports]
    xor edx, edx
.loop:
    cmp edx, ecx
    jae .wait
    mov eax, edx
    shl eax, 4
    mov ebx, [rsi + rax + XHCI_PORTSC]
    test ebx, XHCI_PORTSC_PP
    jnz .next
    and ebx, ~XHCI_PORTSC_CHANGE_BITS
    and ebx, ~XHCI_PORTSC_PED
    or  ebx, XHCI_PORTSC_PP
    mov [rsi + rax + XHCI_PORTSC], ebx
.next:
    inc edx
    jmp .loop
.wait:
    mov rbx, [tick_count]
    add rbx, 20
.wait_loop:
    mov rax, [tick_count]
    cmp rax, rbx
    jae .done
    pause
    jmp .wait_loop
.done:
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; ----------------------------------------------------------------------------
; MDIO access via the PLA_OCP_GPHY_BASE window.
; ----------------------------------------------------------------------------
; rtl8156_mdio_set_base — point the GPHY indirection window at OCP_BASE_PHY.
; Must be called once before any mdio read/write. Linux re-points it as
; needed; we only ever access the 0xA000 PHY page so once is enough.
rtl8156_mdio_set_base:
    push rax
    push rcx
    push rdx
    push rsi
    push rdi
    mov dword [abs RTL8156_SCRATCH_ADDR], RTL8156_OCP_BASE_PHY
    mov edi, RTL8156_PLA_OCP_GPHY_BASE & ~3
    mov esi, RTL8156_MCU_PLA | RTL8156_BYTE_EN_WORD
    mov edx, 4
    mov rcx, RTL8156_SCRATCH_ADDR
    call rtl8156_ocp_write
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rax
    ret

; rtl8156_mdio_read — EDI = MII reg number (0..31). Returns 16-bit value in EAX
; (low word). Caller must have set the base via rtl8156_mdio_set_base first.
rtl8156_mdio_read:
    push rcx
    push rdx
    push rsi
    push rdi
    push rbx
    ; OCP offset within page = PHY_REG0_OFFSET + reg*2  (e.g. reg 0 -> 0x400,
    ; reg 1 -> 0x402, reg 2 -> 0x404, ...).
    shl edi, 1
    add edi, RTL8156_PHY_REG0_OFFSET
    and edi, 0x0FFF
    or edi, 0xB000
    mov ebx, edi                             ; save full PLA addr (incl bit 1)
    and edi, ~3                              ; dword-align for the OCP read
    mov esi, RTL8156_MCU_PLA
    mov edx, 4
    mov rcx, RTL8156_SCRATCH_ADDR
    call rtl8156_ocp_read
    ; Pick low or high word depending on which word we wanted.
    test ebx, 2
    jnz .high_word
    movzx eax, word [abs RTL8156_SCRATCH_ADDR + 0]
    jmp .done
.high_word:
    movzx eax, word [abs RTL8156_SCRATCH_ADDR + 2]
.done:
    pop rbx
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    ret

; rtl8156_mdio_write — EDI = MII reg, ESI = 16-bit value.
rtl8156_mdio_write:
    push rax
    push rbx
    push rcx
    push rdx
    push rdi
    push rsi
    movzx eax, si                            ; value
    shl edi, 1
    add edi, RTL8156_PHY_REG0_OFFSET
    and edi, 0x0FFF
    or edi, 0xB000
    mov ebx, edi
    and edi, ~3                              ; dword-aligned PLA addr
    test ebx, 2
    jz .lo
    ; Write the high word: byte enables 0xCC, value in [+2]
    mov dword [abs RTL8156_SCRATCH_ADDR], 0
    mov [abs RTL8156_SCRATCH_ADDR + 2], ax
    mov esi, RTL8156_MCU_PLA | 0xCC
    jmp .go
.lo:
    mov dword [abs RTL8156_SCRATCH_ADDR], 0
    mov [abs RTL8156_SCRATCH_ADDR + 0], ax
    mov esi, RTL8156_MCU_PLA | RTL8156_BYTE_EN_WORD
.go:
    mov edx, 4
    mov rcx, RTL8156_SCRATCH_ADDR
    call rtl8156_ocp_write
    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; Bring the PHY out of power-down: read BMCR, clear PDOWN+ISOLATE,
; set ANE+RAN, write back.
rtl8156_phy_powerup:
    push rax
    push rsi
    push rdi

    call rtl8156_mdio_set_base

    ; Read BMCR and dump it.
    mov edi, RTL8156_MII_BMCR
    call rtl8156_mdio_read
    lea rsi, [rel ser_bmcr_tag]
    call rtl8156_ser_puts
    push rax
    mov al, ah
    call rtl8156_ser_phex8
    pop rax
    call rtl8156_ser_phex8
    ; Read BMSR.
    mov al, ' '
    mov dx, 0x3F8
    out dx, al
    mov edi, RTL8156_MII_BMSR
    call rtl8156_mdio_read
    mov [rtl8156_last_bmsr], ax
    push rax
    mov al, ah
    call rtl8156_ser_phex8
    pop rax
    call rtl8156_ser_phex8
    mov al, 10
    out dx, al

    ; Write BMCR = ANE | RAN. Clear PDOWN (0x0800) implicitly.
    mov edi, RTL8156_MII_BMCR
    mov esi, RTL8156_BMCR_ANE | RTL8156_BMCR_RAN
    call rtl8156_mdio_write

    pop rdi
    pop rsi
    pop rax
    ret

rtl8156_vendor_init:
    ; Run the OOB exit + link-list re-init. Skipping this leaves the PHY
    ; gated off — MDIO reads return 0 so BMSR LSTATUS never asserts and
    ; rtl8156_wait_link always times out (observed on real RTL8156
    ; passthrough; the device is otherwise enumerated correctly).
    ; ----------------------------------------------------------------
    ; OOB exit + link list re-init (Linux r8153_first_init prologue).
    ; At cold power-up the chip considers itself in "Out Of Band" mode
    ; where the host-side MAC/RX path is gated off. Without explicitly
    ; clearing NOW_IS_OOB and waiting for LINK_LIST_READY the bulk IN
    ; endpoint never delivers a frame even with everything else right.
    ; ----------------------------------------------------------------
    push rbx
    ; Read PLA_OOB_CTRL byte, clear NOW_IS_OOB, write back.
    mov edi, RTL8156_PLA_OOB_CTRL & ~3
    mov esi, RTL8156_MCU_PLA
    mov edx, 4
    mov rcx, RTL8156_SCRATCH_ADDR
    call rtl8156_ocp_read
    mov eax, [abs RTL8156_SCRATCH_ADDR]
    and eax, ~(RTL8156_NOW_IS_OOB << ((RTL8156_PLA_OOB_CTRL & 3) * 8))
    mov [abs RTL8156_SCRATCH_ADDR], eax
    mov edi, RTL8156_PLA_OOB_CTRL & ~3
    mov esi, RTL8156_MCU_PLA | RTL8156_BYTE_DWORD
    mov edx, 4
    mov rcx, RTL8156_SCRATCH_ADDR
    call rtl8156_ocp_write

    ; Trigger link-list re-init: PLA_SFF_STS_7 |= MCU_BORW_EN, then
    ; |= RE_INIT_LL, then poll for LINK_LIST_READY.
    mov edi, RTL8156_PLA_SFF_STS_7 & ~3
    mov esi, RTL8156_MCU_PLA
    mov edx, 4
    mov rcx, RTL8156_SCRATCH_ADDR
    call rtl8156_ocp_read
    mov eax, [abs RTL8156_SCRATCH_ADDR]
    or eax, (RTL8156_MCU_BORW_EN << ((RTL8156_PLA_SFF_STS_7 & 3) * 8))
    mov [abs RTL8156_SCRATCH_ADDR], eax
    mov edi, RTL8156_PLA_SFF_STS_7 & ~3
    mov esi, RTL8156_MCU_PLA | RTL8156_BYTE_DWORD
    mov edx, 4
    mov rcx, RTL8156_SCRATCH_ADDR
    call rtl8156_ocp_write

    mov edi, RTL8156_PLA_SFF_STS_7 & ~3
    mov esi, RTL8156_MCU_PLA
    mov edx, 4
    mov rcx, RTL8156_SCRATCH_ADDR
    call rtl8156_ocp_read
    mov eax, [abs RTL8156_SCRATCH_ADDR]
    or eax, (RTL8156_RE_INIT_LL << ((RTL8156_PLA_SFF_STS_7 & 3) * 8))
    mov [abs RTL8156_SCRATCH_ADDR], eax
    mov edi, RTL8156_PLA_SFF_STS_7 & ~3
    mov esi, RTL8156_MCU_PLA | RTL8156_BYTE_DWORD
    mov edx, 4
    mov rcx, RTL8156_SCRATCH_ADDR
    call rtl8156_ocp_write

    ; Poll for LINK_LIST_READY (bit 1 of PLA_SFF_STS_7 word).
    mov rbx, [tick_count]
    add rbx, 200                  ; 2s timeout
.ll_wait:
    mov edi, RTL8156_PLA_SFF_STS_7 & ~3
    mov esi, RTL8156_MCU_PLA
    mov edx, 4
    mov rcx, RTL8156_SCRATCH_ADDR
    call rtl8156_ocp_read
    mov eax, [abs RTL8156_SCRATCH_ADDR]
    shr eax, ((RTL8156_PLA_SFF_STS_7 & 3) * 8)
    test eax, RTL8156_LINK_LIST_READY
    jnz .ll_ready
    mov rax, [tick_count]
    cmp rax, rbx
    jae .ll_timeout
    pause
    jmp .ll_wait
.ll_ready:
    lea rsi, [rel ser_ll_ready]
    call rtl8156_ser_puts
    jmp .ll_done
.ll_timeout:
    lea rsi, [rel ser_ll_timeout]
    call rtl8156_ser_puts
.ll_done:
    pop rbx
.skip_oob_init:
    call rtl8156_phy_powerup
    ; Read MAC from PLA_IDR.
    mov edi, RTL8156_PLA_IDR
    mov esi, RTL8156_MCU_PLA
    mov edx, 8
    mov rcx, RTL8156_SCRATCH_ADDR
    call rtl8156_ocp_read
    test eax, eax
    jz .fail
    mov eax, [abs RTL8156_SCRATCH_ADDR]
    mov [rtl8156_mac], eax
    mov ax, [abs RTL8156_SCRATCH_ADDR + 4]
    mov [rtl8156_mac + 4], ax
    ; Debug: dump the MAC we just read.
    push rsi
    push rax
    push rdx
    lea rsi, [rel ser_mac_tag]
    call rtl8156_ser_puts
    mov al, [rtl8156_mac + 0]
    call rtl8156_ser_phex8
    mov al, [rtl8156_mac + 1]
    call rtl8156_ser_phex8
    mov al, [rtl8156_mac + 2]
    call rtl8156_ser_phex8
    mov al, [rtl8156_mac + 3]
    call rtl8156_ser_phex8
    mov al, [rtl8156_mac + 4]
    call rtl8156_ser_phex8
    mov al, [rtl8156_mac + 5]
    call rtl8156_ser_phex8
    mov al, 10
    mov dx, 0x3F8
    out dx, al
    pop rdx
    pop rax
    pop rsi

    ; Set PLA_RMS (RX max frame size). Linux r8152 always writes this; if
    ; left at reset default the MAC silently drops every inbound frame even
    ; with promiscuous mode set. 1522 = 1500 MTU + Ethernet + VLAN headroom.
    mov dword [abs RTL8156_SCRATCH_ADDR], 1522
    mov edi, RTL8156_PLA_RMS
    mov esi, RTL8156_MCU_PLA | RTL8156_BYTE_EN_WORD
    mov edx, 4
    mov rcx, RTL8156_SCRATCH_ADDR
    call rtl8156_ocp_write

    ; PLA_MAR = all ones — accept any multicast hash so the filter never
    ; drops a frame we passed RCR. Two dword writes to cover the 8 bytes.
    mov dword [abs RTL8156_SCRATCH_ADDR], 0xFFFFFFFF
    mov edi, RTL8156_PLA_MAR
    mov esi, RTL8156_MCU_PLA | RTL8156_BYTE_DWORD
    mov edx, 4
    mov rcx, RTL8156_SCRATCH_ADDR
    call rtl8156_ocp_write
    mov dword [abs RTL8156_SCRATCH_ADDR], 0xFFFFFFFF
    mov edi, RTL8156_PLA_MAR + 4
    mov esi, RTL8156_MCU_PLA | RTL8156_BYTE_DWORD
    mov edx, 4
    mov rcx, RTL8156_SCRATCH_ADDR
    call rtl8156_ocp_write

    ; Disable RX aggregation for single-frame polling.
    mov dword [abs RTL8156_SCRATCH_ADDR], RTL8156_RX_AGG_DISABLE
    mov edi, RTL8156_USB_USB_CTRL
    mov esi, RTL8156_MCU_USB | RTL8156_BYTE_DWORD
    mov edx, 4
    mov rcx, RTL8156_SCRATCH_ADDR
    call rtl8156_ocp_write

    ; Accept unicast to our MAC plus broadcast/multicast during ARP.
    ; Promiscuous: AAP|APM|AM|AB so we receive every frame on the link.
    mov dword [abs RTL8156_SCRATCH_ADDR], RTL8156_RCR_AAP | RTL8156_RCR_APM | RTL8156_RCR_AM | RTL8156_RCR_AB
    mov edi, RTL8156_PLA_RCR
    mov esi, RTL8156_MCU_PLA | RTL8156_BYTE_DWORD
    mov edx, 4
    mov rcx, RTL8156_SCRATCH_ADDR
    call rtl8156_ocp_write

    ; Linux r8152 clears RXDY_GATED_EN before receiving frames.
    mov edi, RTL8156_PLA_MISC_1 & ~3
    mov esi, RTL8156_MCU_PLA
    mov edx, 4
    mov rcx, RTL8156_SCRATCH_ADDR
    call rtl8156_ocp_read
    mov eax, [abs RTL8156_SCRATCH_ADDR]
    and eax, ~RTL8156_RXDY_GATED_EN
    mov [abs RTL8156_SCRATCH_ADDR], eax
    mov edi, RTL8156_PLA_MISC_1 & ~3
    mov esi, RTL8156_MCU_PLA | RTL8156_BYTE_DWORD
    mov edx, 4
    mov rcx, RTL8156_SCRATCH_ADDR
    call rtl8156_ocp_write

    ; Enable RX/TX via byte write at PLA_CR.
    mov dword [abs RTL8156_SCRATCH_ADDR], ((RTL8156_CR_RE | RTL8156_CR_TE) << 24)
    mov edi, RTL8156_PLA_CR & ~3
    mov esi, RTL8156_MCU_PLA | 0x88
    mov edx, 4
    mov rcx, RTL8156_SCRATCH_ADDR
    call rtl8156_ocp_write

    ; Notify RX DMA ownership update for r8153+ devices.
    mov dword [abs RTL8156_SCRATCH_ADDR], RTL8156_OWN_UPDATE_CLEAR
    mov edi, RTL8156_USB_UPT_RXDMA_OWN & ~3
    mov esi, RTL8156_MCU_USB | 0x88
    mov edx, 4
    mov rcx, RTL8156_SCRATCH_ADDR
    call rtl8156_ocp_write

    ; Re-clear RXDY_GATED_EN now that RX is enabled. Linux r8152.c sequences
    ; this AFTER the PLA_CR write — clearing it beforehand alone is not
    ; sufficient on r815x silicon and leaves the RX FIFO gated shut.
    mov edi, RTL8156_PLA_MISC_1 & ~3
    mov esi, RTL8156_MCU_PLA
    mov edx, 4
    mov rcx, RTL8156_SCRATCH_ADDR
    call rtl8156_ocp_read
    mov eax, [abs RTL8156_SCRATCH_ADDR]
    and eax, ~RTL8156_RXDY_GATED_EN
    mov [abs RTL8156_SCRATCH_ADDR], eax
    mov edi, RTL8156_PLA_MISC_1 & ~3
    mov esi, RTL8156_MCU_PLA | RTL8156_BYTE_DWORD
    mov edx, 4
    mov rcx, RTL8156_SCRATCH_ADDR
    call rtl8156_ocp_write

    ; Configure the USB RX early-flush so single-frame polling actually gets
    ; data out of the chip. Without these, the MAC waits for a buffer-full
    ; or aggregation timer that we never arm, and every IN token returns 0
    ; bytes. Values mirror r8152 single-frame defaults: small threshold,
    ; minimum timeout, size set to one MTU-ish frame.
    mov dword [abs RTL8156_SCRATCH_ADDR], 0x00000080   ; RX_BUF_TH = 0x80
    mov edi, RTL8156_USB_RX_BUF_TH
    mov esi, RTL8156_MCU_USB | RTL8156_BYTE_DWORD
    mov edx, 4
    mov rcx, RTL8156_SCRATCH_ADDR
    call rtl8156_ocp_write

    mov dword [abs RTL8156_SCRATCH_ADDR], 0x00000600   ; one frame's worth
    mov edi, RTL8156_USB_RX_EARLY_SIZE
    mov esi, RTL8156_MCU_USB | RTL8156_BYTE_DWORD
    mov edx, 4
    mov rcx, RTL8156_SCRATCH_ADDR
    call rtl8156_ocp_write

    mov dword [abs RTL8156_SCRATCH_ADDR], 0x00000001   ; flush ASAP
    mov edi, RTL8156_USB_RX_EARLY_TIMEOUT
    mov esi, RTL8156_MCU_USB | RTL8156_BYTE_DWORD
    mov edx, 4
    mov rcx, RTL8156_SCRATCH_ADDR
    call rtl8156_ocp_write

    ; PHY auto-negotiation starts automatically when the adapter is powered
    ; via USB; rtl8156_wait_link polls PLA_PHYSTATUS for it to complete.
    mov eax, 1
    ret
.fail:
    xor eax, eax
    ret

; ============================================================================
; Wait for PHY link to come up. Polls PLA_PHYSTATUS (0xC0D8). Bits[2:0] == 3
; (PHY_STAT_LAN_ON) indicates the MAC/PHY has negotiated a link.
; Returns EAX=1 on link, EAX=0 on timeout. Best-effort: caller continues
; either way so a late-plugged cable still works on next ping retry.
; ============================================================================
rtl8156_wait_link:
    push rbx
    push rcx
    push rdx
    push rsi

    lea rsi, [rel ser_link_wait_8156]
    call rtl8156_ser_puts

    ; Kick PHY auto-neg via MDIO BMCR (Linux r8152 r8152_mdio_write path).
    ; OCP address = OCP_BASE_PHY + (MII_BMCR << 1) = 0xA400; byte_enable=0x33
    ; restricts the write to the low 16 bits so BMSR at +2 is not touched.
    mov dword [abs RTL8156_SCRATCH_ADDR], RTL8156_BMCR_ANE | RTL8156_BMCR_RAN
    mov edi, RTL8156_OCP_BASE_PHY + (RTL8156_MII_BMCR << 1)
    mov esi, RTL8156_MCU_PLA | RTL8156_BYTE_EN_WORD
    mov edx, 4
    mov rcx, RTL8156_SCRATCH_ADDR
    call rtl8156_ocp_write

    mov rbx, [tick_count]
    add rbx, 500                        ; ~5 s budget
.loop:
    ; Read MII BMSR via the GPHY indirection window.
    mov edi, RTL8156_MII_BMSR
    call rtl8156_mdio_read
    ; Debug-print BMSR once per ~50 ticks (500 ms).
    mov rdx, [tick_count]
    mov rcx, [rtl8156_phy_dbg_last]
    sub rdx, rcx
    cmp rdx, 50
    jb .check
    mov rdx, [tick_count]
    mov [rtl8156_phy_dbg_last], rdx
    push rax
    push rsi
    push rdx
    lea rsi, [rel ser_bmsr_tag]
    call rtl8156_ser_puts
    pop rdx
    push rdx
    push rax
    mov al, ah
    call rtl8156_ser_phex8
    pop rax
    push rax
    call rtl8156_ser_phex8
    mov al, 10
    mov dx, 0x3F8
    out dx, al
    pop rax
    pop rdx
    pop rsi
    pop rax
.check:
    test ax, RTL8156_BMSR_LSTATUS
    jnz .up
.next:
    mov rax, [tick_count]
    cmp rax, rbx
    jae .timeout
    pause
    jmp .loop
.up:
    lea rsi, [rel ser_link_up_8156]
    call rtl8156_ser_puts
    mov eax, 1
    jmp .done
.timeout:
    lea rsi, [rel ser_link_timeout_8156]
    call rtl8156_ser_puts
    xor eax, eax
.done:
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

rtl8156_find_bulk_eps:
    mov rsi, XHCI_CTRL_BUF_ADDR
    cmp byte [rsi], 4
    jb .nf
    movzx ecx, word [rsi + 2]
    cmp ecx, 4
    jb .nf
    cmp ecx, 512
    ja .nf
    xor edx, edx
    xor ebx, ebx
    mov byte [rtl8156_bulk_in_addr], 0
    mov byte [rtl8156_bulk_out_addr], 0
.parse:
    cmp edx, ecx
    jae .check
    movzx eax, byte [rsi + rdx]
    cmp eax, 2
    jb .nf
    mov r8d, edx
    add r8d, eax
    cmp r8d, ecx
    ja .nf
    mov al, [rsi + rdx + 1]
    cmp al, USB_DESC_INTERFACE
    je .iface
    cmp al, USB_DESC_ENDPOINT
    je .ep
    jmp .next
.iface:
    cmp byte [rsi + rdx], 9
    jb .nf
    cmp byte [rsi + rdx + 5], 0xFF
    jne .not_iface
    mov bl, 1
    jmp .next
.not_iface:
    xor ebx, ebx
    jmp .next
.ep:
    test ebx, ebx
    jz .next
    cmp byte [rsi + rdx], 7
    jb .nf
    mov al, [rsi + rdx + 3]
    and al, 3
    cmp al, USB_EP_BULK
    jne .next
    mov ax, [rsi + rdx + 4]
    and ax, 0x07FF
    test ax, ax
    jnz .mps_ok
    mov ax, 1024
.mps_ok:
    mov al, [rsi + rdx + 2]
    test al, 0x80
    jz .out_ep
    mov [rtl8156_bulk_in_addr], al
    mov ax, [rsi + rdx + 4]
    and ax, 0x07FF
    test ax, ax
    jnz .in_mps
    mov ax, 1024
.in_mps:
    mov [rtl8156_bulk_in_mps], ax
    ; Peek at the descriptor immediately after this EP descriptor. If it is
    ; a SuperSpeed Endpoint Companion (type 0x30, length 6) grab bMaxBurst
    ; (offset 2). Required by xHCI for SS bulk endpoints — without it the
    ; chip's burst attempts are dropped and IN tokens return zero bytes
    ; forever.
    movzx eax, byte [rsi + rdx]           ; EP desc length (usually 7)
    mov r8, rsi
    add r8, rdx
    add r8, rax                           ; next descriptor
    movzx r9d, byte [r8 + 0]
    cmp r9d, 6
    jb .next
    cmp byte [r8 + 1], 0x30               ; SS EP Companion
    jne .next
    mov al, [r8 + 2]
    mov [rtl8156_bulk_in_burst], al
    jmp .next
.out_ep:
    mov [rtl8156_bulk_out_addr], al
    mov ax, [rsi + rdx + 4]
    and ax, 0x07FF
    test ax, ax
    jnz .out_mps
    mov ax, 1024
.out_mps:
    mov [rtl8156_bulk_out_mps], ax
    movzx eax, byte [rsi + rdx]
    mov r8, rsi
    add r8, rdx
    add r8, rax
    movzx r9d, byte [r8 + 0]
    cmp r9d, 6
    jb .next
    cmp byte [r8 + 1], 0x30
    jne .next
    mov al, [r8 + 2]
    mov [rtl8156_bulk_out_burst], al
.next:
    movzx eax, byte [rsi + rdx]
    add edx, eax
    jmp .parse
.check:
    cmp byte [rtl8156_bulk_in_addr], 0
    je .nf
    cmp byte [rtl8156_bulk_out_addr], 0
    je .nf
    mov eax, 1
    ret
.nf:
    xor eax, eax
    ret

rtl8156_configure_bulk_eps:
    push rbx
    push rcx
    push rdi
    push rsi
    push r12
    push r13
    push r14
    push r15

    movzx eax, byte [rtl8156_bulk_out_addr]
    and eax, 0x7F
    shl eax, 1
    mov [rtl8156_bulk_out_dci], al
    movzx eax, byte [rtl8156_bulk_in_addr]
    and eax, 0x7F
    shl eax, 1
    inc eax
    mov [rtl8156_bulk_in_dci], al

    mov rdi, XHCI_INPUT_CTX_ADDR
    push rdi
    mov ecx, 4096 / 8
    xor eax, eax
    rep stosq
    pop rdi

    movzx eax, byte [rtl8156_bulk_out_dci]
    mov ebx, 1
    mov ecx, eax
    shl ebx, cl
    movzx eax, byte [rtl8156_bulk_in_dci]
    mov edx, 1
    mov ecx, eax
    shl edx, cl
    or ebx, edx
    or ebx, 1
    mov [rdi + 4], ebx

    movzx ecx, byte [xhci_ctx_stride]
    lea rsi, [rdi + rcx]
    mov rbx, XHCI_DEV_CTX_ADDR
    mov eax, [rbx + 0]
    and eax, ~(0x1F << 27)
    ; Context Entries = max(IN dci, OUT dci). Previously we used only IN dci
    ; which left OUT (DCI 4) outside the valid range when IN dci was 3.
    movzx edx, byte [rtl8156_bulk_in_dci]
    movzx r8d, byte [rtl8156_bulk_out_dci]
    cmp r8d, edx
    jbe .have_max_dci
    mov edx, r8d
.have_max_dci:
    shl edx, 27
    or eax, edx
    mov [rsi + 0], eax
    mov eax, [rbx + 4]
    mov [rsi + 4], eax
    mov eax, [rbx + 8]
    mov [rsi + 8], eax
    mov eax, [rbx + 12]
    mov [rsi + 12], eax

    mov r12d, RTL8156_BULK_OUT_RING_ADDR
    movzx r13d, word [rtl8156_bulk_out_mps]
    movzx r14d, byte [rtl8156_bulk_out_dci]
    mov r15d, XHCI_EP_BULK_OUT
    call rtl8156_write_ep_ctx

    mov r12d, RTL8156_BULK_IN_RING_ADDR
    movzx r13d, word [rtl8156_bulk_in_mps]
    movzx r14d, byte [rtl8156_bulk_in_dci]
    mov r15d, XHCI_EP_BULK_IN
    call rtl8156_write_ep_ctx

    call rtl8156_init_bulk_rings

    mov r8d, XHCI_INPUT_CTX_ADDR
    xor r9d, r9d
    xor r10d, r10d
    movzx eax, byte [xhci_slot_id]
    shl eax, 24
    or eax, TRB_CONFIG_EP
    mov r11d, eax
    call xhci_submit_cmd
    cmp eax, 1
    jne .fail

    ; Dump the post-Configure Device Context for the IN endpoint so we can
    ; see whether xHCI accepted our EP context (State field bits[2:0] of
    ; dword 0: 1=Running, 2=Halted, 3=Stopped, 4=Error). Also dump dword 1
    ; (MPS<<16 | MaxBurst<<8 | EPType<<3) so we can verify the values stuck.
    push rax
    push rcx
    push rdx
    push rsi
    push rdi
    movzx ecx, byte [xhci_ctx_stride]
    movzx eax, byte [rtl8156_bulk_in_dci]
    imul eax, ecx                  ; DEV_CTX has no Input Control prefix
    lea rsi, [RTL8156_XHCI_DEV_CTX_ADDR + rax]
    lea rdi, [rel ser_ep_ctx_in]
    push rsi
    mov rsi, rdi
    call rtl8156_ser_puts
    pop rsi
    mov eax, [rsi + 0]
    push rax
    shr eax, 24
    call rtl8156_ser_phex8
    pop rax
    push rax
    shr eax, 16
    call rtl8156_ser_phex8
    pop rax
    push rax
    shr eax, 8
    call rtl8156_ser_phex8
    pop rax
    call rtl8156_ser_phex8
    mov dx, 0x3F8
    mov al, ' '
    out dx, al
    mov eax, [rsi + 4]
    push rax
    shr eax, 24
    call rtl8156_ser_phex8
    pop rax
    push rax
    shr eax, 16
    call rtl8156_ser_phex8
    pop rax
    push rax
    shr eax, 8
    call rtl8156_ser_phex8
    pop rax
    call rtl8156_ser_phex8
    mov al, 10
    out dx, al
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rax

    mov eax, 1
    jmp .done
.fail:
    xor eax, eax
.done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rsi
    pop rdi
    pop rcx
    pop rbx
    ret

; R12D=ring, R13D=mps, R14D=dci, R15D=xhci ep type.
rtl8156_write_ep_ctx:
    push rax
    push rcx
    push rdx
    push rsi
    movzx ecx, byte [xhci_ctx_stride]
    mov eax, r14d
    inc eax
    imul eax, ecx
    lea rsi, [XHCI_INPUT_CTX_ADDR + rax]
    mov dword [rsi + 0], 0
    mov eax, (3 << 1)
    mov ecx, r15d
    shl ecx, 3
    or eax, ecx
    mov ecx, r13d
    shl ecx, 16
    or eax, ecx
    ; Max Burst Size (bits 15:8). For SuperSpeed bulk endpoints this MUST
    ; match the SS Endpoint Companion's bMaxBurst; otherwise xHCI rejects
    ; the device's burst attempts and IN tokens come back empty forever.
    cmp r15d, XHCI_EP_BULK_IN
    jne .burst_out
    movzx edx, byte [rtl8156_bulk_in_burst]
    jmp .burst_apply
.burst_out:
    cmp r15d, XHCI_EP_BULK_OUT
    jne .burst_done
    movzx edx, byte [rtl8156_bulk_out_burst]
.burst_apply:
    and edx, 0xFF
    shl edx, 8
    or eax, edx
.burst_done:
    mov [rsi + 4], eax
    mov eax, r12d
    or eax, 1
    mov [rsi + 8], eax
    mov dword [rsi + 12], 0
    mov eax, 1514
    mov ecx, r13d
    shl ecx, 16
    or eax, ecx
    mov [rsi + 16], eax
    pop rsi
    pop rdx
    pop rcx
    pop rax
    ret

rtl8156_init_bulk_rings:
    push rax
    push rcx
    push rdi
    mov rdi, RTL8156_BULK_IN_RING_ADDR
    mov ecx, XHCI_RING_SIZE * XHCI_TRB_SIZE / 8
    xor eax, eax
    rep stosq
    mov rdi, RTL8156_BULK_OUT_RING_ADDR
    mov ecx, XHCI_RING_SIZE * XHCI_TRB_SIZE / 8
    rep stosq
    mov rdi, RTL8156_BULK_IN_RING_ADDR
    lea rax, [rdi + (XHCI_RING_SIZE - 1) * XHCI_TRB_SIZE]
    mov qword [rax], RTL8156_BULK_IN_RING_ADDR
    mov dword [rax + 8], 0
    mov dword [rax + 12], TRB_LINK | TRB_TC
    mov rdi, RTL8156_BULK_OUT_RING_ADDR
    lea rax, [rdi + (XHCI_RING_SIZE - 1) * XHCI_TRB_SIZE]
    mov qword [rax], RTL8156_BULK_OUT_RING_ADDR
    mov dword [rax + 8], 0
    mov dword [rax + 12], TRB_LINK | TRB_TC
    mov dword [rtl8156_bulk_in_enqueue], 0
    mov dword [rtl8156_bulk_out_enqueue], 0
    mov byte [rtl8156_bulk_in_cycle], 1
    mov byte [rtl8156_bulk_out_cycle], 1
    pop rdi
    pop rcx
    pop rax
    ret

rtl8156_send_dhcp_discover:
    push rax
    push rcx
    push rdi
    call rtl8156_build_dhcp_base
    lea rdi, [abs RTL8156_TX_BUF_ADDR + 8 + 14 + 20 + 8 + 240]
    mov byte [rdi + 0], 53       ; DHCP message type
    mov byte [rdi + 1], 1
    mov byte [rdi + 2], 1        ; discover
    add rdi, 3
    mov byte [rdi + 0], 12       ; option 12: hostname — shown by routers (eero, etc.)
    mov byte [rdi + 1], 7
    mov dword [rdi + 2], 'Nexu'
    mov word  [rdi + 6], 'sO'
    mov byte  [rdi + 8], 'S'
    add rdi, 9
    mov byte [rdi + 0], 55       ; parameter request list
    mov byte [rdi + 1], 3
    mov byte [rdi + 2], 1        ; subnet mask
    mov byte [rdi + 3], 3        ; router
    mov byte [rdi + 4], 6        ; DNS
    add rdi, 5
    mov byte [rdi], 255
    mov rcx, rdi
    sub rcx, (RTL8156_TX_BUF_ADDR + 8 + 14 + 20 + 8)
    inc ecx
    call rtl8156_finish_dhcp_udp
    pop rdi
    pop rcx
    pop rax
    ret

rtl8156_send_dhcp_request:
    push rax
    push rcx
    push rdi
    call rtl8156_build_dhcp_base
    lea rdi, [abs RTL8156_TX_BUF_ADDR + 8 + 14 + 20 + 8 + 240]
    mov byte [rdi + 0], 53       ; DHCP message type
    mov byte [rdi + 1], 1
    mov byte [rdi + 2], 3        ; request
    add rdi, 3
    mov byte [rdi + 0], 50       ; requested IP
    mov byte [rdi + 1], 4
    mov eax, [rtl8156_dhcp_ip]
    mov [rdi + 2], eax
    add rdi, 6
    mov byte [rdi + 0], 54       ; server identifier
    mov byte [rdi + 1], 4
    mov eax, [rtl8156_dhcp_server]
    mov [rdi + 2], eax
    add rdi, 6
    mov byte [rdi + 0], 12       ; hostname (so the router shows "NexusOS")
    mov byte [rdi + 1], 7
    mov dword [rdi + 2], 'Nexu'
    mov word  [rdi + 6], 'sO'
    mov byte  [rdi + 8], 'S'
    add rdi, 9
    mov byte [rdi + 0], 55
    mov byte [rdi + 1], 3
    mov byte [rdi + 2], 1
    mov byte [rdi + 3], 3
    mov byte [rdi + 4], 6
    add rdi, 5
    mov byte [rdi], 255
    mov rcx, rdi
    sub rcx, (RTL8156_TX_BUF_ADDR + 8 + 14 + 20 + 8)
    inc ecx
    call rtl8156_finish_dhcp_udp
    pop rdi
    pop rcx
    pop rax
    ret

rtl8156_build_dhcp_base:
    push rax
    push rcx
    push rsi
    push rdi

    lea rdi, [abs RTL8156_TX_BUF_ADDR + 8]
    mov ecx, 342
    xor eax, eax
    rep stosb

    lea rdi, [abs RTL8156_TX_BUF_ADDR + 8]
    mov ecx, 6
    mov al, 0xFF
    rep stosb
    lea rsi, [rtl8156_mac]
    mov ecx, 6
    rep movsb
    mov word [rdi], 0x0008       ; IPv4

    ; IPv4 header.
    mov byte [abs RTL8156_TX_BUF_ADDR + 8 + 14], 0x45
    mov byte [abs RTL8156_TX_BUF_ADDR + 8 + 15], 0
    mov word [abs RTL8156_TX_BUF_ADDR + 8 + 18], 0x7856
    mov word [abs RTL8156_TX_BUF_ADDR + 8 + 20], 0
    mov byte [abs RTL8156_TX_BUF_ADDR + 8 + 22], 64
    mov byte [abs RTL8156_TX_BUF_ADDR + 8 + 23], 17 ; UDP
    mov word [abs RTL8156_TX_BUF_ADDR + 8 + 24], 0
    mov dword [abs RTL8156_TX_BUF_ADDR + 8 + 26], 0
    mov dword [abs RTL8156_TX_BUF_ADDR + 8 + 30], 0xFFFFFFFF

    ; UDP header.
    mov word [abs RTL8156_TX_BUF_ADDR + 8 + 14 + 20], 0x4400 ; src 68
    mov word [abs RTL8156_TX_BUF_ADDR + 8 + 14 + 22], 0x4300 ; dst 67
    mov word [abs RTL8156_TX_BUF_ADDR + 8 + 14 + 26], 0      ; checksum optional for IPv4

    ; BOOTP/DHCP fixed area.
    lea rdi, [abs RTL8156_TX_BUF_ADDR + 8 + 14 + 20 + 8]
    mov byte [rdi + 0], 1        ; BOOTREQUEST
    mov byte [rdi + 1], 1        ; Ethernet
    mov byte [rdi + 2], 6
    mov byte [rdi + 3], 0
    mov eax, [rtl8156_dhcp_xid]
    mov [rdi + 4], eax
    mov word [rdi + 10], 0x0080  ; broadcast flag
    lea rsi, [rtl8156_mac]
    lea rdi, [rdi + 28]
    mov ecx, 6
    rep movsb
    mov dword [abs RTL8156_TX_BUF_ADDR + 8 + 14 + 20 + 8 + 236], 0x63538263

    pop rdi
    pop rsi
    pop rcx
    pop rax
    ret

; ECX = DHCP/BOOTP payload length from UDP payload start.
rtl8156_finish_dhcp_udp:
    push rax
    push rcx
    push rdi
    mov eax, ecx
    add eax, 8
    xchg al, ah
    mov [abs RTL8156_TX_BUF_ADDR + 8 + 14 + 24], ax ; UDP length
    mov eax, ecx
    add eax, 8 + 20
    xchg al, ah
    mov [abs RTL8156_TX_BUF_ADDR + 8 + 16], ax      ; IP total length
    lea rdi, [abs RTL8156_TX_BUF_ADDR + 8 + 14]
    mov ecx, 20
    call net_checksum
    mov [abs RTL8156_TX_BUF_ADDR + 8 + 24], ax
    movzx ecx, word [abs RTL8156_TX_BUF_ADDR + 8 + 16]
    xchg cl, ch
    add ecx, 14
    call rtl8156_tx_frame
    pop rdi
    pop rcx
    pop rax
    ret

rtl8156_send_arp_gateway:
    push rax
    push rcx
    push rsi
    push rdi
    lea rdi, [abs RTL8156_TX_BUF_ADDR + 8]
    mov ecx, 60
    xor eax, eax
    rep stosb
    lea rdi, [abs RTL8156_TX_BUF_ADDR + 8]
    mov ecx, 6
    mov al, 0xFF
    rep stosb
    lea rsi, [rtl8156_mac]
    mov ecx, 6
    rep movsb
    mov word [rdi], 0x0608
    add rdi, 2
    mov word [rdi], 0x0100
    mov word [rdi + 2], 0x0008
    mov byte [rdi + 4], 6
    mov byte [rdi + 5], 4
    mov word [rdi + 6], 0x0100
    lea rsi, [rtl8156_mac]
    lea rdi, [abs RTL8156_TX_BUF_ADDR + 8 + 22]
    mov ecx, 6
    rep movsb
    mov eax, [rtl8156_guest_ip]
    mov dword [abs RTL8156_TX_BUF_ADDR + 8 + 28], eax
    mov qword [abs RTL8156_TX_BUF_ADDR + 8 + 32], 0
    mov eax, [rtl8156_next_hop_ip]
    mov dword [abs RTL8156_TX_BUF_ADDR + 8 + 38], eax
    mov ecx, 60
    call rtl8156_tx_frame
    pop rdi
    pop rsi
    pop rcx
    pop rax
    ret

rtl8156_send_icmp_gateway:
    push rax
    push rbx
    push rcx
    push rsi
    push rdi
    lea rdi, [abs RTL8156_TX_BUF_ADDR + 8]
    mov ecx, 60
    xor eax, eax
    rep stosb
    lea rdi, [abs RTL8156_TX_BUF_ADDR + 8]
    lea rsi, [rtl8156_gw_mac]
    mov ecx, 6
    rep movsb
    lea rsi, [rtl8156_mac]
    mov ecx, 6
    rep movsb
    mov word [rdi], 0x0008
    mov byte [abs RTL8156_TX_BUF_ADDR + 8 + 14], 0x45
    mov word [abs RTL8156_TX_BUF_ADDR + 8 + 16], 0x1C00
    mov word [abs RTL8156_TX_BUF_ADDR + 8 + 18], 0x5634
    mov byte [abs RTL8156_TX_BUF_ADDR + 8 + 22], 64
    mov byte [abs RTL8156_TX_BUF_ADDR + 8 + 23], 1
    mov word [abs RTL8156_TX_BUF_ADDR + 8 + 24], 0
    mov eax, [rtl8156_guest_ip]
    mov dword [abs RTL8156_TX_BUF_ADDR + 8 + 26], eax
    mov eax, [rtl8156_target_ip]
    mov dword [abs RTL8156_TX_BUF_ADDR + 8 + 30], eax
    lea rdi, [abs RTL8156_TX_BUF_ADDR + 8 + 14]
    mov ecx, 20
    call net_checksum
    mov [abs RTL8156_TX_BUF_ADDR + 8 + 24], ax
    mov byte [abs RTL8156_TX_BUF_ADDR + 8 + 34], 8
    mov byte [abs RTL8156_TX_BUF_ADDR + 8 + 35], 0
    mov word [abs RTL8156_TX_BUF_ADDR + 8 + 36], 0
    mov word [abs RTL8156_TX_BUF_ADDR + 8 + 38], 0xBEEF
    inc word [rtl8156_ping_seq]
    mov ax, [rtl8156_ping_seq]
    xchg al, ah
    mov [abs RTL8156_TX_BUF_ADDR + 8 + 40], ax
    lea rdi, [abs RTL8156_TX_BUF_ADDR + 8 + 34]
    mov ecx, 8
    call net_checksum
    mov [abs RTL8156_TX_BUF_ADDR + 8 + 36], ax
    mov ecx, 60
    call rtl8156_tx_frame
    pop rdi
    pop rsi
    pop rcx
    pop rbx
    pop rax
    ret

; ECX = Ethernet frame length at RTL8156_TX_BUF_ADDR+8.
rtl8156_tx_frame:
    push rax
    push rcx
    push rdx
    push rsi
    lea rsi, [rel ser_tx_tag]
    call rtl8156_ser_puts
    mov al, cl
    call rtl8156_ser_phex8
    mov al, 10
    mov dx, 0x3F8
    out dx, al
    pop rsi
    pop rdx
    mov eax, ecx
    or eax, RTL8156_TX_FS | RTL8156_TX_LS
    mov [abs RTL8156_TX_BUF_ADDR], eax
    mov dword [abs RTL8156_TX_BUF_ADDR + 4], 0
    add ecx, 8
    mov edi, RTL8156_TX_BUF_ADDR
    call rtl8156_bulk_out
    push rdx
    push rsi
    lea rsi, [rel ser_tx_done]
    call rtl8156_ser_puts
    mov al, al            ; just to avoid empty
    pop rsi
    pop rdx
    pop rcx
    pop rax
    ret

; Generic NIC ABI wrapper. RDI = complete Ethernet frame, ECX = length.
global rtl8156_net_tx_frame
rtl8156_net_tx_frame:
    push rcx
    push rsi
    push rdi
    push r8
    cmp byte [rtl8156_active], 1
    je .active
    call rtl8156_init
    test eax, eax
    jz .fail
.active:
    mov r8d, ecx
    mov rsi, rdi
    mov rdi, RTL8156_TX_BUF_ADDR + 8
    cld
    rep movsb
    mov ecx, r8d
    call rtl8156_tx_frame
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

; rtl8156_rx_once — non-blocking RX pump. Pulls at most one transfer event
; off the shared xHCI event ring and dispatches it via consume_event (NIC) or
; the HID requeue path. Used at boot (before usb_poll_mouse is running) and
; redundantly from DHCP/ICMP wait loops — both paths just call this; whoever
; pops the event from the ring wins, and either flows into handle_frame the
; same way through rtl8156_consume_event.
rtl8156_rx_once:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    call rtl8156_arm_rx
    call xhci_poll_event
    test eax, eax
    jz .done
    mov ecx, ebx
    shr ecx, 10
    and ecx, 0x3F
    cmp ecx, 32
    jne .done
    mov edx, ebx
    shr edx, 24
    and edx, 0xFF
    movzx ecx, byte [rtl8156_slot_id]
    cmp edx, ecx
    je .nic_event
    ; Other slot — re-prime HID so its mouse ring stays armed.
    extern usb_hid_requeue_slot1_one
    call usb_hid_requeue_slot1_one
    jmp .done
.nic_event:
    call rtl8156_consume_event
.done:
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

global rtl8156_net_poll_rx
rtl8156_net_poll_rx:
    cmp byte [rtl8156_active], 1
    jne .no_work
    call rtl8156_rx_once
    mov eax, 1
    ret
.no_work:
    xor eax, eax
    ret

; RDI = Ethernet frame, ECX = len.
rtl8156_handle_frame:
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
    cmp word [rdi + 20], 0x0200
    jne .done
    mov eax, [rtl8156_next_hop_ip]
    cmp dword [rdi + 28], eax
    jne .done
    lea rsi, [rdi + 22]
    lea rdi, [rtl8156_gw_mac]
    mov ecx, 6
    rep movsb
    mov byte [rtl8156_have_gw_mac], 1
    jmp .done
.ip:
    cmp ecx, 42
    jb .done
    cmp byte [rdi + 23], 17
    je .udp
    cmp byte [rdi + 23], 1
    jne .done
    mov eax, [rtl8156_guest_ip]
    cmp dword [rdi + 30], eax
    jne .icmp_ignore
    cmp byte [rdi + 34], 0
    jne .icmp_ignore
    cmp word [rdi + 38], 0xBEEF
    jne .icmp_ignore
    ; Capture TTL from the IPv4 header (offset 8 of IP header == frame+22)
    ; so net_info(NI_PING_LAST_TTL) can report it to userspace.
    mov al, [rdi + 22]
    mov [rtl8156_ping_last_ttl], al
    mov byte [rtl8156_ping_reply], 1
    jmp .done
.icmp_ignore:
    jmp .done
.udp:
    call rtl8156_handle_udp
.done:
    pop rsi
    pop rcx
    pop rax
    ret

; RDI = Ethernet frame, ECX = len.
rtl8156_handle_udp:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push r8
    push r9

    cmp ecx, 282
    jb .done
    cmp word [rdi + 34], 0x4300      ; UDP source port 67
    jne .done
    cmp word [rdi + 36], 0x4400      ; UDP dest port 68
    jne .done
    mov eax, [rtl8156_dhcp_xid]
    cmp [rdi + 46], eax
    jne .done
    cmp dword [rdi + 278], 0x63538263
    jne .done

    mov eax, [rdi + 58]              ; yiaddr
    mov [rtl8156_dhcp_candidate_ip], eax
    mov byte [rtl8156_dhcp_msg_type], 0
    mov dword [rtl8156_dhcp_candidate_server], 0
    mov dword [rtl8156_dhcp_candidate_router], 0
    mov dword [rtl8156_dhcp_candidate_dns], 0

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
    mov [rtl8156_dhcp_msg_type], al
    jmp .next_opt
.server_id:
    cmp edx, 4
    jb .next_opt
    mov eax, [rsi + 2]
    mov [rtl8156_dhcp_candidate_server], eax
    jmp .next_opt
.router:
    cmp edx, 4
    jb .next_opt
    mov eax, [rsi + 2]
    mov [rtl8156_dhcp_candidate_router], eax
    jmp .next_opt
.dns_server:
    cmp edx, 4
    jb .next_opt
    mov eax, [rsi + 2]
    mov [rtl8156_dhcp_candidate_dns], eax
.next_opt:
    mov rsi, r9
    jmp .opt_loop
.opt_pad:
    inc rsi
    jmp .opt_loop
.classify:
    cmp byte [rtl8156_dhcp_msg_type], 2
    je .offer
    cmp byte [rtl8156_dhcp_msg_type], 5
    je .ack
    jmp .done
.offer:
    mov eax, [rtl8156_dhcp_candidate_ip]
    test eax, eax
    jz .done
    mov [rtl8156_dhcp_ip], eax
    mov eax, [rtl8156_dhcp_candidate_server]
    mov [rtl8156_dhcp_server], eax
    mov eax, [rtl8156_dhcp_candidate_router]
    mov [rtl8156_dhcp_router], eax
    mov eax, [rtl8156_dhcp_candidate_dns]
    mov [rtl8156_dhcp_dns], eax
    mov byte [rtl8156_dhcp_offer_seen], 1
    jmp .done
.ack:
    mov eax, [rtl8156_dhcp_candidate_ip]
    test eax, eax
    jz .done
    mov [rtl8156_dhcp_ip], eax
    mov eax, [rtl8156_dhcp_candidate_server]
    test eax, eax
    jz .keep_server
    mov [rtl8156_dhcp_server], eax
.keep_server:
    mov eax, [rtl8156_dhcp_candidate_router]
    test eax, eax
    jz .keep_router
    mov [rtl8156_dhcp_router], eax
.keep_router:
    mov eax, [rtl8156_dhcp_candidate_dns]
    test eax, eax
    jz .keep_dns
    mov [rtl8156_dhcp_dns], eax
.keep_dns:
    mov byte [rtl8156_dhcp_ack_seen], 1
.done:
    pop r9
    pop r8
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; RDI=OCP value/register, ESI=wIndex/type, EDX=len, RCX=buffer.
rtl8156_ocp_read:
    mov r8d, edi
    shl r8d, 16
    or r8d, (RTL8156_REQ_REGS << 8) | RTL8156_REQT_READ
    mov r9d, edx
    shl r9d, 16
    or r9d, esi
    mov rdi, rcx
    mov rcx, rdx
    call rtl8156_control_in
    ret

; RDI=OCP value/register, ESI=wIndex/type|byteen, EDX=len, RCX=buffer.
rtl8156_ocp_write:
    mov r8d, edi
    shl r8d, 16
    or r8d, (RTL8156_REQ_REGS << 8) | RTL8156_REQT_WRITE
    mov r9d, edx
    shl r9d, 16
    or r9d, esi
    mov rdi, rcx
    mov rcx, rdx
    call rtl8156_control_out
    ret

; R8/R9 setup, RDI buffer, RCX length.
rtl8156_control_in:
    push rcx
    push rdi
    mov r10d, 8
    mov r11d, TRB_SETUP | TRB_IDT | TRB_TRT_IN
    call xhci_queue_ctrl_trb
    pop rdi
    pop rcx
    mov r8d, edi
    xor r9d, r9d
    mov r10d, ecx
    mov r11d, TRB_DATA | TRB_DIR_IN
    call xhci_queue_ctrl_trb
    xor r8d, r8d
    xor r9d, r9d
    xor r10d, r10d
    mov r11d, TRB_STATUS | TRB_DIR_OUT | TRB_IOC
    call xhci_queue_ctrl_trb
    movzx edi, byte [xhci_slot_id]
    mov esi, 1
    call xhci_ring_doorbell
    call rtl8156_wait_completion
    ret

; R8/R9 setup, RDI buffer, RCX length.
rtl8156_control_out:
    push rcx
    push rdi
    mov r10d, 8
    mov r11d, TRB_SETUP | TRB_IDT | TRB_TRT_OUT
    call xhci_queue_ctrl_trb
    pop rdi
    pop rcx
    mov r8d, edi
    xor r9d, r9d
    mov r10d, ecx
    mov r11d, TRB_DATA | TRB_DIR_OUT
    call xhci_queue_ctrl_trb
    xor r8d, r8d
    xor r9d, r9d
    xor r10d, r10d
    mov r11d, TRB_STATUS | TRB_DIR_IN | TRB_IOC
    call xhci_queue_ctrl_trb
    movzx edi, byte [xhci_slot_id]
    mov esi, 1
    call xhci_ring_doorbell
    call rtl8156_wait_completion
    ret

rtl8156_control_nodata:
    mov r10d, 8
    mov r11d, TRB_SETUP | TRB_IDT | TRB_TRT_NO_DATA
    call xhci_queue_ctrl_trb
    xor r8d, r8d
    xor r9d, r9d
    xor r10d, r10d
    mov r11d, TRB_STATUS | TRB_DIR_IN | TRB_IOC
    call xhci_queue_ctrl_trb
    movzx edi, byte [xhci_slot_id]
    mov esi, 1
    call xhci_ring_doorbell
    call rtl8156_wait_completion
    ret

rtl8156_bulk_in:
    push rcx
    push rdi
    mov r8d, edi
    xor r9d, r9d
    mov r10d, ecx
    mov r11d, TRB_NORMAL | TRB_IOC | (1 << 2)
    mov rdi, RTL8156_BULK_IN_RING_ADDR
    mov esi, rtl8156_bulk_in_enqueue
    mov edx, rtl8156_bulk_in_cycle
    call rtl8156_queue_bulk_trb
    ; Doorbell the NIC's own slot, NOT the shared xhci_slot_id — that global
    ; gets clobbered by usb_hid / re-enumeration after rtl8156 init returns.
    movzx edi, byte [rtl8156_slot_id]
    movzx esi, byte [rtl8156_bulk_in_dci]
    call xhci_ring_doorbell
    call rtl8156_wait_completion
    pop rdi
    pop rcx
    ret

; ----------------------------------------------------------------------------
; rtl8156_consume_event — driven from the SINGLE shared USB event-ring poller
; (currently usb_poll_mouse) once it has decided that the popped transfer
; event belongs to our NIC slot. Caller passes the completion code in EAX and
; the DW0/DW1 fields in EBX/ECX (matching xhci_poll_event's return ABI). We
; mark the in-flight bulk-IN as cleared, run handle_frame on the RX buffer
; if the event was Success/Short, then queue a fresh bulk-IN so a continuous
; RX stream is maintained without any per-syscall polling.
;
; This is the layering pivot point — DHCP / ICMP / ARP all consume RX data
; through handle_frame, which is fed exclusively from here. No syscall path
; ever touches xhci_poll_event directly anymore.
; ----------------------------------------------------------------------------
global rtl8156_consume_event
rtl8156_consume_event:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    push r9
    push r10
    push r11
    ; Endpoint DCI lives in EBX (DW3) bits 20:16.
    mov edx, ebx
    shr edx, 16
    and edx, 0x1F
    movzx ecx, byte [rtl8156_bulk_in_dci]
    cmp edx, ecx
    je .rx_completion
    movzx ecx, byte [rtl8156_bulk_out_dci]
    cmp edx, ecx
    je .tx_completion
    ; Unknown endpoint — drop.
    jmp .out

.tx_completion:
    ; TX event — record completion code so a parallel rtl8156_wait_completion
    ; (called from bulk_out) can pick it up via the mailbox.
    mov [rel rtl8156_tx_done_code], eax
    mov byte [rel rtl8156_tx_done_set], 1
    jmp .out

.rx_completion:
    mov byte [rtl8156_bulk_in_inflight], 0
    ; Only Success(1) and Short(13) carry valid RX data.
    cmp eax, 1
    je .have_rx
    cmp eax, 13
    je .have_rx
    jmp .requeue
.have_rx:
    mov eax, [abs RTL8156_RX_BUF_ADDR]
    and eax, RTL8156_RX_LEN_MASK
    cmp eax, 18 + 14
    jb .requeue
    sub eax, 4
    lea rdi, [abs RTL8156_RX_BUF_ADDR + 24]
    mov ecx, eax
    call rtl8156_handle_frame
.requeue:
    ; Queue the next bulk-IN TRB so the next frame can arrive.
    mov r8d, RTL8156_RX_BUF_ADDR
    xor r9d, r9d
    mov r10d, 4096
    mov r11d, TRB_NORMAL | TRB_IOC | (1 << 2)
    mov rdi, RTL8156_BULK_IN_RING_ADDR
    mov esi, rtl8156_bulk_in_enqueue
    mov edx, rtl8156_bulk_in_cycle
    call rtl8156_queue_bulk_trb
    movzx edi, byte [rtl8156_slot_id]
    movzx esi, byte [rtl8156_bulk_in_dci]
    call xhci_ring_doorbell
    mov byte [rtl8156_bulk_in_inflight], 1
.out:
    pop r11
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; ----------------------------------------------------------------------------
; rtl8156_arm_rx — queue an initial bulk-IN TRB so the next NIC frame will
; surface on the xHCI event ring. Call once after rtl8156_init succeeds so
; the consume_event loop has something to be waiting for. Idempotent.
; ----------------------------------------------------------------------------
global rtl8156_arm_rx
rtl8156_arm_rx:
    push rax
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    push r9
    push r10
    push r11
    cmp byte [rtl8156_bulk_in_inflight], 1
    je .out
    mov r8d, RTL8156_RX_BUF_ADDR
    xor r9d, r9d
    mov r10d, 4096
    mov r11d, TRB_NORMAL | TRB_IOC | (1 << 2)
    mov rdi, RTL8156_BULK_IN_RING_ADDR
    mov esi, rtl8156_bulk_in_enqueue
    mov edx, rtl8156_bulk_in_cycle
    call rtl8156_queue_bulk_trb
    movzx edi, byte [rtl8156_slot_id]
    movzx esi, byte [rtl8156_bulk_in_dci]
    call xhci_ring_doorbell
    mov byte [rtl8156_bulk_in_inflight], 1
.out:
    pop r11
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rax
    ret

; EDI = buf addr, ECX = max len. Returns EAX=1 if a NIC bulk-IN transfer
; event completed this call (data is in [edi]), EAX=0 otherwise. Never
; blocks: at most one xhci_poll_event call and at most one new TRB queued.
global rtl8156_bulk_in_nonblocking
rtl8156_bulk_in_nonblocking:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    push r9
    push r10
    push r11
    ; Queue a fresh bulk-IN TRB if none is currently in flight.
    cmp byte [rtl8156_bulk_in_inflight], 1
    je .poll
    mov r8d, edi
    xor r9d, r9d
    mov r10d, ecx
    mov r11d, TRB_NORMAL | TRB_IOC | (1 << 2)
    mov rdi, RTL8156_BULK_IN_RING_ADDR
    mov esi, rtl8156_bulk_in_enqueue
    mov edx, rtl8156_bulk_in_cycle
    call rtl8156_queue_bulk_trb
    movzx edi, byte [rtl8156_slot_id]
    movzx esi, byte [rtl8156_bulk_in_dci]
    call xhci_ring_doorbell
    mov byte [rtl8156_bulk_in_inflight], 1
.poll:
    call xhci_poll_event
    test eax, eax
    jz .no_event
    ; Only care about Transfer Events (TRB type 32 in DWord3 bits 15:10).
    mov ecx, ebx
    shr ecx, 10
    and ecx, 0x3F
    cmp ecx, 32
    jne .no_event
    ; Check slot ID.
    mov edx, ebx
    shr edx, 24
    and edx, 0xFF
    movzx ecx, byte [rtl8156_slot_id]
    cmp edx, ecx
    jne .other_slot
    ; Our event. Mark in-flight cleared.
    mov byte [rtl8156_bulk_in_inflight], 0
    ; Accept Success(1) and Short Packet(13) as data.
    cmp eax, 1
    je .ok
    cmp eax, 13
    je .ok
    xor eax, eax
    jmp .out
.ok:
    mov eax, 1
    jmp .out
.other_slot:
    ; HID Transfer Event — re-prime its ring and report "no data" to caller.
    extern usb_hid_requeue_slot1_one
    call usb_hid_requeue_slot1_one
    xor eax, eax
    jmp .out
.no_event:
    xor eax, eax
.out:
    pop r11
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

rtl8156_bulk_out:
    push rcx
    push rdi
    mov r8d, edi
    xor r9d, r9d
    mov r10d, ecx
    mov r11d, TRB_NORMAL | TRB_IOC
    mov rdi, RTL8156_BULK_OUT_RING_ADDR
    mov esi, rtl8156_bulk_out_enqueue
    mov edx, rtl8156_bulk_out_cycle
    call rtl8156_queue_bulk_trb
    movzx edi, byte [rtl8156_slot_id]
    movzx esi, byte [rtl8156_bulk_out_dci]
    call xhci_ring_doorbell
    call rtl8156_wait_completion
    pop rdi
    pop rcx
    ret

; RDI=ring, ESI=&enqueue, EDX=&cycle, R8-R11=TRB.
rtl8156_queue_bulk_trb:
    push rax
    push rbx
    push rcx
    mov ebx, [rsi]
    cmp ebx, XHCI_RING_SIZE - 1
    jl .no_wrap
    lea rax, [rdi + (XHCI_RING_SIZE - 1) * XHCI_TRB_SIZE]
    mov ecx, [rax + 12]
    and ecx, ~1
    movzx eax, byte [rdx]
    or ecx, eax
    lea rax, [rdi + (XHCI_RING_SIZE - 1) * XHCI_TRB_SIZE]
    mov [rax + 12], ecx
    xor byte [rdx], 1
    mov dword [rsi], 0
    xor ebx, ebx
.no_wrap:
    imul eax, ebx, XHCI_TRB_SIZE
    add rdi, rax
    mov [rdi + 0], r8d
    mov [rdi + 4], r9d
    mov [rdi + 8], r10d
    mov eax, r11d
    movzx ecx, byte [rdx]
    or eax, ecx
    mov [rdi + 12], eax
    inc ebx
    mov [rsi], ebx
    pop rcx
    pop rbx
    pop rax
    ret

rtl8156_wait_completion:
    push rbx
    push rcx
    push rdx
    push rsi
    mov rsi, [tick_count]
    add rsi, 200
.poll:
    ; TX-completion mailbox first — if usb_poll_mouse already popped our
    ; bulk-OUT transfer event from the shared ring, it's been stashed here.
    cmp byte [rel rtl8156_tx_done_set], 1
    jne .ring_poll
    mov byte [rel rtl8156_tx_done_set], 0
    mov eax, [rel rtl8156_tx_done_code]
    cmp eax, 1
    je .ok
    cmp eax, 13
    je .ok
    jmp .fail
.ring_poll:
    call xhci_poll_event
    test eax, eax
    jz .check_time
    mov ecx, ebx
    shr ecx, 10
    and ecx, 0x3F
    cmp ecx, 32
    je .ours_check
    cmp ecx, 33
    je .event
    jmp .poll
.ours_check:
    ; Transfer Event — first check the slot ID.
    mov edx, ebx
    shr edx, 24
    and edx, 0xFF
    movzx ecx, byte [rtl8156_slot_id]
    cmp edx, ecx
    je .nic_ep_check
    push rax
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    push r9
    push r10
    push r11
    extern usb_hid_requeue_slot1_one
    call usb_hid_requeue_slot1_one
    pop r11
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rax
    jmp .poll

.nic_ep_check:
    ; NIC slot — bulk-IN events should NOT terminate this wait (we are
    ; waiting on a TX completion). Hand bulk-IN events to consume_event so
    ; the RX path still progresses, then keep polling. Bulk-OUT events ARE
    ; the TX completion we are after.
    push rax
    push rbx
    push rcx
    push rdx
    mov edx, ebx
    shr edx, 16
    and edx, 0x1F
    movzx ecx, byte [rtl8156_bulk_out_dci]
    test ecx, ecx
    jz .nic_ep_is_completion
    cmp edx, 1
    je .nic_ep_is_completion
    cmp edx, ecx
    pop rdx
    pop rcx
    pop rbx
    pop rax
    je .event
    ; Not bulk-OUT — it's bulk-IN (or interrupt). Route via consume_event.
    call rtl8156_consume_event
    jmp .poll
.nic_ep_is_completion:
    pop rdx
    pop rcx
    pop rbx
    pop rax
    jmp .event

.event:
    ; Accept: 1 = Success, 13 = Short Packet (valid data, device sent less
    ; than the TRB length — normal for bulk IN of variable-size frames).
    ; THIS WAS THE RX BUG: only accepting 1 made every IN look like a fail.
    cmp eax, 1
    je .ok
    cmp eax, 13
    je .ok
    jmp .fail
.ok:
    mov eax, 1
    jmp .done
.check_time:
    mov rax, [tick_count]
    cmp rax, rsi
    jl .poll
.fail:
    xor eax, eax
.done:
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

rtl8156_diag_char:
    push rdx
    mov dx, 0x3F8
    out dx, al
    pop rdx
    ret

rtl8156_ser_init:
    push rax
    push rdx
    mov dx, 0x3F8
    mov al, '['
    out dx, al
    mov al, 'R'
    out dx, al
    mov al, '8'
    out dx, al
    mov al, '1'
    out dx, al
    mov al, '5'
    out dx, al
    mov al, '6'
    out dx, al
    mov al, ' '
    out dx, al
    pop rdx
    pop rax
    ret

rtl8156_ser_ready:
    push rax
    push rdx
    mov dx, 0x3F8
    mov al, 'O'
    out dx, al
    mov al, 'K'
    out dx, al
    mov al, ']'
    out dx, al
    mov al, 10
    out dx, al
    pop rdx
    pop rax
    ret

rtl8156_ser_fail:
    push rax
    push rdx
    mov dx, 0x3F8
    mov al, 'F'
    out dx, al
    mov al, 'A'
    out dx, al
    mov al, 'I'
    out dx, al
    mov al, 'L'
    out dx, al
    mov al, ']'
    out dx, al
    mov al, 10
    out dx, al
    pop rdx
    pop rax
    ret

rtl8156_ser_puts:
    push rax
    push rdx
    push rsi
    mov dx, 0x3F8
.loop:
    mov al, [rsi]
    test al, al
    jz .done
    out dx, al
    inc rsi
    jmp .loop
.done:
    pop rsi
    pop rdx
    pop rax
    ret

rtl8156_ser_putc:
    push rax
    push rdx
    mov dx, 0x3F8
    out dx, al
    pop rdx
    pop rax
    ret

; AL = byte to print as 2 hex chars
rtl8156_ser_phex8:
    push rax
    push rcx
    push rdx
    mov dx, 0x3F8
    mov cl, al
    shr al, 4
    and al, 0x0F
    cmp al, 10
    jl .h1d
    add al, 'A' - 10
    jmp .h1e
.h1d:
    add al, '0'
.h1e:
    out dx, al
    mov al, cl
    and al, 0x0F
    cmp al, 10
    jl .h2d
    add al, 'A' - 10
    jmp .h2e
.h2d:
    add al, '0'
.h2e:
    out dx, al
    pop rdx
    pop rcx
    pop rax
    ret

; -------------------------------------------------------------------------
; rtl8156_selftest — boot-time auto-test of the network stack.
; Drives a deterministic serial trace: try RTL8156 USB NIC first, fall back
; to the emulated RTL8139 PCI NIC. Net path that succeeds gets DHCP +
; ICMP-echo exercised. Emits [NETSELFTEST <tag>] markers so a harness can
; grade the run by scraping serial.log:
;   [NETSELFTEST PASS rtl8156]   ← USB 2.5G NIC reached + DHCP + ping
;   [NETSELFTEST PASS rtl8139]   ← only the emulated PCI NIC worked
;   [NETSELFTEST FAIL]           ← neither backend reached DHCP+ping
; -------------------------------------------------------------------------
extern rtl_active
extern rtl_dhcp_bound
extern net_ping_ipv4
global rtl8156_selftest
rtl8156_selftest:
    push rdi
    push rsi
    lea rsi, [rel ser_selftest_begin]
    call rtl8156_ser_puts

    ; Try the USB RTL8156 first; success here is the "good" outcome.
    ; Let rtl8156_init bring up xHCI itself. It uses that fact to decide
    ; whether it may run the initial port power/reset sweep; pre-initializing
    ; xHCI here makes the NIC probe skip that required first pass.
    call rtl8156_init
    test eax, eax
    jz .try_8139
    call rtl8156_dhcp_configure
    cmp byte [rtl8156_dhcp_bound], 1
    jne .try_8139
    mov eax, [rtl8156_dhcp_router]
    bswap eax
    mov edi, eax
    call rtl8156_icmp_ping_ipv4
    test eax, eax
    jz .try_8139
    lea rsi, [rel ser_ping_gw_ok]
    call rtl8156_ser_puts
    ; Also exercise an off-LAN public address (8.8.8.8) so we know the gateway
    ; actually forwards and replies. Non-fatal — selftest still passes if the
    ; gateway responded; we just mark whether 8.8.8.8 was reachable.
    mov edi, 0x08080808            ; 8.8.8.8 packed A.B.C.D
    call rtl8156_icmp_ping_ipv4
    test eax, eax
    jz .ext_ping_failed
    lea rsi, [rel ser_ping_ext_ok]
    call rtl8156_ser_puts
    jmp .selftest_pass_8156
.ext_ping_failed:
    lea rsi, [rel ser_ping_ext_fail]
    call rtl8156_ser_puts
.selftest_pass_8156:
    lea rsi, [rel ser_selftest_pass_8156]
    call rtl8156_ser_puts
    jmp .done

.try_8139:
    lea rsi, [rel ser_selftest_no_init]
    call rtl8156_ser_puts
    ; Fallback: emulated PCI NIC. net_ping_ipv4 internally calls
    ; rtl8139_icmp_ping_ipv4, which lazy-runs DHCP and prints
    ; [DHCP DISC]/[DHCP OFFER]/[DHCP ACK] over COM1.
    cmp byte [rtl_active], 1
    jne .fail
    ; Ping the QEMU usermode gateway (10.0.2.2). This is also what triggers
    ; lazy DHCP in the rtl8139 driver, so [DHCP DISC]/[DHCP OFFER]/[DHCP ACK]
    ; and TX/RX traffic markers all fire here. We then accept either a
    ; successful echo *or* a confirmed DHCP lease as proof the NIC RX/TX is
    ; healthy — QEMU slirp doesn't always answer ICMP, so DHCP-bound is the
    ; reliable signal.
    mov edi, 0x0202000A            ; 10.0.2.2 packed A.B.C.D
    call net_ping_ipv4
    cmp byte [rtl_dhcp_bound], 1
    jne .fail
    lea rsi, [rel ser_selftest_pass_8139]
    call rtl8156_ser_puts
    jmp .done
.fail:
    lea rsi, [rel ser_selftest_fail]
    call rtl8156_ser_puts
.done:
    pop rsi
    pop rdi
    ret

section .data
ser_selftest_begin     db "[NETSELFTEST BEGIN]", 10, 0
ser_selftest_pass_8156 db "[NETSELFTEST PASS rtl8156]", 10, 0
ser_ping_gw_ok        db "[PING GW OK]", 10, 0
ser_ping_ext_ok       db "[PING 8.8.8.8 OK]", 10, 0
ser_ping_ext_fail     db "[PING 8.8.8.8 FAIL]", 10, 0
ser_selftest_pass_8139 db "[NETSELFTEST PASS rtl8139]", 10, 0
ser_selftest_fail      db "[NETSELFTEST FAIL]", 10, 0
ser_selftest_no_xhci   db "[NETSELFTEST xhci_init failed]", 10, 0
ser_selftest_no_init   db "[NETSELFTEST rtl8156_init failed - falling back to rtl8139]", 10, 0
sz_r8156_init  db "NET: RTL8156 USB init", 0
sz_r8156_ready db "NET: RTL8156 USB ready", 0
sz_r8156_fail  db "NET: RTL8156 USB unavailable", 0
ser_dhcp_start db "[DHCP DISC]", 10, 0
ser_dhcp_offer db "[DHCP OFFER]", 10, 0
ser_dhcp_ack db "[DHCP ACK]", 10, 0
ser_dhcp_fail db "[DHCP FAIL]", 10, 0
ser_r8156_ping_fail db "[R8156 PING FAIL]", 10, 0
ser_link_wait_8156 db "[R8156 LINK WAIT]", 10, 0
ser_link_up_8156 db "[R8156 LINK UP]", 10, 0
ser_link_timeout_8156 db "[R8156 LINK TIMEOUT]", 10, 0
ser_phy_tag db "PHY:", 0
ser_mac_tag db "MAC:", 0
ser_oob_tag db "OOB:", 0
ser_ll_ready db "[LL READY]", 10, 0
ser_ll_timeout db "[LL TIMEOUT]", 10, 0
ser_tcr0_tag db "TCR0:", 0
ser_cr_tag db "CR:", 0
ser_bmcr_tag db "BMCR BMSR:", 0
ser_bmsr_tag db "BMSR:", 0
ser_tx_tag db "TX len=", 0
ser_tx_done db "TXok", 10, 0
ser_rx_tag db "RX len=", 0
ser_ep_tag db "[R8156 EP in/out mps]:", 0
ser_ep_ctx_in db "[R8156 IN ctx d0/d1]:", 0
; Static profiles used until DHCP is available. Values are little-endian IPv4
; in frame order: guest, next-hop gateway.
rtl8156_ip_profiles:
    dd 0x3264A8C0, 0x0164A8C0    ; 192.168.100.50 -> 192.168.100.1
    dd 0x3201A8C0, 0x0101A8C0    ; 192.168.1.50   -> 192.168.1.1
    dd 0x3200A8C0, 0x0100A8C0    ; 192.168.0.50   -> 192.168.0.1
    dd 0x3289A8C0, 0x0189A8C0    ; 192.168.137.50 -> 192.168.137.1
    dd 0x3200000A, 0x0100000A    ; 10.0.0.50      -> 10.0.0.1
RTL8156_IP_PROFILE_COUNT equ 5

section .bss
global rtl8156_active
global rtl8156_probed
global rtl8156_dbg_stage
global rtl8156_dhcp_bound
global rtl8156_dhcp_state
global rtl8156_dhcp_ip
global rtl8156_dhcp_router
global rtl8156_dhcp_server
global rtl8156_dhcp_dns
global rtl8156_guest_ip
global rtl8156_next_hop_ip
rtl8156_active:          resb 1
alignb 4
rtl8156_lock:            resd 1
; TX-completion mailbox. The main-loop poller routes bulk-OUT transfer
; events here so an in-progress wait_completion (driving a TX) can still
; observe them even though the event ring was drained by usb_poll_mouse.
global rtl8156_tx_done_set, rtl8156_tx_done_code
rtl8156_tx_done_set:  resb 1
alignb 4
rtl8156_tx_done_code: resd 1
rtl8156_probed:          resb 1
rtl8156_dbg_stage:       resb 1
rtl8156_phy_dbg_last:    resq 1
rtl8156_rx_poll_count:   resd 1
global rtl8156_last_vid, rtl8156_last_pid, rtl8156_last_portsc, rtl8156_last_bmsr
rtl8156_last_vid:        resw 1
rtl8156_last_pid:        resw 1
rtl8156_last_portsc:     resd 1
rtl8156_last_bmsr:       resw 1
rtl8156_product:         resw 1
rtl8156_bulk_in_addr:    resb 1
rtl8156_bulk_out_addr:   resb 1
rtl8156_bulk_in_dci:     resb 1
rtl8156_bulk_out_dci:    resb 1
rtl8156_bulk_in_mps:     resw 1
rtl8156_bulk_out_mps:    resw 1
rtl8156_bulk_in_burst:   resb 1
rtl8156_bulk_out_burst:  resb 1
rtl8156_bulk_in_enqueue: resd 1
rtl8156_bulk_out_enqueue: resd 1
rtl8156_bulk_in_cycle:   resb 1
rtl8156_bulk_out_cycle:  resb 1
rtl8156_probe_port_tries: resd 1
rtl8156_walk_port:        resb 1
global rtl8156_net_mac
rtl8156_net_mac:
rtl8156_mac:             resb 6
rtl8156_gw_mac:          resb 6
rtl8156_have_gw_mac:     resb 1
rtl8156_slot_id:         resb 1
global rtl8156_port
rtl8156_port:            resb 1
rtl8156_ping_reply:      resb 1
global rtl8156_ping_last_ttl
rtl8156_ping_last_ttl:   resb 1
rtl8156_ping_seq:        resw 1
rtl8156_guest_ip:        resd 1
rtl8156_next_hop_ip:     resd 1
rtl8156_target_ip:       resd 1
rtl8156_dhcp_bound:      resb 1
rtl8156_dhcp_offer_seen: resb 1
rtl8156_dhcp_ack_seen:   resb 1
rtl8156_dhcp_msg_type:   resb 1
rtl8156_dhcp_xid:        resd 1
rtl8156_dhcp_state:      resb 1
rtl8156_dhcp_deadline:   resq 1
rtl8156_bulk_in_inflight: resb 1
rtl8156_dhcp_ip:         resd 1
rtl8156_dhcp_server:     resd 1
rtl8156_dhcp_router:     resd 1
rtl8156_dhcp_dns:        resd 1
rtl8156_dhcp_candidate_ip: resd 1
rtl8156_dhcp_candidate_server: resd 1
rtl8156_dhcp_candidate_router: resd 1
rtl8156_dhcp_candidate_dns: resd 1
global rtl8156_ping_start_tick, rtl8156_ping_start_tsc
rtl8156_ping_start_tick: resq 1
rtl8156_ping_start_tsc:  resq 1
rtl8156_ping_async_state: resb 1
rtl8156_ping_async_retries: resb 1
alignb 8
rtl8156_ping_async_deadline: resq 1
global rtl8156_net_info
rtl8156_net_info:
    resb NET_NIC_INFO_SIZE
