# TODO / Spec Index — READ THIS FIRST

Single map of every TODO/spec/roadmap doc so a new session knows **which doc is
authoritative for what** and does not get tripped up by the sprawl. If two docs
disagree, the authority rules below win. Keep this file current when you add or
retire a doc.

_Last reconciled: 2026-06-04._

---

## Authority hierarchy (who wins on a conflict)

1. **`docs/STATUS.md`** — formal source of truth for *project status* and the
   *security threat-model / scope boundary* (§9). Nothing overrides STATUS on
   "what is the state" or "what is in/out of scope."
2. **`docs/architecture-defense-in-depth.md`** — canonical *target topology*
   (separation-kernel, the kill-chain defense matrix, the capability-vs-crypto
   rule, opportunistic-hardware-with-software-floor rule). Nothing overrides this
   on "what is the intended architecture."
3. **The four `trackN-*.md` docs** — authoritative for their slice of the
   beyond-zero-trust program, and **more current than the master list** where they
   overlap (the master list lags; trust the track doc).
4. **`docs/nhl-beyond-zero-trust-todo.md`** — the master program checklist
   (includes the newer "Extended Hardening" + "Kill-Chain Defense" + "Hardware
   Memory Encryption" sections). Authoritative only where no track doc covers it.
5. **`docs/security_todo.md`** — the *original* §1–§13 runtime hardening. All
   items LANDED. This is a different (earlier) program from the tracks — see
   "Two security programs" below.

---

## Two security programs (do not confuse them)

- **`security_todo.md` (§1–§13)** = the **landed runtime mitigations** baked into
  today's kernel (W^X, CPI, cap-mask HMAC, nk-monitor, KPTI/SMAP/CET scaffolds,
  heterogeneous syscall numbering, per-slot keys, measured boot + blob MAC, etc.).
  **All `[x]`** and live. It is *done*; treat it as the security baseline, not a
  backlog.
- **`nhl-beyond-zero-trust-todo.md` + `trackN` + `architecture-defense-in-depth.md`**
  = the **newer NHL-only "beyond zero trust" architecture** layered on top
  (signed-everything, threshold, seL4 invariants, RAM-only/anti-forensic,
  user-space drivers + proxies + monitor). This is the *active backlog*.

They are complementary, not duplicates: the tracks build the architecture; the
§1–§13 mitigations are the enforcement primitives that architecture reuses.

---

## Every doc, what it is, and current state

### Status & architecture (truth docs)
| Doc | Authoritative for | State |
|---|---|---|
| `STATUS.md` | project status; threat-model scope (§9, incl. the RAM-dump refinement) | current |
| `architecture-defense-in-depth.md` | target separation-kernel topology + kill-chain matrix | current (2026-06-04) |

### Active backlog — beyond-zero-trust program
| Doc | Scope | State (2026-06-04) |
|---|---|---|
| `nhl-beyond-zero-trust-todo.md` | master checklist + Extended Hardening + Kill-Chain Defense + HW mem-enc | active; master P0/P1 mostly `[ ]`; Extended/Kill-Chain are net-new |
| `track1-repo-enforcement-todo.md` | repo enforcement (no new .asm/.inc, presubmits, CI) | **DONE / green** |
| `track2-signed-everything-todo.md` | signed-artifact envelope + threshold | **checker only** — runtime reader/writer + threshold TODO |
| `track3-sel4-validity-todo.md` | seL4-style authority invariants | 9 invariants **`tested`** (runner executes vectors); `proven`/exhaustive-checker next |
| `track4-ram-anti-forensic-todo.md` | RAM-only/amnesiac + anti-forensic + HW FME (TME/SME) + leak≠elevation | **new, not started**; design + honest scope written |

### Landed baseline
| Doc | Scope | State |
|---|---|---|
| `security_todo.md` | §1–§13 runtime mitigations | **all `[x]` / live**; §5/§7 dispatcher wiring + §12 loader rewrite are now WIRED (2026-06-04) |

### Other backlogs (not part of the security program)
| Doc | Scope | State |
|---|---|---|
| `nexushl-zero-asm-roadmap.md` | zero-asm migration (compiler track + verification) | active; kernel modules zero-asm; boot blocked on codegen |
| `nexushl-boot-conversion.md` | boot module-by-module zero-asm ladder | active; blocked on PE/COFF + UEFI-ABI codegen |
| `maintainability-todo.md` | code maintainability backlog (`src/` only) | draft/working |

### Background / historical (not live checklists)
| Doc | What it is |
|---|---|
| `agent-beyond-zero-trust-security.md` | early vision note for the NHL-only architecture (superseded by the tracks) |
| `agent-nhl-no-asm-audit.md` | read-only audit findings (historical) |
| `reference-index.md` | index of *reference* docs (kernel/syscall/spec), not TODOs |

---

## Single verification entry point

```
powershell -ExecutionPolicy Bypass -File scripts\test\test_nhl_security_guards.ps1
```
Covers: release-privacy + no-asm + legacy inventory + policy-module compile
(`--forbid-asm --deny-unsafe`) + checker fixtures + seL4 invariants (now
vector-evaluated via `scripts\test\eval_invariants.py`).

Build: monolithic `nasm -f bin` on `src/kernel/kernel_build.asm` via
`scripts\build\build_uefi.ps1` (run from repo root). UEFI smoke:
`scripts\test\test_smoke_uefi.ps1`.

---

## GOTCHAS — known false alarms (do not chase)

- **`worktrees/` inventory failures.** `test_nhl_security_guards.ps1` currently
  EXITS 1 with ~400 `[new-legacy-extension] worktrees/...` findings. These are a
  **stray untracked git worktree** (`worktrees/beautiful-yonath-843eca/`), NOT a
  real regression. Only findings whose path is OUTSIDE `worktrees/` matter. Fix
  the noise with `git worktree prune` / gitignore. Verify your own change with:
  filter the output to non-`worktrees/` path-bearing finding lines — zero = clean.
- **`security_todo.md` "SCOPED OUT / DEFERRED" notes are stale.** §5 (snapshot-on-
  open), §7 (net active-slot), and §12 (syscall-perm loader rewrite) were written
  as deferred but are **now wired** (each item carries an `_UPDATE (now LIVE)_`
  note). Do not re-implement them.
- **Master list lags the track docs.** Several `[ ]` items under
  `nhl-beyond-zero-trust-todo.md` "P0: Repository Enforcement" are actually DONE in
  `track1-*.md`. Trust the track doc.
- **QEMU TCG cannot test some features.** Hardware memory encryption (TME/SME),
  CET shadow-stack arming, and KPTI live-mode are no-ops or untestable under TCG.
  `pmemsave`/smoke tests validate only the software layers. Don't claim a
  hardware-gated feature works from a TCG boot.
- **GPU rendering is mostly deprecated.** `STATUS.md` "Active focus: GPU" predates
  the 2026-05-26 deprecation; Tier 2/3 (DCN/GFX11) are retired, only the portable
  Tier 1 survives. The real thrust is zero-asm + the security program.

---

## Current frontier (what to pick up next)

- **Track 2**: in-OS signed-envelope reader + reject-matrix fixtures (turns
  "checker exists" into "system enforces") — the keystone.
- **Track 3**: promote `tested → proven` via the exhaustive 7-bit-space checker.
- **Track 4**: Part A amnesiac/RAM-only increment; Part C TME/SME detection
  scaffold (CET/SMAP/KPTI pattern, status via SYS_SYSINFO); Part D planted-leak
  negative test.
- **Kill-Chain Defense**: biggest lift is moving drivers out of the kernel into
  user-space sandboxed processes — everything else in that section builds on it.
