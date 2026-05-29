; ============================================================================
; NexusOS v3.0 - UEFI Bootloader (BOOTX64.EFI)
; Loads KERNEL.BIN from EFI partition, sets up GOP/paging, jumps to kernel.
; ============================================================================
bits 64
default rel

%include "src/include/boot_memory.inc"

; --- PE image layout ---
%define HDR_SZ       0x200
%define TEXT_RAW     0x10000
%define TEXT_VA      0x1000
%define RELOC_FOFF   (HDR_SZ + TEXT_RAW)
%define RELOC_FSZ    0x200
%define RELOC_VA     0x11000
%define RELOC_VSZ    0x0C
%define IMAGE_SZ     0x12000

; --- UEFI System Table offsets ---
%define ST_BOOTSVC   96

; --- Boot Services offsets ---
%define BS_ALLOCPG   40
%define BS_GETMMAP   56
%define BS_ALLOCPL   64
%define BS_HNDLPROT  152
%define BS_OPENPROT  280
%define BS_LOCHNDL   312
%define BS_LOCATE    320
%define BS_EXITBOOT  232
%define BS_WATCHDOG  256

; --- GOP offsets ---
%define GOP_QUERY    0
%define GOP_SET      8
%define GOP_MODE     24
%define GOPM_MAX     0
%define GOPM_CUR     4
%define GOPM_FBBASE  24
%define GOPI_HRES    4
%define GOPI_VRES    8
%define GOPI_PPSL    32

; --- Simple Filesystem / File offsets ---
%define SFS_OPENVOL  8
%define FP_OPEN      8
%define FP_CLOSE     16
%define FP_READ      32
%define FP_WRITE     40

; --- Physical memory aliases ---
%define VBE_INFO     VBE_INFO_ADDR
%define PT_BASE      PAGE_TABLE_ADDR
%define KERN_DEST    KERNEL_LOAD_ADDR
%define KERN_STACK   KERNEL_STACK_TOP
%define APPS_MAX_SZ  APPS_BLOB_MAX_SIZE

; --- UCS-2 string macro ---
%macro ustr 1+
  %assign %%i 1
  %strlen %%n %1
  %rep %%n
    %substr %%c %1 %%i
    dw %%c
    %assign %%i %%i+1
  %endrep
  dw 0
%endmacro

; --- Serial macros (COM1 = 0x3F8, clobber nothing) ---

%macro SER 1
%ifndef RELEASE_BUILD
    push rax
    push rdx
    mov dx, 0x3F8
    mov al, %1
    out dx, al
    pop rdx
    pop rax
%endif
%endmacro

%macro SDBG 1
%ifndef RELEASE_BUILD
  push rax
  push rdx
  mov dx, 0x3F8
  %strlen %%n %1
  %assign %%i 1
  %rep %%n
    %substr %%c %1 %%i
    mov al, %%c
    out dx, al
    %assign %%i %%i+1
  %endrep
  mov al, 13
  out dx, al
  mov al, 10
  out dx, al
  pop rdx
  pop rax
%endif
%endmacro

%macro SREG 2
%ifndef RELEASE_BUILD
  push rbx
  push rax
  push rcx
  push rdx
  mov rbx, %2
  mov dx, 0x3F8
  %strlen %%n %1
  %assign %%i 1
  %rep %%n
    %substr %%c %1 %%i
    mov al, %%c
    out dx, al
    %assign %%i %%i+1
  %endrep
  mov al, '='
  out dx, al
  mov ecx, 16
%%hl:
  rol rbx, 4
  mov al, bl
  and al, 0xF
  add al, '0'
  cmp al, '9'
  jle %%ok
  add al, 7
%%ok:
  out dx, al
  dec ecx
  jnz %%hl
  mov al, 13
  out dx, al
  mov al, 10
  out dx, al
  pop rdx
  pop rcx
  pop rax
  pop rbx
%endif
%endmacro

; ============================================================================
; PE/COFF HEADER
; ============================================================================
section .text start=0
    dw 0x5A4D                       ; MZ
    times 29 dw 0
    dd pe_hdr

pe_hdr:
    dd 0x00004550                   ; "PE\0\0"
    dw 0x8664                       ; x86-64
    dw 2                            ; 2 sections
    dd 0, 0, 0
    dw opt_end - opt_hdr
    dw 0x0206

opt_hdr:
    dw 0x020B                       ; PE32+
    db 1, 0
    dd TEXT_RAW, 0, 0, TEXT_VA, TEXT_VA
    dq KERN_DEST                    ; Image base (preferred)
    dd 0x1000, 0x200                ; Section / file alignment
    dw 0,0, 0,0, 0,0
    dd 0, IMAGE_SZ, HDR_SZ, 0
    dw 10, 0                        ; Subsystem: EFI Application
    dq KERN_DEST, KERN_DEST, KERN_DEST, KERN_DEST
    dd 0, 6                         ; Data directory count
    dd 0,0, 0,0, 0,0, 0,0, 0,0
    dd RELOC_VA, RELOC_VSZ          ; Base reloc directory
opt_end:

    db '.text',0,0,0
    dd TEXT_RAW, TEXT_VA, TEXT_RAW, HDR_SZ
    dd 0, 0
    dw 0, 0
    dd 0xE0000060                   ; Code | Execute | Read | Write

    db '.reloc',0,0
    dd RELOC_VSZ, RELOC_VA, RELOC_FSZ, RELOC_FOFF
    dd 0, 0
    dw 0, 0
    dd 0x42000040                   ; Initialized data | Discardable | Read

    times (HDR_SZ - ($ - $$)) db 0

; ============================================================================
; ENTRY POINT
; RCX = ImageHandle   RDX = SystemTable
; ============================================================================
_start:
    ; Entry RSP = 16n-8.  sub 40 -> 16n-48 = 0 mod 16. Aligned for calls.
    sub rsp, 40
    mov [v_handle], rcx
    mov [v_systab], rdx

    mov rax, [rdx + ST_BOOTSVC]
    mov [v_bs], rax

    ; Disable watchdog (4 args, all zero except handle)
    mov rcx, [v_bs]
    mov rax, [rcx + BS_WATCHDOG]
    xor ecx, ecx
    xor edx, edx
    xor r8d, r8d
    xor r9d, r9d
    call rax

    ; === S0: Claim fixed physical pages for kernel use ===
    call claim_pages

    ; === S1: GOP graphics init ===
    call gop_init
    test rax, rax
    jnz .gop_warn
    jmp .gop_done
.gop_warn:
    mov rdi, VBE_INFO
    xor eax, eax
    mov ecx, 24 / 4
    rep stosd
.gop_done:

    ; === S1.25: Allocate dynamic boot-owned buffers ===
    call alloc_boot_regions

    ; === S1.5: Locate EFI_SIMPLE_POINTER_PROTOCOL and save for kernel ===
    call locate_spp

    ; === S2: Load kernel from filesystem ===
    call load_kernel
    test rax, rax
    jnz .fail_kernel

    ; === S2b: Load APPS.BIN ===
    ; KASLR mode keeps using the embedded app blob. The diff-relocation fixup
    ; table patches that copy along with the rest of the kernel payload; the
    ; standalone APPS.BIN is built at the unslid 0x100000 base and cannot be
    ; reused after a random slide without a second relocation pass.
%ifndef ENABLE_KASLR
    call load_apps
%else
    mov qword [abs VBE_INFO + VBE_APPS_BASE_OFF], 0
    mov qword [abs VBE_INFO + VBE_APPS_SIZE_OFF], 0
%endif

    ; === S2b2: Load DATA.IMG (FAT16 ramdisk for real hardware) ===
    ; Real laptops have no legacy IDE controller, so the kernel's fat16
    ; driver cannot reach a separate data disk. The build script writes
    ; the FAT partition to \EFI\BOOT\DATA.IMG; we slurp it into firmware-
    ; allocated pages and publish (base, size) via VBE_INFO. ata.asm's
    ; ramdisk shim then satisfies fat16 sector I/O from RAM. Non-fatal:
    ; if DATA.IMG is missing the kernel falls back to ATA PIO and simply
    ; finds no usable volume (same as today).
    call load_data_img

    ; === S2b3: Phase 1b - resolve DATA.IMG physical LBA extents on the ESP
    ; via EFI_BLOCK_IO_PROTOCOL while firmware services are still alive.
    ; Captured in VBE_INFO + STORAGE_EXTENTS_ADDR for ramdisk_flush in the
    ; kernel (Phase 5). Non-fatal: failure leaves contract zeroed.
    call resolve_data_img_extents

    ; === S2c: If previous kernel left a klog flush request in RAM, write it
    ; out to \KLOG.TXT and clear the magic. Non-fatal on failure. ===
    call flush_klog_if_pending

    ; === S3: Build identity-mapped page tables ===
    call setup_paging

    ; === S4: Exit boot services ===
    call exit_boot_services
    test rax, rax
    jnz .fail_exit

    cli

    SER 'E'             ; E = ExitBootServices OK

    ; Fix CR4: clear LA57/PCIDE/SMEP/SMAP/PKE, enable PAE+SSE
    mov rax, cr4
    btr rax, 7          ; PGE   off
    btr rax, 12         ; LA57  off
    btr rax, 17         ; PCIDE off
    btr rax, 20         ; SMEP  off
    btr rax, 21         ; SMAP  off
    btr rax, 22         ; PKE   off
    bts rax, 5          ; PAE   on
    bts rax, 9          ; OSFXSR on
    bts rax, 10         ; OSXMMEXCPT on
    mov cr4, rax
    SER 'C'             ; C = CR4 fixed

    ; Fix EFER: set LME and NXE. NXE is required before any PTE uses
    ; PAGE_NX (bit 63); per-slot W^X enforcement (l3_apply_wx_policy)
    ; relies on this. BIOS path mirrors this in stage2.asm.
    mov ecx, 0xC0000080
    rdmsr
    bts eax, 8          ; LME on
    bts eax, 11         ; NXE on (enable NX bit in page tables)
    wrmsr
    SER 'F'             ; F = EFER fixed

    ; Clear CR0.WP so we can write UEFI's read-only 0x100000
    mov rax, cr0
    btr rax, 16
    mov cr0, rax
    SER 'W'             ; W = WP cleared

    ; Copy GDT to 0x500 and trampoline to 0x8000 BEFORE anything
    ; else can corrupt the PE image we're still running from.
    cld
    lea rsi, [gdt64]
    mov rdi, 0x500
    mov rcx, gdt64_end - gdt64
    rep movsb

    lea rsi, [trampoline]
    mov rdi, 0x8000
    mov rcx, (trampoline_end - trampoline + 7) / 8
    rep movsq
    SER 'T'             ; T = GDT + trampoline copied

    ; Load GDT from 0x580 (fixed physical address)
    mov word  [abs 0x580], gdt64_end - gdt64 - 1
    mov qword [abs 0x582], 0x500
    lgdt [abs 0x580]

    ; Far return to reload CS = 0x08
    lea rax, [.cs_reload]
    push qword 0x08
    push rax
    retfq

.cs_reload:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    SER 'G'             ; G = GDT + segments reloaded

    ; Switch to kernel stack
    mov rsp, KERN_STACK
    SER 'S'             ; S = stack set

    ; === KASLR: parse container header, pick slide, set up trampoline args ===
    ;
    ; Container layout (see tools/build/extract_kaslr_fixups.py):
    ;   0x00 8  magic "NXKASLR0"
    ;   0x08 4  payload_size
    ;   0x0C 4  entry_offset
    ;   0x10 4  fixup_count
    ;   0x14 4  reserved
    ;   0x18 fixup_count*4   fixup_offsets (u32 each, into payload)
    ;   ...  payload_size    raw kernel bytes (assembled at KERNEL_LOAD_ADDR)
    ;
    ; Slide window:
    ;   max_slide = KERNEL_STACK_TOP - STACK_RESERVE - KERNEL_LOAD_ADDR - payload
    ;             = 0xC00000 - 0x40000 - 0x100000 - payload_size
    ;             = 0xAC0000 - payload_size
    ;   Floor-aligned to 4 KiB. 256 KiB stack reserve keeps the kernel stack
    ;   (grows down from 0xC00000) clear of slid kernel text.
    ;
    ; Without ENABLE_KASLR the slide is forced to 0 — runtime layout must
    ; reproduce the legacy "kernel at 0x100000" behavior byte-for-byte.
    mov rsi, [v_kernel_addr]

    mov rax, [rsi]
    mov rbx, 0x3052_4C53_414B_584E   ; "NXKASLR0" little-endian
    cmp rax, rbx
    jne .kaslr_bad_magic

    mov eax, [rsi + 0x08]            ; payload_size
    mov [v_payload_size], rax
    mov eax, [rsi + 0x0C]            ; entry_offset
    mov [v_entry_off], rax
    mov eax, [rsi + 0x10]            ; fixup_count
    mov [v_fixup_count], rax

    lea rbx, [rsi + 0x18]            ; fixup table start
    mov [v_fixup_src], rbx

    mov rax, [v_fixup_count]
    shl rax, 2                       ; *4 bytes per fixup offset
    add rax, rbx                     ; payload start = fixups end
    mov [v_payload_src], rax

%ifdef ENABLE_KASLR
    mov rax, 0xAC0000
    sub rax, [v_payload_size]
    jbe .slide_zero                  ; payload too large for window
    shr rax, 12                      ; max_pages (exclusive upper bound)
    jz  .slide_zero
    mov rbx, rax                     ; rbx = max_pages

    push rbx
    mov eax, 1
    cpuid
    bt  ecx, 30                      ; RDRAND support
    pop rbx
    jnc .slide_rdtsc
    rdrand rax
    jc  .slide_mix
    rdrand rax
    jc  .slide_mix
.slide_rdtsc:
    rdtsc
    shl rdx, 32
    or  rax, rdx
.slide_mix:
    push rax
    rdtsc
    shl rdx, 32
    or  rax, rdx
    pop rcx
    xor rax, rcx
    mov rcx, 0x9E3779B97F4A7C15
    xor rax, rcx
    mov rcx, 0x5851F42D4C957F2D
    mul rcx                          ; LCG multiply (rax = low 64 bits)
    mov rcx, 0x14057B7EF767814F
    add rax, rcx
.slide_have_rand:
    xor edx, edx
    div rbx                          ; rdx = rand mod max_pages
    test rdx, rdx
    jnz .slide_nonzero
    cmp rbx, 1
    jbe .slide_nonzero
    mov edx, 1                       ; keep enabled-KASLR boots visibly slid
.slide_nonzero:
    shl rdx, 12                      ; -> bytes, 4 KiB aligned
    mov [v_kslide], rdx
    jmp .slide_done
.slide_zero:
%endif
    mov qword [v_kslide], 0
.slide_done:

%ifndef RELEASE_BUILD
    ; Serial print "KS=XXXXXXXX " for boot-log triage.
    SER 'K'
    SER 'S'
    SER '='
    mov ebx, [v_kslide]
    mov ecx, 8
.kslide_print_loop:
    rol ebx, 4
    mov al, bl
    and al, 0x0F
    cmp al, 10
    jb  .kslide_digit
    add al, 'A' - 10 - '0'
.kslide_digit:
    add al, '0'
    mov dx, 0x3F8
    out dx, al
    dec ecx
    jnz .kslide_print_loop
    SER ' '
%endif

    ; Trampoline contract (see trampoline: below).
    mov rsi, [v_payload_src]
    mov rdi, KERN_DEST
    add rdi, [v_kslide]
    mov rcx, [v_payload_size]
    mov r8,  [v_fixup_src]
    mov r9,  [v_fixup_count]
    mov r10, [v_kslide]
    mov r11, [v_entry_off]
    SER 'J'             ; J = jumping to trampoline
    mov rax, 0x8000
    jmp rax

.kaslr_bad_magic:
    SDBG 'KASLR-MAGIC'
    jmp .halt

; --- Failure handlers ---
.fail_kernel:
    SDBG 'KERN-FAIL'
    jmp .halt
.fail_exit:
    SDBG 'EXIT-FAIL'
.halt:
    cli
    hlt
    jmp .halt

; ============================================================================
; TRAMPOLINE  - copied to 0x8000, runs after ExitBootServices
; In:  RSI = payload source           (within UEFI-allocated buffer)
;      RDI = destination base         (KERN_DEST + slide)
;      RCX = payload byte count
;      R8  = fixup table source       (u32 offsets, within UEFI buffer)
;      R9  = fixup count
;      R10 = slide value              (added to each [dest+offset] qword)
;      R11 = entry offset             (jump target = dest_base + R11)
;
; The UEFI-allocated buffer that holds the original wrapped kernel (R8's
; backing) does NOT overlap [RDI, RDI+RCX) — UEFI's AllocateAnyPages places
; it well above the kernel destination window — so fixup reads remain valid
; after the copy.
; ============================================================================
align 16
trampoline:
    ; Preserve dest base + fixup-walk regs across rep movsq.
    mov r12, rdi                ; dest base (preserved)
    mov r13, r8                 ; fixup table cursor (preserved)
    mov r14, r9                 ; remaining fixup count (preserved)

    add rcx, 7
    shr rcx, 3                  ; round up to qwords
    rep movsq

    ; Walk fixups: for each u32 off in [r13 .. r13 + r14*4): [r12+off] += r10
    test r10, r10
    jz   .tramp_no_fixups       ; slide=0 -> nothing to patch
    test r14, r14
    jz   .tramp_no_fixups
.tramp_fix_loop:
    mov  eax, [r13]             ; u32 offset (zero-extended)
    add  [r12 + rax], r10
    add  r13, 4
    dec  r14
    jnz  .tramp_fix_loop
.tramp_no_fixups:

    wbinvd
    ; Switch to our own page tables (with User bits for ring 3)
    mov rax, PT_BASE
    mov cr3, rax
    add r12, r11                ; entry = dest_base + entry_offset
    jmp r12
trampoline_end:

; ============================================================================
; CLAIM_PAGES  - AllocateAddress for all fixed kernel memory regions
; Failures are tolerated (firmware may own 0x100000; trampoline handles it).
; ============================================================================
claim_pages:
    ; Entry RSP=16n-8. push -> 16n-16. sub 32 -> 16n-48 = 0 mod 16.
    push rbx
    sub rsp, 32

    %macro DO_CLAIM 2               ; addr, num_pages
      mov qword [v_tmp_addr], %1
      mov rcx, [v_bs]
      mov rax, [rcx + BS_ALLOCPG]
      mov ecx, 2                    ; AllocateAddress
      mov edx, 2                    ; EfiLoaderData
      mov r8, %2
      lea r9, [v_tmp_addr]
      call rax
    %endmacro

    DO_CLAIM VBE_INFO,   1          ; Boot info block
    DO_CLAIM 0x1000,     1          ; E820 entry count page
    DO_CLAIM E820_MAP_ADDR, 4       ; BIOS-compatible memory map handoff
    DO_CLAIM PT_BASE,    19         ; PML4+PDPT0+PDPT1+PD0+PT0+12 app PTs (0x70000..0x80FFF)
                                    ; + 1 gap page at 0x81000 (BIOS PD3 slot, unused here)
                                    ; + syscall-stack PT at 0x82000 = 19 pages total
    DO_CLAIM SMP_TRAMPOLINE_ADDR, 1 ; Trampoline
    ; NOTE: Do NOT claim KERN_DEST (0x100000) here — UEFI loaded our own
    ; PE image at ImageBase=0x100000.  Claiming it could corrupt memory
    ; protections on our code/data/stack while we're still executing.
    ; The trampoline copies the kernel there AFTER ExitBootServices.
    DO_CLAIM KERN_STACK, 16         ; Kernel stack + IDT space

    add rsp, 32
    pop rbx
    ret

; ============================================================================
; ALLOC_BOOT_REGIONS - allocate variable physical regions and publish boot info
; ============================================================================
alloc_boot_regions:
    push rbx
    sub rsp, 40

    mov qword [abs VBE_INFO + VBE_BACKBUF_OFF], BACK_BUFFER_ADDR
    mov qword [abs VBE_INFO + VBE_BACKBUF_SIZE_OFF], BOOT_BACK_BUFFER_SIZE
    mov qword [abs VBE_INFO + VBE_APP_ARENA_BASE_OFF], APP_DATA_ADDR
    mov qword [abs VBE_INFO + VBE_APP_ARENA_SIZE_OFF], (APP_SLOT_SIZE * APP_SLOT_COUNT)

    ; App arena uses 2MB PDE permissions today, so keep it 2MB-aligned.
    mov qword [v_tmp_addr], APP_DATA_ADDR
    mov rcx, [v_bs]
    mov rax, [rcx + BS_ALLOCPG]
    mov ecx, 2                      ; AllocateAddress
    mov edx, 2                      ; EfiLoaderData
    mov r8, (APP_SLOT_SIZE * APP_SLOT_COUNT) / 0x1000
    lea r9, [v_tmp_addr]
    call rax
    test rax, rax
    jnz .alloc_backbuf
    mov rax, [v_tmp_addr]
    mov [abs VBE_INFO + VBE_APP_ARENA_BASE_OFF], rax

.alloc_backbuf:
    mov qword [v_tmp_addr], 0
    mov rcx, [v_bs]
    mov rax, [rcx + BS_ALLOCPG]
    mov ecx, 0                      ; AllocateAnyPages
    mov edx, 2                      ; EfiLoaderData
    mov r8, (BOOT_BACK_BUFFER_SIZE + 0xFFF) / 0x1000
    lea r9, [v_tmp_addr]
    call rax
    test rax, rax
    jnz .done

    mov rax, [v_tmp_addr]
    mov [abs VBE_INFO + VBE_BACKBUF_OFF], rax

.done:
    add rsp, 40
    pop rbx
    ret

; ============================================================================
; GOP_INIT  - find GOP, set best video mode (prefer 1024x768), fill VBE_INFO
; Returns: RAX = 0 success, 1 fail
; ============================================================================
gop_init:
    push rbx
    push r12
    push r13
    push r14
    push r15
    ; 5 pushes = 40 bytes. Entry 16n-8. After pushes: 16n-48.
    ; sub 80 -> 16n-128 = 0 mod 16. Aligned.
    sub rsp, 80
    ; [rsp +  0..31] shadow space
    ; [rsp + 32]     arg5 slot
    ; [rsp + 40]     arg6 slot
    ; [rsp + 48]     local: num_handles
    ; [rsp + 56]     local: handle_buffer ptr
    ; [rsp + 64]     local: info_size
    ; [rsp + 72]     local: info_ptr

    ; --- Try LocateProtocol(gop_guid, NULL, &v_gop) ---
    mov rax, [v_bs]
    mov rax, [rax + BS_LOCATE]
    lea rcx, [guid_gop]
    xor edx, edx
    lea r8, [v_gop]
    call rax
    test rax, rax
    jz .found

    ; --- Fallback: LocateHandleBuffer + OpenProtocol ---
    mov qword [rsp+48], 0
    mov qword [rsp+56], 0
    mov rcx, [v_bs]
    mov rax, [rcx + BS_LOCHNDL]
    mov ecx, 2                      ; ByProtocol
    lea rdx, [guid_gop]
    xor r8d, r8d
    lea r9, [rsp+48]                ; &num_handles
    lea r10, [rsp+56]               ; &handle_buffer
    mov [rsp+32], r10               ; arg5
    call rax
    test rax, rax
    jnz .fail

    cmp qword [rsp+48], 0
    je .fail

    ; OpenProtocol(handle[0], &guid, &v_gop, imghandle, NULL, GET_PROTOCOL=2)
    mov rsi, [rsp+56]
    mov rcx, [rsi]
    mov rdx, [v_bs]
    mov rax, [rdx + BS_OPENPROT]
    lea rdx, [guid_gop]
    lea r8, [v_gop]
    mov r9, [v_handle]
    mov qword [rsp+32], 0
    mov qword [rsp+40], 2
    call rax
    test rax, rax
    jnz .fail

.found:
    mov rbx, [v_gop]
    test rbx, rbx
    jz .fail

    ; --- Iterate modes, pick the largest one whose pixel count fits the
    ;     kernel back buffer. "Largest" = greatest width*height. The cap
    ;     comes from boot_memory.inc::BOOT_BACK_BUFFER_SIZE (bytes) so any
    ;     future bump to the back buffer automatically widens the set of
    ;     acceptable modes.
    mov rax, [rbx + GOP_MODE]
    mov r12d, [rax + GOPM_MAX]
    xor r13d, r13d                  ; current mode index
    mov r14d, 0xFFFFFFFF            ; best mode (none)
    xor r15, r15                    ; best pixel count (rdx:rax fits in 32b for our sizes)

.mode_loop:
    cmp r13d, r12d
    jge .select

    mov rcx, rbx
    mov edx, r13d
    lea r8, [rsp+64]
    lea r9, [rsp+72]
    mov rax, [rbx + GOP_QUERY]
    call rax
    test rax, rax
    jnz .next_mode

    mov rax, [rsp+72]
    test rax, rax
    jz .next_mode

    mov ecx, [rax + GOPI_HRES]
    mov edx, [rax + GOPI_VRES]

    ; Reject modes wider than MAX_FB_WIDTH or taller than MAX_FB_HEIGHT.
    ; Without these caps we could pick a mode whose backing scanline does
    ; not fit BOOT_BACK_BUFFER_SIZE and crash the compositor.
    cmp ecx, MAX_FB_WIDTH
    ja .next_mode
    cmp edx, MAX_FB_HEIGHT
    ja .next_mode

    ; pixels = w * h. Compare to running max in r15.
    mov eax, ecx
    imul eax, edx                   ; eax = pixel count (fits in 32 bits for any sane res)
    cmp rax, r15
    jbe .next_mode
    mov r15, rax
    mov r14d, r13d

.next_mode:
    inc r13d
    jmp .mode_loop

.select:
    cmp r14d, 0xFFFFFFFF
    je .fail

    mov rcx, rbx
    mov edx, r14d
    mov rax, [rbx + GOP_SET]
    call rax
    test rax, rax
    jnz .fail

    mov rax, [rbx + GOP_MODE]
    mov rcx, [rax + GOPM_FBBASE]
    mov [v_fb], rcx

    mov edx, [rax + GOPM_CUR]
    mov rcx, rbx
    lea r8, [rsp+64]
    lea r9, [rsp+72]
    mov rax, [rbx + GOP_QUERY]
    call rax

    mov rax, [rsp+72]               ; Info ptr
    test rax, rax
    jz .fallback

    mov ecx, [rax + GOPI_HRES]
    mov [v_scrw], ecx
    mov ecx, [rax + GOPI_VRES]
    mov [v_scrh], ecx
    mov ecx, [rax + GOPI_PPSL]
    mov [v_pitch], ecx
    jmp .fill_vbe

.fallback:
    mov dword [v_scrw],  1024
    mov dword [v_scrh],  768
    mov dword [v_pitch], 1024

.fill_vbe:
    ; Fill boot info block:
    ;   [+0]  fb_addr   (qword)
    ;   [+8]  width     (dword)
    ;   [+12] height    (dword)
    ;   [+16] pitch_bytes (dword, pixels*4)
    ;   [+20] bpp       (dword)
    mov rdi, VBE_INFO
    mov rax, [v_fb]
    mov [rdi + VBE_FB_ADDR_OFF], rax
    mov eax, [v_scrw]
    mov [rdi + VBE_WIDTH_OFF], eax
    mov eax, [v_scrh]
    mov [rdi + VBE_HEIGHT_OFF], eax
    mov eax, [v_pitch]
    shl eax, 2                      ; pixels/line -> bytes/line
    mov [rdi + VBE_PITCH_OFF], eax
    mov dword [rdi + VBE_BPP_OFF], 32

    xor eax, eax
    jmp .done

.fail:
    mov eax, 1

.done:
    add rsp, 80
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

; ============================================================================
; LOAD_KERNEL  - open \EFI\BOOT\KERNEL.BIN via UEFI FS, read into RAM
; Uses LoadedImage protocol to get our boot device, then SFS from it.
; Returns: RAX = 0 success, 1 fail
; Writes:  v_kernel_addr, v_ksize
; ============================================================================
load_kernel:
    push rbx
    push r12
    push r13
    push r14
    push r15
    ; 5 pushes = 40 bytes. Entry 16n-8. After pushes: 16n-48.
    ; sub 96 -> 16n-144 = 0 mod 16. Aligned.
    sub rsp, 96
    ; [rsp +  0..31] shadow
    ; [rsp + 32]     arg5
    ; [rsp + 40]     arg6
    ; [rsp + 48]     local: scratch
    ; [rsp + 56]     local: scratch
    ; [rsp + 64]     local: read_size
    ; [rsp + 72..95] scratch

    mov rcx, [v_bs]
    mov rax, [rcx + BS_HNDLPROT]    ; HandleProtocol
    mov rcx, [v_handle]              ; our ImageHandle
    lea rdx, [guid_lip]             ; LoadedImage GUID
    lea r8,  [v_lip]                ; &LoadedImage
    call rax
    test rax, rax
    jnz .fail

    ; --- Step 2: Get DeviceHandle from LoadedImage ---
    mov rax, [v_lip]
    mov rax, [rax + 24]
    mov [v_devhandle], rax
    test rax, rax
    jz .fail

    ; --- Step 3: Get SFS from DeviceHandle ---
    mov rcx, [v_bs]
    mov rax, [rcx + BS_HNDLPROT]
    mov rcx, [v_devhandle]
    lea rdx, [guid_sfs]
    lea r8,  [v_sfs]
    call rax
    test rax, rax
    jnz .fail

    ; --- Step 4: OpenVolume ---
    mov rbx, [v_sfs]
    mov rcx, rbx
    lea rdx, [v_root]
    mov rax, [rbx + SFS_OPENVOL]
    call rax
    test rax, rax
    jnz .fail

    ; --- Step 5: Open \EFI\BOOT\KERNEL.BIN ---
    mov rbx, [v_root]
    mov rcx, rbx
    lea rdx, [v_file]
    lea r8,  [s_kern_path]
    mov r9,  1
    mov qword [rsp+32], 0
    mov rax, [rbx + FP_OPEN]
    call rax
    test rax, rax
    jnz .fail

    ; --- Step 6: Allocate memory for kernel anywhere UEFI permits ---
    mov rcx, [v_bs]
    mov rax, [rcx + BS_ALLOCPG]
    xor ecx, ecx                    ; AllocateAnyPages
    mov edx, 2                      ; EfiLoaderData
    mov r8,  0x2000                 ; 8192 pages = 32 MB
    lea r9,  [v_kernel_addr]
    call rax
    test rax, rax
    jnz .fail

    ; --- Step 7: Read kernel into allocated buffer ---
    mov qword [rsp+64], 0x2000000   ; max read size (in/out)
    mov rbx, [v_file]
    mov rcx, rbx
    lea rdx, [rsp+64]               ; &ByteCount
    mov r8,  [v_kernel_addr]        ; buffer
    mov rax, [rbx + FP_READ]
    call rax
    test rax, rax
    jnz .fail

    mov rax, [rsp+64]
    mov [v_ksize], rax
    test rax, rax
    jz .fail

    ; --- Close file and root ---
    mov rbx, [v_file]
    mov rcx, rbx
    mov rax, [rbx + FP_CLOSE]
    call rax

    mov rbx, [v_root]
    mov rcx, rbx
    mov rax, [rbx + FP_CLOSE]
    call rax

    xor eax, eax
    jmp .done

.fail:
    mov eax, 1

.done:
    add rsp, 96
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

; ============================================================================
; LOAD_APPS - open \EFI\BOOT\APPS.BIN, read into RAM at APPS_DEST.
; Writes blob base + size into boot info for the kernel to pick up.
; Non-fatal on failure: app blob boot-info fields stay 0.
; ============================================================================
load_apps:
    push rbx
    sub rsp, 48
    ; [rsp +  0..31] shadow
    ; [rsp + 32]     arg5 / scratch
    ; [rsp + 40]     local: read_size (in/out)

    ; Write safe defaults in case anything fails.
    mov qword [abs VBE_INFO + VBE_APPS_BASE_OFF], 0
    mov qword [abs VBE_INFO + VBE_APPS_SIZE_OFF], 0
    mov qword [v_apps_size], 0

    ; Reopen root volume (original root file was closed by load_kernel).
    mov rbx, [v_sfs]
    test rbx, rbx
    jz .fail
    mov rcx, rbx
    lea rdx, [v_root]
    mov rax, [rbx + SFS_OPENVOL]
    call rax
    test rax, rax
    jnz .fail

    ; Open \EFI\BOOT\APPS.BIN
    mov rbx, [v_root]
    mov rcx, rbx
    lea rdx, [v_file]
    lea r8,  [s_apps_path]
    mov r9,  1
    mov qword [rsp+32], 0
    mov rax, [rbx + FP_OPEN]
    call rax
    test rax, rax
    jnz .fail

    ; Allocate APPS.BIN storage from firmware, then read file in.
    mov qword [v_tmp_addr], 0
    mov rcx, [v_bs]
    mov rax, [rcx + BS_ALLOCPG]
    mov ecx, 0                      ; AllocateAnyPages
    mov edx, 2                      ; EfiLoaderData
    mov r8, APPS_MAX_SZ / 0x1000
    lea r9, [v_tmp_addr]
    call rax
    test rax, rax
    jnz .close_and_fail

    mov qword [rsp+40], APPS_MAX_SZ
    mov rbx, [v_file]
    mov rcx, rbx
    lea rdx, [rsp+40]
    mov r8, [v_tmp_addr]
    mov rax, [rbx + FP_READ]
    call rax
    test rax, rax
    jnz .close_and_fail

    mov rax, [rsp+40]               ; actual bytes read
    test rax, rax
    jz .close_and_fail
    mov [v_apps_size], rax
    mov rdx, [v_tmp_addr]
    mov [abs VBE_INFO + VBE_APPS_BASE_OFF], rdx
    mov [abs VBE_INFO + VBE_APPS_SIZE_OFF], rax

    mov rbx, [v_file]
    mov rcx, rbx
    mov rax, [rbx + FP_CLOSE]
    call rax
    jmp .done

.close_and_fail:
    mov rbx, [v_file]
    mov rcx, rbx
    mov rax, [rbx + FP_CLOSE]
    call rax
.fail:
.done:
    add rsp, 48
    pop rbx
    ret

; ============================================================================
; LOAD_DATA_IMG - open \EFI\BOOT\DATA.IMG, read into firmware-allocated RAM,
; publish (base, size) in VBE_INFO so the kernel's ramdisk shim can take over
; block I/O for the FAT16 partition. See src/kernel/drivers/ramdisk.asm and
; docs/ramdisk.md for the contract. Non-fatal on every error: missing file,
; allocation failure, or oversize image all leave the ramdisk fields zero
; and the kernel falls back to ATA PIO.
; ============================================================================
%define DATA_IMG_MAX_SZ DATA_IMG_MAX_SIZE

load_data_img:
    push rbx
    sub rsp, 48
    ; [rsp +  0..31] shadow
    ; [rsp + 32]     arg5 / scratch
    ; [rsp + 40]     local: read_size (in/out)

    ; Safe defaults so a partial failure cannot leave stale pointers.
    mov qword [abs VBE_INFO + VBE_RAMDISK_BASE_OFF], 0
    mov qword [abs VBE_INFO + VBE_RAMDISK_SIZE_OFF], 0
    mov qword [v_data_size], 0

    ; Reopen root volume (previous opens have been closed).
    mov rbx, [v_sfs]
    test rbx, rbx
    jz .fail
    mov rcx, rbx
    lea rdx, [v_root]
    mov rax, [rbx + SFS_OPENVOL]
    call rax
    test rax, rax
    jnz .fail

    ; Open \EFI\BOOT\DATA.IMG (read-only).
    mov rbx, [v_root]
    mov rcx, rbx
    lea rdx, [v_file]
    lea r8,  [s_data_path]
    mov r9,  1
    mov qword [rsp+32], 0
    mov rax, [rbx + FP_OPEN]
    call rax
    test rax, rax
    jnz .fail

    ; AllocatePages(AnyPages, EfiLoaderData, DATA_IMG_MAX_SZ / 4K, &addr).
    mov qword [v_tmp_addr], 0
    mov rcx, [v_bs]
    mov rax, [rcx + BS_ALLOCPG]
    mov ecx, 0
    mov edx, 2
    mov r8, DATA_IMG_MAX_SZ / 0x1000
    lea r9, [v_tmp_addr]
    call rax
    test rax, rax
    jnz .close_and_fail

    mov qword [rsp+40], DATA_IMG_MAX_SZ
    mov rbx, [v_file]
    mov rcx, rbx
    lea rdx, [rsp+40]
    mov r8, [v_tmp_addr]
    mov rax, [rbx + FP_READ]
    call rax
    test rax, rax
    jnz .close_and_fail

    mov rax, [rsp+40]                       ; actual bytes read
    test rax, rax
    jz .close_and_fail
    mov [v_data_size], rax
    mov rdx, [v_tmp_addr]
    mov [abs VBE_INFO + VBE_RAMDISK_BASE_OFF], rdx
    mov [abs VBE_INFO + VBE_RAMDISK_SIZE_OFF], rax

    mov rbx, [v_file]
    mov rcx, rbx
    mov rax, [rbx + FP_CLOSE]
    call rax
    jmp .done

.close_and_fail:
    mov rbx, [v_file]
    mov rcx, rbx
    mov rax, [rbx + FP_CLOSE]
    call rax
.fail:
.done:
    add rsp, 48
    pop rbx
    ret

; ============================================================================
; RESOLVE_DATA_IMG_EXTENTS - Phase 1b (partial)
; ----------------------------------------------------------------------------
; While firmware services are still alive, open EFI_BLOCK_IO_PROTOCOL on the
; boot device handle (which is the ESP partition), read its BPB, and capture
; the FAT32 parameters needed to walk DATA.IMG's cluster chain.
;
; Status:
;   [x] HandleProtocol(devhandle, BlockIoGuid)
;   [x] Allocate sector scratch
;   [x] Read partition LBA 0 and parse FAT32 BPB into v_fat_* fields
;   [ ] Walk root directory cluster, find "DATA    IMG" entry          (TODO Phase 1b.2)
;   [ ] Walk FAT32 chain, coalesce runs into extents at               (TODO Phase 1b.3)
;       STORAGE_EXTENTS_ADDR, write VBE_STORAGE_EXT_* fields
;   [ ] Resolve partition-relative -> absolute disk LBA via            (TODO Phase 1b.4)
;       DevicePath HARDDRIVE node (needed when NVMe driver lands)
;
; Until Phase 1b.2-1b.3 land, VBE_STORAGE_EXT_CNT_OFF stays 0 so the kernel's
; ramdisk_flush keeps no-op behavior. The BPB capture below is non-destructive
; and idempotent - safe to call every boot.
;
; Non-fatal on every UEFI error: failure leaves the contract zeroed and the
; rest of boot is unaffected.
; ============================================================================
; EFI_BLOCK_IO_PROTOCOL layout
%define BIO_MEDIA      8
%define BIO_RESET      16
%define BIO_READ       24
%define BIO_WRITE      32
%define BIO_FLUSH      40

; EFI_BLOCK_IO_MEDIA layout (natural alignment, EFI 2.0)
%define BIOM_MEDIAID   0
%define BIOM_BLKSZ     32     ; UINT32 BlockSize after 5 BOOLEAN + pad
%define BIOM_LASTBLK   40     ; EFI_LBA LastBlock (u64, 8-aligned)
; Note: older EFI 1.x had BlockSize at +24; we don't support those.

; FAT32 BPB offsets (from start of partition sector 0)
%define BPB32_BYTSPSEC 11
%define BPB32_SECPCLUS 13
%define BPB32_RSVDSEC  14
%define BPB32_NUMFATS  16
%define BPB32_FATSZ32  36
%define BPB32_ROOTCLUS 44
%define BPB32_SIG      510    ; should be 0xAA55

; FAT32 directory entry offsets
%define DIRENT_ATTR       11
%define DIRENT_CLUS_HI    20
%define DIRENT_CLUS_LO    26
%define DIRENT_FILE_SIZE  28
%define ATTR_LONG_NAME    0x0F
%define ATTR_DIRECTORY    0x10
%define FAT32_EOC         0x0FFFFFF8

resolve_data_img_extents:
    push rbx
    push r12
    push r13
    sub rsp, 48
    ; [rsp+0..31] shadow
    ; [rsp+32]    arg5 slot

    SER 'X'                                  ; X = resolve_extents entered

    ; --- Zero contract fields up-front so any early return is "no backing" ---
    mov byte  [abs VBE_INFO + VBE_STORAGE_CLASS_OFF], 0
    mov byte  [abs VBE_INFO + VBE_STORAGE_LUN_OFF], 0
    mov word  [abs VBE_INFO + VBE_STORAGE_BLKSIZE_OFF], 0
    mov dword [abs VBE_INFO + VBE_STORAGE_EXT_CNT_OFF], 0
    mov qword [abs VBE_INFO + VBE_STORAGE_EXT_PTR_OFF], 0

    mov rax, [v_devhandle]
    test rax, rax
    jz .rdx_fail

    ; --- HandleProtocol(v_devhandle, &guid_blkio, &v_blkio) ---
    mov qword [v_blkio], 0
    mov rcx, [v_devhandle]
    lea rdx, [guid_blkio]
    lea r8,  [v_blkio]
    mov rax, [v_bs]
    mov rax, [rax + BS_HNDLPROT]
    call rax
    test rax, rax
    jnz .rdx_fail
    cmp qword [v_blkio], 0
    je .rdx_fail

    ; --- AllocatePages(AnyPages, EfiLoaderData, 1, &v_bpb_buf) ---
    mov qword [v_bpb_buf], 0
    mov rcx, [v_bs]
    mov rax, [rcx + BS_ALLOCPG]
    mov ecx, 0
    mov edx, 2
    mov r8, 1
    lea r9, [v_bpb_buf]
    call rax
    test rax, rax
    jnz .rdx_fail
    cmp qword [v_bpb_buf], 0
    je .rdx_fail

    ; --- Capture media params (BlockSize, MediaId) ---
    mov rbx, [v_blkio]
    mov r12, [rbx + BIO_MEDIA]
    test r12, r12
    jz .rdx_fail
    mov eax, [r12 + BIOM_BLKSZ]
    cmp eax, 512
    jne .rdx_fail              ; only 512 B blocks supported today
    mov [v_part_blksz], eax
    mov eax, [r12 + BIOM_MEDIAID]
    mov [v_part_mediaid], eax

    ; --- ReadBlocks(This, MediaId, LBA=0, BufSz=512, Buf=v_bpb_buf) ---
    mov rcx, rbx
    mov edx, [v_part_mediaid]
    xor r8, r8                 ; LBA = 0
    mov r9, 512                ; BufferSize
    mov rax, [v_bpb_buf]
    mov [rsp+32], rax
    mov rax, [rbx + BIO_READ]
    call rax
    test rax, rax
    jnz .rdx_fail

    ; --- Validate boot signature, then FAT32 BPB ---
    mov r13, [v_bpb_buf]
    cmp word [r13 + BPB32_SIG], 0xAA55
    jne .rdx_fail
    movzx eax, word [r13 + BPB32_BYTSPSEC]
    cmp eax, 512
    jne .rdx_fail
    movzx eax, byte [r13 + BPB32_SECPCLUS]
    test eax, eax
    jz .rdx_fail
    mov [v_fat_secperclus], eax
    movzx eax, word [r13 + BPB32_RSVDSEC]
    test eax, eax
    jz .rdx_fail
    mov [v_fat_rsvd], eax
    movzx eax, byte [r13 + BPB32_NUMFATS]
    cmp eax, 1
    jb .rdx_fail
    mov [v_fat_numfats], eax
    mov eax, [r13 + BPB32_FATSZ32]
    test eax, eax
    jz .rdx_fail              ; FAT16 ESP not supported here (UEFI spec requires FAT32 on ESPs > 512 MB)
    mov [v_fat_size32], eax
    mov eax, [r13 + BPB32_ROOTCLUS]
    cmp eax, 2
    jb .rdx_fail
    mov [v_fat_rootclus], eax

    ; FirstDataSector = RsvdSecCnt + NumFATs * FATSz32
    mov eax, [v_fat_rsvd]
    mov edx, [v_fat_numfats]
    imul edx, [v_fat_size32]
    add eax, edx
    mov [v_fat_first_data_sec], eax

    SER 'B'                                  ; B = BPB parsed OK

    ; Publish stable metadata before the walk. Class stays 0 until a kernel
    ; backing driver exists, but the extent table can already be captured.
    mov ax, [v_part_blksz]
    mov [abs VBE_INFO + VBE_STORAGE_BLKSIZE_OFF], ax
    mov qword [abs VBE_INFO + VBE_STORAGE_EXT_PTR_OFF], STORAGE_EXTENTS_ADDR

    ; --- Resolve \EFI\BOOT\DATA.IMG by walking FAT32 directory clusters ---
    mov eax, [v_fat_rootclus]
    lea rsi, [s_efi_83]
    call fat32_find_dirent
    jc .rdx_fail
    test bl, ATTR_DIRECTORY
    jz .rdx_fail

    lea rsi, [s_boot_83]
    call fat32_find_dirent
    jc .rdx_fail
    test bl, ATTR_DIRECTORY
    jz .rdx_fail

    lea rsi, [s_data_83]
    call fat32_find_dirent
    jc .rdx_fail
    test bl, ATTR_DIRECTORY
    jnz .rdx_fail
    cmp eax, 2
    jb .rdx_fail
    test edx, edx
    jz .rdx_fail
    mov [v_data_first_clus], eax
    mov [v_data_file_size], edx

    SER 'D'                                  ; D = DATA.IMG directory entry found

    ; --- Walk the DATA.IMG FAT32 chain and coalesce contiguous clusters ---
    call fat32_emit_data_extents
    jc .rdx_fail
    mov [abs VBE_INFO + VBE_STORAGE_EXT_CNT_OFF], eax

    SER 'e'                                  ; e = extents emitted

.rdx_fail:
    add rsp, 48
    pop r13
    pop r12
    pop rbx
    ret

; read_part_sector
;   r8  = partition-relative LBA
;   r10 = 512-byte destination buffer
;   returns EFI_STATUS in rax
;   clobbers volatile registers
read_part_sector:
    sub rsp, 40
    mov r11, [v_blkio]
    mov rcx, r11
    mov edx, [v_part_mediaid]
    mov r9, 512
    mov [rsp+32], r10
    mov rax, [r11 + BIO_READ]
    call rax
    add rsp, 40
    ret

; fat32_cluster_lba
;   eax = cluster number
;   returns rax = partition-relative LBA of the cluster's first sector
;   clobbers rdx
fat32_cluster_lba:
    sub eax, 2
    mul dword [v_fat_secperclus]
    add eax, [v_fat_first_data_sec]
    ret

; fat32_get_next_cluster
;   eax = current cluster
;   returns CF clear + eax = next cluster (masked to 28 bits), or CF set
;   clobbers volatile registers
fat32_get_next_cluster:
    sub rsp, 40
    shl eax, 2
    mov edx, eax
    shr eax, 9
    add eax, [v_fat_rsvd]
    mov r8d, eax
    mov r10, [v_bpb_buf]
    mov [rsp+32], edx
    call read_part_sector
    test rax, rax
    jnz .gnc_fail
    mov edx, [rsp+32]
    and edx, 511
    mov r10, [v_bpb_buf]
    mov eax, [r10 + rdx]
    and eax, 0x0FFFFFFF
    clc
    add rsp, 40
    ret
.gnc_fail:
    stc
    add rsp, 40
    ret

; fat32_find_dirent
;   eax = starting directory cluster
;   rsi = pointer to 11-byte 8.3 uppercase name
;   returns CF clear + eax = first cluster, edx = file size, bl = attr
;   returns CF set if not found or on read/FAT error
fat32_find_dirent:
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    cld
    mov r12d, eax
    mov r13, rsi
.fde_cluster:
    cmp r12d, 2
    jb .fde_fail
    xor r14d, r14d
.fde_sector:
    mov eax, r12d
    call fat32_cluster_lba
    add eax, r14d
    mov r8d, eax
    mov r10, [v_bpb_buf]
    call read_part_sector
    test rax, rax
    jnz .fde_fail

    mov r15, [v_bpb_buf]
    mov ecx, 16
.fde_entry:
    mov al, [r15]
    test al, al
    jz .fde_fail                 ; 0x00 marks end of this directory
    cmp al, 0xE5
    je .fde_next_entry
    mov bl, [r15 + DIRENT_ATTR]
    mov al, bl
    and al, ATTR_LONG_NAME
    cmp al, ATTR_LONG_NAME
    je .fde_next_entry

    push rcx
    mov rsi, r13
    mov rdi, r15
    mov ecx, 11
    repe cmpsb
    pop rcx
    jne .fde_next_entry

    movzx eax, word [r15 + DIRENT_CLUS_HI]
    shl eax, 16
    movzx edx, word [r15 + DIRENT_CLUS_LO]
    or eax, edx
    mov edx, [r15 + DIRENT_FILE_SIZE]
    clc
    jmp .fde_done
.fde_next_entry:
    add r15, 32
    dec ecx
    jnz .fde_entry

    inc r14d
    cmp r14d, [v_fat_secperclus]
    jb .fde_sector

    mov eax, r12d
    call fat32_get_next_cluster
    jc .fde_fail
    cmp eax, FAT32_EOC
    jae .fde_fail
    mov r12d, eax
    jmp .fde_cluster
.fde_fail:
    stc
.fde_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

; fat32_emit_data_extents
;   eax = DATA.IMG first cluster
;   edx = DATA.IMG file size in bytes
;   returns CF clear + eax = extent count, or CF set
fat32_emit_data_extents:
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    mov r12d, eax
    mov eax, edx
    add eax, 511
    shr eax, 9
    mov r13d, eax                   ; remaining file sectors
    xor r15d, r15d                  ; extent count
    test r13d, r13d
    jz .ede_fail
.ede_cluster:
    mov eax, r12d
    call fat32_cluster_lba
    mov rbx, rax                    ; current extent start LBA
    mov ecx, [v_fat_secperclus]
    cmp ecx, r13d
    jbe .ede_chunk_ok
    mov ecx, r13d
.ede_chunk_ok:
    test r15d, r15d
    jz .ede_new_extent

    mov edi, r15d
    dec edi
    shl edi, 4
    lea r14, [abs STORAGE_EXTENTS_ADDR + rdi]
    mov rax, [r14]
    mov edx, [r14 + 8]
    add rax, rdx
    cmp rax, rbx
    jne .ede_new_extent
    add [r14 + 8], ecx
    jmp .ede_appended
.ede_new_extent:
    cmp r15d, STORAGE_EXTENTS_MAX
    jae .ede_fail
    mov edi, r15d
    shl edi, 4
    lea r14, [abs STORAGE_EXTENTS_ADDR + rdi]
    mov [r14], rbx
    mov [r14 + 8], ecx
    mov dword [r14 + 12], 0
    inc r15d
.ede_appended:
    sub r13d, ecx
    jz .ede_done

    mov eax, r12d
    call fat32_get_next_cluster
    jc .ede_fail
    cmp eax, FAT32_EOC
    jae .ede_fail
    cmp eax, 2
    jb .ede_fail
    mov r12d, eax
    jmp .ede_cluster
.ede_done:
    mov eax, r15d
    clc
    jmp .ede_ret
.ede_fail:
    stc
.ede_ret:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

; ============================================================================
; FLUSH_KLOG_IF_PENDING
; ----------------------------------------------------------------------------
; Checks the kernel-log flush region at 0x600000 for a magic header left
; behind by the previous boot's kernel (via F11). If present, writes the
; payload to \KLOG.TXT on the ESP and clears the magic so we do not write
; the same buffer again next boot.
;
; Layout at 0x600000:
;   +0  qword magic = 0x3130534E474F4C4B  ("KLOGNS01")
;   +8  qword payload length (bytes)
;   +16 payload (ASCII text)
;
; Non-fatal: any UEFI error simply skips the write and continues boot.
; ============================================================================
%define KLOG_FLUSH_ADDR_LO 0x600000
%define KLOG_MAGIC_QWORD   0x3130534E474F4C4B

flush_klog_if_pending:
    push rbx
    push r12
    push r13
    sub rsp, 64
    ; [rsp +  0..31] shadow
    ; [rsp + 32]     arg5
    ; [rsp + 40]     local: bytecount in/out
    ; [rsp + 48]     scratch

    SER 'k'                                  ; k = flush_klog entered

    ; --- Check magic ---
    mov rax, KLOG_MAGIC_QWORD
    cmp [abs KLOG_FLUSH_ADDR_LO], rax
    jne .fk_no_magic
    SER 'M'                                  ; M = magic found
    jmp .fk_have_magic
.fk_no_magic:
    SER 'm'                                  ; m = no magic
    jmp .fk_done
.fk_have_magic:

    mov r12, [abs KLOG_FLUSH_ADDR_LO + 8]   ; payload length
    test r12, r12
    jz .fk_clear                            ; empty payload, just clear magic
    cmp r12, 0x100000                       ; sanity cap 1 MB
    ja .fk_clear

    ; --- Reopen root volume ---
    mov rbx, [v_sfs]
    test rbx, rbx
    jz .fk_clear
    mov rcx, rbx
    lea rdx, [v_root]
    mov rax, [rbx + SFS_OPENVOL]
    call rax
    test rax, rax
    jz .fk_root_ok
    SER 'R'                                  ; R = OpenVolume failed
    jmp .fk_clear
.fk_root_ok:

    ; --- Open \KLOG.TXT with CREATE|READ|WRITE ---
    mov rbx, [v_root]
    mov rcx, rbx
    lea rdx, [v_file]
    lea r8,  [s_klog_path]
    ; OpenMode = CREATE(0x8000000000000000) | READ(1) | WRITE(2) = 0x8000000000000003
    mov r9, 0x8000000000000003
    mov qword [rsp+32], 0                   ; Attributes = 0
    mov rax, [rbx + FP_OPEN]
    call rax
    test rax, rax
    jz .fk_open_ok
    SER 'O'                                  ; O = Open(KLOG.TXT) failed
    jmp .fk_close_root
.fk_open_ok:
    SER 'o'                                  ; o = Open succeeded

    ; --- Write payload ---
    mov [rsp+40], r12                        ; bytecount in
    mov rbx, [v_file]
    mov rcx, rbx
    lea rdx, [rsp+40]
    mov r8, KLOG_FLUSH_ADDR_LO + 16          ; payload ptr
    mov rax, [rbx + FP_WRITE]
    call rax
    test rax, rax
    jz .fk_write_ok
    SER 'X'                                  ; X = Write failed
    jmp .fk_close_file
.fk_write_ok:
    SER 'w'                                  ; w = Write succeeded
.fk_close_file:

    ; --- Close file ---
    mov rbx, [v_file]
    mov rcx, rbx
    mov rax, [rbx + FP_CLOSE]
    call rax

.fk_close_root:
    mov rbx, [v_root]
    test rbx, rbx
    jz .fk_clear
    mov rcx, rbx
    mov rax, [rbx + FP_CLOSE]
    call rax

.fk_clear:
    ; Wipe the magic so we don't re-write next boot.
    xor eax, eax
    mov [abs KLOG_FLUSH_ADDR_LO], rax
    mov [abs KLOG_FLUSH_ADDR_LO + 8], rax

.fk_done:
    add rsp, 64
    pop r13
    pop r12
    pop rbx
    ret

; ============================================================================
; SETUP_PAGING  - identity-map 512 GB.
; The first 1 GB uses 2 MB pages so the app arena can be user-accessible
; while the rest stays supervisor-only; everything above 1 GB stays mapped
; with supervisor-only 1 GB pages.
; ============================================================================
setup_paging:
    push r14
    push r15
    %define UEFI_PAGE_PRESENT      0x01
    %define UEFI_PAGE_WRITABLE     0x02
    %define UEFI_PAGE_USER         0x04
    %define UEFI_PAGE_LARGE        0x80
    ; W^X: kernel text lives in [KTEXT_START, KTEXT_END). All other pages NX.
    %define UEFI_KTEXT_START_PAGE  0x100     ; PTE index of 0x100000
    %define UEFI_KTEXT_END_PAGE    0x200     ; executable kernel text through 2 MiB
    %define UEFI_PT0_BASE          0x74000   ; 4KB page table for PD0[0]
    %define UEFI_APP_PT_BASE       0x75000   ; 8 PTs (0x75000..0x7CFFF) for app arena
    push rbx
    push r12
    push r13

    ; Clear 19 pages (0x70000..0x82FFF):
    ;   PML4 + PDPT0 + PDPT1 + PD0 + PT0     = 5 pages
    ;   12 app-arena PTs at UEFI_APP_PT_BASE = 12 pages
    ;   gap page at 0x81000 (BIOS PD3 slot)  = 1 page
    ;   syscall-stack PT at 0x82000          = 1 page (kernel-installed)
    ; The 12 arena PTs give the app arena 4KB granularity for per-slot USER
    ; toggling and W^X; the syscall-stack PT is wired up later by the kernel.
    mov rdi, PT_BASE
    xor eax, eax
    mov ecx, 19 * 4096 / 4
    rep stosd

    ; PML4[0] -> PDPT0 at 0x71000 (covers 0-512 GB).
    ; Mark this branch user-accessible because PDPT0[0] contains the app arena.
    mov qword [abs PT_BASE], 0x71000 | 7
    ; PML4[1] -> PDPT1 at 0x72000 (covers 512-1024 GB), supervisor-only.
    mov qword [abs PT_BASE + 8], 0x72000 | 3

    ; PDPT0[0] -> PD0 at 0x73000 for the first 1 GB, with User set.
    mov qword [abs PT_BASE + 0x1000], 0x73000 | 7

    ; PDPT0[1..511]: 1 GB identity pages starting at 1 GB, supervisor-only, NX.
    mov rdi, PT_BASE + 0x1000 + 8
    mov rbx, 0x40000000             ; physical base = 1 GB
    mov r12d, 511
.loop_pdpt0:
    mov rax, rbx
    or  rax, 0x83                   ; Present | Writable | Page Size (1 GB)
    bts rax, 63                     ; NX (data only, no code execution)
    mov [rdi], rax
    add rdi, 8
    add rbx, 0x40000000             ; +1 GB
    dec r12d
    jnz .loop_pdpt0

    ; PD0[0]: point to fine-grained PT0 (4KB pages over 0..2MB) for W^X split.
    mov qword [abs PT_BASE + 0x3000], UEFI_PT0_BASE | (UEFI_PAGE_PRESENT | UEFI_PAGE_WRITABLE | UEFI_PAGE_USER)

    ; PT0[0..511]: 4KB identity pages over 0..2MB.
    ;   pages [KTEXT_START..KTEXT_END)  : executable (kernel code)
    ;   all other pages                  : NX + writable (data/stack/etc)
    ; All supervisor-only: ring 3 never accesses anything below 2MB. Marking
    ; these USER would expose the page tables (PT_BASE), GDT, IDT pointer and
    ; kernel text to ring-3 reads/writes.
    mov rdi, UEFI_PT0_BASE
    xor ebx, ebx                    ; ebx = PTE index
    xor eax, eax                    ; eax = physical base
.loop_pt0:
    mov rdx, rax
    or  edx, UEFI_PAGE_PRESENT | UEFI_PAGE_WRITABLE
    ; Trampoline at 0x8000 must stay executable: its final two instructions
    ; (mov rax,KERN_DEST / jmp rax) execute AFTER cr3 is reloaded with PT_BASE.
    cmp ebx, 8
    je .pt0_write
    cmp ebx, UEFI_KTEXT_START_PAGE
    jb .pt0_nx
    cmp ebx, UEFI_KTEXT_END_PAGE
    jae .pt0_nx
    jmp .pt0_write                  ; kernel text: executable
.pt0_nx:
    bts rdx, 63                     ; NX
    jmp .pt0_write
.pt0_write:
    mov [rdi], rdx
    add eax, 0x1000
    add rdi, 8
    inc ebx
    cmp ebx, 512
    jb .loop_pt0

    ; PD0[1..511]: 2 MB identity pages over 2MB..1GB, supervisor-only by default.
    ; App arena PDEs get USER bit (code runs here, no NX).
    ; All other PDEs are kernel data/heap/framebuffer: NX.
    mov rdi, PT_BASE + 0x3000 + 8
    mov rax, 0x200000
    or  rax, UEFI_PAGE_PRESENT | UEFI_PAGE_WRITABLE | UEFI_PAGE_LARGE
    mov ebx, 1
    mov r14, [abs VBE_INFO + VBE_APP_ARENA_BASE_OFF]
    shr r14, 21
    mov r15, [abs VBE_INFO + VBE_APP_ARENA_SIZE_OFF]
    add r15, 0x1FFFFF
    shr r15, 21
    add r15, r14
.loop_pd0:
    mov rdx, rax
    cmp rbx, r14
    jb .pd0_nx
    cmp rbx, r15
    jae .pd0_nx
    ; App arena: PDE points at a 4KB page table (not a 2MB large page) so the
    ; kernel can toggle the USER bit per slot and enforce W^X per page.
    ; PT for this PDE is at UEFI_APP_PT_BASE + (pde_index - r14) * 4KB.
    mov rdx, rbx
    sub rdx, r14
    shl rdx, 12
    add rdx, UEFI_APP_PT_BASE
    or  rdx, UEFI_PAGE_PRESENT | UEFI_PAGE_WRITABLE | UEFI_PAGE_USER
    jmp .pd0_write
.pd0_nx:
    ; Keep the loaded kernel image executable after the first 2 MiB. The
    ; trampoline jumps into KERNEL_LOAD_ADDR and the monolithic kernel's text
    ; spans multiple MiB once generated NexusHL apps are included.
    cmp ebx, 1
    jb .pd0_set_nx
    cmp ebx, 8
    jb .pd0_write
.pd0_set_nx:
    bts rdx, 63                     ; kernel data region: NX
.pd0_write:
    mov [rdi], rdx
    add rax, 0x200000
    add rdi, 8
    inc ebx
    cmp ebx, 512
    jb .loop_pd0

    ; Fill the app-arena 4KB page tables. The arena spans (r15-r14) PDEs,
    ; each PDE backed by 512 4KB PTEs. Physical base = r14 << 21.
    ; Every PTE starts Present|Writable|USER and executable; the kernel
    ; tightens USER (slot isolation) and NX (W^X) at runtime per slot.
    mov rdi, UEFI_APP_PT_BASE
    mov rax, r14
    shl rax, 21                     ; arena physical base
    or  rax, UEFI_PAGE_PRESENT | UEFI_PAGE_WRITABLE | UEFI_PAGE_USER
    mov rcx, r15
    sub rcx, r14                    ; arena PDE count
    shl rcx, 9                      ; * 512 PTEs per PDE
.loop_app_pt:
    mov [rdi], rax
    add rax, 0x1000
    add rdi, 8
    dec rcx
    jnz .loop_app_pt

    ; Per-slot stack guard pages: clear PAGE_PRESENT one 4KB page below
    ; each slot's user stack. Slot count = (r15 - r14) arena PDEs (one PDE
    ; per 2 MiB slot). See boot_memory.inc:L3_SLOT_USER_STACK_GUARD_OFF.
    mov rdi, UEFI_APP_PT_BASE + L3_SLOT_USER_STACK_GUARD_PTE * 8
    mov rcx, r15
    sub rcx, r14
.loop_guard_pt:
    mov rax, [rdi]
    and rax, ~UEFI_PAGE_PRESENT
    mov [rdi], rax
    add rdi, 0x1000          ; same PTE slot in the next slot's PT
    dec rcx
    jnz .loop_guard_pt

    ; PDPT1[0..511]: 1 GB identity pages starting at 512 GB, supervisor-only, NX.
    mov rdi, PT_BASE + 0x2000
    mov rbx, 0x8000000000           ; physical base = 512 GB
    mov r12d, 512
.loop2:
    mov rax, rbx
    or  rax, 0x83                   ; Present | Writable | Page Size (1 GB)
    bts rax, 63                     ; NX
    mov [rdi], rax
    add rdi, 8
    add rbx, 0x40000000             ; +1 GB
    dec r12d
    jnz .loop2

    pop r13
    pop r12
    pop rbx
    pop r15
    pop r14
    ret

; ============================================================================
; EXIT_BOOT_SERVICES  - get memory map and call ExitBootServices (3 retries)
; ============================================================================
; LOCATE_SPP  - Find EFI_SIMPLE_POINTER_PROTOCOL and store pointer in VBE block
; Failure is non-fatal: just leaves VBE_INFO+SPP_OFF as 0.
; ============================================================================
locate_spp:
    push rbx
    push r12
    ; 2 pushes = 16. Entry 16n-8. After pushes: 16n-24. sub 40 -> 16n-64 = 0 mod 16.
    sub rsp, 40

    ; LocateProtocol(GUID, NULL, &Interface)
    ; RCX=BS, RAX=LocateProtocol, then: RCX=&GUID, RDX=0, R8=&v_spp
    mov rbx, [v_bs]
    mov rax, [rbx + BS_LOCATE]       ; LocateProtocol
    lea rcx, [guid_spp]
    xor edx, edx                     ; Registration = NULL
    lea r8,  [v_spp]
    call rax
    test rax, rax
    jnz .no_spp

    mov r12, [v_spp]
    test r12, r12
    jz .no_spp

    ; Call Reset(interface, ExtendedVerification=0)
    mov rax, [r12 + 0]               ; Reset is first vtable entry
    mov rcx, r12
    xor edx, edx
    call rax

    mov qword [abs VBE_INFO + VBE_SPP_OFF], r12
    jmp .done

.no_spp:
    mov qword [abs VBE_INFO + VBE_SPP_OFF], 0

.done:
    add rsp, 40
    pop r12
    pop rbx
    ret

; ============================================================================
; Returns: RAX = 0 success, 1 fail
; ============================================================================
exit_boot_services:
    push rbx
    push r12
    ; 2 pushes = 16 bytes. Entry 16n-8. After pushes: 16n-24.
    ; sub 104 -> 16n-128 = 0 mod 16. Aligned.
    sub rsp, 104
    ; [rsp +  0..31] shadow
    ; [rsp + 32]     arg5
    ; [rsp + 40]     scratch
    ; [rsp + 48]     local: mmap_size
    ; [rsp + 56]     local: map_key
    ; [rsp + 64]     local: desc_size
    ; [rsp + 72]     local: desc_version
    ; [rsp + 80]     local: mmap_buffer ptr

    ; Allocate memory map buffer (16 KB)
    mov rcx, [v_bs]
    mov rax, [rcx + BS_ALLOCPL]
    mov ecx, 2                      ; EfiLoaderData
    mov rdx, 16384
    lea r8, [rsp+80]
    call rax
    test rax, rax
    jnz .fail

    mov r12d, 3                     ; retry counter

.retry:
    mov qword [rsp+48], 16384
    mov rcx, [v_bs]
    mov rax, [rcx + BS_GETMMAP]
    lea rcx, [rsp+48]               ; &mmap_size
    mov rdx, [rsp+80]               ; buffer
    lea r8,  [rsp+56]               ; &map_key
    lea r9,  [rsp+64]               ; &desc_size
    lea rbx, [rsp+72]
    mov [rsp+32], rbx               ; &desc_version (arg5)
    call rax
    test rax, rax
    jnz .fail

    call publish_e820_map

    ; *** No UEFI calls between GetMemoryMap and ExitBootServices ***
    SER 'X'                         ; X = GetMemoryMap OK, about to exit

    mov rcx, [v_bs]
    mov rax, [rcx + BS_EXITBOOT]
    mov rcx, [v_handle]
    mov rdx, [rsp+56]               ; map_key
    call rax
    test rax, rax
    jz .ok

    dec r12d
    jnz .retry
    jmp .fail

.ok:
    xor eax, eax
    jmp .done

.fail:
    mov eax, 1

.done:
    add rsp, 104
    pop r12
    pop rbx
    ret

; ============================================================================
; PUBLISH_E820_MAP - convert the UEFI memory map into the kernel's legacy
; E820 handoff block at E820_COUNT_ADDR/E820_MAP_ADDR.
;
; Input locals from exit_boot_services:
;   [rsp+48] mmap_size, [rsp+64] desc_size, [rsp+80] mmap_buffer
; ============================================================================
publish_e820_map:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    push r9
    push r10
    push r11

    mov rsi, [rsp + 48 + 80]        ; caller rsp+48 after return addr + 9 pushes
    mov rbx, [rsp + 64 + 80]        ; descriptor size
    mov r10, [rsp + 80 + 80]        ; descriptor buffer
    xor r11d, r11d                  ; output entry count

    test rsi, rsi
    jz .done
    test rbx, rbx
    jz .done

    mov rdi, E820_MAP_ADDR
.loop:
    cmp rsi, rbx
    jb .done

    mov eax, [r10 + 0]              ; EFI_MEMORY_DESCRIPTOR.Type
    cmp eax, 7                      ; EfiConventionalMemory
    jne .next

    cmp r11d, 255                   ; 255 * 24 fits below the 0x8000 trampoline
    jae .done

    mov rax, [r10 + 8]              ; PhysicalStart
    mov [rdi + 0], rax
    mov rax, [r10 + 24]             ; NumberOfPages
    shl rax, 12
    mov [rdi + 8], rax
    mov dword [rdi + 16], 1         ; E820 usable RAM
    mov dword [rdi + 20], 0         ; ACPI extended attributes

    add rdi, 24
    inc r11d

.next:
    add r10, rbx
    sub rsi, rbx
    jmp .loop

.done:
    mov [abs E820_COUNT_ADDR], r11w

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

; ============================================================================
; GDT  (copied to 0x500 before any kernel activity)
; CS = 0x08 (64-bit code), DS/ES/SS = 0x10 (data)
; ============================================================================
align 16
gdt64:
    dq 0                            ; Null

gdt64_code:
    dw 0x0000, 0x0000               ; Limit, Base[15:0]
    db 0x00                         ; Base[23:16]
    db 10011010b                    ; P=1 DPL=0 S=1 Type=1010 (Code R/X)
    db 00100000b                    ; L=1 (64-bit), D=0
    db 0x00                         ; Base[31:24]

gdt64_data:
    dw 0x0000, 0x0000
    db 0x00
    db 10010010b                    ; P=1 DPL=0 S=1 Type=0010 (Data R/W)
    db 00000000b
    db 0x00

gdt64_user_code32:                  ; Selector 0x18 - user 32-bit code placeholder (sysret layout)
    dq 0x00CFFA000000FFFF

gdt64_user_data:                    ; Selector 0x20 - user data DPL=3
    dw 0x0000, 0x0000
    db 0x00
    db 11110010b
    db 00000000b
    db 0x00

gdt64_user_code64:                  ; Selector 0x28 - user 64-bit code DPL=3
    dw 0x0000, 0x0000
    db 0x00
    db 11111010b
    db 00100000b
    db 0x00

gdt64_tss_uefi:                     ; Selector 0x30 - TSS descriptor (16 bytes)
    dw 103                          ; Limit (104 bytes - 1)
    dw 0                            ; Base[15:0]  (filled by tss_init)
    db 0                            ; Base[23:16]
    db 10001001b                    ; Present, TSS Available
    db 0                            ; Flags + Limit High
    db 0                            ; Base[31:24]
    dq 0                            ; Base[63:32] + reserved

gdt64_end:

; ============================================================================
; Protocol GUIDs
; ============================================================================
align 4
guid_gop:
    dd 0x9042a9de
    dw 0x23dc, 0x4a38
    db 0x96, 0xfb, 0x7a, 0xde, 0xd0, 0x80, 0x51, 0x6a

guid_sfs:
    dd 0x964e5b22
    dw 0x6459, 0x11d2
    db 0x8e, 0x39, 0x00, 0xa0, 0xc9, 0x69, 0x72, 0x3b

; EFI_BLOCK_IO_PROTOCOL (964e5b21-6459-11d2-8e39-00a0c9697239)
guid_blkio:
    dd 0x964e5b21
    dw 0x6459, 0x11d2
    db 0x8e, 0x39, 0x00, 0xa0, 0xc9, 0x69, 0x72, 0x39

guid_lip:
    dd 0x5b1b31a1
    dw 0x9562, 0x11d2
    db 0x8e, 0x3f, 0x00, 0xa0, 0xc9, 0x69, 0x72, 0x3b

; EFI_SIMPLE_POINTER_PROTOCOL
guid_spp:
    dd 0x31878c87
    dw 0x0b75, 0x11d5
    db 0x9a, 0x4f, 0x00, 0x90, 0x27, 0x3f, 0xc1, 0x4d

; ============================================================================
; UCS-2 file paths
; ============================================================================
align 2
s_kern_path:    ustr "\EFI\BOOT\KERNEL.BIN"
s_apps_path:    ustr "\EFI\BOOT\APPS.BIN"
s_data_path:    ustr "\EFI\BOOT\DATA.IMG"
s_klog_path:    ustr "\KLOG.TXT"

; FAT32 8.3 path components for \EFI\BOOT\DATA.IMG extent resolution.
s_efi_83:       db 'EFI     ', '   '
s_boot_83:      db 'BOOT    ', '   '
s_data_83:      db 'DATA    ', 'IMG'

; ============================================================================
; Variables
; ============================================================================
align 8
v_handle:      dq 0
v_systab:      dq 0
v_bs:          dq 0
v_gop:         dq 0
v_spp:         dq 0
v_fb:          dq 0
v_scrw:        dd 0
v_scrh:        dd 0
v_pitch:       dd 0
v_lip:         dq 0
v_devhandle:   dq 0
v_sfs:         dq 0
v_root:        dq 0
v_file:        dq 0
v_kernel_addr: dq 0
v_ksize:       dq 0
v_apps_size:   dq 0
v_data_size:   dq 0
v_tmp_addr:    dq 0

; --- KASLR container parse results (filled post-ExitBootServices) -----------
v_payload_src:  dq 0
v_payload_size: dq 0
v_fixup_src:    dq 0
v_fixup_count:  dq 0
v_entry_off:    dq 0
v_kslide:       dq 0

; --- Phase 1b: storage extent resolution scratch -------------------------
; Populated by resolve_data_img_extents. Once Phase 2/3 land (NVMe / USB-MSC)
; the kernel's ramdisk_flush will consult these via VBE_INFO + the extent
; table at STORAGE_EXTENTS_ADDR to write dirty ramdisk pages back to the ESP.
v_blkio:        dq 0
v_bpb_buf:      dq 0    ; 4 KiB scratch page, sector 0 of partition
v_part_blksz:   dd 0
v_part_mediaid: dd 0
v_fat_secperclus:    dd 0
v_fat_rsvd:          dd 0
v_fat_numfats:       dd 0
v_fat_size32:        dd 0
v_fat_rootclus:      dd 0
v_fat_first_data_sec: dd 0
v_data_first_clus:   dd 0
v_data_file_size:    dd 0

; Pad text section to full raw size
times (HDR_SZ + TEXT_RAW - ($ - $$)) db 0

; ============================================================================
; .reloc section (minimal - one page entry, zero fixups)
; ============================================================================
    dd 0x1000, 12
    dw 0, 0

times (HDR_SZ + TEXT_RAW + RELOC_FSZ - ($ - $$)) db 0
