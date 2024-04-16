## Casting and Conversion

## Implicit Casts

Fern is intended to be highly versatile and will attempt implicit casts and light conversions where possible with any type.

Notable exceptions to this rule are float, scalar, and arrays, which will never implicitly cast unless they are of the same kind as what is being cast to. Meaning that you may not implicitly cast a non-float to a float, a non-scalar to a scalar, and (an exception) any type to an array.

>Arrays may implicitly cast to a non-array type.

### Reinterpret

Reinterpreting is defined as a direct cast from one type to another, where no bits are lost or gained and field layout is retained across the cast.

### Reorder

Reordering is defined as a light conversion from one type to another, where no bits are lost or gained but field layout is not retained across the conversion.

### Promotion and Demotion

Promotion and demotion are defined as casts in which one or more of the types involved are integral, bits may be lost or gained and field layout is irrelevant.

### Dereference Cast

References which may implicitly cast by the 2 above casts may be viable for dereference casting, in which the data at a reference is dereferenced and then subsequently cast to a type.

## Conversion

Types which may not be implicitly cast may be converted instead, if they may not be converted a comptime error should be thrown.
This is a key part of Fern and also is a pivotal part of execution of members of one type as another.

Conversion will recursively implicitly cast, but not convert.

### Piping

Piping allows you do `foo |> B.bar()` and this may act as a cast into a function call, however it is a conversion pipe operation in which `foo` is considered to be converted to `B` and has `bar()` called on it.

This same principle applies without members, and may be used like `foo |> B` when `foo` cannot implicitly cast to `B`.

### Fulfillment

Fulfillment is defined as a conversion in which as many fields as possible are transfered from one type to another.

For example, suppose we have 2 types `A` and `B`, `A` shares 2 integer fields with `B` but also has an additional field that `B` does not have.
Fulfillment conversion would allow conversion from `A` to `B`, but a field will be lost in the conversion.

### Array Conversion

Array conversion is defined as conversion in which the length field of the array is the only thing modified, as it adjusts to the correct size based on the element.