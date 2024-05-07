# Lexical

## Strings and Characters

String literals may be defined using `q{...}` or `"..."`, when using the latter syntax `d` or `w` may be prepended to dictate the size of the characters (`dchar` or `wchar`) or `r` to dictate that all escapes are ignored. 

Character literals may be defined using `'...'` in which a single character is defined.

### Escapes

Escape sequences are sequences of characters which result in a special character being used.

| Sequence | Definition |
|----------|------------|
| `\'` | ' |
| `\"` | " |
| `\\` | \ |
| `\0` | Null terminator. |
| `\a` | Alert. |
| `\b` | Backspace. |
| `\f` | Form backfeed. |
| `\n` | Newline. |
| `\r` | Carriage return. |
| `\t` | Horizontal tab. |
| `\v` | Vertical tab. |
| `\xhh..` | Hexadecimal character insert. |

## Literal Suffixes

Literal suffixes are suffixes which may be appended to a literal to change the way that the literal is formatted or interpreted.

| Integral -Fix | Definition |
|------------------------|------------|
| `u` | Unsigned, suffix. |
| `U` | Signed, suffix. |
| `L` | 64-bit integer, suffix. |
| `f` | 32-bit floating point, suffix. |
| `0x` | Hexadecimal, prefix. |
| `0X` | Hexadecimal, prefix. |

## Comments, Terminators, and Scopes

`// comment`

`/* multi-line comment */`

Comments in Fern use the syntax `\\` for single-line and `/*..*/` for multi-line.

`[type] name;`

`[type] name[(parameters)]`

Terminators in Fern are `;`, which are necessary to end any expression or declaration of a signature (such as a type or function.)

`{ .. }`

Scopes in Fern are started and ended using curly brackets.

## Keywords

| Keyword | Definition |
|---------|------------|
| `this` | Refers to the parent instance of the scope in which it was used, it is a comptime error if the scope has no instance. |
| `return` | [Return](grammar.md#functions)
| `delete` | [Destruct](grammar.md#constructors-and-destructors) |
| `bool` | [Builtin](grammar.md#builtins)
| `true` | [Builtin](grammar.md#builtins)
| `false` | [Builtin](grammar.md#builtins)
| `byte` | [Builtin](grammar.md#builtins)
| `ubyte` | [Builtin](grammar.md#builtins)
| `short` | [Builtin](grammar.md#builtins)
| `ushort` | [Builtin](grammar.md#builtins)
| `int` | [Builtin](grammar.md#builtins)
| `uint` | [Builtin](grammar.md#builtins)
| `long` | [Builtin](grammar.md#builtins)
| `float` | [Builtin](grammar.md#builtins)
| `double` | [Builtin](grammar.md#builtins)
| `ulong` | [Builtin](grammar.md#builtins)
| `nint` | [Builtin](grammar.md#builtins)
| `nuint` | [Builtin](grammar.md#builtins)
| `void` | [Builtin](grammar.md#builtins)
| `char` | [Builtin](grammar.md#builtins)
| `wchar` | [Builtin](grammar.md#builtins)
| `dchar` | [Builtin](grammar.md#builtins)
| `string` | [Builtin](grammar.md#builtins)
| `wstring` | [Builtin](grammar.md#builtins)
| `dstring` | [Builtin](grammar.md#builtins)
| `pure` | [Attribute](grammar.md#attributes)
| `const` | [Attribute](grammar.md#attributes)
| `static` | [Attribute](grammar.md#attributes)
| `public` | [Attribute](grammar.md#attributes)
| `private` | [Attribute](grammar.md#attributes)
| `internal` | [Attribute](grammar.md#attributes)
| `partial` | [Attribute](grammar.md#attributes)
| `unsafe` | [Attribute](grammar.md#attributes)
| `inline` | [Attribute](grammar.md#attributes)
| `mustuse` | [Attribute](grammar.md#attributes)
| `ref` | [Attribute](grammar.md#attributes)
| `align` | [Attribute](grammar.md#attributes)
| `offset` | [Attribute](grammar.md#attributes)
| `transient` | [Attribute](grammar.md#attributes)
| `atomic` | [Attribute](grammar.md#attributes)
| `alias` | [Alias](grammar.md#symbols-and-aliases)
| `module` | [Type](grammar.md#module)
| `import` | [Type](grammar.md#import)
| `struct` | [Type](grammar.md#user-defined-types)
| `class` | [Type](grammar.md#user-defined-types)
| `tagged` | [Type](grammar.md#user-defined-types)
| `unittest` | [Unittest](grammar.md#unittest)
| `function` | [Function Pointer](grammar.md#function-and-delegate-pointer-types)
| `delegate` | [Function Pointer](grammar.md#function-and-delegate-pointer-types)
| `if` | [Statement](grammar.md#statements)
| `else` | [Statement](grammar.md#statements)
| `foreach` | [Statement](grammar.md#statements)
| `foreach_reverse` | [Statement](grammar.md#statements)
| `while` | [Statement](grammar.md#statements)
| `switch` | [Statement](grammar.md#statements)
| `case` | [Statement](grammar.md#statements)
| `default` | [Statement](grammar.md#statements)
| `goto` | [Statement](grammar.md#statements)
| `with` | [Statement](grammar.md#statements)
| `break` | [Statement](grammar.md#statements)
| `continue` | [Statement](grammar.md#statements)
| `mixin` | [Mixin](grammar.md#mixins)
| `is` | [Conditional](grammar.md#types)
| `debug` | [Versioning](model.md#versoning) |
| `export` | Reserved |
| `extern` | Reserved |
| `assert` | Reserved |
| `__asm` | Reserved |

## Special Symbols

The prefix `__` is resserved for implementation and thus should be blacklisted for use in declarations. Such implementation are as follows, but implementations may add to this:

| Symbol | Definition |
|--------|------------|
| `__Windows` | Is Windows being targeted? |
| `__Linux` | Is Linux being targeted? |
| `__OSX` | Is OSX being targeted? |
| `__Posix` | Is Posix being targeted? |
| `__iOS` | Is iOS being targeted? |
| `__tvOS` | Is tvOS being targeted? |
| `__watchOS` | Is watchOS being targeted? |
| `__visionOS` | Is visionOS being targeted? |
| `__FreeBSD` | Is FreeBSD being targeted? |
| `__OpenBSD` | Is OpenBSD being targeted? |
| `__NetBSD` | Is NetBSD being targeted? |
| `__Solaris` | Is Solaris being targeted? |
| `__Android` | Is Android being targeted? |
| `__x86` | Is x86 being targeted? |
| `__x86_64` | Is x86_64 being targeted? |
| `__x64` | Is 64-bit being targeted? |
| `__x32` | Is 32-bit being targeted? |
| `__fnc` | Is the Fern Native Compiler being used? |
| `.sizeof` | The size in bytes of the symbol being targeted, this is a member. |
| `.alignof` | The alignment in bytes of the symbol being targeted, this is a member. |
| `.offsetof` | The offset in bytes of the symbol being targeted, this is a member. |
| `.typeof` | The type of the symbol being targeted, this is a member. |
| `.tag` | The tag of a tagged, this is a member. |
| `.ptr` | The pointer of an object, this is a member. |
| `.length` | The length of an array, this is a member. |