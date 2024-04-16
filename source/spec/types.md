## Builtin Types

| Type | Definition |
|------|------------|
| `byte` | 8-bit unsigned integer. |
| `sbyte` | 8-bit signed integer. |
| `short` | 16-bit signed integer. |
| `ushort` | 16-bit unsigned integer. |
| `int` | 32-bit signed integer. |
| `uint` | 32-bit unsigned integer. |
| `long` | 64-bit signed integer. |
| `ulong` | 64-bit unsigned integer. |
| `float` | 32-bit floating point. |
| `double` | 64-bit floating point. |
| `void` | Represents an untype, may be pointed to but not explicitly declared as a variable. |
| `char` | 8-bit character integer. |
| `wchar` | 16-bit character integer. |
| `dchar` | 32-bit character integer. |
| `string` | A string formed out of `char` |
| `wstring` | A string formed out of `wchar` |
| `dstring` | A string formed out of `dchar` |

Strings may be defined using `q{...}` or `"..."`, when using the latter syntax `d` or `w` may be prepended to dictate the size of the characters (`dchar` or `wchar`) or `r` to dictate that all escapes are ignored. 

## Operators

| Operator | Definition |
|----------|------------|
| `\|>` | Conversion pipe operator, used to pipe data to a type, member function, or field. |
| `<o>` (`<+>`) | Horizontal binary operator. |
| `\|x\|` | Absolute value operator. |
| `\|\|x\|\|` | Magnitude operator. |
| `>` `<` `<=` `>=` | Comparison operators, special behavior is defined for array types, which return a mask of where the comparison returned true. |
| `+` `-` `*` `/` `%` `^^` `<<` `>>` `<<<` `&` `^` `&` `\|` `~` `in` | Binary operators. `in` is used for checking if an associative array contains an element, and `~` is used for concatenation by default.
| `==` `!=` `&&` `\|\|` | Equality operators. |
| `[..]` | Slicing operator, defined to return a slice of elements from a range by default, using a given lower and or upper bounds or the entire range is returned. |
| `[x]` | Indexing operator, used for range interfaces by default. |
| `--` `++` `~` `-` | Unary postdecrement, postincrement, not, and neg operators. Postdecrement and postincrement may appear as preX versions in which they are after a variable. |
| `*` `&` | Pointer dereference and reference. |

## Implicit Casts

Fern defines no such thing as an explicit cast, there exists only conversions and implicit casts. Any of the following definitions are grounds for implicit casting, otherwise, see conversion.

### Reinterpret

Reinterpreting is defined as a direct cast from one type to another, where no bits are lost or gained and field layout is retained across the cast.

## Conversion

### Pipe Conversion

Use of the `|>` operator may allow for piping