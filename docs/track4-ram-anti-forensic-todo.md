# Track 4 — RAM-Only / Anti-Forensic Memory

Goal: NexusOS runs entirely from RAM (amnesiac — nothing survives power-off) and
reduces what a memory dump can reveal to the smallest possible, clearly-bounded
residual. Driven by the requirement: "make it RAM-only for now, where if a RAM
dump was taken nothing would be readable or reversible."

## SCOPE & HONESTY RULE (refined — read before claiming anything)

Separate **what is stored in DRAM** from **what is transiently on-die**:

- **Stored bytes in DRAM CAN be protected.** Data at rest in RAM — FS cache, app
  blobs, idle slot arenas, kernel secrets — can be kept encrypted/whitened *in
  software* (Part B). With **hardware full-memory encryption** (Intel TME / AMD
  SME, Part C) the memory controller encrypts *all* DRAM traffic, so even stored
  `.text` and page tables are ciphertext in the DIMMs — a cold-boot / physical-
  DIMM / DMA-of-DRAM capture yields AES-XTS ciphertext, not data.
- **On-die transient state is the only irreducible plaintext.** Plaintext exists
  only inside the CPU package — caches, registers, the micro-op actually
  executing, and (in pure software, without TME/SME) the single granule currently
  decrypted for use. A dump of *physical DRAM* under TME/SME does not contain it;
  only an attacker who reads on-die state (JTAG, a debug exploit running on the
  same CPU, sustained single-step) sees it, and that attacker is out of scope.

So the earlier "impossible in software" overstated it: software protects stored
data; hardware FME extends that to literally all of DRAM including instructions.
The residual is on-die transient state, not "the working set sitting in RAM."

**The real objective is not perfect opacity — it is that a captured dump cannot
be reversed into ELEVATION.** Even if a dump leaks files, the qrng seed, the
canary, or `l3_slot_key[]`, that disclosure must NOT compose into a privilege
gain — blocked independently by ≥8 mechanisms (Part D). This is the
beyond-zero-trust thesis applied to memory disclosure: no single leaked secret,
and no small set of them, is sufficient. We never claim more than the `pmemsave`
test and the Part D matrix actually demonstrate.

## THREAT-MODEL EXPANSION (deliberate)

The original model put a physical attacker with the boot medium / a DRAM debugger
fully OUT of scope. This track opts into a **best-effort defense against a
one-shot snapshot attacker** (a single RAM dump / cold-boot image / DMA capture),
while a **sustained** attacker who can repeatedly read DRAM or single-step the CPU
remains out of scope (they can read the working set as it is decrypted). Update
`docs/STATUS.md` §9 to record this refinement precisely; do not overclaim.

## Status legend
- [x] done and verified  [~] partial  [ ] not started

## Part A — RAM-Only / Amnesiac Execution (achievable)

- [ ] No runtime writes to persistent storage: ESP / DATA.IMG / APPS.BIN are
      read-only after load, or served from a RAM-backed image; runtime mutable
      state lives only in RAM.
- [ ] Nothing persists across power-off by construction (no swap, no hibernation,
      no scratch files) — assert this rather than assume it.
- [ ] Wipe-on-shutdown: zero all key material + every app-slot arena (and ideally
      all of usable DRAM) on a clean exit/reset path.
- [ ] Wipe-on-panic: the existing `kernel_panic_canary` / lockdown path zeroes
      secrets before halting, so a crash-then-dump cannot harvest them.
- [ ] Wipe-on-tamper: zero secrets on a detected intrusion (nk-monitor #PF,
      cap-HMAC tamper, code-range mismatch) before reporting.

## Part B — Anti-Forensic Memory Hardening (best-effort; residual documented)

- [ ] Per-boot ephemeral memory key: one RDTSC^RDRAND draw (same source as
      `kernel_canary` / `l3_boot_nonce`), kernel-only, never copied into ring-3.
- [ ] Encrypt-at-rest-in-RAM: keep app blobs, the FAT16 cache, and NON-ACTIVE
      slot arenas encrypted under that key; decrypt the smallest necessary granule
      into a small working window on demand, then re-encrypt / zeroize.
- [ ] Hold the ephemeral key only in registers or a single kernel page that is
      itself the FIRST thing scrubbed on any teardown/panic.
- [ ] Whiten kernel secrets at rest: store `kernel_canary`, `l3_slot_key[]`, the
      blob-signing key XOR-masked; unmask only into a register at point of use.
- [ ] Minimize plaintext residency: smallest granule, shortest lifetime; no
      secret left in the framebuffer / scrollback / serial log longer than needed.
- [ ] Poison freed memory: fill freed pages with a pattern (extends the existing
      slot-recycle `rep stosq` wipe) so stale secrets never linger.
- [ ] Rolling re-key of the in-RAM encryption so a dump's usable plaintext window
      is time-bounded.
- [ ] Defeat structure fingerprinting: pad + encrypt at-rest regions so a dump
      cannot pattern-scan for known kernel structures.
- [ ] HARD LIMIT (document in code + STATUS.md, do not pretend otherwise): the
      executing `.text`, live page tables, active-slot working set, and current
      register/stack frame are plaintext at dump time. Mitigation reduces the
      readable surface to the live set, not to nothing.

## Part C — Hardware Full-Memory Encryption (opportunistic: detect + enable)

Transparent, memory-controller AES that makes *all* DRAM ciphertext at the DIMM —
the only thing that closes the cold-boot / physical-DIMM / DMA-of-DRAM gap for the
executing-code-in-DRAM and page-table residual that software alone cannot. Treat
exactly like the existing CET / SMAP / KPTI scaffolds: **detection always
compiled, enable behind a build gate, hard no-op (and clean boot) on CPUs/VMs
without it, status exposed via SYS_SYSINFO** (200..240 security-status range).

Two families — bare-metal FME applies to NexusOS directly; the confidential-VM
TEEs apply only if NexusOS runs as a guest or hosts VMs.

### Bare-metal full-memory encryption (directly applicable)
- [x] **Intel TME** detect: `CPUID.7.0.ECX[13]` (TME) enumerates MSRs
      `IA32_TME_CAPABILITY` (0x981) and `IA32_TME_ACTIVATE` (0x982); read
      `IA32_TME_ACTIVATE` bit 1 (ENABLED) / bit 0 (LOCKED) and `KEYID_BITS`
      (35:32). NOTE: TME is normally turned on + LOCKED by BIOS/firmware before
      the OS runs — so for TME the OS role is **detect + report + assert it is on**
      (and warn if a "secure" boot finds it off), not enable. AES-XTS-128, key
      from the CPU hardware RNG, never exposed to software.
- [~] **Intel TME-MK (MKTME)** detect: per-KeyID encryption via physical-address
      key-id bits — future per-domain/per-slot key separation (maps onto the
      per-slot key model, §10). Detect the KeyID count from `IA32_TME_ACTIVATE`.
- [~] **AMD SME** detect: `CPUID 0x8000001F` EAX bit 0 (SME), C-bit position in
      EBX[5:0]; enable bit is `MSR_AMD64_SYSCFG` (0xC0010010) bit 23. Unlike TME,
      SME lets the OS mark individual pages encrypted via the **C-bit** in the page
      tables once firmware enables SYSCFG[23] — so NexusOS can *opportunistically*
      set the C-bit on the highest-value pages (kernel secrets, slot arenas, FS
      cache) and let the memory controller encrypt them transparently.
- [ ] **AMD SME-MK / per-page ASID** detect for future per-slot keys.
- [x] Report all of the above through SYS_SYSINFO so the Settings security tab
      shows "RAM encryption: TME on / SME pages / none (software-only)".

  _2026-06-04 scaffold_: `src/tools/security/fme_memory_encryption_check.nxh`
  defines the TME/SME/SEV CPUID/MSR constants, pure predicates, MKTME KeyID
  extraction, and SECST-compatible status mapping, and is compiled by the NHL
  security guard with pass/fail fixtures. Live kernel CPUID/MSR reads now publish
  RAM-encryption and confidential-guest rows through SYS_SYSINFO/Settings. SME
  page-table C-bit use is still pending.

### Confidential-VM TEEs (only if NexusOS runs as guest / hosts VMs)
- [ ] **AMD SEV / SEV-ES / SEV-SNP** detect: `CPUID 0x8000001F` EAX bit 1 (SEV) /
      bit 4 (SEV-SNP); active via `MSR_AMD64_SEV` (0xC0010131) bit 0; SNP RMP via
      `RMP_BASE`/`RMP_END` (0xC0010132/3). Relevant if NexusOS is ever run *inside*
      a confidential VM (guest memory + register state encrypted from the host).
- [ ] **Intel TDX** detect (trust-domain guest). Same "only as a guest" caveat.
- [ ] Decide + document whether NexusOS targets being a confidential **guest**
      (gets SEV-SNP/TDX protection for free from the host) — likely the cheapest
      path to true whole-memory opacity on cloud hardware.

### Honest caveats for Part C
- [ ] Document: **QEMU TCG does not emulate TME/SME memory-controller crypto** —
      guest DRAM stays plaintext on the host, so the `pmemsave` test below
      validates only the *software* at-rest layer (Part B). Part C is verifiable
      only on real silicon (or KVM+SEV). Do not claim FME works from a TCG boot.
- [ ] Document: TME/SME defeat *passive DRAM capture*; they do NOT defend against
      an attacker executing on the same CPU (the memory controller decrypts for
      any on-die access) — that is the §1–§12 ring-3 containment job, i.e. Part D.

## Part D — A Leaked Dump Must NOT Compose Into Elevation (≥8 independent reasons)

The load-bearing requirement. Assume an attacker fully reverses a dump and
recovers the qrng seed, `kernel_canary`, `l3_slot_key[]`, the blob-signing key,
and all file contents. Elevation in a *fresh* boot must still fail, independently,
for many reasons — so no single (or small set of) leaked secret is sufficient.
Audit and make each a tested barrier:

- [ ] **(1) Per-boot ephemeral secrets.** `kernel_canary`, `l3_boot_nonce`,
      `l3_slot_key[]`, and the Part B/C memory key are RDTSC^RDRAND *per boot* — a
      dump from boot A is worthless against boot B. (Verify the rotation.)
- [ ] **(2) Per-slot key separation.** `l3_slot_key[]` is per-slot AND per-boot;
      one slot's key never widens another. (§10.)
- [ ] **(3) Heterogeneous syscall numbering.** Per-launch permutation; a static
      exploit blob built from the dump lands on the wrong handler next launch.
      (§12.)
- [ ] **(4) Per-slot code ASLR.** Leaked gadget addresses don't transfer to the
      next slot/boot. (§1.)
- [ ] **(5) Code-pointer integrity tags.** Callback tags are bound to the live
      window VA *and* the per-boot canary — a dumped tag won't verify after boot.
      (§1 CPI.)
- [ ] **(6) Cap-mask HMAC + time-of-check auth.** A forged/widened mask needs the
      fresh-boot canary, slot id, and domain constant and is re-stamped on every
      legit write — a stale dumped mask fails closed → CANARY panic. (§4.)
- [ ] **(7) W^X + nested-kernel page-table monitor.** No secret lets ring-3 make a
      page W+X or remap a slot supervisor; the PTE write #PFs. (§1, nk_monitor.)
- [ ] **(8) Measured boot + blob MAC, fail-closed.** A modified image/blob halts
      before any ring-3 entry, so a dump-informed tamper can't be booted. (§9.)
- [ ] **(9) KPTI / SMAP / SMEP.** Kernel memory not speculatively reachable from
      ring-3; user pointers gated. (§3.)
- [ ] **(10) Anomaly detector + strike teardown.** A slot probing high-risk
      syscalls is killed before it can iterate a leaked-secret attack. (§11/§12.)
- [ ] **(11) Default-deny caps + per-syscall allowlist.** A hijacked slot is
      confined to its manifest's exact call set. (§2/§4.)
- [ ] **(12) Kernel shadow stack + guard pages.** ROP into the kernel fails
      closed. (§1.)
- [ ] Write the **exfiltration→elevation matrix**: for each recoverable artifact
      (qrng seed, canary, slot key, blob key, file bytes, gadget addrs), list
      which barriers above independently defeat its use, and add a negative test
      that *plants the dumped secret into a fresh boot and proves elevation still
      fails*. This is the concrete proof of "leak ≠ elevation."

## Verification (make the goal measurable, not aspirational)

- [ ] RAM-dump test: at runtime take a real dump (QEMU `pmemsave` /
      `dump-guest-memory`) and grep the image for known secrets — `kernel_canary`,
      a known key, plaintext file contents, a planted at-rest sentinel. Assert
      NONE appear except the documented live-working-set residual.
- [ ] Negative test: a secret planted in an at-rest (encrypted) region must NOT
      appear in the dump; the same secret while actively in use MAY (and the test
      documents exactly which residual it is).
- [ ] Amnesia test: power-cycle and confirm no secret/state is recoverable from
      the (RAM-backed) medium.
- [ ] Perf gate: boot + run clean with at-rest encryption enabled; bound the
      decrypt-on-demand overhead on the FS/app-launch paths.

## Done definition for Track 4

- [ ] The OS runs RAM-only and is amnesiac across power-off.
- [ ] A single RAM dump yields no key material, no full FS, and no full slot
      memory — only the documented on-die/live-granule residual (Part A+B).
- [ ] Hardware FME (TME/SME) is detected, reported, and opportunistically used
      where present, closing the cold-boot/DRAM gap on real silicon (Part C).
- [ ] A planted-leak negative test proves a fully-reversed dump still cannot
      elevate on a fresh boot — the exfiltration→elevation matrix holds (Part D).
- [ ] The irreducible plaintext residual is named precisely in STATUS.md and
      proven bounded by the `pmemsave` test, with no claim exceeding it.

## Follow-up: legacy v0 app blobs are W+X (security review finding)

A v0 (no-manifest) app's entire blob is mapped both Writable and eXecutable by
`l3_apply_wx_policy` (`src/kernel/proc/usermode_paging.inc`, the `r10d==0`
legacy-permissive path). Any in-blob memory-corruption bug therefore composes
straight into a write-then-execute primitive — it does not by itself grant ring-0,
but it removes the W^X speed bump every other layer assumes.

This is **not closeable at the page-table layer**: `nxhc` emits app blobs in embed
mode with no section directives, so code, `state` data and inline strings share the
same pages. Forcing R+X faults legitimate data writes; forcing W+NX faults
execution.

- [ ] Compiler: in embed/app mode, page-align and split the blob into a
      `[code R+X][data/strings W+NX]` layout and emit the code/data boundary.
- [ ] Loader: auto-install a real v1 W^X manifest from that boundary at slot
      install (the `SYS_WX_INSTALL_MANIFEST` path and the W^X walk already exist),
      so v0/permissive becomes unreachable for first-party apps.
- [ ] Verify: a v0 app that writes into its own code window after the change is
      rejected/faults; a normal app still boots and draws.
