/// Comptime symbol information for types, functions, fields, etc.
module fnc.symbols;

import fnc.emission;
import tern.state;
import tern.algorithm.mutation : insert, alienate;

// All symbols may have their members accessed at comptime using `->` followed by the member name, alignment is internally align and marker is not visible.

public enum SymAttr : ulong
{
    // TODO: Make sure Fern can automatically infer long from shifting
    //       D doesn't do this so 1 << 32 throws an error about the fact that 1 is assumed to be int.

    // Top-Level Kind
    TYPE = 1L << 0,
    STRUCT = 1L << 1,
    CLASS = 1L << 2,
    TAGGED = 1L << 3,
    TUPLE = 1L << 4,
    MODULE = 1L << 5,

    FUNCTION = 1L << 5,
    DELEGATE = 1L << 6,
    LAMBDA = 1L << 7,
    CTOR = 1L << 8,
    DTOR = 1L << 9,
    UNITTEST = 1L << 10,

    FIELD = 1L << 11,
    LOCAL = 1L << 12,
    PARAMETER = 1L << 13,

    EXPRESSION = 1L << 14,
    LITERAL = 1L << 15,

    // Attributes
    PUBLIC = 1L << 16,
    PRIVATE = 1L << 17,
    INTERNAL = 1L << 18,

    SAFE = 1L << 19,
    SYSTEM = 1L << 20,
    TRUSTED = 1L << 21,

    STATIC = 1L << 22,
    // NOT thread-local storage.
    GLOBAL = 1L << 23,
    // Non-temporal.
    TRANSIENT = 1L << 24,
    ATOMIC = 1L << 25,
    BITFIELD = 1L << 26,
    PURE = 1L << 36,
    CONST = 1L << 37,
    REF = 1L << 38,

    KIND_HEAP = 1L << 27,
    KIND_STACK = 1L << 28,
    KIND_SCALAR = 1L << 29,
    KIND_FLOAT = 1L << 30,
    KIND_XMM = 1L << 31,
    KIND_YMM = 1L << 32,
    KIND_ZMM = 1L << 33,
    KIND_READONLY = 1L << 34,
    KIND_DEFAULT = 1L << 35,

    ARRAY = 1L << 39,
    DYNARRAY = 1L << 40,
    // Static array.
    FIXARRAY = 1L << 41,
    // Associative array.
    ASOARRAY = 1L << 42,

    STRING = 1L << 43,
    WSTRING = 1L << 44,
    DSTRING = 1L << 45,
    BYTE = 1L << 46,
    WORD = 1L << 47,
    DWORD = 1L << 48,
    QWORD = 1L << 49,
    FLOAT = 1L << 50,
    DOUBLE = 1L << 51,
    SIGNED = 1L << 52,

    GLOB = 1L << 53,
    ALIAS = 1L << 54,

    FORMAT_MASK = DYNARRAY | ASOARRAY | SIGNED | FLOAT | DOUBLE | BITFIELD,
    INTEGRAL = BYTE | WORD | DWORD | QWORD,
    FLOATING = FLOAT | DOUBLE,
}

public class Symbol
{
public:
final:
    Glob glob;
    SymAttr symattr;
    string name;
    Symbol[] parents;
    Symbol[] children;
    Symbol[] attributes;

    string identifier()
    {
        string ret;
        foreach (parent; parents)
            ret ~= parent.name~'.';
        return ret~name;
    }

    bool isType() => (symattr & SymAttr.TYPE) != 0;
    bool isClass() => (symattr & SymAttr.CLASS) != 0;
    bool isStruct() => (symattr & SymAttr.STRUCT) != 0;
    bool isTagged() => (symattr & SymAttr.TAGGED) != 0;
    bool isTuple() => (symattr & SymAttr.TUPLE) != 0;

    bool isModule() => (symattr & SymAttr.MODULE) != 0;
    bool isGlob() => (symattr & SymAttr.GLOB) != 0;
    bool isAlias() => (symattr & SymAttr.ALIAS) != 0;
    bool isAliasSeq() => isAlias && isArray;
    bool isAggregate() => isModule || isStruct || isClass || isTagged || isTuple;

    bool isFunction() => (symattr & SymAttr.FUNCTION) != 0;
    bool isDelegate() => (symattr & SymAttr.DELEGATE) != 0;
    bool isLambda() => (symattr & SymAttr.LAMBDA) != 0;
    bool isCtor() => (symattr & SymAttr.CTOR) != 0;
    bool isDtor() => (symattr & SymAttr.DTOR) != 0;
    bool isSCtor() => isCtor && isStatic;
    bool isSDtor() => isDtor && isStatic;
    bool isUnittest() => (symattr & SymAttr.UNITTEST) != 0;

    bool isField() => (symattr & SymAttr.FIELD) != 0;
    bool isLocal() => (symattr & SymAttr.LOCAL) != 0;
    bool isParameter() => (symattr & SymAttr.PARAMETER) != 0;
    bool isVariable() => isField || isLocal || isParameter;

    bool isExpression() => (symattr & SymAttr.EXPRESSION) != 0;
    bool isLiteral() => (symattr & SymAttr.LITERAL) != 0;

    bool isArray() => (symattr & SymAttr.ARRAY) != 0;
    bool isDynamicArray() => (symattr & SymAttr.DYNARRAY) != 0;
    bool isStaticArray() => (symattr & SymAttr.FIXARRAY) != 0;
    bool isAssociativeArray() => (symattr & SymAttr.ASOARRAY) != 0;
    bool isString() => (symattr & SymAttr.STRING) != 0;
    bool isWideString() => (symattr & SymAttr.WSTRING) != 0 || (symattr & SymAttr.DSTRING) != 0;
    bool isSigned() => (symattr & SymAttr.SIGNED) != 0;
    bool isIntegral() => (symattr & SymAttr.INTEGRAL) != 0;
    bool isFloating() => (symattr & SymAttr.FLOATING) != 0;
    bool isNumeric() => isIntegral || isFloating;
    bool isByRef() => isClass || isKHeap || isRef;
    bool isVector() => isKXMM || isKYMM || isKZMM;

    bool isPublic() => (symattr & SymAttr.PUBLIC) != 0;
    bool isPrivate() => (symattr & SymAttr.PRIVATE) != 0;
    bool isInternal() => (symattr & SymAttr.INTERNAL) != 0;

    bool isSafe() => (symattr & SymAttr.SAFE) != 0;
    bool isSystem() => (symattr & SymAttr.SYSTEM) != 0;
    bool isTrusted() => (symattr & SymAttr.TRUSTED) != 0;

    bool isStatic() => (symattr & SymAttr.STATIC) != 0;
    bool isGlobal() => (symattr & SymAttr.GLOBAL) != 0;
    bool isTransient() => (symattr & SymAttr.TRANSIENT) != 0;
    bool isAtomic() => (symattr & SymAttr.ATOMIC) != 0;
    bool isBitfield() => (symattr & SymAttr.BITFIELD) != 0;
    bool isPure() => (symattr & SymAttr.PURE) != 0;
    bool isConst() => (symattr & SymAttr.CONST) != 0;
    bool isRef() => (symattr & SymAttr.REF) != 0;

    bool isKHeap() => (symattr & SymAttr.KIND_HEAP) != 0;
    bool isKStack() => (symattr & SymAttr.KIND_STACK) != 0;
    bool isKScalar() => (symattr & SymAttr.KIND_SCALAR) != 0;
    bool isKFloat() => (symattr & SymAttr.KIND_FLOAT) != 0;
    bool isKXMM() => (symattr & SymAttr.KIND_XMM) != 0;
    bool isKYMM() => (symattr & SymAttr.KIND_YMM) != 0;
    bool isKZMM() => (symattr & SymAttr.KIND_ZMM) != 0;
    bool isKReadOnly() => (symattr & SymAttr.KIND_READONLY) != 0;
    bool isKDefault() => (symattr & SymAttr.KIND_DEFAULT) != 0;

    Symbol freeze()
    {
        if (isVariable)
        {
            Variable temp = cast(Variable)this;
            temp.data = temp.data.dup;
            return cast(Symbol)temp;
        }
        return this;
    }
}

public class Type : Symbol
{
public:
final:
    Type[] inherits;
    Variable[] fields;
    Function[] functions;
    ubyte[] data;
    size_t size;
    // Internally referred to as align.
    size_t alignment;
    // For pointer and arrays, how deeply nested they are.
    // This is not front-facing to the runtime.
    uint depth;

    string type()
    {
        if ((symattr & SymAttr.CLASS) != 0)
            return "class";
        else if ((symattr & SymAttr.TAGGED) != 0)
            return "tagged";
        else //if ((symattr & SymAttr.STRUCT) != 0)
            return "struct";
    }

    bool canCast(Type val)
    {
        // arrays cannot reinterpret unless static and same size
        // pointers can only reinterpret if the types can reinterpret with a depth == 0
        // prims can reinterpret if the first field can reinterpret and there is only 1 field
        // fields must have the same format, size, and offset
        // ints can reinterpret if reinterpreting from a smaller int

        // TODO: There's no way this is sufficiently efficient, needs a rewrite?
        //       Does this even work???

        if (val == this)
            return true;
        else if (val.size != size)
            return false;

        if (fields.length == 1 && val.fields.length == 0)
            return fields[0].type.canCast(val);
        else if (val.fields.length == 1 && fields.length == 0)
            return val.fields[0].type.canCast(this);
        else if (val.fields.length == 0 && fields.length == 0)
        {
            return !val.symattr.hasFlag(SymAttr.DYNARRAY) &&
                !val.symattr.hasFlag(SymAttr.ASOARRAY) &&
                !symattr.hasFlag(SymAttr.DYNARRAY) &&
                !symattr.hasFlag(SymAttr.ASOARRAY) &&
                (val.symattr & SymAttr.FORMAT_MASK) == (symattr & SymAttr.FORMAT_MASK) &&
                val.size >= size;
        }

        foreach (i, field; val.fields)
        {
            if (field.offset != fields[i].offset ||
                (field.type.symattr & SymAttr.FORMAT_MASK) != (fields[i].type.symattr & SymAttr.FORMAT_MASK) ||
                !field.type.canCast(fields[i].type))
                return false;
        }

        return true;
    }
}

/* unittest 
{
    Type a = new Type();
    a.size = 1;
    a.symattr |= SymAttr.BYTE;

    Type b = new Type();
    b.size = 2;
    b.symattr |= SymAttr.WORD;

    assert(!b.canCast(a));
} */

public class Function : Symbol
{
public:
final:
    // Will begin with all alias parameters and then subsequently ret-args.
    Symbol[] parameters;
    // Will begin with ret-args and then subsequently all locals.
    Symbol[] locals;
    Instruction[] instructions;
    size_t alignment;

    string type()
    {
        // ctor and dtor are also functions, so we needn't check for them.
        if ((symattr & SymAttr.FUNCTION) != 0)
            return "function";
        else if ((symattr & SymAttr.UNITTEST) != 0)
            return "unittest";
        else
            return "delegate";
    }
}

// Locals and parameters use Variable.
// Expressions and literals should also be represented by a variable,
// but I haven't yet worked this out.

// Store alias to instance??
// NOTE: foo->fields should allow you to get the data of foo at runtime!!

public class Variable : Symbol
{
public:
final:
    ubyte[] data;
    size_t size;
    size_t alignment;
    size_t offset;
    // This is not front-facing!
    Marker marker;

    alias marker this;

    Type type()
    {
        return cast(Type)parents[$-1];
    }
}

public class Alias : Symbol
{
public:
final:
    union
    {
        Symbol single;
        Symbol[] many;
    }

    Alias flatten()
    {
        while (single.isAlias)
            single = (cast(Alias)single).flatten().single;
        
        foreach (i, sym; many)
        {
            if (!sym.isAlias)
                continue;

            if ((cast(Alias)sym).many != null)
            {
                // Replace sym with its contents in many.
                many.alienate(i, 1);
                many.insert(i, (cast(Alias)sym).flatten().many);
            }
            else
                sym = (cast(Alias)sym).flatten().single;
        }

        return this;
    }

    string type()
    {
        return "alias";
    }
}

public class Module : Symbol
{
public:
final:
    Symbol[] imports;
    Type[] types;
    Variable[] fields;
    Function[] functions;
}

public class Glob
{
public:
final:
    Symbol[string] symbols;
    Module[string] modules;
    Type[string] types;
    Variable[string] variables;
    Function[string] functions;
    Alias[string] aliases;
    Function[] unittests;
}