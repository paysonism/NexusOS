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

    ; Verify the directory-entry write did not corrupt the cache guard.
    call fat16_canary_check
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
