# Lexical

## Strings and Characters

String literals may be defined using `q{...}` or `"..."`, when using the latter syntax `d` or `w` may be prepended to dictate the size of the characters (`dchar` or `wchar`) or `r` to dictate that all escapes are ignored. 

Character literals may be defined using `'...'` in which a single character is defined.

### Escapes

## Literal Suffixes

Literal suffixes are suffixes which may be appended to a literal to change the way that the literal is formatted or interpreted.

| Integral Suffix | Definition |
|------------------------|------------|
| `u` | Unsigned. |
| `U` | Signed. |
| `L` | 64-bit integer. |
| `f` | 32-bit floating point |

## Comments, Terminators, and Scopes

`// comment`

`/* multi-line comment */`

Comments in Fern use the syntax `\\` for single-line and `\*..*\` for multi-line.

`[type] name;`

`[type] name[(parameters)]`

Terminators in Fern are `;`, which are necessary to end any expression or declaration of a signature (such as a type or function.)

`{ .. }`

Scopes in Fern are started and ended using curly brackets.

## Keywords

| Keyword | Definition |
|---------|------------|
| `this` | Refers to the parent instance of the scope in which it was used, it is a comptime error if the scope has no instance. |
| `delete` | Calls the destructor of the provided variable. |
