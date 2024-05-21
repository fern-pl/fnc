/// Code generation facilities for compiler backend.
module fnc.emission.x86;

public import gallinule.x86;
import std.typecons;
import fnc.emission.ir;
import fnc.symbols;
import std.traits;

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
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.VME));
            case CRIDPVI:
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.PVI));
            case CRIDTSD:
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.TSD));
            case CRIDDE:
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.DE));
            case CRIDPSE:
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.PSE));
            case CRIDPAE:
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.PAE));
            case CRIDMCE:
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.MCE));
            case CRIDPGE:
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.PGE));
            case CRIDPCE:
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.PCE));
            case CRIDOSFXSR:
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.OSFXSR));
            case CRIDOSXMMEXCPT:
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.OSXMMEXCPT));
            case CRIDUMIP:
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.UMIP));
            case CRIDVMXE:
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.VMXE));
            case CRIDSMXE:
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.SMXE));
            case CRIDFSGSBASE:
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.FSGSBASE));
            case CRIDPCIDE:
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.PCIDE));
            case CRIDOSXSAVE:
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.OSXSAVE));
            case CRIDSMEP:
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.SMEP));
            case CRIDSMAP:
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.SMAP));
            case CRIDPKE:
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.PKE));
            case CRIDCET:
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.CET));
            case CRIDPKS:
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.PKS));
            case CRIDUINTR:
                return stage(Instruction(OpCode.MOV, instr.operands[0], cr4)) +
                stage(Instruction(OpCode.AND, instr.operands[0], 1 << CRID.UINTR));

            case IDAVX512VL:
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.AVX512VL)) +
                // NOTE: This would have problems depending on what marker is the first operand.
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDAVX512BW:
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.AVX512BW)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDSHA:
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.SHA)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDAVX512CD:
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.AVX512CD)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDAVX512ER:
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.AVX512ER)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDAVX512PF:
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.AVX512PF)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDPT:
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.PT)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDCLWB:
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.CLWB)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDCLFLUSHOPT:
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.CLFLUSHOPT)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDPCOMMIT:
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.PCOMMIT)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDAVX512IFMA:
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.AVX512IFMA)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDSMAP:
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.SMAP)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDADX:
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.ADX)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDRDSEED:
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.RDSEED)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDAVX512DQ:
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.AVX512DQ)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDAVX512F:
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.AVX512F)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDPQE:
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.PQE)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDRTM:
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.RTM)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDINVPCID:
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.INVPCID)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDERMS:
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.ERMS)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDBMI2:
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.BMI2)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDSMEP:
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.SMEP)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDFPDP:
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.FPDP)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDAVX2:
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.AVX2)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDHLE:
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.HLE)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDBMI1:
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.BMI1)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDSGX:
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.SGX)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDTSCADJ:
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.TSC_ADJUST)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));
            case IDFSGSBASE:
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ebx, 1 << CPUID7_EBX.FSGSBASE)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ebx));

            case IDPREFETCHWT1:
                return stage(Instruction(OpCode.CPUID, 7)) +
                stage(Instruction(OpCode.AND, ecx, 1 << CPUID7_ECX.PREFETCHWT1)) +
                stage(Instruction(OpCode.MOV, instr.operands[0], ecx));
            default:
                assert(0, "Invalid instruction staging!");
        }
        return -1;
    }
}

auto emit(ref Block!true block, Instruction instr)
{
    // Should check to make sure the instruction is valid,
    // conditional instructions need to have an actual condition flag.
    //assert(!instr.details.hasFlag(Details.ILLEGAL), "Invalid instruction, are you missing a condition?");

    with (block) with (OpCode) switch (instr.opcode)
    {
        case CRIDVME:
            enum ofn = "cridvme";
            mixin(ofn~"();");
            break;
        case CRIDPVI:
            enum ofn = "cridpvi";
            mixin(ofn~"();");
            break;
        case CRIDTSD:
            enum ofn = "cridtsd";
            mixin(ofn~"();");
            break;
        case CRIDDE:
            enum ofn = "cridde";
            mixin(ofn~"();");
            break;
        case CRIDPSE:
            enum ofn = "cridpse";
            mixin(ofn~"();");
            break;
        case CRIDPAE:
            enum ofn = "cridpae";
            mixin(ofn~"();");
            break;
        case CRIDMCE:
            enum ofn = "cridmce";
            mixin(ofn~"();");
            break;
        case CRIDPGE:
            enum ofn = "cridpge";
            mixin(ofn~"();");
            break;
        case CRIDPCE:
            enum ofn = "cridpce";
            mixin(ofn~"();");
            break;
        case CRIDOSFXSR:
            enum ofn = "cridosfxsr";
            mixin(ofn~"();");
            break;
        case CRIDOSXMMEXCPT:
            enum ofn = "cridosxmmexcpt";
            mixin(ofn~"();");
            break;
        case CRIDUMIP:
            enum ofn = "cridumip";
            mixin(ofn~"();");
            break;
        case CRIDVMXE:
            enum ofn = "cridvmxe";
            mixin(ofn~"();");
            break;
        case CRIDSMXE:
            enum ofn = "cridsmxe";
            mixin(ofn~"();");
            break;
        case CRIDFSGSBASE:
            enum ofn = "cridfsgsbase";
            mixin(ofn~"();");
            break;
        case CRIDPCIDE:
            enum ofn = "cridpcide";
            mixin(ofn~"();");
            break;
        case CRIDOSXSAVE:
            enum ofn = "cridosxsave";
            mixin(ofn~"();");
            break;
        case CRIDSMEP:
            enum ofn = "cridsmep";
            mixin(ofn~"();");
            break;
        case CRIDSMAP:
            enum ofn = "cridsmap";
            mixin(ofn~"();");
            break;
        case CRIDPKE:
            enum ofn = "cridpke";
            mixin(ofn~"();");
            break;
        case CRIDCET:
            enum ofn = "cridcet";
            mixin(ofn~"();");
            break;
        case CRIDPKS:
            enum ofn = "cridpks";
            mixin(ofn~"();");
            break;
        case CRIDUINTR:
            enum ofn = "criduintr";
            mixin(ofn~"();");
            break;
        case IDAVX512VL:
            enum ofn = "idavx512vl";
            mixin(ofn~"();");
            break;
        case IDAVX512BW:
            enum ofn = "idavx512bw";
            mixin(ofn~"();");
            break;
        case IDSHA:
            enum ofn = "idsha";
            mixin(ofn~"();");
            break;
        case IDAVX512CD:
            enum ofn = "idavx512cd";
            mixin(ofn~"();");
            break;
        case IDAVX512ER:
            enum ofn = "idavx512er";
            mixin(ofn~"();");
            break;
        case IDAVX512PF:
            enum ofn = "idavx512pf";
            mixin(ofn~"();");
            break;
        case IDPT:
            enum ofn = "idpt";
            mixin(ofn~"();");
            break;
        case IDCLWB:
            enum ofn = "idclwb";
            mixin(ofn~"();");
            break;
        case IDCLFLUSHOPT:
            enum ofn = "idclflushopt";
            mixin(ofn~"();");
            break;
        case IDPCOMMIT:
            enum ofn = "idpcommit";
            mixin(ofn~"();");
            break;
        case IDAVX512IFMA:
            enum ofn = "idavx512ifma";
            mixin(ofn~"();");
            break;
        case IDSMAP:
            enum ofn = "idsmap";
            mixin(ofn~"();");
            break;
        case IDADX:
            enum ofn = "idadx";
            mixin(ofn~"();");
            break;
        case IDRDSEED:
            enum ofn = "idrdseed";
            mixin(ofn~"();");
            break;
        case IDAVX512DQ:
            enum ofn = "idavx512dq";
            mixin(ofn~"();");
            break;
        case IDAVX512F:
            enum ofn = "idavx512f";
            mixin(ofn~"();");
            break;
        case IDPQE:
            enum ofn = "idpqe";
            mixin(ofn~"();");
            break;
        case IDRTM:
            enum ofn = "idrtm";
            mixin(ofn~"();");
            break;
        case IDINVPCID:
            enum ofn = "idinvpcid";
            mixin(ofn~"();");
            break;
        case IDERMS:
            enum ofn = "iderms";
            mixin(ofn~"();");
            break;
        case IDBMI2:
            enum ofn = "idbmi2";
            mixin(ofn~"();");
            break;
        case IDSMEP:
            enum ofn = "idsmep";
            mixin(ofn~"();");
            break;
        case IDFPDP:
            enum ofn = "idfpdp";
            mixin(ofn~"();");
            break;
        case IDAVX2:
            enum ofn = "idavx2";
            mixin(ofn~"();");
            break;
        case IDHLE:
            enum ofn = "idhle";
            mixin(ofn~"();");
            break;
        case IDBMI1:
            enum ofn = "idbmi1";
            mixin(ofn~"();");
            break;
        case IDSGX:
            enum ofn = "idsgx";
            mixin(ofn~"();");
            break;
        case IDTSCADJ:
            enum ofn = "idtscadj";
            mixin(ofn~"();");
            break;
        case IDFSGSBASE:
            enum ofn = "idfsgsbase";
            mixin(ofn~"();");
            break;
        case IDPREFETCHWT1:
            enum ofn = "idprefetchwt1";
            mixin(ofn~"();");
            break;
        case IDAVX512VBMI:
            enum ofn = "idavx512vbmi";
            mixin(ofn~"();");
            break;
        case IDUMIP:
            enum ofn = "idumip";
            mixin(ofn~"();");
            break;
        case IDPKU:
            enum ofn = "idpku";
            mixin(ofn~"();");
            break;
        case IDAVX512VBMI2:
            enum ofn = "idavx512vbmi2";
            mixin(ofn~"();");
            break;
        case IDCET:
            enum ofn = "idcet";
            mixin(ofn~"();");
            break;
        case IDGFNI:
            enum ofn = "idgfni";
            mixin(ofn~"();");
            break;
        case IDVAES:
            enum ofn = "idvaes";
            mixin(ofn~"();");
            break;
        case IDVPCL:
            enum ofn = "idvpcl";
            mixin(ofn~"();");
            break;
        case IDAVX512VNNI:
            enum ofn = "idavx512vnni";
            mixin(ofn~"();");
            break;
        case IDAVX512BITALG:
            enum ofn = "idavx512bitalg";
            mixin(ofn~"();");
            break;
        case IDTME:
            enum ofn = "idtme";
            mixin(ofn~"();");
            break;
        case IDAVX512VP:
            enum ofn = "idavx512vp";
            mixin(ofn~"();");
            break;
        case IDVA57:
            enum ofn = "idva57";
            mixin(ofn~"();");
            break;
        case IDRDPID:
            enum ofn = "idrdpid";
            mixin(ofn~"();");
            break;
        case IDSGXLC:
            enum ofn = "idsgxlc";
            mixin(ofn~"();");
            break;
        case IDAVX512QVNNIW:
            enum ofn = "idavx512qvnniw";
            mixin(ofn~"();");
            break;
        case IDAVX512QFMA:
            enum ofn = "idavx512qfma";
            mixin(ofn~"();");
            break;
        case IDPCONFIG:
            enum ofn = "idpconfig";
            mixin(ofn~"();");
            break;
        case IDIBRSIBPB:
            enum ofn = "idibrsibpb";
            mixin(ofn~"();");
            break;
        case IDSTIBP:
            enum ofn = "idstibp";
            mixin(ofn~"();");
            break;
        case IDSSE3:
            enum ofn = "idsse3";
            mixin(ofn~"();");
            break;
        case IDPCLMUL:
            enum ofn = "idpclmul";
            mixin(ofn~"();");
            break;
        case IDDTES64:
            enum ofn = "iddtes64";
            mixin(ofn~"();");
            break;
        case IDMON:
            enum ofn = "idmon";
            mixin(ofn~"();");
            break;
        case IDDSCPL:
            enum ofn = "iddscpl";
            mixin(ofn~"();");
            break;
        case IDVMX:
            enum ofn = "idvmx";
            mixin(ofn~"();");
            break;
        case IDSMX:
            enum ofn = "idsmx";
            mixin(ofn~"();");
            break;
        case IDEST:
            enum ofn = "idest";
            mixin(ofn~"();");
            break;
        case IDTM2:
            enum ofn = "idtm2";
            mixin(ofn~"();");
            break;
        case IDSSSE3:
            enum ofn = "idssse3";
            mixin(ofn~"();");
            break;
        case IDCID:
            enum ofn = "idcid";
            mixin(ofn~"();");
            break;
        case IDSDBG:
            enum ofn = "idsdbg";
            mixin(ofn~"();");
            break;
        case IDFMA:
            enum ofn = "idfma";
            mixin(ofn~"();");
            break;
        case IDCX16:
            enum ofn = "idcx16";
            mixin(ofn~"();");
            break;
        case IDXTPR:
            enum ofn = "idxtpr";
            mixin(ofn~"();");
            break;
        case IDPDCM:
            enum ofn = "idpdcm";
            mixin(ofn~"();");
            break;
        case IDPCID:
            enum ofn = "idpcid";
            mixin(ofn~"();");
            break;
        case IDDCA:
            enum ofn = "iddca";
            mixin(ofn~"();");
            break;
        case IDSSE41:
            enum ofn = "idsse41";
            mixin(ofn~"();");
            break;
        case IDSSE42:
            enum ofn = "idsse42";
            mixin(ofn~"();");
            break;
        case IDX2APIC:
            enum ofn = "idx2apic";
            mixin(ofn~"();");
            break;
        case IDMOVBE:
            enum ofn = "idmovbe";
            mixin(ofn~"();");
            break;
        case IDPOPCNT:
            enum ofn = "idpopcnt";
            mixin(ofn~"();");
            break;
        case IDTSCD:
            enum ofn = "idtscd";
            mixin(ofn~"();");
            break;
        case IDAES:
            enum ofn = "idaes";
            mixin(ofn~"();");
            break;
        case IDXSAVE:
            enum ofn = "idxsave";
            mixin(ofn~"();");
            break;
        case IDOSXSAVE:
            enum ofn = "idosxsave";
            mixin(ofn~"();");
            break;
        case IDAVX:
            enum ofn = "idavx";
            mixin(ofn~"();");
            break;
        case IDF16C:
            enum ofn = "idf16c";
            mixin(ofn~"();");
            break;
        case IDRDRAND:
            enum ofn = "idrdrand";
            mixin(ofn~"();");
            break;
        case IDHV:
            enum ofn = "idhv";
            mixin(ofn~"();");
            break;
        case IDFPU:
            enum ofn = "idfpu";
            mixin(ofn~"();");
            break;
        case IDVME:
            enum ofn = "idvme";
            mixin(ofn~"();");
            break;
        case IDDE:
            enum ofn = "idde";
            mixin(ofn~"();");
            break;
        case IDPSE:
            enum ofn = "idpse";
            mixin(ofn~"();");
            break;
        case IDTSC:
            enum ofn = "idtsc";
            mixin(ofn~"();");
            break;
        case IDMSR:
            enum ofn = "idmsr";
            mixin(ofn~"();");
            break;
        case IDPAE:
            enum ofn = "idpae";
            mixin(ofn~"();");
            break;
        case IDCX8:
            enum ofn = "idcx8";
            mixin(ofn~"();");
            break;
        case IDAPIC:
            enum ofn = "idapic";
            mixin(ofn~"();");
            break;
        case IDSEP:
            enum ofn = "idsep";
            mixin(ofn~"();");
            break;
        case IDMTRR:
            enum ofn = "idmtrr";
            mixin(ofn~"();");
            break;
        case IDPGE:
            enum ofn = "idpge";
            mixin(ofn~"();");
            break;
        case IDMCA:
            enum ofn = "idmca";
            mixin(ofn~"();");
            break;
        case IDCMOV:
            enum ofn = "idcmov";
            mixin(ofn~"();");
            break;
        case IDPAT:
            enum ofn = "idpat";
            mixin(ofn~"();");
            break;
        case IDPSE36:
            enum ofn = "idpse36";
            mixin(ofn~"();");
            break;
        case IDPSN:
            enum ofn = "idpsn";
            mixin(ofn~"();");
            break;
        case IDCLFL:
            enum ofn = "idclfl";
            mixin(ofn~"();");
            break;
        case IDDS:
            enum ofn = "idds";
            mixin(ofn~"();");
            break;
        case IDACPI:
            enum ofn = "idacpi";
            mixin(ofn~"();");
            break;
        case IDMMX:
            enum ofn = "idmmx";
            mixin(ofn~"();");
            break;
        case IDFXSR:
            enum ofn = "idfxsr";
            mixin(ofn~"();");
            break;
        case IDSSE:
            enum ofn = "idsse";
            mixin(ofn~"();");
            break;
        case IDSSE2:
            enum ofn = "idsse2";
            mixin(ofn~"();");
            break;
        case IDSS:
            enum ofn = "idss";
            mixin(ofn~"();");
            break;
        case IDHTT:
            enum ofn = "idhtt";
            mixin(ofn~"();");
            break;
        case IDTM:
            enum ofn = "idtm";
            mixin(ofn~"();");
            break;
        case IDIA64:
            enum ofn = "idia64";
            mixin(ofn~"();");
            break;
        case IDPBE:
            enum ofn = "idpbe";
            mixin(ofn~"();");
            break;
        case PFADD:
            assert (instr.markFormat("rn"));
            if (instr.operands[1].kind == Kind.ALLOCATION)
                pfadd(instr.operands[0].as!MMX, instr.operands[1].as!(Address!64));
            else
                pfadd(instr.operands[0].as!MMX, instr.operands[1].as!MMX);
            break;
        case PFSUB:
            assert (instr.markFormat("rn"));
            if (instr.operands[1].kind == Kind.ALLOCATION)
                pfsub(instr.operands[0].as!MMX, instr.operands[1].as!(Address!64));
            else
                pfsub(instr.operands[0].as!MMX, instr.operands[1].as!MMX);
            break;
        case PFSUBR:
            assert (instr.markFormat("rn"));
            if (instr.operands[1].kind == Kind.ALLOCATION)
                pfsubr(instr.operands[0].as!MMX, instr.operands[1].as!(Address!64));
            else
                pfsubr(instr.operands[0].as!MMX, instr.operands[1].as!MMX);
            break;
        case PFMUL:
            assert (instr.markFormat("rn"));
            if (instr.operands[1].kind == Kind.ALLOCATION)
                pfmul(instr.operands[0].as!MMX, instr.operands[1].as!(Address!64));
            else
                pfmul(instr.operands[0].as!MMX, instr.operands[1].as!MMX);
            break;
        case PFCMPEQ:
            assert (instr.markFormat("rn"));
            if (instr.operands[1].kind == Kind.ALLOCATION)
                pfcmpeq(instr.operands[0].as!MMX, instr.operands[1].as!(Address!64));
            else
                pfcmpeq(instr.operands[0].as!MMX, instr.operands[1].as!MMX);
            break;
        case PFCMPGE:
            assert (instr.markFormat("rn"));
            if (instr.operands[1].kind == Kind.ALLOCATION)
                pfcmpge(instr.operands[0].as!MMX, instr.operands[1].as!(Address!64));
            else
                pfcmpge(instr.operands[0].as!MMX, instr.operands[1].as!MMX);
            break;
        case PFCMPGT:
            assert (instr.markFormat("rn"));
            if (instr.operands[1].kind == Kind.ALLOCATION)
                pfcmpgt(instr.operands[0].as!MMX, instr.operands[1].as!(Address!64));
            else
                pfcmpgt(instr.operands[0].as!MMX, instr.operands[1].as!MMX);
            break;
        case PF2ID:
            assert (instr.markFormat("rn"));
            if (instr.operands[1].kind == Kind.ALLOCATION)
                pf2id(instr.operands[0].as!MMX, instr.operands[1].as!(Address!64));
            else
                pf2id(instr.operands[0].as!MMX, instr.operands[1].as!MMX);
            break;
        case PI2FD:
            assert (instr.markFormat("rn"));
            if (instr.operands[1].kind == Kind.ALLOCATION)
                pi2fd(instr.operands[0].as!MMX, instr.operands[1].as!(Address!64));
            else
                pi2fd(instr.operands[0].as!MMX, instr.operands[1].as!MMX);
            break;
        case PF2IW:
            assert (instr.markFormat("rn"));
            if (instr.operands[1].kind == Kind.ALLOCATION)
                pf2iw(instr.operands[0].as!MMX, instr.operands[1].as!(Address!64));
            else
                pf2iw(instr.operands[0].as!MMX, instr.operands[1].as!MMX);
            break;
        case PI2FW:
            assert (instr.markFormat("rn"));
            if (instr.operands[1].kind == Kind.ALLOCATION)
                pi2fw(instr.operands[0].as!MMX, instr.operands[1].as!(Address!64));
            else
                pi2fw(instr.operands[0].as!MMX, instr.operands[1].as!MMX);
            break;
        case PFMAX:
            assert (instr.markFormat("rn"));
            if (instr.operands[1].kind == Kind.ALLOCATION)
                pfmax(instr.operands[0].as!MMX, instr.operands[1].as!(Address!64));
            else
                pfmax(instr.operands[0].as!MMX, instr.operands[1].as!MMX);
            break;
        case PFMIN:
            assert (instr.markFormat("rn"));
            if (instr.operands[1].kind == Kind.ALLOCATION)
                pfmin(instr.operands[0].as!MMX, instr.operands[1].as!(Address!64));
            else
                pfmin(instr.operands[0].as!MMX, instr.operands[1].as!MMX);
            break;
        case PFRCP:
            assert (instr.markFormat("rn"));
            if (instr.operands[1].kind == Kind.ALLOCATION)
                pfrcp(instr.operands[0].as!MMX, instr.operands[1].as!(Address!64));
            else
                pfrcp(instr.operands[0].as!MMX, instr.operands[1].as!MMX);
            break;
        case PFRSQRT:
            assert (instr.markFormat("rn"));
            if (instr.operands[1].kind == Kind.ALLOCATION)
                pfrsqrt(instr.operands[0].as!MMX, instr.operands[1].as!(Address!64));
            else
                pfrsqrt(instr.operands[0].as!MMX, instr.operands[1].as!MMX);
            break;
        case PFRCPIT1:
            assert (instr.markFormat("rn"));
            if (instr.operands[1].kind == Kind.ALLOCATION)
                pfrcpit1(instr.operands[0].as!MMX, instr.operands[1].as!(Address!64));
            else
                pfrcpit1(instr.operands[0].as!MMX, instr.operands[1].as!MMX);
            break;
        case PFRSQIT1:
            assert (instr.markFormat("rn"));
            if (instr.operands[1].kind == Kind.ALLOCATION)
                pfrsqit1(instr.operands[0].as!MMX, instr.operands[1].as!(Address!64));
            else
                pfrsqit1(instr.operands[0].as!MMX, instr.operands[1].as!MMX);
            break;
        case PFRCPIT2:
            assert (instr.markFormat("rn"));
            if (instr.operands[1].kind == Kind.ALLOCATION)
                pfrcpit2(instr.operands[0].as!MMX, instr.operands[1].as!(Address!64));
            else
                pfrcpit2(instr.operands[0].as!MMX, instr.operands[1].as!MMX);
            break;
        case PFACC:
            assert (instr.markFormat("rn"));
            if (instr.operands[1].kind == Kind.ALLOCATION)
                pfacc(instr.operands[0].as!MMX, instr.operands[1].as!(Address!64));
            else
                pfacc(instr.operands[0].as!MMX, instr.operands[1].as!MMX);
            break;
        case PFNACC:
            assert (instr.markFormat("rn"));
            if (instr.operands[1].kind == Kind.ALLOCATION)
                pfnacc(instr.operands[0].as!MMX, instr.operands[1].as!(Address!64));
            else
                pfnacc(instr.operands[0].as!MMX, instr.operands[1].as!MMX);
            break;
        case PFPNACC:
            assert (instr.markFormat("rn"));
            if (instr.operands[1].kind == Kind.ALLOCATION)
                pfpnacc(instr.operands[0].as!MMX, instr.operands[1].as!(Address!64));
            else
                pfpnacc(instr.operands[0].as!MMX, instr.operands[1].as!MMX);
            break;
        case PMULHRW:
            assert (instr.markFormat("rn"));
            if (instr.operands[1].kind == Kind.ALLOCATION)
                pmulhrw(instr.operands[0].as!MMX, instr.operands[1].as!(Address!64));
            else
                pmulhrw(instr.operands[0].as!MMX, instr.operands[1].as!MMX);
            break;
        case PAVGUSB:
            assert (instr.markFormat("rn"));
            if (instr.operands[1].kind == Kind.ALLOCATION)
                pavgusb(instr.operands[0].as!MMX, instr.operands[1].as!(Address!64));
            else
                pavgusb(instr.operands[0].as!MMX, instr.operands[1].as!MMX);
            break;
        case PSWAPD:
            assert (instr.markFormat("rn"));
            if (instr.operands[1].kind == Kind.ALLOCATION)
                pswapd(instr.operands[0].as!MMX, instr.operands[1].as!(Address!64));
            else
                pswapd(instr.operands[0].as!MMX, instr.operands[1].as!MMX);
            break;
        case FEMMS:
            enum ofn = "femms";
            mixin(ofn~"();");
            break;
        case ICEBP:
            enum ofn = "icebp";
            mixin(ofn~"();");
            break;
        case PTWRITE:
            assert (instr.markFormat("n"));
            if (instr.operands[0].size == 4)
            {
                if (instr.operands[0].kind == Kind.ALLOCATION)
                    ptwrite(instr.operands[0].as!(Address!32));
                else
                    ptwrite(instr.operands[0].as!R32);
            }
            else
            {
                if (instr.operands[0].kind == Kind.ALLOCATION)
                    ptwrite(instr.operands[0].as!(Address!64));
                else
                    ptwrite(instr.operands[0].as!R64);
            }
            break;
        case CLWB:
            assert (instr.markFormat("n"));
            if (instr.operands[0].kind == Kind.ALLOCATION)
                clwb(instr.operands[0].as!(Address!8));
            else
                clwb(instr.operands[0].as!R8);
            break;
        case CLFLUSHOPT:
            assert (instr.markFormat("n"));
            if (instr.operands[0].kind == Kind.ALLOCATION)
                clflushopt(instr.operands[0].as!(Address!8));
            else
                clflushopt(instr.operands[0].as!R8);
            break;
        case STAC:
            enum ofn = "stac";
            mixin(ofn~"();");
            break;
        case CLAC:
            enum ofn = "clac";
            mixin(ofn~"();");
            break;
        case ADC:
            if (instr.markFormat("l"))
            {
                if (instr.markFormat("1"))
                    adc(instr.operands[0].b);
                else if (instr.markFormat("2"))
                    adc(instr.operands[0].w);
                else if (instr.markFormat("4"))
                    adc(instr.operands[0].d);
                else if (instr.markFormat("8"))
                    adc(instr.operands[0].q);
            }
            else if (instr.markFormat("rl"))
            {
                if (instr.markFormat("11"))
                    adc(instr.operands[0].as!R8, instr.operands[1].b);
                else if (instr.markFormat("21"))
                    adc(instr.operands[0].as!R16, instr.operands[1].b);
                else if (instr.markFormat("22"))
                    adc(instr.operands[0].as!R16, instr.operands[1].w);
                else if (instr.markFormat("41"))
                    adc(instr.operands[0].as!R32, instr.operands[1].b);
                else if (instr.markFormat("44"))
                    adc(instr.operands[0].as!R32, instr.operands[1].d);
                else if (instr.markFormat("81"))
                    adc(instr.operands[0].as!R64, instr.operands[1].b);
                else if (instr.markFormat("84"))
                    adc(instr.operands[0].as!R64, instr.operands[1].d);
            }
            else if (instr.markFormat("ml"))
            {
                if (instr.markFormat("11"))
                    adc(instr.operands[0].as!(Address!8), instr.operands[1].b);
                else if (instr.markFormat("21"))
                    adc(instr.operands[0].as!(Address!16), instr.operands[1].b);
                else if (instr.markFormat("22"))
                    adc(instr.operands[0].as!(Address!16), instr.operands[1].w);
                else if (instr.markFormat("41"))
                    adc(instr.operands[0].as!(Address!32), instr.operands[1].b);
                else if (instr.markFormat("44"))
                    adc(instr.operands[0].as!(Address!32), instr.operands[1].d);
                else if (instr.markFormat("81"))
                    adc(instr.operands[0].as!(Address!64), instr.operands[1].b);
                else if (instr.markFormat("84"))
                    adc(instr.operands[0].as!(Address!64), instr.operands[1].d);
            }
            else if (instr.markFormat("nr"))
            {
                // TODO:
            }
            else if (instr.markFormat("nm"))
            {
                
            }
            break;
        case ADCX:
            enum ofn = "adcx";
            break;
        case ADOX:
            enum ofn = "adox";
            break;
        case RDSEED:
            enum ofn = "rdseed";
            break;
        case BNDCL:
            enum ofn = "bndcl";
            break;
        case BNDCU:
            enum ofn = "bndcu";
            break;
        case BNDLDX:
            enum ofn = "bndldx";
            break;
        case BNDSTX:
            enum ofn = "bndstx";
            break;
        case BNDMK:
            enum ofn = "bndmk";
            break;
        case BNDMOV:
            enum ofn = "bndmov";
            break;
        case BOUND:
            enum ofn = "bound";
            break;
        case XEND:
            enum ofn = "xend";
            mixin(ofn~"();");
            break;
        case XABORT:
            enum ofn = "xabort";
            break;
        case XBEGIN:
            enum ofn = "xbegin";
            break;
        case XTEST:
            enum ofn = "xtest";
            mixin(ofn~"();");
            break;
        case INVPCID:
            enum ofn = "invpcid";
            break;
        case XACQUIRE:
            enum ofn = "xacquire";
            mixin(ofn~"(0);");
            break;
        case XRELEASE:
            enum ofn = "xrelease";
            mixin(ofn~"(0);");
            break;
        case TZCNT:
            enum ofn = "tzcnt";
            break;
        case LZCNT:
            enum ofn = "lzcnt";
            break;
        case ANDN:
            enum ofn = "andn";
            break;
        case ECREATE:
            enum ofn = "encls_ecreate";
            mixin(ofn~"();");
            break;
        case EINIT:
            enum ofn = "encls_einit";
            mixin(ofn~"();");
            break;
        case EREMOVE:
            enum ofn = "encls_eremove";
            mixin(ofn~"();");
            break;
        case EDBGRD:
            enum ofn = "encls_edbgrd";
            mixin(ofn~"();");
            break;
        case EDBGWR:
            enum ofn = "encls_edbgwr";
            mixin(ofn~"();");
            break;
        case EEXTEND:
            enum ofn = "encls_eextend";
            mixin(ofn~"();");
            break;
        case ELDB:
            enum ofn = "encls_eldb";
            mixin(ofn~"();");
            break;
        case ELDU:
            enum ofn = "encls_eldu";
            mixin(ofn~"();");
            break;
        case EBLOCK:
            enum ofn = "encls_eblock";
            mixin(ofn~"();");
            break;
        case EPA:
            enum ofn = "encls_epa";
            mixin(ofn~"();");
            break;
        case EWB:
            enum ofn = "encls_ewb";
            mixin(ofn~"();");
            break;
        case ETRACK:
            enum ofn = "encls_etrack";
            mixin(ofn~"();");
            break;
        case EAUG:
            enum ofn = "encls_eaug";
            mixin(ofn~"();");
            break;
        case EMODPR:
            enum ofn = "encls_emodpr";
            mixin(ofn~"();");
            break;
        case EMODT:
            enum ofn = "encls_emodt";
            mixin(ofn~"();");
            break;
        case ERDINFO:
            enum ofn = "encls_erdinfo";
            mixin(ofn~"();");
            break;
        case ETRACKC:
            enum ofn = "encls_etrackc";
            mixin(ofn~"();");
            break;
        case ELDBC:
            enum ofn = "encls_eldbc";
            mixin(ofn~"();");
            break;
        case ELDUC:
            enum ofn = "encls_elduc";
            mixin(ofn~"();");
            break;
        case EREPORT:
            enum ofn = "enclu_ereport";
            mixin(ofn~"();");
            break;
        case EGETKEY:
            enum ofn = "enclu_egetkey";
            mixin(ofn~"();");
            break;
        case EENTER:
            enum ofn = "enclu_eenter";
            mixin(ofn~"();");
            break;
        case EEXIT:
            enum ofn = "enclu_eexit";
            mixin(ofn~"();");
            break;
        case EACCEPT:
            enum ofn = "enclu_eaccept";
            mixin(ofn~"();");
            break;
        case EMODPE:
            enum ofn = "enclu_emodpe";
            mixin(ofn~"();");
            break;
        case EACCEPTCOPY:
            enum ofn = "enclu_eacceptcopy";
            mixin(ofn~"();");
            break;
        case EDECCSSA:
            enum ofn = "enclu_edeccssa";
            mixin(ofn~"();");
            break;
        case EDECVIRTCHILD:
            enum ofn = "enclv_edecvirtchild";
            mixin(ofn~"();");
            break;
        case EINCVIRTCHILD:
            enum ofn = "enclv_eincvirtchild";
            mixin(ofn~"();");
            break;
        case ESETCONTEXT:
            enum ofn = "enclv_esetcontext";
            mixin(ofn~"();");
            break;
        case MONITOR:
            enum ofn = "monitor";
            mixin(ofn~"();");
            break;
        case MWAIT:
            enum ofn = "mwait";
            mixin(ofn~"();");
            break;
        case INVVPID:
            enum ofn = "invvpid";
            break;
        case INVEPT:
            enum ofn = "invept";
            break;
        case VMCALL:
            enum ofn = "vmcall";
            mixin(ofn~"();");
            break;
        case VMFUNC:
            enum ofn = "vmfunc";
            mixin(ofn~"();");
            break;
        case VMCLEAR:
            enum ofn = "vmclear";
            break;
        case VMLAUNCH:
            enum ofn = "vmlaunch";
            mixin(ofn~"();");
            break;
        case VMRESUME:
            enum ofn = "vmresume";
            mixin(ofn~"();");
            break;
        case VMXOFF:
            enum ofn = "vmxoff";
            mixin(ofn~"();");
            break;
        case VMXON:
            enum ofn = "vmxon";
            break;
        case VMWRITE:
            enum ofn = "vmwrite";
            break;
        case VMREAD:
            enum ofn = "vmread";
            break;
        case VMPTRST:
            enum ofn = "vmptrst";
            break;
        case VMPTRLD:
            enum ofn = "vmptrld";
            break;
        case CAPABILITIES:
            enum ofn = "getsec_capabilities";
            mixin(ofn~"();");
            break;
        case ENTERACCS:
            enum ofn = "getsec_enteraccs";
            mixin(ofn~"();");
            break;
        case EXITAC:
            enum ofn = "getsec_exitac";
            mixin(ofn~"();");
            break;
        case SENTER:
            enum ofn = "getsec_senter";
            mixin(ofn~"();");
            break;
        case SEXIT:
            enum ofn = "getsec_sexit";
            mixin(ofn~"();");
            break;
        case PARAMETERS:
            enum ofn = "getsec_parameters";
            mixin(ofn~"();");
            break;
        case SMCTRL:
            enum ofn = "getsec_smctrl";
            mixin(ofn~"();");
            break;
        case WAKEUP:
            enum ofn = "getsec_wakeup";
            mixin(ofn~"();");
            break;
        case CMPXCHG16B:
            enum ofn = "cmpxchg16b";
            break;
        case POPCNT:
            enum ofn = "popcnt";
            break;
        case XGETBV:
            enum ofn = "xgetbv";
            mixin(ofn~"();");
            break;
        case XSETBV:
            enum ofn = "xsetbv";
            mixin(ofn~"();");
            break;
        case XRSTOR:
            enum ofn = "xrstor";
            break;
        case XSAVE:
            enum ofn = "xsave";
            break;
        case XRSTORS:
            enum ofn = "xrstors";
            break;
        case XSAVES:
            enum ofn = "xsaves";
            break;
        case XSAVEOPT:
            enum ofn = "xsaveopt";
            break;
        case XSAVEC:
            enum ofn = "xsavec";
            break;
        case RDRAND:
            enum ofn = "rdrand";
            break;
        case FABS:
            enum ofn = "fabs";
            mixin(ofn~"();");
            break;
        case FCHS:
            enum ofn = "fchs";
            mixin(ofn~"();");
            break;
        case FCLEX:
            enum ofn = "fclex";
            mixin(ofn~"();");
            break;
        case FNCLEX:
            enum ofn = "fnclex";
            mixin(ofn~"();");
            break;
        case FADD:
            if (instr.markFormat("m"))
            {
                if (instr.operands[0].size == 4)
                    fadd(instr.operands[0].as!(Address!32));
                else if (instr.operands[0].size == 8)
                    fadd(instr.operands[0].as!(Address!64));
            }
            else if (instr.operands[0].size == -3)
                fadd(instr.operands[0].as!ST, instr.operands[1].as!ST);
            break;
        case FADDP:
            assert(instr.markFormat("r"));
            faddp(instr.operands[0].as!ST);
            break;
        case FIADD:
            assert(instr.markFormat("m"));
            if (instr.operands[0].size == 2)
                fiadd(instr.operands[0].as!(Address!16));
            else if (instr.operands[0].size == 4)
                fiadd(instr.operands[0].as!(Address!32));
            break;
        case FBLD:
            assert(instr.markFormat("m"));
            fbld(instr.operands[0].as!(Address!80));
            break;
        case FBSTP:
            assert(instr.markFormat("m"));
            fbstp(instr.operands[0].as!(Address!80));
            break;
        case FCOM:
            if (instr.markFormat("m"))
            {
                if (instr.operands[0].size == 4)
                    fcom(instr.operands[0].as!(Address!32));
                else if (instr.operands[0].size == 8)
                    fcom(instr.operands[0].as!(Address!64));
            }
            else if (instr.operands[0].size == -3)
                fcom(instr.operands[0].as!ST);
            break;
        case FCOMP:
            if (instr.markFormat("m"))
            {
                if (instr.operands[0].size == 4)
                    fcomp(instr.operands[0].as!(Address!32));
                else if (instr.operands[0].size == 8)
                    fcomp(instr.operands[0].as!(Address!64));
            }
            else if (instr.operands[0].size == -3)
                fcomp(instr.operands[0].as!ST);
            break;
        case FCOMPP:
            enum ofn = "fcompp";
            mixin(ofn~"();");
            break;
        case FCOMI:
            assert(instr.markFormat("r"));
            fcomi(instr.operands[0].as!ST);
            break;
        case FCOMIP:
            assert(instr.markFormat("r"));
            fcomip(instr.operands[0].as!ST);
            break;
        case FUCOMI:
            assert(instr.markFormat("r"));
            fucomi(instr.operands[0].as!ST);
            break;
        case FUCOMIP:
            assert(instr.markFormat("r"));
            fucomip(instr.operands[0].as!ST);
            break;
        case FICOM:
            enum ofn = "ficom";
            break;
        case FICOMP:
            enum ofn = "ficomp";
            break;
        case FUCOM:
            enum ofn = "fucom";
            break;
        case FUCOMP:
            enum ofn = "fucomp";
            break;
        case FUCOMPP:
            enum ofn = "fucompp";
            break;
        case FTST:
            enum ofn = "ftst";
            mixin(ofn~"();");
            break;
        case F2XM1:
            enum ofn = "f2xm1";
            mixin(ofn~"();");
            break;
        case FYL2X:
            enum ofn = "fyl2x";
            mixin(ofn~"();");
            break;
        case FYL2XP1:
            enum ofn = "fyl2xp1";
            mixin(ofn~"();");
            break;
        case FCOS:
            enum ofn = "fcos";
            mixin(ofn~"();");
            break;
        case FSIN:
            enum ofn = "fsin";
            mixin(ofn~"();");
            break;
        case FSINCOS:
            enum ofn = "fsincos";
            mixin(ofn~"();");
            break;
        case FSQRT:
            enum ofn = "fsqrt";
            mixin(ofn~"();");
            break;
        case FPTAN:
            enum ofn = "fptan";
            mixin(ofn~"();");
            break;
        case FPATAN:
            enum ofn = "fpatan";
            mixin(ofn~"();");
            break;
        case FPREM:
            enum ofn = "fprem";
            mixin(ofn~"();");
            break;
        case FPREM1:
            enum ofn = "fprem1";
            mixin(ofn~"();");
            break;
        case FDECSTP:
            enum ofn = "fdecstp";
            mixin(ofn~"();");
            break;
        case FINCSTP:
            enum ofn = "fincstp";
            mixin(ofn~"();");
            break;
        case FILD:
            enum ofn = "fild";
            break;
        case FIST:
            enum ofn = "fist";
            break;
        case FISTP:
            enum ofn = "fistp";
            break;
        case FISTTP:
            enum ofn = "fisttp";
            break;
        case FLDCW:
            enum ofn = "fldcw";
            break;
        case FSTCW:
            enum ofn = "fstcw";
            break;
        case FNSTCW:
            enum ofn = "fnstcw";
            break;
        case FLDENV:
            enum ofn = "fldenv";
            break;
        case FSTENV:
            enum ofn = "fstenv";
            break;
        case FNSTENV:
            enum ofn = "fnstenv";
            break;
        case FSTSW:
            enum ofn = "fstsw";
            break;
        case FNSTSW:
            enum ofn = "fnstsw";
            break;
        case FLD:
            enum ofn = "fld";
            break;
        case FLD1:
            enum ofn = "fld1";
            mixin(ofn~"();");
            break;
        case FLDL2T:
            enum ofn = "fldl2t";
            mixin(ofn~"();");
            break;
        case FLDL2E:
            enum ofn = "fldl2e";
            mixin(ofn~"();");
            break;
        case FLDPI:
            enum ofn = "fldpi";
            mixin(ofn~"();");
            break;
        case FLDLG2:
            enum ofn = "fldlg2";
            mixin(ofn~"();");
            break;
        case FLDLN2:
            enum ofn = "fldln2";
            mixin(ofn~"();");
            break;
        case FLDZ:
            enum ofn = "fldz";
            mixin(ofn~"();");
            break;
        case FST:
            enum ofn = "fst";
            break;
        case FSTP:
            enum ofn = "fstp";
            break;
        case FDIV:
            enum ofn = "fdiv";
            break;
        case FDIVP:
            enum ofn = "fdivp";
            break;
        case FIDIV:
            enum ofn = "fidiv";
            break;
        case FDIVR:
            enum ofn = "fdivr";
            break;
        case FDIVRP:
            enum ofn = "fdivrp";
            break;
        case FIDIVR:
            enum ofn = "fidivr";
            break;
        case FSCALE:
            enum ofn = "fscale";
            break;
        case FRNDINT:
            enum ofn = "frndint";
            break;
        case FEXAM:
            enum ofn = "fexam";
            break;
        case FFREE:
            enum ofn = "ffree";
            break;
        case FXCH:
            enum ofn = "fxch";
            break;
        case FXTRACT:
            enum ofn = "fxtract";
            break;
        case FNOP:
            enum ofn = "fnop";
            break;
        case FNINIT:
            enum ofn = "fninit";
            break;
        case FINIT:
            enum ofn = "finit";
            break;
        case FSAVE:
            enum ofn = "fsave";
            break;
        case FNSAVE:
            enum ofn = "fnsave";
            break;
        case FRSTOR:
            enum ofn = "frstor";
            break;
        case FXSAVE:
            enum ofn = "fxsave";
            break;
        case FXRSTOR:
            enum ofn = "fxrstor";
            break;
        case FMUL:
            enum ofn = "fmul";
            break;
        case FMULP:
            enum ofn = "fmulp";
            break;
        case FIMUL:
            enum ofn = "fimul";
            break;
        case FSUB:
            enum ofn = "fsub";
            break;
        case FSUBP:
            enum ofn = "fsubp";
            break;
        case FISUB:
            enum ofn = "fisub";
            break;
        case FSUBR:
            enum ofn = "fsubr";
            break;
        case FSUBRP:
            enum ofn = "fsubrp";
            break;
        case FISUBR:
            enum ofn = "fisubr";
            break;
        case FCMOVCC:
            enum ofn = "fcmovcc";
            break;
        case RDMSR:
            enum ofn = "rdmsr";
            mixin(ofn~"();");
            break;
        case WRMSR:
            enum ofn = "wrmsr";
            mixin(ofn~"();");
            break;
        case CMPXCHG8B:
            enum ofn = "cmpxchg8b";
            break;
        case SYSENTER:
            enum ofn = "sysenter";
            mixin(ofn~"();");
            break;
        case SYSEXITC:
            enum ofn = "sysexitc";
            mixin(ofn~"();");
            break;
        case SYSEXIT:
            enum ofn = "sysexit";
            mixin(ofn~"();");
            break;
        case CMOVCC:
            enum ofn = "cmovcc";
            break;
        case CLFLUSH:
            enum ofn = "clflush";
            break;
        case HRESET:
            enum ofn = "hreset";
            break;
        case INCSSPD:
            enum ofn = "incsspd";
            break;
        case INCSSPQ:
            enum ofn = "incsspq";
            break;
        case CLRSSBSY:
            enum ofn = "clrssbsy";
            break;
        case SETSSBSY:
            enum ofn = "setssbsy";
            mixin(ofn~"();");
            break;
        case RDSSPD:
            enum ofn = "rdsspd";
            break;
        case RDSSPQ:
            enum ofn = "rdsspq";
            break;
        case WRSSD:
            enum ofn = "wrssd";
            break;
        case WRSSQ:
            enum ofn = "wrssq";
            break;
        case WRUSSD:
            enum ofn = "wrussd";
            break;
        case WRUSSQ:
            enum ofn = "wrussq";
            break;
        case RSTORSSP:
            enum ofn = "rstorssp";
            break;
        case SAVEPREVSSP:
            enum ofn = "saveprevssp";
            mixin(ofn~"();");
            break;
        case ENDBR32:
            enum ofn = "endbr32";
            mixin(ofn~"();");
            break;
        case ENDBR64:
            enum ofn = "endbr64";
            mixin(ofn~"();");
            break;
        case RDFSBASE:
            enum ofn = "rdfsbase";
            break;
        case RDGSBASE:
            enum ofn = "rdgsbase";
            break;
        case WRFSBASE:
            enum ofn = "wrfsbase";
            break;
        case WRGSBASE:
            enum ofn = "wrgsbase";
            break;
        case RDPID:
            enum ofn = "rdpid";
            break;
        case WRPKRU:
            enum ofn = "wrpkru";
            mixin(ofn~"();");
            break;
        case RDPKRU:
            enum ofn = "rdpkru";
            mixin(ofn~"();");
            break;
        case TESTUI:
            enum ofn = "testui";
            mixin(ofn~"();");
            break;
        case STUI:
            enum ofn = "stui";
            mixin(ofn~"();");
            break;
        case CLUI:
            enum ofn = "clui";
            mixin(ofn~"();");
            break;
        case UIRET:
            enum ofn = "uiret";
            mixin(ofn~"();");
            break;
        case SENDUIPI:
            enum ofn = "senduipi";
            break;
        case UMWAIT:
            enum ofn = "umwait";
            break;
        case UMONITOR:
            enum ofn = "umonitor";
            break;
        case TPAUSE:
            enum ofn = "tpause";
            break;
        case CLDEMOTE:
            enum ofn = "cldemote";
            break;
        case XRESLDTRK:
            enum ofn = "xresldtrk";
            mixin(ofn~"();");
            break;
        case XSUSLDTRK:
            enum ofn = "xsusldtrk";
            mixin(ofn~"();");
            break;
        case SERIALIZE:
            enum ofn = "serialize";
            mixin(ofn~"();");
            break;
        case PCONFIG:
            enum ofn = "pconfig";
            mixin(ofn~"();");
            break;
        case RDPMC:
            enum ofn = "rdpmc";
            mixin(ofn~"();");
            break;
        case WBINVD:
            enum ofn = "wbinvd";
            mixin(ofn~"();");
            break;
        case WBNOINVD:
            enum ofn = "wbnoinvd";
            mixin(ofn~"();");
            break;
        case INVD:
            enum ofn = "invd";
            mixin(ofn~"();");
            break;
        case LGDT:
            enum ofn = "lgdt";
            break;
        case SGDT:
            enum ofn = "sgdt";
            break;
        case LLDT:
            enum ofn = "lldt";
            break;
        case SLDT:
            enum ofn = "sldt";
            break;
        case LIDT:
            enum ofn = "lidt";
            break;
        case SIDT:
            enum ofn = "sidt";
            break;
        case LMSW:
            enum ofn = "lmsw";
            break;
        case SMSW:
            enum ofn = "smsw";
            break;
        case INVLPG:
            enum ofn = "invlpg";
            break;
        case SAHF:
            enum ofn = "sahf";
            mixin(ofn~"();");
            break;
        case LAHF:
            enum ofn = "lahf";
            mixin(ofn~"();");
            break;
        case SARX:
            enum ofn = "sarx";
            break;
        case SHLX:
            enum ofn = "shlx";
            break;
        case SHRX:
            enum ofn = "shrx";
            break;
        case MOVQ:
            enum ofn = "movq";
            break;
        case MOVD:
            enum ofn = "movd";
            break;
        case ADDPD:
            enum ofn = "addpd";
            break;
        case ADDPS:
            enum ofn = "addps";
            break;
        case ADDSS:
            enum ofn = "addss";
            break;
        case ADDSD:
            enum ofn = "addsd";
            break;
        case LFENCE:
            enum ofn = "lfence";
            mixin(ofn~"();");
            break;
        case SFENCE:
            enum ofn = "sfence";
            mixin(ofn~"();");
            break;
        case MFENCE:
            enum ofn = "mfence";
            mixin(ofn~"();");
            break;
        case ADDSUBPS:
            enum ofn = "addsubps";
            break;
        case ADDSUBPD:
            enum ofn = "addsubpd";
            break;
        case VADDPD:
            enum ofn = "vaddpd";
            break;
        case VADDPS:
            enum ofn = "vaddps";
            break;
        case VADDSD:
            enum ofn = "vaddsd";
            break;
        case VADDSS:
            enum ofn = "vaddss";
            break;
        case VADDSUBPD:
            enum ofn = "vaddsubpd";
            break;
        case VADDSUBPS:
            enum ofn = "vaddsubps";
            break;
        case VMOVQ:
            enum ofn = "vmovq";
            break;
        case VMOVD:
            enum ofn = "vmovd";
            break;
        case AESDEC:
            enum ofn = "aesdec";
            break;
        case VAESDEC:
            enum ofn = "vaesdec";
            break;
        case AESDEC128KL:
            enum ofn = "aesdec128kl";
            break;
        case AESDEC256KL:
            enum ofn = "aesdec256kl";
            break;
        case AESDECLAST:
            enum ofn = "aesdeclast";
            break;
        case VAESDECLAST:
            enum ofn = "vaesdeclast";
            break;
        case AESDECWIDE128KL:
            enum ofn = "aesdecwide128kl";
            break;
        case AESDECWIDE256KL:
            enum ofn = "aesdecwide256kl";
            break;
        case AESENC:
            enum ofn = "aesenc";
            break;
        case VAESENC:
            enum ofn = "vaesenc";
            break;
        case AESENC128KL:
            enum ofn = "aesenc128kl";
            break;
        case AESENC256KL:
            enum ofn = "aesenc256kl";
            break;
        case AESENCLAST:
            enum ofn = "aesenclast";
            break;
        case VAESENCLAST:
            enum ofn = "vaesenclast";
            break;
        case AESENCWIDE128KL:
            enum ofn = "aesencwide128kl";
            break;
        case AESENCWIDE256KL:
            enum ofn = "aesencwide256kl";
            break;
        case AESIMC:
            enum ofn = "aesimc";
            break;
        case VAESIMC:
            enum ofn = "vaesimc";
            break;
        case AESKEYGENASSIST:
            enum ofn = "aeskeygenassist";
            break;
        case VAESKEYGENASSIST:
            enum ofn = "vaeskeygenassist";
            break;
        case SHA1MSG1:
            enum ofn = "sha1msg1";
            break;
        case SHA1MSG2:
            enum ofn = "sha1msg2";
            break;
        case SHA1NEXTE:
            enum ofn = "sha1nexte";
            break;
        case SHA256MSG1:
            enum ofn = "sha256msg1";
            break; 
        case SHA1RNDS4:
            enum ofn = "sha1rnds4";
            break;
        case SHA256RNDS2:
            enum ofn = "sha256rnds2";
            break;
        // TODO: Branch not taken and taken?
        case CRC32:
            enum ofn = "crc32";
            break;
        case ENDQCMD:
            enum ofn = "endqcmd";
            break;
        case CMPXCHG:
            enum ofn = "cmpxchg";
            break;
        case AAA:
            enum ofn = "aaa";
            mixin(ofn~"();");
            break;
        case AAD:
            enum ofn = "aad";
            break;
        case AAM:
            enum ofn = "aam";
            break;
        case AAS:
            enum ofn = "aas";
            mixin(ofn~"();");
            break;
        case ADD:
            enum ofn = "add";
            break;
        case AND:
            enum ofn = "and";
            break;
        case ARPL:
            enum ofn = "arpl";
            break;
        case BSF:
            enum ofn = "bsf";
            break;
        case BSR:
            enum ofn = "bsr";
            break;
        case BSWAP:
            enum ofn = "bswap";
            break;
        case BT:
            enum ofn = "bt";
            break;
        case BTC:
            enum ofn = "btc";
            break;
        case BTR:
            enum ofn = "btr";
            break;
        case BTS:
            enum ofn = "bts";
            break;
        case CMP:
            enum ofn = "cmp";
            break;
        case CWD:
            enum ofn = "cwd";
            mixin(ofn~"();");
            break;
        case CDQ:
            enum ofn = "cdq";
            mixin(ofn~"();");
            break;
        case CQO:
            enum ofn = "cqo";
            mixin(ofn~"();");
            break;
        case CBW:
            enum ofn = "cbw";
            mixin(ofn~"();");
            break;
        case CWDE:
            enum ofn = "cwde";
            mixin(ofn~"();");
            break;
        case CDQE:
            enum ofn = "cdqe";
            mixin(ofn~"();");
            break;
        case CPUID:
            enum ofn = "cpuid";
            break;
        case CLC:
            enum ofn = "clc";
            mixin(ofn~"();");
            break;
        case CLD:
            enum ofn = "cld";
            mixin(ofn~"();");
            break;
        case CLI:
            enum ofn = "cli";
            mixin(ofn~"();");
            break;
        case CLTS:
            enum ofn = "clts";
            mixin(ofn~"();");
            break;
        case CMC:
            enum ofn = "cmc";
            mixin(ofn~"();");
            break;
        case DEC:
            enum ofn = "dec";
            break;
        case INT:
            assert(instr.markFormat("l"));

            if (instr.operands[0].b == 3)
                int3();
            else if (instr.operands[0].b == 1)
                int1();
            else
                _int(instr.operands[0].b);

            break;
        case INTO:
            enum ofn = "into";
            mixin(ofn~"();");
            break;
        case UD:
            assert(instr.markFormat("l") || instr.markFormat("lrn"));
            assert(instr.operands[0].d <= 3 && (instr.operands[0].d == 2 || instr.operands.length == 3));
            
            if (instr.operands.length == 1)
                ud2();
            else if (instr.operands[0].d == 0)
            {
                assert(instr.operands[1].size == 4 && instr.operands[2].size == 4);

                if (instr.operands[2].kind == Kind.REGISTER)
                    ud0(instr.operands[1].as!(Reg!32), instr.operands[2].as!(Reg!32));
                else
                    ud0(instr.operands[1].as!(Reg!32), instr.operands[2].as!(Address!32));
            }
            else if (instr.operands[0].d == 1)
            {
                assert(instr.operands[1].size == 4 && instr.operands[2].size == 4);

                if (instr.operands[2].kind == Kind.REGISTER)
                    ud1(instr.operands[1].as!(Reg!32), instr.operands[2].as!(Reg!32));
                else
                    ud1(instr.operands[1].as!(Reg!32), instr.operands[2].as!(Address!32));
            }

            break;
        case IRET:
            enum ofn = "iret";
            mixin(ofn~"();");
            break;
        case INC:
            enum ofn = "inc";
            break;
        case HLT:
            enum ofn = "hlt";
            break;
        case PAUSE:
            enum ofn = "pause";
            break;
        case SWAPGS:
            enum ofn = "swapgs";
            break;
        case LOCK:
            enum ofn = "lock";
            mixin(ofn~"(0);");
            break;
        case WAIT:
            enum ofn = "wait";
            mixin(ofn~"();");
            break;
        case FWAIT:
            enum ofn = "fwait";
            mixin(ofn~"();");
            break;
        case SYSRETC:
            enum ofn = "sysretc";
            mixin(ofn~"();");
            break;
        case SYSRET:
            enum ofn = "sysret";
            mixin(ofn~"();");
            break;
        case SYSCALL:
            enum ofn = "syscall";
            mixin(ofn~"();");
            break;
        case RSM:
            enum ofn = "rsm";
            mixin(ofn~"();");
            break;
        case LEAVE:
            enum ofn = "leave";
            mixin(ofn~"();");
            break;
        case ENTER:
            enum ofn = "enter";
            break;
        case LEA:
            enum ofn = "lea";
            break;
        case LDS:
            enum ofn = "lds";
            break;
        case LSS:
            enum ofn = "lss";
            break;
        case LES:
            enum ofn = "les";
            break;
        case LFS:
            enum ofn = "lfs";
            break;
        case LGS:
            enum ofn = "lgs";
            break;
        case LSL:
            enum ofn = "lsl";
            break;
        case LTR:
            enum ofn = "ltr";
            break;
        case STR:
            enum ofn = "str";
            break;
        case NEG:
            enum ofn = "neg";
            break;
        case NOP:
            enum ofn = "nop";
            mixin(ofn~"();");
            break;
        case NOT:
            enum ofn = "not";
            break;
        case RET:
            if (instr.operands.length == 0)
                ret();
            else
                ret(instr.operands[0].w);

            break;
        case RETF:
            if (instr.operands.length == 0)
                retf();
            else
                retf(instr.operands[0].w);

            break;
        case STC:
            enum ofn = "stc";
            mixin(ofn~"();");
            break;
        case STD:
            enum ofn = "std";
            mixin(ofn~"();");
            break;
        case STI:
            enum ofn = "sti";
            mixin(ofn~"();");
            break;
        case SUB:
            enum ofn = "sub";
            break;
        case SBB:
            enum ofn = "sbb";
            break;
        case XOR:
            enum ofn = "xor";
            break;
        case OR:
            enum ofn = "or";
            break;
        case SAL:
            enum ofn = "sal";
            break;
        case SAR:
            enum ofn = "sar";
            break;
        case SHL:
            enum ofn = "shl";
            break;
        case SHR:
            enum ofn = "shr";
            break;
        case RCL:
            enum ofn = "rcl";
            break;
        case RCR:
            enum ofn = "rcr";
            break;
        case ROL:
            enum ofn = "rol";
            break;
        case ROR:
            enum ofn = "ror";
            break;
        case VERR:
            enum ofn = "verr";
            break;
        case VERW:
            enum ofn = "verw";
            break;
        case TEST:
            enum ofn = "test";
            break;
        case POP:
            enum ofn = "pop";
            break;
        case POPDS:
            enum ofn = "popds";
            mixin(ofn~"();");
            break;
        case POPES:
            enum ofn = "popes";
            mixin(ofn~"();");
            break;
        case POPSS:
            enum ofn = "popss";
            mixin(ofn~"();");
            break;
        case POPFS:
            enum ofn = "popfs";
            mixin(ofn~"();");
            break;
        case POPGS:
            enum ofn = "popgs";
            mixin(ofn~"();");
            break;
        case POPA:
            enum ofn = "popa";
            mixin(ofn~"();");
            break;
        case POPF:
            enum ofn = "popf";
            mixin(ofn~"();");
            break;
        case PUSH:
            enum ofn = "push";
            break;
        case PUSHCS:
            enum ofn = "pushcs";
            mixin(ofn~"();");
            break;
        case PUSHSS:
            enum ofn = "pushss";
            mixin(ofn~"();");
            break;
        case PUSHDS:
            enum ofn = "pushds";
            mixin(ofn~"();");
            break;
        case PUSHES:
            enum ofn = "pushes";
            mixin(ofn~"();");
            break;
        case PUSHFS:
            enum ofn = "pushfs";
            mixin(ofn~"();");
            break;
        case PUSHGS:
            enum ofn = "pushgs";
            mixin(ofn~"();");
            break;  
        case PUSHA:
            enum ofn = "pusha";
            mixin(ofn~"();");
            break;
        case PUSHF:
            enum ofn = "pushf";
            mixin(ofn~"();");
            break;
        case XADD:
            enum ofn = "xadd";
            break;
        case XCHG:
            enum ofn = "xchg";
            break;
        case XLAT:
            enum ofn = "xlat";
            mixin(ofn~"();");
            break;
        case XLATB:
            enum ofn = "xlatb";
            mixin(ofn~"();");
            break;
        case LAR:
            enum ofn = "lar";
            break;
        case DAA:
            enum ofn = "daa";
            mixin(ofn~"();");
            break;
        case DAS:
            enum ofn = "das";
            mixin(ofn~"();");
            break;
        case MUL:
            enum ofn = "mul";
            break;
        case IMUL:
            enum ofn = "imul";
            break;
        case DIV:
            enum ofn = "div";
            break;
        case IDIV:
            enum ofn = "idiv";
            break;
        case MOV:
            if (instr.markFormat("rr"))
            {
                //
            }
            break;
        case MOVSX:
            enum ofn = "movsx";
            break;
        case MOVSXD:
            enum ofn = "movsxd";
            break;
        case MOVZX:
            enum ofn = "movzx";
            break;
        case MOVS:
            enum ofn = "movs";
            break;
        case MOVSB:
            enum ofn = "movsb";
            mixin(ofn~"();");
            break;
        case MOVSW:
            enum ofn = "movsw";
            mixin(ofn~"();");
            break;
        case MOVSD:
            enum ofn = "movsd";
            mixin(ofn~"();");
            break;
        case MOVSQ:
            enum ofn = "movsq";
            mixin(ofn~"();");
            break;
        case CALL:
            enum ofn = "call";
            break;
        case LOOPCC:
            enum ofn = "loop";
            break;
        case JMP:
            enum ofn = "jmp";
            break;
        case JCC:
            enum ofn = "jcc";
            break;
        case REPCC:
            enum ofn = "repcc";
            break;
        case CMPS:
            enum ofn = "cmps";
            break;
        case CMPSB:
            enum ofn = "cmpsb";
            mixin(ofn~"();");
            break;
        case CMPSW:
            enum ofn = "cmpsw";
            mixin(ofn~"();");
            break;
        case CMPSD:
            enum ofn = "cmpsd";
            mixin(ofn~"();");
            break;
        case CMPSQ:
            enum ofn = "cmpsq";
            mixin(ofn~"();");
            break;
        case SCAS:
            enum ofn = "scas";
            break;
        case SCASB:
            enum ofn = "scasb";
            mixin(ofn~"();");
            break;
        case SCASW:
            enum ofn = "scasw";
            mixin(ofn~"();");
            break;
        case SCASD:
            enum ofn = "scasd";
            mixin(ofn~"();");
            break;
        case SCASQ:
            enum ofn = "scasq";
            mixin(ofn~"();");
            break;
        case LODS:
            enum ofn = "lods";
            break;
        case LODSB:
            enum ofn = "lodsb";
            mixin(ofn~"();");
            break;
        case LODSW:
            enum ofn = "lodsw";
            mixin(ofn~"();");
            break;
        case LODSD:
            enum ofn = "lodsd";  
            mixin(ofn~"();");
            break;
        case LODSQ:
            enum ofn = "lodsq";
            mixin(ofn~"();");
            break;
        case STOS:
            enum ofn = "stos";
            break;
        case STOSB:
            enum ofn = "stosb";
            mixin(ofn~"();");
            break;
        case STOSW:
            enum ofn = "stosw";
            mixin(ofn~"();");
            break;
        case STOSD:
            enum ofn = "stosd";
            mixin(ofn~"();");
            break;
        case STOSQ:
            enum ofn = "stosq";
            mixin(ofn~"();");
            break;
        case IN:
            enum ofn = "_in";
            break;
        case INS:
            enum ofn = "ins";
            break;
        case INSB:
            enum ofn = "insb";
            mixin(ofn~"();");
            break;
        case INSW:
            enum ofn = "insw";
            mixin(ofn~"();");
            break;
        case INSD:
            enum ofn = "insd";
            mixin(ofn~"();");
            break;
        case OUT:
            enum ofn = "_out";
            break; 
        case OUTS:
            enum ofn = "outs";
            break;
        case OUTSB:
            enum ofn = "outsb";
            mixin(ofn~"();");
            break;
        case OUTSW:
            enum ofn = "outsw";
            mixin(ofn~"();");
            break;
        case OUTSD:
            enum ofn = "outsd";
            mixin(ofn~"();");
            break;
        case SETCC:
            enum ofn = "setcc";
            break;
        default:
            assert(0, "Unsupported instruction opcode!");
    }
}