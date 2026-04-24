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
    "true","false","asm","syscall","extern","const","struct","break","continue"
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
                out.append(Tok("str",v[1:-1],line,col))
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
            p.eat(); nm=p.eat("id").v; p.eat("="); v=p.eat("num").v; p.match(";")
            decls.append(node("const",name=nm,val=v))
        elif t.v=="extern":
            p.eat(); nm=p.eat("id").v; p.match(";")
            decls.append(node("extern",name=nm))
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

class CG:
    def __init__(s,app_prefix):
        s.text=[]; s.rodata=[]; s.data=[]
        s.lbl=0
        s.prefix=app_prefix
        s.str_lbls={}
        s.consts={}
        s.externs=set()
        s.loops=[]  # (brk_lbl, cont_lbl)
    def L(s,base="L"):
        s.lbl+=1; return f".{base}{s.lbl}"
    def emit(s,line): s.text.append(line)
    def str_label(s,val):
        if val in s.str_lbls: return s.str_lbls[val]
        n=len(s.str_lbls); lbl=f"{s.prefix}_str{n}"
        s.str_lbls[val]=lbl
        esc=val.encode("utf-8").decode("latin-1","replace")
        safe=esc.replace('\\','\\\\').replace('"','\\"')
        s.rodata.append(f'{lbl}: db "{safe}", 0')
        return lbl

def compile_unit(decls,app_prefix):
    cg=CG(app_prefix)
    app_meta={"name":app_prefix,"stack":4096}
    # collect top-level
    str_defs={}
    for d in decls:
        if d["k"]=="app":
            app_meta["name"]=d["name"]; app_meta["stack"]=d["stack"]
        elif d["k"]=="strdef":
            lbl=f"{app_prefix}_{d['name']}"
            cg.str_lbls[d["val"]]=lbl
            safe=d["val"].replace('\\','\\\\').replace('"','\\"')
            cg.rodata.append(f'{lbl}: db "{safe}", 0')
            str_defs[d["name"]]=lbl
        elif d["k"]=="const":
            cg.consts[d["name"]]=d["val"]
        elif d["k"]=="extern":
            cg.externs.add(d["name"])
    cg.str_defs=str_defs
    # collect local fn names (so calls resolve to prefixed symbols)
    cg.local_fns={d["name"] for d in decls if d["k"]=="fn"}
    # functions
    for d in decls:
        if d["k"]=="fn":
            gen_fn(cg,d,app_prefix)
    # assemble output
    out=[]
    out.append(f"; NexusHL generated — do not edit by hand")
    out.append(f'; app="{app_meta["name"]}" stack={app_meta["stack"]}')
    out.append("bits 64")
    for e in sorted(cg.externs):
        out.append(f"extern {e}")
    out.append("section .text")
    out.extend(cg.text)
    if cg.rodata:
        out.append("section .rodata")
        out.extend(cg.rodata)
    if cg.data:
        out.append("section .data")
        out.extend(cg.data)
    return "\n".join(out)+"\n"

def gen_fn(cg,fn,prefix):
    name=f"{prefix}_{fn['name']}"
    params=fn["params"]
    # scope: var -> rbp offset
    scope={}
    for i,pn in enumerate(params):
        if i>=len(CALL_REGS):
            raise SyntaxError(f"fn {fn['name']}: too many params")
        scope[pn]=-8*(i+1)
    cg.emit(f"global {name}")
    cg.emit(f"{name}:")
    # prologue: 512 bytes of locals max (64 i64 slots)
    local_size=512
    cg.emit("    push rbp")
    cg.emit("    mov rbp, rsp")
    cg.emit(f"    sub rsp, {local_size}")
    # save params to stack
    for i,pn in enumerate(params):
        cg.emit(f"    mov [rbp{scope[pn]}], {CALL_REGS[i]}")
    # callee-saved (we use rbx, r12 in body possibly)
    cg.emit("    push rbx")
    cg.emit("    push r12")
    # body
    next_off=[-8*(len(params)+1)]  # start after params
    st=FnState(cg,scope,next_off,local_size)
    st.epilogue=f".fn_end_{cg.lbl}_{name}"
    for stmt in fn["body"]:
        gen_stmt(st,stmt)
    cg.emit(f"{st.epilogue}:")
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
        cg.emit(f"    mov [rbp{off}], rax")
    elif k=="assign":
        lhs=s["lhs"]
        if lhs["k"]!="ident":
            raise SyntaxError("only simple variable assignment supported")
        if lhs["name"] not in st.scope:
            raise SyntaxError(f"unknown var {lhs['name']}")
        gen_expr(st,s["rhs"])
        off=st.scope[lhs["name"]]
        cg.emit(f"    mov [rbp{off}], rax")
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
            cg.emit(f"    mov rax, [rbp{st.scope[n]}]")
        elif n in cg.consts:
            cg.emit(f"    mov rax, {cg.consts[n]}")
        elif n in cg.str_defs:
            cg.emit(f"    lea rax, [rel {cg.str_defs[n]}]")
        else:
            raise SyntaxError(f"unknown identifier {n}")
    elif k=="addr":
        n=e["name"]
        if n in cg.str_defs:
            cg.emit(f"    lea rax, [rel {cg.str_defs[n]}]")
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
        gen_expr(st,e["lhs"]); cg.emit("    push rax")
        gen_expr(st,e["rhs"]); cg.emit("    mov rcx, rax"); cg.emit("    pop rax")
        op=e["op"]
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
                gen_expr(st,args[0]); cg.emit("    mov eax, [rax]")
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
        if len(args)>6: raise SyntaxError("call has max 6 args")
        for a in args:
            gen_expr(st,a); cg.emit("    push rax")
        for reg in reversed(CALL_REGS[:len(args)]):
            cg.emit(f"    pop {reg}")
        if name in getattr(cg,"local_fns",set()):
            cg.emit(f"    call {cg.prefix}_{name}")
        else:
            cg.externs.add(name)
            cg.emit(f"    call {name}")
    else:
        raise SyntaxError(f"bad expr {k}")

# -------------------- driver --------------------
def resolve_use(name, lib_dir):
    path=os.path.join(lib_dir, name.replace(".", os.sep)+".nxh")
    if not os.path.isfile(path):
        raise FileNotFoundError(f"use {name}: {path} not found")
    return path

def compile_file(path, lib_dir, app_prefix=None):
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
    return compile_unit(expanded, "app_hl_"+prefix)

def main():
    import argparse
    ap=argparse.ArgumentParser()
    ap.add_argument("input")
    ap.add_argument("-o","--output",required=True)
    ap.add_argument("-L","--lib",default=os.path.join(os.path.dirname(__file__),"..","lib"))
    ap.add_argument("--prefix",default=None)
    args=ap.parse_args()
    asm=compile_file(args.input, os.path.abspath(args.lib), args.prefix)
    with open(args.output,"w",encoding="utf-8",newline="\n") as f: f.write(asm)
    print(f"[nxhc] {args.input} -> {args.output} ({len(asm)} bytes)")

if __name__=="__main__":
    main()
