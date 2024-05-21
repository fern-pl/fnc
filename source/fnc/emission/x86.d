/// Code generation facilities for compiler backend.
module fnc.emission.x86;

import fnc.emission.ir;
import fnc.symbols;
import std.typecons;
import std.traits;

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
static const cr0 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(-1, 0, false));
static const cr2 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(-1, 2, false));
static const cr3 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(-1, 3, false));
static const cr4 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(-1, 4, false));

static const dr0 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(-2, 0, false));
static const dr1 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(-2, 1, false));
static const dr2 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(-2, 2, false));
static const dr3 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(-2, 3, false));
static const dr6 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(-2, 6, false));
static const dr7 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(-2, 7, false));

static const st0 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(-3, 0, false));
static const st1 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(-3, 1, false));
static const st2 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(-3, 2, false));
static const st3 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(-3, 3, false));
static const st4 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(-3, 4, false));
static const st5 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(-3, 5, false));
static const st6 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(-3, 6, false));
static const st7 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(-3, 7, false));

static const al = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(8, 0, false));
static const cl = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(8, 1, false));
static const dl = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(8, 2, false));
static const bl = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(8, 3, false));
static const ah = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(8, 4, false));
static const ch = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(8, 5, false));
static const dh = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(8, 6, false));
static const bh = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(8, 7, false));
static const spl = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(8, 4, true));
static const bpl = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(8, 5, true));
static const sil = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(8, 6, true));
static const dil = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(8, 7, true));
static const r8b = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(8, 8, false));
static const r9b = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(8, 9, false));
static const r10b = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(8, 10, false));
static const r11b = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(8, 11, false));
static const r12b = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(8, 12, false));
static const r13b = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(8, 13, false));
static const r14b = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(8, 14, false));
static const r15b = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(8, 15, false));

static const ax = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(16, 0, false));
static const cx = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(16, 1, false));
static const dx = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(16, 2, false));
static const bx = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(16, 3, false));
static const sp = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(16, 4, false));
static const bp = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(16, 5, false));
static const si = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(16, 6, false));
static const di = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(16, 7, false));
static const r8w = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(16, 8, false));
static const r9w = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(16, 9, false));
static const r10w = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(16, 10, false));
static const r11w = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(16, 11, false));
static const r12w = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(16, 12, false));
static const r13w = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(16, 13, false));
static const r14w = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(16, 14, false));
static const r15w = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(16, 15, false));

static const eax = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(32, 0, false));
static const ecx = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(32, 1, false));
static const edx = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(32, 2, false));
static const ebx = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(32, 3, false));
static const esp = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(32, 4, false));
static const ebp = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(32, 5, false));
static const esi = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(32, 6, false));
static const edi = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(32, 7, false));
static const r8d = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(32, 8, false));
static const r9d = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(32, 9, false));
static const r10d = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(32, 10, false));
static const r11d = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(32, 11, false));
static const r12d = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(32, 12, false));
static const r13d = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(32, 13, false));
static const r14d = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(32, 14, false));
static const r15d = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(32, 15, false));

static const rax = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(64, 0, false));
static const rcx = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(64, 1, false));
static const rdx = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(64, 2, false));
static const rbx = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(64, 3, false));
static const rsp = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(64, 4, false));
static const rbp = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(64, 5, false));
static const rsi = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(64, 6, false));
static const rdi = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(64, 7, false));
static const r8 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(64, 8, false));
static const r9 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(64, 9, false));
static const r10 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(64, 10, false));
static const r11 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(64, 11, false));
static const r12 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(64, 12, false));
static const r13 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(64, 13, false));
static const r14 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(64, 14, false));
static const r15 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(64, 15, false));

// TODO: MM and first 8 R64 can be used interchangably, this is bad!
static const mm0 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(64, 0, false));
static const mm1 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(64, 1, false));
static const mm2 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(64, 2, false));
static const mm3 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(64, 3, false));
static const mm4 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(64, 4, false));
static const mm5 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(64, 5, false));
static const mm6 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(64, 6, false));
static const mm7 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(64, 7, false));

static const xmm0 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(128, 0, false));
static const xmm1 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(128, 1, false));
static const xmm2 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(128, 2, false));
static const xmm3 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(128, 3, false));
static const xmm4 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(128, 4, false));
static const xmm5 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(128, 5, false));
static const xmm6 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(128, 6, false));
static const xmm7 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(128, 7, false));
static const xmm8 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(128, 8, false));
static const xmm9 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(128, 9, false));
static const xmm10 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(128, 10, false));
static const xmm11 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(128, 11, false));
static const xmm12 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(128, 12, false));
static const xmm13 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(128, 13, false));
static const xmm14 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(128, 14, false));
static const xmm15 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(128, 15, false));

static const ymm0 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(256, 0, false));
static const ymm1 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(256, 1, false));
static const ymm2 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(256, 2, false));
static const ymm3 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(256, 3, false));
static const ymm4 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(256, 4, false));
static const ymm5 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(256, 5, false));
static const ymm6 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(256, 6, false));
static const ymm7 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(256, 7, false));
static const ymm8 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(256, 8, false));
static const ymm9 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(256, 9, false));
static const ymm10 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(256, 10, false));
static const ymm11 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(256, 11, false));
static const ymm12 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(256, 12, false));
static const ymm13 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(256, 13, false));
static const ymm14 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(256, 14, false));
static const ymm15 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(256, 15, false));

static const zmm0 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(512, 0, false));
static const zmm1 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(512, 1, false));
static const zmm2 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(512, 2, false));
static const zmm3 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(512, 3, false));
static const zmm4 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(512, 4, false));
static const zmm5 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(512, 5, false));
static const zmm6 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(512, 6, false));
static const zmm7 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(512, 7, false));
static const zmm8 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(512, 8, false));
static const zmm9 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(512, 9, false));
static const zmm10 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(512, 10, false));
static const zmm11 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(512, 11, false));
static const zmm12 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(512, 12, false));
static const zmm13 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(512, 13, false));
static const zmm14 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(512, 14, false));
static const zmm15 = new Symbol(null, SymAttr.LOCAL, null, null, null, null, Marker(512, 15, false));

enum ubyte es = 0x26;
enum ubyte cs = 0x2e;
enum ubyte ss = 0x36;
enum ubyte ds = 0x3e;
enum ubyte fs = 0x64;
enum ubyte gs = 0x65;

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
                else if (src.kind = Kind.ALLOCATION)
                {
                    hasRex |= src.register >= 8;
                    w = src.size == 64;
                    b = src.register >= 8;

                    if (src.segment != ds)
                        buffer = src.segment~buffer;
                }

                if (dst.kind == Kind.REGISTER)
                {
                    hasRex |= dst.size == 64 || (dst.size == 8 && dst.extended) || dst.index >= 8;
                    w = dst.size == 64;
                    b = dst.index >= 8;
                }
                else if (dst.kind = Kind.ALLOCATION)
                {
                    hasRex |= dst.register >= 8;
                    w = dst.size == 64;
                    x = dst.register >= 8;

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
                        vvvv = cast(ubyte)~dst.register;

                    dst = Marker(dst.size, stor.index, dst.extended);
                }
                else if (stor.kind == Kind.ALLOCATION)
                {
                    if (dst.kind == Kind.REGISTER)
                        vvvv = cast(ubyte)~dst.index;
                    else static if (dst.kind == Kind.ALLOCATION)
                        vvvv = cast(ubyte)~dst.register;
                        
                    dst = Marker(dst.size, stor.register, dst.extended);
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
                    b = src.register >= 8;

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
                    x = dst.register >= 8;

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

                static if (is(typeof(arg) == int))
                    buffer ~= cast(ubyte)arg;
                else static if (is(typeof(arg) == long))
                    buffer ~= (cast(ubyte*)&arg)[0..uint.sizeof];
                else static if (isScalarType!(typeof(arg)))
                    buffer ~= (cast(ubyte*)&arg)[0..typeof(arg).sizeof];
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
        with (OpCode) switch (instr.opcode)
        {
            case CRIDVME:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.VME));
            case CRIDPVI:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.PVI));
            case CRIDTSD:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.TSD));
            case CRIDDE:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.DE));
            case CRIDPSE:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.PSE));
            case CRIDPAE:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.PAE));
            case CRIDMCE:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.MCE));
            case CRIDPGE:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.PGE));
            case CRIDPCE:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.PCE));
            case CRIDOSFXSR:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.OSFXSR));
            case CRIDOSXMMEXCPT:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.OSXMMEXCPT));
            case CRIDUMIP:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.UMIP));
            case CRIDVMXE:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.VMXE));
            case CRIDSMXE:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.SMXE));
            case CRIDFSGSBASE:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.FSGSBASE));
            case CRIDPCIDE:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.PCIDE));
            case CRIDOSXSAVE:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.OSXSAVE));
            case CRIDSMEP:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.SMEP));
            case CRIDSMAP:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.SMAP));
            case CRIDPKE:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.PKE));
            case CRIDCET:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.CET));
            case CRIDPKS:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.PKS));
            case CRIDUINTR:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.UINTR));

            case IDAVX512VL:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.AVX512VL)) +
                // NOTE: This would have problems depending on what marker is the first operand.
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDAVX512BW:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.AVX512BW)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDSHA:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.SHA)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDAVX512CD:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.AVX512CD)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDAVX512ER:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.AVX512ER)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDAVX512PF:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.AVX512PF)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDPT:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.PT)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDCLWB:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.CLWB)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDCLFLUSHOPT:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.CLFLUSHOPT)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDPCOMMIT:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.PCOMMIT)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDAVX512IFMA:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.AVX512IFMA)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDSMAP:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.SMAP)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDADX:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.ADX)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDRDSEED:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.RDSEED)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDAVX512DQ:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.AVX512DQ)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDAVX512F:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.AVX512F)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDPQE:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.PQE)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDRTM:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.RTM)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDINVPCID:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.INVPCID)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDERMS:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.ERMS)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDBMI2:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.BMI2)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDSMEP:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.SMEP)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDFPDP:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.FPDP)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDAVX2:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.AVX2)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDHLE:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.HLE)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDBMI1:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.BMI1)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDSGX:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.SGX)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDTSCADJ:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.TSC_ADJUST)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDFSGSBASE:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.FSGSBASE)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));

            case IDPREFETCHWT1:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.PREFETCHWT1)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDAVX512VBMI:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.AVX512VBMI)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDUMIP:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.UMIP)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDPKU:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.PKU)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDOSPKE:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.OSPKE)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDAVX512VBMI2:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.AVX512VBMI2)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDCET:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.CET)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDGFNI:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.GFNI)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDVAES:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.VAES)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDVPCL:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.VPCL)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDAVX512VNNI:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.AVX512VNNI)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDAVX512BITALG:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.AVX512BITALG)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDTME:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.TME)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDAVX512VP:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.AVX512VP)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDVA57:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.VA57)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDRDPID:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.RDPID)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDSGXLC:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.SGX_LC)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));

            case IDAVX512QVNNIW:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID7_EDX.AVX512QVNNIW)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));
            case IDAVX512QFMA:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID7_EDX.AVX512QFMA)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));
            case IDPCONFIG:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID7_EDX.PCONFIG)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));
            case IDIBRSIBPB:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID7_EDX.IBRS_IBPB)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));
            case IDSTIBP:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID7_EDX.STIBP)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));

            case IDSSE3:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.SSE3)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDPCLMUL:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.PCLMUL)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDDTES64:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.DTES64)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDMON:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.MON)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDDSCPL:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.DSCPL)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDVMX:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.VMX)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDSMX:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.SMX)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDEST:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.EST)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDTM2:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.TM2)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDSSSE3:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.SSSE3)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDCID:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.CID)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDSDBG:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.SDBG)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDFMA:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.FMA)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDCX16:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.CX16)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDXTPR:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.XTPR)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDPDCM:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.PDCM)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDPCID:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.PCID)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDDCA:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.DCA)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDSSE41:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.SSE4_1)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDSSE42:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.SSE4_2)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDX2APIC:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.X2APIC)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDMOVBE:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.MOVBE)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDPOPCNT:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.POPCNT)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDTSCD:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.TSCD)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDAES:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.AES)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDXSAVE:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.XSAVE)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDOSXSAVE:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.OSXSAVE)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDAVX:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.AVX)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDF16C:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.F16C)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDRDRAND:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.RDRAND)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            case IDHV:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID1_ECX.HV)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));

            case IDFPU:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.FPU)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));
            case IDVME:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.VME)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));
            case IDDE:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.DE)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));
            case IDPSE:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.PSE)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));
            case IDTSC:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.TSC)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));
            case IDMSR:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.MSR)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));
            case IDPAE:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.PAE)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));
            case IDCX8:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.CX8)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));
            case IDAPIC:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.APIC)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));
            case IDSEP:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.SEP)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));
            case IDMTRR:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.MTRR)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));
            case IDPGE:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.PGE)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));
            case IDMCA:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.MCA)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));
            case IDCMOV:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.CMOV)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));
            case IDPAT:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.PAT)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));
            case IDPSE36:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.PSE36)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));
            case IDPSN:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.PSN)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));
            case IDCLFL:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.CLFL)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));
            case IDDS:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.DS)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));
            case IDACPI:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.ACPI)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));
            case IDMMX:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.MMX)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));
            case IDFXSR:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.FXSR)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));
            case IDSSE:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.SSE)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));
            case IDSSE2:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.SSE2)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));
            case IDSS:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.SS)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));
            case IDHTT:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.HTT)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));
            case IDTM:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.TM)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));
            case IDIA64:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.IA64)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));
            case IDPBE:
                assert(instr.markFormat("n"));
                return stage(Instruction(OpCode.CPUID, 1)) +
                stage(Instruction(OpCode.AND, edx, 1 << CPUID1_EDX.PBE)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], edx));
            default:
                assert(0, "Invalid instruction staging!");
        }
        return -1;
    }
}