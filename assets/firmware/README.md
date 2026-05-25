# DMCUB firmware blobs

These are the AMD DMCUB (Display MicroController Unit B) firmware images
from the upstream `linux-firmware` repository, mirrored verbatim. NexusOS
loads them at boot to drive AMD GPU display features (panel control,
brightness, IPS power management, etc.).

Source: <https://gitlab.com/kernel-firmware/linux-firmware/-/tree/main/amdgpu>

License: redistributable per the linux-firmware license terms (see
upstream `WHENCE` file for the AMD ucode entry).

| File on FAT (8.3) | Original name              | Target hardware                  |
|-------------------|----------------------------|----------------------------------|
| DCN35DMC.BIN      | `dcn_3_5_dmcub.bin`        | DCN 3.5 — Strix Point, Phoenix2  |
| DCN314.BIN        | `dcn_3_1_4_dmcub.bin`      | DCN 3.1.4 — Phoenix1             |

Layout (per `dmcub_firmware_header_v1_0` in amdgpu_ucode.h):
- 0x00..0x28: common firmware header (size, version, ucode offset, crc)
- 0x28..0x30: dmcub fields (inst_const_bytes, bss_data_bytes)
- `ucode_off..ucode_off+0x100`: PSP header (skip)
- After PSP: instruction-const region (firmware code + read-only data)
- Last 0x100 of inst_const: PSP footer (skip)
- 64-byte `dmub_fw_meta_info` lives in the last 16 bytes of the
  scannable region — search at `(size - 0x100 - i - 64)` for i in 0..16
- Magic = `0x444D5542` ("DMUB" little-endian)

Update by re-downloading from upstream when new ucode versions are
released. Do not modify in place.
