## Grammar

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
| `<o>` (`<+>`) | Horizontal binary operator. |
| `\|x\|` | Absolute value operator. |
| `\|\|x\|\|` | Magnitude operator. |
| `>` `<` `<=` `>=` | Comparison operators, special behavior is defined for array types, which return a mask of where the comparison returned true. |
| `+` `-` `*` `/` `%` `^^` `<<` `>>` `<<<` `&` `^` `&` `\|` `~` `in` | Binary operators. `in` is used for checking if an associative array contains an element, and `~` is used for array concatenation by default.
| `==` `!=` `&&` `\|\|` | Equality operators. |
| `[..]` | Slicing operator, defined to return a slice of elements from a range by default, using a given lower and or upper bounds or the entire range is returned. |
| `[x]` | Indexing operator, used for range interfaces by default. |
| `--` `++` `~` `-` | Unary postdecrement, postincrement, not, and neg operators. Postdecrement and postincrement may appear as preX versions in which they are after a variable. |
| `*` `&` | Pointer dereference and reference. |

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

Use of `void` or a user-defined type with no members should be treated as a comptime error, you may get around this through aliasing.

All variable declarations are initialized with zero, this may be prevented by setting the initial value to `void`.

### Alias

Aliases are defined with `alias` or `alias[]` (for an array of aliases) to arbitrarily refer to code, this may be an expression, statement, type, or literal. You may not write to an alias at runtime, as they are evaluated during compilation, but reassignment to an alias at comptime is legal.

Aliases may be instance data if assigned to a variable.

### Generics

Types and functions may declare generic arguments, these are added as an additional set of parameters inside of parenthesis, and aliases may be passed by not stating a type (ie: `(T)`.)

### Lambdas

Lambdas (`=>`) may be declared in function/property syntax or as inline lambdas such as `a => return a == 1` where the parameter types are inferred.

Use of a lambda for a property will result in the property only having a `get`.

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

Neither constructors nor destructors are mandatory, and all types have a default constructor to initialize with zero (will never be void when using the default constructor) as well as a default destructor to free it.

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