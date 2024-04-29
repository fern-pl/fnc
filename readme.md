# Fern
<p align = "center">
  <a href="https://github.com/cetio/fern/actions/workflows/d.yml"> <img src="https://github.com/cetio/fern/actions/workflows/d.yml/badge.svg"> </a>
  <a href="https://raw.githubusercontent.com/cetio/fern/main/LICENSE.txt"> <img src="https://img.shields.io/github/license/cetio/fern.svg" alt="GitHub repo license"/> </a>
  <a href="https://github.com/cetio/fern"><img src="https://img.shields.io/github/repo-size/cetio/fern.svg" alt="GitHub repo size"/></a>
  <a href="https://github.com/cetio/fern"><img src="https://img.shields.io/github/languages/code-size/cetio/fern.svg" alt="GitHub code size"/></a>
  <a href="https://github.com/cetio/fern"><img src="https://img.shields.io/github/commit-activity/t/cetio/fern.svg" alt="GitHub commits"/></a>
  
  
</center>

[![Gallinule](https://img.shields.io/badge/Gallinule-2ea44f?style=for-the-badge&logo=github)](https://github.com/cetio/gallinule)

Fern is a natively compiled, highly versatile language intended to bring together metaprogramming, performance, and ease-of-use to a happy medium.

Examples [exist](examples) but are small tidbits meant to facilitate parser testing, the language is not functional.

## Notable Features

1. [Hybrid Memory Management](spec/model.md#memory-management)
    - Linear Reference Counting

2. [Symbol-First Casting and Conversion](spec/model.md#casts-and-conversions)
3. [UFCS (Uniform Function Call Syntax)](spec/model.md#ufcs)
4. [CTFE (Compile-Time Function Execution)](spec/model.md#ctfe)
5. [Symbols and Aliases](spec/grammar.md#symbols-and-aliases)
6. [Granular Attributes](spec/grammar.md#attributes)
7. [Variable-Based Return](spec/grammar.md#functions)

## Specification

1. [Model](spec/model.md)

2. [Grammar](spec/grammar.md)
3. [Lexical](spec/lexical.md)

Fern is planned to be able to, as well as natively compile, compile into CIL which may be interpreted directly as if Fern were C# and the standard library is likely to incorporate a more fully fleshed out rendition of [Godwit](https://github.com/cetio/godwit) to enable full seamless integration and interop with .NET languages.
