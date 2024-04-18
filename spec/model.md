# Model

## Casts and Conversions

Casts in Fern are largely implicit, and need not an operator, however, the `|>` is used for conversion and may also perform casting or conversion piping.

All casts and conversions will recursively try to cast members, but will not try to convert.

### Conversion Pipe

`variable |> type[.member]`

Conversion piping is used to pipe data to a type's member. It may also be used to normally convert data to a type if no member is specified.

> Piping to a member will result in the data first being cast or converted to the type in order to access the member.

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