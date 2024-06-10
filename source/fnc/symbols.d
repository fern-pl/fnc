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

/// The global glob from which all symbols should originate.
public static Glob glob;

public shared static this()
{
    glob = new Glob();
}

public enum SymAttr : ulong
{
    // TODO: Make sure Fern can automatically infer long from shifting,
    //       D doesn't do this so 1 << 32 throws an error about the fact that 1 is assumed to be int.

    // Variants
    TYPE = 1L << 0,
    MODULE = 1L << 1,
    VARIABLE = 1L << 2,
    FUNCTION = 1L << 3,
    EXPRESSION = 1L << 4,
    LITERAL = 1L << 5,
    GLOB = 1L << 6,
    ALIAS = 1L << 7,

    // Attributes
    PUBLIC = 1L << 8,
    PRIVATE = 1L << 9,
    INTERNAL = 1L << 10,
    STATIC = 1L << 11,

    // Variable and functions
    CONST = 1L << 12,
    // Is this variable's size too large to put in the executable as data?
    // Is this function's code size too large to inline?
    FAT = 1L << 13,
    // Is this variable or function safe to do anything we want with it in terms of size?
    TINY = 1L << 14,

    // Functions
    DELEGATE = 1L << 15,
    //UNITTEST = 1L << 16,
    CTOR = 1L << 17,
    DTOR = 1L << 18,
    PURE = 1L << 19,
    SAFE = 1L << 20,
    TRUSTED = 1L << 21,
    SYSTEM = 1L << 22,
    ENTRYPOINT = 1L << 23,

    // Variables
    // Is this variable's data not TLS?
    GLOBAL = 1L << 15,
    // Is this variable non-temporal and won't enter the cache?
    TRANSIENT = 1L << 16,
    ATOMIC = 1L << 17,
    BITFIELD = 1L << 18,
    // Is this variable going to have its GC allocation inlined?
    EMPLACE = 1L << 19,
    LOCAL = 1L << 20,
    PARAMETER = 1L << 21,

    // Variables, types, and literals
    ARRAY = 1L << 22,
    DYNARRAY = 1L << 23,
    FIXARRAY = 1L << 24,
    ASOARRAY = 1L << 26,

    STRING = 1L << 27,
    WSTRING = 1L << 28,
    DSTRING = 1L << 29,
    BYTE = 1L << 30,
    WORD = 1L << 31,
    DWORD = 1L << 32,
    QWORD = 1L << 33,
    FLOAT = 1L << 34,
    DOUBLE = 1L << 34,
    SIGNED = 1L << 35,

    VALUE = 1L << 36,
    /// Is this symbol a pointer or passed by ref?
    REF = 1L << 25,
    TAGGED = 1L << 37,
    TUPLE = 1L << 38,
    MMVEC = 1L << 49,

    FIELD = VARIABLE | LOCAL | PARAMETER,
    AGGREGATE = TYPE | MODULE,
    FLOATING = FLOAT | DOUBLE,
    INTEGRAL = BYTE | WORD | DWORD | QWORD,
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

    // TODO: Destroy symbols and create a new reference if they already exist to minimize footprint.
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
    bool isReferenceType() => isType && (symattr & SymAttr.REF) != 0;
    bool isValueType() => (symattr & SymAttr.VALUE) != 0;
    bool isTagged() => (symattr & SymAttr.TAGGED) != 0;
    bool isTuple() => (symattr & SymAttr.TUPLE) != 0;
    bool isMMVec() => (symattr & SymAttr.MMVEC) != 0;

    bool isModule() => (symattr & SymAttr.MODULE) != 0;
    bool isGlob() => (symattr & SymAttr.GLOB) != 0;
    bool isAlias() => (symattr & SymAttr.ALIAS) != 0;
    bool isAliasSeq() => isAlias && isArray;
    bool isAggregate() => (symattr & SymAttr.AGGREGATE) != 0;

    bool isFunction() => (symattr & SymAttr.FUNCTION) != 0;
    bool isDelegate() => (symattr & SymAttr.DELEGATE) != 0;
    bool isCtor() => (symattr & SymAttr.CTOR) != 0;
    bool isDtor() => (symattr & SymAttr.DTOR) != 0;

    bool isField() => (symattr & SymAttr.FIELD) == SymAttr.VARIABLE;
    bool isLocal() => (symattr & SymAttr.LOCAL) != 0;
    bool isParameter() => (symattr & SymAttr.PARAMETER) != 0;
    bool isVariable() => (symattr & SymAttr.VARIABLE) != 0;

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
    bool isByRef() => (symattr & SymAttr.REF) != 0;

    bool isNested() => !parent.isModule;  
    bool isPrimitive() => !isAggregate && !isArray;
    bool isBuiltin() => !isAggregate;
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
    uint array_depth;
    uint pointer_depth;

    Symbol type()
    {
        if (isReferenceType)
            return expression("ref");
        else //if ((symattr & SymAttr.STRUCT) != 0)
            return expression("value");
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
        return expression("function");
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

static Expression expression(dstring str)
{
    return str in glob.symbols ? cast(Expression)glob.symbols[str] : (cast(Expression)(glob.symbols[str] = new Expression(str)));
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
            return expression("alias[]");
        else
            return expression("alias");
    }
}

public class Module : Symbol
{
public:
final:
    // TODO: Public imports.
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