; ============================================================================
; NexusOS v3.0 - Monolithic Kernel Build Wrapper
; Combines all kernel components into a single binary
; ============================================================================
[bits 64]
[org 0x100000]

; Define macros to ignore extern/global directives in included files
; Using 1-* allows the macro to ignore any number of arguments (comma separated)
%ifmacro extern 1-*
%unmacro extern 1-*
%endif
%macro extern 1-*
%endmacro

%ifmacro global 1-*
%unmacro global 1-*
%endif
%macro global 1-*
%endmacro

%include "build/sig_hashes.inc"

; --- Core Kernel Entry Point (MUST BE FIRST) ---
section .text
%include "src/kernel/core/entry.asm"
section .text
%include "src/kernel/core/main.asm"
section .text
%include "src/kernel/core/idt.asm"
section .text
%include "src/kernel/core/isr.asm"
%ifdef ENABLE_TRACE
section .text
%include "src/kernel/core/trace.asm"
%endif
section .text
%include "src/kernel/core/memory.asm"
section .text
%include "src/kernel/core/pic.asm"
section .text
%include "src/kernel/core/pit.asm"
section .text
%include "src/kernel/core/tss.asm"
section .text
%include "src/kernel/core/perfdiag.asm"
section .text
%include "src/boot/gdt.asm"
section .text
%include "src/kernel/proc/usermode.asm"
section .text
%include "src/kernel/proc/process.asm"
section .text
%include "src/kernel/proc/syscall.asm"
section .text
%include "src/kernel/proc/workqueue.asm"

; --- ACPI & APIC Core ---
section .text
%include "src/kernel/arch/rsdp.asm"
section .text
%include "src/kernel/arch/acpi.asm"
section .text
%include "src/kernel/arch/madt.asm"
section .text
%include "src/kernel/arch/aml_parser.asm"
section .text
%include "src/kernel/arch/apic.asm"
section .text
%include "src/kernel/arch/ioapic.asm"

; --- Drivers ---
section .text
%include "src/kernel/drivers/acpi_pci.asm"
section .text
%include "src/kernel/drivers/acpi_ec.asm"
section .text
%include "src/kernel/drivers/display.asm"
section .text
%include "src/kernel/drivers/keyboard.asm"
section .text
%include "src/kernel/drivers/mouse.asm"
section .text
%include "src/kernel/drivers/ata.asm"
section .text
%include "src/kernel/drivers/pci.asm"
section .text
%include "src/kernel/drivers/xhci.asm"
section .text
%include "src/kernel/drivers/usb_hid.asm"
section .text
%include "src/kernel/drivers/spi.asm"
section .text
%include "src/kernel/drivers/spi_hid.asm"
section .text
%include "src/kernel/drivers/i2c_hid.asm"
section .text
%include "src/kernel/drivers/hid_parser.asm"
section .text
%include "src/kernel/drivers/battery.asm"

; --- Filesystem ---
section .text
%include "src/kernel/fs/fat16.asm"

; --- GUI System ---
section .text
%include "src/kernel/gui/resources.asm"
section .text
%include "src/kernel/gui/render.asm"
section .text
%include "src/kernel/gui/window.asm"
section .text
%include "src/kernel/gui/taskbar.asm"
section .text
%include "src/kernel/gui/desktop.asm"
section .text
%include "src/kernel/gui/cursor.asm"
section .text
%include "src/kernel/gui/boot_anim.asm"

; --- Built-in User Apps ---
section .text
%include "src/user/apps.asm"

; --- Libraries ---
section .text
%include "src/kernel/lib/string.asm"
%include "src/kernel/lib/font.asm"
%include "src/kernel/lib/math.asm"
%include "src/kernel/lib/xml.asm"

; --- Generated Signature Registry ---
%ifdef ENABLE_SIG_SECTION
%include "build/sig_registry.inc"
%endif

; --- Helper Wrappers ---
fn_memcpy_wrapper:
    jmp fn_memcpy
fn_memset_wrapper:
    jmp fn_memset
fn_strlen_wrapper:
    jmp fn_strlen

; Resolve symbols used by other modules
memcpy equ fn_memcpy
memset equ fn_memset
strlen equ fn_strlen

; --- BSS Section ---
section .bss
alignb 16
_bss_start:
; NASM aggregates sections, so all .bss from included files will end up here.
_bss_end:
