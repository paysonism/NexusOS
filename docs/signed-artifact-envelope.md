# Signed Artifact Envelope — Canonical Specification (v1)

This is the keystone of the beyond-zero-trust architecture: a single signed
container shared by **boot, kernel, hypervisor, drivers, apps, policies, configs,
updates, recovery bundles, and tests**. Threshold signing, revocation,
anti-rollback, and policy binding all hang off this one envelope. Everything that
the system trusts must arrive inside it.

Policy kernels:
- `src/tools/security/signed_envelope.nxh` — structural contract (this doc).
- `src/tools/security/signed_artifact_check.nxh` — semantic field validity
  (role-for-type, signature window, anti-rollback).
- `src/tools/security/schema_canonical_check.nxh` — canonical scalar encoding and
  bounded nesting.

The envelope is **detached-signature** style: a header + canonical TLV field
region + payload, with the signature block computed over the canonical bytes.

## Byte layout (v1)

| Offset | Size | Field          | Notes                                  |
|--------|------|----------------|----------------------------------------|
| 0      | 4    | magic          | `'N','X','S','E'` (78,88,83,69)        |
| 4      | 2    | schema_version | u16, must be `1`                       |
| 6      | 2    | artifact_type  | u16, `ART_*` (1..9)                    |
| 8      | 2    | target_domain  | u16, `DOMAIN_*` (1..7)                 |
| 10     | 2    | field_count    | u16, `12..64`                          |
| 12     | 2    | header_len     | u16, offset where the TLV region ends and payload begins |
| 14     | ...  | TLV fields     | `field_count` records, ids strictly ascending |
| ...    | ...  | payload        | artifact bytes                         |
| ...    | ...  | signature block| detached threshold signatures          |

All multi-byte scalars are canonical per `schema_canonical_check` (minimal
width). Non-canonical, duplicate, descending, or out-of-bounds encodings fail
closed.

## Mandatory signed fields

Every field below is a TLV record inside the canonical region and is covered by
the signature. The presence bitmask (`FIELDBIT_*` in `signed_envelope.nxh`)
reports which were seen.

Bit | Field              | Why it must be signed
----|--------------------|-----------------------------------------------
0   | TYPE               | A signature for an app must not validate a kernel.
1   | DOMAIN             | Binds the artifact to its security domain.
2   | TARGET_DEVICE      | A device/class binding stops cross-device replay.
3   | HASH               | SHA-256 of the payload.
4   | SCHEMA_VERSION     | Verifier selects the right rules.
5   | SIGNER_ROLE        | A role not authorized for the type is rejected.
6   | VALIDITY           | not-before / not-after window.
7   | MONOTONIC_VERSION  | Downgrade protection.
8   | ROLLBACK_COUNTER   | Anti-rollback counter.
9   | COSIGNER_ROLES     | Required co-signer roles (threshold).
10  | REVOCATION_EPOCH   | Stale-epoch rejection.
11  | BUILD_PROVENANCE   | Reproducible-build provenance hash (release).
12  | POLICY_DEPENDENCY  | Policy hash the artifact was built against (runnable only).

- `REQUIRED_BASE` = bits 0..11 (4095): required for **every** shipped artifact.
- `REQUIRED_RUNNABLE` = bits 0..12 (8191): runnable artifacts
  (BOOT/KERNEL/HYPERVISOR/DRIVER/APP) must additionally bind a policy dependency.

## Verification order (fail closed at each step)

1. `security_envelope_magic_ok` — magic matches.
2. schema_version == 1, artifact_type in range, target_domain in range.
3. `field_count` within `[12,64]`.
4. For each TLV: `security_envelope_field_order_ok` (strictly ascending id ⇒
   canonical + no duplicates) and `security_envelope_offset_ok` (in-bounds, no
   overflow).
5. `security_envelope_required_present` — all required bits for the class present.
6. `security_envelope_accept` — composes 1–5 into one decision.
7. Hand decoded fields to `signed_artifact_check` for semantic validity
   (role-for-type, signature window, anti-rollback).
8. Verify threshold signatures over the canonical bytes (see threshold_check).

Any failure ⇒ reject. There is no "warn and continue" path.

## Non-goals for v1

- Field encryption (the envelope is integrity/authenticity, not confidentiality).
- In-place mutation. Envelopes are immutable; updates ship new envelopes.
- Backward-compatible parsing of unknown critical fields — unknown critical
  fields fail closed by design (`schema_canonical_check`).
