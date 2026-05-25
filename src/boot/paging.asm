; ============================================================================
; NexusOS v3.0 - Page Table Setup
; Identity-maps first 4GB using 2MB pages for long mode
; PML4 at 0x70000, PDPT at 0x71000, PD tables at 0x72000-0x75FFF
; ============================================================================
bits 16   ; We are in 16-bit Unreal Mode

%include "src/include/boot_memory.inc"

PAGE_PRESENT    equ 0x01
PAGE_WRITABLE   equ 0x02
PAGE_USER       equ 0x04     ; User-accessible (ring 3)
PAGE_LARGE      equ 0x80     ; 2MB page (PS bit in PD entry)
APP_USER_PDE0   equ (APP_DATA_ADDR / 0x200000)
APP_USER_PDE_COUNT equ ((APP_SLOT_COUNT * APP_SLOT_SIZE + 0x1FFFFF) / 0x200000)

setup_paging:
    ; Clear page table area (24KB: 0x70000 - 0x75FFF)
    ; In 16-bit mode, STOSD uses DI (16-bit). We must enable 32-bit addressing override!
    ; With a32 prefix, it uses EDI which is valid in Unreal Mode.
    
    mov edi, 0x70000
    xor eax, eax
    mov ecx, (6 * 4096) / 4    ; 6 pages (PML4, PDPT, 4*PD), 4 bytes at a time
    
    ; Address-size override prefix (0x67) for 32-bit addressing in 16-bit mode
    ; This makes REP STOSD use ECX and EDI instead of CX and DI.
    a32 rep stosd

    ; Now setup pointers using 32-bit addressing override for MOV
    
    ; PML4[0] -> PDPT at 0x71000
    ; Using a32 prefix for implicit DS:EDI addressing
    mov edi, 0x70000
    mov eax, 0x71000 | PAGE_PRESENT | PAGE_WRITABLE | PAGE_USER
    a32 mov [edi], eax
    
    ; PDPT[0] -> PD at 0x72000 (covers 0-1GB)
    mov edi, 0x71000
    mov eax, 0x72000 | PAGE_PRESENT | PAGE_WRITABLE | PAGE_USER
    a32 mov [edi], eax

    ; PDPT[1] -> PD at 0x73000 (covers 1-2GB)
    mov edi, 0x71008
    mov eax, 0x73000 | PAGE_PRESENT | PAGE_WRITABLE | PAGE_USER
    a32 mov [edi], eax

    ; PDPT[2] -> PD at 0x74000 (covers 2-3GB)
    mov edi, 0x71010
    mov eax, 0x74000 | PAGE_PRESENT | PAGE_WRITABLE | PAGE_USER
    a32 mov [edi], eax

    ; PDPT[3] -> PD at 0x75000 (covers 3-4GB)
    mov edi, 0x71018
    mov eax, 0x75000 | PAGE_PRESENT | PAGE_WRITABLE | PAGE_USER
    a32 mov [edi], eax

    ; Fill PD tables with 2MB pages
    ; Each PD has 512 entries, each mapping 2MB = total 1GB per PD
    ; 4 PDs = 4GB total coverage
    
    mov edi, 0x72000            ; Start of PD tables
    mov eax, PAGE_PRESENT | PAGE_WRITABLE | PAGE_LARGE  ; Supervisor-only by default
    mov ecx, 512 * 4            ; 2048 entries total (4 PDs x 512)
    xor ebx, ebx                ; PDE index across the whole 4GB map

.fill_pd:
    push eax
    cmp ebx, APP_USER_PDE0
    jb .write_entry
    mov edx, APP_USER_PDE0 + APP_USER_PDE_COUNT
    cmp ebx, edx
    jae .write_entry
    or eax, PAGE_USER
.write_entry:
    ; Write entry (low 32 bits)
    a32 mov [edi], eax
    pop eax
    
    ; Write entry (high 32 bits) -> 0
    ; (No need to write high dword explicitly as we zeroed the whole block earlier!)
    ; But we need to skip 8 bytes total per entry
    
    add eax, 0x200000           ; Next 2MB page physical address
    add edi, 8                  ; Next PD entry (8 bytes each)
    inc ebx
    dec ecx
    jnz .fill_pd

    ret
