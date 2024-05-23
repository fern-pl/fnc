/// Comptime symbol information for types, functions, fields, etc.
module fnc.symbols;

import fnc.emission;
import tern.state;
import tern.algorithm.mutation : insert, alienate, filter;
import tern.algorithm.searching : contains, indexOf;
import tern.typecons.security : Atomic;
import core.thread.osthread;
import core.time;

// All symbols may have their children accessed at comptime using `->` followed by the child name, alignment is internally align and marker is not visible.

public:
/// The global glob from which all symbols should originate.
static Glob glob;
static Symbol _class;
static Symbol _struct;
static Symbol _tagged;
static Symbol _alias;
static Symbol _function;
static Symbol _delegate;
static Symbol _unittest;
static Symbol _aliasseq;

shared static this()
{
    glob = new Glob();
    _struct = new Expression("struct");
    _class = new Expression("class");
    _tagged = new Expression("tagged");
    _alias = new Expression("alias");
    _function = new Expression("function");
    _delegate = new Expression("delegate");
    _unittest = new Expression("unittest");
    _aliasseq = new Expression("alias[]");
}

public enum SymAttr : ulong
{
    // TODO: Make sure Fern can automatically infer long from shifting,
    //       D doesn't do this so 1 << 32 throws an error about the fact that 1 is assumed to be int.

    // Top-Level Kind
    TYPE = 1L << 0,
    STRUCT = 1L << 1,
    CLASS = 1L << 2,
    TAGGED = 1L << 3,
    TUPLE = 1L << 4,

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
    PUBLIC_IMPORT = 1L << 55,
    MODULE = 1L << 56,
    //OPTIONAL = 1L << 57,

    FORMAT_MASK = DYNARRAY | ASOARRAY | SIGNED | FLOAT | DOUBLE | BITFIELD
}

public class Symbol
{
public:
final:
    // Declaring all of this causes redundancy and increased allocation size, but I don't think it would benefit
    // performance or anything if we split this up to only giving the members to symbols that need it.
    SymAttr symattr;
    dstring name;
    Symbol parent;
    Symbol[] children;
    Symbol[] attributes;
    /// This should contain the pending evaluations from the mixin thing.
    // You know what I mean Mitchell I sent you a paragraph on it.
    dstring[] evaluations;
    // This is not front-facing!
    Marker marker;
    size_t references;
    shared Atomic!bool lock;

    alias marker this;

    bool unlock() => lock = false;
    bool waitLock()
    {
        while (lock)
            Thread.sleep(dur!("msecs")(10));
        return lock = true;
    }

    dstring identifier()
    {
        dstring ret;
        Symbol sym = parent;
        while (sym !is null)
        {
            ret ~= sym.name~"."d;
            sym = sym.parent;
        } 
        return ret~name;
    }

    Symbol[] parents()
    {
        Symbol[] ret = [parent];
        while (ret[$-1].parent !is null)
            ret ~= ret[$-1].parent;
        return ret;
    }

    void finalize()
    {
        // TODO: Lock in more places for safety?
        // TODO: Resolve partial conflicts, especially as a child.
        waitLock();
        scope (exit) unlock();
        with (SymAttr) switch (symattr)
        {
            case TYPE:
                glob.types[identifier] = cast(Type)this;
                break;
            case FIELD:
            //case LOCAL:
            //case PARAMETER:
                glob.variables[identifier] = cast(Variable)this;
                break;
            case FUNCTION:
                glob.functions[identifier] = cast(Function)this;
                break;
            case MODULE:
                glob.modules[identifier] = cast(Module)this;
                break;
            case ALIAS:
                glob.aliases[identifier] = cast(Alias)this;
                break;
            default:
                break;
        }
        glob.symbols[identifier] = this;
        parent.children ~= this;
    }

    this()
    {
        // stupid ass default ctor
    }
    
    this(SymAttr symattr, dstring name, Symbol parent, Symbol[] children, Symbol[] attributes, Marker marker)
    {
        this.symattr = symattr;
        this.name = name;
        this.parent = parent;
        this.children = children;
        this.attributes = attributes;
        this.marker = marker;
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
    bool isIntegral() => (symattr & SymAttr.BYTE) != 0 || (symattr & SymAttr.WORD) != 0 || (symattr & SymAttr.DWORD) != 0 || (symattr & SymAttr.QWORD) != 0;
    bool isFloating() => (symattr & SymAttr.FLOAT) != 0 || (symattr & SymAttr.DOUBLE) != 0;
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

    bool isNested() => !parent.isModule;  
    bool isPrimitive() => !isAggregate && !isArray;
    bool isBuiltin() => !isAggregate;
    bool hasDepth() => isType && (cast(Type)this).depth > 0;
    bool hasBody() => isFunction && (cast(Function)this).instructions.length > 0;
    bool hasDataAllocations() => (isFunction && (cast(Function)this).locals.length > 0) || (isAggregate && (cast(Type)this).fields.length > 0);
    bool isEnum()
    {
        if (!isTagged)
            return false;
        else if (isConst)
            return true;

        Type self = cast(Type)this;
        foreach (field; self.fields)
        {
            if (!isConst)
                return false;
        }
        return true;
    }
    Function[] getOverloads(dstring name)
    {
        Function[] ret;
        if (isModule)
        {
            Module mod = cast(Module)this;
            foreach (func; mod.functions)
            {
                if (func.name == name)
                    ret ~= func;
            }
            return ret;
        }
        else if (isType)
        {
            Type type = cast(Type)this;
            foreach (func; type.functions)
            {
                if (func.name == name)
                    ret ~= func;
            }
            return ret;
        }
        throw new Throwable("Tried to iterate overloads "~cast(string)name~" for a non-function carrying symbol!");
    }

    Symbol getChild(dstring name) => glob.symbols[identifier~'.'~name];
    Symbol getParent(dstring name) => glob.symbols[name~'.'~this.name];
    Symbol getAttribute(dstring name) => attributes.filter!(x => x.name == name)[0];
    Variable getField(dstring name) => glob.variables[identifier~'.'~name];
    Function getFunction(dstring name) => glob.functions[identifier~'.'~name];
    Symbol getInherit(dstring name) => (cast(Type)this).inherits.filter!(x => x.name == name)[0];
    Alias getAlias(dstring name) => glob.aliases[identifier~'.'~name];
    // Templated functions/types need to be figured out somehow
    bool hasParent(dstring name) => (name~'.'~this.name in glob.symbols) != null;
    bool hasChild(dstring name) => (identifier~'.'~name in glob.symbols) != null;
    bool hasAttribute(dstring name) => attributes.contains!(x => x.name == name);
    bool hasField(dstring name) => hasChild(name) && getChild(name).isField;
    bool hasFunction(dstring name) => hasChild(name) && getChild(name).isFunction;
    bool hasInherit(dstring name) => isType && (cast(Type)this).inherits.contains!(x => x.name == name);
    bool hasAlias(dstring name) => identifier~'.'~name in glob.symbols && getChild(name).isAlias;

    bool hasParent(Symbol sym) => parents.contains(sym);
    bool hasChild(Symbol sym) => sym.parent == this;
    bool hasAttribute(Symbol sym) => attributes.contains(sym);
    bool hasField(Symbol sym) => sym.isField && sym.parent == this;
    bool hasFunction(Symbol sym) => sym.isFunction && sym.parent == this;
    bool hasInherit(Symbol sym) => isType && (cast(Type)this).inherits.contains(sym);
    bool hasAlias(Symbol sym) => sym.isAlias && sym.parent == this;

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

    // The _ should not show up when doing symbol work in Fern.
    // sym->module not sym->_module!
    Module _module()
    {
        assert(parent !is null, "Tried to take the module of an uncontained type!");
        return cast(Module)parents[0];
    }
}

/// For associative arrays the type symbol should be the key type (with SymAttr.ASOARRAY) with a first child symbol as the value type.
public class Type : Symbol
{
public:
final:
    Symbol[] inherits;
    Variable[] fields;
    Function[] functions;
    ubyte[] data;
    size_t size;
    // Internally referred to as align.
    size_t alignment;
    // For pointer and arrays, how deeply nested they are.
    // This is not front-facing to the runtime.
    uint depth;

    Symbol type()
    {
        if ((symattr & SymAttr.CLASS) != 0)
            return _class;
        else if ((symattr & SymAttr.TAGGED) != 0)
            return _tagged;
        else //if ((symattr & SymAttr.STRUCT) != 0)
            return _struct;
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
            return (cast(Type)fields[0].type).canCast(val);
        else if (val.fields.length == 1 && fields.length == 0)
            return (cast(Type)val.fields[0].type).canCast(this);
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
                !(cast(Type)field.type).canCast(cast(Type)fields[i].type))
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

    Symbol type()
    {
        // ctor and dtor are also functions, so we needn't check for them.
        if ((symattr & SymAttr.FUNCTION) != 0)
            return _function;
        else if ((symattr & SymAttr.UNITTEST) != 0)
            return _unittest;
        else
            return _delegate;
    }
}

/// Locals and parameters use Variable as well as fields.
/// Any default assignment of a field in a type should result in that being postponed and added as instructions to the default ctor.
// TODO: Decide how optional and named parameters work in the IR.
public class Variable : Symbol
{
public:
final:
    Symbol type;
    ubyte[] data;
    size_t size;
    // The GC doesn't actually allocate on powers of 2, this means alignment can be anything.
    size_t alignment;
    size_t offset;
}

public class Expression : Symbol
{
public:
final:
    union
    {
        dstring str;
        ubyte[] data;
    }

    alias str this;

    this(dstring str...)
    {
        this.str = str;
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

    Symbol type()
    {
        if (isAliasSeq)
            return _aliasseq;
        else
            return _alias;
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

    dstring[] queryIdentifiers()
    {
        dstring[] ret = [identifier];
        foreach (_import; imports)
            ret ~= _import.identifier;
        return ret;
    }
}

public class Glob : Symbol
{
public:
final:
    Symbol[dstring] symbols;
    Module[dstring] modules;
    Type[dstring] types;
    Variable[dstring] variables;
    Function[dstring] functions;
    Alias[dstring] aliases;
    Function[] unittests;
    Symbol[] context;
}