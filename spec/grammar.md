# Grammar

## Module

`module name`

Modules are top level declarations which act like namespaces and may contain lower members inside of it.

A module identifier cannot be used more than once unless the module was declared using the `partial` attribute.

A declaration of a module appears as such `module name;` or `partial module name;` where `name` is the name of the module which is being declared.

## Import

`import name`

Import declarations are used to import modules to be used, and may be used anywhere within code, with their effects only applicable in the scope which they were declared.

A whole module may be imported with `import name;` where `name` is the name of the module being imported, this may include submodules such as in `import foo.bar;` where the submodule `bar` in `foo` is imported, along with all of the submodules of `bar`.

A selection may be imported with `import name : foo` where `name` is the name of the module being imported from and `foo` is the symbol being imported from the module, the same submodule importing rules apply as with whole module imports.

A public import may be import even to other modules which import the module in which the public import was declared, this can be done like `public import name` where `name` is the name of the module being imported.

```
module foo;

public import bar;
```

In this example importing `foo` would result in also importing `bar`.

## Types

`type is type`

`variable is type`

Types and variables may be compared to a type using `is` to evaluate if they are of the same type.

Types have a minimum size of 1 byte, but it is a comptime error to use a type with no members to declare a variable. (see [Fields and Variables](grammar.md#fields-and-variables))

### Builtins

The following types are built into Fern, and may be used without any imports:

| Type | Definition | Size (b) |
|------|------------|-------|
| `bool` | Boolean, `false` if 0, `true` otherwise. | 1 |
| `byte` | 8-bit signed integer. | 1
| `ubyte` | 8-bit unsigned integer. | 1
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
| `nuint` | Represents the max size unsigned integer available. | variable
| `char` | 8-bit character integer. | 1
| `wchar` | 16-bit character integer. | 2
| `dchar` | 32-bit character integer. | 4
| `string` | A string formed out of `char` | variable (array)
| `wstring` | A string formed out of `wchar` | variable (array)
| `dstring` | A string formed out of `dchar` | variable (array)

Strings are defined as dynamic arrays if their value is not known at comptime, or static arrays if their value is known at comptime (ie: string literals.)

#### Operators

Operators are a builtin part of the language used to perform certain operations. All of these may be overloaded and functionality varies, but should by default apply by normal rationality.

| Operator | Definition |
|----------|------------|
| `\|>` | Conversion pipe operator, used to pipe data to a type, member function, or field. |
| `<\|` | Downcast operator, downcasts data to its superior type. |
| `>` `<` `<=` `>=` | Comparison operators, special behavior is defined for array types, which return a mask of where the comparison returned true. |
| `+` `-` `*` `/` `%` `^^` `<<` `>>` `<<<` `^` `&` `\|` `~` `in` | Binary operators. `in` is used for checking if an associative array contains an element, and `~` is used for array concatenation by default. |
| `==` `!=` `&&` `\|\|` | Equality operators. |
| `[..]` | Slicing operator, defined to return a slice of elements from a range by default, using a given lower and or upper bounds or the entire range is returned. |
| `[x]` | Indexing operator, used for range interfaces by default. |
| `--` `++` `~` `-` | Unary postdecrement, postincrement, not, and neg operators. Postdecrement and postincrement may appear as preX versions in which they are after a variable. |
| `*` `&` | Unary pointer dereference and reference. |
| `x ? y : z` | Ternary operator, if `x` evaluates to `true`, the output will be `y`, otherwise it will be `z` |

The following operators are defined as op-assign, meaning that they perform the operation followed by an assignment.

| Operator |
|----------|
| `+=` `-=` `*=` `/=` `%=` `^^=` `~=` |
| `<<=` `>>=` `<<<=` `^=` `&=` `\|=` |

### Arrays

`type[]`

`type[length]`

Fern defines 2 kinds of arrays, static arrays, dynamic arrays.
Upon construction, all arrays may use the syntax `T[x]` to define their length.

Dynamic arrays may be created out of any type using the syntax `T[]` and they store their length and pointer to data as fields `length` and `ptr`.

Static arrays must have their length known at comptime and may be created out of any type using the syntax `T[L]` where `L` is the length of the array. Unlike dynamic arrays, static arrays do not store data by reference, and instead are value-types. However, they still retain comptime data for `length` and `ptr` gets a pointer to the data.

Static arrays may not be concatenated through use of `~`, however they still must have their length initialized at first.

### Pointers

`type*`

Pointers are natively sized integers which point to memory, they may be created by using the reference operator `&` and dereferenced by using the dereference operator `*`.

Pointers may be represented as `void*`, `nint`, `nuint`, or appending `*` to the end of a type.

> Pointers are cumulative, meaning that you can point to pointers and so on.

### User-defined Types

`[aggregation] name`

Fern declares 3 different kinds of user-defined types.
A type with no members has a minimum size of 1 byte, however it may also not be explicitly used to declare a variable.

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
	V4(ubyte, ubyte, ubyte, ubyte);
	V6(string);
}
```

All types may, but not must, contain member declarations, and the above are only examples.

## Functions

`[type] name([(parameters)]) { .. }`

`name([arguments])`

Functions are executable code with parameters which may be invoked through the syntax `name([arguments])`.

```
T foo(...)
{
    ...
}
```

### Parameters and Arguments

##### Parameters

`[variable declaration]...`

##### Arguments

`[variable][value]...`

Parameters are syntactically an array of variable declarations, and are part of the signature of a declaration.

Arguments are the actual values passed to something, like a function, and are either variables or values. You may declare a variable inline as an argument, like `foo(int a)` which would create a new variable `a` from the point of that call onwards.

### Delegates and Function Pointers

##### Delegate declaration:

`[(parameters)] { ... }`

##### Function and delegate pointer types:

`type function([parameters])`

`type delegate([parameters])`

Delegates are scope-independent variable functions which may be passed around and called, they are identical to function pointers in practice, but store context data meaning they are aware of `this`.

You may explicitly create a delegate, but functions and function pointers will also become delegates implicitly.

### Lambdas

`[parameters] => ..`

Lambdas may be declared in function/property syntax or as inline lambdas such as `a => return a == 1` where the parameter types are inferred and a delegate is constructed based on the lambda.

Use of a lambda for a property will result in the property only having a `get`.

```
// foo will always return 1.
int foo() => 1;

// foo is a property that will always return 1.
property int foo() => 1;
```

### Properties

`property [type] name { [get { .. }] [set { .. }]`

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

### Constructors and Destructors

`this[(parameters)] { .. }`

`~this[(parameters)] { .. }`

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

### Unittest

`unittest [name] { .. }`

Unittests are used for executing test code under a unittest build. They function identically to functions besides being automatically run at once and having no return values.

Names are not mandatory for unittests, but highly recommended for clarity.

```
unittest foo
{
   ...
}
```

## Fields and Variables

`[type] name`

A field, return value, or parameter are variables, but variables are not a field, return value, or parameter. This distinction is important.

Use of `void` or a user-defined type with no members as the type of a field or variable should be treated as a comptime error, you may get around this through aliasing.

All declarations are initialized with zero, this may be prevented by setting the initial value to `void`.

#### Bitfields

`[type] name : [bits]`

Bitfields are identical to normal variables besides being constrained to a specified bit size. If a type with variables is constrained by a bitfield, all fields must be able to maintain the same ratio of bits as they initially had or it is a comptime error.

Despite the deceiving name, bitfields may apply to any variable.

```
struct A
{
    // foo is constrained to 3 bits but acts like a normal field would.
    T foo : 3;
}
```

## Attributes

`[attributes] [arregation] name..`

`[attributes] [type] name..`

Attributes are special metadata which may be applied to certain things. They do not necessarily indicate special functionality but may be assigned such.

| Attribute | Definition | Applicable |
|-----------|------------|------------|
| `public` | Public accessibility, may be accessed anywhere. | All |
| `private` | Private accessibility, may only be accessed by the same declaration it is a part of. | All |
| `internal` | Internal accessibility, may only be accessed by the same package as it was declared. | All |
| `partial` | May be distributed across several declarations of the given symbol, allows for splitting across multiple files. | Types, Modules |
| `abstract` | Does not have an implementation but enforces that, if inherited, it must have an implementation | Function |
| `pure` | Does not modify any state except its parent type (if it has any.) | Function |
| `unsafe` | Ignores all safety checks usually applied to functions. | Function |
| `@tapped` | Ignores all attributes that may be inferred or applied to the parent scope(s). | Function |
| `inline` | Guarantees that a function is inlined by the compiler or an error is thrown. | Function |
| `const` | Immutable, including by any direct references, does not indicate read-only memory. | Variables |
| `auto` | Infers type at comptime, similar to type aliasing but implicit. | Variables |
| `ref` | Carries a reference to data. | Parameters, Return Values |
| `mustuse` | Must be used or cast to `void` or an error is thrown. | Return Values |
| `static` | Data is stored globally rather than by-instance. | Variables |
| `align(n)` | Aligns data to the given boundary `n` which must be a power of 2 and supplied. | Fields |

Abstract functions must have their signature end in a semicolon without declaring a body.

### `kind:x`

`[aggregation] name kind:[x]`

User-defined types with the `kind:x` attribute have their allocation strategy chosen by one of the following kinds. This is not guaranteed to be honored by the implementation, but suggests a certain storage type.

| Kind | Definition |
|------|------------|
| `heap` | Allocate on the heap. |
| `stack` | Allocate on the stack. |
| `scalar` | Store in scalar registers. |
| `float` | Store in float registers. |
| `xmmword` | Store in `XMM` or appropriate vectors. |
| `ymmword` | Store in `YMM` or appropriate vectors. |
| `zmmword` | Store in `ZMM` or appropriate vectors. |
| `default` | Implementation defined. |

Types with the `kind:heap` attribute are `voidable` by default and must be constructed to create an instance.

### `voidable`

`type[?] name`

Any variable may be `voidable` by appending `?` to the end of the provided type. Declaring a variable as such will result in it being able to evaluate to `void`, this is indicates that no value has been assigned to it and is fundamentally different from being zeroed, as it exists as a separate state.

### User-defined Attributes

`[@][symbol] [aggregation] name..`

`[@][symbol] [type] name..`

User-defined attributes may be created by simply prepending `@` before a symbol.

## Symbols and Aliases

A symbol is any literal, statement, or otherwise declaration.

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

`name[(parameters)]`

Parameters must be typed as they are normally typed, however, aliases to arbitrary symbols must have the format `alias name` and type symbols may have the format `name` where neither `alias` nor a type is declared.

`!([arguments])`

`![argument]`

Types and functions may declare generic arguments, these are added as an additional set of parameters inside of parenthesis, and must always evaluate to aliases which makes them comptime exclusive and allow for specialized code-generation.

```
// T acts as an alias to a type.
T foo(T)(T a)
{
    return a;
}

foo!int(1);
// or foo!(int)(1);
```

### Mixins

TBD

## Statements

`statement [(arguments)]` (varies)

Statements are declarations which have special executive functionality, Fern defines the following statements:

| Statement | Definition |
|-----------|------------|
| `if` | Conditionally executes the next line or scope. |
| `else` | Alternate of `if` in which the next line or scope will be executed if an `if` was present prior and failed |
| `foreach` | Iterates the next line or scope over a range of values, this may be a data range or integral range by use of `L..U` where `L` is the lower bound and `U` is the upper bound |
| `foreach_reverse` | Identical to `foreach` but operates in reverse. |
| `while` | Iterates the next line or scope while a condition is true. |
| `switch` | Selects a `case` based on the value provided to the switch. Should evaluate to a jump-table after compilation. |
| `case` | Conditionally executes the next line or scope based on the value of a `switch` statement. This is declared as `case value:`. |
| `default` | A default case for `switch` statements which executes if no other cases execute. This is declared as `default:`. |
| `goto` | Jumps to a `label` within code, this is declared as `goto name` |
| `label` | Labels a part of code to be jumped to by a `goto` statement, this is declared as `name:`. |
| `with` | Used to declare a scope in which all function calls are first evaluated as members of a variable. |
| `break` | Exits the current scope. |
| `continue` | Continues to the next iteration in a loop. |

### Static

Fern defines static statements as statements which may be evalutated at comptime. Statements may be speculated and executed at comptime, but also may be explicitly declared if they are of the following:

| Statement |
|-----------|
| `static if` |
| `static foreach` |
| `static foreach_reverse` |
| `static while` |
| `static switch` |