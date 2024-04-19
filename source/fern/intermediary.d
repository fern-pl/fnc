module fern.intermediary;

import gallinule.x86;

public enum OpCode
{
    add,
    sub,
    mul,
    div,
    pow,
    mod,
    shl,
    shr,
    shls,
    xor,
    and,
    or,
    not,
    neg,
    por,
    pand,
    mref,
    index,
    slice,
    move,
    cmp,
    jmp,
    dcast,
    pconv,
    cmove,
    concat,
    call,
    ret,
    //contains
}

public enum Modifiers
{
    FLOAT = 1 << 0,
    POINTER = 1 << 1,
    DYNAMIC_ARRAY = 1 << 2,
    MEMORY_LITERAL = 1 << 3,
    VALUE_LITERAL = 1 << 4,
}

public struct Function
{
public:
final:
    Variable ret;
    Variable[string] variables;
    Instruction[] instrs;
}

public struct Instruction
{
public:
final:
    OpCode opcode;
    string[] operands;
}

public struct Type
{
public:
final:
    size_t size;
    Modifiers modifiers;
    Variable[] fields;
}

public struct Variable
{
public:
final:
    union
    {
        uint[] markers;
        size_t offset;
    }
    Type type;

    this(T)(T val)
    {
        static if (is(T : U*, U))
        {
            type = Type(0, Modifiers.MEMORY_LITERAL);
            *cast(T*)&markers = val;
        }
        else
        {
            type = Type(T.sizeof, Modifiers.VALUE_LITERAL);
            *cast(T*)&markers = val;
        }
    }
}

public:
static:
ST[] floats = [st0, st1, st2, st3, st4, st5, st6, st7];
R8[] bytes = [al, cl, dl, bl, ah, ch, dh, bh, spl, bpl, sil, dil, r8b, r9b, r10b, r11b, r12b, r13b, r14b, r15b];
R16[] words = [ax, cx, dx, bx, sp, bp, si, di, r8w, r9w, r10w, r11w, r12w, r13w, r14w, r15w];
R32[] dwords = [eax, ecx, edx, ebx, esp, ebp, esi, edi, r8d, r9d, r10d, r11d, r12d, r13d, r14d, r15d];
R64[] qwords = [rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15];
MMX[] mmx = [mm0, mm1, mm2, mm3, mm4, mm5, mm6, mm7];
XMM[] xmm = [xmm0, xmm1, xmm2, xmm3, xmm4, xmm5, xmm6, xmm7, xmm8, xmm9, xmm10, xmm11, xmm12, xmm13, xmm14, xmm15];
YMM[] ymm = [ymm0, ymm1, ymm2, ymm3, ymm4, ymm5, ymm6, ymm7, ymm8, ymm9, ymm10, ymm11, ymm12, ymm13, ymm14, ymm15];