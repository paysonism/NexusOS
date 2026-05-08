"""
Regression model for src/kernel/drivers/display.asm:fill_rect.

The fixed implementation sign-extends x/y/w/h, clips in 64-bit, rejects
starting coordinates outside the screen with unsigned compares, and computes
the row offset with a 64-bit pitch. This test exercises boundary and random
inputs and asserts every modeled write is inside the back buffer extent.
"""

from __future__ import annotations

import random


def s32(value: int) -> int:
    value &= 0xFFFFFFFF
    return value - 0x100000000 if value & 0x80000000 else value


def u32(value: int) -> int:
    return value & 0xFFFFFFFF


def fill_rect_fixed(x: int, y: int, w: int, h: int, bb_addr: int, scr_w: int, scr_h: int, pitch: int):
    r9 = s32(x)
    r10 = s32(y)
    r11 = s32(w)
    r12 = s32(h)

    if r9 < 0:
        r11 += r9
        r9 = 0

    if r11 <= 0:
        return None
    if r9 >= scr_w:
        return None

    right = r9 + r11
    if right > scr_w:
        r11 = scr_w - r9

    if r10 < 0:
        r12 += r10
        r10 = 0

    if r12 <= 0:
        return None
    if r10 >= scr_h:
        return None

    bottom = r10 + r12
    if bottom > scr_h:
        r12 = scr_h - r10

    if r11 <= 0 or r12 <= 0:
        return None

    offset = r10 * pitch + r9 * 4
    return bb_addr + offset, r11, r12


def syscall_rect_accepts(x: int, y: int, w: int, h: int, scr_w: int, scr_h: int) -> bool:
    values = (x, y, w, h)
    if any(value & 0xFFFFFFFF00000000 for value in values):
        return False
    return not (u32(x) > scr_w or u32(y) > scr_h or u32(w) > scr_w or u32(h) > scr_h)


BB = 0x180000000
SCR_W = 1920
SCR_H = 1080
PITCH = 7680
FB_END = BB + PITCH * SCR_H


def assert_inside(case):
    result = fill_rect_fixed(*case, BB, SCR_W, SCR_H, PITCH)
    if result is None:
        return
    addr, width, rows = result
    assert BB <= addr < FB_END, (case, hex(addr), "start escaped")
    last = addr + (rows - 1) * PITCH + width * 4 - 1
    assert BB <= last < FB_END, (case, hex(last), "end escaped")


boundary_values = [
    -(2**31),
    -(2**31) + 1,
    -1,
    0,
    1,
    SCR_W - 1,
    SCR_W,
    SCR_W + 1,
    SCR_H - 1,
    SCR_H,
    SCR_H + 1,
    0x7FFFFFFF,
    0x80000000,
    0xFFFFFFFF,
]


def main() -> None:
    cases = []

    for x in boundary_values:
        for y in boundary_values:
            for w in [-1, 0, 1, SCR_W - 1, SCR_W, SCR_W + 1, 0x7FFFFFFF, 0x80000000]:
                for h in [-1, 0, 1, SCR_H - 1, SCR_H, SCR_H + 1, 0x7FFFFFFF, 0x80000000]:
                    cases.append((x, y, w, h))

    rng = random.Random(0xC0DEF11)
    for _ in range(10_000):
        cases.append(tuple(rng.randrange(-(2**31), 2**32) for _ in range(4)))

    for case in cases:
        assert_inside(case)

    # The original minimal PoC must now be clipped away by the hardened math
    # and rejected before render_rect at the syscall boundary.
    poc_case = (0x7FFFFFFF, 0x7FFFFFFF, 1, 1)
    assert fill_rect_fixed(*poc_case, BB, SCR_W, SCR_H, PITCH) is None
    assert not syscall_rect_accepts(*poc_case, SCR_W, SCR_H)

    legit_case = (10, 20, 30, 40)
    assert fill_rect_fixed(*legit_case, BB, SCR_W, SCR_H, PITCH) == (BB + 20 * PITCH + 10 * 4, 30, 40)
    assert syscall_rect_accepts(*legit_case, SCR_W, SCR_H)

    print(f"checked {len(cases)} cases: zero framebuffer escapes")


if __name__ == "__main__":
    main()
