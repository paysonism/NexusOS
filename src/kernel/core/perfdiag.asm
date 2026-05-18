; ============================================================================
; NexusOS v3.0 - Cache32Max CPU/cache/frequency diagnostics
; ============================================================================
bits 64

%include "constants.inc"
%include "macros.inc"

extern ser_print_hex64
extern tick_count
extern madt_enabled_cpu_count
extern smp_target_cores
extern smp_started_cores
extern smp_alive_cores
extern smp_parked_cores
extern l3_app_arena_base_v

section .text
global perfdiag_init
global perfdiag_print_profile
global perfdiag_print_memory
global perfdiag_print_smp
global perfdiag_benchmark

perfdiag_init:
    call perfdiag_collect
    call perfdiag_print_profile
    ret

perfdiag_collect:
    push rax
    push rbx
    push rcx
    push rdx

    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000006
    jb .fallback

    mov eax, 0x80000005
    cpuid
    mov eax, ecx
    shr eax, 24
    mov [l1d_kb], eax
    mov eax, edx
    shr eax, 24
    mov [l1i_kb], eax

    mov eax, 0x80000006
    cpuid
    mov eax, ecx
    shr eax, 16
    mov [l2_kb], eax
    mov eax, edx
    shr eax, 18
    and eax, 0x3FFF
    shl eax, 9
    mov [l3_kb], eax
    jmp .topology

.fallback:
    mov dword [l1d_kb], 32
    mov dword [l1i_kb], 32
    mov dword [l2_kb], 1024
    mov dword [l3_kb], 16384

.topology:
    mov eax, 1
    cpuid
    mov eax, ebx
    shr eax, 16
    and eax, 0xFF
    test eax, eax
    jnz .store_logical
    mov eax, 1
.store_logical:
    mov [cpuid_logical_count], eax

    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

perfdiag_print_profile:
    push rdi
    lea rdi, [rel msg_cpu]
    call serial_puts
    mov eax, [cpuid_logical_count]
    mov rdi, rax
    call ser_print_hex64
    call serial_crlf

    lea rdi, [rel msg_cache]
    call serial_puts
    mov eax, [l1d_kb]
    add eax, [l1i_kb]
    mov rdi, rax
    call ser_print_hex64
    SER '/'
    mov eax, [l2_kb]
    mov rdi, rax
    call ser_print_hex64
    SER '/'
    mov eax, [l3_kb]
    mov rdi, rax
    call ser_print_hex64
    call serial_crlf

    lea rdi, [rel msg_freq]
    call serial_puts
    call measure_tsc_tick
    mov [cpu_tsc_per_tick], rax
    mov rdi, rax
    call ser_print_hex64
    call serial_crlf

    call perfdiag_print_memory
    call perfdiag_print_smp
    pop rdi
    ret

perfdiag_print_memory:
    push rdi
    lea rdi, [rel msg_memcap]
    call serial_puts
%ifdef NEXUS_CACHE32_MAX
    mov rdi, CACHE32_RAM_LIMIT
%else
    xor rdi, rdi
%endif
    call ser_print_hex64
    SER ' '
    lea rdi, [rel msg_gui]
    call serial_puts
    mov rdi, GUI_LLC_ARENA_START
    call ser_print_hex64
    SER '-'
    mov rdi, GUI_LLC_ARENA_END
    call ser_print_hex64
    SER ' '
    lea rdi, [rel msg_app]
    call serial_puts
    mov rdi, [rel l3_app_arena_base_v]
    call ser_print_hex64
    call serial_crlf
    pop rdi
    ret

perfdiag_print_smp:
    push rdi
    lea rdi, [rel msg_smp]
    call serial_puts
    mov eax, [madt_enabled_cpu_count]
    test eax, eax
    jnz .have_madt
%ifdef NEXUS_CACHE32_MAX
    mov eax, [cpuid_logical_count]
    cmp eax, 2
    jb .have_madt
    mov eax, 1
    jmp .have_madt
%endif
    mov eax, [cpuid_logical_count]
.have_madt:
    mov rdi, rax
    call ser_print_hex64
    SER '/'
    mov eax, [smp_target_cores]
    mov rdi, rax
    call ser_print_hex64
    SER '/'
    mov eax, [smp_started_cores]
    mov rdi, rax
    call ser_print_hex64
    SER '/'
    mov eax, [smp_alive_cores]
    mov rdi, rax
    call ser_print_hex64
    SER '/'
    mov eax, [smp_parked_cores]
    mov rdi, rax
    call ser_print_hex64
    call serial_crlf
    pop rdi
    ret

perfdiag_benchmark:
    push rbx
    push rcx
    push rdx
    push rdi
    lea rdi, [rel msg_bench]
    call serial_puts
    call rdtsc64
    mov rbx, rax
    mov ecx, 2000000
.loop:
    imul rax, rax, 1103515245
    add rax, 12345
    dec ecx
    jnz .loop
    mov rdx, rax
    call rdtsc64
    sub rax, rbx
    mov rdi, rax
    call ser_print_hex64
    SER ':'
    mov rdi, rdx
    call ser_print_hex64
    call serial_crlf
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    ret

measure_tsc_tick:
    push rbx
    push rcx
    push rdx
    push r8

    pushfq
    pop rax
    test eax, 0x200
    jz .no_if

    mov rbx, [tick_count]
    mov ecx, 5000000
.wait_first:
    cmp [tick_count], rbx
    jne .got_first
    dec ecx
    jnz .wait_first
    jmp .no_if
.got_first:
    call rdtsc64
    mov r8, rax
    mov rbx, [tick_count]
    mov ecx, 5000000
.wait_second:
    cmp [tick_count], rbx
    jne .got_second
    dec ecx
    jnz .wait_second
    jmp .no_if
.got_second:
    call rdtsc64
    sub rax, r8
    jmp .done

.no_if:
    xor eax, eax
.done:
    pop r8
    pop rdx
    pop rcx
    pop rbx
    ret

rdtsc64:
    push rdx
    rdtsc
    shl rdx, 32
    or rax, rdx
    pop rdx
    ret

serial_puts:
    push rax
    push rdx
    push rdi
.loop:
    mov al, [rdi]
    test al, al
    jz .done
    call serial_putc
    inc rdi
    jmp .loop
.done:
    pop rdi
    pop rdx
    pop rax
    ret

serial_crlf:
    push rax
    mov al, 13
    call serial_putc
    mov al, 10
    call serial_putc
    pop rax
    ret

serial_putc:
    push rdx
    push rax
    mov dx, 0x3F8 + 5
.wait:
    in al, dx
    test al, 0x20
    jz .wait
    pop rax
    mov dx, 0x3F8
    out dx, al
    pop rdx
    ret

section .data
align 64
l1d_kb: dd 32
l1i_kb: dd 32
l2_kb: dd 1024
l3_kb: dd 16384
global cpuid_logical_count
cpuid_logical_count: dd 1
; TSC ticks elapsed over one PIT tick (10ms). CPU Hz = value * 100, so
; MHz = value / 10000. Captured once by perfdiag_print_profile.
global cpu_tsc_per_tick
cpu_tsc_per_tick: dq 0

msg_cpu:    db 'CPU:', 0
msg_cache:  db 'CACHE:', 0
msg_freq:   db 'FREQ:', 0
msg_memcap: db 'MEMCAP:', 0
msg_gui:    db 'GUI:', 0
msg_app:    db 'APP:', 0
msg_smp:    db 'SMP:', 0
msg_bench:  db 'BENCH:', 0
