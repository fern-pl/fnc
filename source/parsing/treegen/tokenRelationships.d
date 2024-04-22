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

// int x, y, z;
const TokenGrepPacket[] DeclarationLine = [
    TokenGrepPacketToken(TokenGrepMethod.NameUnit, []),
    TokenGrepPacketRec(TokenGrepMethod.PossibleCommaSeperated, [
            TokenGrepPacketToken(TokenGrepMethod.MatchesTokenType, [
                    Token(TokenType.Letter, [])
                ])
        ]),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokenType, [
            Token(TokenType.Semicolon, [])
        ])
];
// int x, y, z = [1, 2, 3];
const TokenGrepPacket[] DeclarationAndAssignment = [
    TokenGrepPacketToken(TokenGrepMethod.NameUnit, []),
    TokenGrepPacketRec(TokenGrepMethod.PossibleCommaSeperated, [
            TokenGrepPacketToken(TokenGrepMethod.MatchesTokenType, [
                    Token(TokenType.Letter, [])
                ])
        ]),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokenType, [
            Token(TokenType.Equals, [])
        ]),
    TokenGrepPacketToken(TokenGrepMethod.Glob, []),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokenType, [
            Token(TokenType.Semicolon, [])
        ])
];

bool matchesToken(in TokenGrepPacket[] testWith, Token[] tokens)
{
    size_t index = 0;
    return matchesToken(testWith, tokens, index);
}

import std.stdio;

bool matchesToken(in TokenGrepPacket[] testWith, Token[] tokens, ref size_t index)
{
    foreach (testIndex, packet; testWith)
    {
        switch (packet.method)
        {
        case TokenGrepMethod.NameUnit:
            if (index >= tokens.length)
                return false;
            NameUnit name = genNameUnit(tokens, index);
            if (name.names.length == 0)
                return false;
            break;
        case TokenGrepMethod.MatchesTokenType:
            Nullable!Token potential = tokens.nextNonWhiteToken(index);
            if (potential.ptr == null)
                return false;
            Token token = potential;
            bool doRet = true;

            foreach (const(Token) potentialMatch; packet.tokens)
            {
                if (potentialMatch.tokenVariety == token.tokenVariety)
                    doRet = false;
            }
            if (doRet)
                return false;
            break;
        case TokenGrepMethod.MatchesTokens:
            foreach (const(Token) testToken; packet.tokens)
            {
                Nullable!Token tokenNullable = tokens.nextNonWhiteToken(index);
                if (tokenNullable.ptr == null)
                    return false;
                Token token = tokenNullable;
                if (token.tokenVariety != testToken.tokenVariety || token.value != testToken.value)
                    return false;
            }
            break;
        case TokenGrepMethod.PossibleCommaSeperated:
            if (index >= tokens.length)
                return false;
            Token[][] tstack;
            Token[] currentGroup;
            size_t maxComma = 0;
            foreach (secountIndex, token; tokens[index .. $])
            {
                if (token.tokenVariety == TokenType.Comma)
                {
                    maxComma = secountIndex + 1;
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

        case TokenGrepMethod.Glob:
            if (testWith[testIndex + 1 .. $].matchesToken(tokens[index .. $]))
                return true;
            int braceDeph = 0;
            while (true)
            {
                Nullable!Token tokenNullable = tokens.nextToken(index);
                if (tokenNullable.ptr == null)
                    return false;
                Token token = tokenNullable;
                if (token.tokenVariety == TokenType.OpenBraces)
                    braceDeph += 1;
                else if (token.tokenVariety == TokenType.CloseBraces && braceDeph != 0)
                    braceDeph -= 1;
                else if (braceDeph == 0)
                {
                    size_t index_inc;
                    if (testWith[testIndex + 1 .. $].matchesToken(tokens[index .. $], index_inc))
                    {
                        index += index_inc;
                        return true;
                    }
                }
            }
            break;
        default:
            assert(0, "Not implemented");

        }
    }

    return true;
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
    return Token(o != '=' ? TokenType.Operator : TokenType.Equals, [o]);
}

// https://en.cppreference.com/w/c/language/operator_precedence
// Order of operations in the language. This is broken up
// into layers, the layers are what is done first. And inside
// of each layer they are read left to right, or right to left.

const OperatorPrecedenceLayer[] operatorPrecedence = [
    // OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
    //         // TODO: Unary
    //     ]),
    // OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
    //         OperationPrecedenceEntry(OperationVariety.PreIncrement, [
    //                 OPR('+'), OPR('+'), Token(TokenType.Filler)
    //             ]),
    //         OperationPrecedenceEntry(OperationVariety.PreDecrement, [
    //                 OPR('-'), OPR('-'), Token(TokenType.Filler)
    //             ]),
    //         OperationPrecedenceEntry(OperationVariety.PostIncrement, [
    //                 Token(TokenType.Filler), OPR('+'), OPR('+')
    //             ]),
    //         OperationPrecedenceEntry(OperationVariety.PostDecrement, [
    //                 Token(TokenType.Filler), OPR('-'), OPR('-')
    //             ]),

    //         OperationPrecedenceEntry(OperationVariety.LogicalNot, [
    //                 OPR('!'), Token(TokenType.Filler)
    //             ]),
    //         OperationPrecedenceEntry(OperationVariety.BitwiseNot, [
    //                 OPR('~'), Token(TokenType.Filler)
    //             ]),
    //     ]),
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
    // OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
    //         OperationPrecedenceEntry(OperationVariety.BitshiftLeftSigned, [
    //                 Token(TokenType.Filler), OPR('<'), OPR('<'),
    //                 Token(TokenType.Filler)
    //             ]),
    //         OperationPrecedenceEntry(OperationVariety.BitshiftRightSigned, [
    //                 Token(TokenType.Filler), OPR('>'), OPR('>'),
    //                 Token(TokenType.Filler)
    //             ]),
    //     ]),
    // OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
    //         OperationPrecedenceEntry(OperationVariety.LessThanEq, [
    //                 Token(TokenType.Filler), OPR('<'), OPR('='),
    //                 Token(TokenType.Filler)
    //             ]),
    //         OperationPrecedenceEntry(OperationVariety.GreaterThanEq, [
    //                 Token(TokenType.Filler), OPR('>'), OPR('='),
    //                 Token(TokenType.Filler)
    //             ]),
    //         OperationPrecedenceEntry(OperationVariety.LessThan, [
    //                 Token(TokenType.Filler), OPR('<'), Token(TokenType.Filler)
    //             ]),
    //         OperationPrecedenceEntry(OperationVariety.GreaterThan, [
    //                 Token(TokenType.Filler), OPR('>'), Token(TokenType.Filler)
    //             ]),
    //     ]),
    // OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
    //         OperationPrecedenceEntry(OperationVariety.NotEqualTo, [
    //                 Token(TokenType.Filler), OPR('!'), OPR('='),
    //                 Token(TokenType.Filler)
    //             ]),
    //         OperationPrecedenceEntry(OperationVariety.EqualTo, [
    //                 Token(TokenType.Filler), OPR('='), OPR('='),
    //                 Token(TokenType.Filler)
    //             ]),
    //     ]),
    // OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
    //         OperationPrecedenceEntry(OperationVariety.BitwiseAnd, [
    //                 Token(TokenType.Filler), OPR('&'), Token(TokenType.Filler)
    //             ]),
    //     ]),
    // OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
    //         OperationPrecedenceEntry(OperationVariety.BitwiseXor, [
    //                 Token(TokenType.Filler), OPR('^'), Token(TokenType.Filler)
    //             ]),
    //     ]),
    // OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
    //         OperationPrecedenceEntry(OperationVariety.BitwiseOr, [
    //                 Token(TokenType.Filler), OPR('|'), Token(TokenType.Filler)
    //             ]),
    //     ]),
    // OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
    //         OperationPrecedenceEntry(OperationVariety.LogicalAnd, [
    //                 Token(TokenType.Filler), OPR('&'), OPR('&'),
    //                 Token(TokenType.Filler)
    //             ]),
    //     ]),
    // OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
    //         OperationPrecedenceEntry(OperationVariety.LogicalOr, [
    //                 Token(TokenType.Filler), OPR('|'), OPR('|'),
    //                 Token(TokenType.Filler)
    //             ]),
    //     ]),
    // OperatorPrecedenceLayer(OperatorOrder.RightToLeft, [
    //         OperationPrecedenceEntry(OperationVariety.Assignment, [
    //                 Token(TokenType.Filler), OPR('='), Token(TokenType.Filler)
    //             ]), // asignment
    //         OperationPrecedenceEntry(OperationVariety.AddEq, [
    //                 Token(TokenType.Filler), OPR('+'), OPR('='),
    //                 Token(TokenType.Filler)
    //             ]),
    //         OperationPrecedenceEntry(OperationVariety.SubstractEq, [
    //                 Token(TokenType.Filler), OPR('-'), OPR('='),
    //                 Token(TokenType.Filler)
    //             ]),
    //         OperationPrecedenceEntry(OperationVariety.MultiplyEq, [
    //                 Token(TokenType.Filler), OPR('*'), OPR('='),
    //                 Token(TokenType.Filler)
    //             ]),
    //         OperationPrecedenceEntry(OperationVariety.DivideEq, [
    //                 Token(TokenType.Filler), OPR('/'), OPR('='),
    //                 Token(TokenType.Filler)
    //             ]),
    //         OperationPrecedenceEntry(OperationVariety.ModEq, [
    //                 Token(TokenType.Filler), OPR('%'), OPR('='),
    //                 Token(TokenType.Filler)
    //             ]),

    //         OperationPrecedenceEntry(OperationVariety.BitwiseAndEq, [
    //                 Token(TokenType.Filler), OPR('&'), OPR('='),
    //                 Token(TokenType.Filler)
    //             ]),
    //         OperationPrecedenceEntry(OperationVariety.BitwiseXorEq, [
    //                 Token(TokenType.Filler), OPR('^'), OPR('='),
    //                 Token(TokenType.Filler)
    //             ]),
    //         OperationPrecedenceEntry(OperationVariety.BitwiseOrEq, [
    //                 Token(TokenType.Filler), OPR('|'), OPR('='),
    //                 Token(TokenType.Filler)
    //             ]),
    //         OperationPrecedenceEntry(OperationVariety.BitwiseNotEq, [
    //                 Token(TokenType.Filler), OPR('~'), OPR('='),
    //                 Token(TokenType.Filler)
    //             ]),
    //     ])

];
import std.container.array;

private bool testAndJoin(const(OperationPrecedenceEntry) entry, ref Array!AstNode nodes, size_t startIndex)
{
    if (entry.tokens.length > nodes.length)
        return false;
    size_t nodeIndex = startIndex;
    AstNode[] operands;

    for (size_t index = 0; index < entry.tokens.length; index++)
    {
        Nullable!AstNode nodeNullable = nodes.nextNonWhiteNode(nodeIndex);
        if (nodeNullable.ptr == null)
            return false;
        AstNode node = nodeNullable;
        switch (entry.tokens[index].tokenVariety)
        {

        case TokenType.Filler:

            if (node.action == AstAction.TokenHolder || node.action == AstAction.Keyword || node.action == AstAction
                .Scope)
                return false;
            operands ~= node;
            break;
        case TokenType.Operator:
            if (node.action != AstAction.TokenHolder)
                return false;
            Token token = node.tokenBeingHeld;
            if (token.tokenVariety != TokenType.Equals && token.tokenVariety != TokenType.Operator)
                return false;
            if (token.value != entry.tokens[index].value)
                return false;
            break;
        default:
            assert(0);

        }
    }

    AstNode oprNode = new AstNode();
    oprNode.action = AstAction.DoubleArgumentOperation;
    if (operands.length == 0)
        assert(0);
    if (operands.length == 1)
    {
        oprNode.action = AstAction.SingleArgumentOperation;
        oprNode.singleArgumentOperationNodeData = SingleArgumentOperationNodeData(
            entry.operation,
            operands[0],
        );
    }
    if (operands.length == 2)
        oprNode.doubleArgumentOperationNodeData = DoubleArgumentOperationNodeData(
            entry.operation,
            operands[0],
            operands[1]
        );

    nodes[startIndex] = oprNode;
    nodes.linearRemove(nodes[startIndex + 1 .. nodeIndex]);
    return true;
}

// private void merge(const(OperationPrecedenceEntry) entry, ref Array!AstNode nodes, size_t startIndex)
// {
//     AstNode[] nodeData;
//     size_t nodeIndex = startIndex-1;
//     for (size_t index = 0; index < entry.tokens.length; index++)
//     {
//         Nullable!AstNode nodeNullable = nodes.nextNonWhiteNode(nodeIndex);
//         if (nodeNullable.ptr == null) 
//             assert(0, "Unexpected end of array in AST merge");
//         AstNode node = nodeNullable;
//         switch (entry.tokens[index].tokenVariety)
//         {
//             case TokenType.Filler:
//                 nodeData ~= node;
//                 break;
//             case TokenType.Operator:
//                 break;
//             default:
//                 assert(0);
//         }
//     }
//     AstNode oprNode = new AstNode();
//     oprNode.action = AstAction.DoubleArgumentOperation;
//     if (nodeData.length == 0)
//         assert(0);
//     if (nodeData.length == 1)
//     {
//         oprNode.action = AstAction.SingleArgumentOperation;
//         oprNode.singleArgumentOperationNodeData = SingleArgumentOperationNodeData(
//             entry.operation,
//             nodeData[0],
//         );
//     }
//     if (nodeData.length == 2)
//         oprNode.doubleArgumentOperationNodeData = DoubleArgumentOperationNodeData(
//             entry.operation,
//             nodeData[0],
//             nodeData[1]
//         );

//     nodes[startIndex] = oprNode;
//     nodes.linearRemove(nodes[startIndex + 1 .. nodeIndex-1]);

// }

void scanAndMergeOperators(Array!AstNode nodes)
{
    // OperatorOrder order;
    auto data = nodes.data;
    static foreach (layer; operatorPrecedence)
    {
        static if (layer.order == OperatorOrder.LeftToRight)
        {
            for (size_t index = 0; index < nodes.length; index++)
            {
                foreach (entry; layer.layer)
                {
                    if (entry.testAndJoin(nodes, index))
                    {
                        index--;
                        continue;
                    }

                }

            }
        }
        // static if (layer.order == OperatorOrder.RightToLeft){
        //     for (size_t index = nodes.length; index != -1; index--){
        //         foreach (entry; layer.layer)
        //         {
        //             entry.testAndJoin(nodes, index);
        //         }
        //     }
        // }
    }
}
