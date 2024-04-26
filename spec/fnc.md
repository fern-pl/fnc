# FNC

## Strings & Vectorization

FNC uses heap-last vector-first schema for strings. Strings do not have the same priority as vector types, like a `long[2]` but retains second priority at all times to try to fit them into registers. 

If a string overflows outside of a vector, it will go onto the heap instead, where it will act as a rope which allocates ahead of itself to account for repeated reassignment at the cost of using extra memory.

Vectors are not explicitly defined as types, but all static arrays that directly correspond to a vector type will act as a vector type implicitly, these are defined as the following types.

| Type | Intel Intrinsics |
|------|------------------|
| `byte[16]` | `__m128i` |
| `ubyte[16]` | `__m128i` |
| `short[8]` | `__m128i` |
| `ushort[8]` | `__m128i` |
| `int[4]` | `__m128i` |
| `uint[4]` | `__m128i` |
| `long[2]` | `__m128i` |
| `ulong[2]` | `__m128i` |
| `float[4]` | `__m128` |
| `double[2]` | `__m128d` |
| `byte[32]` | `__m256i` |
| `ubyte[32]` | `__m256i` |
| `short[16]` | `__m256i` |
| `ushort[16]` | `__m256i` |
| `int[8]` | `__m256i` |
| `uint[8]` | `__m256i` |
| `long[4]` | `__m256i` |
| `ulong[4]` | `__m256i` |
| `float[8]` | `__m256` |
| `double[4]` | `__m256d` |
| `byte[64]` | `__m512i` |
| `ubyte[64]` | `__m512i` |
| `short[32]` | `__m512i` |
| `ushort[32]` | `__m512i` |
| `int[16]` | `__m512i` |
| `uint[16]` | `__m512i` |
| `long[8]` | `__m512i` |
| `ulong[8]` | `__m512i` |
| `float[16]` | `__m512` |
| `double[8]` | `__m512d` |

The following intrinsics are defined for such vector types:

TODO: TBD

## Phases

> The Arbore project tree is read before anything else and `arbore.json` is used to determine compilation information, if it exists, which is highly recommended to allow for caching of metadata which aids in compilation speeds.

1. Lexical Analysis
    - Source code is split up into tokens and initially parsed.
2. Syntax Analysis
    - Tokens are parsed to make usable input for the compiler, during this phase comptime errors for basic syntax are thrown. 
    - Function call inference is done during this phase, determining special syntax such as implicit generics instantiation, UFCS function extensions, etc.
3. Semantic Analysis
    - Input code is made to actually usable code, symbols are resolved, tables are set up, functions are generated, and inference is done. This may take place numerous times.
    - Inference will be done by the compiler back-end during this phase, determining function attributes that were not implicitly declared and throwing comptime errors that were not previously caught.
4. Evaluation & Resolution
    - Symbols which may not be resolved without a prior step, such as executing comptime functions or otherwise mixing in code is done, if this results in a symbol being evaluated then semantic analysis will take place again to resolve whatever was done by this step.
5. Pollution, Scoring & Initialization
    - Function instructions are traversed to determine hierarchy of pollution, scoring variables based on frequency, and initialization of variables are added if they are not already initialized.
    - Vector types are always maximally scored, meaning they have guaranteed priority to their registers over other non-vector types.
6. Optimization I
    - Instructions which may be evaluated at comptime are automatically evaluated and their results are inlined. This will result in expressions like `if (true)` or `1 + 2` to evaluate to no branch and `3` respectively.
    - Inefficient operations, such as `mov rax, 0` would be replaced with their more effective counterparts, like `xor rax, rax` and inference of intentions and implications are done for later passes.
7. Optimization II
8. Optimization III
9. Optimization IV
10. Optimization V
11. Linear Reference Counting
    - Variables are linearly reference counted, this is done by traversing the instructions of functions in the current hierarchy and checking when the variable is last accessed, it is collected after the last time it has been accessed or not collected if it either exits all scopes in the hierarchy or is unable to be confidently determined to be collectable.
    - A variable would not be collected if it is used in a call to an external function with unavailable source, assigned to a global field, assigned to an external object's data, or otherwise leaves the scope in a way where it cannot be tracked; this would lead to the garbage collector handling the object rather than the reference counter.
12. Compilation
    - After all functions have been resolved types are set up, functions are compiled, data is inlined to the object, and the final compiled object is prepared to be linked in the next phase.
13. Linking
    - The compiled object is linked, producing the actual binary.
14. Caching
    - Comptime information that was previously evaluated in the Evaluation & Resolution stage are cached to better streamline the build process in the future. This is only done if the compilation took place in an Arbore project.

## Arbore

Arbore is the standardized Fern build system intended to be an cross-compiler system to allow any compiler to easily cache metadata and understand your project at a glance.

### Structure

- `bin\`
- `source\`
- `arbore-selections.json`
- `arbore.json`

`bin\` holds all recent compilations and cached metadata, namely comptime information used to speed up future builds and recent binaries.

`source\` holds all source files used for compilation, this may be modified to not be used or for other folders to also contain source files using `arb.json`. Internal folders inside of a source folder are ignored by compilation and have no bearing on output.

`arbore-selections.json` is reserved and not explicitly required. It is intended to eventually be used for adding library dependencies.

`arbore.json` is the core of Arbore, all contents are reserved.