# Track 2 — Signed Everything (Beyond-Zero-Trust P0 keystone)

Goal: every artifact the system trusts arrives inside one canonical **signed
envelope**, and nothing unsigned, malformed, mis-targeted, expired, downgraded,
replayed, or wrong-role is ever accepted. This is what lets NexusOS exceed iOS on
the axis iOS does not cover: *no single key and no single component can mint
trusted state.*

Maps to `docs/nhl-beyond-zero-trust-todo.md` → "P0: Signed Everything",
"P0: Threshold Signing", and parts of "P1: Crypto / Parser / Schema Safety".
Spec: `docs/signed-artifact-envelope.md`.

## Status legend
- [x] done and verified green
- [~] partial / landed but incomplete
- [ ] not started

## Landed in this increment

- [x] Canonical envelope spec (`docs/signed-artifact-envelope.md`, v1).
- [x] Structural policy kernel `src/tools/security/signed_envelope.nxh`:
      magic, schema-version, type/domain range, strict-ascending (canonical +
      dedup) field ordering, in-bounds/no-overflow offsets, required-field
      bitmask per artifact class, composed `security_envelope_accept`.
- [x] Compiles `--target kernel --forbid-asm --deny-unsafe`.
- [x] Pass/fail fixtures + wired into `test_nhl_security_fixtures.ps1`,
      `test_nhl_security_guards.ps1`, and the no-asm module manifest.

## P0 — complete the envelope

- [x] The presence bitmask currently encodes the *mandatory* fields; add the
      `TARGET_DEVICE` semantics to `signed_artifact_check` (device / device-class
      match) so cross-device replay is rejected, not just structurally required.
- [x] Add a canonical-serialization predicate set so the *signed bytes* are
      unambiguous (tie envelope ↔ `schema_canonical_check`): reject non-minimal
      widths, duplicate TLV ids (already via ordering), and trailing garbage.
- [x] Add `security_envelope_payload_region_ok` to assert payload + signature
      block exactly tile `[header_len, total_len]` with no gaps/overlap.
- [x] Add a streaming/bounded verification contract: max envelope size, max
      field_count (have 64), max payload — all checked before allocation.
- [x] Constant-time comparison helper for hash/MAC equality (P1 crypto rule).

## P0 — threshold signing on top of the envelope

- [ ] Define threshold policy per artifact class (boot accept, kernel/hypervisor
      activation, driver, app, policy, config, firmware, recovery, key rotation,
      key revocation) — extend `threshold_check.nxh`.
- [ ] `COSIGNER_ROLES` field must be cross-checked against the class threshold:
      reject if quorum/required roles unmet.
- [ ] Reject duplicate signers, wrong-role signers, threshold downgrade.
- [ ] Quorum change requires BOTH old and new quorum approval.
- [ ] Negative tests: one stolen key cannot authorize; one build server cannot
      release; one update server cannot ship; one recovery key cannot reset
      trust anchors.

## P0 — reject matrix (every one needs a fail fixture)

- [ ] unsigned artifact
- [ ] malformed envelope (bad magic / short / overflow offsets)
- [ ] mismatched artifact type (app signature presented for kernel)
- [ ] wrong target domain
- [ ] wrong target device / device class
- [ ] expired signature window
- [ ] stale revocation epoch
- [ ] replayed artifact (nonce / monotonic counter)
- [ ] downgraded artifact (monotonic version / rollback counter)
- [ ] valid signature from a role not authorized for the type
- [ ] manifest/payload disagreement (hash mismatch)
- [ ] missing required field per class (have: runnable-missing-policy-dep)
- [ ] non-canonical / duplicate / descending field encoding (have: fixture)

## P1 — host integration (the real producers/consumers)

- [ ] Write a memory-safe host *envelope writer* (build-time) that emits v1
      envelopes for build outputs; keep it out of the running OS image.
- [ ] Write the kernel/boot *envelope reader* that decodes TLVs and calls the
      NHL predicates — this is what turns "checker exists" into "system enforces".
- [ ] Bind envelope verification into the boot chain (P1 Boot Chain track).
- [ ] Bind envelope verification into the update path (P1 Update System track).
- [ ] Cache verified immutable artifacts by hash (perf gate).

## P1 — fuzzing & parser safety

- [ ] Fuzz the envelope decoder (malformed TLV, length overflow, deep nesting,
      duplicate/critical-unknown fields, path traversal in bundle names).
- [ ] Differential test: two independent decoders agree on accept/reject.
- [ ] Property test: canonicalize(decode(x)) == x for all accepted envelopes.

## Done definition for Track 2

- [ ] Every trusted artifact is a signed v1 envelope; unsigned input is impossible
      to accept anywhere in boot/kernel/update.
- [ ] Every entry in the reject matrix has a passing negative test.
- [ ] Threshold quorum is enforced from the `COSIGNER_ROLES` field per class.
- [ ] A memory-safe writer produces, and an in-OS reader verifies, real envelopes.
- [ ] No single stolen key authorizes any critical action.
