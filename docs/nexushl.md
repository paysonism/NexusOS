# NexusHL — Safe Higher-Level Assembly Language

NexusHL (`.nxh`) is a tiny compiled language that targets the existing NexusOS
ring-3 app ABI. It exists so large multi-layer apps can be written, read, and
refactored without hand-tracking registers, while every emitted instruction
stays inside the syscall boundary documented in `docs/syscalls.md`.

The toolchain is entirely host-side. The compiler emits plain NASM that the
existing `build_uefi.ps1` pipeline assembles. There is no runtime, no heap,
no interpreter, no dynamic loader — so there is no new attack surface on the
running kernel.

## Quick start

```
powershell -NoProfile -File build_nxh.ps1     # compile + nasm-verify all .nxh apps
powershell -NoProfile -File run_uefi.ps1      # boot VM
python src/user/nexushl/compiler/nxhdbg.py    # tail serial, highlights [nxhl] lines
```

## File layout

```
src/user/nexushl/
  compiler/
    nxhc.py          # compiler: .nxh -> .asm
    nxhdbg.py        # serial debugger, TCP 127.0.0.1:5555
  lib/
    core.nxh         # syscall numbers, window offsets, colors, keys
  apps/
    hello.nxh        # smoke app, emits [nxhl] markers on every callback
build/nxh/
  <name>.asm         # generated NASM (do not edit)
  <name>.bin         # nasm-verified object (proof of syntactic validity)
```

## Language reference

### Top level
```
use <lib>                              # pulls in a .nxh from src/user/nexushl/lib
app "<Name>" { stack = <N>; }          # app metadata (reserved for future loader)
str <name> = "...";                    # static zero-terminated string in .rodata
const <NAME> = <int>;                  # compile-time integer
extern <symbol>;                       # declare an external NASM symbol
fn <name>(a, b, c) { ... }             # function with up to 6 params
```

### Statements
```
let x = <expr>;                        # new stack-local i64
x = <expr>;                            # assign to an existing local
if <cond> { ... } else { ... }         # else-if chains allowed
while <cond> { ... }                   # break; continue; allowed inside
return [<expr>];                       # early exit
syscall(<num>, <arg>, ...);            # kernel call, up to 6 args
call name(<arg>, ...);                 # raw NASM `call` to an extern
asm "<raw nasm line>";                 # unsafe escape hatch (discouraged)
```

### Expressions
- Integer literals: `123`, `0xFF`
- Booleans: `true`, `false`
- String literal `"..."` evaluates to its address (same as `&name` for a `str`)
- `&name` — address of a `str` declared at top level
- Operators: `+ - * / % & | ^ << >> == != < > <= >= && || !`
- Function-call syntax only on identifiers (`foo(x)`), no raw pointers yet
- Array index `a[i]` reserved for future use

### Callbacks
A `.nxh` app typically exposes the three callback names the window manager
expects. Param names are arbitrary; what matters is their position:

```
fn draw(win)          { ... }          # win = shadow window pointer
fn click(win, x, y)   { ... }          # x,y are client-area mouse coords
fn key(win, k)        { ... }          # k is the translated key value
```

Params are spilled to stack at entry, so you can call `syscall(...)` freely
without worrying about `rdi`/`rsi`/`rdx` being clobbered.

### What NexusHL refuses
- Direct register names (no `mov rax, ...` unless wrapped in `asm "..."`)
- Raw memory dereference (`[rax+8]`, etc.)
- Pointer arithmetic
- Hidden allocation — all storage is either top-level `str`/`const` or stack
- Inline asm without the explicit `asm "..."` block (and each one is a lint)
- Undeclared identifiers

## Safety model

1. **No runtime** — compiler runs on the host only. A malicious `.nxh` cannot
   run without first being assembled into the kernel image you build.
2. **ABI-locked syscalls** — `syscall(n, ...)` is the *only* way to talk to
   the kernel, and the numbers live in `lib/core.nxh` which mirrors
   `src/include/syscall_user.inc`. Change either, change both.
3. **Callee-saved spills** — every param is copied to a stack slot before
   any user code runs, so argument registers are always free for syscalls.
4. **No pointer arithmetic** — strings are opaque addresses; array indexing
   (when added) will emit compile-time bounds checks.
5. **Byte-for-byte reviewable output** — every `.nxh` has a matching
   `.asm` under `build/nxh/` that you can read, diff, and disassemble.

## Compiler internals

`nxhc.py` is a single file: lexer → recursive-descent parser → one-pass
codegen. The only register convention in emitted code:

- Expression result lives in `rax`
- Binary-op RHS lives in `rcx`
- Callee frame uses `rbp`, locals at `[rbp - N]`
- Syscall args are pushed in order, then popped into
  `rdi`, `rsi`, `rdx`, `r10`, `r8`, `r9`
- `rbx` and `r12` are saved at entry (available for future use)

128 bytes of locals per function (16 `let` slots). Bump in `gen_fn` when we
hit that limit.

## Debugging a HL app

1. Instrument with `syscall(SYS_PRINT, &marker_string)` at every branch of
   interest. Prefix markers with `[nxhl]` so `nxhdbg.py --grep '\[nxhl\]'`
   filters them out of the kernel trace.
2. Build + boot: `build_nxh.ps1; build_uefi.ps1; run_uefi.ps1`.
3. Attach the debugger: `python src/user/nexushl/compiler/nxhdbg.py`.
4. Stop the VM: `taskkill /F /IM qemu-system-x86_64.exe`.

## Integration with `apps.asm`

HL apps are **not** auto-linked. To ship a HL-authored app alongside the
kernel today:

1. Compile it: `build_nxh.ps1` produces `build/nxh/<name>.asm`.
2. Copy or `%include` it from a new `src/user/apps/<name>_hl.inc`.
3. Register its `<prefix>_draw` / `<prefix>_click` / `<prefix>_key` labels
   in `src/user/apps/state.inc` next to the existing app entries.
4. Rebuild the kernel.

Old `.asm`/`.inc` apps keep working unchanged — nothing in `src/user/apps/`
or `src/kernel/` is touched by the HL build.

## Roadmap (post file-explorer port)

- Structs + typed struct field access (emits validated offsets)
- Bounded arrays with compile-time range checks (`[N]T`)
- Multi-module projects with a real module resolver (transitive `use`)
- Stricter types (`i32` vs `i64`, `str` vs `ptr<u8>`)
- External-app binary output matching the `NXSAPP64` header in
  `docs/app-loader-format.md`
