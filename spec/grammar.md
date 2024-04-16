## Grammar

## Comments

Comments in Fern use the syntax `\\` for single-line and `\*..*\` for multi-line.

## Builtin Types

| Type | Definition | Size (b) |
|------|------------|-------|
| `byte` | 8-bit unsigned integer. | 1
| `sbyte` | 8-bit signed integer. | 1
| `short` | 16-bit signed integer. | 2
| `ushort` | 16-bit unsigned integer. | 2
| `int` | 32-bit signed integer. | 4
| `uint` | 32-bit unsigned integer. | 4
| `long` | 64-bit signed integer. | 8
| `ulong` | 64-bit unsigned integer. | 8
| `float` | 32-bit floating point. | 4
| `double` | 64-bit floating point. | 8
| `void` | Represents an untype, may be pointed to but not explicitly declared as a variable. | 1
| `nint` | Represents the max size signed integer available. | variable
| `unint` | Represents the max size unsigned integer available. | variable
| `char` | 8-bit character integer. | 1
| `wchar` | 16-bit character integer. | 2
| `dchar` | 32-bit character integer. | 4
| `string` | A string formed out of `char` | variable (array)
| `wstring` | A string formed out of `wchar` | variable (array)
| `dstring` | A string formed out of `dchar` | variable (array)

| Integer Literal Suffix | Definition |
|------------------------|------------|
| `u` | Unsigned. |
| `U` | Signed. |
| `L` | 64-bit integer. |

Strings are defined as dynamic arrays if their value is not known at comptime, or static arrays if their value is known at comptime (ie: string literals through use of the below.)

String literals may be defined using `q{...}` or `"..."`, when using the latter syntax `d` or `w` may be prepended to dictate the size of the characters (`dchar` or `wchar`) or `r` to dictate that all escapes are ignored. 

## Arrays

Fern defines 2 kinds of arrays, static arrays and dynamic arrays.
Upon construction, all arrays may use the syntax `T[x]` to define their length.

Dynamic arrays may be created out of any type using the syntax `T[]` and they store their length and pointer to data as fields `length` and `ptr`.

Static arrays must have their length known at comptime and may be created out of any type using the syntax `T[L]` where `L` is the length of the array. Unlike dynamic arrays, static arrays do not store data by reference, and instead are value-types. However, they still retain comptime data for `length` and `ptr` gets a pointer to the data.

Static arrays may not be concatenated through use of `~`, however they still must have their length initialized at first.

## Operators

| Operator | Definition |
|----------|------------|
| `\|>` | Conversion pipe operator, used to pipe data to a type, member function, or field. |
| `<\|` | Downcast operator, downcasts data to its superior type. |
| `\|x\|` | Absolute value operator. |
| `\|\|x\|\|` | Magnitude operator. |
| `>` `<` `<=` `>=` | Comparison operators, special behavior is defined for array types, which return a mask of where the comparison returned true. |
| `+` `-` `*` `/` `%` `^^` `<<` `>>` `<<<` `^` `&` `\|` `~` `in` | Binary operators. `in` is used for checking if an associative array contains an element, and `~` is used for array concatenation by default. |
| `==` `!=` `&&` `\|\|` | Equality operators. |
| `[..]` | Slicing operator, defined to return a slice of elements from a range by default, using a given lower and or upper bounds or the entire range is returned. |
| `[x]` | Indexing operator, used for range interfaces by default. |
| `--` `++` `~` `-` | Unary postdecrement, postincrement, not, and neg operators. Postdecrement and postincrement may appear as preX versions in which they are after a variable. |
| `*` `&` | Unary pointer dereference and reference. |

The following operators are defined as op-assign, meaning that they perform the operation followed by an assignment.

| Operator |
|----------|
| `+=` `-=` `*=` `/=` `%=` `^^=` `~=` |
| `<<=` `>>=` `<<<=` `^=` `&=` `\|=` |

## User-defined Types

Fern declares 3 different kinds of user-defined types.
A type with no members has a minimum size of 1 byte, however it may also not be explicitly used to declare a variable.

| Keyword | Definition |
|---------|------------|
| `struct` | A value-type, typically will have a `kind:default` of `kind:stack`. |
| `class` | A reference type, typically will have a `kind:default` of `kind:heap`. |
| `union` | A union/sum-type, typically will have a `kind:default` of `kind:stack` |

An example of struct/class syntax is as follows:
```
struct/class Element
{
    int kind;
    short value;
}
```

An example of union syntax is as follows:
```
union IpAddr
{
	V4(byte, byte, byte, byte);
	V6(string);
}
```

All types may, but not must, contain member declarations, and the above are only examples.

## Declarations

Semicolons are not mandatory in Fern, however, they are also not removed explicitly from the language and can be used as you please.
Fern is **not** whitespace dependent, meaning that you may use any symbol whereever you want, so long as it is ordered correctly.

### Module

Modules are top level declarations which act like namespaces and may contain lower members inside of it.

A module identifier cannot be used more than once unless the module was declared using the `partial` attribute.

A declaration of a module appears as such `module name;` or `partial module name;` where `name` is the name of the module which is being declared.

### Import

Import declarations are used to import modules to be used, and may be used anywhere within code, with their effects only applicable in the scope which they were declared.

A whole module may be imported with `import name;` where `name` is the name of the module being imported, this may include submodules such as in `import foo.bar;` where the submodule `bar` in `foo` is imported, along with all of the submodules of `bar`.

A selection may be imported with `import name : foo` where `name` is the name of the module being imported from and `foo` is the symbol being imported from the module, the same submodule importing rules apply as with whole module imports.

A public import may be import even to other modules which import the module in which the public import was declared, this can be done like `public import name` where `name` is the name of the module being imported.

```
module foo;

public import bar;
```

In this example importing `foo` would result in also importing `bar`.

### Alias

Aliases are defined with `alias` or `alias[]` (for an array of aliases) to arbitrarily refer to any symbol or value. You may not write to an alias at runtime, as they are evaluated during compilation, but reassignment to an alias at comptime is legal.

Aliases may be instance data if assigned to a variable and are able to be used in replacement of any symbol anywhere in code.

```
alias foo = 1;

// This function will be evaluated at comptime
void bar() pure
{
    // foo now contains a direct alias to bar, this allows us to use foo like it is that symbol.
    foo = bar;

    // foo now contains a direct alias to int.
    foo = int;

    // Declared a variable with the type of int because it's the symbol stored in foo.
    foo a = 2;
}
```

### Generics

Types and functions may declare generic arguments, these are added as an additional set of parameters inside of parenthesis, and aliases may be passed by not stating a type (ie: `(T)`.)

Assignment of generic arguments uses the syntax `!(...)` or `!...` if you are passing a single argument.

```
// T acts as an alias to a symbol, in this case a type.
T foo(T)(T a)
{
    return a;
}

foo!int(1);
// or foo!(int)(1);
```

### Functions

Functions must follow the proceeding syntax:

```
T foo(...)
{
    ...
}
```

If a function has void as its return type it will have no return value.

### Fields and Variables

Fields and variables both must follow the proceeding syntax:

```
T foo;
// We avoid initialization here.
T foo = void;
```

Use of `void` or a user-defined type with no members as the type of a field or variable should be treated as a comptime error, you may get around this through aliasing.

All declarations are initialized with zero, this may be prevented by setting the initial value to `void`.

### Properties

Properties are special functions which act as fields, they must have the following declaration syntax, both a `get` and `set` are not necessary but you must have one of them.

```
property T foo()
{
    get
    {
        ...
    }
    set
    {
        ...
    }
}
```

This may be accessed in code as such `T foo_value = foo` or `foo = new_foo_value`.

### Lambdas

Lambdas (`=>`) may be declared in function/property syntax or as inline lambdas such as `a => return a == 1` where the parameter types are inferred.

Use of a lambda for a property will result in the property only having a `get`.

```
// foo will always return 1.
int foo() => 1;

// foo is a property that will always return 1.
property int foo() => 1;
```

### Constructors and Destructors

Constructors are functions which are used to construct an instance of a type, they are to be called on a type as if the type itself were a function and must be declared with the following syntax:

```
this(...)
{
    ...
}
```

Constructors may be called on existing data by use of `foo.ctor()` in which the overload is chosen by the arguments.

Destructors are functions which are used to free an instance of a type, they will be automatically run when freeing or may be directly called using `delete foo` and must be declared with the following syntax:

```
~this(...)
{
    ...
}
```

`static` constructors and destructors will be executed the first time that a type is constructed or destructed, and never again.

Neither constructors nor destructors are mandatory. All types will initially have a blank destructor as well as a default constructor which takes optional arguments for all fields.

## Attributes

### `kind:`

User-defined types with the `kind:x` attribute have their allocation strategy chosen by one of the following kinds. This is not guaranteed to be honored by the implementation, but suggests a certain storage type.

| Kind | Definition |
|------|------------|
| `heap` | Allocate on the heap. |
| `stack` | Allocate on the stack. |
| `scalar` | Store in scalar registers, the implementation may throw a warning and or use the stack if registers are insufficient for storage. |
| `float` | Store in float registers. |
| `xmmword` | Store in `XMM` or appropriate vectors. |
| `ymmword` | Store in `YMM` or appropriate vectors. |
| `zmmword` | Store in `ZMM` or appropriate vectors. |
| `default` | Implementation defined. |

Types with the `kind:heap` attribute are voidable by default and must be constructed to create an instance.

### `const` 

Variables with the `const` attribute are immutable, including by any direct references, however, they are not necessarily stored in read-only memory.

### `pure`

Functions with the `pure` attribute declare that they will have the same output for every same input and do not read or write global state.

If a `pure` function resides within a user-defined type, the function is assumed to have the same output for every same input and is able to read and write the state of the type it resides in.

>This may be confusing, but just know that the type which the `pure` function nests in is not considered to be global state, and it acts as if it has a first parameter of that type.

### `partial`

User-defined types and modules may be declared partial, meaning that they may be declared again later and all declarations will be merged during compilation.

For instance, one may declare a `partial struct A` in one file, and declare `partial struct A` again in another file, and the final output will result in a single `struct A`

### `ref`

Parameters and return values with the `ref` attribute will pass data by reference implicitly.

All other use of `ref` is invalid and should be treated as a comptime error.

### `unsafe`

Functions with the `unsafe` attribute have all non-fatal language safety checks disabled.

### `auto`

Variables (and parameters) with the `auto` attribute infer their types based on input, despite being an attribute, you may not have both `auto` and a type declaration for data.

### `static`

Members with the `static` attribute have their data shared on a by-type basis, rather than by-instance.

Variables with the `static` attribute have their data shared across all instances of that same variable.

### `property`

Functions with the `property` attribute should abide by property syntax which declares that they act as a field but may execute code and must return a value that is not `void`.

### `mustuse`

Functions with the `mustuse` attribute return a value which must be assigned to a variable, returned, or otherwise used by the calling code. Failure to do such will cause a comptime error unless the return is converted to `void`.

### `inline`

Functions with the `inline` attribute should be guaranteed inlining by the compiler, failure to inline is a comptime error.

### `align(n)`

Fields with the `align` attribute will be aligned to a `n` byte boundary. `n` must be supplied or it is a comptime error.