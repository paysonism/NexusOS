# NexusOS Multi-Core (SMP Work Queue)

This document describes how NexusOS uses more than one CPU core, and how to
offload expensive work so the GUI stays responsive.

## Goal

A heavy operation in an app (SVG rasterisation, image decode, layout) used to
run on the boot CPU inside the single render loop, freezing the whole desktop
until it finished. The SMP work queue lets that work run on another core while
the boot CPU keeps drawing frames at full speed.

## Model: worker-core offload

NexusOS does **not** schedule whole apps preemptively across cores. It uses a
simpler, lower-risk model:

- **BSP (boot processor, CPU 0)** runs the kernel, the GUI render loop, drivers,
  and all ring-3 app code — exactly as before.
- **APs (application processors, the other cores)** do nothing but pull
  *compute jobs* from a shared queue and run them.

A "job" is a self-contained kernel function plus one argument. The BSP submits
jobs; an idle AP picks one up, runs it, and publishes the result.

## Components

| Piece | File | Role |
|-------|------|------|
| AP bring-up | `src/kernel/arch/apic.asm` | INIT/SIPI trampoline; each AP ends in `smp_worker_loop` instead of a HLT park loop. |
| Work queue + worker loop | `src/kernel/proc/workqueue.asm` | Job array, submit/poll/reap API, and the AP worker loop. |
| Wiring | `src/kernel/core/main.asm` | `kmain` calls `workqueue_init` before `smp_ap_startup`, then `workqueue_selftest`. |

## How a core becomes a worker

`smp_ap_startup` (in `apic.asm`) copies a real-mode trampoline low in memory and
sends INIT/SIPI IPIs. Each AP walks 16-bit → 32-bit → 64-bit mode, enables SSE
(so vectorised job code does not `#UD`), records itself live, and then jumps to
`smp_worker_loop`. It never returns; the core is a permanent worker.

Only built with the `NEXUS_CACHE32_MAX` + `NEXUS_CACHE32_AP_STARTUP` defines
(the Cache32Max profile). In the Default profile APs are not started and every
job runs inline on the BSP — callers behave identically either way.

## Concurrency design

- **One producer** (the BSP), **N consumers** (the APs).
- A job slot is claimed with a single `lock cmpxchg` on its status word, so
  there is **no global lock**. A slow or dead AP can never stall the BSP, and
  two APs can never run the same job.
- Each slot is its own 64-byte cache line — cores working different slots never
  ping-pong a shared line (no false sharing).
- Status store ordering (x86 TSO) guarantees a worker that observes `PENDING`
  also observes the function pointer and argument written just before it.

Status lifecycle: `FREE → BUILDING → PENDING → RUNNING → DONE → FREE`.

## BSP API (`workqueue.asm`)

| Function | In | Out | Notes |
|----------|----|----|-------|
| `workqueue_init` | – | – | Reset the queue; must run before `smp_ap_startup`. |
| `workqueue_submit` | RDI=func, RSI=arg, RDX=priority | RAX=handle or `-1` | Queues a job; runs it inline if no AP is alive. |
| `workqueue_done` | RDI=handle | RAX=1 if finished | Non-blocking poll. |
| `workqueue_reap` | RDI=handle | RAX=result | Reads result and frees the slot. |
| `workqueue_wait` | RDI=handle | RAX=result | Blocks until done, then reaps. |
| `wq_lock` | RDI=lock ptr | – | Acquire a shared-state spinlock. |
| `wq_unlock` | RDI=lock ptr | – | Release a shared-state spinlock. |

## Job priority — keeping the system responsive

`workqueue_submit` takes a priority in RDX:

| Constant | Value | Use for |
|----------|-------|---------|
| `WQ_PRIO_LOW` | 0 | Background app work — may be starved while higher work exists. |
| `WQ_PRIO_NORMAL` | 1 | The default for ordinary offloaded work. |
| `WQ_PRIO_HIGH` | 2 | System-critical jobs that must not wait behind app work. |

Each sweep, a worker scans all slots and claims the **highest-priority**
`PENDING` job, not the first one it sees. This is what stops a misbehaving or
busy app from degrading the system: a flood of `WQ_PRIO_LOW` jobs from a frozen
or runaway app can never delay a `WQ_PRIO_HIGH` system job, and it can never
affect the BSP at all — the BSP never runs jobs, so the GUI render loop is
isolated from app work by construction.

A job still runs to completion once claimed (APs take no timer IRQs). A job
that loops forever permanently consumes **one** AP, but no more: other APs keep
serving the queue and the BSP is untouched. Priority ensures the remaining
cores spend their time on the work that matters.

## Sharing state safely

A job **may** touch state shared with the BSP — the framebuffer, the page
allocator, driver state — as long as **every** accessor, on the BSP side too,
holds the matching lock. `workqueue.asm` provides a spinlock primitive and
three named locks:

| Lock | Guards |
|------|--------|
| `wq_alloc_lock` | The physical page allocator (`page_alloc` / `page_free`). |
| `wq_fb_lock` | The shared framebuffer. |
| `wq_driver_lock` | Shared driver state. |

```asm
    mov rdi, wq_alloc_lock
    call wq_lock
    ; ... critical section: touch the shared resource ...
    mov rdi, wq_alloc_lock
    call wq_unlock
```

`page_alloc` / `page_free` already take `wq_alloc_lock` internally, so a job can
allocate pages with no extra ceremony. For the framebuffer and driver state the
BSP-side code must be taught to take the lock before that resource is genuinely
job-safe — until then, treat it as BSP-only.

A lock only protects if **both** sides take it. The simplest job is still a
self-contained one that reads only read-only data and writes only its own
output buffer — that needs no lock at all.

## Job contract — REQUIRED

A function submitted as a job **must**:

1. Be trusted kernel code. Jobs are never submitted from ring 3, so the function
   pointer is always a kernel address. **Never expose submit as a syscall.**
2. Take one argument in RDI and return a scalar in RAX.
3. Follow the SysV ABI (preserve RBX, RBP, R12–R15).
4. Touch shared mutable state **only** under the matching lock (see "Sharing
   state safely"). Unlocked access to a resource another core may touch is the
   classic SMP bug — it corrupts memory intermittently and is hard to debug.
5. Do bounded work — APs receive no timer IRQs, so a job runs to completion.

## Recommended usage (keeps the render loop alive)

Submit the heavy job, keep rendering frames, and poll once per frame:

```asm
    mov rdi, svg_rasterise_tile      ; job function
    mov rsi, tile_descriptor         ; argument
    call workqueue_submit
    mov [svg_job], eax               ; stash handle; return to the render loop

    ; ... later, once per frame ...
    mov edi, [svg_job]
    call workqueue_done
    test eax, eax
    jz  .not_ready_yet               ; still rendering on the AP; draw a frame
    mov edi, [svg_job]
    call workqueue_reap              ; result in RAX; slot freed
```

Use `workqueue_wait` only when there is genuinely nothing else to do — it blocks
the BSP and defeats the purpose.

## Verification

`workqueue_selftest` runs during `kmain`, submits 8 known jobs, verifies every
result, and prints `WQ:<submitted>/<passed>` to the serial log. A healthy boot
shows `WQ:...8/...8`. With APs alive (`SMP:` shows >1 core) this exercises the
real cross-core path; otherwise it exercises the inline fallback.

## Future work (roadmap)

- Offload SVG tile rasterisation and image decode to the queue.
- A `workqueue_submit_many` / barrier helper for data-parallel splits.
- Per-AP idle `mwait` instead of a `pause` spin to cut power draw.
