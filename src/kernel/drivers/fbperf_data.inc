; ---------------------------------------------------------------------------
section .data

FBPERF_MAX_VAR_MTRR equ 16

msg_banner:  db 13,10,'[FBPERF] === framebuffer perf dump ===',13,10,0
msg_end:     db '[FBPERF] === end ===',13,10,0
k_initdone:  db '[FBPERF] init_done=',0
k_fb_addr:   db '[FBPERF] fb_addr=',0
k_bb_addr:   db '[FBPERF] bb_addr=',0
k_scr_w:     db '[FBPERF] scr_width=',0
k_scr_h:     db '[FBPERF] scr_height=',0
k_scr_p:     db '[FBPERF] scr_pitch=',0
k_cr0:       db '[FBPERF] cr0=',0
k_cr3:       db '[FBPERF] cr3=',0
k_cr4:       db '[FBPERF] cr4=',0
k_cpuidpat:  db '[FBPERF] cpuid01.edx.PAT=',0
k_pat:       db '[FBPERF] IA32_PAT=',0
k_mtrrcap:   db '[FBPERF] IA32_MTRRCAP=',0
k_mtrrdef:   db '[FBPERF] IA32_MTRR_DEF_TYPE=',0
k_mtrrn:     db '[FBPERF] mtrr_var_count=',0
k_mtrrv:     db '[FBPERF] mtrr[i] ',0
k_pml4:      db '[FBPERF] pml4e=',0
k_pdpt:      db '[FBPERF] pdpte=',0
k_pde:       db '[FBPERF] pde=',0
k_pte:       db '[FBPERF] pte=',0
k_leafval:   db '[FBPERF] fb_leaf_value=',0
k_leaflev:   db '[FBPERF] fb_leaf_level=',0
k_caching:   db '[FBPERF] fb_caching_type=',0
k_wcplan:    db '[FBPERF] wc_plan_pat=',0
k_wcarm:     db '[FBPERF] wc_armed=',0
k_wcact:     db '[FBPERF] wc_activated=',0
k_flips:     db '[FBPERF] flips_total=',0
k_fullf:     db '[FBPERF] full_flips=',0
k_rectf:     db '[FBPERF] rect_flips=',0
k_bytes:     db '[FBPERF] bytes_total=',0
k_fullb:     db '[FBPERF] full_bytes=',0
k_rectb:     db '[FBPERF] rect_bytes=',0
k_tsctot:    db '[FBPERF] tsc_total=',0
k_tscmin:    db '[FBPERF] tsc_min=',0
k_tscmax:    db '[FBPERF] tsc_max=',0
k_tsclast:   db '[FBPERF] tsc_last=',0
k_dirty:     db '[FBPERF] dirty_rect_sum=',0

section .bss
alignb 8
fbperf_tsc_at_begin:     resq 1
fbperf_rect_last_w:      resd 1
fbperf_rect_last_h:      resd 1
fbperf_flips_total:      resq 1
fbperf_full_flips:       resq 1
fbperf_rect_flips:       resq 1
fbperf_bytes_total:      resq 1
fbperf_full_bytes:       resq 1
fbperf_rect_bytes:       resq 1
fbperf_tsc_total:        resq 1
fbperf_tsc_min:          resq 1
fbperf_tsc_max:          resq 1
fbperf_tsc_last:         resq 1
fbperf_dirty_rect_sum:   resq 1

fbperf_cr0:              resq 1
fbperf_cr3:              resq 1
fbperf_cr4:              resq 1
fbperf_cpuid_pat_supported: resd 1
fbperf_cpuid_mtrr_supported: resd 1
fbperf_pat_msr:          resq 1
fbperf_mtrrcap:          resd 1
fbperf_mtrr_def_type:    resd 1
fbperf_mtrr_var_count:   resd 1
fbperf_mtrr_var:         resb (16 * FBPERF_MAX_VAR_MTRR)

fbperf_walk_addr:        resq 1
fbperf_pml4e:            resq 1
fbperf_pdpte:            resq 1
fbperf_pde:              resq 1
fbperf_pte:              resq 1
fbperf_fb_pte_value:     resq 1
fbperf_fb_pte_level:     resd 1
fbperf_fb_caching_type:  resd 1

fbperf_wc_plan_pat:      resq 1
fbperf_wc_armed:         resb 1
fbperf_wc_activated:     resb 1
fbperf_init_done:        resb 1

section .text
