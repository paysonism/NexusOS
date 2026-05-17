; ============================================================================
; NexusOS v3.0 - FAT16 Filesystem Driver
; Reads/writes files from a FAT16 partition starting at a fixed sector offset
; ============================================================================
bits 64

%include "constants.inc"

section .text

; auto-wrapped (FN_BEGIN emits global): global fat16_init
global fat16_list_dir
; auto-wrapped (FN_BEGIN emits global): global fat16_read_file
; auto-wrapped (FN_BEGIN emits global): global fat16_write_file
; auto-wrapped (FN_BEGIN emits global): global fat16_delete_entry
; auto-wrapped (FN_BEGIN emits global): global fat16_rename_entry
; auto-wrapped (FN_BEGIN emits global): global fat16_mkdir
; auto-wrapped (FN_BEGIN emits global): global fat16_get_file_size
; auto-wrapped (FN_BEGIN emits global): global fat16_file_count
; auto-wrapped (FN_BEGIN emits global): global fat16_get_entry

extern ata_read_sectors
extern ata_write_sectors
extern ata_drive_sel

; The FAT16 partition starts after the fixed BIOS kernel reservation.
; Keep this in constants.inc so the BIOS image builder and filesystem agree.
FAT16_FAT_CACHE_SECTORS equ 128
FAT16_ROOT_CACHE_SECTORS equ 32
FAT16_MAX_FAT_ENTRIES equ (FAT16_FAT_CACHE_SECTORS * 256)

; FAT16 BPB offsets (from start of boot sector)
BPB_BYTES_PER_SECT  equ 11        ; word
BPB_SECT_PER_CLUS   equ 13        ; byte
BPB_RESERVED_SECTS  equ 14        ; word
BPB_NUM_FATS        equ 16        ; byte
BPB_ROOT_ENTRIES    equ 17        ; word
BPB_TOTAL_SECTS16   equ 19        ; word
BPB_FAT_SIZE16      equ 22        ; word

; FAT16 directory entry offsets
DIR_NAME            equ 0          ; 8 bytes filename
DIR_EXT             equ 8          ; 3 bytes extension
DIR_ATTR            equ 11         ; 1 byte attributes
DIR_FIRST_CLUS_HI   equ 20        ; 2 bytes (FAT32 only, 0 for FAT16)
DIR_FIRST_CLUS_LO   equ 26        ; 2 bytes
DIR_FILE_SIZE       equ 28         ; 4 bytes
DIR_ENTRY_SIZE      equ 32

; Attributes
ATTR_READ_ONLY      equ 0x01
ATTR_HIDDEN         equ 0x02
ATTR_SYSTEM         equ 0x04
ATTR_VOLUME_ID      equ 0x08
ATTR_DIRECTORY      equ 0x10
ATTR_ARCHIVE        equ 0x20
ATTR_LFN            equ 0x0F

; Temp buffers. Cache32Max keeps these cold buffers outside the 4MB..16MB GUI
; LLC arena and outside the 16MB..24MB app arena.
%ifdef NEXUS_CACHE32_MAX
FAT16_SECTOR_BUF    equ 0x1A00000   ; 512 byte sector buffer
FAT16_FAT_CACHE     equ 0x1A01000   ; FAT table cache (up to 64KB)
FAT16_ROOT_CACHE    equ 0x1A11000   ; Root directory cache (up to 32 sectors = 16KB)
FAT16_FILE_BUF      equ 0x1A21000   ; File read buffer (up to 64KB)
FAT16_DIR_CACHE     equ 0x1A31000   ; Current directory listing cache
%else
; Moved to 13MB region to avoid XHCI conflict (0x900000-0x9F0000)
FAT16_SECTOR_BUF    equ 0xD00000   ; 512 byte sector buffer
FAT16_FAT_CACHE     equ 0xD01000   ; FAT table cache (up to 64KB)
FAT16_ROOT_CACHE    equ 0xD11000   ; Root directory cache (up to 32 sectors = 16KB)
FAT16_FILE_BUF      equ 0xD21000   ; File read buffer (up to 64KB)
FAT16_DIR_CACHE     equ 0xD31000   ; Current directory listing cache
%endif

; ============================================================================
; fat16_init - Initialize FAT16 driver, read BPB and cache FAT + root dir
; Returns: eax = 0 on success
; ============================================================================
FN_BEGIN fat16_init, 0, 0, FN_RET_SCALAR
    push rbx
    push rcx
    push rdx
    push rdi
    push rsi

    ; Read boot sector of FAT16 partition
    ; First attempt with default drive (0xE0)
    mov rdi, FAT16_PART_LBA
    mov rsi, FAT16_SECTOR_BUF
    mov edx, 1
    call ata_read_sectors
    test eax, eax
    jnz .try_next_drive

    ; Check partition signature
    cmp word [abs FAT16_SECTOR_BUF + 510], 0xAA55
    je .bpb_found

.try_next_drive:
    ; Toggle drive (0xE0 -> 0xF0 or vice versa)
    mov al, [ata_drive_sel]
    xor al, 0x10
    mov [ata_drive_sel], al

    ; Try reading again
    mov rdi, FAT16_PART_LBA
    mov rsi, FAT16_SECTOR_BUF
    mov edx, 1
    call ata_read_sectors
    test eax, eax
    jnz .init_fail

    ; Check signature again
    cmp word [abs FAT16_SECTOR_BUF + 510], 0xAA55
    jne .init_fail

.bpb_found:
    ; Parse BPB
    mov rbx, FAT16_SECTOR_BUF
    movzx eax, word [rbx + BPB_BYTES_PER_SECT]
    cmp eax, 512
    jne .init_fail
    mov [fat16_bytes_per_sect], ax
    movzx eax, byte [rbx + BPB_SECT_PER_CLUS]
    test eax, eax
    jz .init_fail
    cmp eax, 128
    ja .init_fail
    mov [fat16_sect_per_clus], al
    movzx eax, word [rbx + BPB_RESERVED_SECTS]
    test eax, eax
    jz .init_fail
    mov [fat16_reserved_sects], ax
    movzx eax, byte [rbx + BPB_NUM_FATS]
    cmp eax, 1
    jb .init_fail
    cmp eax, 2
    ja .init_fail
    mov [fat16_num_fats], al
    movzx eax, word [rbx + BPB_ROOT_ENTRIES]
    test eax, eax
    jz .init_fail
    cmp eax, FAT16_ROOT_CACHE_SECTORS * 16
    ja .init_fail
    mov [fat16_root_entries], ax
    movzx eax, word [rbx + BPB_FAT_SIZE16]
    test eax, eax
    jz .init_fail
    cmp eax, FAT16_FAT_CACHE_SECTORS
    ja .init_fail
    mov [fat16_fat_size], ax
    movzx eax, word [rbx + BPB_TOTAL_SECTS16]
    test eax, eax
    jz .init_fail
    mov [fat16_total_sects], eax

    ; Calculate key offsets (all relative to partition start)
    ; FAT start = reserved sectors
    movzx eax, word [fat16_reserved_sects]
    mov [fat16_fat_start_sect], eax

    ; Root dir start = reserved + num_fats * fat_size
    movzx ecx, byte [fat16_num_fats]
    movzx edx, word [fat16_fat_size]
    imul ecx, edx
    jo .init_fail
    add eax, ecx
    jc .init_fail
    cmp eax, [fat16_total_sects]
    jae .init_fail
    mov [fat16_root_start_sect], eax

    ; Root dir sectors = (root_entries * 32 + 511) / 512
    movzx ecx, word [fat16_root_entries]
    shl ecx, 5            ; * 32
    add ecx, 511
    shr ecx, 9            ; / 512
    mov [fat16_root_sectors], ecx

    ; Data region start = root_start + root_sectors
    add eax, ecx
    jc .init_fail
    cmp eax, [fat16_total_sects]
    jae .init_fail
    mov [fat16_data_start_sect], eax
    mov edx, [fat16_total_sects]
    sub edx, eax
    movzx ecx, byte [fat16_sect_per_clus]
    mov eax, edx
    xor edx, edx
    div ecx
    add eax, 2
    cmp eax, FAT16_MAX_FAT_ENTRIES
    jbe .fat_entries_ok
    mov eax, FAT16_MAX_FAT_ENTRIES
.fat_entries_ok:
    mov [fat16_fat_entries], eax

    ; Cache the FAT table
    mov edi, [fat16_fat_start_sect]
    add edi, FAT16_PART_LBA
    mov rsi, FAT16_FAT_CACHE
    movzx edx, word [fat16_fat_size]
    call ata_read_sectors

    ; Cache the root directory
    mov edi, [fat16_root_start_sect]
    add edi, FAT16_PART_LBA
    mov rsi, FAT16_ROOT_CACHE
    mov edx, [fat16_root_sectors]
    cmp edx, FAT16_ROOT_CACHE_SECTORS
    ja .init_fail
    call ata_read_sectors

    ; Count files in root dir
    call fat16_count_root_files

    xor eax, eax
    jmp .init_ret

.init_fail:
    mov eax, -1

.init_ret:
    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    ret

; Internal: count valid files in root directory
fat16_count_root_files:
    push rcx
    push rbx
    mov rbx, FAT16_ROOT_CACHE
    xor ecx, ecx           ; count
    xor edx, edx           ; index
    movzx r8d, word [fat16_root_entries]
.count_loop:
    cmp edx, r8d
    jge .count_done
    cmp byte [rbx], 0      ; end of entries
    je .count_done
    cmp byte [rbx], 0xE5   ; deleted entry
    je .count_skip
    mov al, [rbx + DIR_ATTR]
    cmp al, ATTR_LFN          ; LFN entries have attr = 0x0F exactly
    je .count_skip
    test al, ATTR_VOLUME_ID
    jnz .count_skip
    inc ecx
.count_skip:
    add rbx, DIR_ENTRY_SIZE
    inc edx
    jmp .count_loop
.count_done:
    mov [fat16_file_count_val], ecx
    pop rbx
    pop rcx
    ret

; ============================================================================
; fat16_file_count - Return number of files in root directory
; Returns: eax = file count
; ============================================================================
FN_BEGIN fat16_file_count, 0, 0, FN_RET_SCALAR
    mov eax, [fat16_file_count_val]
    ret

; ============================================================================
; fat16_get_entry - Get nth valid directory entry from root dir
; edi = index (0-based)
; Returns: rax = pointer to 32-byte dir entry, or 0 if not found
; ============================================================================
FN_BEGIN fat16_get_entry, 0, 0, FN_RET_SCALAR
    push rbx
    push rcx
    push rdx

    mov rbx, FAT16_ROOT_CACHE
    xor ecx, ecx           ; valid entry counter
    xor edx, edx           ; raw entry counter
    movzx r8d, word [fat16_root_entries]

.ge_loop:
    cmp edx, r8d
    jge .ge_not_found
    cmp byte [rbx], 0
    je .ge_not_found
    cmp byte [rbx], 0xE5
    je .ge_skip
    mov al, [rbx + DIR_ATTR]
    test al, ATTR_VOLUME_ID
    jnz .ge_skip
    cmp al, ATTR_LFN
    je .ge_skip
    ; Valid entry
    cmp ecx, edi
    je .ge_found
    inc ecx
.ge_skip:
    add rbx, DIR_ENTRY_SIZE
    inc edx
    jmp .ge_loop

.ge_found:
    mov rax, rbx
    pop rdx
    pop rcx
    pop rbx
    ret

.ge_not_found:
    xor eax, eax
    pop rdx
    pop rcx
    pop rbx
    ret

; ============================================================================
; fat16_read_file - Read a file by directory entry pointer
; rdi = pointer to directory entry (from fat16_get_entry)
; rsi = destination buffer
; edx = max bytes to read
; Returns: eax = bytes read, or -1 on error
; ============================================================================
FN_BEGIN fat16_read_file, 0, 0, FN_RET_SCALAR
    push rbx
    push rcx
    push rdx
    push r12
    push r13
    push r14
    push r15
    push rdi
    push rsi

    mov r12, rdi           ; dir entry ptr
    mov r13, rsi           ; dest buffer
    mov r14d, edx          ; max bytes
    mov r15d, [r12 + DIR_FILE_SIZE]  ; actual file size

    ; Use smaller of max_bytes and file_size
    cmp r14d, r15d
    jle .size_ok
    mov r14d, r15d
.size_ok:

    ; Get first cluster
    movzx ebx, word [r12 + DIR_FIRST_CLUS_LO]
    test ebx, ebx
    jz .rf_empty           ; empty file

    xor ecx, ecx           ; bytes read so far
    movzx r8d, byte [fat16_sect_per_clus]
    mov r10d, [fat16_fat_entries]

.rf_cluster_loop:
    test r10d, r10d
    jz .rf_done
    dec r10d
    ; Check cluster validity
    cmp ebx, 2
    jl .rf_done
    cmp ebx, 0xFFF8
    jge .rf_done
    cmp ebx, [fat16_fat_entries]
    jae .rf_done

    ; Calculate LBA for this cluster
    ; LBA = data_start + (cluster - 2) * sect_per_clus + PART_LBA
    mov eax, ebx
    sub eax, 2
    movzx edx, byte [fat16_sect_per_clus]
    imul eax, edx
    jo .rf_done
    add eax, [fat16_data_start_sect]
    jc .rf_done
    mov edx, eax
    movzx r11d, byte [fat16_sect_per_clus]
    add edx, r11d
    jc .rf_done
    cmp edx, [fat16_total_sects]
    ja .rf_done
    add eax, FAT16_PART_LBA

    ; Read the cluster into a kernel scratch buffer, then copy only the
    ; requested bytes so a final partial read cannot overwrite the caller.
    push rcx
    mov edi, eax
    mov rsi, FAT16_FILE_BUF
    movzx edx, byte [fat16_sect_per_clus]
    call ata_read_sectors
    pop rcx

    movzx eax, byte [fat16_sect_per_clus]
    shl eax, 9             ; * 512
    mov r11d, r14d
    sub r11d, ecx           ; remaining requested bytes
    cmp r11d, eax
    jbe .rf_copy_len_ok
    mov r11d, eax
.rf_copy_len_ok:
    push rcx
    lea rdi, [r13 + rcx]
    mov rsi, FAT16_FILE_BUF
    mov ecx, r11d
    cld
    rep movsb
    pop rcx
    add ecx, r11d

    ; Check if we've read enough
    cmp ecx, r14d
    jge .rf_done

    ; Follow FAT chain
    ; Next cluster = FAT[current_cluster] (16-bit entry)
    mov eax, ebx
    shl eax, 1             ; * 2 (FAT16 entries are 2 bytes)
    movzx ebx, word [FAT16_FAT_CACHE + rax]
    jmp .rf_cluster_loop

.rf_empty:
    xor ecx, ecx

.rf_done:
    ; Return min(bytes_read, requested)
    cmp ecx, r14d
    jle .rf_ret_ok
    mov ecx, r14d
.rf_ret_ok:
    mov eax, ecx

    pop rsi
    pop rdi
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdx
    pop rcx
    pop rbx
    ret

; ============================================================================
; fat16_write_file - Write/create a file in root directory
; rdi = pointer to 11-char filename (8.3 format, space-padded)
; rsi = source buffer
; edx = number of bytes to write
; Returns: eax = 0 on success, -1 on error
; ============================================================================
FN_BEGIN fat16_write_file, 0, 0, FN_RET_SCALAR
    push rbx
    push rcx
    push rdx
    push r12
    push r13
    push r14
    push r15
    push rdi
    push rsi

    mov r12, rdi           ; filename
    mov r13, rsi           ; source buffer
    mov r14d, edx          ; byte count

    ; First, find existing entry or free slot in root dir
    mov rbx, FAT16_ROOT_CACHE
    xor ecx, ecx
    movzx r8d, word [fat16_root_entries]
    mov r15, 0             ; free slot pointer (0 = not found yet)

.wf_search:
    cmp ecx, r8d
    jge .wf_search_done
    cmp byte [rbx], 0
    je .wf_found_free
    cmp byte [rbx], 0xE5
    je .wf_found_free

    ; Compare filename (11 bytes)
    push rcx
    push rdi
    push rsi
    mov rdi, rbx
    mov rsi, r12
    mov ecx, 11
.wf_cmp:
    mov al, [rdi]
    cmp al, [rsi]
    jne .wf_cmp_diff
    inc rdi
    inc rsi
    dec ecx
    jnz .wf_cmp
    ; Match found - overwrite this entry
    pop rsi
    pop rdi
    pop rcx
    mov r15, rbx
    jmp .wf_have_slot

.wf_cmp_diff:
    pop rsi
    pop rdi
    pop rcx
    add rbx, DIR_ENTRY_SIZE
    inc ecx
    jmp .wf_search

.wf_found_free:
    cmp r15, 0
    jne .wf_skip_free
    mov r15, rbx           ; remember first free slot
.wf_skip_free:
    ; Check if this is end-of-dir marker
    cmp byte [rbx], 0
    je .wf_search_done
    add rbx, DIR_ENTRY_SIZE
    inc ecx
    jmp .wf_search

.wf_search_done:
    cmp r15, 0
    je .wf_error            ; no free slot

.wf_have_slot:
    ; r15 = dir entry to use
    ; If overwriting existing file, free old clusters first
    cmp byte [r15], 0
    je .wf_new_entry
    cmp byte [r15], 0xE5
    je .wf_new_entry

    ; Free existing cluster chain
    movzx ebx, word [r15 + DIR_FIRST_CLUS_LO]
    mov r9d, [fat16_fat_entries]
.wf_free_chain:
    test r9d, r9d
    jz .wf_new_entry
    dec r9d
    cmp ebx, 2
    jl .wf_new_entry
    cmp ebx, 0xFFF8
    jge .wf_new_entry
    cmp ebx, [fat16_fat_entries]
    jae .wf_new_entry
    mov eax, ebx
    shl eax, 1
    movzx ebx, word [FAT16_FAT_CACHE + rax]
    mov word [FAT16_FAT_CACHE + rax], 0  ; free cluster
    jmp .wf_free_chain

.wf_new_entry:
    ; Write filename to entry
    push rcx
    push rdi
    push rsi
    mov rdi, r15
    mov rsi, r12
    mov ecx, 11
    rep movsb
    pop rsi
    pop rdi
    pop rcx

    ; Set attributes
    mov byte [r15 + DIR_ATTR], ATTR_ARCHIVE
    ; Clear high cluster word
    mov word [r15 + DIR_FIRST_CLUS_HI], 0
    ; Set file size
    mov [r15 + DIR_FILE_SIZE], r14d

    ; Allocate clusters and write data
    test r14d, r14d
    jz .wf_empty_file

    ; Find first free cluster
    xor ebx, ebx           ; first cluster (will store here)
    mov ecx, 2             ; start searching from cluster 2
    mov r8d, [fat16_fat_entries]

.wf_find_first_free:
    cmp ecx, r8d
    jge .wf_error_full
    mov eax, ecx
    shl eax, 1
    cmp word [FAT16_FAT_CACHE + rax], 0
    je .wf_got_first
    inc ecx
    jmp .wf_find_first_free

.wf_got_first:
    mov ebx, ecx           ; first cluster
    mov [r15 + DIR_FIRST_CLUS_LO], cx

    ; Write data cluster by cluster
    mov r8d, r14d           ; remaining bytes
    mov r9, r13             ; current src pointer
    mov r10d, ebx           ; current cluster

.wf_write_cluster:
    cmp r10d, [fat16_fat_entries]
    jae .wf_error_full
    ; Write this cluster's data. Final partial clusters are padded from a
    ; zero-filled kernel scratch buffer so the disk write never overreads the
    ; caller's source buffer.
    mov eax, r10d
    sub eax, 2
    movzx edx, byte [fat16_sect_per_clus]
    imul eax, edx
    jo .wf_error_full
    add eax, [fat16_data_start_sect]
    jc .wf_error_full
    mov edx, eax
    movzx r11d, byte [fat16_sect_per_clus]
    add edx, r11d
    jc .wf_error_full
    cmp edx, [fat16_total_sects]
    ja .wf_error_full
    add eax, FAT16_PART_LBA

    movzx r11d, byte [fat16_sect_per_clus]
    shl r11d, 9
    cmp r8d, r11d
    jb .wf_write_partial_cluster

    push rcx
    mov edi, eax
    mov rsi, r9
    movzx edx, byte [fat16_sect_per_clus]
    call ata_write_sectors
    pop rcx

    ; Advance source pointer
    add r9, r11
    sub r8d, r11d
    jle .wf_last_cluster     ; no more data
    jmp .wf_alloc_next

.wf_write_partial_cluster:
    push rax
    push rcx
    push rdi
    push rsi
    mov rdi, FAT16_FILE_BUF
    mov ecx, r11d
    xor eax, eax
    cld
    rep stosb
    mov rdi, FAT16_FILE_BUF
    mov rsi, r9
    mov ecx, r8d
    rep movsb
    pop rsi
    pop rdi
    pop rcx
    pop rax

    push rcx
    mov edi, eax
    mov rsi, FAT16_FILE_BUF
    movzx edx, byte [fat16_sect_per_clus]
    call ata_write_sectors
    pop rcx

    add r9, r8
    xor r8d, r8d
    jmp .wf_last_cluster

    ; Allocate next cluster
.wf_alloc_next:
    mov ecx, r10d
    inc ecx                  ; start search after current
.wf_find_next:
    cmp ecx, [fat16_fat_entries]
    jge .wf_error_full
    mov eax, ecx
    shl eax, 1
    cmp word [FAT16_FAT_CACHE + rax], 0
    je .wf_got_next
    inc ecx
    jmp .wf_find_next

.wf_got_next:
    ; Link current cluster to next
    mov eax, r10d
    shl eax, 1
    mov [FAT16_FAT_CACHE + rax], cx
    mov r10d, ecx
    jmp .wf_write_cluster

.wf_last_cluster:
    ; Mark end of chain
    mov eax, r10d
    shl eax, 1
    mov word [FAT16_FAT_CACHE + rax], 0xFFFF

.wf_empty_file:
    ; Write updated FAT back to disk
    mov edi, [fat16_fat_start_sect]
    add edi, FAT16_PART_LBA
    mov rsi, FAT16_FAT_CACHE
    movzx edx, word [fat16_fat_size]
    cmp edx, 128
    jle .wf_fat_ok
    mov edx, 128
.wf_fat_ok:
    call ata_write_sectors

    ; Write second FAT copy if exists
    cmp byte [fat16_num_fats], 2
    jl .wf_skip_fat2
    mov edi, [fat16_fat_start_sect]
    movzx eax, word [fat16_fat_size]
    add edi, eax
    add edi, FAT16_PART_LBA
    mov rsi, FAT16_FAT_CACHE
    movzx edx, word [fat16_fat_size]
    cmp edx, 128
    jle .wf_fat2_ok
    mov edx, 128
.wf_fat2_ok:
    call ata_write_sectors
.wf_skip_fat2:

    ; Write updated current directory back to disk. The cache may contain the
    ; root directory or a loaded subdirectory.
    call fat16_flush_current_dir

    ; Recount files
    call fat16_count_root_files

    xor eax, eax
    jmp .wf_ret

.wf_error_full:
.wf_error:
    mov eax, -1

.wf_ret:
    pop rsi
    pop rdi
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdx
    pop rcx
    pop rbx
    ret

; ============================================================================
; fat16_flush_fats - Write cached FAT table to every on-disk FAT copy
; Returns: eax = 0 on success
; ============================================================================
FN_BEGIN fat16_flush_fats, 0, 0, FN_RET_SCALAR
    push rdi
    push rsi
    push rdx
    push rax

    mov edi, [fat16_fat_start_sect]
    add edi, FAT16_PART_LBA
    mov rsi, FAT16_FAT_CACHE
    movzx edx, word [fat16_fat_size]
    cmp edx, FAT16_FAT_CACHE_SECTORS
    jbe .ff_fat1_len_ok
    mov edx, FAT16_FAT_CACHE_SECTORS
.ff_fat1_len_ok:
    call ata_write_sectors

    cmp byte [fat16_num_fats], 2
    jl .ff_done
    mov edi, [fat16_fat_start_sect]
    movzx eax, word [fat16_fat_size]
    add edi, eax
    add edi, FAT16_PART_LBA
    mov rsi, FAT16_FAT_CACHE
    movzx edx, word [fat16_fat_size]
    cmp edx, FAT16_FAT_CACHE_SECTORS
    jbe .ff_fat2_len_ok
    mov edx, FAT16_FAT_CACHE_SECTORS
.ff_fat2_len_ok:
    call ata_write_sectors

.ff_done:
    pop rax
    xor eax, eax
    pop rdx
    pop rsi
    pop rdi
    ret

; ============================================================================
; fat16_flush_current_dir - Write the current directory cache back to disk
; Returns: eax = 0 on success, -1 on unsupported/invalid current dir
; ============================================================================
FN_BEGIN fat16_flush_current_dir, 0, 0, FN_RET_SCALAR
    push rbx
    push rdi
    push rsi
    push rdx
    push r8
    push r9

    movzx ebx, word [fat16_cur_dir_cluster]
    test ebx, ebx
    jnz .fcd_subdir

    mov edi, [fat16_root_start_sect]
    add edi, FAT16_PART_LBA
    mov rsi, FAT16_ROOT_CACHE
    mov edx, [fat16_root_sectors]
    cmp edx, FAT16_ROOT_CACHE_SECTORS
    ja .fcd_fail
    call ata_write_sectors
    xor eax, eax
    jmp .fcd_done

.fcd_subdir:
    cmp ebx, 2
    jb .fcd_fail
    cmp ebx, 0xFFF8
    jae .fcd_fail
    cmp ebx, [fat16_fat_entries]
    jae .fcd_fail

    mov r9d, ebx
    mov eax, r9d
    sub eax, 2
    movzx edx, byte [fat16_sect_per_clus]
    imul eax, edx
    jo .fcd_fail
    add eax, [fat16_data_start_sect]
    jc .fcd_fail
    mov r8d, eax
    movzx edx, byte [fat16_sect_per_clus]
    add r8d, edx
    jc .fcd_fail
    cmp r8d, [fat16_total_sects]
    ja .fcd_fail
    add eax, FAT16_PART_LBA
    mov edi, eax
    mov rsi, FAT16_ROOT_CACHE
    movzx edx, byte [fat16_sect_per_clus]
    call ata_write_sectors
    xor eax, eax
    jmp .fcd_done

.fcd_fail:
    mov eax, -1
.fcd_done:
    pop r9
    pop r8
    pop rdx
    pop rsi
    pop rdi
    pop rbx
    ret

; ============================================================================
; fat16_delete_entry - Delete a file or empty directory from the current view
; rdi = pointer to 32-byte directory entry from fat16_get_entry/SYS_FS_ENTRY
; Returns: eax = 0 on success, -1 on error
; ============================================================================
FN_BEGIN fat16_delete_entry, 0, 0, FN_RET_SCALAR
    push rbx
    push r12
    push r13

    mov r12, rdi
    cmp byte [r12], 0
    je .de_error
    cmp byte [r12], 0xE5
    je .de_error

    mov al, [r12 + DIR_ATTR]
    test al, ATTR_DIRECTORY
    jz .de_free_chain
    movzx ebx, word [r12 + DIR_FIRST_CLUS_LO]
    test ebx, ebx
    jz .de_mark_deleted
    call fat16_dir_cluster_is_empty
    test eax, eax
    jz .de_error

.de_free_chain:
    movzx ebx, word [r12 + DIR_FIRST_CLUS_LO]
    mov r13d, [fat16_fat_entries]
.de_chain_loop:
    test r13d, r13d
    jz .de_mark_deleted
    dec r13d
    cmp ebx, 2
    jb .de_mark_deleted
    cmp ebx, 0xFFF8
    jae .de_mark_deleted
    cmp ebx, [fat16_fat_entries]
    jae .de_mark_deleted
    mov eax, ebx
    shl eax, 1
    movzx ebx, word [FAT16_FAT_CACHE + rax]
    mov word [FAT16_FAT_CACHE + rax], 0
    jmp .de_chain_loop

.de_mark_deleted:
    mov byte [r12], 0xE5
    call fat16_flush_fats
    call fat16_flush_current_dir
    call fat16_count_root_files
    xor eax, eax
    jmp .de_done

.de_error:
    mov eax, -1
.de_done:
    pop r13
    pop r12
    pop rbx
    ret

; ============================================================================
; fat16_rename_entry - Rename an entry in the current directory
; rdi = directory entry pointer, rsi = 11-byte FAT 8.3 name
; Returns: eax = 0 on success, -1 on error/duplicate name
; ============================================================================
FN_BEGIN fat16_rename_entry, 0, 0, FN_RET_SCALAR
    push rbx
    push rcx
    push rdi
    push rsi
    push r12
    push r13

    mov r12, rdi
    mov r13, rsi
    cmp byte [r12], 0
    je .ren_error
    cmp byte [r12], 0xE5
    je .ren_error

    mov rbx, FAT16_ROOT_CACHE
    xor edx, edx
    movzx r8d, word [fat16_root_entries]
.ren_dup_loop:
    cmp edx, r8d
    jge .ren_copy
    cmp byte [rbx], 0
    je .ren_copy
    cmp byte [rbx], 0xE5
    je .ren_dup_next
    cmp rbx, r12
    je .ren_dup_next
    push rdi
    push rsi
    push rcx
    mov rdi, rbx
    mov rsi, r13
    mov ecx, 11
    repe cmpsb
    pop rcx
    pop rsi
    pop rdi
    je .ren_error
.ren_dup_next:
    add rbx, DIR_ENTRY_SIZE
    inc edx
    jmp .ren_dup_loop

.ren_copy:
    mov rdi, r12
    mov rsi, r13
    mov ecx, 11
    cld
    rep movsb
    call fat16_flush_current_dir
    xor eax, eax
    jmp .ren_done

.ren_error:
    mov eax, -1
.ren_done:
    pop r13
    pop r12
    pop rsi
    pop rdi
    pop rcx
    pop rbx
    ret

; ============================================================================
; fat16_mkdir - Create a single-cluster directory in the current directory
; rdi = pointer to 11-byte FAT 8.3 directory name
; Returns: eax = 0 on success, -1 on error
; ============================================================================
FN_BEGIN fat16_mkdir, 0, 0, FN_RET_SCALAR
    push rbx
    push rcx
    push rdx
    push rdi
    push rsi
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi
    xor r13d, r13d          ; free dir-entry slot

    mov rbx, FAT16_ROOT_CACHE
    xor ecx, ecx
    movzx r8d, word [fat16_root_entries]
.md_scan_loop:
    cmp ecx, r8d
    jge .md_scan_done
    cmp byte [rbx], 0
    je .md_found_free
    cmp byte [rbx], 0xE5
    je .md_found_free

    push rcx
    push rdi
    push rsi
    mov rdi, rbx
    mov rsi, r12
    mov ecx, 11
    repe cmpsb
    pop rsi
    pop rdi
    pop rcx
    je .md_error

    add rbx, DIR_ENTRY_SIZE
    inc ecx
    jmp .md_scan_loop

.md_found_free:
    test r13, r13
    jnz .md_skip_free
    mov r13, rbx
.md_skip_free:
    cmp byte [rbx], 0
    je .md_scan_done
    add rbx, DIR_ENTRY_SIZE
    inc ecx
    jmp .md_scan_loop

.md_scan_done:
    test r13, r13
    jz .md_error

    mov ecx, 2
    mov r8d, [fat16_fat_entries]
.md_find_cluster:
    cmp ecx, r8d
    jge .md_error
    mov eax, ecx
    shl eax, 1
    cmp word [FAT16_FAT_CACHE + rax], 0
    je .md_cluster_found
    inc ecx
    jmp .md_find_cluster

.md_cluster_found:
    mov r14d, ecx
    mov eax, r14d
    shl eax, 1
    mov word [FAT16_FAT_CACHE + rax], 0xFFFF

    ; Clear one directory cluster and seed "." and ".." entries.
    mov rdi, FAT16_FILE_BUF
    movzx ecx, byte [fat16_sect_per_clus]
    shl ecx, 9
    xor eax, eax
    cld
    rep stosb

    mov rdi, FAT16_FILE_BUF
    mov byte [rdi + 0], '.'
    mov ecx, 10
    mov rdi, FAT16_FILE_BUF + 1
    mov al, ' '
    rep stosb
    mov byte [abs FAT16_FILE_BUF + DIR_ATTR], ATTR_DIRECTORY
    mov word [abs FAT16_FILE_BUF + DIR_FIRST_CLUS_LO], r14w

    mov rdi, FAT16_FILE_BUF + DIR_ENTRY_SIZE
    mov byte [rdi + 0], '.'
    mov byte [rdi + 1], '.'
    mov ecx, 9
    mov rdi, FAT16_FILE_BUF + DIR_ENTRY_SIZE + 2
    mov al, ' '
    rep stosb
    mov byte [abs FAT16_FILE_BUF + DIR_ENTRY_SIZE + DIR_ATTR], ATTR_DIRECTORY
    mov ax, [fat16_cur_dir_cluster]
    mov word [abs FAT16_FILE_BUF + DIR_ENTRY_SIZE + DIR_FIRST_CLUS_LO], ax

    mov eax, r14d
    sub eax, 2
    movzx edx, byte [fat16_sect_per_clus]
    imul eax, edx
    jo .md_error
    add eax, [fat16_data_start_sect]
    jc .md_error
    mov r15d, eax
    movzx edx, byte [fat16_sect_per_clus]
    add r15d, edx
    jc .md_error
    cmp r15d, [fat16_total_sects]
    ja .md_error
    add eax, FAT16_PART_LBA
    mov edi, eax
    mov rsi, FAT16_FILE_BUF
    movzx edx, byte [fat16_sect_per_clus]
    call ata_write_sectors

    mov rdi, r13
    mov rsi, r12
    mov ecx, 11
    cld
    rep movsb
    mov byte [r13 + DIR_ATTR], ATTR_DIRECTORY
    mov word [r13 + DIR_FIRST_CLUS_HI], 0
    mov word [r13 + DIR_FIRST_CLUS_LO], r14w
    mov dword [r13 + DIR_FILE_SIZE], 0

    call fat16_flush_fats
    call fat16_flush_current_dir
    call fat16_count_root_files
    xor eax, eax
    jmp .md_done

.md_error:
    mov eax, -1
.md_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    ret

; EBX=directory cluster. Returns eax=1 if it contains only "."/".." or empty.
fat16_dir_cluster_is_empty:
    push rbx
    push rcx
    push rdi
    push rsi
    push r8
    push r9

    cmp ebx, 2
    jb .dce_fail
    cmp ebx, 0xFFF8
    jae .dce_fail
    cmp ebx, [fat16_fat_entries]
    jae .dce_fail

    mov eax, ebx
    sub eax, 2
    movzx edx, byte [fat16_sect_per_clus]
    imul eax, edx
    jo .dce_fail
    add eax, [fat16_data_start_sect]
    jc .dce_fail
    mov r8d, eax
    movzx edx, byte [fat16_sect_per_clus]
    add r8d, edx
    jc .dce_fail
    cmp r8d, [fat16_total_sects]
    ja .dce_fail
    add eax, FAT16_PART_LBA
    mov edi, eax
    mov rsi, FAT16_FILE_BUF
    movzx edx, byte [fat16_sect_per_clus]
    call ata_read_sectors

    mov rdi, FAT16_FILE_BUF
    movzx ecx, byte [fat16_sect_per_clus]
    shl ecx, 4              ; sectors * 512 / 32 entries
.dce_loop:
    test ecx, ecx
    jz .dce_empty
    cmp byte [rdi], 0
    je .dce_empty
    cmp byte [rdi], 0xE5
    je .dce_next
    cmp byte [rdi], '.'
    jne .dce_fail
    mov al, [rdi + 1]
    cmp al, ' '
    je .dce_next
    cmp al, '.'
    jne .dce_fail
.dce_next:
    add rdi, DIR_ENTRY_SIZE
    dec ecx
    jmp .dce_loop

.dce_empty:
    mov eax, 1
    jmp .dce_done
.dce_fail:
    xor eax, eax
.dce_done:
    pop r9
    pop r8
    pop rsi
    pop rdi
    pop rcx
    pop rbx
    ret



; ============================================================================
; fat16_change_dir - Change current directory (load into ROOT_CACHE)
; ax = cluster number (0 = root)
; Returns: eax = 0 on success
; ============================================================================
; auto-wrapped (FN_BEGIN emits global): global fat16_change_dir
FN_BEGIN fat16_change_dir, 0, 0, FN_RET_SCALAR
    push rbx
    push rcx
    push rdx
    push rdi
    push rsi
    push r8
    push r9
    push r10
    push r11

    movzx ebx, ax          ; cluster
    mov [fat16_cur_dir_cluster], bx
    
    ; Cluster 0 -> Load Root Directory
    test ebx, ebx
    jnz .cd_subdir
    
    ; Load Root (contiguous)
    mov edi, [fat16_root_start_sect]
    add edi, FAT16_PART_LBA
    mov rsi, FAT16_ROOT_CACHE
    mov edx, [fat16_root_sectors]
    cmp edx, FAT16_ROOT_CACHE_SECTORS
    ja .cd_fail
    call ata_read_sectors
    
    ; Reset file count
    call fat16_count_root_files
    xor eax, eax
    jmp .cd_done

.cd_subdir:
    ; Subdirectory: Read cluster chain into FAT16_ROOT_CACHE
    ; Max entries restricted by ROOT_CACHE size (16KB = 512 entries)
    ; Clear cache first
    mov rdi, FAT16_ROOT_CACHE
    mov ecx, 16384 / 4
    xor eax, eax
    rep stosd
    
    mov rsi, FAT16_ROOT_CACHE ; Dest
    xor r10d, r10d            ; Total bytes read
    mov r11d, [fat16_fat_entries]
    
.cd_loop:
    test r11d, r11d
    jz .cd_finish
    dec r11d
    cmp ebx, 2
    jl .cd_finish
    cmp ebx, 0xFFF8
    jge .cd_finish
    cmp ebx, [fat16_fat_entries]
    jae .cd_finish
    
    ; Read cluster
    mov eax, ebx
    sub eax, 2
    movzx edx, byte [fat16_sect_per_clus]
    imul eax, edx
    jo .cd_finish
    add eax, [fat16_data_start_sect]
    jc .cd_finish
    mov edx, eax
    movzx r9d, byte [fat16_sect_per_clus]
    add edx, r9d
    jc .cd_finish
    cmp edx, [fat16_total_sects]
    ja .cd_finish
    add eax, FAT16_PART_LBA
    
    mov edi, eax
    movzx edx, byte [fat16_sect_per_clus]
    
    ; Safety check for cache overflow
    mov eax, edx
    shl eax, 9 ; bytes to read
    lea r9d, [r10d + eax]
    cmp r9d, 16384
    jg .cd_finish ; Truncate if too big
    
    call ata_read_sectors
    
    ; Advance ptr
    movzx eax, byte [fat16_sect_per_clus]
    shl eax, 9
    add rsi, rax
    add r10d, eax
    
    ; Next cluster
    mov eax, ebx
    shl eax, 1
    movzx ebx, word [FAT16_FAT_CACHE + rax]
    jmp .cd_loop

.cd_finish:
    ; Recount files in new view
    call fat16_count_root_files
    xor eax, eax

.cd_done:
    pop r11
    pop r10

    pop r9
    pop r8
    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    ret

.cd_fail:
    mov eax, -1
    jmp .cd_done

; ============================================================================
; fat16_get_file_size - Get file size from directory entry
; rdi = pointer to directory entry
; Returns: eax = file size in bytes
; ============================================================================
FN_BEGIN fat16_get_file_size, 0, 0, FN_RET_SCALAR
    mov eax, [rdi + DIR_FILE_SIZE]
    ret

; ============================================================================
; fat16_sync_root - Write root directory cache to disk
; ============================================================================
; auto-wrapped (FN_BEGIN emits global): global fat16_sync_root
FN_BEGIN fat16_sync_root, 0, 0, FN_RET_SCALAR
    call fat16_flush_current_dir
    ret

; ============================================================================
; Data
; ============================================================================
section .data

fat16_bytes_per_sect  dw 512
fat16_sect_per_clus   db 4
fat16_reserved_sects  dw 1
fat16_num_fats        db 2
fat16_root_entries    dw 512
fat16_fat_size        dw 0
fat16_fat_start_sect  dd 0
fat16_root_start_sect dd 0
fat16_root_sectors    dd 0
fat16_data_start_sect dd 0
fat16_total_sects     dd 0
fat16_fat_entries     dd 0
fat16_file_count_val  dd 0
fat16_cur_dir_cluster dw 0


; ============================================================================
; fat16_debug_dump_root - Dump details about FAT16 init to buffer
; ============================================================================
; auto-wrapped (FN_BEGIN emits global): global fat16_debug_dump_root
FN_BEGIN fat16_debug_dump_root, 0, 0, FN_RET_SCALAR
    push rdi
    push rsi
    push rax
    push rbx
    push rcx
    push rdx

    mov rbx, rdi              ; RBX = write pointer

    ; Header
    lea rsi, [.hdr]
    call .copystr

    ; Drive Selection
    lea rsi, [.s_drive]
    call .copystr
    movzx eax, byte [ata_drive_sel]
    call .writehex8

    ; Partition LBA
    lea rsi, [.s_lba]
    call .copystr
    mov eax, FAT16_PART_LBA
    call .writehex32

    ; Signature check (from buffer)
    lea rsi, [.s_sig]
    call .copystr
    movzx eax, word [abs FAT16_SECTOR_BUF + 510]
    call .writehex16

    ; File Count
    lea rsi, [.s_files]
    call .copystr
    mov eax, [fat16_file_count_val]
    call .writehex32

    ; Root Start Sector
    lea rsi, [.s_root]
    call .copystr
    mov eax, [fat16_root_start_sect]
    call .writehex32
    
    ; Null terminate
    mov byte [rbx], 0

    pop rdx
    pop rcx
    pop rbx
    pop rax
    pop rsi
    pop rdi
    ret

; -- internal helpers --
.copystr:
    lodsb
    test al, al
    jz .cs_done
    mov [rbx], al
    inc rbx
    jmp .copystr
.cs_done:
    ret

.writehex8:
    push rax
    shr al, 4
    call .nib
    pop rax
    push rax
    and al, 0x0F
    call .nib
    pop rax
    ret

.writehex16:
    push rax
    shr ax, 8
    call .writehex8
    pop rax
    push rax
    call .writehex8
    pop rax
    ret

.writehex32:
    push rax
    shr eax, 16
    call .writehex16
    pop rax
    push rax
    call .writehex16
    pop rax
    ret
    
.nib:
    cmp al, 10
    jb .nib_digit
    add al, 'A' - 10
    jmp .nib_out
.nib_digit:
    add al, '0'
.nib_out:
    mov [rbx], al
    inc rbx
    ret

.hdr      db "FAT16 DBG: ", 0
.s_drive  db " Drv:", 0
.s_lba    db " LBA:", 0
.s_sig    db " Sig:", 0
.s_files  db " Files:", 0
.s_root   db " Root:", 0
