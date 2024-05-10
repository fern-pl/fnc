/// Comptime symbol information for types, functions, fields, etc.
module fnc.symbols;

import fnc.emission;
import tern.state;
import tern.algorithm.mutation : insert, alienate;

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

    FORMAT_MASK = DYNARRAY | ASOARRAY | SIGNED | FLOAT | DOUBLE | BITFIELD
}

public class Symbol
{
public:
final:
    Glob glob;
    SymAttr attr;
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

    bool isType() => (attr & SymAttr.TYPE) != 0;
    bool isClass() => (attr & SymAttr.CLASS) != 0;
    bool isStruct() => (attr & SymAttr.STRUCT) != 0;
    bool isTagged() => (attr & SymAttr.TAGGED) != 0;
    bool isTuple() => (attr & SymAttr.TUPLE) != 0;

    bool isModule() => (attr & SymAttr.MODULE) != 0;
    bool isGlob() => (attr & SymAttr.GLOB) != 0;
    bool isAlias() => (attr & SymAttr.ALIAS) != 0;

    bool isFunction() => (attr & SymAttr.FUNCTION) != 0;
    bool isDelegate() => (attr & SymAttr.DELEGATE) != 0;
    bool isLambda() => (attr & SymAttr.LAMBDA) != 0;
    bool isCtor() => (attr & SymAttr.CTOR) != 0;
    bool isDtor() => (attr & SymAttr.DTOR) != 0;
    bool isUnittest() => (attr & SymAttr.UNITTEST) != 0;

    bool isField() => (attr & SymAttr.FIELD) != 0;
    bool isLocal() => (attr & SymAttr.LOCAL) != 0;
    bool isParameter() => (attr & SymAttr.PARAMETER) != 0;
    bool isVariable() => isField || isLocal || isParameter;

    bool isExpression() => (attr & SymAttr.EXPRESSION) != 0;
    bool isLiteral() => (attr & SymAttr.LITERAL) != 0;

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
    size_t alignment;
    // For pointer and arrays, how deeply nested they are.
    // This is not front-facing to the runtime.
    uint depth;

    string type()
    {
        if ((attr & SymAttr.CLASS) != 0)
            return "class";
        else if ((attr & SymAttr.TAGGED) != 0)
            return "tagged";
        else //if ((attr & SymAttr.STRUCT) != 0)
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
            return !val.attr.hasFlag(SymAttr.DYNARRAY) &&
                !val.attr.hasFlag(SymAttr.ASOARRAY) &&
                !attr.hasFlag(SymAttr.DYNARRAY) &&
                !attr.hasFlag(SymAttr.ASOARRAY) &&
                (val.attr & SymAttr.FORMAT_MASK) == (attr & SymAttr.FORMAT_MASK) &&
                val.size >= size;
        }

        foreach (i, field; val.fields)
        {
            if (field.offset != fields[i].offset ||
                (field.type.attr & SymAttr.FORMAT_MASK) != (fields[i].type.attr & SymAttr.FORMAT_MASK) ||
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
    a.attr |= SymAttr.BYTE;

    Type b = new Type();
    b.size = 2;
    b.attr |= SymAttr.WORD;

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
        if ((attr & SymAttr.FUNCTION) != 0)
            return "function";
        else if ((attr & SymAttr.UNITTEST) != 0)
            return "unittest";
        else
            return "delegate";
    }
}

// Locals and parameters use Variable.
// Expressions and literals should also be represented by a variable,
// but I haven't yet worked this out.

public class Variable : Symbol
{
public:
final:
    ubyte[] data;
    size_t size;
    size_t alignment;
    size_t offset;
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