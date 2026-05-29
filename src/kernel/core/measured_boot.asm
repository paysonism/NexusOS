; ============================================================================
; NexusOS v3.0 - Measured Boot (security_todo.md §9)
; ----------------------------------------------------------------------------
; Builds a kernel-owned measurement CHAIN over every boot stage that is
; visible to the kernel in RAM, extend-style:
;
;     chain = H(chain || stage_bytes)        for each stage, in order
;
; The final digest lands in kernel BSS (mb_digest) — a kernel-only location,
; never mapped USER, so ring-3 cannot read or forge it. A future sealed
; syscall can expose it for remote attestation (security_todo.md §9), but the
; storage + chaining land here.
;
; THREAT MODEL (docs/STATUS.md §9 boundary): the root of trust is measured
; boot + a kernel-held key, NOT silicon. A physical attacker with the boot
; medium is explicitly out of scope. So we measure the loaded artifacts as the
; kernel sees them, not a hardware-anchored PCR.
;
; HASH PRIMITIVE — DOCUMENTED STOPGAP: this uses a 64-bit FNV-1a extend step,
; the same non-cryptographic family already relied on elsewhere in the tree
; (FN_BEGIN fn_id stamping, sig_hashes). It gives a stable, collision-resistant-
; enough fingerprint to DETECT accidental or casual tampering of a boot stage.
; It is NOT a cryptographic hash: do not treat the digest as preimage- or
; collision-resistant against a determined adversary. Swapping in a compact
; SHA-256 later only requires replacing mb_extend's inner step — the chain
; structure and storage stay identical. Clearly labelled per the §9 TODO.
;
; Stages measured (in chain order):
;   1. kernel code     [_start .. _kernel_text_end)    (executable kernel image;
;                                                       mutable .data past it is
;                                                       intentionally excluded)
;   2. app blob        [app_blob_start .. app_blob_end) (the ring-3 payload)
;
; Both extents are slid together by KASLR (same fixup table), so the measured
; bytes are slide-independent in content. Called once from kmain after the
; canary/cap-HMAC seeding and before any ring-3 entry.
; ============================================================================
bits 64

%include "trace.inc"
%include "app_blob_sig.inc"

; FNV-1a 64-bit constants.
MB_FNV_OFFSET equ 0xCBF29CE484222325
MB_FNV_PRIME  equ 0x00000100000001B3

extern _start                  ; kernel image base (== KERNEL_LOAD_ADDR + slide)
extern _kernel_text_end         ; end-of-text marker (kernel_build.asm)
extern app_blob_start
extern app_blob_end
; Live blob extent published by app_blob_init (usermode.asm). In the default
; KASLR build these point at the fixed-up embedded [app_blob_start,
; app_blob_end); on the non-KASLR APPS.BIN path they point at the loaded blob.
; We verify whichever blob the kernel will actually run.
extern app_blob_base_v
extern app_blob_size_v
extern kernel_panic_canary

section .text

; ----------------------------------------------------------------------------
; mb_extend - fold a byte range into the running chain (mb_chain), FNV-1a.
;   rdi = start ptr, rsi = end ptr (exclusive)
; Internal helper (not global): caller already holds [mb_chain] valid.
; Preserves nothing of note to the caller beyond the chain update; clobbers
; rax/rcx/rdx/rdi.
; ----------------------------------------------------------------------------
mb_extend:
    mov rax, [rel mb_chain]
    mov rcx, MB_FNV_PRIME
.byte_loop:
    cmp rdi, rsi
    jae .done
    movzx edx, byte [rdi]
    xor rax, rdx               ; FNV-1a: hash ^= byte
    mul rcx                    ; hash *= prime (rax = low 64 of rax*rcx)
    inc rdi
    jmp .byte_loop
.done:
    mov [rel mb_chain], rax
    ret

; ----------------------------------------------------------------------------
; measured_boot_init - measure all boot stages into mb_chain, publish mb_digest.
; Idempotent guard (mb_done) so a stray second call cannot re-fold the chain.
; ----------------------------------------------------------------------------
FN_BEGIN measured_boot_init, 0, 0, FN_RET_VOID
    cmp byte [rel mb_done], 0
    jne .ret
    push rdi
    push rsi
    push rax
    push rcx
    push rdx

    ; Seed the chain with the FNV offset basis.
    mov rax, MB_FNV_OFFSET
    mov [rel mb_chain], rax

    ; Stage 1: kernel code [_start .. _kernel_text_end)
    lea rdi, [rel _start]
    lea rsi, [rel _kernel_text_end]
    call mb_extend

    ; Stage 2: app blob [app_blob_start .. app_blob_end)
    lea rdi, [rel app_blob_start]
    lea rsi, [rel app_blob_end]
    call mb_extend

    ; Publish the final digest into its kernel-only resting place.
    mov rax, [rel mb_chain]
    mov [rel mb_digest], rax
    mov byte [rel mb_done], 1

    pop rdx
    pop rcx
    pop rax
    pop rsi
    pop rdi
.ret:
    FN_END measured_boot_init
    ret

; ============================================================================
; app_blob_verify_signature - kernel-verified MAC over the user blob
; (security_todo.md §9 "Sign the user blob"). Fails CLOSED: a mismatch jumps
; to kernel_panic_canary (the same fail-closed sink as a corrupted canary, a
; forged callback, or a code-range integrity violation), so an app can never
; launch from a tampered/corrupted blob.
;
; Verifies the LIVE blob the kernel will actually run — [app_blob_base_v,
; app_blob_base_v + app_blob_size_v) — which in the default KASLR build is the
; fixed-up embedded [app_blob_start, app_blob_end).
;
; KASLR CANONICALIZATION: the embedded blob is RELOCATED at boot, so a handful
; of absolute qwords inside it slide by the kernel slide and differ from the
; build-time image. The MAC EXCLUDES those windows: at each blob-relative offset
; in mb_blob_sig_fixups[0..count) we fold 8 zero bytes instead of the relocated
; bytes. The build tool zeroed the same offsets when computing the expected MAC,
; so the result is slide-independent. Every non-relocated blob byte is covered;
; the relocated address words are excluded by design (see app_blob_sig.inc).
;
; MAC = FNV-1a( KEY8 || covered_blob || KEY8 ), an HMAC-style key envelope over
; the FNV-1a family used elsewhere (see app_blob_sig.inc for the threat-model
; justification and the stopgap-primitive note). The expected MAC + the
; exclusion table were patched in at build time by patch_blob_sig.py using the
; identical APP_BLOB_SIG_KEY, so build-time and runtime MACs match by
; construction iff the covered blob bytes match.
;
; Called once from kmain after measured_boot_init and before any ring-3 entry.
; Idempotent guard (mb_blob_sig_done) so a stray second call is a no-op.
; Preserves all caller registers.
; ----------------------------------------------------------------------------
FN_BEGIN app_blob_verify_signature, 0, 0, FN_RET_VOID
    cmp byte [rel mb_blob_sig_done], 0
    jne .ret
    push rdi
    push rsi
    push rax
    push rcx
    push rdx
    push r8
    push r10
    push r11

    ; r8 = key envelope value; rax = running FNV hash seeded with the basis.
    mov r8, APP_BLOB_SIG_KEY
    mov rax, APP_BLOB_SIG_FNV_OFFSET
    mov rcx, APP_BLOB_SIG_FNV_PRIME

    ; Prefix the key (8 bytes, LE).
    mov rdx, r8
    call .fold8

    ; Fold the live blob bytes [base, base+size), excluding the sliding qwords
    ; listed (blob-relative, ascending) in mb_blob_sig_fixups[0..count). For an
    ; excluded offset we fold 8 zero bytes so the hash is slide-independent.
    ;   rdi = blob base ptr, rsi = exclusive end ptr
    ;   r10 = current blob-relative offset (== rdi - base)
    ;   r11 = index of the next fixup offset to skip (0..count)
    mov rdi, [rel app_blob_base_v]
    mov rsi, [rel app_blob_size_v]
    add rsi, rdi                        ; rsi = exclusive end ptr
    xor r10d, r10d                      ; offset cursor
    xor r11d, r11d                      ; next-fixup index
.blob_loop:
    cmp rdi, rsi
    jae .blob_done
    ; If offset r10 matches the next exclusion entry, fold 8 zeros and skip 8.
    cmp r11d, [rel mb_blob_sig_fixup_count]
    jae .blob_take_byte
    mov edx, [rel mb_blob_sig_fixups + r11*4]
    cmp r10, rdx
    jne .blob_take_byte
    ; Excluded window: fold 8 zero bytes. FNV-1a of a 0x00 byte is
    ; (hash ^ 0) * prime == hash * prime, so 8 zero bytes == hash *= prime^8.
    ; rcx holds the prime throughout; use rdx as the byte counter (reloaded
    ; with the real byte on the take-byte path, so clobbering it is fine).
    mov edx, 8
.blob_zero8:
    imul rax, rcx                       ; hash *= prime
    dec edx
    jnz .blob_zero8
    add rdi, 8
    add r10, 8
    inc r11d
    jmp .blob_loop
.blob_take_byte:
    movzx edx, byte [rdi]
    xor rax, rdx                        ; FNV-1a: hash ^= byte
    imul rax, rcx                       ; hash *= prime
    inc rdi
    inc r10
    jmp .blob_loop
.blob_done:
    ; Suffix the key (8 bytes, LE).
    mov rdx, r8
    call .fold8

    ; Compare against the build-time expected MAC. Mismatch -> fail closed.
    cmp rax, [rel mb_blob_sig_expected]
    jne .mismatch
    mov byte [rel mb_blob_sig_done], 1

    pop r11
    pop r10
    pop r8
    pop rdx
    pop rcx
    pop rax
    pop rsi
    pop rdi
.ret:
    FN_END app_blob_verify_signature
    ret

.mismatch:
    ; The blob the kernel is about to run does not match its build-time MAC:
    ; tampered, corrupted, or truncated. Refuse to continue — same fail-closed
    ; sink as every other integrity violation. Never returns.
    jmp kernel_panic_canary

; .fold8 - fold the 8 LE bytes of rdx into the running FNV hash in rax, prime
; preloaded in rcx. Clobbers rdx (consumed); preserves rcx, r8, and the rest.
.fold8:
    push rdi
    push r9
    mov edi, 8
.fold8_byte:
    movzx r9, dl
    xor rax, r9                         ; FNV-1a: hash ^= byte
    imul rax, rcx                        ; hash *= prime
    shr rdx, 8
    dec edi
    jnz .fold8_byte
    pop r9
    pop rdi
    ret

; ----------------------------------------------------------------------------
; Build-time expected MAC + KASLR sliding-offset exclusion table, behind a
; locator the patch tool scans for. All are emitted as 0 and overwritten by
; tools/build/patch_blob_sig.py, which finds the marker in KERNEL.A.RAW and
; writes FNV-1a(KEY || zeroed-blob || KEY), the count, and the ascending
; blob-relative sliding offsets. The values are constants (identical across ORG
; builds), so they are NOT KASLR fixups. Layout matches APP_BLOB_SIG_MARKER's
; documented format in app_blob_sig.inc.
;
; Lives in .data (the flat-bin build treats .text/.rodata data inits as nobits
; and drops them; .data is genuine emitted, mutable image memory). It is past
; _kernel_text_end so kernel_lockdown_ro does NOT map it read-only — acceptable
; under the threat model: a kernel-write bug able to overwrite this table could
; equally overwrite the verifier or the canary, and a physical attacker is out
; of scope (docs/STATUS.md). The kernel never writes these at runtime.
; ----------------------------------------------------------------------------
section .data
align 8
mb_blob_sig_marker:
    APP_BLOB_SIG_MARKER
mb_blob_sig_expected:    dq 0
mb_blob_sig_fixup_count: dd 0
mb_blob_sig_fixups:      times APP_BLOB_SIG_MAX_FIXUPS dd 0

section .bss
align 8
; Running chain accumulator during measurement.
mb_chain:  resq 1
; One-shot guard so app_blob_verify_signature folds/compares at most once.
mb_blob_sig_done: resb 1
; Final measurement digest — kernel-only, the §9 "kernel-owned location".
; A future sealed attestation syscall reads this; ring-3 never can.
global mb_digest
mb_digest: resq 1
mb_done:   resb 1
