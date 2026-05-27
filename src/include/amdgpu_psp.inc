; ============================================================================
; amdgpu_psp.inc - PSP GFX command interface constants
; ----------------------------------------------------------------------------
; Source of truth:
;   Linux drivers/gpu/drm/amd/amdgpu/psp_gfx_if.h
;   Linux drivers/gpu/drm/amd/amdgpu/amdgpu_psp.h
;
; PSP GFX commands are submitted through the KM/GPCOM ring after SOS is alive.
; This is distinct from the bootloader C2PMSG_33/35/36 protocol used to load
; SOS itself. On Strix APUs ABL has already started SOS, so Wave 3 uses the
; GPCOM path.
; ============================================================================

%ifndef AMDGPU_PSP_INC
%define AMDGPU_PSP_INC

; --- Control register commands -------------------------------------------
PSP_GFX_CTRL_INIT_GPCOM_RING equ 0x00020000
PSP_GFX_CTRL_CONSUME_CMD     equ 0x00090000
PSP_GFX_FLAG_RESPONSE        equ 0x80000000
PSP_GFX_FLAG_MASK            equ 0x80000000
PSP_RING_TYPE_KM             equ 2

; --- Ring command IDs ------------------------------------------------------
PSP_GFX_CMD_BUF_VERSION      equ 1
PSP_GFX_CMD_RESP_SIZE        equ 1024
PSP_GFX_RB_FRAME_SIZE        equ 64

PSP_GFX_CMD_SETUP_TMR        equ 0x00000005
PSP_GFX_CMD_LOAD_IP_FW       equ 0x00000006

; --- Firmware type IDs for LOAD_IP_FW -------------------------------------
; Do not use the older hand-written bring-up notes here: upstream values are:
; CP_ME=1, CP_PFP=2, CP_MEC=4, RLC_G=8.
PSP_GFX_FW_TYPE_CP_ME        equ 1
PSP_GFX_FW_TYPE_CP_PFP       equ 2
PSP_GFX_FW_TYPE_CP_MEC       equ 4
PSP_GFX_FW_TYPE_RLC_G        equ 8

; --- Extended autoload (psp_gfx_uc_info) FW type IDs ----------------------
; Source: drivers/gpu/drm/amd/amdgpu/psp_gfx_if.h enum psp_gfx_fw_type
; The autoload TOC uses these IDs (not the LOAD_IP_FW subset above). Each
; psp_gfx_uc_info entry is 16 bytes: id (u32), offset_in_buf (u32),
; size (u32), reserved (u32). Entries with id=0 terminate the table.
PSP_GFX_FW_TYPE_RLC_GPM_MEM           equ 18  ; RLC restore-list GPM
PSP_GFX_FW_TYPE_RLC_SRM_MEM           equ 19  ; RLC restore-list SRM
PSP_GFX_FW_TYPE_RLC_IRAM              equ 20
PSP_GFX_FW_TYPE_RLC_DRAM_BOOT         equ 21
PSP_GFX_FW_TYPE_GLOBAL_TAP_DELAYS     equ 22
PSP_GFX_FW_TYPE_SE0_TAP_DELAYS        equ 23
PSP_GFX_FW_TYPE_SE1_TAP_DELAYS        equ 24
PSP_GFX_FW_TYPE_CP_MES                equ 36
PSP_GFX_FW_TYPE_MES_STACK             equ 37
PSP_GFX_FW_TYPE_CP_MES_KIQ            equ 38
PSP_GFX_FW_TYPE_MES_KIQ_STACK         equ 39
PSP_GFX_FW_TYPE_IMU_I                 equ 40
PSP_GFX_FW_TYPE_IMU_D                 equ 41
PSP_GFX_FW_TYPE_SDMA0_UCODE           equ 42
PSP_GFX_FW_TYPE_SDMA1_UCODE           equ 43

; psp_gfx_uc_info layout (16 bytes per entry)
PSP_UC_INFO_ID                        equ 0
PSP_UC_INFO_OFFSET                    equ 4
PSP_UC_INFO_SIZE                      equ 8
PSP_UC_INFO_RESERVED                  equ 12
PSP_UC_INFO_STRIDE                    equ 16

; --- struct psp_gfx_cmd_resp offsets --------------------------------------
PSP_CMD_BUF_SIZE             equ 0
PSP_CMD_BUF_VERSION          equ 4
PSP_CMD_ID                   equ 8
PSP_CMD_RESP_BUF_ADDR_LO     equ 12
PSP_CMD_RESP_BUF_ADDR_HI     equ 16
PSP_CMD_RESP_OFFSET          equ 20
PSP_CMD_RESP_BUF_SIZE        equ 24
PSP_CMD_PAYLOAD              equ 28
PSP_CMD_RESP                 equ 864
PSP_CMD_RESP_STATUS          equ PSP_CMD_RESP + 0
PSP_CMD_RESP_FW_ADDR_LO      equ PSP_CMD_RESP + 8
PSP_CMD_RESP_FW_ADDR_HI      equ PSP_CMD_RESP + 12
PSP_CMD_RESP_TMR_SIZE        equ PSP_CMD_RESP + 16

; --- SETUP_TMR payload offsets --------------------------------------------
PSP_TMR_BUF_ADDR_LO          equ PSP_CMD_PAYLOAD + 0
PSP_TMR_BUF_ADDR_HI          equ PSP_CMD_PAYLOAD + 4
PSP_TMR_BUF_SIZE             equ PSP_CMD_PAYLOAD + 8
PSP_TMR_FLAGS                equ PSP_CMD_PAYLOAD + 12
PSP_TMR_SYS_ADDR_LO          equ PSP_CMD_PAYLOAD + 16
PSP_TMR_SYS_ADDR_HI          equ PSP_CMD_PAYLOAD + 20

; --- LOAD_IP_FW payload offsets -------------------------------------------
PSP_IP_FW_ADDR_LO            equ PSP_CMD_PAYLOAD + 0
PSP_IP_FW_ADDR_HI            equ PSP_CMD_PAYLOAD + 4
PSP_IP_FW_SIZE               equ PSP_CMD_PAYLOAD + 8
PSP_IP_FW_TYPE               equ PSP_CMD_PAYLOAD + 12

; --- struct psp_gfx_rb_frame offsets --------------------------------------
PSP_FRAME_CMD_ADDR_LO        equ 0
PSP_FRAME_CMD_ADDR_HI        equ 4
PSP_FRAME_CMD_SIZE           equ 8
PSP_FRAME_FENCE_ADDR_LO      equ 12
PSP_FRAME_FENCE_ADDR_HI      equ 16
PSP_FRAME_FENCE_VALUE        equ 20
PSP_FRAME_VMID               equ 32

%endif ; AMDGPU_PSP_INC
