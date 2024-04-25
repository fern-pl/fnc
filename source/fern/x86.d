module fern.x86;

import gallinule.x86;

public enum OpCode : ubyte
{
    AAA,
    AAD,
    AAM,
    AAS,
    ADCX,
    ADD,
    ADOX,
    AND,
    ANDN,
    ARPL,
    BSF,
    BSR,
    BSWAP,
    BT,
    BTC,
    BTR,
    BTS,
    CALL,
    CBW,
    CDQ,
    CDQE,
    CLAC,
    CLC,
    CLD,
    STC,
    STD,
    STI,
    STAC,
    TEST,
    CLDEMOTE,
    CLFLUSH,
    CLFLUSHOPT,
    CLI,
    CMOV,
    CMP,
    CMPXCHG,
    CMPXCHG8B,
    CMPXCHG16B,
    CPUID,
    CQO,
    CWD,
    CWDE,
    DAA,
    DAS,
    DEC,
    DIV,
    HLT,
    IDIV,
    IMUL,
    INC,
    INT,
    JMP,
    LEA,
    LOCK,
    LZCNT,
    TZCNT,
    MOV,
    MOVSX,
    MOVSXD,
    MOVZX,
    MUL,
    NEG,
    NOT,
    NOP,
    OR,
    POP,
    PUSH,
    POPA,
    PUSHA,
    POPF,
    PUSHF,
    ROL,
    ROR,
    POR,
    PAND,
    SUB,
    RET,
    SHL,
    SHR,
    SET,
    XOR,
    RDSEED,
    RDRAND,
    XACQUIRE,
    XACQUIRE_LOCK,
    LOCK,
    XRELEASE,
    POPCNT,
    FABS,
    FCHS,
    FCLEX,
    FNCLEX,
    FADD,
    FADDP,
    FIADD,
    FBLD,
    FBSTP,
    FCOM,
    FCOMP,
    FCOMPP,
    FCOMI,
    FCOMIP,
    FUCOMI,
    FUCOMIP,
    FICOM,
    FICOMP,
    FUCOM,
    FUCOMP,
    FUCOMPP,
    FTST,
    F2XM1,
    FYL2X,
    FYL2XP1,
    FCOS,
    FSIN,
    FSINCOS,
    FSQRT,
    FPTAN,
    FPATAN,
    FPREM,
    FPREM1,
    FDECSTP,
    FINCSTP,
    FILD,
    FIST,
    FISTP,
    FISTTP,
    FLDCW,
    FSTCW,
    FNSTCW,
    FLDENV,
    FSTENV,
    FNSTENV,
    FSTSW,
    FNSTSW,
    FLD,
    FLD1,
    FLDL2T,
    FLDL2E,
}

public enum Detail
{
    // PUSHA, POPA, RET and CALL require special parsing
    READ1 = 1 << 0,
    READ2 = 1 << 1,
    READ3 = 1 << 2,
    WRITE1 = 1 << 3,
    WRITE2 = 1 << 4,
    WRITE3 = 1 << 5,

    // These are not opcode defined
    GREATER = 255,
    GREATEREQ = 254,
    LESSER = 253,
    LESSEREQ = 252,
    EQUAL = 251,
    NEQUAL = 250,
    CARRY = 249,
    NCARRY = 248,
    SIGN = 247,
    NSIGN = 246,
    ZERO = 251,
    NZERO = 250
}

public enum Modifiers : ubyte
{
    FLOAT = 1 << 0,
    POINTER = 1 << 1,
    ARRAY = 1 << 2,
    // 1 << 3
    BYTE = 1 << 4,
    WORD = 1 << 5,
    DWORD = 1 << 6,
    QWORD = 1 << 7,

    MASK = 0b11100000
}

public struct Function
{
private:
final:
    Variable[string] variables;
    Instruction[] instructions;

    // pollution and bartering need to be handled

    void prepare()
    {
        foreach (i, ref instr; instructions)
        {
            foreach (j, ref operand; instr.operands)
            {
                if ((variables[operand].type.modifiers & Modifiers.MASK) == 0 ||
                    variables[operand].visited)
                    continue;
                
                if ((instr.detail & Detail.READ1) != 0 && j == 0)
                    instructions = Instruction(OpCode.XOR, operand, operand)~instructions;
                else if ((instr.detail & Detail.READ2) != 0 && j == 1)
                    instructions = Instruction(OpCode.XOR, operand, operand)~instructions;
                else if ((instr.detail & Detail.READ3) != 0 && j == 2)
                    instructions = Instruction(OpCode.XOR, operand, operand)~instructions;

                variables[operand].visited = true;

                if (variables[operand].type.size <= 1 && bytes.length >= 1)
                {
                    variables[operand].markers ~= 100 | bytes[0].index;

                    if (bytes.length > 1)
                        bytes = bytes[1..$];
                    else
                        bytes = null;
                }
                else if (variables[operand].type.size <= 2 && words.length >= 1)
                {
                    variables[operand].markers ~= 100 | words[0].index;

                    if (words.length > 1)
                        words = words[1..$];
                    else
                        words = null;
                }
                else if (variables[operand].type.size <= 4 && dwords.length >= 1)
                {
                    variables[operand].markers ~= 100 | dwords[0].index;

                    if (dwords.length > 1)
                        dwords = dwords[1..$];
                    else
                        dwords = null;
                }
                else if (variables[operand].type.size <= 8 && qwords.length >= 1)
                {
                    variables[operand].markers ~= 100 | qwords[0].index;

                    if (qwords.length > 1)
                        qwords = qwords[1..$];
                    else
                        qwords = null;
                }
            }
        }
        import std.stdio;
        debug writeln(instructions);
    }
}

public struct Instruction
{
public:
final:
    OpCode opcode;
    string[] operands;
    Detail detail;
    byte score;

    this(OpCode opcode, string[] operands...)
    {
        this.opcode = opcode;
        this.operands = operands;

        with (OpCode) switch (opcode)
        {
            case ADD:
            case SUB:
            case MUL:
            case DIV:
            case IMUL:
            case IDIV:
            case ROL:
            case ROR:
            case SHL:
            case SHR:
            case XOR:
            case AND:
            case OR:
            case POR:
            case PAND:
            case ANDN:
            case BT:
            case BTC:
            case BTR:
            case BTS:
            case TEST:
                detail = Detail.READ1 | Detail.READ2;
                break;
            case NOT:
            case NEG:
            case PUSH:
            case SET:
            case BSWAP:
            case DEC:
            case INC:
                detail = Detail.READ1;
                break;
            case POP:
                detail = Detail.WRITE1;
                break;
            case MOV:
            case MOVSX:
            case MOVSXD:
            case MOVZX:
            case CMOV:
            case LZCNT:
            case TZCNT:
            case BSF:
            case BSR:
            case LEA:
                detail = Detail.WRITE1 | Detail.READ2;
                break;
            default:
                break;
        }
    }
}

public struct Type
{
public:
final:
    size_t size;
    Modifiers modifiers;
    // When setting up types this should have the types and offsets for the variables.
    Variable[] fields;
}

public struct Variable
{
public:
final:
    union
    {
        void* ptr;
        ubyte b;
        ushort w;
        uint d;
        ulong q;

        ushort[] markers;
        size_t offset;
    }
    string name;
    Type type;
    bool visited;

    this(T)(T val)
    {
        static if (is(T : U*, U))
        {
            type = Type(0, Modifiers.MEMORY_LITERAL);
            ptr = cast(void*)val;
        }
        else static if (T.sizeof == 1)
        {
            type = Type(0, Modifiers.BYTE);
            b = cast(ubyte)val;
        }
        else static if (T.sizeof == 2)
        {
            type = Type(0, Modifiers.WORD);
            w = cast(ushort)val;
        }
        else static if (T.sizeof == 4)
        {
            type = Type(0, Modifiers.DWORD);
            d = cast(uint)val;
        }
        else
        {
            type = Type(0, Modifiers.QWORD);
            q = cast(ulong)val;
        }
    }

    this(string name, Type type)
    {
        this.name = name;
        this.type = type;
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
