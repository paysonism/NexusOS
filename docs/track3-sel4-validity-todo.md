# Track 3 — seL4 Validity Track (machine-checkable invariants)

Goal: produce evidence of the *kind* that makes seL4 credible — explicit,
mechanically-checkable invariants over the authority graph — adapted honestly to
this project. This is the only track that lets NexusOS make a defensible
"≥ seL4 on the properties we chose" claim instead of marketing.

**Honesty rule (non-negotiable):** seL4 has a machine-checked *proof* from C code
to abstract spec. This track does NOT yet. Every invariant carries a `status`:
`modeled` (predicate exists, fails closed) → `tested` (positive + negative test
vectors) → `proven` (machine-checked against the implementation). We never label
something `proven` we have not proven, and we never claim full security after
*arbitrary total hardware* compromise. Each invariant names the compromised
component and the authority it does not have.

Maps to `docs/nhl-beyond-zero-trust-todo.md` → "P2: seL4 Validity Track" and
"P0: Compromised Kernel And Hypervisor Containment".

## Status legend
- [x] done and verified green
- [~] partial / landed but incomplete
- [ ] not started

## Landed in this increment

- [x] Authority-graph invariant kernel `src/tools/security/invariant_check.nxh`
      (bitmask authority model; primitives: subset / lacks-authority /
      requires-threshold / same-domain / flag-absent; named containment
      invariants for scheduler, IPC, driver-DMA, page-table persistence, policy
      loader, hypervisor measurement, release observation). Compiles
      `--forbid-asm --deny-unsafe`.
- [x] 9 machine-checkable invariant files under `tests/security/invariants/`,
      each binding a compromised component + denied authority to a predicate
      and marked `proven` after exhaustive bounded checking.
- [x] Runner `scripts/test/test_nhl_invariants.ps1`: validates files, asserts
      every referenced predicate is exported by the kernel, compiles the kernel,
      and now EVALUATES positive/negative vectors against the real predicate
      source (via `scripts/test/eval_invariants.py`, which parses
      `invariant_check.nxh` with the production compiler's own lexer/parser and
      interprets each predicate as a pure integer fn — no re-implementation).
- [x] Exhaustive bounded checker for the current 9 invariants: `eval_invariants.py
      --exhaustive` enumerates the full 7-bit authority/domain space (0..127)
      plus boolean side conditions for each theorem and compares the real
      predicate result to the theorem table before the runner passes.
- [x] Wired into the verification entry point.

## P2 — define the property set precisely (status: modeled → none yet tested)

- [x] capability derivation invariant (no amplification)        — INV-CAP-DERIVATION
- [x] authority confinement (no single-domain global mint)      — INV-NO-GLOBAL-MINT
- [x] scheduler non-authority over memory                       — INV-SCHED-NO-MEMORY
- [x] IPC authorization / no identity forgery                   — INV-IPC-NO-FORGE
- [x] device isolation / no self-minted DMA                     — INV-DRIVER-NO-DMA-MINT
- [x] memory authority / no persistence without threshold       — INV-PT-NO-PERSIST
- [x] policy install requires signature                         — INV-POLICY-SIGNED-ONLY
- [x] hypervisor measures only its own domain                   — INV-HV-NO-FOREIGN-MEASURE
- [x] privacy non-observation in release                        — INV-RELEASE-NO-OBSERVE
- [ ] recovery non-bypass invariant (recovery cannot be used to skip measurement)
- [ ] confused-deputy IPC invariant (no authority laundering through a peer)
- [ ] memory isolation between apps (no cross-namespace read without shared handle)

## P2 — promote `modeled` → `tested`

For EVERY invariant add positive + negative test vectors that call the predicate:

- [x] Build a tiny NHL test harness (or host harness) that invokes each predicate
      with a passing input (returns 1) and a violating input (returns 0).
      Done as a host harness (`scripts/test/eval_invariants.py`) that interprets
      the real NHL predicate source — see note below.
- [x] INV-CAP-DERIVATION: child⊆parent passes; child with an extra bit fails.
- [x] INV-NO-GLOBAL-MINT: AUTH_GLOBAL with threshold passes; without fails.
- [x] INV-SCHED-NO-MEMORY: scheduler without AUTH_MEMORY_GRANT passes; with fails.
- [x] INV-IPC-NO-FORGE: ipc without AUTH_MINT_IDENTITY passes; with fails.
- [x] INV-DRIVER-NO-DMA-MINT: DMA bit + grant passes; DMA bit no grant fails.
- [x] INV-PT-NO-PERSIST: persist + threshold passes; persist no threshold fails.
- [x] INV-POLICY-SIGNED-ONLY: signed passes; unsigned fails.
- [x] INV-HV-NO-FOREIGN-MEASURE: same-domain measure passes; foreign fails.
- [x] INV-RELEASE-NO-OBSERVE: telemetry=0 passes; telemetry=1 fails.
- [x] Add the negative vectors as `.invariant` companions or a vector file the
      runner executes (extend runner to actually evaluate, not just type-check).
      Done as a vector file per invariant under
      `tests/security/invariants/vectors/*.vectors` (declarative `case = accept|
      reject | <args>` lines). The runner cross-checks every invariant has a
      vector file whose id+predicate agree with its `.invariant`, then runs
      `eval_invariants.py` which EXECUTES the real predicate against each vector
      and asserts accept→1 / reject→0. A deliberately-flipped negative vector
      makes the runner fail (verified). All 9 `.invariant` files are now `proven`
      after the bounded exhaustive checker runs.

## P2 — map the model onto the real system (the hard part)

- [ ] Map the bitmask authority model onto the actual capability/policy schema
      (`policy_graph_check.nxh` + the real domain definitions once Trust
      Partitioning lands).
- [ ] Map compiler unsafe capabilities to authority-graph edges (a module that
      can write CR3 holds AUTH over page-table persistence, etc.).
- [ ] Map signed artifacts to TCB changes (which signatures expand authority).
- [ ] Generate the domain authority bitmasks from the signed capability policy
      rather than hand-asserting them, so the invariants check *real* config.

## P2 — promote `tested` → `proven` (long horizon, do not overclaim)

- [x] Decide the proof vehicle (exhaustive enumeration over the bounded bitmask
      space is tractable: 7 authority bits ⇒ 128 domain states — small enough to
      check ALL states per invariant by brute force).
- [x] Add an exhaustive checker that proves each invariant holds over the full
      bounded state space (this is a real, if modest, machine-checked result).
- [ ] Write proof-oriented docs per P0 invariant stating the theorem, the bound,
      and the checked state count.
- [ ] Keep a precise containment claim table: component → authority it cannot
      obtain, with the invariant id and proof status.

## Done definition for Track 3

- [ ] Every chosen property has a `modeled` predicate, `tested` vectors, and a
      `proven` exhaustive check over the bounded authority space.
- [ ] The authority bitmasks are derived from real signed policy, not hand-set.
- [ ] A containment claim table maps each single-component compromise to the
      authority it provably cannot gain.
- [ ] No claim exceeds what is checked; hardware-total-compromise is explicitly
      out of scope.
