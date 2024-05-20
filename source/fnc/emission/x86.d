/// Code generation facilities for compiler backend.
module fnc.emission.x86;

public import gallinule.x86;
import std.typecons;
import fnc.emission.ir;
import fnc.symbols;
import std.traits;

public struct Stager
{
public:
final:
    ptrdiff_t[string] labels;
    Tuple!(ptrdiff_t, string, string, bool)[] branches;
    ubyte[] buffer;
    bool is64Bit;
}

package template emit(ubyte OP, ubyte SELECTOR = M, ubyte SIZE = 128, ubyte MAP = DEFAULT, ubyte PREFIX = 0)
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
                b = dst.register >= 8;

                if (dst.segment != ds)
                    buffer = dst.segment~buffer;
            }

            if ((is64Bit && (dst.size != 64 || src.size != 64)) || dst.size != 32 || src.size != 32)
                buffer = 0x67~buffer;

            if (dst.size == 16 || src.size == 16)
                buffer = 0x66~buffer;
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