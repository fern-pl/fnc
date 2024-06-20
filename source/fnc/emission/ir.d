module fnc.emission.ir;

import gallinule.x86;
import fnc.symbols;
import std.traits;
import tern.meta;

public enum OpCode : ushort
{
    // Abstracted instructions:
    //  MOV
    //  CALL
    //  ADD
    //  SUB
    //  MUL
    //  DIV
    //  XOR
    //  AND
    //  OR
    //  NEG
    //  NOT
    //  SYSCALL
    FREE,
    ALLOC,
    LOOPRCC,
    
    CRIDVME,
    CRIDPVI,
    CRIDTSD,
    CRIDDE,
    CRIDPSE,
    CRIDPAE,
    CRIDMCE,
    CRIDPGE,
    CRIDPCE,
    CRIDOSFXSR,
    CRIDOSXMMEXCPT,
    CRIDUMIP,
    CRIDVMXE,
    CRIDSMXE,
    CRIDFSGSBASE,
    CRIDPCIDE,
    CRIDOSXSAVE,
    CRIDSMEP,
    CRIDSMAP,
    CRIDPKE,
    CRIDCET,
    CRIDPKS,
    CRIDUINTR,

    IDAVX512VL,
    IDAVX512BW,
    IDSHA,
    IDAVX512CD,
    IDAVX512ER,
    IDAVX512PF,
    IDPT,
    IDCLWB,
    IDCLFLUSHOPT,
    IDPCOMMIT,
    IDAVX512IFMA,
    IDSMAP,
    IDADX,
    IDRDSEED,
    IDAVX512DQ,
    IDAVX512F,
    IDPQE,
    IDRTM,
    IDINVPCID,
    IDERMS,
    IDBMI2,
    IDSMEP,
    IDFPDP,
    IDAVX2,
    IDHLE,
    IDBMI1,
    IDSGX,
    IDTSCADJ,
    IDFSGSBASE,
    
    IDPREFETCHWT1,
    IDAVX512VBMI,
    IDUMIP,
    IDPKU,
    IDAVX512VBMI2,
    IDCET,
    IDOSPKE,
    IDGFNI,
    IDVAES,
    IDVPCL,
    IDAVX512VNNI,
    IDAVX512BITALG,
    IDTME,
    IDAVX512VP,
    IDVA57,
    IDRDPID,
    IDSGXLC,
    
    IDAVX512QVNNIW,
    IDAVX512QFMA,
    IDPCONFIG,
    IDIBRSIBPB,
    IDSTIBP,

    IDSSE3,
    IDPCLMUL,
    IDDTES64,
    IDMON,
    IDDSCPL,
    IDVMX,
    IDSMX,
    IDEST,
    IDTM2,
    IDSSSE3,
    IDCID,
    IDSDBG,
    IDFMA,
    IDCX16,
    IDXTPR,
    IDPDCM,
    IDPCID,
    IDDCA,
    IDSSE41,
    IDSSE42,
    IDX2APIC,
    IDMOVBE,
    IDPOPCNT,
    IDTSCD,
    IDAES,
    IDXSAVE,
    IDOSXSAVE,
    IDAVX,
    IDF16C,
    IDRDRAND,
    IDHV,

    IDFPU,
    IDVME,
    IDDE,
    IDPSE,
    IDTSC,
    IDMSR,
    IDPAE,
    IDCX8,
    IDAPIC,
    IDSEP,
    IDMTRR,
    IDPGE,
    IDMCA,
    IDCMOV,
    IDPAT,
    IDPSE36,
    IDPSN,
    IDCLFL,
    IDDS,
    IDACPI,
    IDMMX,
    IDFXSR,
    IDSSE,
    IDSSE2,
    IDSS,
    IDHTT,
    IDTM,
    IDIA64,
    IDPBE,
    //
    PFADD,
    PFSUB,
    PFSUBR,
    PFMUL,

    PFCMPEQ,
    PFCMPGE,
    PFCMPGT,

    PF2ID,
    PI2FD,
    PF2IW,
    PI2FW,

    PFMAX,
    PFMIN,

    PFRCP,
    PFRSQRT,
    PFRCPIT1,
    PFRSQIT1,
    PFRCPIT2,

    PFACC,
    PFNACC,
    PFPNACC,
    PMULHRW,

    PAVGUSB,
    PSWAPD,

    FEMMS,
    //
    ICEBP,
    //
    PTWRITE,
    //
    CLWB,
    //
    CLFLUSHOPT,
    //
    STAC,
    CLAC,
    //
    ADC,
    ADCX,
    ADOX,
    //
    RDSEED,
    //
    BNDCL,
    BNDCU,
    BNDCN,
    BNDLDX,
    BNDSTX,
    BNDMK,
    BNDMOV,
    BOUND,
    //
    XEND,
    XABORT,
    XBEGIN,
    XTEST,
    //
    INVPCID,
    //
    XACQUIRE,
    XRELEASE,
    //
    TZCNT,
    LZCNT,
    ANDN,
    //
    ECREATE,
    EADD,
    EINIT,
    EREMOVE,
    EDBGRD,
    EDBGWR,
    EEXTEND,
    ELDB,
    ELDU,
    EBLOCK,
    EPA,
    EWB,
    ETRACK,
    EAUG,
    EMODPR,
    EMODT,
    ERDINFO,
    ETRACKC,
    ELDBC,
    ELDUC,
    
    EREPORT,
    EGETKEY,
    EENTER,
    ERESUME,
    EEXIT,
    EACCEPT,
    EMODPE,
    EACCEPTCOPY,
    EDECCSSA,

    EDECVIRTCHILD,
    EINCVIRTCHILD,
    ESETCONTEXT,
    //
    MONITOR,
    MWAIT,
    //
    INVVPID,
    INVEPT,

    VMCALL,
    VMFUNC,
    VMCLEAR,
    VMLAUNCH,
    VMRESUME,
    VMXOFF,
    VMXON,

    VMWRITE,
    VMREAD,

    VMPTRST,
    VMPTRLD,
    //
    CAPABILITIES,
    ENTERACCS,
    EXITAC,
    SENTER,
    SEXIT,
    PARAMETERS,
    SMCTRL,
    WAKEUP,
    //
    CMPXCHG16B,
    //
    POPCNT,
    //
    XGETBV,
    XSETBV,

    XRSTOR,
    XSAVE,

    XRSTORS,
    XSAVES,

    XSAVEOPT,
    XSAVEC,
    //
    RDRAND,
    //
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
    FLDPI,
    FLDLG2,
    FLDLN2,
    FLDZ,

    FST,
    FSTP,

    FDIV,
    FDIVP,
    FIDIV,

    FDIVR,
    FDIVRP,
    FIDIVR,

    FSCALE,
    FRNDINT,
    FEXAM,
    FFREE,
    FXCH,
    FXTRACT,

    FNOP,
    FNINIT,
    FINIT,

    FSAVE,
    FNSAVE,

    FRSTOR,
    FXSAVE,

    FXRSTOR,

    FMUL,
    FMULP,
    FIMUL,

    FSUB,
    FSUBP,
    FISUB,

    FSUBR,
    FSUBRP,
    FISUBR,

    FCMOVCC,
    //
    RDMSR,
    WRMSR,
    //
    CMPXCHG8B,
    //
    SYSENTER,
    SYSEXITC,
    SYSEXIT,
    //
    CMOVCC,
    //
    CLFLUSH,
    //
    HRESET,
    //
    INCSSPD,
    INCSSPQ,
    CLRSSBSY,
    SETSSBSY,

    RDSSPD,
    RDSSPQ,
    WRSSD,
    WRSSQ,
    WRUSSD,
    WRUSSQ,

    RSTORSSP,
    SAVEPREVSSP,

    ENDBR32,
    ENDBR64,

    RDFSBASE,
    RDGSBASE,

    WRFSBASE,
    WRGSBASE,
    //
    RDPID,
    //
    WRPKRU,
    RDPKRU,
    //
    RDTSC,
    RDTSCP,
    //
    TESTUI,
    STUI,
    CLUI,
    UIRET,
    SENDUIPI,
    //
    UMWAIT,
    UMONITOR,
    TPAUSE,
    //
    CLDEMOTE,
    //
    XRESLDTRK,
    XSUSLDTRK,
    //
    SERIALIZE,
    //
    PCONFIG,
    //
    RDPMC,
    //
    WBINVD,
    WBNOINVD,

    INVD,

    LGDT,
    SGDT,

    LLDT,
    SLDT,

    LIDT,
    SIDT,

    LMSW,
    SMSW,
    //
    INVLPG,
    //
    SAHF,
    LAHF,
    //
    SARX,
    SHLX,
    SHRX,
    //
    MOVQ,
    MOVD,
    //
    ADDPD,
    ADDPS,
    ADDSS,
    ADDSD,
    //
    LFENCE,
    SFENCE,
    MFENCE,
    //
    ADDSUBPS,
    ADDSUBPD,
    //
    VADDPD,
    VADDPS,
    VADDSD,
    VADDSS,

    VADDSUBPD,
    VADDSUBPS,

    VMOVQ,
    VMOVD,
    //
    AESDEC,
    VAESDEC,

    AESDEC128KL,
    AESDEC256KL,

    AESDECLAST,
    VAESDECLAST,

    AESDECWIDE128KL,
    AESDECWIDE256KL,

    AESENC,
    VAESENC,

    AESENC128KL,
    AESENC256KL,

    AESENCLAST,
    VAESENCLAST,

    AESENCWIDE128KL,
    AESENCWIDE256KL,

    AESIMC,
    VAESIMC,

    AESKEYGENASSIST,
    VAESKEYGENASSIST,
    //
    SHA1MSG1,
    SHA1MSG2,
    SHA1NEXTE,

    SHA256MSG1,
    SHA1RNDS4,
    SHA256RNDS2,
    //
    //NOT_TAKEN,
    //TAKEN,
    CRC32,

    ENDQCMD,

    CMPXCHG,

    AAA,
    AAD,
    AAM,
    AAS,
    ADD,
    AND,

    ARPL,

    BSF,
    BSR,
    BSWAP,
    BT,
    BTC,
    BTR,
    BTS,
    
    CMP,

    CWD,
    CDQ,
    CQO,

    CBW,
    CWDE,
    CDQE,

    CPUID,

    CLC,
    CLD,
    CLI,
    CLTS,
    CMC,

    DEC,

    INT,
    INTO,
    UD,
    IRET,

    INC,

    HLT,
    PAUSE,
    SWAPGS,

    WAIT,
    FWAIT,

    SYSRETC,
    SYSRET,
    SYSCALL,
    RSM,

    LEAVE,
    ENTER,

    LEA,
    LDS,
    LSS,
    LES,
    LFS,
    LGS,
    LSL,
    
    LTR,
    STR,

    NEG,
    NOP,
    NOT,

    RET,
    RETF,

    STC,
    STD,
    STI,

    SUB,
    SBB,

    XOR,
    OR,

    SAL,
    SAR,
    SHL,
    SHR,

    RCL,
    RCR,
    ROL,
    ROR,

    VERR,
    VERW,

    TEST,

    POP,
    POPDS,
    POPES,
    POPSS,
    POPFS,
    POPGS,
    POPA,
    POPF,

    PUSH,
    PUSHCS,
    PUSHSS,
    PUSHDS,
    PUSHES,
    PUSHFS,
    PUSHGS,
    PUSHA,
    PUSHF,

    XADD,
    XCHG,
    XLAT,
    XLATB,

    LAR,

    DAA,
    DAS,

    MUL,
    IMUL,
    DIV,
    IDIV,

    MOV,
    MOVSX,
    MOVSXD,
    MOVZX,
    MOVS,
    MOVSB,
    MOVSW,
    MOVSD,
    MOVSQ,

    CALL,
    LOOPCC,
    JMP,
    JCC,
    REPCC,

    CMPS,
    CMPSB,
    CMPSW,
    CMPSD,
    CMPSQ,

    SCAS,
    SCASB,
    SCASW,
    SCASD,
    SCASQ,

    LODS,
    LODSB,
    LODSW,
    LODSD,
    LODSQ,

    STOS,
    STOSB,
    STOSW,
    STOSD,
    STOSQ,

    IN,
    INS,
    INSB,
    INSW,
    INSD,

    OUT,
    OUTS,
    OUTSB,
    OUTSW,
    OUTSD,

    SETCC
}

public enum Details
{
    // PUSHA, POPA, RET and CALL require special parsing
    READ1 = 1 << 0,
    READ2 = 1 << 1,
    READ3 = 1 << 2,
    WRITE1 = 1 << 3,
    WRITE2 = 1 << 4,
    WRITE3 = 1 << 5,

    POLLUTE_AX = 1 << 6,
    POLLUTE_BX = 1 << 7,
    POLLUTE_CX = 1 << 8,
    POLLUTE_DX = 1 << 9,

    // These are not opcode defined
    GREATER = 1 << 10,
    GREATEREQ = 1 << 11,
    LESSER = 1 << 12,
    LESSEREQ = 1 << 13,
    EQUAL = 1 << 14,
    NEQUAL = 1 << 15,
    CARRY = 1 << 16,
    NCARRY = 1 << 17,
    SIGN = 1 << 18,
    NSIGN = 1 << 19,
    ZERO = 1 << 20,
    NZERO = 1 << 21,
    TAKEN = 1 << 22,
    NOT_TAKEN = 1 << 23,
    LOCK = 1 << 24,
}

public enum Kind : ubyte
{
    NONE,
    LITERAL,
    ALLOCATION,
    REGISTER
}

public struct Marker
{
public:
final:
    /// This is for internal marking allocation, not symbols!
    Kind kind;
    /// ditto
    size_t size;
    /// ditto
    int score;
    union
    {
        struct //asAllocation
        {
            /// ditto
            ubyte segment = ds;
            /// ditto
            uint offset;
            /// ditto
            short baseSize;
            // Will cause problems? Extended registers, dunno
            /// ditto
            ubyte baseIndex = 255;
        }

        struct //asRegister
        {
            /// ditto
            ubyte index;
            /// ditto
            bool extended;
        }

        struct //asLiteral
        {
            union
            {
                /// ditto
                ubyte b;
                /// ditto
                ushort w;
                /// ditto
                uint d;
                /// ditto
                ulong q;
            }
        }
    }

    this(size_t size, uint offset, ubyte segment = ds, short baseSize = 8, ubyte baseIndex = 255)
    {
        this.kind = Kind.ALLOCATION;
        this.size = size;
        this.segment = segment;
        this.offset = offset;
        this.baseSize = baseSize;
        this.baseIndex = baseIndex;
    }

    this(size_t size, ubyte index, bool extended)
    {
        this.kind = Kind.REGISTER;
        this.size = size;
        this.index = index;
        this.extended = extended;
    }

    this(T)(T val)
    {
        this.kind = Kind.LITERAL;
        this.size = T.sizeof * 8;

        /* static if (is(T : U*, U))
        {
            type = Type(0, Modifiers.MEMORY_LITERAL);
            ptr = cast(void*)val;
        }
        else static if (is(T == string))
            name = val; */
        static if (T.sizeof == 1)
            b = cast(ubyte)val;
        else static if (T.sizeof == 2)
            w = cast(ushort)val;
        else static if (T.sizeof == 4)
            d = cast(uint)val;
        else static if (T.sizeof == 8)
            q = cast(ulong)val;
    }
}

package class RM(short SIZE) { }
package class Reg(short SIZE) { }
package class Addr(short SIZE) { }
package class Literal { }

public struct Instruction
{
public:
final:
    OpCode opcode;
    Symbol[] operands;
    Details details;
    int score;

    Marker first() => operands[0];
    Marker second() => operands[1];
    Marker third() => operands[2];

    bool format(FMT...)()
    {
        if (FMT.length != operands.length)
            return false;

        foreach (i, k; FMT)
        {
            if (is(k == Literal) && operands[i].kind != Kind.LITERAL)
                return false;
            else if (is(k == ubyte) && operands[i].size != 8)
                return false;
            else if (is(k == ushort) && operands[i].size != 16)
                return false;
            else if (is(k == uint) && operands[i].size != 32)
                return false;
            else if (is(k == ulong) && operands[i].size != 64)
                return false;
            else static if (isInstanceOf!(RM, k))
            {
                if ((operands[i].kind != Kind.REGISTER && operands[i].kind != Kind.ALLOCATION) || TemplateArgsOf!(k)[0] != operands[i].size)
                    return false;
            }
            else static if (isInstanceOf!(Reg, k))
            {
                if (operands[i].kind != Kind.REGISTER || TemplateArgsOf!(k)[0] != operands[i].size)
                    return false;
            }
            else static if (isInstanceOf!(Addr, k))
            {
                if (operands[i].kind != Kind.ALLOCATION || TemplateArgsOf!(k)[0] != operands[i].size)
                    return false;
            }
            else
                assert(0, "kill yourself");
        }
        return true;
    }

    this(ARGS...)(OpCode opcode, ARGS args)
    {
        Symbol[] operands;
        foreach (arg; args)
        {
            static if (is(Unqual!(typeof(arg)) == Symbol))
                operands ~= cast(Symbol)arg;
            else
            {
                SymAttr attr = SymAttr.LITERAL;
                // We don't check for if its a vector, but this shouldn't matter.
                static if (is(typeof(arg) == string))
                    attr |= SymAttr.STRING;
                else static if (is(typeof(arg) == ubyte) || is(typeof(arg) == byte))
                    attr |= SymAttr.BYTE;
                else static if (is(typeof(arg) == ushort) || is(typeof(arg) == short))
                    attr |= SymAttr.WORD;
                else static if (is(typeof(arg) == uint) || is(typeof(arg) == int))
                    attr |= SymAttr.DWORD;
                else static if (is(typeof(arg) == ulong) || is(typeof(arg) == long))
                    attr |= SymAttr.QWORD;
                else static if (is(typeof(arg) == float))
                    attr |= SymAttr.FLOAT;
                else static if (is(typeof(arg) == double))
                    attr |= SymAttr.DOUBLE;
                else static if (isArray!(typeof(arg)))
                    attr |= SymAttr.ARRAY;

                static if (isStaticArray!(typeof(arg)))
                    attr |= SymAttr.FIXARRAY;
                else static if (isAssociativeArray!(typeof(arg)))
                    attr |= SymAttr.ASOARRAY;
                else static if (isDynamicArray!(typeof(arg)))
                    attr |= SymAttr.DYNARRAY;

                static if (isSigned!(typeof(arg)))
                    attr |= SymAttr.SIGNED;

                operands ~= new Symbol(attr, null, null, null, null, Marker(arg));
            }   
        }

        Details detail(string fmt) pure
        {
            Details ret;
            foreach (i, c; fmt)
            {
                switch (c)
                {
                    case 'r':
                        if (i == 0)
                            ret |= Details.READ1;
                        else if (i == 1)
                            ret |= Details.READ2;
                        else if (i == 2)
                            ret |= Details.READ3;
                        break;
                    case 'w':
                        if (i == 0)
                            ret |= Details.WRITE1;
                        else if (i == 1)
                            ret |= Details.WRITE2;
                        else if (i == 2)
                            ret |= Details.WRITE3;
                        break;
                    case 'x':
                        if (i == 0)
                            ret |= Details.WRITE1 | Details.READ1;
                        else if (i == 1)
                            ret |= Details.WRITE2 | Details.READ2;
                        else if (i == 2)
                            ret |= Details.WRITE3 | Details.READ3;
                        break;
                    case 'a':
                        ret |= Details.POLLUTE_AX;
                        break;
                    case 'b':
                        ret |= Details.POLLUTE_BX;
                        break;
                    case 'c':
                        ret |= Details.POLLUTE_CX;
                        break;
                    case 'd':
                        ret |= Details.POLLUTE_DX;
                        break;
                    default:
                        break;
                }
            }
            return ret;
        }

        this.opcode = opcode;
        this.operands = operands;

        with (OpCode) switch (opcode)
        {
            // TODO: Floats, add more flags??
            case AAD:
            case AAM:
                if (format!(Literal))
                    details = detail("ra");
                else
                    details = detail("a");
                break;
            case JMP:
            case JCC:
            case LOOPCC:
            case CALL:
                if (format!(RM))
                    details = detail("r");
                break;
            case ADD:
            case SUB:
            case ROL:
            case ROR:
            case RCL:
            case SHL:
            case SHR:
            case SAR:
            case SAL:
            case XOR:
            case OR:
            case AND:
            case BT:
            case BTC:
            case BTR:
            case BTS:
            case TEST:
            case ADC:
                if (operands.length == 1)
                    details = detail("ra");
                else
                    details = detail("xr");
                break;
            case ADCX:
            case ADOX:
            case PFADD:
            case PFSUB:
            case PFSUBR:
            case PFMUL:
            case PFCMPEQ:
            case PFCMPGE:
            case PFCMPGT:
            case PF2ID:
            case PI2FD:
            case PF2IW:
            case PI2FW:
            case PFMAX:
            case PFMIN:
            case PFRCP:
            case PFRSQRT:
            case PFRCPIT1:
            case PFRSQIT1:
            case PFRCPIT2:
            case PFACC:
            case PFNACC:
            case PFPNACC:
            case PMULHRW:
            case PAVGUSB:
            case PSWAPD:
                details = detail("xr");
                break;
            case BNDCL:
            case BNDCU:
            case BNDCN:
            case BNDLDX:
            case BOUND:
            case INVPCID:
            case INVVPID:
            case INVEPT:
            case ARPL:
                details = detail("rr");
                break;
            case LTR:
            case INC:
            case DEC:
            case SETCC:
            case PUSH:
            case NOT:
            case NEG:
            case PTWRITE:
            case CLWB:
            case CLFLUSH:
            case CLFLUSHOPT:
            case VMPTRST:
            case XRSTOR:
            case XRSTORS:
            case SENDUIPI:
            case UMWAIT:
            case UMONITOR:
            case TPAUSE:
            case CLDEMOTE:
            case SGDT:
            case SLDT:
            case SIDT:
            case SMSW:
            case INVLPG:
            case ALLOC:
            case HRESET:
                details = detail("r");
                break;
            case NOP:
                if (operands.length == 1)
                    details = detail("r");
                break;
            case BSWAP:
            case FREE:
                details = detail("x");
                break;
            case STR:
            case POP:
            case RDSEED:
            case RDRAND:
            case VMCLEAR:
            case VMXON:
            case VMPTRLD:
            case XSAVE:
            case XSAVES:
            case XSAVEOPT:
            case XSAVEC:
            case LLDT:
            case LGDT:
            case LIDT:
            case LMSW:
                details = detail("w");
                break;
            case CMPXCHG16B:
            case CMPXCHG8B:
                details = detail("xabcd");
                break;
            case CMPXCHG:
                details = detail("xra");
                break;
            case IDIV:
            case DIV:
            case MUL:
                details = detail("xad");
                break;
            case IMUL:
                if (operands.length == 1)
                    details = detail("rad");
                else
                    details = detail("xr");
                break;
            case MOVSX:
            case MOVSXD:
            case MOVZX:
            case MOV:
            case LEA:
            case LDS:
            case LSS:
            case LES:
            case LFS:
            case LGS:
            case LSL:
            case CMOVCC:
            case LZCNT:
            case TZCNT:
            case BSF:
            case BSR:
            case BNDSTX:
            case BNDMK:
            case BNDMOV:
            case VMREAD:
            case POPCNT:
                details = detail("wr");
                break;
            case CRIDCET:
            case CRIDDE:
            case CRIDFSGSBASE:
            case CRIDMCE:
            case CRIDOSFXSR:
            case CRIDOSXMMEXCPT:
            case CRIDOSXSAVE:
            case CRIDPAE:
            case CRIDPCE:
            case CRIDPCIDE:
            case CRIDPGE:
            case CRIDPKE:
            case CRIDPKS:
            case CRIDPSE:
            case CRIDPVI:
            case CRIDSMAP:
            case CRIDSMEP:
            case CRIDSMXE:
            case CRIDTSD:
            case CRIDUMIP:
            case CRIDUINTR:
            case CRIDVME:
            case CRIDVMXE:
            case ECREATE:
            case EADD:
            case EINIT:
            case EREMOVE:
            case EDBGRD:
            case EDBGWR:
            case EEXTEND:
            case ELDB:
            case ELDU:
            case EBLOCK:
            case EPA:
            case EWB:
            case ETRACK:
            case EAUG:
            case EMODPR:
            case EMODT:
            case ERDINFO:
            case ETRACKC:
            case ELDBC:
            case ELDUC:
            case EREPORT:
            case EGETKEY:
            case EENTER:
            case ERESUME:
            case EEXIT:
            case EACCEPT:
            case EMODPE:
            case EACCEPTCOPY:
            case EDECCSSA:
            case EDECVIRTCHILD:
            case EINCVIRTCHILD:
            case ESETCONTEXT:
            case CAPABILITIES:
            case ENTERACCS:
            case EXITAC:
            case SENTER:
            case SEXIT:
            case PARAMETERS:
            case SMCTRL:
            case WAKEUP:
            case RDPKRU:
            case WRPKRU:
            case LAHF:
            case SAHF:
            case CPUID:
            case VMFUNC:
            case RDTSC:
            case RDTSCP:
            case AAA:
            case AAS:
                details = detail("a");
                break;
            case IDACPI:
            case IDADX:
            case IDAES:
            case IDAPIC:
            case IDAVX:
            case IDAVX2:
            case IDAVX512BITALG:
            case IDAVX512BW:
            case IDAVX512CD:
            case IDAVX512DQ:
            case IDAVX512ER:
            case IDAVX512F:
            case IDAVX512IFMA:
            case IDAVX512PF:
            case IDAVX512QFMA:
            case IDAVX512QVNNIW:
            case IDAVX512VBMI:
            case IDAVX512VBMI2:
            case IDAVX512VL:
            case IDAVX512VNNI:
            case IDAVX512VP:
            case IDBMI1:
            case IDBMI2:
            case IDCET:
            case IDOSPKE:
            case IDCID:
            case IDCLFL:
            case IDCLFLUSHOPT:
            case IDCLWB:
            case IDCMOV:
            case IDCX16:
            case IDCX8:
            case IDDCA:
            case IDDTES64:
            case IDDE:
            case IDDS:
            case IDDSCPL:
            case IDERMS:
            case IDEST:
            case IDF16C:
            case IDFMA:
            case IDFPDP:
            case IDFPU:
            case IDFSGSBASE:
            case IDFXSR:
            case IDGFNI:
            case IDHLE:
            case IDHTT:
            case IDHV:
            case IDIA64:
            case IDIBRSIBPB:
            case IDINVPCID:
            case IDMCA:
            case IDMMX:
            case IDMON:
            case IDMOVBE:
            case IDMSR:
            case IDMTRR:
            case IDOSXSAVE:
            case IDPAE:
            case IDPAT:
            case IDPBE:
            case IDPCID:
            case IDPCLMUL:
            case IDPCOMMIT:
            case IDPCONFIG:
            case IDPDCM:
            case IDPGE:
            case IDPKU:
            case IDPOPCNT:
            case IDPQE:
            case IDPREFETCHWT1:
            case IDPSE:
            case IDPSE36:
            case IDPSN:
            case IDPT:
            case IDRDPID:
            case IDRDRAND:
            case IDRDSEED:
            case IDRTM:
            case IDSDBG:
            case IDSEP:
            case IDSGX:
            case IDSGXLC:
            case IDSHA:
            case IDSMAP:
            case IDSMEP:
            case IDSMX:
            case IDSS:
            case IDSSE:
            case IDSSE2:
            case IDSSE3:
            case IDSSE41:
            case IDSSE42:
            case IDSSSE3:
            case IDSTIBP:
            case IDTM:
            case IDTM2:
            case IDTME:
            case IDTSC:
            case IDTSCADJ:
            case IDTSCD:
            case IDUMIP:
            case IDVA57:
            case IDVAES:
            case IDVME:
            case IDVMX:
            case IDVPCL:
            case IDX2APIC:
            case IDXSAVE:
            case IDXTPR:
            case RDMSR:
            case WRMSR:
            case RDPMC:
            case PCONFIG:
                details = detail("abcd");
                break;
            case RET:
            case INT:
            case STAC:
            case STC:
            case STD:
            case STI:
            case CLAC:
            case CLC:
            case CLD:
            case CLI:
            case SYSCALL:
            case SYSENTER:
            case SYSEXIT:
            case SYSEXITC:
            case INTO:
            case RETF:
            case FEMMS:
            case ICEBP:
            case XEND:
            case XABORT:
            case XBEGIN:
            case XTEST:
            case XACQUIRE:
            case XRELEASE:
            case MONITOR:
            case MWAIT:
            case VMCALL:
            case VMLAUNCH:
            case VMRESUME:
            case VMXOFF:    
            case XGETBV:
            case XSETBV:
            case REPCC:
            case TESTUI:
            case STUI:
            case CLUI:
            case UIRET:
            case XRESLDTRK:
            case XSUSLDTRK:
            case SERIALIZE:
            case WBINVD:
            case WBNOINVD:
            case INVD:
            case CLTS:
            case CMC:
            case IRET:
            case HLT:
            case PAUSE:
            case SWAPGS:
            case WAIT:
            case FWAIT:
            case RSM:
            case LEAVE:
                break;
            case ANDN:
            case SARX:
            case SHLX:
            case SHRX:
                details = detail("wrr");
                break;
            case UD:
                if (operands[0].d != 2)
                    details = detail("rr");
                break;
            default:
                assert(0, "Unimplemented instruction opcode!");
                break;
        }
    }
}

/* public struct Function
{
public:
final:
    Symbol[string] locals;
    Instruction[] instructions;

    void init()
    {
        foreach (i, ref instr; instructions)
        {
            foreach (j, ref operand; instr.operands)
            {
                if (operand.name == null || locals[operand.name].score != 0)
                    continue;
                
                if (instr.details.hasFlag(Details.READ1) != 0 && j == 0)
                    instructions = Instruction(OpCode.XOR, operand, operand)~instructions;
                else if (instr.details.hasFlag(Details.READ2) != 0 && j == 1)
                    instructions = Instruction(OpCode.XOR, operand, operand)~instructions;
                else if (instr.details.hasFlag(Details.READ3) && j == 2)
                    instructions = Instruction(OpCode.XOR, operand, operand)~instructions;

                if (locals[operand.name].modifiers.hasFlag(TypeModifiers.STRING))
                    locals[operand.name].score = int.max - 1;
                else if (locals[operand.name].modifiers.hasFlag(TypeModifiers.VECTOR))
                    locals[operand.name].score = int.max;
                else
                    locals[operand.name].score++;
            }
        }
    }
} */

public interface IStager
{
    ubyte[] finalize();
    ptrdiff_t label(string name);
    size_t stage(Instruction instr);
}