%ifndef L3_RUNTIME_INC
%define L3_RUNTIME_INC

L3_RT_ENTRY          equ 0
L3_RT_ARG0           equ 8
L3_RT_ARG1           equ 16
L3_RT_ARG2           equ 24
L3_RT_KERNEL_RSP     equ 32
L3_RT_KERNEL_RFLAGS  equ 40
L3_RT_USER_RSP       equ 48
L3_RT_USER_RIP       equ 56
L3_RT_USER_RFLAGS    equ 64
L3_RT_APP_BASE       equ 72
L3_RT_SYSCALL_NUM    equ 80
L3_RT_USER_RDX       equ 88
L3_RT_USER_R8        equ 96
L3_RT_USER_R9        equ 104
L3_RT_USER_R10       equ 112
L3_RT_SLOT           equ 120
L3_RT_SIZE           equ 128

%endif
