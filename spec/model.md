# Model

Fern is symbol-oriented, meaning that no matter what you're doing, it prioritizes symbols and guaranteeing semantics over strong-typing and data storage.

This is intended to be without compromise, errors will be thrown if Fern cannot determine how to make your code function, but also the backend may implicitly do things without your knowledge if it means compilation.

## Versioning and Contracts

Versioning may be done by using `static if` to influence code generation alongside [compilation symbols](lexical.md#special-symbols). The `debug` keyword is provided to selectively compile a line or scope if targeting debug build.

## Memory Management

## Inheritance

`name [: [^]inherits..]`

Inheritance allows for code to be easier reused across your codebase and more consistent, clear distribution of members and data across inheriting symbols. 

> The [downcasting](grammar.md#operators) (`<|`) operator helps facilitate moving to inherited types.

> Where are interfaces? Fret not child, they exist no more, use abstract functions to achieve such lofty goals.

### Function Inheritance

Functions may inherit from another function, this simply causes the function to act as another function but with localized attributes.

Return value and parameters must match up with the inherited function.

```
int foo(long a) => a |> int;

// bar inherits all of the code from foo, meaning that it functions the exact same, but we can change the attributes.
int bar(long a) pure : foo;

// This is illegal, baz may not inherit from foo because it has a different return value.
void baz(long a) : foo;
```

### Type Inheritance

Types may inherit from other types, causing all members to be inherited. If the inheriting type has a member identical to an inherited type, the inheritance of that member will be ignored (retaining only one.) 

An inherited type must have at least one member to inherit, not have any non-abstract member collisions, and not be a builtin, array, pointer, or tagged, or a comptime error is thrown.

Abstract functions contained within an inherited type must be implemented by the inheriting type or a comptime error will be thrown, this is done by defining the member and giving it a body.

A type may inherit a single prime (`^`) type prepended before the inherited type name, this will result in all operators to be inherited, which is disabled by default.

```
struct A
{
    int a;

    abstract int foo();
}

struct B
{
    long b;
}

// C inherits all members of A and B, with A being the prime inherit and thus technically the operators of A are inherited, but we don't have any. 
struct C : ^A, B
{
    // We must declare a body for foo, as it is an abstract and requires an implementation;
    int foo() => 1337;
}
```

## Casts and Conversions

Casts in Fern are largely implicit, and need not an operator, however, the `|>` is used for conversion and may also perform casting or conversion piping.

All casts and conversions will recursively try to cast members, but will not try to convert.

> An comptime error will be thrown if it is impossible to cast from one type to another or to convert from one type to another.

### Conversion Pipe

`variable |> type[.member]`

Conversion piping is used to pipe data to a type's member. It may also be used to normally convert data to a type if no member is specified.

> Piping to a member will result in the data first being cast or converted to the type in order to access the member.

### Downcast

`variable <|`

`type <|`

Downcasting casts a variable to its superior type or retrieves the symbol of a type's superior type.

### Reinterpret Cast

Reinterpreting is a direct cast from one type to another, where no bits are lost or gained and field layout is retained across the cast.

> Static arrays may reinterpret to any type, so long as no bits are lost or gained.

```
struct A
{
    int a;
    byte b;
}

struct B
{
    int a;
    byte b;
}

// B is implicitly reinterpreted as A, since they have the same field layout
A foo = B(1, 2);
```

### Pointer Cast

Pointer casting is a direct cast from one pointer to another where element types between the two pointers are able to cast or the type being cast to is `void*`, `nint`, or `nuint`.

```
struct A
{
    int a;
}

A foo;
// A* is being cast to int* because A may cast to int.
int* bar = &foo;
// int* is being cast to void* because all pointers may cast to void*
void* baz = bar;
// void* is being cast to nuint because all pointers may cast to nuint.
nuint foo2 = baz;
```

### Stranded Cast

Stranded casting is a form of reinterpret cast in which a structure with a single field may cast to the type of that single field.

```
struct A
{
    int a;
}

// foo is now the value of `A.a` because it is a stranded field.
int foo = A();
```

### Promotion Conversion

Integers may promote to a larger integer in which they do not lose any bits and maintain the same format.

> As `float` and `double` do not maintain the same format, `float` *cannot* be promoted to `double`.

```
int foo = 1;
// foo is promoted to long.
long bar = foo;
```

### Reorder Conversion

Reordering is a conversion from one type to another, where no bits are lost or gained but field layout is not retained across the conversion.

```
struct A
{
    byte a;
    int b;
}

struct B
{
    int a;
    byte b;
}

// B is implicitly reordered to A, since the field layout needs only reordered.
A foo = B(1, 2);
```

### Fulfillment Conversion

Fulfillment is a conversion in which as many fields as possible are transfered from one type to another.

It is a comptime error for none of the fields in either type to be fulfilled.

```
struct A
{
    int a;
    short b;
    long c;
}

struct B
{
    int a;
    byte b;
}

// The fields a and b from B are fulfilled in A as well as possible, meaning now the value of a and b in A are the same as they were in B, and c becomes zeroed.
A foo = B(1, 2) |> A;
```

### Array Conversion

This conversion only is necessary when converting **to** an array type, casting from happens implicitly.

Array conversion is a conversion in which the length field of the array is the only thing modified, as it adjusts to the correct size based on the element.

```
long[] foo = [1L];
// long[] is converted to a byte[8], bounds checking determines if this is safe.
byte[8] bar = foo |> byte[8];
// byte[8] is converted to a long[], with the length automatically determined to be 1.
long[] foo = bar |> long[];
```

### Promotion II and Integral Conversion

Integrals may freely convert to each other, where converting a floating point to an integer will result in rounding up from `.5` to the nearest whole number.

This also permits arbitrary pointer conversion to and from any pointer or integer type.

Promotion also may happen from `float` to `double` and other integrals which do not maintain the same format or have data loss.

```
float foo = 2.3;
// bar will be 2, as it is rounded down from `.5`.
int bar = foo |> int;

// This is very bad but legal.
void* foo2 = bar |> void*;
// foo2 is actually cast from void* to int*.
int* bar2 = foo2 |> int*;
```

### Demotion Conversion

Integrals may demote from one to another, where bits are lost and format is irrelevant.

```
long foo = 1;
/// 32 bits are lost, in this conversion.
int bar = foo |> int;
```

## UFCS

## CTFE

## ABI