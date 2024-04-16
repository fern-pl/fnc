## Attributes

## `kind:`

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

## `const` 

Variables with the `const` attribute are immutable, including by any direct references, however, they are not necessarily stored in read-only memory.

## `pure`

Functions with the `pure` attribute declare that they will have the same output for every same input and do not read or write global state.

If a `pure` function resides within a user-defined type, the function is assumed to have the same output for every same input and is able to read and write the state of the type it resides in.

>This may be confusing, but just know that the type which the `pure` function nests in is not considered to be global state, and it acts as if it has a first parameter of that type.

## `partial`

User-defined types and modules may be declared partial, meaning that they may be declared again later and all declarations will be merged during compilation.

For instance, one may declare a `partial struct A` in one file, and declare `partial struct A` again in another file, and the final output will result in a single `struct A`

## `ref`

Parameters and return values with the `ref` attribute will pass data by reference implicitly.

All other use of `ref` is invalid and should be treated as a comptime error.

## `unsafe`

Functions with the `unsafe` attribute have all non-fatal language safety checks disabled.

## `auto`

Variables (and parameters) with the `auto` attribute infer their types based on input, despite being an attribute, you may not have both `auto` and a type declaration for data.

## `static`

Members with the `static` attribute have their data shared on a by-type basis, rather than by-instance.

Variables with the `static` attribute have their data shared across all instances of that same variable.

## `property`

Functions with the `property` attribute should abide by property syntax which declares that they act as a field but may execute code and must return a value that is not `void`.

## `mustuse`

Functions with the `mustuse` attribute return a value which must be assigned to a variable, returned, or otherwise used by the calling code. Failure to do such will cause a comptime error unless the return is converted to `void`.

## `inline`

Functions with the `inline` attribute should be guaranteed inlining by the compiler, failure to inline is a comptime error.