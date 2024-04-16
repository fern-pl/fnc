## Casting and Conversion

## Implicit Casts

Fern is intended to be highly versatile and will attempt implicit casts and light conversions where possible with any type.

Notable exceptions to this rule are float, scalar, and arrays, which will never implicitly cast unless they are of the same kind as what is being cast to. Meaning that you may not implicitly cast a non-float to a float, a non-scalar to a scalar, and (an exception) any type to an array.

>Arrays may implicitly cast to a non-array type.

### Reinterpret

Reinterpreting is defined as a direct cast from one type to another, where no bits are lost or gained and field layout is retained across the cast.

Classes will be implicitly dereferenced in order to achieve reinterpret casting.

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

### Reorder

Reordering is defined as a light conversion from one type to another, where no bits are lost or gained but field layout is not retained across the conversion.

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

### Promotion and Demotion

Promotion and demotion are defined as casts in which one or more of the types involved are integral, bits may be lost or gained and field layout is irrelevant.

```
// Implicitly demoting a long to an int.
int a = 8L;
// Implicitly promoting an int to a long.
long b = a;
```

## Conversion

Types which may not be implicitly cast may be converted instead, if they may not be converted a comptime error should be thrown.
This is a key part of Fern and also is a pivotal part of execution of members of one type as another.

Conversion will recursively implicitly cast, but not convert.

### Piping

Piping allows you do `foo |> B.bar()` and this may act as a cast into a function call, however it is a conversion pipe operation in which `foo` is considered to be converted to `B` and has `bar()` called on it.

This same principle applies without members, and may be used like `foo |> B` when `foo` cannot implicitly cast to `B`.

### Fulfillment

Fulfillment is defined as a conversion in which as many fields as possible are transfered from one type to another.

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

Array conversion is defined as conversion in which the length field of the array is the only thing modified, as it adjusts to the correct size based on the element.

```
long[] foo = [1L];
// long[] is converted to a byte[8], bounds checking determines if this is safe.
byte[8] bar = foo |> byte[8];
// byte[8] is converted to a long[], with the length automatically determined to be 1.
long[] foo = bar |> long[];