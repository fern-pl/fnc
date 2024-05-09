I# Metaprogramming

## Member Evaluations

> Locals are commonly referred to as variables, which in Fern are specifically variables that are local to a function (ie: not a field or parameter variable. )

| Member | Evaluates | Applicable |
|--------|-----------|------------|
| `attributes` | All attributes of the given symbol. | All |
| `children` | Children of the given symbol. | All |
| `parents` | Parents of the given symbol. | All |
| `identifier` | The full identifier of the given symbol, including parents. | All |
| `symattr` | The symbol attributes of the given symbol has, this is ***not*** the same as `attributes`. | All |
| `inherits` | Initial value of the given symbol's data. | Types |
| `sizeof` | The size of the given symbol's data. | Variables, Types, Functions |
| `alignof` | The alignment of the given symbol's data. | Variables, Types, Functions |
| `typeof` | The type of the given symbol's data. | Variables, Types |
| `init` | Initial value of the given symbol's data. | Variables, Types |
| `offsetof` | The offset of the given symbol's data. | Variables |
| `returnof` | Return type of the given symbol. | Functions |
| `parameters` | Parameters of the given symbol. | Functions |
| `locals` | Locals of the given symbol. | Functions |
| `children` | Imported symbols of the given symbol. | Module |

## Symbol Attributes & Formats

| Symbol Attribute | Definition |
|-------------|------------|
| `type` | Structure of data with or without instance presence - `struct`, `class`, `tagged` or `tuple`. |
| `struct` | A product-type aggregate passed by-value. |
| `class` | A product-type aggregate passed by-reference. |
| `tagged` | A sum-type aggregate passed by-value with a `tag`. |
| `tuple` | A sum-type aggregate passed by-value with arbitrary types. |
| `module` | Top or domain level scope with no instance presence. |
| `function` | Executable code scope taking parameters and returning a return type. |
| `delegate` | Dynamic executable code scope taking parameters and returning a return type from an address. |
| `lambda` | Special inline format of `delegate`. |
| `ctor` | Scope constructor, namely used for `type` and `module`. |
| `dtor` | Scope destructor, namely used for `type` and `module`. |
| `unittest` | Scope independent executable code taking no parameters and not returning anything. Executes synchronously and may not be called. |
| `field` | Data that exists and persists outside of an execution scope. |
| `local` | Data that exists and persists only inside of an execution scope. |
| `parameter` | Local declarations in a function signature which require arguments. |
| `expression` | Code which may not function without an existing statement to modify, like `1 + 1` |
| `literal` | Value known to the compiler before execution. |
| `glob` | The global scope of the entire program, containing all of its symbols. |

This is implementation defined, but generally symbols have or store the same information as the following formats internally:

```
Symbol [ 
    Glob glob;
    SymAttr attr;
    string name;
    Symbol[] parents;
    Symbol[] children;
    Symbol[] attributes;
]
```

```
Type : Symbol [
    Type[] inherits;
    Variable[] fields;
    Function[] functions;
    ubyte[] init;
    size_t sizeof;
    size_t alignof;
    // For pointer and arrays, how deeply nested they are.
    // This is not front-facing to the runtime.
    uint depth;
]
```

```
# This is also used for delegates, lambdas, ctors, dtors, and unittests.
Function : Symbol [
    // The first parameter is always the return.
    Variable[] parameters;
    // This will include the return and parameters as the first locals.
    Variable[string] locals;
    Instruction[] instructions;
    size_t alignof;
]
```

```
# This is also used for locals, parameters, expressions, and literals.
Variable : Symbol [
    ubyte[] init;
    size_t sizeof;
    size_t alignof;
    size_t offsetof;
    Marker marker;
]
```

```
Module : Symbol [
    Symbol[] imports;
    Type[] types;
    Variable[] fields;
    Function[] functions;
]
```

```
# This is used to store global information about the program.
Glob : Symbol [
    Symbol[string] symbols;
    Module[string] modules;
    Type[string] types;
    Field[string] fields;
    Function[string] functions;
    Function[] unittests;
]
```