#!/usr/bin/env python3
# NexusHL compiler (nxhc) — translates .nxh -> NASM .asm
# Host-side only. Zero runtime. Every memory access goes through typed
# accessors; every kernel call goes through a named syscall wrapper. No raw
# register access unless the caller writes an `asm { ... }` escape block.
#
# Pipeline: lex -> parse -> sema -> emit. One file, no deps.

import os, re, sys, json

KEYWORDS = {
    "use","app","fn","let","if","else","while","for","return",
    "str","i8","i16","i32","i64","u8","u16","u32","u64","ptr","void","bool",
    "true","false","asm","syscall","extern","const","struct","state","break","continue"
}

TOK_RE = re.compile(r"""
    (?P<ws>\s+)
  | (?P<cmt>\#[^\n]*)
  | (?P<str>"(?:\\.|[^"\\])*")
  | (?P<hex>0x[0-9a-fA-F]+)
  | (?P<num>\d+)
  | (?P<id>[A-Za-z_][A-Za-z0-9_]*)
  | (?P<op>==|!=|<=|>=|&&|\|\||<<|>>|[+\-*/%=&|^<>!{}()\[\],;:.])
""", re.X)

class Tok:
    __slots__=("k","v","line","col")
    def __init__(s,k,v,line,col): s.k,s.v,s.line,s.col=k,v,line,col
    def __repr__(s): return f"<{s.k}:{s.v!r}@{s.line}:{s.col}>"

def lex(src, path):
    out=[]; i=0; line=1; col=1
    while i<len(src):
        m=TOK_RE.match(src,i)
        if not m: raise SyntaxError(f"{path}:{line}:{col}: bad char {src[i]!r}")
        g=m.lastgroup; v=m.group()
        if g=="ws":
            nl=v.count("\n")
            if nl: line+=nl; col=len(v)-v.rfind("\n")
            else: col+=len(v)
        elif g=="cmt":
            col+=len(v)
        else:
            if g=="id" and v in KEYWORDS:
                out.append(Tok(v,v,line,col))
            elif g=="str":
                # Process common escape sequences inside string literals.
                # NASM's own double-quoted strings don't process escapes, so
                # this is the only place a NexusHL author can spell a quote,
                # a backslash, or a control character.
                raw=v[1:-1]
                buf=[]; j=0
                while j<len(raw):
                    ch=raw[j]
                    if ch=='\\' and j+1<len(raw):
                        nx=raw[j+1]
                        if nx=='n': buf.append('\n')
                        elif nx=='t': buf.append('\t')
                        elif nx=='r': buf.append('\r')
                        elif nx=='0': buf.append('\x00')
                        elif nx=='\\': buf.append('\\')
                        elif nx=='"': buf.append('"')
                        elif nx=="'": buf.append("'")
                        else: buf.append(nx)
                        j+=2
                    else:
                        buf.append(ch); j+=1
                out.append(Tok("str","".join(buf),line,col))
            elif g=="hex":
                out.append(Tok("num",int(v,16),line,col))
            elif g=="num":
                out.append(Tok("num",int(v),line,col))
            elif g=="id":
                out.append(Tok("id",v,line,col))
            else:
                out.append(Tok(v,v,line,col))
            col+=len(v)
        i=m.end()
    out.append(Tok("eof","",line,col))
    return out

class P:
    def __init__(s,toks,path): s.t=toks; s.i=0; s.path=path
    def peek(s,k=0): return s.t[s.i+k]
    def eat(s,kind=None,val=None):
        x=s.t[s.i]
        if kind and x.k!=kind: s.err(f"expected {kind}, got {x.k}({x.v!r})")
        if val is not None and x.v!=val: s.err(f"expected {val!r}, got {x.v!r}")
        s.i+=1; return x
    def match(s,kind,val=None):
        x=s.t[s.i]
        if x.k!=kind: return False
        if val is not None and x.v!=val: return False
        s.i+=1; return True
    def err(s,msg):
        x=s.t[s.i]
        raise SyntaxError(f"{s.path}:{x.line}:{x.col}: {msg}")

# AST
def node(k,**kw): kw["k"]=k; return kw

def parse(toks,path):
    p=P(toks,path)
    decls=[]
    while p.peek().k!="eof":
        t=p.peek()
        if t.v=="use":
            p.eat(); name=p.eat("id").v
            while p.match(".",):
                name+="."+p.eat("id").v
            p.match(";")
            decls.append(node("use",name=name))
        elif t.v=="app":
            p.eat(); nm=p.eat("str").v
            stack=4096
            if p.match("{"):
                while not p.match("}"):
                    k=p.eat("id").v; p.eat("="); v=p.eat("num").v; p.match(";")
                    if k=="stack": stack=v
            decls.append(node("app",name=nm,stack=stack))
        elif t.v=="str":
            p.eat(); nm=p.eat("id").v; p.eat("="); val=p.eat("str").v; p.match(";")
            decls.append(node("strdef",name=nm,val=val))
        elif t.v=="const":
            p.eat(); nm=p.eat("id").v; p.eat("=")
            neg=False
            if p.peek().k=="-": p.eat(); neg=True
            v=p.eat("num").v
            if neg: v = -v
            p.match(";")
            decls.append(node("const",name=nm,val=v))
        elif t.v=="extern":
            p.eat(); nm=p.eat("id").v; p.match(";")
            decls.append(node("extern",name=nm))
        elif t.v=="state":
            p.eat(); p.eat("{")
            fields=[]
            while not p.match("}"):
                nm=p.eat("id").v
                if p.match(":") or p.match("="):
                    sz=p.eat("num").v
                else:
                    p.err("state field needs ': <byte_count>'")
                p.match(";")
                fields.append((nm,sz))
            decls.append(node("state",fields=fields))
        elif t.v=="fn":
            decls.append(parse_fn(p))
        else:
            p.err(f"unexpected top-level {t.v!r}")
    return decls

def parse_fn(p):
    p.eat("fn"); name=p.eat("id").v
    p.eat("(")
    params=[]
    if not p.match(")"):
        while True:
            pn=p.eat("id").v
            params.append(pn)
            if p.match(")"): break
            p.eat(",")
    body=parse_block(p)
    return node("fn",name=name,params=params,body=body)

def parse_block(p):
    p.eat("{")
    stmts=[]
    while not p.match("}"):
        stmts.append(parse_stmt(p))
    return stmts

def parse_stmt(p):
    t=p.peek()
    if t.v=="let":
        p.eat(); nm=p.eat("id").v; p.eat("="); e=parse_expr(p); p.match(";")
        return node("let",name=nm,expr=e)
    if t.v=="return":
        p.eat()
        e=None
        if p.peek().k!=";" and p.peek().k!="}":
            e=parse_expr(p)
        p.match(";")
        return node("return",expr=e)
    if t.v=="if":
        p.eat(); cond=parse_expr(p); thn=parse_block(p); els=None
        if p.match("else",):
            if p.peek().v=="if":
                els=[parse_stmt(p)]
            else:
                els=parse_block(p)
        return node("if",cond=cond,then=thn,els=els)
    if t.v=="while":
        p.eat(); cond=parse_expr(p); body=parse_block(p)
        return node("while",cond=cond,body=body)
    if t.v=="break":
        p.eat(); p.match(";"); return node("break")
    if t.v=="continue":
        p.eat(); p.match(";"); return node("continue")
    if t.v=="asm":
        p.eat(); s=p.eat("str").v; p.match(";")
        return node("asm",text=s)
    # expr-stmt or assign
    e=parse_expr(p)
    if p.match("="):
        rhs=parse_expr(p); p.match(";")
        return node("assign",lhs=e,rhs=rhs)
    p.match(";")
    return node("exprstmt",expr=e)

PREC={"||":1,"&&":2,"==":3,"!=":3,"<":4,">":4,"<=":4,">=":4,
      "+":5,"-":5,"|":5,"^":5,"*":6,"/":6,"%":6,"&":6,"<<":6,">>":6}

def parse_expr(p): return parse_binop(p,0)

def parse_binop(p,minp):
    lhs=parse_unary(p)
    while True:
        t=p.peek()
        op=t.v if t.k in ("==","!=","<=",">=","&&","||","<<",">>","+","-","*","/","%","&","|","^","<",">") else None
        if op is None or op not in PREC or PREC[op]<minp: break
        p.eat()
        rhs=parse_binop(p,PREC[op]+1)
        lhs=node("bin",op=op,lhs=lhs,rhs=rhs)
    return lhs

def parse_unary(p):
    t=p.peek()
    if t.v=="-":
        p.eat(); e=parse_unary(p); return node("neg",expr=e)
    if t.v=="!":
        p.eat(); e=parse_unary(p); return node("not",expr=e)
    if t.v=="&":
        p.eat(); nm=p.eat("id").v; return node("addr",name=nm)
    return parse_postfix(p)

def parse_postfix(p):
    e=parse_primary(p)
    while True:
        if p.match("("):
            args=[]
            if not p.match(")"):
                while True:
                    args.append(parse_expr(p))
                    if p.match(")"): break
                    p.eat(",")
            if e.get("k")=="ident":
                e=node("call",name=e["name"],args=args)
            else:
                p.err("callable must be identifier")
        elif p.match("["):
            idx=parse_expr(p); p.eat("]")
            e=node("index",target=e,idx=idx)
        else:
            break
    return e

def parse_primary(p):
    t=p.peek()
    if t.k=="num":
        p.eat(); return node("int",val=t.v)
    if t.v=="true":
        p.eat(); return node("int",val=1)
    if t.v=="false":
        p.eat(); return node("int",val=0)
    if t.k=="str":
        p.eat(); return node("strlit",val=t.v)
    if t.v=="syscall":
        p.eat(); p.eat("(")
        args=[]
        if not p.match(")"):
            while True:
                args.append(parse_expr(p))
                if p.match(")"): break
                p.eat(",")
        if not args: p.err("syscall needs number")
        return node("syscall",num=args[0],args=args[1:])
    if t.k=="id":
        p.eat(); return node("ident",name=t.v)
    if p.match("("):
        e=parse_expr(p); p.eat(")"); return e
    p.err(f"unexpected {t.v!r}")

# -------------------- codegen --------------------
ARG_REGS=["rdi","rsi","rdx","r10","r8","r9"]           # syscall ABI
CALL_REGS=["rdi","rsi","rdx","rcx","r8","r9"]          # System V AMD64 (regular calls)

def rbpoff(o):
    # Format a signed rbp displacement: negative locals -> "-N", positive
    # (stack-passed params 7+) -> "+N".  o == 0 collapses to "".
    if o<0: return str(o)
    if o>0: return "+"+str(o)
    return ""

class CG:
    def __init__(s,app_prefix):
        s.text=[]; s.rodata=[]; s.data=[]
        s.lbl=0
        s.prefix=app_prefix
        s.str_lbls={}
        s.state_defs={}
        s.consts={}
        s.externs=set()
        s.loops=[]  # (brk_lbl, cont_lbl)
        s.sigs=[]
    def L(s,base="L"):
        s.lbl+=1; return f".{base}{s.lbl}"
    def emit(s,line): s.text.append(line)
    def str_label(s,val):
        if val in s.str_lbls: return s.str_lbls[val]
        n=len(s.str_lbls); lbl=f"{s.prefix}_str{n}"
        s.str_lbls[val]=lbl
        s.rodata.append(f"{lbl}: " + _emit_db_bytes(val))
        return lbl

def _emit_db_bytes(val):
    # NASM double-quoted strings do NOT process escapes (no \n, no \\), and
    # putting an embedded " requires switching to a single-quoted form. To
    # be robust to any content — including backslashes (paths) and quotes —
    # emit the string as a list of byte values plus a NUL terminator. The
    # output is identical in size but immune to NASM quoting quirks.
    raw = val.encode("utf-8")
    if not raw:
        return "db 0"
    parts = ", ".join(str(b) for b in raw)
    return f"db {parts}, 0"

# -------------------- peephole optimizer --------------------
# The codegen above is a naive stack machine: every expression result lands in
# rax and is push/pop-shuffled into ABI registers. That makes hot inner loops
# (e.g. the SVG rasterizer's per-pixel fixed-point math) waste a huge fraction
# of their cycles on push/pop. This pass losslessly rewrites a few mechanical
# patterns to direct register moves. Semantics are preserved: every rewrite is
# a straight-line substitution within a basic block, and we bail out on any
# line that isn't a known pure data-move instruction.
#
# Patterns:
#   A) (mov rax, OP_i ; push rax){N} (pop REG_j){N}
#        -> mov REG_pop_order, OP_i ...
#      Used for N-arg call/syscall arg marshalling.
#   B) push rax ; pop REG     -> mov REG, rax
#      Catches any leftover single-arg case not covered by A.
#   C) mov rax, OP ; mov rcx, rax ; pop rax
#        -> mov rcx, OP ; pop rax
#      Catches binary-op RHS evaluation where rax is about to be overwritten.

_PEEP_LOAD_RAX = re.compile(r"^\s*mov\s+rax,\s*(.+?)\s*$")
_PEEP_PUSH_RAX = re.compile(r"^\s*push\s+rax\s*$")
_PEEP_POP_REG  = re.compile(r"^\s*pop\s+([a-z][a-z0-9]+)\s*$")
_PEEP_MOV_R_RAX = re.compile(r"^\s*mov\s+([a-z][a-z0-9]+),\s*rax\s*$")
_REG_WORD = re.compile(r"\b([a-z][a-z0-9]+)\b")
# Operands considered safe to relocate: they read no registers other than
# rbp/rip-relative or are pure immediates. We detect by checking the operand
# does not mention any general-purpose reg name that could be clobbered by
# the move target. Conservative: only allow rbp, rsp, rip in operands.
_ALLOWED_OPERAND_REGS = {"rbp","rsp","rip"}

def _operand_safe_for_target(op, target_reg):
    # Reject if operand references the target register (would change meaning).
    if re.search(r"\b" + re.escape(target_reg) + r"\b", op):
        return False
    # Reject if operand references any register not in the allowlist (could be
    # clobbered by an earlier move in the rewritten sequence).
    for m in _REG_WORD.finditer(op):
        w = m.group(1)
        # skip pure decimal numbers (already filtered by \b[a-z]) and known-safe
        if w in _ALLOWED_OPERAND_REGS: continue
        if w in ("byte","word","dword","qword","ptr","rel"): continue
        # any other identifier that looks like a register? Be conservative:
        # ban rax/rbx/rcx/rdx/rsi/rdi/r8..r15 — these can be clobbered.
        if w == "rax" or w == "rbx" or w == "rcx" or w == "rdx" \
           or w == "rsi" or w == "rdi" or (w.startswith("r") and w[1:].isdigit()):
            return False
    return True

def _peephole(lines):
    # Pass A: collapse N-arg push/pop staging into direct moves.
    out = []
    i = 0
    n = len(lines)
    while i < n:
        # Detect run of (mov rax, OP ; push rax) pairs.
        ops = []
        j = i
        while j + 1 < n:
            m1 = _PEEP_LOAD_RAX.match(lines[j])
            if not m1: break
            if not _PEEP_PUSH_RAX.match(lines[j+1]): break
            ops.append(m1.group(1))
            j += 2
        if ops:
            # Count trailing pops (must equal len(ops), all distinct, none rax).
            pops = []
            k = j
            while k < n:
                m2 = _PEEP_POP_REG.match(lines[k])
                if not m2: break
                pops.append(m2.group(1))
                k += 1
            if (len(pops) == len(ops)
                and len(set(pops)) == len(pops)
                and "rax" not in pops):
                # pops are LIFO: pops[m] receives ops[N-1-m].
                N = len(ops)
                regs = pops
                # Verify each chosen src is safe given the target register
                # AND every later target's register isn't referenced by an
                # earlier-emitted src (we emit pops in order; src for pops[0]
                # gets emitted first, so it must not reference pops[1..]'s
                # regs since those moves happen later — but later moves can't
                # clobber an already-emitted src, only the destination reg.
                # So just check: src must not reference its own destination.
                safe = True
                for m, popreg in enumerate(pops):
                    src = ops[N - 1 - m]
                    if not _operand_safe_for_target(src, popreg):
                        safe = False; break
                if safe:
                    # Additional check: src must not reference a destination
                    # that will be written before this move (i.e., any pops[<m]).
                    # Emit order: pops[0], pops[1], ... pops[N-1].
                    written = set()
                    for m, popreg in enumerate(pops):
                        src = ops[N - 1 - m]
                        for w in written:
                            if re.search(r"\b" + re.escape(w) + r"\b", src):
                                safe = False; break
                        if not safe: break
                        written.add(popreg)
                if safe:
                    for m, popreg in enumerate(pops):
                        src = ops[N - 1 - m]
                        out.append(f"    mov {popreg}, {src}")
                    i = k
                    continue
        out.append(lines[i])
        i += 1

    # Pass B: any remaining adjacent push rax / pop REG.
    lines = out
    out = []
    i = 0
    n = len(lines)
    while i < n:
        if (i + 1 < n
            and _PEEP_PUSH_RAX.match(lines[i])
            and _PEEP_POP_REG.match(lines[i+1])):
            reg = _PEEP_POP_REG.match(lines[i+1]).group(1)
            if reg != "rax":
                out.append(f"    mov {reg}, rax")
            i += 2
            continue
        out.append(lines[i])
        i += 1

    # Pass C: mov rax, OP / mov rcx, rax / pop rax  -> mov rcx, OP / pop rax
    # (and same for any target reg, not just rcx). The trailing pop rax shows
    # the rax load was only a staging step.
    lines = out
    out = []
    i = 0
    n = len(lines)
    while i < n:
        if i + 2 < n:
            m1 = _PEEP_LOAD_RAX.match(lines[i])
            m2 = _PEEP_MOV_R_RAX.match(lines[i+1])
            m3 = _PEEP_POP_REG.match(lines[i+2])
            if m1 and m2 and m3 and m3.group(1) == "rax" and m2.group(1) != "rax":
                op = m1.group(1)
                tgt = m2.group(1)
                if _operand_safe_for_target(op, tgt):
                    out.append(f"    mov {tgt}, {op}")
                    out.append(lines[i+2])
                    i += 3
                    continue
        out.append(lines[i])
        i += 1
    return out

def compile_unit(decls,app_prefix,embed=False):
    global LAST_SIGS
    cg=CG(app_prefix)
    cg.embed=embed
    app_meta={"name":app_prefix,"stack":4096}
    # collect top-level
    str_defs={}
    for d in decls:
        if d["k"]=="app":
            app_meta["name"]=d["name"]; app_meta["stack"]=d["stack"]
        elif d["k"]=="strdef":
            lbl=f"{app_prefix}_{d['name']}"
            cg.str_lbls[d["val"]]=lbl
            cg.rodata.append(f"{lbl}: " + _emit_db_bytes(d["val"]))
            str_defs[d["name"]]=lbl
        elif d["k"]=="const":
            cg.consts[d["name"]]=d["val"]
        elif d["k"]=="extern":
            cg.externs.add(d["name"])
        elif d["k"]=="state":
            for nm,sz in d["fields"]:
                if sz <= 0:
                    raise SyntaxError(f"state {nm}: size must be positive")
                lbl=f"{app_prefix}_{nm}"
                cg.state_defs[nm]=lbl
                cg.data.append(f"{lbl}: times {sz} db 0")
    cg.str_defs=str_defs
    # collect local fn names (so calls resolve to prefixed symbols)
    cg.local_fns={d["name"] for d in decls if d["k"]=="fn"}
    cg.fn_argc={d["name"]:len(d["params"]) for d in decls if d["k"]=="fn"}
    # functions
    for d in decls:
        if d["k"]=="fn":
            gen_fn(cg,d,app_prefix)
    # assemble output
    out=[]
    out.append(f"; NexusHL generated — do not edit by hand")
    out.append(f'; app="{app_meta["name"]}" stack={app_meta["stack"]}')
    if not embed:
        out.append("bits 64")
        out.append("default rel")
        out.append('%include "trace.inc"')
    for e in sorted(cg.externs):
        out.append(f"extern {e}")
    if not embed:
        out.append("section .text")
    out.extend(_peephole(cg.text))
    # Strings: emit as inert bytes in current section. In standalone mode put
    # them in .rodata; in embed mode keep them in .text (safe — no code falls
    # through into them since every fn ends with `ret`).
    if cg.rodata:
        if not embed:
            out.append("section .rodata")
        out.extend(cg.rodata)
    if cg.data:
        if not embed:
            out.append("section .data")
        out.extend(cg.data)
    LAST_SIGS=cg.sigs
    return "\n".join(out)+"\n"

def gen_fn(cg,fn,prefix):
    name=f"{prefix}_{fn['name']}"
    params=fn["params"]
    # scope: var -> rbp offset
    scope={}
    # Params 0..5 arrive in CALL_REGS and are spilled to negative rbp slots.
    # Params 6+ arrive on the caller's stack (System V): after `push rbp`,
    # arg6 sits at [rbp+16], arg7 at [rbp+24], ...  They are read in place.
    for i,pn in enumerate(params):
        if i<len(CALL_REGS):
            scope[pn]=-8*(i+1)
        else:
            scope[pn]=16+8*(i-len(CALL_REGS))
    kindmask=0
    cg.sigs.append({
        "name": name,
        "argc": len(params),
        "kindmask": kindmask,
        "retkind": "FN_RET_SCALAR",
        "args": [{"index": i, "name": pn, "kind": "FN_KIND_SCALAR"} for i, pn in enumerate(params)],
    })
    cg.emit(f"FN_BEGIN {name}, {len(params)}, {kindmask}, FN_RET_SCALAR")
    for i,pn in enumerate(params):
        cg.emit(f"FN_ARG {i}, {pn}, FN_KIND_SCALAR")
    # Frame size = one 8-byte slot per `let` in the body (scopes are not
    # reclaimed) plus the register-param spill area, rounded up to 16 bytes.
    # Sizing per-function keeps recursive functions' frames small while
    # letting wide functions declare as many locals as they need.
    def count_lets(stmts):
        n=0
        for s in stmts:
            k=s.get("k")
            if k=="let": n+=1
            if k=="if":
                n+=count_lets(s.get("then",[]))
                n+=count_lets(s.get("els",[]) or [])
            if k=="while":
                n+=count_lets(s.get("body",[]))
        return n
    reg_param_count=min(len(params),len(CALL_REGS))
    n_locals=count_lets(fn["body"])
    local_size=8*(reg_param_count+n_locals)+64
    local_size=(local_size+15)&~15
    cg.emit("    push rbp")
    cg.emit("    mov rbp, rsp")
    cg.emit(f"    sub rsp, {local_size}")
    # save register params to their negative slots (stack params stay put)
    for i,pn in enumerate(params):
        if i<len(CALL_REGS):
            cg.emit(f"    mov [rbp{rbpoff(scope[pn])}], {CALL_REGS[i]}")
    # callee-saved (we use rbx, r12 in body possibly)
    cg.emit("    push rbx")
    cg.emit("    push r12")
    # body
    next_off=[-8*(reg_param_count+1)]  # locals start below the reg-param slots
    st=FnState(cg,scope,next_off,local_size)
    st.epilogue=f".fn_end_{cg.lbl}_{name}"
    for stmt in fn["body"]:
        gen_stmt(st,stmt)
    cg.emit(f"{st.epilogue}:")
    cg.emit(f"    FN_END {name}")
    cg.emit("    pop r12")
    cg.emit("    pop rbx")
    cg.emit("    mov rsp, rbp")
    cg.emit("    pop rbp")
    cg.emit("    ret")

class FnState:
    def __init__(s,cg,scope,next_off,local_size):
        s.cg=cg; s.scope=scope; s.next_off=next_off; s.local_size=local_size
        s.epilogue=""
    def new_local(s,name):
        s.next_off[0]-=8
        if -s.next_off[0]>s.local_size:
            raise SyntaxError("too many locals (>128 bytes)")
        s.scope[name]=s.next_off[0]
        return s.scope[name]

def gen_stmt(st,s):
    cg=st.cg; k=s["k"]
    if k=="let":
        off=st.new_local(s["name"])
        gen_expr(st,s["expr"])  # into rax
        cg.emit(f"    mov [rbp{rbpoff(off)}], rax")
    elif k=="assign":
        lhs=s["lhs"]
        if lhs["k"]!="ident":
            raise SyntaxError("only simple variable assignment supported")
        if lhs["name"] not in st.scope:
            raise SyntaxError(f"unknown var {lhs['name']}")
        gen_expr(st,s["rhs"])
        off=st.scope[lhs["name"]]
        cg.emit(f"    mov [rbp{rbpoff(off)}], rax")
    elif k=="exprstmt":
        gen_expr(st,s["expr"])
    elif k=="return":
        if s["expr"]:
            gen_expr(st,s["expr"])
        cg.emit(f"    jmp {st.epilogue}")
    elif k=="if":
        lelse=cg.L("else"); lend=cg.L("endif")
        gen_expr(st,s["cond"])
        cg.emit("    test rax, rax")
        cg.emit(f"    jz {lelse}")
        for stmt in s["then"]: gen_stmt(st,stmt)
        cg.emit(f"    jmp {lend}")
        cg.emit(f"{lelse}:")
        if s.get("els"):
            for stmt in s["els"]: gen_stmt(st,stmt)
        cg.emit(f"{lend}:")
    elif k=="while":
        lstart=cg.L("wst"); lend=cg.L("wend")
        cg.loops=getattr(cg,"loops",[])
        cg.loops.append((lend,lstart))
        cg.emit(f"{lstart}:")
        gen_expr(st,s["cond"])
        cg.emit("    test rax, rax")
        cg.emit(f"    jz {lend}")
        for stmt in s["body"]: gen_stmt(st,stmt)
        cg.emit(f"    jmp {lstart}")
        cg.emit(f"{lend}:")
        cg.loops.pop()
    elif k=="break":
        if not cg.loops: raise SyntaxError("break outside loop")
        cg.emit(f"    jmp {cg.loops[-1][0]}")
    elif k=="continue":
        if not cg.loops: raise SyntaxError("continue outside loop")
        cg.emit(f"    jmp {cg.loops[-1][1]}")
    elif k=="asm":
        for ln in s["text"].split("\\n"):
            cg.emit("    "+ln)
    else:
        raise SyntaxError(f"bad stmt {k}")

def gen_expr(st,e):
    cg=st.cg; k=e["k"]
    if k=="int":
        cg.emit(f"    mov rax, {e['val']}")
    elif k=="strlit":
        lbl=cg.str_label(e["val"])
        cg.emit(f"    lea rax, [rel {lbl}]")
    elif k=="ident":
        n=e["name"]
        if n in st.scope:
            cg.emit(f"    mov rax, [rbp{rbpoff(st.scope[n])}]")
        elif n in cg.consts:
            cg.emit(f"    mov rax, {cg.consts[n]}")
        elif n in cg.str_defs:
            cg.emit(f"    lea rax, [rel {cg.str_defs[n]}]")
        elif n in cg.state_defs:
            cg.emit(f"    lea rax, [rel {cg.state_defs[n]}]")
        else:
            raise SyntaxError(f"unknown identifier {n}")
    elif k=="addr":
        n=e["name"]
        if n in st.scope:
            cg.emit(f"    lea rax, [rbp{rbpoff(st.scope[n])}]")
        elif n in cg.str_defs:
            cg.emit(f"    lea rax, [rel {cg.str_defs[n]}]")
        elif n in cg.state_defs:
            cg.emit(f"    lea rax, [rel {cg.state_defs[n]}]")
        elif n in cg.externs:
            cg.emit(f"    lea rax, [rel {n}]")
        else:
            # implicit extern: allow &any_symbol — register it so NASM resolves it
            cg.externs.add(n)
            cg.emit(f"    lea rax, [rel {n}]")
    elif k=="neg":
        gen_expr(st,e["expr"]); cg.emit("    neg rax")
    elif k=="not":
        gen_expr(st,e["expr"])
        cg.emit("    test rax, rax"); cg.emit("    sete al"); cg.emit("    movzx rax, al")
    elif k=="bin":
        op=e["op"]
        # Strength-reduce `/` and `%` by a compile-time power-of-two constant.
        # idiv is ~20-90 cycles; the shift idiom below is ~3 and preserves the
        # signed (truncate-toward-zero) semantics NexusHL `/` guarantees.
        if op in ("/","%"):
            cv=None
            r=e["rhs"]
            if r["k"]=="int":
                cv=r["val"]
            elif r["k"]=="ident" and r["name"] in cg.consts:
                cvv=cg.consts[r["name"]]
                if isinstance(cvv,int): cv=cvv
            if isinstance(cv,int) and cv>0 and (cv&(cv-1))==0:
                kbit=cv.bit_length()-1
                gen_expr(st,e["lhs"])
                if kbit==0:
                    if op=="%": cg.emit("    xor rax, rax")
                else:
                    cg.emit("    mov rcx, rax")
                    cg.emit("    sar rcx, 63")
                    cg.emit(f"    shr rcx, {64-kbit}")
                    cg.emit("    add rax, rcx")
                    if op=="/":
                        cg.emit(f"    sar rax, {kbit}")
                    else:
                        cg.emit(f"    and rax, {cv-1}")
                        cg.emit("    sub rax, rcx")
                return
        gen_expr(st,e["lhs"]); cg.emit("    push rax")
        gen_expr(st,e["rhs"]); cg.emit("    mov rcx, rax"); cg.emit("    pop rax")
        if op=="+": cg.emit("    add rax, rcx")
        elif op=="-": cg.emit("    sub rax, rcx")
        elif op=="*": cg.emit("    imul rax, rcx")
        elif op=="/": cg.emit("    cqo"); cg.emit("    idiv rcx")
        elif op=="%": cg.emit("    cqo"); cg.emit("    idiv rcx"); cg.emit("    mov rax, rdx")
        elif op=="&": cg.emit("    and rax, rcx")
        elif op=="|": cg.emit("    or rax, rcx")
        elif op=="^": cg.emit("    xor rax, rcx")
        elif op=="<<": cg.emit("    shl rax, cl")
        elif op==">>": cg.emit("    shr rax, cl")
        elif op in ("==","!=","<",">","<=",">="):
            cg.emit("    cmp rax, rcx")
            setop={"==":"sete","!=":"setne","<":"setl",">":"setg","<=":"setle",">=":"setge"}[op]
            cg.emit(f"    {setop} al"); cg.emit("    movzx rax, al")
        elif op=="&&":
            cg.emit("    test rax, rax"); lbl=cg.L("andfalse"); lend=cg.L("andend")
            cg.emit(f"    jz {lbl}")
            cg.emit("    test rcx, rcx"); cg.emit(f"    jz {lbl}")
            cg.emit("    mov rax, 1"); cg.emit(f"    jmp {lend}")
            cg.emit(f"{lbl}:"); cg.emit("    xor rax, rax"); cg.emit(f"{lend}:")
        elif op=="||":
            lt=cg.L("ortrue"); lend=cg.L("orend")
            cg.emit("    test rax, rax"); cg.emit(f"    jnz {lt}")
            cg.emit("    test rcx, rcx"); cg.emit(f"    jnz {lt}")
            cg.emit("    xor rax, rax"); cg.emit(f"    jmp {lend}")
            cg.emit(f"{lt}:"); cg.emit("    mov rax, 1"); cg.emit(f"{lend}:")
        else:
            raise SyntaxError(f"bad op {op}")
    elif k=="syscall":
        # move args into ABI regs, then syscall num in rax
        args=e["args"]
        if len(args)>6: raise SyntaxError("syscall has max 6 args")
        # evaluate to stack first (left-to-right), then pop in reverse
        for a in args:
            gen_expr(st,a); cg.emit("    push rax")
        for reg in reversed(ARG_REGS[:len(args)]):
            cg.emit(f"    pop {reg}")
        gen_expr(st,e["num"])
        cg.emit("    syscall")
    elif k=="call":
        args=e["args"]
        name=e["name"]
        # Builtins: memory load/store — compile inline, no actual call.
        if name in ("lb","lw","lq","sb","sw","sq"):
            if name in ("lb","lw","lq") and len(args)!=1: raise SyntaxError(f"{name} takes 1 arg")
            if name in ("sb","sw","sq") and len(args)!=2: raise SyntaxError(f"{name} takes 2 args")
            if name=="lb":
                gen_expr(st,args[0]); cg.emit("    movzx rax, byte [rax]")
            elif name=="lw":
                gen_expr(st,args[0]); cg.emit("    movsxd rax, dword [rax]")
            elif name=="lq":
                gen_expr(st,args[0]); cg.emit("    mov rax, [rax]")
            elif name in ("sb","sw","sq"):
                gen_expr(st,args[0]); cg.emit("    push rax")
                gen_expr(st,args[1]); cg.emit("    mov rcx, rax"); cg.emit("    pop rax")
                if name=="sb": cg.emit("    mov [rax], cl")
                elif name=="sw": cg.emit("    mov [rax], ecx")
                else: cg.emit("    mov [rax], rcx")
                cg.emit("    xor rax, rax")
            return
        if name in getattr(cg,"fn_argc",{}) and len(args)!=cg.fn_argc[name]:
            raise SyntaxError(f"{name} expects {cg.fn_argc[name]} args, got {len(args)}")
        reg_args=args[:len(CALL_REGS)]
        stack_args=args[len(CALL_REGS):]
        # System V: push stack args 7+ right-to-left so arg6 lands at [rsp].
        for a in reversed(stack_args):
            gen_expr(st,a); cg.emit("    push rax")
        # Evaluate register args, stage on the stack, then pop into regs so
        # earlier args' evaluation can't clobber a register already loaded.
        for a in reg_args:
            gen_expr(st,a); cg.emit("    push rax")
        for reg in reversed(CALL_REGS[:len(reg_args)]):
            cg.emit(f"    pop {reg}")
        if name in getattr(cg,"local_fns",set()):
            cg.emit(f"    FN_CALL {cg.prefix}_{name}, {len(args)}")
        else:
            cg.externs.add(name)
            cg.emit(f"    FN_CALL {name}, {len(args)}")
        if stack_args:
            cg.emit(f"    add rsp, {8*len(stack_args)}")
    else:
        raise SyntaxError(f"bad expr {k}")

# -------------------- driver --------------------
def resolve_use(name, lib_dir):
    path=os.path.join(lib_dir, name.replace(".", os.sep)+".nxh")
    if not os.path.isfile(path):
        raise FileNotFoundError(f"use {name}: {path} not found")
    return path

def compile_file(path, lib_dir, app_prefix=None, embed=False, return_sigs=False):
    with open(path,"r",encoding="utf-8") as f: src=f.read()
    toks=lex(src,path); decls=parse(toks,path)
    # expand uses: prepend decls from lib files
    expanded=[]
    seen=set()
    def load(p):
        if p in seen: return
        seen.add(p)
        with open(p,"r",encoding="utf-8") as f: s=f.read()
        tt=lex(s,p); dd=parse(tt,p)
        # libs can themselves `use`, but keep simple: one level
        for d in dd:
            if d["k"]=="use":
                sub=resolve_use(d["name"], lib_dir)
                load(sub)
            else:
                expanded.append(d)
    # resolve top-level `use` first
    for d in decls:
        if d["k"]=="use":
            sub=resolve_use(d["name"], lib_dir)
            load(sub)
    for d in decls:
        if d["k"]!="use":
            expanded.append(d)
    prefix=app_prefix or os.path.splitext(os.path.basename(path))[0]
    asm=compile_unit(expanded, "app_hl_"+prefix, embed=embed)
    if return_sigs:
        return asm, LAST_SIGS
    return asm

def main():
    import argparse
    ap=argparse.ArgumentParser()
    ap.add_argument("input")
    ap.add_argument("-o","--output",required=True)
    ap.add_argument("-L","--lib",default=os.path.join(os.path.dirname(__file__),"..","lib"))
    ap.add_argument("--prefix",default=None)
    ap.add_argument("--embed",action="store_true",
                    help="emit for %%include into a larger NASM unit: no bits/default/section/extern directives, strings inline in .text")
    ap.add_argument("--emit-sigs",action="store_true",
                    help="write a .sig.json sidecar next to the generated assembly")
    args=ap.parse_args()
    if args.emit_sigs:
        asm,sigs=compile_file(args.input, os.path.abspath(args.lib), args.prefix, embed=args.embed, return_sigs=True)
    else:
        asm=compile_file(args.input, os.path.abspath(args.lib), args.prefix, embed=args.embed)
        sigs=[]
    with open(args.output,"w",encoding="utf-8",newline="\n") as f: f.write(asm)
    if args.emit_sigs:
        sig_path=os.path.splitext(args.output)[0]+".sig.json"
        with open(sig_path,"w",encoding="utf-8",newline="\n") as f:
            json.dump(sigs,f,indent=2)
            f.write("\n")
    print(f"[nxhc] {args.input} -> {args.output} ({len(asm)} bytes)")

if __name__=="__main__":
    main()
