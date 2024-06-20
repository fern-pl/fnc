/// Code generation facilities for compiler backend.
module fnc.emission.x86;

import fnc.emission.ir;
import fnc.symbols;
import std.typecons;
import std.traits;
import std.bitmanip;

public enum CRID
{
    VME,
    PVI,
    TSD,
    DE,
    PSE,
    PAE,
    MCE,
    PGE,
    PCE,
    OSFXSR,
    OSXMMEXCPT,
    UMIP,
    // RESERVED
    VMXE = 13,
    SMXE,
    // RESERVED
    FSGSBASE = 16,
    PCIDE,
    OSXSAVE,
    // RESERVED
    SMEP = 20,
    SMAP,
    PKE,
    CET,
    PKS,
    UINTR
}

public enum CPUID7_EBX
{
    FSGSBASE,
    TSC_ADJUST,
    SGX,
    // LZCNT and TZCNT
    BMI1, 
    // XACQUIRE, XRELEASE, XTEST
    HLE,
    AVX2,
    FPDP,
    SMEP,
    BMI2,
    ERMS,
    // INVPCID
    INVPCID, 
    // XBEGIN, XABORT, XEND and XTEST
    RTM, 
    PQM,
    FPCSDS,
    // BND*/BOUND
    MPX, 
    PQE,
    AVX512F,
    AVX512DQ,
    // RDSEED
    RDSEED,
    // ADCX and ADOX
    ADX, 
    // CLAC and STAC
    SMAP, 
    AVX512IFMA,
    PCOMMIT, 
    // CLFLUSHOPT
    CLFLUSHOPT, 
    // CLWB
    CLWB,
    // PTWRITE 
    PT, 
    AVX512PF,
    AVX512ER,
    AVX512CD,
    SHA,
    AVX512BW,
    AVX512VL
}

public enum CPUID7_ECX
{
    PREFETCHWT1,
    AVX512VBMI,
    UMIP,
    PKU,
    OSPKE,
    AVX512VBMI2 = 6,
    // INCSSP, RDSSP, SAVESSP, RSTORSSP, SETSSBSY, CLRSSBSY, WRSS, WRUSS, ENDBR64, and ENDBR64
    CET,
    GFNI,
    VAES,
    VPCL,
    AVX512VNNI,
    AVX512BITALG,
    TME,
    // VPOPCNT{D,Q}
    AVX512VP,
    VA57 = 16,
    RDPID = 22,
    SGX_LC = 30
}

public enum CPUID7_EDX
{
    AVX512QVNNIW = 2,
    AVX512QFMA = 3,
    PCONFIG = 18,
    IBRS_IBPB = 26,
    STIBP = 27
}

public enum CPUID1_ECX
{
    // FISTTP
    SSE3,
    // PCLMULQDQ
    PCLMUL,
    DTES64,
    // MONITOR/MWAIT
    MON,
    DSCPL,
    // VM*
    VMX,
    SMX,
    EST,
    TM2,
    SSSE3,
    CID,
    SDBG,
    FMA,
    // CMPXCHG16B
    CX16,
    XTPR,
    PDCM,
    PCID,
    DCA,
    SSE4_1,
    SSE4_2,
    X2APIC,
    // MOVBE
    MOVBE,
    // POPCNT
    POPCNT,
    TSCD,
    // AES*
    AES,
    // XGETBV, XSETBV, XSAVEOPT, XSAVE, and XRSTOR
    XSAVE,
    OSXSAVE,
    AVX,
    // VCVTPH2PS and VCVTPS2PH
    F16C,
    // RDRAND
    RDRAND,
    HV
}

public enum CPUID1_EDX
{
    FPU,
    VME,
    DE,
    PSE,
    // RDTSC
    TSC,
    // RDMSR/WRMSR
    MSR,
    PAE,
    // CMPXCHG8B
    CX8,
    APIC,
    // SYSENTER/SYSEXIT
    SEP,
    MTRR,
    PGE,
    MCA,
    // CMOVcc
    CMOV,
    PAT,
    PSE36,
    PSN,
    // CLFLUSH
    CLFL,
    DS,
    ACPI,
    MMX,
    // FXSAVE/FXRSTOR
    FXSR,
    SSE,
    SSE2,
    SS,
    HTT,
    TM,
    IA64,
    PBE
}

public:
static const cr0 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(-1, 0, false));
static const cr2 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(-1, 2, false));
static const cr3 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(-1, 3, false));
static const cr4 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(-1, 4, false));

static const dr0 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(-2, 0, false));
static const dr1 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(-2, 1, false));
static const dr2 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(-2, 2, false));
static const dr3 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(-2, 3, false));
static const dr6 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(-2, 6, false));
static const dr7 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(-2, 7, false));

static const st0 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(-3, 0, false));
static const st1 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(-3, 1, false));
static const st2 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(-3, 2, false));
static const st3 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(-3, 3, false));
static const st4 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(-3, 4, false));
static const st5 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(-3, 5, false));
static const st6 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(-3, 6, false));
static const st7 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(-3, 7, false));

static const al = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(8, 0, false));
static const cl = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(8, 1, false));
static const dl = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(8, 2, false));
static const bl = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(8, 3, false));
static const ah = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(8, 4, false));
static const ch = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(8, 5, false));
static const dh = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(8, 6, false));
static const bh = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(8, 7, false));
static const spl = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(8, 4, true));
static const bpl = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(8, 5, true));
static const sil = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(8, 6, true));
static const dil = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(8, 7, true));
static const r8b = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(8, 8, false));
static const r9b = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(8, 9, false));
static const r10b = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(8, 10, false));
static const r11b = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(8, 11, false));
static const r12b = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(8, 12, false));
static const r13b = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(8, 13, false));
static const r14b = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(8, 14, false));
static const r15b = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(8, 15, false));

static const ax = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(16, 0, false));
static const cx = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(16, 1, false));
static const dx = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(16, 2, false));
static const bx = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(16, 3, false));
static const sp = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(16, 4, false));
static const bp = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(16, 5, false));
static const si = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(16, 6, false));
static const di = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(16, 7, false));
static const r8w = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(16, 8, false));
static const r9w = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(16, 9, false));
static const r10w = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(16, 10, false));
static const r11w = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(16, 11, false));
static const r12w = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(16, 12, false));
static const r13w = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(16, 13, false));
static const r14w = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(16, 14, false));
static const r15w = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(16, 15, false));

static const eax = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(32, 0, false));
static const ecx = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(32, 1, false));
static const edx = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(32, 2, false));
static const ebx = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(32, 3, false));
static const esp = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(32, 4, false));
static const ebp = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(32, 5, false));
static const esi = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(32, 6, false));
static const edi = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(32, 7, false));
static const r8d = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(32, 8, false));
static const r9d = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(32, 9, false));
static const r10d = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(32, 10, false));
static const r11d = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(32, 11, false));
static const r12d = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(32, 12, false));
static const r13d = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(32, 13, false));
static const r14d = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(32, 14, false));
static const r15d = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(32, 15, false));

static const rax = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(64, 0, false));
static const rcx = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(64, 1, false));
static const rdx = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(64, 2, false));
static const rbx = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(64, 3, false));
static const rsp = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(64, 4, false));
static const rbp = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(64, 5, false));
static const rsi = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(64, 6, false));
static const rdi = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(64, 7, false));
static const r8 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(64, 8, false));
static const r9 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(64, 9, false));
static const r10 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(64, 10, false));
static const r11 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(64, 11, false));
static const r12 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(64, 12, false));
static const r13 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(64, 13, false));
static const r14 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(64, 14, false));
static const r15 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(64, 15, false));

// TODO: MM and first 8 R64 can be used interchangably, this is bad!
static const mm0 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(64, 0, false));
static const mm1 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(64, 1, false));
static const mm2 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(64, 2, false));
static const mm3 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(64, 3, false));
static const mm4 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(64, 4, false));
static const mm5 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(64, 5, false));
static const mm6 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(64, 6, false));
static const mm7 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(64, 7, false));

static const xmm0 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(128, 0, false));
static const xmm1 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(128, 1, false));
static const xmm2 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(128, 2, false));
static const xmm3 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(128, 3, false));
static const xmm4 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(128, 4, false));
static const xmm5 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(128, 5, false));
static const xmm6 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(128, 6, false));
static const xmm7 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(128, 7, false));
static const xmm8 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(128, 8, false));
static const xmm9 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(128, 9, false));
static const xmm10 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(128, 10, false));
static const xmm11 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(128, 11, false));
static const xmm12 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(128, 12, false));
static const xmm13 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(128, 13, false));
static const xmm14 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(128, 14, false));
static const xmm15 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(128, 15, false));

static const ymm0 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(256, 0, false));
static const ymm1 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(256, 1, false));
static const ymm2 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(256, 2, false));
static const ymm3 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(256, 3, false));
static const ymm4 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(256, 4, false));
static const ymm5 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(256, 5, false));
static const ymm6 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(256, 6, false));
static const ymm7 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(256, 7, false));
static const ymm8 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(256, 8, false));
static const ymm9 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(256, 9, false));
static const ymm10 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(256, 10, false));
static const ymm11 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(256, 11, false));
static const ymm12 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(256, 12, false));
static const ymm13 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(256, 13, false));
static const ymm14 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(256, 14, false));
static const ymm15 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(256, 15, false));

static const zmm0 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(512, 0, false));
static const zmm1 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(512, 1, false));
static const zmm2 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(512, 2, false));
static const zmm3 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(512, 3, false));
static const zmm4 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(512, 4, false));
static const zmm5 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(512, 5, false));
static const zmm6 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(512, 6, false));
static const zmm7 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(512, 7, false));
static const zmm8 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(512, 8, false));
static const zmm9 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(512, 9, false));
static const zmm10 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(512, 10, false));
static const zmm11 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(512, 11, false));
static const zmm12 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(512, 12, false));
static const zmm13 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(512, 13, false));
static const zmm14 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(512, 14, false));
static const zmm15 = new Symbol(SymAttr.LITERAL, null, null, null, null, Marker(512, 15, false));

enum ubyte es = 0x26;
enum ubyte cs = 0x2e;
enum ubyte ss = 0x36;
enum ubyte ds = 0x3e;
enum ubyte fs = 0x64;
enum ubyte gs = 0x65;

private enum Mode
{
    Memory,
    MemoryOffset8,
    MemoryOffsetExt,
    Register
}

private union ModRM
{
public:
final:
    struct
    {
        mixin(bitfields!(
            ubyte, "src", 3,
            ubyte, "dst", 3,
            ubyte, "mod", 2
        ));
    }
    ubyte b;
    alias b this;
}

ubyte[] generateModRM(ubyte OP)(Marker src, Marker dst, Mode mod = Mode.Register)
{
    if (src.kind == Kind.REGISTER && dst.kind == Kind.REGISTER)
    {
        ModRM ret;
        ret.src = (src.index % 8);
        ret.dst = (dst.index % 8) | OP;
        ret.mod = cast(ubyte)mod;
        return [ret];
    }
    else if (src.kind == Kind.ALLOCATION && dst.kind == Kind.REGISTER)
    {
        if (src.size == 0)
            return generateModRM!OP(Marker(dst.size, src.baseIndex, false), dst, Mode.Memory)~0x25~(cast(ubyte*)&src.offset)[0..uint.sizeof];
        else
        {
            if (src.offset == 0)
                return generateModRM!OP(Marker(dst.size, src.baseIndex, false), dst, Mode.Memory);
            else
            {
                // TODO: SIB?
                if (src.offset >= ubyte.max)
                    return generateModRM!OP(Marker(dst.size, src.baseIndex, false), dst, Mode.MemoryOffset8)~cast(ubyte)src.offset;
                else
                    return generateModRM!OP(Marker(dst.size, src.baseIndex, false), dst, Mode.MemoryOffsetExt)~(cast(ubyte*)&src.offset)[0..uint.sizeof];
            }
        }
    }
    else if (src.kind == Kind.ALLOCATION && dst.kind == Kind.ALLOCATION)
        return generateModRM!OP(Marker(dst.size, dst.baseIndex, false), Marker(src.size, src.baseIndex, false));
    else if (src.kind == Kind.REGISTER && dst.kind == Kind.ALLOCATION)
        return generateModRM!OP(dst, src);
}

enum M = 0;
// Used for generating instructions with directly encoded registers.
enum NRM = 1;
// Used for generating instructions without REX prefixes.
enum NP = 2;
enum VEX = 3;
// Used for generating integer VEX instructions.
enum VEXI = 4;
enum EVEX = 5;
enum MVEX = 6;
// Exactly the same as NP except flips dst and src.
enum SSE = 7;

// map_select
enum XOP = 0;
enum DEFAULT = 1;
enum F38 = 2;
enum F3A = 3;
enum MSR = 7;

public class Stager : IStager
{
public:
final:
    ptrdiff_t[string] labels;
    Tuple!(ptrdiff_t, string, string, bool)[] branches;
    ubyte[] buffer;
    bool is64Bit;
    
    template emit(ubyte OP, ubyte SELECTOR = M, ubyte SIZE = 128, ubyte MAP = DEFAULT, ubyte PREFIX = 0)
    {
        size_t emit(ARGS...)(ARGS args)
        {
            ubyte[] buffer;
            bool prefixed;
            ptrdiff_t skip;

            static if (SELECTOR == M || SELECTOR == NRM || SELECTOR == NP || SELECTOR == SSE)
            void generatePrefix(Marker src, Marker dst, Marker stor = Marker.init)
            {
                prefixed = true;
                bool hasRex;
                bool w;
                bool r;
                bool x;
                bool b;

                if (src.kind == Kind.REGISTER)
                {
                    hasRex |= src.size == 64 || (src.size == 8 && src.extended) || src.index >= 8;
                    w = src.size == 64;
                    b = src.index >= 8;
                }
                else if (src.kind == Kind.ALLOCATION)
                {
                    hasRex |= src.baseIndex >= 8;
                    w = src.size == 64;
                    b = src.baseIndex >= 8;

                    if (src.segment != ds)
                        buffer = src.segment~buffer;
                }

                if (dst.kind == Kind.REGISTER)
                {
                    hasRex |= dst.size == 64 || (dst.size == 8 && dst.extended) || dst.index >= 8;
                    w = dst.size == 64;
                    b = dst.index >= 8;
                }
                else if (dst.kind == Kind.ALLOCATION)
                {
                    hasRex |= dst.baseIndex >= 8;
                    w = dst.size == 64;
                    x = dst.baseIndex >= 8;

                    if (dst.segment != ds)
                        buffer = dst.segment~buffer;
                }

                if ((is64Bit && (dst.size != 64 || src.size != 64)) || dst.size != 32 || src.size != 32)
                    buffer = 0x67~buffer;

                if (dst.size == 16 || src.size == 16)
                    buffer = 0x66~buffer;

                static if (SELECTOR != NP && SELECTOR != SSE)
                {
                    if (hasRex)
                    {
                        ubyte rex = 0b01000000;
                        if (w) rex |= (1 << 3);
                        if (r) rex |= (1 << 2);
                        if (x) rex |= (1 << 1);
                        if (b) rex |= (1 << 0);
                        
                        size_t pos = 0;
                        foreach (i; 0..5)
                        {
                            if (buffer[pos] == 0xf2)
                                pos++;
                            else if (buffer[pos] == 0xf3)
                                pos++;
                            else if (buffer[pos] == 0xf0)
                                pos++;
                            else if (buffer[pos] == 0x66)
                                pos++;
                            else if (buffer[pos] == 0x67)
                                pos++;
                        }
                        buffer = buffer[0..pos]~rex~buffer[pos..$];
                    }
                }
            }

            static if (SELECTOR == VEX || SELECTOR == VEXI)
            void generatePrefix(Marker src, Marker dst, Marker stor = Marker.init)
            {
                prefixed = true;
                bool r;
                bool x;
                bool b;
                immutable ubyte map_select = MAP;
                bool we = SELECTOR == VEX;
                ubyte vvvv = 0b1111;
                immutable bool l = SIZE != 128;
                immutable ubyte pp = (PREFIX == 0x66) ? 1 : ((PREFIX == 0xf3) ? 2 : ((PREFIX == 0xf2) ? 3 : 0));

                if (stor.kind == Kind.REGISTER)
                {
                    if (dst.kind == Kind.REGISTER)
                        vvvv = cast(ubyte)~dst.index;
                    else if (dst.kind == Kind.ALLOCATION)
                        vvvv = cast(ubyte)~dst.baseIndex;

                    dst = Marker(dst.size, stor.index, dst.extended);
                }
                else if (stor.kind == Kind.ALLOCATION)
                {
                    if (dst.kind == Kind.REGISTER)
                        vvvv = cast(ubyte)~dst.index;
                    else if (dst.kind == Kind.ALLOCATION)
                        vvvv = cast(ubyte)~dst.baseIndex;
                        
                    dst = Marker(dst.size, stor.baseIndex, dst.extended);
                }

                if (src.kind == Kind.REGISTER)
                {
                    if (SELECTOR == VEXI)
                        we = src.size == 64;
                    b = src.index >= 8;
                }
                else if (src.kind == Kind.ALLOCATION)
                {
                    if (SELECTOR == VEXI)
                        we = src.size == 64;
                    b = src.baseIndex >= 8;

                    if (src.segment != ds)
                        buffer = src.segment~buffer;
                }
                
                if (dst.kind == Kind.REGISTER)
                {
                    if (SELECTOR == VEXI)
                        we = dst.size == 64;
                    r = dst.index >= 8;
                }
                else if (dst.kind == Kind.ALLOCATION)
                {
                    if (SELECTOR == VEXI)
                        we = dst.size == 64;
                    x = dst.baseIndex >= 8;

                    if (dst.segment != ds)
                        buffer = dst.segment~buffer;
                }

                if ((is64Bit && (dst.size != 64 || src.size != 64)) || dst.size != 32 || src.size != 32)
                    buffer = 0x67~buffer;

                if (dst.size == 16 || src.size == 16)
                    buffer = 0x66~buffer;

                ubyte[] vex;
                if (map_select != 1 || r || x || b || MAP == XOP)
                {
                    static if (SELECTOR != VEXI)
                        we = false;

                    vex ~= MAP == XOP ? 0x8f : 0xc4;
                    vex ~= (cast(ubyte)(((r ? 0 : 1) << 5) | ((x ? 0 : 1) << 6) | ((b ? 0 : 1) << 7))) | (map_select & 0b00011111);
                }
                else
                    vex ~= 0xc5;
                vex ~= we << 7 | (vvvv & 0b00001111) << 3 | (l ? 1 : 0) << 2 | (pp & 0b00000011);
                    
                buffer = vex~buffer;
            }

            foreach (i, arg; args)
            {
                if (skip-- > 0)
                    continue;

                static if (is(typeof(arg) == Marker))
                {
                    if (arg.kind != Kind.LITERAL)
                        continue;
                    else if (arg.size == 8)
                        buffer ~= arg.b;
                    else if (arg.size == 16)
                        buffer ~= (cast(ubyte*)&arg.w)[0..ushort.sizeof];
                    else if (arg.size == 32)
                        buffer ~= (cast(ubyte*)&arg.d)[0..uint.sizeof];
                    else if (arg.size == 64)
                        buffer ~= (cast(ubyte*)&arg.q)[0..ulong.sizeof];
                }

                static if (is(typeof(arg) == int))
                    buffer ~= cast(ubyte)arg;
                else static if (is(typeof(arg) == ubyte[]))
                    buffer ~= arg;
                else static if (SELECTOR == NRM && is(arg == Marker))
                {
                    if (arg.kind != Kind.REGISTER)
                        continue;

                    buffer[$-1] += arg.index % 8;
                    generatePrefix(Marker(arg.size, 0, arg.extended), arg);
                }
                else static if (i + 2 < args.length && is(arg == Marker) && is(arg[i + 1] == Marker) && is(arg[i + 2] == Marker))
                {
                    auto dst = args[i + 2];
                    auto src = arg;
                    buffer ~= generateModRM!OP(dst, src);
                    generatePrefix(src, args[i + 1], dst);
                    ct = 2;
                }
                else static if (i + 1 < args.length && is(arg == Marker) && is(arg[i + 1] == Marker))
                {
                    Marker dst = arg;
                    Marker src = args[i + 1];
                    static if (SELECTOR == M || SELECTOR == NP || SELECTOR == NRM)
                        buffer ~= generateModRM!OP(dst, src);
                    else
                        buffer ~= generateModRM!OP(src, dst);
                    generatePrefix(src, dst);
                    skip = 1;
                }
                else static if (is(arg == Marker))
                {
                    Marker dst = arg;
                    Marker src = Marker(arg.size, 0, arg.extended);
                    static if (SELECTOR == M || SELECTOR == NP || SELECTOR == NRM)
                        buffer ~= generateModRM!OP(dst, src);
                    else
                        buffer ~= generateModRM!OP(src, dst);
                    generatePrefix(src, dst);
                }
            }

            // TODO: This resonates a dark, malignant, sinister otherworldly aura, could it be the demon king?
            if (!prefixed)
            {
                static if (SELECTOR != M && SELECTOR != NP && SELECTOR != NP && SELECTOR != NRM)
                    generatePrefix(Marker(typeof(args[0]).sizeof * 128, 0, false), Marker(typeof(args[0]).sizeof * 128, 0, false));

                static if (SELECTOR == M || SELECTOR == NP || SELECTOR == NP || SELECTOR == NRM)
                foreach (i, arg; args)
                {
                    static if (!is(typeof(arg) == int))
                    {
                        static if (args.length - i - 1 == 0)
                            generatePrefix(Marker(typeof(arg).sizeof * 8, 0, false), Marker(typeof(arg).sizeof * 8, 0, false));
                        else static if (args.length - i - 1 == 1)
                            generatePrefix(Marker(typeof(arg).sizeof * 8, 0, false), Marker(typeof(args[i + 1]).sizeof * 8, 0, false));
                        else static if (args.length - i - 1 == 2)
                            generatePrefix(Marker(typeof(arg).sizeof * 8, 0, false), Marker(typeof(args[i + 1]).sizeof * 8, 0, false), Marker(typeof(args[i + 2]).sizeof * 8, 0, false));
                        break;
                    }
                }
            }

            this.buffer ~= buffer;
            return buffer.length;
        }
    }

    ubyte[] finalize()
    {
        immutable static ubyte[][string] branchMap = [
            "jmp1": [0xeb],
            "jmp2": [0xe9],
            "jmp4": [0xe9],
            "ja1": [0x77],
            "jae1": [0x73],
            "jb1": [0x72],
            "jbe1": [0x76],
            "jc1": [0x72],
            "jecxz1": [0xE3],
            "jecxz1": [0xE3],
            "jrcxz1": [0xE3],
            "je1": [0x74],
            "jg1": [0x7F],
            "jge1": [0x7D],
            "jl1": [0x7C],
            "jle1": [0x7E],
            "jna1": [0x76],
            "jnae1": [0x72],
            "jnb1": [0x73],
            "jnbe1": [0x77],
            "jnc1": [0x73],
            "jne1": [0x75],
            "jng1": [0x7E],
            "jnge1": [0x7C],
            "jnl1": [0x7D],
            "jnle1": [0x7F],
            "jno1": [0x71],
            "jnp1": [0x7B],
            "jns1": [0x79],
            "jnz1": [0x75],
            "jo1": [0x70],
            "jp1": [0x7A],
            "jpe1": [0x7A],
            "jpo1": [0x7B],
            "js1": [0x78],
            "jz1": [0x74],
            "ja2": [0x0F, 0x87],
            "ja4": [0x0F, 0x87],
            "jae2": [0x0F, 0x83],
            "jae4": [0x0F, 0x83],
            "jb2": [0x0F, 0x82],
            "jb4": [0x0F, 0x82],
            "jbe2": [0x0F, 0x86],
            "jbe4": [0x0F, 0x86],
            "jc2": [0x0F, 0x82],
            "jc4": [0x0F, 0x82],
            "je2": [0x0F, 0x84],
            "je4": [0x0F, 0x84],
            "jz2": [0x0F, 0x84],
            "jz4": [0x0F, 0x84],
            "jg2": [0x0F, 0x8F],
            "jg4": [0x0F, 0x8F],
            "jge2": [0x0F, 0x8D],
            "jge4": [0x0F, 0x8D],
            "jl2": [0x0F, 0x8C],
            "jl4": [0x0F, 0x8C],
            "jle2": [0x0F, 0x8E],
            "jle4": [0x0F, 0x8E],
            "jna2": [0x0F, 0x86],
            "jna4": [0x0F, 0x86],
            "jnae2": [0x0F, 0x82],
            "jnae4": [0x0F, 0x82],
            "jnb2": [0x0F, 0x83],
            "jnb4": [0x0F, 0x83],
            "jnbe2": [0x0F, 0x87],
            "jnbe4": [0x0F, 0x87],
            "jnc2": [0x0F, 0x83],
            "jnc4": [0x0F, 0x83],
            "jne2": [0x0F, 0x85],
            "jne4": [0x0F, 0x85],
            "jng2": [0x0F, 0x8E],
            "jng4": [0x0F, 0x8E],
            "jnge2": [0x0F, 0x8C],
            "jnge4": [0x0F, 0x8C],
            "jnl2": [0x0F, 0x8D],
            "jnl4": [0x0F, 0x8D],
            "jnle2": [0x0F, 0x8F],
            "jnle4": [0x0F, 0x8F],
            "jno2": [0x0F, 0x81],
            "jno4": [0x0F, 0x81],
            "jnp2": [0x0F, 0x8B],
            "jnp4": [0x0F, 0x8B],
            "jns2": [0x0F, 0x89],
            "jns4": [0x0F, 0x89],
            "jnz2": [0x0F, 0x85],
            "jnz4": [0x0F, 0x85],
            "jo2": [0x0F, 0x80],
            "jo4": [0x0F, 0x80],
            "jp2": [0x0F, 0x8A],
            "jp4": [0x0F, 0x8A],
            "jpe2": [0x0F, 0x8A],
            "jpe4": [0x0F, 0x8A],
            "jpo2": [0x0F, 0x8B],
            "jpo4": [0x0F, 0x8B],
            "js2": [0x0F, 0x88],
            "js4": [0x0F, 0x88],
            "jz2": [0x0F, 0x84],
            "jz4": [0x0F, 0x84],
            "loop1": [0xe2],
            "loope1": [0xe1],
            "loopne1": [0xe0]
        ];

        size_t abs;
        size_t calculateBranch(T)(T branch)
        {
            size_t size;
            auto rel = labels[branch[1]] - branch[0] + abs;
            bool isRel8 = rel <= ubyte.max && rel >= ubyte.min;
            bool isRel16 = rel <= ushort.max && rel >= ushort.min;

            if (isRel8)
                size = branchMap[branch[2]~'1'].length + 1;
            else if (isRel16)
                size = branchMap[branch[2]~'2'].length + 2;
            else
                size = branchMap[branch[2]~'4'].length + 4;

            return size;
        }

        foreach (ref i, branch; branches)
        {
            if (i + 1 < branches.length && branches[i + 1][3] && branches[i + 1][0] == branch[0])
                labels[branch[1]] += calculateBranch(branches[i + 1]);

            ubyte[] buffer;

            branch[0] += abs;
            auto rel = labels[branch[1]] - branch[0];
            bool isRel8 = rel <= byte.max && rel >= byte.min;
            bool isRel16 = rel <= short.max && rel >= short.min;

            buffer ~= branchMap[branch[2]~(isRel8 ? '1' : isRel16 ? '2' : '4')];

            if (isRel8)
                buffer ~= cast(ubyte)rel;
            else if (isRel16)
                buffer ~= (cast(ubyte*)&rel)[0..2];
            else
                buffer ~= (cast(ubyte*)&rel)[0..4];

            abs += buffer.length;
            this.buffer = this.buffer[0..branch[0]]~buffer~this.buffer[branch[0]..$];
        }
        branches = null;
        return this.buffer;
    }

    ptrdiff_t label(string name) => labels[name] = buffer.length;

    size_t stage(Instruction instr)
    {
        if (instr.details & Details.LOCK)
            buffer ~= 0xf0;

        with (OpCode) switch (instr.opcode)
        {
            case CRIDVME:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.MOV, instr.first, cr4)) +
                stage(Instruction(OpCode.AND, instr.first, 1 << CRID.VME));
            case CRIDPVI:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.MOV, instr.first, cr4)) +
                stage(Instruction(OpCode.AND, instr.first, 1 << CRID.PVI));
            case CRIDTSD:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.MOV, instr.first, cr4)) +
                stage(Instruction(OpCode.AND, instr.first, 1 << CRID.TSD));
            case CRIDDE:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.MOV, instr.first, cr4)) +
                stage(Instruction(OpCode.AND, instr.first, 1 << CRID.DE));
            case CRIDPSE:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.MOV, instr.first, cr4)) +
                stage(Instruction(OpCode.AND, instr.first, 1 << CRID.PSE));
            case CRIDPAE:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.MOV, instr.first, cr4)) +
                stage(Instruction(OpCode.AND, instr.first, 1 << CRID.PAE));
            case CRIDMCE:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.MOV, instr.first, cr4)) +
                stage(Instruction(OpCode.AND, instr.first, 1 << CRID.MCE));
            case CRIDPGE:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.MOV, instr.first, cr4)) +
                stage(Instruction(OpCode.AND, instr.first, 1 << CRID.PGE));
            case CRIDPCE:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.MOV, instr.first, cr4)) +
                stage(Instruction(OpCode.AND, instr.first, 1 << CRID.PCE));
            case CRIDOSFXSR:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.MOV, instr.first, cr4)) +
                stage(Instruction(OpCode.AND, instr.first, 1 << CRID.OSFXSR));
            case CRIDOSXMMEXCPT:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.MOV, instr.first, cr4)) +
                stage(Instruction(OpCode.AND, instr.first, 1 << CRID.OSXMMEXCPT));
            case CRIDUMIP:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.MOV, instr.first, cr4)) +
                stage(Instruction(OpCode.AND, instr.first, 1 << CRID.UMIP));
            case CRIDVMXE:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.MOV, instr.first, cr4)) +
                stage(Instruction(OpCode.AND, instr.first, 1 << CRID.VMXE));
            case CRIDSMXE:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.MOV, instr.first, cr4)) +
                stage(Instruction(OpCode.AND, instr.first, 1 << CRID.SMXE));
            case CRIDFSGSBASE:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.MOV, instr.first, cr4)) +
                stage(Instruction(OpCode.AND, instr.first, 1 << CRID.FSGSBASE));
            case CRIDPCIDE:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.MOV, instr.first, cr4)) +
                stage(Instruction(OpCode.AND, instr.first, 1 << CRID.PCIDE));
            case CRIDOSXSAVE:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.MOV, instr.first, cr4)) +
                stage(Instruction(OpCode.AND, instr.first, 1 << CRID.OSXSAVE));
            case CRIDSMEP:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.MOV, instr.first, cr4)) +
                stage(Instruction(OpCode.AND, instr.first, 1 << CRID.SMEP));
            case CRIDSMAP:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.MOV, instr.first, cr4)) +
                stage(Instruction(OpCode.AND, instr.first, 1 << CRID.SMAP));
            case CRIDPKE:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.MOV, instr.first, cr4)) +
                stage(Instruction(OpCode.AND, instr.first, 1 << CRID.PKE));
            case CRIDCET:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.MOV, instr.first, cr4)) +
                stage(Instruction(OpCode.AND, instr.first, 1 << CRID.CET));
            case CRIDPKS:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.MOV, instr.first, cr4)) +
                stage(Instruction(OpCode.AND, instr.first, 1 << CRID.PKS));
            case CRIDUINTR:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.MOV, instr.first, cr4)) +
                stage(Instruction(OpCode.AND, instr.first, 1 << CRID.UINTR));

            case IDAVX512VL:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.AVX512VL)) +
                // NOTE: This would have problems depending on what marker is the first operand.
                stage(Instruction(OpCode.MOV, instr.first, ebx));
            case IDAVX512BW:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.AVX512BW)) +
                stage(Instruction(OpCode.MOV, instr.first, ebx));
            case IDSHA:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.SHA)) +
                stage(Instruction(OpCode.MOV, instr.first, ebx));
            case IDAVX512CD:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.AVX512CD)) +
                stage(Instruction(OpCode.MOV, instr.first, ebx));
            case IDAVX512ER:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.AVX512ER)) +
                stage(Instruction(OpCode.MOV, instr.first, ebx));
            case IDAVX512PF:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.AVX512PF)) +
                stage(Instruction(OpCode.MOV, instr.first, ebx));
            case IDPT:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.PT)) +
                stage(Instruction(OpCode.MOV, instr.first, ebx));
            case IDCLWB:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.CLWB)) +
                stage(Instruction(OpCode.MOV, instr.first, ebx));
            case IDCLFLUSHOPT:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.CLFLUSHOPT)) +
                stage(Instruction(OpCode.MOV, instr.first, ebx));
            case IDPCOMMIT:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.PCOMMIT)) +
                stage(Instruction(OpCode.MOV, instr.first, ebx));
            case IDAVX512IFMA:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.AVX512IFMA)) +
                stage(Instruction(OpCode.MOV, instr.first, ebx));
            case IDSMAP:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.SMAP)) +
                stage(Instruction(OpCode.MOV, instr.first, ebx));
            case IDADX:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.ADX)) +
                stage(Instruction(OpCode.MOV, instr.first, ebx));
            case IDRDSEED:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.RDSEED)) +
                stage(Instruction(OpCode.MOV, instr.first, ebx));
            case IDAVX512DQ:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.AVX512DQ)) +
                stage(Instruction(OpCode.MOV, instr.first, ebx));
            case IDAVX512F:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.AVX512F)) +
                stage(Instruction(OpCode.MOV, instr.first, ebx));
            case IDPQE:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.PQE)) +
                stage(Instruction(OpCode.MOV, instr.first, ebx));
            case IDRTM:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.RTM)) +
                stage(Instruction(OpCode.MOV, instr.first, ebx));
            case IDINVPCID:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.INVPCID)) +
                stage(Instruction(OpCode.MOV, instr.first, ebx));
            case IDERMS:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.ERMS)) +
                stage(Instruction(OpCode.MOV, instr.first, ebx));
            case IDBMI2:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.BMI2)) +
                stage(Instruction(OpCode.MOV, instr.first, ebx));
            case IDSMEP:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.SMEP)) +
                stage(Instruction(OpCode.MOV, instr.first, ebx));
            case IDFPDP:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.FPDP)) +
                stage(Instruction(OpCode.MOV, instr.first, ebx));
            case IDAVX2:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.AVX2)) +
                stage(Instruction(OpCode.MOV, instr.first, ebx));
            case IDHLE:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.HLE)) +
                stage(Instruction(OpCode.MOV, instr.first, ebx));
            case IDBMI1:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.BMI1)) +
                stage(Instruction(OpCode.MOV, instr.first, ebx));
            case IDSGX:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.SGX)) +
                stage(Instruction(OpCode.MOV, instr.first, ebx));
            case IDTSCADJ:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.TSC_ADJUST)) +
                stage(Instruction(OpCode.MOV, instr.first, ebx));
            case IDFSGSBASE:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.FSGSBASE)) +
                stage(Instruction(OpCode.MOV, instr.first, ebx));

            case IDPREFETCHWT1:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.PREFETCHWT1)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDAVX512VBMI:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.AVX512VBMI)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDUMIP:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.UMIP)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDPKU:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.PKU)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDOSPKE:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.OSPKE)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDAVX512VBMI2:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.AVX512VBMI2)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDCET:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.CET)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDGFNI:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.GFNI)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDVAES:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.VAES)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDVPCL:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.VPCL)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDAVX512VNNI:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.AVX512VNNI)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDAVX512BITALG:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.AVX512BITALG)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDTME:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.TME)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDAVX512VP:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.AVX512VP)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDVA57:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.VA57)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDRDPID:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.RDPID)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDSGXLC:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.SGX_LC)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));

            case IDAVX512QVNNIW:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID7_EDX.AVX512QVNNIW)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));
            case IDAVX512QFMA:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID7_EDX.AVX512QFMA)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));
            case IDPCONFIG:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID7_EDX.PCONFIG)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));
            case IDIBRSIBPB:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID7_EDX.IBRS_IBPB)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));
            case IDSTIBP:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID7_EDX.STIBP)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));

            case IDSSE3:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.SSE3)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDPCLMUL:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.PCLMUL)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDDTES64:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.DTES64)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDMON:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.MON)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDDSCPL:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.DSCPL)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDVMX:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.VMX)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDSMX:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.SMX)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDEST:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.EST)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDTM2:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.TM2)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDSSSE3:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.SSSE3)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDCID:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.CID)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDSDBG:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.SDBG)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDFMA:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.FMA)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDCX16:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.CX16)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDXTPR:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.XTPR)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDPDCM:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.PDCM)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDPCID:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.PCID)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDDCA:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.DCA)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDSSE41:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.SSE4_1)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDSSE42:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.SSE4_2)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDX2APIC:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.X2APIC)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDMOVBE:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.MOVBE)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDPOPCNT:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.POPCNT)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDTSCD:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.TSCD)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDAES:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.AES)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDXSAVE:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.XSAVE)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDOSXSAVE:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.OSXSAVE)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDAVX:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.AVX)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDF16C:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.F16C)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDRDRAND:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.RDRAND)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));
            case IDHV:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.HV)) +
                stage(Instruction(OpCode.MOV, instr.first, ecx));

            case IDFPU:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.FPU)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));
            case IDVME:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.VME)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));
            case IDDE:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.DE)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));
            case IDPSE:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.PSE)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));
            case IDTSC:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.TSC)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));
            case IDMSR:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.MSR)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));
            case IDPAE:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.PAE)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));
            case IDCX8:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.CX8)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));
            case IDAPIC:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.APIC)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));
            case IDSEP:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.SEP)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));
            case IDMTRR:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.MTRR)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));
            case IDPGE:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.PGE)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));
            case IDMCA:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.MCA)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));
            case IDCMOV:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.CMOV)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));
            case IDPAT:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.PAT)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));
            case IDPSE36:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.PSE36)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));
            case IDPSN:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.PSN)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));
            case IDCLFL:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.CLFL)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));
            case IDDS:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.DS)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));
            case IDACPI:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.ACPI)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));
            case IDMMX:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.MMX)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));
            case IDFXSR:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.FXSR)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));
            case IDSSE:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.SSE)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));
            case IDSSE2:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.SSE2)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));
            case IDSS:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.SS)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));
            case IDHTT:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.HTT)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));
            case IDTM:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.TM)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));
            case IDIA64:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.IA64)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));
            case IDPBE:
                assert(instr.format!(RM!64));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.PBE)) +
                stage(Instruction(OpCode.MOV, instr.first, edx));

            case PFADD:
                assert(instr.format!(ulong, RM!64));
                return emit!0(0x0f, 0x0f, instr.first, instr.second, 0x9e);
            case PFSUB:
                assert(instr.format!(ulong, RM!64));
                return emit!0(0x0f, 0x0f, instr.first, instr.second, 0x9a);
            case PFSUBR:
                assert(instr.format!(ulong, RM!64));
                return emit!0(0x0f, 0x0f, instr.first, instr.second, 0xaa);
            case PFMUL:
                assert(instr.format!(ulong, RM!64));
                return emit!0(0x0f, 0x0f, instr.first, instr.second, 0xb4);
            case PFCMPEQ:
                assert(instr.format!(ulong, RM!64));
                return emit!0(0x0f, 0x0f, instr.first, instr.second, 0xb0);
            case PFCMPGE:
                assert(instr.format!(ulong, RM!64));
                return emit!0(0x0f, 0x0f, instr.first, instr.second, 0x90);
            case PFCMPGT:
                assert(instr.format!(ulong, RM!64));
                return emit!0(0x0f, 0x0f, instr.first, instr.second, 0xa0);
            case PF2ID:
                assert(instr.format!(ulong, RM!64));
                return emit!0(0x0f, 0x0f, instr.first, instr.second, 0x1d);
            case PI2FD:
                assert(instr.format!(ulong, RM!64));
                return emit!0(0x0f, 0x0f, instr.first, instr.second, 0x0d);
            case PF2IW:
                assert(instr.format!(ulong, RM!64));
                return emit!0(0x0f, 0x0f, instr.first, instr.second, 0x1c);
            case PI2FW:
                assert(instr.format!(ulong, RM!64));
                return emit!0(0x0f, 0x0f, instr.first, instr.second, 0x0c);
            case PFMAX:
                assert(instr.format!(ulong, RM!64));
                return emit!0(0x0f, 0x0f, instr.first, instr.second, 0xa4);
            case PFMIN:
                assert(instr.format!(ulong, RM!64));
                return emit!0(0x0f, 0x0f, instr.first, instr.second, 0x9d);
            case PFRCP:
                assert(instr.format!(ulong, RM!64));
                return emit!0(0x0f, 0x0f, instr.first, instr.second, 0x96);
            case PFRSQRT:
                assert(instr.format!(ulong, RM!64));
                return emit!0(0x0f, 0x0f, instr.first, instr.second, 0x97);
            case PFRCPIT1:
                assert(instr.format!(ulong, RM!64));
                return emit!0(0x0f, 0x0f, instr.first, instr.second, 0xa6);
            case PFRSQIT1:
                assert(instr.format!(ulong, RM!64));
                return emit!0(0x0f, 0x0f, instr.first, instr.second, 0xa7);
            case PFRCPIT2:
                assert(instr.format!(ulong, RM!64));
                return emit!0(0x0f, 0x0f, instr.first, instr.second, 0xb6);
            case PFACC:
                assert(instr.format!(ulong, RM!64));
                return emit!0(0x0f, 0x0f, instr.first, instr.second, 0xae);
            case PFNACC:
                assert(instr.format!(ulong, RM!64));
                return emit!0(0x0f, 0x0f, instr.first, instr.second, 0x8a);
            case PFPNACC:
                assert(instr.format!(ulong, RM!64));
                return emit!0(0x0f, 0x0f, instr.first, instr.second, 0x8e);
            case PMULHRW:
                assert(instr.format!(ulong, RM!64));
                return emit!0(0x0f, 0x0f, instr.first, instr.second, 0xb7);
            case PAVGUSB:
                assert(instr.format!(ulong, RM!64));
                return emit!0(0x0f, 0x0f, instr.first, instr.second, 0xbf);
            case PSWAPD:
                assert(instr.format!(ulong, RM!64));
                return emit!0(0x0f, 0x0f, instr.first, instr.second, 0xbb);
            case FEMMS:
                assert(instr.format!());
                return emit!0(0x0f, 0x0e);

            case ICEBP:
                assert(instr.format!());
                return emit!0(0xf1);

            case PTWRITE:
                assert(instr.format!(uint) || 
                    instr.format!(ulong));
                return emit!4(0xf3, 0x0f, 0xae, instr.first);

            case CLWB:
                assert(instr.format!(ubyte));
                return emit!6(0x66, 0x0f, 0xae, instr.first);

            case CLFLUSHOPT:
                assert(instr.format!(ubyte));
                return emit!7(0x66, 0x0f, 0xae, instr.first);

            case STAC:
                assert(instr.format!());
                return emit!0(0x0f, 0x01, 0xcb);
            case CLAC:
                assert(instr.format!());
                return emit!0(0x0f, 0x01, 0xca);

            case ADC:
                if (instr.format!(ubyte))
                    return emit!0(0x14, instr.first); // ADC AL, imm8
                if (instr.format!(ushort))
                    return emit!0(0x15, instr.first); // ADC AX, imm16
                if (instr.format!(uint))
                    return emit!0(0x15, instr.first); // ADC EAX, imm32
                if (instr.format!(ulong))
                    return emit!0(0x15, instr.first); // ADC RAX, imm32 (sign-extended)

                if (instr.format!(RM!8, ubyte))
                    return emit!2(0x80, instr.first, instr.second); // ADC r/m8, imm8
                if (instr.format!(RM!16, ushort))
                    return emit!2(0x81, instr.first, instr.second); // ADC r/m16, imm16
                if (instr.format!(RM!32, uint))
                    return emit!2(0x81, instr.first, instr.second); // ADC r/m32, imm32
                if (instr.format!(RM!64, uint))
                    return emit!2(0x81, instr.first, instr.second); // ADC r/m64, imm32 (sign-extended)
                if (instr.format!(RM!16, ubyte))
                    return emit!2(0x83, instr.first, instr.second); // ADC r/m16, imm8 (sign-extended)
                if (instr.format!(RM!32, ubyte))
                    return emit!2(0x83, instr.first, instr.second); // ADC r/m32, imm8 (sign-extended)
                if (instr.format!(RM!64, ubyte))
                    return emit!2(0x83, instr.first, instr.second); // ADC r/m64, imm8 (sign-extended)

                if (instr.format!(RM!8, Reg!8))
                    return emit!0(0x10, instr.first, instr.second); // ADC r/m8, r8
                if (instr.format!(RM!16, Reg!16))
                    return emit!0(0x11, instr.first, instr.second); // ADC r/m16, r16
                if (instr.format!(RM!32, Reg!32))
                    return emit!0(0x11, instr.first, instr.second); // ADC r/m32, r32
                if (instr.format!(RM!64, Reg!64))
                    return emit!0(0x11, instr.first, instr.second); // ADC r/m64, r64

                if (instr.format!(Reg!8, Addr!8))
                    return emit!0(0x12, instr.first, instr.second); // ADC r8, m8
                if (instr.format!(Reg!16, Addr!16))
                    return emit!0(0x13, instr.first, instr.second); // ADC r16, m16
                if (instr.format!(Reg!32, Addr!32))
                    return emit!0(0x13, instr.first, instr.second); // ADC r32, m32
                if (instr.format!(Reg!64, Addr!64))
                    return emit!0(0x13, instr.first, instr.second); // ADC r64, m64

                assert(0);

            case ADCX:
                if (instr.format!(Reg!32, RM!32))
                    return emit!0(0x0F, 0x38, 0xF6, instr.first, instr.second); // ADCX r32, r/m32
                if (instr.format!(Reg!64, RM!64))
                    return emit!0(0x0F, 0x38, 0xF6, instr.first, instr.second); // ADCX r64, r/m64

                assert(0);

            case ADOX:
                if (instr.format!(Reg!32, RM!32))
                    return emit!0(0xF3, 0x0F, 0x38, 0xF6, instr.first, instr.second); // ADOX r32, r/m32
                if (instr.format!(Reg!64, RM!64))
                    return emit!0(0xF3, 0x0F, 0x38, 0xF6, instr.first, instr.second); // ADOX r64, r/m64

                assert(0);

            case RDSEED:
                if (instr.format!(Reg!16))
                    return emit!7(0x0f, 0xc7, instr.first); // RDSEED r16
                if (instr.format!(Reg!32))
                    return emit!7(0x0f, 0xc7, instr.first); // RDSEED r32
                if (instr.format!(Reg!64))
                    return emit!7(0x0f, 0xc7, instr.first); // RDSEED r64

                assert(0);

            case BNDCL:
                if (instr.format!(Reg!32, RM!32))
                    return emit!0(0xf3, 0x0f, 0x1a, instr.first, instr.second); // BNDCL r32, r/m32
                if (instr.format!(Reg!64, RM!64))
                    return emit!0(0xf3, 0x0f, 0x1a, instr.first, instr.second); // BNDCL r64, r/m64

                assert(0);

            case BNDCU:
                if (instr.format!(Reg!32, RM!32))
                    return emit!0(0xf2, 0x0f, 0x1a, instr.first, instr.second); // BNDCU r32, r/m32
                if (instr.format!(Reg!64, RM!64))
                    return emit!0(0xf2, 0x0f, 0x1a, instr.first, instr.second); // BNDCU r64, r/m64

                assert(0);

            case BNDCN:
                if (instr.format!(Reg!32, RM!32))
                    return emit!0(0xf2, 0x0f, 0x1b, instr.first, instr.second); // BNDCN r32, r/m32
                if (instr.format!(Reg!64, RM!64))
                    return emit!0(0xf2, 0x0f, 0x1b, instr.first, instr.second); // BNDCN r64, r/m64

                assert(0);

            case BNDLDX:
                assert(instr.format!(Reg!64, RM!64));
                return emit!(0, NP)(0x0f, 0x1a, instr.first, instr.second); // BNDLDX r64, r/m64

            case BNDSTX:
                assert(instr.format!(RM!64, Reg!64));
                return emit!(0, NP)(0x0f, 0x1b, instr.first, instr.second); // BNDSTX r/m64, r64

            case BNDMK:
                if (instr.format!(Reg!32, RM!32))
                    return emit!0(0xf3, 0x0f, 0x1b, instr.first, instr.second); // BNDMK r32, r/m32
                if (instr.format!(Reg!64, RM!64))
                    return emit!0(0xf3, 0x0f, 0x1b, instr.first, instr.second); // BNDMK r64, r/m64

                assert(0);

            case BNDMOV:
                if (instr.format!(Reg!32, RM!32))
                    return emit!0(0x0f, 0x1a, instr.first, instr.second); // BNDMOV r32, r/m32
                if (instr.format!(Reg!64, RM!64))
                    return emit!0(0x0f, 0x1a, instr.first, instr.second); // BNDMOV r64, r/m64
                if (instr.format!(Addr!32, Reg!32))
                    return emit!0(0x0f, 0x1b, instr.first, instr.second); // BNDMOV m32, r32
                if (instr.format!(Addr!64, Reg!32))
                    return emit!0(0x0f, 0x1b, instr.first, instr.second); // BNDMOV m64, r32

                assert(0);

            case BOUND:
                if (instr.format!(Reg!16, RM!16))
                    return emit!0(0x62, instr.first, instr.second); // BOUND r16, m16
                if (instr.format!(Reg!32, RM!32))
                    return emit!0(0x62, instr.first, instr.second); // BOUND r32, m32

                assert(0);
                
            case XEND:
                assert(instr.format!());
                return emit!0(0x0f, 0x01, 0xd5);

            case XABORT:
                assert(instr.format!(ubyte));
                return emit!0(0xc6, 0xf8, instr.first); // XABORT imm8

            case XBEGIN:
                if (instr.format!(ushort))
                    return emit!0(0xc7, 0xf8, instr.first); // XBEGIN rel16
                if (instr.format!(uint))
                    return emit!0(0xc7, 0xf8, instr.first); // XBEGIN rel32

                assert(0);

            case XTEST:
                assert(instr.format!());
                return emit!0(0x0f, 0x01, 0xd6);

            case INVPCID:
                if (instr.format!(Reg!32, Addr!128))
                    return emit!0(0x0f, 0x38, 0x82, instr.first, instr.second); // INVPCID r32, m128
                if (instr.format!(Reg!64, Addr!128))
                    return emit!0(0x0f, 0x38, 0x82, instr.first, instr.second); // INVPCID r64, m128

                assert(0);

            case TZCNT:
                if (instr.format!(Reg!16, RM!16))
                    return emit!0(0xf3, 0x0f, 0xbc, instr.first, instr.second);
                if (instr.format!(Reg!32, RM!32))
                    return emit!0(0xf3, 0x0f, 0xbc, instr.first, instr.second);
                if (instr.format!(Reg!64 , RM!64))
                    return emit!0(0xf3, 0x0f, 0xbc, instr.first, instr.second);

                assert(0);

            case LZCNT:
                if (instr.format!(Reg!16, RM!16))
                    return emit!0(0xf3, 0x0f, 0xbd, instr.first, instr.second);
                if (instr.format!(Reg!32, RM!32))
                    return emit!0(0xf3, 0x0f, 0xbd, instr.first, instr.second);
                if (instr.format!(Reg!64 , RM!64))
                    return emit!0(0xf3, 0x0f, 0xbd, instr.first, instr.second);

                assert(0);

            case ANDN:
                if (instr.format!(Reg!32, Reg!32, RM!32))
                    return emit!(0, VEXI, 128, F38, 0)(0xf2, instr.first, instr.second, instr.third);
                if (instr.format!(Reg!64, Reg!32, RM!64))
                    return emit!(0, VEXI, 128, F38, 0)(0xf2, instr.first, instr.second, instr.third);

                assert(0);

            case ECREATE:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 0)) +
                emit!0(0x0f, 0x01, 0xcf);
            case EADD:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 1)) +
                emit!0(0x0f, 0x01, 0xcf);
            case EINIT:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 2)) +
                emit!0(0x0f, 0x01, 0xcf);
            case EREMOVE:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 3)) +
                emit!0(0x0f, 0x01, 0xcf);
            case EDBGRD:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 4)) +
                emit!0(0x0f, 0x01, 0xcf);
            case EDBGWR:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 5)) +
                emit!0(0x0f, 0x01, 0xcf);
            case EEXTEND:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 6)) +
                emit!0(0x0f, 0x01, 0xcf);
            case ELDB:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 7)) +
                emit!0(0x0f, 0x01, 0xcf);
            case ELDU:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 8)) +
                emit!0(0x0f, 0x01, 0xcf);
            case EBLOCK:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 9)) +
                emit!0(0x0f, 0x01, 0xcf);
            case EPA:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 10)) +
                emit!0(0x0f, 0x01, 0xcf);
            case EWB:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 11)) +
                emit!0(0x0f, 0x01, 0xcf);
            case ETRACK:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 12)) +
                emit!0(0x0f, 0x01, 0xcf);
            case EAUG:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 13)) +
                emit!0(0x0f, 0x01, 0xcf);
            case EMODPR:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 14)) +
                emit!0(0x0f, 0x01, 0xcf);
            case EMODT:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 15)) +
                emit!0(0x0f, 0x01, 0xcf);
            case ERDINFO:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 16)) +
                emit!0(0x0f, 0x01, 0xcf);
            case ETRACKC:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 17)) +
                emit!0(0x0f, 0x01, 0xcf);
            case ELDBC:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 18)) +
                emit!0(0x0f, 0x01, 0xcf);
            case ELDUC:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 19)) +
                emit!0(0x0f, 0x01, 0xcf);
                
            case EREPORT:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 0)) +
                emit!0(0x0f, 0x01, 0xd7);
            case EGETKEY:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 1)) +
                emit!0(0x0f, 0x01, 0xd7);
            case EENTER:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 2)) +
                emit!0(0x0f, 0x01, 0xd7);
            case ERESUME:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 3)) +
                emit!0(0x0f, 0x01, 0xd7);
            case EEXIT:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 4)) +
                emit!0(0x0f, 0x01, 0xd7);
            case EACCEPT:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 5)) +
                emit!0(0x0f, 0x01, 0xd7);
            case EMODPE:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 6)) +
                emit!0(0x0f, 0x01, 0xd7);
            case EACCEPTCOPY:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 7)) +
                emit!0(0x0f, 0x01, 0xd7);
            case EDECCSSA:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 9)) +
                emit!0(0x0f, 0x01, 0xd7);
                
            case EDECVIRTCHILD:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 0)) +
                emit!0(0x0f, 0x01, 0xc0);
            case EINCVIRTCHILD:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 1)) +
                emit!0(0x0f, 0x01, 0xc0);
            case ESETCONTEXT:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 2)) +
                emit!0(0x0f, 0x01, 0xc0);
                
            case MONITOR:
                assert(instr.format!());
                return emit!0(0x0f, 0x01, 0xc8);
            case MWAIT:
                assert(instr.format!());
                return emit!0(0x0f, 0x01, 0xc9);

            case INVVPID:
                if (instr.format!(Reg!32, Addr!128))
                    return emit!0(0x66, 0x0f, 0x38, 0x81, instr.first, instr.second); // INVVPID r32, m128
                if (instr.format!(Reg!64, Addr!128))
                    return emit!0(0x66, 0x0f, 0x38, 0x81, instr.first, instr.second); // INVVPID r64, m128

                assert(0);

            case INVEPT:
                if (instr.format!(Reg!32, Addr!128))
                    return emit!0(0x66, 0x0f, 0x38, 0x80, instr.first, instr.second); // INVEPT r32, m128
                if (instr.format!(Reg!64, Addr!128))
                    return emit!0(0x66, 0x0f, 0x38, 0x80, instr.first, instr.second); // INVEPT r64, m128
                    
                assert(0);

            case VMCALL:
                assert(instr.format!());
                return emit!0(0x0f, 0x01, 0xc9);
            case VMFUNC:
                assert(instr.format!());
                return emit!0(0x0f, 0x01, 0xd4);
            case VMCLEAR:
                assert(instr.format!(RM!64));
                return emit!6(0x66, 0x0f, 0xc7, instr.first);
            case VMLAUNCH:
                assert(instr.format!());
                return emit!0(0x0f, 0x01, 0xc2);
            case VMRESUME:
                assert(instr.format!());
                return emit!0(0x0f, 0x01, 0xc3);
            case VMXOFF:
                assert(instr.format!());
                return emit!0(0x0f, 0x01, 0xc4);
            case VMXON:
                assert(instr.format!(RM!64));
                return emit!6(0xf3, 0x0f, 0xc7, instr.first);

            case VMWRITE:
                if (instr.format!(Reg!64, RM!64))
                    return emit!(0, NP)(0x0f, 0x79, instr.first, instr.second); // VMWRITE r64, r/m64
                if (instr.format!(Reg!32, RM!32))
                    return emit!(0, NP)(0x0f, 0x79, instr.first, instr.second); // VMWRITE r32, r/m32

                assert(0);

            case VMREAD:
                if (instr.format!(RM!64, Reg!64))
                    return emit!(0, NP)(0x0f, 0x78, instr.first, instr.second); // VMREAD r/m64, r64
                if (instr.format!(RM!32, Reg!32))
                    return emit!(0, NP)(0x0f, 0x78, instr.first, instr.second); // VMREAD r/m32, r32

                assert(0);

            case VMPTRST:
                assert(instr.format!(RM!64));
                return emit!(7, NP)(0x0f, 0xc7, instr.first); // VMPTRST r/m64
            case VMPTRLD:
                assert(instr.format!(RM!64));
                return emit!(6, NP)(0x0f, 0xc7, instr.first); // VMPTRLD r/m64
                
            case CAPABILITIES:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 0)) +
                emit!0(0x0f, 0x37);
            case ENTERACCS:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 2)) +
                emit!0(0x0f, 0x37);
            case EXITAC:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 3)) +
                emit!0(0x0f, 0x37);
            case SENTER:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 4)) +
                emit!0(0x0f, 0x37);
            case SEXIT:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 5)) +
                emit!0(0x0f, 0x37);
            case PARAMETERS:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 6)) +
                emit!0(0x0f, 0x37);
            case SMCTRL:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 7)) +
                emit!0(0x0f, 0x37);
            case WAKEUP:
                assert(instr.format!());
                return stage(Instruction(OpCode.MOV, eax, 8)) +
                emit!0(0x0f, 0x37);
                
            case POPCNT:
                if (instr.format!(Reg!16, RM!16))
                    return emit!0(0xf3, 0x0f, 0xb8, instr.first, instr.second); // POPCNT r16, r/m16
                if (instr.format!(Reg!32, RM!32))
                    return emit!0(0xf3, 0x0f, 0xb8, instr.first, instr.second); // POPCNT r32, r/m32
                if (instr.format!(Reg!64, RM!64))
                    return emit!0(0xf3, 0x0f, 0xb8, instr.first, instr.second); // POPCNT r64, r/m64

                assert(0);

            case XGETBV:
                assert(instr.format!());
                return emit!0(0x0f, 0x01, 0xd0);
            case XSETBV:
                assert(instr.format!());
                return emit!0(0x0f, 0x01, 0xd1);

            // These are supposed to take addresses, but I didn't implement that and don't care
            case XRSTOR:
                return emit!(5, NP)(0x0f, 0xae, instr.first); // XRSTOR m
            case XSAVE:
                return emit!(4, NP)(0x0f, 0xae, instr.first); // XSAVE m

            case XRSTORS:
                return emit!(3, NP)(0x0f, 0xc7, instr.first); // XRSTORS m
            case XSAVES:
                return emit!(5, NP)(0x0f, 0xc7, instr.first); // XSAVES m

            case XSAVEOPT:
                return emit!(6, NP)(0x0f, 0xae, instr.first); // XSAVEOPT m
            case XSAVEC:
                return emit!(4, NP)(0x0f, 0xc7, instr.first); // XSAVEC m
                
            case RDRAND:
                if (instr.format!(Reg!16))
                    return emit!6(0x0f, 0xc7, instr.first); // RDRAND r16
                if (instr.format!(Reg!32))
                    return emit!6(0x0f, 0xc7, instr.first); // RDRAND r32
                if (instr.format!(Reg!64))
                    return emit!6(0x0f, 0xc7, instr.first); // RDRAND r64

                assert(0);

            case FABS:
                assert(instr.format!());
                return emit!0(0xd9, 0xe1);
            case FCHS:
                assert(instr.format!());
                return emit!0(0xd9, 0xe0);

            case FCLEX:
                assert(instr.format!());
                return emit!0(0x9b, 0xdb, 0xe2);
            case FNCLEX:
                assert(instr.format!());
                return emit!0(0xdb, 0xe2);

            case FADD:
                if (instr.format!(Addr!32))
                    return emit!(0, NP)(0xd8, instr.first);
                if (instr.format!(Addr!64))
                    return emit!(0, NP)(0xdc, instr.first);
                if (instr.format!(Reg!(-3), Reg!(-3)))
                {
                    if (instr.first.index == 0)
                        emit!(0, NRM)(0xd8, 0xc0, instr.second);
                    else if (instr.second.index == 0)
                        emit!(0, NRM)(0xdc, 0xc0, instr.first);
                    else
                        assert(0, "Cannot encode 'fadd' with no 'st0' operand!");
                }

                assert(0);
            case FADDP:
                assert(instr.format!(Reg!(-3)));
                return emit!(0, NRM)(0xde, 0xc0, instr.first);
            case FIADD:
                if (instr.format!(Addr!32))
                    return emit!(0, NP)(0xda, instr.first);
                if (instr.format!(Addr!16))
                    return emit!(0, NP)(0xde, instr.first);

                assert(0);

            case FBLD:
                assert(instr.format!(Addr!80));
                return emit!(4, NP)(0xdf, instr.first);
            case FBSTP:
                assert(instr.format!(Addr!80));
                return emit!(6, NP)(0xdf, instr.first);

            default:
                assert(0, "Invalid instruction staging!");
        }
        return -1;
    }
}