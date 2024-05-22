module fnc.treegen.relationships;

import fnc.tokenizer.tokens;
import fnc.treegen.ast_types;
import fnc.treegen.utils;

import tern.typecons.common : Nullable, nullable;

/+
    This file contains a couple of things:
        1. The "Token Grep" system, a dogshit version of regex of parsing tokenized code
        2. The order of operation used for grouping
+/

enum TokenGrepMethod {
    Glob,
    Whitespace,
    MatchesTokens,
    MatchesTokenType,
    Scope,
    NamedUnit,
    Type,
    PossibleCommaSeperated,
    Letter,
    Optional
}

struct TokenGrepPacket {
    TokenGrepMethod method;
    union {
        Token[] tokens;
        TokenGrepPacket[] packets;
    }
}

struct TokenGrepResult {
    TokenGrepMethod method;
    union {
        TokenGrepResult[] commaSeperated;
        Nullable!(TokenGrepResult[]) optional;
        Token[] tokens; // Glob
        NamedUnit name;
        AstNode type;

    }

    pragma(always_inline)
    TokenGrepResult assertAs(TokenGrepMethod test) {
        import std.conv;

        debug assert(this.method == test, this.method.to!string ~ " != " ~ test.to!string);
        return this;
    }
}

TokenGrepPacket TokenGrepPacketToken(TokenGrepMethod method, Token[] list) {
    TokenGrepPacket ret;
    ret.method = method;
    ret.tokens = list;
    return ret;
}

TokenGrepPacket TokenGrepPacketRec(TokenGrepMethod method, TokenGrepPacket[] list) {
    TokenGrepPacket ret;
    ret.method = method;
    ret.packets = list;
    return ret;
}

// The following are definitions of different types of
// structures found throughout the language. They are defined
// in a modular way, and it is surprisingly efficient.
// This is all unmantainable as FUCK, and confusing to read.
// But this works, and is quite convinent. 

const TokenGrepPacket[] ReturnStatement = [
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.Letter, "return".makeUnicodeString)
        ]),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.Equals, ['=']),
            Token(TokenType.Operator, ['>']),
        ]),
    TokenGrepPacketToken(TokenGrepMethod.Glob, []),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.Semicolon, [';'])
        ]),
];
const TokenGrepPacket[] IfStatementWithoutScope = [
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.Letter, "if".makeUnicodeString)
        ]),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.OpenBraces, ['('])
        ]),
    TokenGrepPacketToken(TokenGrepMethod.Glob, []),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.CloseBraces, [')'])
        ]),
    TokenGrepPacketToken(TokenGrepMethod.Glob, []),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.Semicolon, [';'])
        ]),
];
const TokenGrepPacket[] IfStatementWithScope = [
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.Letter, "if".makeUnicodeString)
        ]),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.OpenBraces, ['('])
        ]),
    TokenGrepPacketToken(TokenGrepMethod.Glob, []),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.CloseBraces, [')'])
        ]),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.OpenBraces, ['{'])
        ]),
    TokenGrepPacketToken(TokenGrepMethod.Glob, []),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.CloseBraces, ['}'])
        ]),
];
const TokenGrepPacket[] ElseStatementWithoutScope = [
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.Letter, "else".makeUnicodeString)
        ]),
    TokenGrepPacketToken(TokenGrepMethod.Glob, []),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.Semicolon, [';'])
        ]),
];
const TokenGrepPacket[] ElseStatementWithScope = [
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.Letter, "else".makeUnicodeString)
        ]),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.OpenBraces, ['{'])
        ]),
    TokenGrepPacketToken(TokenGrepMethod.Glob, []),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.CloseBraces, ['}'])
        ]),
];

const size_t DECLARATION_TYPE = 0;
const size_t DECLARATION_VARS = 1;
// int x, y, z;
const TokenGrepPacket[] DeclarationLine = [
    TokenGrepPacketToken(TokenGrepMethod.Type, []),
    TokenGrepPacketRec(TokenGrepMethod.PossibleCommaSeperated, [
            TokenGrepPacketToken(TokenGrepMethod.NamedUnit, []),
        ]),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokenType, [
            Token(TokenType.Semicolon, [])
        ])
];
const size_t DECLARATION_EXPRESSION = 3;

// int x, y, z = [1, 2, 3];
const TokenGrepPacket[] DeclarationAndAssignment = [
    TokenGrepPacketToken(TokenGrepMethod.Type, []),
    TokenGrepPacketRec(TokenGrepMethod.PossibleCommaSeperated, [
            TokenGrepPacketToken(TokenGrepMethod.NamedUnit, []),
        ]),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokenType, [
            Token(TokenType.Equals, [])
        ]),
    TokenGrepPacketToken(TokenGrepMethod.Glob, []),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokenType, [
            Token(TokenType.Semicolon, [])
        ])
];

// int x
const TokenGrepPacket[] FunctionArgDeclaration = [
    TokenGrepPacketToken(TokenGrepMethod.Type, []),

    TokenGrepPacketToken(TokenGrepMethod.NamedUnit, []),
];
const TokenGrepPacket[] FunctionArgDeclarationAndDefault = [
    TokenGrepPacketToken(TokenGrepMethod.Type, []),

    TokenGrepPacketToken(TokenGrepMethod.NamedUnit, []),

    TokenGrepPacketToken(TokenGrepMethod.MatchesTokenType, [
            Token(TokenType.Equals, [])
        ]),
    TokenGrepPacketToken(TokenGrepMethod.Glob, []),
];

const TokenGrepPacket[] GenericArgDeclarationTypeless = [
    TokenGrepPacketToken(TokenGrepMethod.NamedUnit, []),
];
const TokenGrepPacket[] GenericArgDeclarationTypelessWithDefault = [
    TokenGrepPacketToken(TokenGrepMethod.NamedUnit, []),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokenType, [
            Token(TokenType.Equals, [])
        ]),
    TokenGrepPacketToken(TokenGrepMethod.Glob, []),
];

const size_t IMPORT_PACKAGE_NAME = 0;
// import foo.bar
const TokenGrepPacket[] TotalImport = [
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.Letter, "import".makeUnicodeString)
        ]),
    TokenGrepPacketToken(TokenGrepMethod.NamedUnit, []),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokenType, [
            Token(TokenType.Semicolon, [])
        ])
];

// import foo : bar

const size_t SELECTIVE_IMPORT_SELECTIONS = 1;
const TokenGrepPacket[] SelectiveImport = [
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.Letter, "import".makeUnicodeString)
        ]),
    TokenGrepPacketToken(TokenGrepMethod.NamedUnit, []),

    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.Colon, ":".makeUnicodeString)
        ]),

    TokenGrepPacketRec(TokenGrepMethod.PossibleCommaSeperated, [
            TokenGrepPacketToken(TokenGrepMethod.NamedUnit, []),
        ]),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokenType, [
            Token(TokenType.Semicolon, [])
        ])
];
// module foo.bar;
const TokenGrepPacket[] ModuleDeclaration = [
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.Letter, "module".makeUnicodeString)
        ]),
    TokenGrepPacketToken(TokenGrepMethod.NamedUnit, []),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokenType, [
            Token(TokenType.Semicolon, [])
        ])
];

private const auto OPTIONAL_GENERIC_ARGUMENTS =
    TokenGrepPacketRec(TokenGrepMethod.Optional, [
            TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
                    Token(TokenType.OpenBraces, ['('])
                ]),
            TokenGrepPacketToken(TokenGrepMethod.Glob, []),
            TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
                    Token(TokenType.CloseBraces, [')'])
                ]),
        ]);

const FUNCTION_RETURN_TYPE = 0;
const FUNCTION_NAME = 1;
const FUNCTION_GENERIC_ARGS = 2;
const FUNCTION_ARGS = 3;
const FUNCTION_ATTRIBUTES = 4;
const FUNCTION_SCOPE = 5;

// void main();
const TokenGrepPacket[] AbstractFunctionDeclaration = [
    TokenGrepPacketToken(TokenGrepMethod.Type, []),
    TokenGrepPacketToken(TokenGrepMethod.NamedUnit, []),

    // Generic
    OPTIONAL_GENERIC_ARGUMENTS,

    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.OpenBraces, ['('])
        ]),
    // Parameters
    TokenGrepPacketToken(TokenGrepMethod.Glob, []),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.CloseBraces, [')'])
        ]),
    // Prepended attributes
    TokenGrepPacketToken(TokenGrepMethod.Glob, []),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokenType, [
            Token(TokenType.Semicolon, [])
        ])
];

const TokenGrepPacket[] FunctionDeclaration = [
    TokenGrepPacketToken(TokenGrepMethod.Type, []),
    TokenGrepPacketToken(TokenGrepMethod.NamedUnit, []),

    OPTIONAL_GENERIC_ARGUMENTS,
    // Parameters
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.OpenBraces, ['('])
        ]),
    TokenGrepPacketToken(TokenGrepMethod.Glob, []),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.CloseBraces, [')'])
        ]),
    TokenGrepPacketToken(TokenGrepMethod.Glob, []),
    // Body
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.OpenBraces, ['{'])
        ]),
    // Parameters
    TokenGrepPacketToken(TokenGrepMethod.Glob, []),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.CloseBraces, ['}'])
        ]),
];
const int OBJECT_NAME = 0;
const int OBJECT_GENERIC = 1;
const int OBJECT_BODY = 2;
const StructDeclaration = [
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.Letter, "struct".makeUnicodeString)
        ]),
    TokenGrepPacketToken(TokenGrepMethod.NamedUnit, []),
    OPTIONAL_GENERIC_ARGUMENTS,
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.OpenBraces, ['{'])
        ]),
    TokenGrepPacketToken(TokenGrepMethod.Glob, []),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.CloseBraces, ['}'])
        ]),
];
const ClassDeclaration = [
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.Letter, "class".makeUnicodeString)
        ]),
    TokenGrepPacketToken(TokenGrepMethod.NamedUnit, []),
    OPTIONAL_GENERIC_ARGUMENTS,
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.OpenBraces, ['{'])
        ]),
    TokenGrepPacketToken(TokenGrepMethod.Glob, []),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.CloseBraces, ['}'])
        ]),
];

const TaggedDeclaration = [
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.Letter, "tagged".makeUnicodeString)
        ]),
    TokenGrepPacketToken(TokenGrepMethod.NamedUnit, []),
    OPTIONAL_GENERIC_ARGUMENTS,
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.OpenBraces, ['{'])
        ]),
    TokenGrepPacketToken(TokenGrepMethod.Glob, []),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.CloseBraces, ['}'])
        ]),
];

enum LineVariety {
    TotalImport,
    SelectiveImport,
    ModuleDeclaration,
    FunctionDeclaration,
    ReturnStatement,

    SimpleExpression,
    IfStatementWithScope,
    IfStatementWithoutScope,
    ElseStatementWithScope,
    ElseStatementWithoutScope,
    DeclarationLine,
    DeclarationAndAssignment,

    TaggedDeclaration,
    StructDeclaration,
    ClassDeclaration,

    TaggedUntypedItem,

    GenericArgDeclarationTypelessWithDefault,
    GenericArgDeclarationTypeless,
    AbstractFunctionDeclaration
}

struct VarietyTestPair {
    LineVariety variety;
    const(TokenGrepPacket[]) test;
}

// Defines what you are allowed to do in what types of scope
const VarietyTestPair[] ABSTRACT_SCOPE_PARSE = [
    VarietyTestPair(LineVariety.TotalImport, TotalImport),
    VarietyTestPair(LineVariety.SelectiveImport, SelectiveImport),
    VarietyTestPair(LineVariety.DeclarationLine, DeclarationLine),
    VarietyTestPair(LineVariety.DeclarationAndAssignment, DeclarationAndAssignment),
];
const VarietyTestPair[] GLOBAL_SCOPE_PARSE = [
    VarietyTestPair(LineVariety.ModuleDeclaration, ModuleDeclaration),
    VarietyTestPair(LineVariety.StructDeclaration, StructDeclaration),
    VarietyTestPair(LineVariety.ClassDeclaration, ClassDeclaration),
    VarietyTestPair(LineVariety.TaggedDeclaration, TaggedDeclaration),
    VarietyTestPair(LineVariety.AbstractFunctionDeclaration, AbstractFunctionDeclaration),
    VarietyTestPair(LineVariety.FunctionDeclaration, FunctionDeclaration)
] ~ ABSTRACT_SCOPE_PARSE;

const VarietyTestPair[] FUNCTION_SCOPE_PARSE = [
    VarietyTestPair(LineVariety.IfStatementWithScope, IfStatementWithScope),
    VarietyTestPair(LineVariety.ElseStatementWithScope, ElseStatementWithScope),
    VarietyTestPair(LineVariety.IfStatementWithoutScope, IfStatementWithoutScope),

    VarietyTestPair(LineVariety.ElseStatementWithoutScope, ElseStatementWithoutScope),
    VarietyTestPair(LineVariety.ReturnStatement, ReturnStatement),
] ~ ABSTRACT_SCOPE_PARSE;

const VarietyTestPair[] FUNCTION_ARGUMENT_PARSE = [
    VarietyTestPair(LineVariety.DeclarationAndAssignment,
        FunctionArgDeclarationAndDefault ~ TokenGrepPacketToken(TokenGrepMethod.MatchesTokenType,
            [
                Token(TokenType.Comma, [])
            ]
    )),
    VarietyTestPair(LineVariety.DeclarationAndAssignment, FunctionArgDeclarationAndDefault),
    VarietyTestPair(LineVariety.DeclarationLine, FunctionArgDeclaration),
];

const VarietyTestPair[] GENERIC_ARGUMENT_PARSE = [
    VarietyTestPair(LineVariety.GenericArgDeclarationTypelessWithDefault,
        GenericArgDeclarationTypelessWithDefault ~ TokenGrepPacketToken(
            TokenGrepMethod.MatchesTokenType,
            [
                Token(TokenType.Comma, [])
            ]
    )),
    VarietyTestPair(LineVariety.GenericArgDeclarationTypelessWithDefault, GenericArgDeclarationTypelessWithDefault),
    VarietyTestPair(LineVariety.GenericArgDeclarationTypeless, GenericArgDeclarationTypeless),
];

// Used in structs / classes
const VarietyTestPair[] OBJECT_DEFINITION_PARSE = [
    VarietyTestPair(LineVariety.DeclarationLine, DeclarationLine),
    VarietyTestPair(LineVariety.DeclarationAndAssignment, DeclarationAndAssignment),
    VarietyTestPair(LineVariety.FunctionDeclaration, FunctionDeclaration)
];
const VarietyTestPair[] TAGGED_DEFINITION_PARS = OBJECT_DEFINITION_PARSE ~ [
    VarietyTestPair(LineVariety.TaggedUntypedItem, [
            TokenGrepPacketToken(TokenGrepMethod.NamedUnit, []),
            TokenGrepPacketToken(TokenGrepMethod.MatchesTokenType, [
                    Token(TokenType.Semicolon, [])
                ])
        ])
];

Nullable!(TokenGrepResult[]) matchesToken(in TokenGrepPacket[] testWith, Token[] tokens) {
    size_t index = 0;
    return matchesToken(testWith, tokens, index);
}

import std.stdio;

alias tokenGrepBox = Nullable!(TokenGrepResult[]);
Nullable!(TokenGrepResult[]) matchesToken(in TokenGrepPacket[] testWith, Token[] tokens, ref size_t index) {
    TokenGrepResult[] returnVal;
    foreach (testIndex, packet; testWith) {
        switch (packet.method) {
            case TokenGrepMethod.NamedUnit:
                if (index >= tokens.length)
                    return tokenGrepBox(null);
                NamedUnit name = genNamedUnit(tokens, index);
                if (name.names.length == 0)
                    return tokenGrepBox(null);
                TokenGrepResult result;
                result.method = TokenGrepMethod.NamedUnit;
                result.name = name;
                returnVal ~= result;
                break;
            case TokenGrepMethod.MatchesTokenType:
                Token[] found;

                foreach (const(Token) potentialMatch; packet.tokens) {
                    Nullable!Token potential = tokens.nextNonWhiteToken(index);
                    if (potential.ptr == null)
                        return tokenGrepBox(null);
                    Token token = potential;
                    if (potentialMatch.tokenVariety != token.tokenVariety)
                        return tokenGrepBox(null);
                    found ~= token;
                }
                TokenGrepResult res;
                res.method = TokenGrepMethod.Letter;
                res.tokens = found;
                returnVal ~= res;
                break;
            case TokenGrepMethod.MatchesTokens:
                foreach (const(Token) testToken; packet.tokens) {
                    Nullable!Token tokenNullable = tokens.nextNonWhiteToken(index);
                    if (tokenNullable.ptr == null)
                        return tokenGrepBox(null);
                    Token token = tokenNullable;
                    if (token.tokenVariety != testToken.tokenVariety || token.value != testToken
                        .value)
                        return tokenGrepBox(null);
                }
                break;
            case TokenGrepMethod.PossibleCommaSeperated:
                if (index >= tokens.length)
                    return tokenGrepBox(null);

                TokenGrepResult commaSeperatedGroup;
                commaSeperatedGroup.method = TokenGrepMethod.PossibleCommaSeperated;
                commaSeperatedGroup.commaSeperated = new TokenGrepResult[0];
                size_t commaSearchIndex = index;
                while (commaSearchIndex < tokens.length) {
                    size_t matchSize;
                    auto itemTestResult = packet.packets.matchesToken(tokens[commaSearchIndex .. $], matchSize);
                    if (itemTestResult == null)
                        break;

                    commaSearchIndex += matchSize;

                    commaSeperatedGroup.commaSeperated ~= itemTestResult.value;

                    auto possibleNext = tokens.nextNonWhiteToken(commaSearchIndex);

                    if (possibleNext == null || possibleNext.value.tokenVariety != TokenType.Comma) {
                        commaSearchIndex--;
                        break;
                    }
                }
                if (!commaSeperatedGroup.commaSeperated.length)
                    return tokenGrepBox(null);
                returnVal ~= commaSeperatedGroup;
                index = commaSearchIndex;
                break;
            case TokenGrepMethod.Type:
                import fnc.treegen.expression_parser : prematureSingleTokenGroupLength, expressionNodeFromTokens;

                size_t potentialSize = prematureSingleTokenGroupLength(tokens, index);
                if (!potentialSize)
                    return tokenGrepBox(null);
                Array!AstNode type = expressionNodeFromTokens(tokens[index .. index + potentialSize]);

                if (type.length != 1)
                    return tokenGrepBox(null);

                TokenGrepResult tokenGrep;
                tokenGrep.method = TokenGrepMethod.Type;
                tokenGrep.type = type[0];
                returnVal ~= tokenGrep;
                index += potentialSize;
                break;

            case TokenGrepMethod.Optional:
                TokenGrepResult optinalResult;
                optinalResult.method = TokenGrepMethod.Optional;

                auto restToTest = testWith[testIndex + 1 .. $];

                size_t tempIndex = index;
                tokenGrepBox optional = packet.packets.matchesToken(tokens, tempIndex);

                if (optional == null)
                    goto WITHOUT_OPTIONAL;
                // NOT PART OF THE IF, this is a workaround untill CETIO FIXES HIS BUG
                {
                    tokenGrepBox restOfLine = restToTest.matchesToken(tokens, tempIndex);

                    if (restOfLine == null)
                        goto WITHOUT_OPTIONAL;

                    optinalResult.optional = optional;
                    index = tempIndex;

                    return tokenGrepBox(returnVal ~ optinalResult ~ restOfLine.value);
                }

        WITHOUT_OPTIONAL: {
                    tokenGrepBox restOfLine = restToTest.matchesToken(tokens, index);
                    if (restOfLine == null)
                        return tokenGrepBox(null);

                    optinalResult.optional.ptr = null; // WTF @Cetio

                    return tokenGrepBox(returnVal ~ optinalResult ~ restOfLine.value);
                }
            case TokenGrepMethod.Glob:
                size_t temp_index;
                auto grepMatchGroup = testWith[testIndex + 1 .. $];

                auto firstGlob = grepMatchGroup.matchesToken(tokens[index .. $], temp_index);

                TokenGrepResult globResult;
                globResult.method = TokenGrepMethod.Glob;
                globResult.tokens = [];

                if (!grepMatchGroup.length) {
                    globResult.tokens = tokens[index .. $];
                    index = tokens.length;
                    return tokenGrepBox(returnVal ~ globResult);
                }
                if (firstGlob.ptr) {
                    index += temp_index;
                    return tokenGrepBox(returnVal ~ globResult ~ firstGlob.value);
                }

                int braceDeph = 0;
                size_t startingIndex = index;
                index--;
                while (true) {
                    Nullable!Token tokenNullable = tokens.nextToken(index);
                    if (tokenNullable == null)
                        return tokenGrepBox(null);
                    Token token = tokenNullable;
                    globResult.tokens ~= token;

                    if (token.tokenVariety == TokenType.OpenBraces)
                        braceDeph++;
                    if (token.tokenVariety == TokenType.CloseBraces)
                        braceDeph--;

                    if (braceDeph == 0) {
                        size_t index_inc = 0;
                        auto res = grepMatchGroup.matchesToken(tokens[index + 1 .. $], index_inc);
                        if (res != null) {
                            globResult.tokens = tokens[startingIndex .. index + 1];
                            index += index_inc + 1;
                            return tokenGrepBox(returnVal ~ globResult ~ res.value);
                        }
                    }

                }
                break;
            default:
                assert(0, "Not implemented");

        }
    }

    return tokenGrepBox(returnVal);
}

NamedUnit[] collectNamedUnits(TokenGrepResult[] greps) {
    NamedUnit[] ret;
    foreach (TokenGrepResult grepResult; greps) {
        assert(grepResult.method == TokenGrepMethod.NamedUnit);
        ret ~= grepResult.name;
    }
    return ret;
}

enum OperatorOrder {
    LeftToRight,
    RightToLeft
}

struct OperatorPrecedenceLayer {
    OperatorOrder order;
    OperationPrecedenceEntry[] layer;
}

struct OperationPrecedenceEntry {
    OperationVariety operation;

    // These tokens are just the template used for
    // determining what is parsed in what order.

    // TokenType of Operator is the operator to match to.
    // TokenType of Filler is an expression (or equivelent)
    const(Token[]) tokens;
}

private Token OPR(dchar o) {
    return Token(o != '=' ? TokenType.Operator : TokenType.Equals, [o]);
}

const auto SEPERATION_LAYER =
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
            OperationPrecedenceEntry(OperationVariety.Period, [
                    Token(TokenType.Filler), Token(TokenType.Period, ['.']),
                    Token(TokenType.Filler)
                ]),
            OperationPrecedenceEntry(OperationVariety.Arrow, [
                    Token(TokenType.Filler), Token(TokenType.Operator, ['-']),
                    Token(TokenType.Operator, ['>']),
                    Token(TokenType.Filler)
                ]),
        ]);
const auto SEPERATION_LAYER_WITH_VOIDABLE = OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
        OperationPrecedenceEntry(OperationVariety.Voidable, [
                Token(TokenType.Filler), Token(TokenType.Operator, ['?'])
            ])
    ] ~ cast(OperationPrecedenceEntry[]) SEPERATION_LAYER.layer);

// https://en.cppreference.com/w/c/language/operator_precedence
// Order of operations in the language. This is broken up
// into layers, the layers are what is done first. And inside
// of each layer they are read left to right, or right to left.

const OperatorPrecedenceLayer[] operatorPrecedence = [
    SEPERATION_LAYER,
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
            OperationPrecedenceEntry(OperationVariety.PreIncrement, [
                    OPR('+'), OPR('+'), Token(TokenType.Filler)
                ]),
            OperationPrecedenceEntry(OperationVariety.PreDecrement, [
                    OPR('-'), OPR('-'), Token(TokenType.Filler)
                ]),
            OperationPrecedenceEntry(OperationVariety.PostIncrement, [
                    Token(TokenType.Filler), OPR('+'), OPR('+')
                ]),
            OperationPrecedenceEntry(OperationVariety.PostDecrement, [
                    Token(TokenType.Filler), OPR('-'), OPR('-')
                ]),

            OperationPrecedenceEntry(OperationVariety.LogicalNot, [
                    Token(TokenType.ExclamationMark, "!".makeUnicodeString),
                    Token(TokenType.Filler)
                ])
        ]),
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
            OperationPrecedenceEntry(OperationVariety.Multiply, [
                    Token(TokenType.Filler), OPR('*'), Token(TokenType.Filler)
                ]),
            OperationPrecedenceEntry(OperationVariety.Divide, [
                    Token(TokenType.Filler), OPR('/'), Token(TokenType.Filler)
                ]),
            OperationPrecedenceEntry(OperationVariety.Mod, [
                    Token(TokenType.Filler), OPR('%'), Token(TokenType.Filler)
                ]),
        ]),
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
            OperationPrecedenceEntry(OperationVariety.Add, [
                    Token(TokenType.Filler), OPR('+'), Token(TokenType.Filler)
                ]),
            OperationPrecedenceEntry(OperationVariety.Substract, [
                    Token(TokenType.Filler), OPR('-'), Token(TokenType.Filler)
                ]),
        ]),
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
            OperationPrecedenceEntry(OperationVariety.BitshiftLeftSigned, [
                    Token(TokenType.Filler), OPR('<'), OPR('<'),
                    Token(TokenType.Filler)
                ]),
            OperationPrecedenceEntry(OperationVariety.BitshiftRightSigned, [
                    Token(TokenType.Filler), OPR('>'), OPR('>'),
                    Token(TokenType.Filler)
                ]),
            OperationPrecedenceEntry(OperationVariety.BitshiftLeftUnSigned, [
                    Token(TokenType.Filler), OPR('<'), OPR('<'), OPR('<'),
                    Token(TokenType.Filler)
                ]),
            OperationPrecedenceEntry(OperationVariety.BitshiftRightUnSigned, [
                    Token(TokenType.Filler), OPR('>'), OPR('>'), OPR('>'),
                    Token(TokenType.Filler)
                ]),
        ]),
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
            OperationPrecedenceEntry(OperationVariety.LessThanEq, [
                    Token(TokenType.Filler), OPR('<'), OPR('='),
                    Token(TokenType.Filler)
                ]),
            OperationPrecedenceEntry(OperationVariety.GreaterThanEq, [
                    Token(TokenType.Filler), OPR('>'), OPR('='),
                    Token(TokenType.Filler)
                ]),
            OperationPrecedenceEntry(OperationVariety.LessThan, [
                    Token(TokenType.Filler), OPR('<'), Token(TokenType.Filler)
                ]),
            OperationPrecedenceEntry(OperationVariety.GreaterThan, [
                    Token(TokenType.Filler), OPR('>'), Token(TokenType.Filler)
                ]),
        ]),
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
            OperationPrecedenceEntry(OperationVariety.NotEqualTo, [
                    Token(TokenType.Filler), OPR('!'), OPR('='),
                    Token(TokenType.Filler)
                ]),
            OperationPrecedenceEntry(OperationVariety.EqualTo, [
                    Token(TokenType.Filler),
                    Token(TokenType.Equals, "==".makeUnicodeString),
                    Token(TokenType.Filler)
                ]),
        ]),
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
            OperationPrecedenceEntry(OperationVariety.BitwiseAnd, [
                    Token(TokenType.Filler), OPR('&'), Token(TokenType.Filler)
                ]),
        ]),
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
            OperationPrecedenceEntry(OperationVariety.BitwiseXor, [
                    Token(TokenType.Filler), OPR('^'), Token(TokenType.Filler)
                ]),
        ]),
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
            OperationPrecedenceEntry(OperationVariety.BitwiseOr, [
                    Token(TokenType.Filler), OPR('|'), Token(TokenType.Filler)
                ]),
        ]),
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
            OperationPrecedenceEntry(OperationVariety.LogicalAnd, [
                    Token(TokenType.Filler), OPR('&'), OPR('&'),
                    Token(TokenType.Filler)
                ]),
        ]),
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
            OperationPrecedenceEntry(OperationVariety.LogicalOr, [
                    Token(TokenType.Filler), OPR('|'), OPR('|'),
                    Token(TokenType.Filler)
                ]),
        ]),
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
            OperationPrecedenceEntry(OperationVariety.Range, [
                    Token(TokenType.Filler), Token(TokenType.Period, ['.', '.']),
                    Token(TokenType.Filler)
                ]),
            OperationPrecedenceEntry(OperationVariety.Concatenate, [
                    Token(TokenType.Filler), OPR('~'), Token(TokenType.Filler)
                ]),
        ]),
    OperatorPrecedenceLayer(OperatorOrder.RightToLeft, [
        OperationPrecedenceEntry(OperationVariety.TernaryOperator, [
                Token(TokenType.Filler), Token(TokenType.Letter, "if".makeUnicodeString),
                Token(TokenType.Filler), Token(TokenType.Letter, "else".makeUnicodeString),
                Token(TokenType.Filler)
            ]),

    ]),
    OperatorPrecedenceLayer(OperatorOrder.RightToLeft, [
            OperationPrecedenceEntry(OperationVariety.Assignment, [
                    Token(TokenType.Filler), OPR('='), Token(TokenType.Filler)
                ]),
            OperationPrecedenceEntry(OperationVariety.ArrayStyleAssignment, [
                    Token(TokenType.Filler),
                    Token(TokenType._ArrayStyleAssignment),
                    Token(TokenType.Filler)
                ]),
            OperationPrecedenceEntry(OperationVariety.AddEq, [
                    Token(TokenType.Filler), OPR('+'), OPR('='),
                    Token(TokenType.Filler)
                ]),
            OperationPrecedenceEntry(OperationVariety.SubstractEq, [
                    Token(TokenType.Filler), OPR('-'), OPR('='),
                    Token(TokenType.Filler)
                ]),
            OperationPrecedenceEntry(OperationVariety.MultiplyEq, [
                    Token(TokenType.Filler), OPR('*'), OPR('='),
                    Token(TokenType.Filler)
                ]),
            OperationPrecedenceEntry(OperationVariety.DivideEq, [
                    Token(TokenType.Filler), OPR('/'), OPR('='),
                    Token(TokenType.Filler)
                ]),
            OperationPrecedenceEntry(OperationVariety.ModEq, [
                    Token(TokenType.Filler), OPR('%'), OPR('='),
                    Token(TokenType.Filler)
                ]),

            OperationPrecedenceEntry(OperationVariety.BitwiseAndEq, [
                    Token(TokenType.Filler), OPR('&'), OPR('='),
                    Token(TokenType.Filler)
                ]),
            OperationPrecedenceEntry(OperationVariety.BitwiseXorEq, [
                    Token(TokenType.Filler), OPR('^'), OPR('='),
                    Token(TokenType.Filler)
                ]),
            OperationPrecedenceEntry(OperationVariety.BitwiseOrEq, [
                    Token(TokenType.Filler), OPR('|'), OPR('='),
                    Token(TokenType.Filler)
                ]),
            OperationPrecedenceEntry(OperationVariety.ConcatenateEq, [
                    Token(TokenType.Filler), OPR('~'), OPR('='),
                    Token(TokenType.Filler)
                ]),
            OperationPrecedenceEntry(OperationVariety.BitshiftLeftSignedEq, [
                    Token(TokenType.Filler), OPR('<'), OPR('<'), OPR('='),
                    Token(TokenType.Filler)
                ]),
            OperationPrecedenceEntry(OperationVariety.BitshiftRightSignedEq, [
                    Token(TokenType.Filler), OPR('>'), OPR('>'), OPR('='),
                    Token(TokenType.Filler)
                ]),
            OperationPrecedenceEntry(OperationVariety.BitshiftLeftUnSignedEq, [
                    Token(TokenType.Filler), OPR('<'), OPR('<'), OPR('<'),
                    OPR('='),
                    Token(TokenType.Filler)
                ]),
            OperationPrecedenceEntry(OperationVariety.BitshiftRightUnSignedEq, [
                    Token(TokenType.Filler), OPR('>'), OPR('>'), OPR('>'),
                    OPR('='),
                    Token(TokenType.Filler)
                ])
        ])

];
import std.container.array;

bool testAndJoin(const(OperationPrecedenceEntry) entry, ref Array!AstNode nodes, size_t startIndex) {
    if (entry.tokens.length > nodes.length)
        return false;
    size_t nodeIndex = startIndex;
    AstNode[] operands;
    AstNode potentialArrayStyleAssignmentData;

    for (size_t index = 0; index < entry.tokens.length; index++) {
        Nullable!AstNode nodeNullable = nodes.nextNonWhiteNode(nodeIndex);
        if (nodeNullable == null)
            return false;
        AstNode node = nodeNullable;
        switch (entry.tokens[index].tokenVariety) {

            case TokenType.Filler:

                if (node.action == AstAction.TokenHolder)
                    return false;
                operands ~= node;
                break;
            case TokenType._ArrayStyleAssignment:
                if (node.action != AstAction.ProtoArrayEq)
                    return false;
                potentialArrayStyleAssignmentData = node.arrayEqNodeData;
                break;
            case TokenType.Letter:
                if (node.action != AstAction.NamedUnit)
                    return false;
                if (node.namedUnit.names.length != 1) // We don't support operators with . in it
                    return false;
                if (node.namedUnit.names[0] != entry.tokens[index].value)
                    return false;
                break;
            case TokenType.QuestionMark:
            case TokenType.ExclamationMark:
            case TokenType.Equals:
            case TokenType.Operator:
                if (node.action != AstAction.TokenHolder)
                    return false;
                Token token = node.tokenBeingHeld;
                if (!token.isLikeOpr)
                    return false;
                if (token.value != entry.tokens[index].value)
                    return false;
                break;
            case TokenType.Period:
                if (node.tokenBeingHeld.tokenVariety != TokenType.Period
                    || node.tokenBeingHeld.value.length != entry.tokens[index].value.length)
                    return false;
                break;
            default:
                assert(0);

        }
    }
    AstNode oprNode = new AstNode();

    if (entry.operation == OperationVariety.Assignment) {
        oprNode.action = AstAction.AssignVariable;
        oprNode.assignVariableNodeData = AssignVariableNodeData(
            [operands[0]],
            operands[1]
        );
        goto trim;
    }

    oprNode.action = AstAction.DoubleArgumentOperation;
    if (operands.length == 0)
        assert(0);
    if (operands.length == 1 && entry.operation == OperationVariety.Voidable) {
        oprNode.action = AstAction.Voidable;
        oprNode.voidableType = operands[0];
    }
   else if (entry.operation == OperationVariety.ArrayStyleAssignment) {
        oprNode.action = AstAction.NArgumentOperation;
        assert(potentialArrayStyleAssignmentData, "potentialArrayStyleAssignmentData not resolved");
        oprNode.nArgumentOperationNodeData = NArgumentOperationNodeData(entry.operation, operands 
                ~ potentialArrayStyleAssignmentData 
                );
    }
    else if (operands.length == 1) {

        oprNode.action = AstAction.SingleArgumentOperation;
        oprNode.singleArgumentOperationNodeData = SingleArgumentOperationNodeData(
            entry.operation,
            operands[0],
        );

    }
    else if (operands.length == 2)
        oprNode.doubleArgumentOperationNodeData = DoubleArgumentOperationNodeData(
            entry.operation,
            operands[0],
            operands[1]
        );
    else {
        oprNode.action = AstAction.NArgumentOperation;
        oprNode.nArgumentOperationNodeData = NArgumentOperationNodeData(entry.operation, operands);
    }
trim:

    nodes[startIndex] = oprNode;
    nodes.linearRemove(nodes[startIndex + 1 .. nodeIndex]);
    return true;
}

void scanAndMergeOperators(ref Array!AstNode nodes) {
    // OperatorOrder order;
    static foreach (layer; operatorPrecedence) {
        static if (layer.order == OperatorOrder.LeftToRight) {
            for (size_t index = 0; index < nodes.length; index++) {
                foreach (entry; layer.layer) {
                    if (entry.testAndJoin(nodes, index)) {
                        index--;
                        continue;
                    }

                }
            }
        }
        static if (layer.order == OperatorOrder.RightToLeft) {
            for (size_t index = nodes.length; index != -1; index--) {
                foreach (entry; layer.layer) {
                    if (entry.testAndJoin(nodes, index)) {
                        index++;
                        continue;
                    }
                }
            }
        }
    }
}
