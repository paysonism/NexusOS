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