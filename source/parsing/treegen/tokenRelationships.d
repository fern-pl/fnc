module parsing.treegen.tokenRelationships;
import parsing.tokenizer.tokens;
import parsing.treegen.astTypes;
import parsing.treegen.treeGenUtils;
import tern.typecons.common : Nullable;

enum TokenGrepMethod
{
    Glob,
    Whitespace,
    MatchesTokens,
    MatchesTokenType,
    Scope,
    ConditionWithCertainReturnType,
    NameUnit,
    PossibleCommaSeperated
}

struct TokenGrepPacket
{
    TokenGrepMethod method;
    union
    {
        Token[] tokens;
        TokenGrepPacket[] packets;
    }
}

TokenGrepPacket TokenGrepPacketToken(TokenGrepMethod method, Token[] list)
{
    TokenGrepPacket ret;
    ret.method = method;
    ret.tokens = list;
    return ret;
}

TokenGrepPacket TokenGrepPacketRec(TokenGrepMethod method, TokenGrepPacket[] list)
{
    TokenGrepPacket ret;
    ret.method = method;
    ret.packets = list;
    return ret;
}

const TokenGrepPacket[] IF_STATEMENT_WITH_SCOPE = [
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.Letter, "if".makeUnicodeString)
        ]),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.OpenBraces, ['('])
        ]),
    TokenGrepPacketToken(TokenGrepMethod.ConditionWithCertainReturnType, []),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.CloseBraces, [')'])
        ]),

    TokenGrepPacketToken(TokenGrepMethod.Scope, []),
];
const TokenGrepPacket[] IF_STATEMENT_WITHOUT_SCOPE = [
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.Letter, "if".makeUnicodeString)
        ]),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.OpenBraces, ['('])
        ]),
    TokenGrepPacketToken(TokenGrepMethod.ConditionWithCertainReturnType, []),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.CloseBraces, [')'])
        ]),

    TokenGrepPacketToken(TokenGrepMethod.Glob, []),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.Semicolon, [';'])
        ]),
];

// int x, y, z;
const TokenGrepPacket[] DeclarationLine = [
    TokenGrepPacketToken(TokenGrepMethod.NameUnit, []),
    TokenGrepPacketRec(TokenGrepMethod.PossibleCommaSeperated, [
            TokenGrepPacketToken(TokenGrepMethod.MatchesTokenType, [
                    Token(TokenType.Letter, [])
                ])
        ]),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokenType, [ Token(TokenType.Semicolon, []) ])
];

bool matchesToken(in TokenGrepPacket[] testWith, Token[] tokens){
    size_t index = 0;
    return matchesToken(testWith, tokens, index);
}

import std.stdio;

private bool matchesToken(in TokenGrepPacket[] testWith, Token[] tokens, ref size_t index)
{
    foreach (packet; testWith)
    {
        switch (packet.method)
        {
        case TokenGrepMethod.NameUnit:
            if (index >= tokens.length)
                return false;
            NameUnit name = genNameUnit(tokens, index);
            if (name.names.length == 0)
                return false;
            name.writeln;
            break;
        case TokenGrepMethod.MatchesTokenType:
            Nullable!Token potential = tokens.nextNonWhiteToken(index);
            if (potential.ptr == null)
                return false;
            Token token = potential;
            foreach (const(Token) potentialMatch ; packet.tokens){
                if (potentialMatch.tokenVariety == token.tokenVariety) 
                    goto MATCH;
            }
            return false;

            MATCH:
            break;
        case TokenGrepMethod.PossibleCommaSeperated:
            if (index >= tokens.length)
                return false;
            Token[][] tstack;
            Token[] currentGroup;
            size_t maxComma = 0;
            size_t secountIndex = 0;
            foreach (token; tokens[index .. $])
            {
                scope (exit) secountIndex++;

                if (token.tokenVariety == TokenType.Comma)
                {
                    maxComma = secountIndex;
                    tstack ~= currentGroup;
                    currentGroup = new Token[0];
                    continue;
                }
                currentGroup ~= token;
            }
            size_t searchExtent;
            tstack ~= currentGroup;
            foreach (Token[] tokenGroup; tstack)
            {
                searchExtent = 0;
                if (!matchesToken(packet.packets, tokenGroup, searchExtent))
                    return false;
            }
            index += maxComma + searchExtent;

            break;
        default:
            assert(0, "Not implemented");

        }
    }

    return true;
}

unittest
{
    import parsing.tokenizer.make_tokens;

    DeclarationLine.matchesToken(tokenizeText("mod.type x;")).writeln;
}

enum OperatorOrder
{
    LeftToRight,
    RightToLeft
}

struct OperatorPrecedenceLayer
{
    OperatorOrder order;
    OperationPrecedenceEntry[] layer;
}

struct OperationPrecedenceEntry
{
    OperationVariety operation;

    // These tokens are just the template used for
    // determining what is parsed in what order.

    // TokenType of Operator is the operator to match to.
    // TokenType of Filler is an expression (or equivelent)
    const(Token[]) tokens;
}

private Token OPR(dchar o)
{
    return Token(TokenType.Operator, [o]);
}

// https://en.cppreference.com/w/c/language/operator_precedence
// Order of operations in the language. This is broken up
// into layers, the layers are what is done first. And inside
// of each layer they are read left to right, or right to left.

const OperatorPrecedenceLayer[] operatorPrecedence = [
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
            // TODO: Unary
        ]),
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
                    OPR('!'), Token(TokenType.Filler)
                ]),
            OperationPrecedenceEntry(OperationVariety.BitwiseNot, [
                    OPR('~'), Token(TokenType.Filler)
                ]),
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
                    Token(TokenType.Filler), OPR('='), OPR('='),
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
    OperatorPrecedenceLayer(OperatorOrder.RightToLeft, [
            OperationPrecedenceEntry(OperationVariety.Assignment, [
                    Token(TokenType.Filler), OPR('='), Token(TokenType.Filler)
                ]), // asignment
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
            OperationPrecedenceEntry(OperationVariety.BitwiseNotEq, [
                    Token(TokenType.Filler), OPR('~'), OPR('='),
                    Token(TokenType.Filler)
                ]),
        ])

];
