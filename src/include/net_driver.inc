; ============================================================================
; NexusOS network driver ABI
; ----------------------------------------------------------------------------
; A NIC driver should stay hardware-only:
;   - probe/init the device
;   - expose its MAC
;   - transmit one complete Ethernet frame
;   - pump receive completions and pass complete Ethernet frames upward
;
; Protocol ownership lives in src/kernel/net:
;   Ethernet -> ARP -> IPv4 -> UDP/TCP/DHCP/DNS/ICMP
;
; Driver ops table layout:
;   dq name_ptr
;   dd driver_id
;   dd priority          ; larger wins when multiple NICs are active
;   dq init_fn           ; () -> EAX=1 active, 0 unavailable
;   dq active_flag_ptr   ; byte, 1 active
;   dq mac_ptr           ; six bytes
;   dq tx_frame_fn       ; RDI=Ethernet frame, ECX=len -> EAX=1 queued/sent
;   dq poll_rx_fn        ; non-blocking RX pump, returns EAX=1 if work
;   dq legacy_ping_fn    ; temporary until ICMP is fully generic
;   dq legacy_dhcp_fn    ; temporary until DHCP is fully generic
;   dq legacy_dhcp_start_fn
;   dq info_block_ptr    ; NET_NIC_INFO_* byte/dword fields below
; ============================================================================

NET_NIC_OP_NAME             equ 0
NET_NIC_OP_ID               equ 8
NET_NIC_OP_PRIORITY         equ 12
NET_NIC_OP_INIT             equ 16
NET_NIC_OP_ACTIVE_PTR       equ 24
NET_NIC_OP_MAC_PTR          equ 32
NET_NIC_OP_TX_FRAME         equ 40
NET_NIC_OP_POLL_RX          equ 48
NET_NIC_OP_LEGACY_PING4     equ 56
NET_NIC_OP_LEGACY_DHCP      equ 64
NET_NIC_OP_LEGACY_DHCP_START equ 72
NET_NIC_OP_INFO_PTR         equ 80
NET_NIC_OP_SIZE             equ 88

NET_NIC_INFO_DHCP_BOUND     equ 0
NET_NIC_INFO_DHCP_STATE     equ 1
NET_NIC_INFO_LAST_TTL       equ 2
NET_NIC_INFO_RESERVED       equ 3
NET_NIC_INFO_DHCP_IP        equ 4
NET_NIC_INFO_DHCP_ROUTER    equ 8
NET_NIC_INFO_DHCP_SERVER    equ 12
NET_NIC_INFO_GUEST_IP       equ 16
NET_NIC_INFO_NEXT_HOP_IP    equ 20
NET_NIC_INFO_DNS_SERVER     equ 24
NET_NIC_INFO_SIZE           equ 28

NET_NIC_NONE                equ 0
NET_NIC_RTL8156             equ 1
NET_NIC_RTL8139             equ 2

NET_ETH_TYPE_IPV4           equ 0x0008
NET_ETH_TYPE_ARP            equ 0x0608
NET_IP_PROTO_ICMP           equ 1
NET_IP_PROTO_TCP            equ 6
NET_IP_PROTO_UDP            equ 17
