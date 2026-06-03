; ============================================================================
; PE/COFF HEADER
; ============================================================================
; PE/COFF magics, section flags, and alignments are named + spec-cited in
; src/include/uefi_abi.inc (PECOFF §2-§4). Image geometry (TEXT_*, RELOC_*,
; HDR_SZ, IMAGE_SZ) is loader-specific and named in uefi_loader_defs.inc.
section .text start=0
    dw PE_DOS_MAGIC                 ; "MZ" DOS stub
    times 29 dw 0
    dd pe_hdr

pe_hdr:
    dd PE_NT_SIGNATURE              ; "PE\0\0"
    dw PE_MACHINE_X64               ; x86-64
    dw 2                            ; 2 sections
    dd 0, 0, 0
    dw opt_end - opt_hdr
    dw PE_CHARACTERISTICS

opt_hdr:
    dw PE_OPT_MAGIC_PE32PLUS        ; PE32+
    db 1, 0
    dd TEXT_RAW, 0, 0, TEXT_VA, TEXT_VA
    dq KERN_DEST                    ; Image base (preferred)
    dd PE_SECT_ALIGN, PE_FILE_ALIGN ; Section / file alignment
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
    dd PE_SCN_TEXT_RWX              ; Code | Execute | Read | Write

    db '.reloc',0,0
    dd RELOC_VSZ, RELOC_VA, RELOC_FSZ, RELOC_FOFF
    dd 0, 0
    dw 0, 0
    dd PE_SCN_RELOC_RD              ; Initialized data | Discardable | Read

    times (HDR_SZ - ($ - $$)) db 0
