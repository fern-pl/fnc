/// Comptime symbol information for types, functions, fields, etc.
module fern.symbols;

import fern.emission;

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
}

public class Function : Symbol
{
public:
final:
    // The first parameter is always the return.
    Variable[] parameters;
    // This will include the return and parameters as the first locals.
    Variable[] locals;
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

    Symbol type()
    {
        return parents[$-1];
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
    Variable[string] fields;
    Function[string] functions;
    Function[] unittests;
}