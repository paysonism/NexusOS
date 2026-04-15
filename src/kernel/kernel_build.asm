; ============================================================================
; NexusOS v3.0 - Monolithic Kernel Build Wrapper
; Combines all kernel components into a single binary
; ============================================================================
[bits 64]
[org 0x100000]

; Define macros to ignore extern/global directives in included files
; Using 1-* allows the macro to ignore any number of arguments (comma separated)
%unmacro extern 1-*
%macro extern 1-*
%endmacro

%unmacro global 1-*
%macro global 1-*
%endmacro

; --- Core Kernel Entry Point (MUST BE FIRST) ---
section .text
%include "src/kernel/entry.asm"
section .text
%include "src/kernel/main.asm"
section .text
%include "src/kernel/idt.asm"
section .text
%include "src/kernel/isr.asm"
section .text
%include "src/kernel/memory.asm"
section .text
%include "src/kernel/pic.asm"
section .text
%include "src/kernel/pit.asm"
section .text
%include "src/kernel/tss.asm"
section .text
%include "src/boot/gdt.asm"
section .text
%include "src/kernel/usermode.asm"
section .text
%include "src/kernel/process.asm"
section .text
%include "src/kernel/syscall.asm"

; --- ACPI & APIC Core ---
section .text
%include "src/kernel/rsdp.asm"
section .text
%include "src/kernel/acpi.asm"
section .text
%include "src/kernel/madt.asm"
section .text
%include "src/kernel/aml_parser.asm"
section .text
%include "src/kernel/apic.asm"
section .text
%include "src/kernel/ioapic.asm"

; --- Drivers ---
section .text
%include "src/drivers/acpi_pci.asm"
section .text
%include "src/drivers/acpi_ec.asm"
section .text
%include "src/drivers/display.asm"
section .text
%include "src/drivers/keyboard.asm"
section .text
%include "src/drivers/mouse.asm"
section .text
%include "src/drivers/ata.asm"
section .text
%include "src/drivers/pci.asm"
section .text
%include "src/drivers/xhci.asm"
section .text
%include "src/drivers/usb_hid.asm"
section .text
%include "src/drivers/spi.asm"
section .text
%include "src/drivers/spi_hid.asm"
section .text
%include "src/drivers/i2c_hid.asm"
section .text
%include "src/drivers/hid_parser.asm"
section .text
%include "src/drivers/battery.asm"

; --- Filesystem ---
section .text
%include "src/kernel/fat16.asm"

; --- GUI System ---
section .text
%include "src/gui/render.asm"
section .text
%include "src/gui/window.asm"
section .text
%include "src/gui/taskbar.asm"
section .text
%include "src/gui/desktop.asm"
section .text
%include "src/gui/cursor.asm"
section .text
%include "src/gui/apps.asm"

; --- Libraries ---
section .text
%include "src/lib/string.asm"
%include "src/lib/font.asm"
%include "src/lib/math.asm"

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
