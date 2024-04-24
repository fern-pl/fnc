module parsing.treegen.tokenRelationships;
import parsing.tokenizer.tokens;
import parsing.treegen.astTypes;
import parsing.treegen.treeGenUtils;
import tern.typecons.common : Nullable, nullable;

enum TokenGrepMethod
{
    Glob,
    Whitespace,
    MatchesTokens,
    MatchesTokenType,
    Scope,
    NameUnit,
    PossibleCommaSeperated,
    Letter
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

struct TokenGrepResult
{
    TokenGrepMethod method;
    union
    {
        TokenGrepResult[] commaSeperated;
        Token[] tokens; // Glob
        NameUnit name;

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

// The following are definitions of different type of
// structures found throughout the language. They are defined
// in a modular way, and it is surprisingly efficient.
// This is all unmantainable as FUCK, and confusing to read.
// But this works, and is quite convinent. 

// TODO: Refactor ALL of this:

const size_t DECLARATION_TYPE = 0;
const size_t DECLARATION_VARS = 1;
// int x, y, z;
const TokenGrepPacket[] DeclarationLine = [
    TokenGrepPacketToken(TokenGrepMethod.NameUnit, []),
    TokenGrepPacketRec(TokenGrepMethod.PossibleCommaSeperated, [
            TokenGrepPacketToken(TokenGrepMethod.NameUnit, []),
        ]),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokenType, [
            Token(TokenType.Semicolon, [])
        ])
];
const size_t DECLARATION_EXPRESSION = 3;

// int x, y, z = [1, 2, 3];
const TokenGrepPacket[] DeclarationAndAssignment = [
    TokenGrepPacketToken(TokenGrepMethod.NameUnit, []),
    TokenGrepPacketRec(TokenGrepMethod.PossibleCommaSeperated, [
            TokenGrepPacketToken(TokenGrepMethod.NameUnit, []),
        ]),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokenType, [
            Token(TokenType.Equals, [])
        ]),
    TokenGrepPacketToken(TokenGrepMethod.Glob, []),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokenType, [
            Token(TokenType.Semicolon, [])
        ])
];

const size_t IMPORT_PACKAGE_NAME = 0;
// import foo.bar
const TokenGrepPacket[] TotalImport = [
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.Letter, "import".makeUnicodeString)
        ]),
    TokenGrepPacketToken(TokenGrepMethod.NameUnit, []),
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
    TokenGrepPacketToken(TokenGrepMethod.NameUnit, []),

    TokenGrepPacketToken(TokenGrepMethod.MatchesTokens, [
            Token(TokenType.Colon, ":".makeUnicodeString)
        ]),

    TokenGrepPacketRec(TokenGrepMethod.PossibleCommaSeperated, [
            TokenGrepPacketToken(TokenGrepMethod.NameUnit, []),
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
    TokenGrepPacketToken(TokenGrepMethod.NameUnit, []),
    TokenGrepPacketToken(TokenGrepMethod.MatchesTokenType, [
            Token(TokenType.Semicolon, [])
        ])
];

Nullable!(TokenGrepResult[]) matchesToken(in TokenGrepPacket[] testWith, Token[] tokens)
{
    size_t index = 0;
    return matchesToken(testWith, tokens, index);
}
alias tokenGrepBox = Nullable!(TokenGrepResult[]);
Nullable!(TokenGrepResult[]) matchesToken(in TokenGrepPacket[] testWith, Token[] tokens, ref size_t index)
{
    TokenGrepResult[] returnVal;
    foreach (testIndex, packet; testWith)
    {
        switch (packet.method)
        {
        case TokenGrepMethod.NameUnit:
            if (index >= tokens.length)
                return tokenGrepBox(null);
            NameUnit name = genNameUnit(tokens, index);
            if (name.names.length == 0)
                return tokenGrepBox(null);
            TokenGrepResult result;
            result.method = TokenGrepMethod.NameUnit;
            result.name = name;
            returnVal ~= result;
            break;
        case TokenGrepMethod.MatchesTokenType:
            Nullable!Token potential = tokens.nextNonWhiteToken(index);
            if (potential.ptr == null)
                return tokenGrepBox(null);
            Token token = potential;
            bool doRet = true;
            Token[] found;

            foreach (const(Token) potentialMatch; packet.tokens)
            {
                if (potentialMatch.tokenVariety == token.tokenVariety)
                    doRet = false;
                found ~= token;
            }
            TokenGrepResult res;
            res.method = TokenGrepMethod.Letter;
            res.tokens = found;
            returnVal ~= res;
            if (doRet)
                return tokenGrepBox(null);
            break;
        case TokenGrepMethod.MatchesTokens:
            foreach (const(Token) testToken; packet.tokens)
            {
                Nullable!Token tokenNullable = tokens.nextNonWhiteToken(index);
                if (tokenNullable.ptr == null)
                    return tokenGrepBox(null);
                Token token = tokenNullable;
                if (token.tokenVariety != testToken.tokenVariety || token.value != testToken.value)
                    return tokenGrepBox(null);
            }
            break;
        case TokenGrepMethod.PossibleCommaSeperated:
            if (index >= tokens.length)
                return tokenGrepBox(null);

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
            TokenGrepResult commaSeperatedGroup;
            commaSeperatedGroup.method = TokenGrepMethod.PossibleCommaSeperated;
            commaSeperatedGroup.commaSeperated = new TokenGrepResult[0];
            foreach (Token[] tokenGroup; tstack)
            {
                searchExtent = 0;
                auto res = matchesToken(packet.packets, tokenGroup, searchExtent);
                if (!res.ptr)
                    return tokenGrepBox(null);
                commaSeperatedGroup.commaSeperated ~= res.value;
            }
            returnVal ~= commaSeperatedGroup;
            index += maxComma + searchExtent;
            break;

        case TokenGrepMethod.Glob:
            auto firstGlob = testWith[testIndex + 1 .. $].matchesToken(tokens[index .. $]);
            TokenGrepResult globResult;
            globResult.method = TokenGrepMethod.Glob;
            globResult.tokens = [];
            
            if (firstGlob.ptr)
                return  tokenGrepBox(returnVal ~ globResult ~ firstGlob.value);
            
            
            int braceDeph = 0;
            size_t startingIndex = index;
            auto grepMatchGroup = testWith[testIndex + 1 .. $];
            while (true)
            {
                Nullable!Token tokenNullable = tokens.nextToken(index);
                if (tokenNullable.ptr == null)
                    return tokenGrepBox(null);
                Token token = tokenNullable;
                globResult.tokens ~= token;
            
                if (token.tokenVariety == TokenType.OpenBraces)
                    braceDeph += 1;
                else if (token.tokenVariety == TokenType.CloseBraces && braceDeph != 0)
                    braceDeph -= 1;
                else if (braceDeph == 0)
                {
                    size_t index_inc;
                    auto res = grepMatchGroup.matchesToken(tokens[index .. $], index_inc);
                    if (res.ptr)
                    {
 
                        globResult.tokens = tokens[startingIndex .. index];
                        
                        index += index_inc;
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

NameUnit[] collectNameUnits(TokenGrepResult[] greps){
    NameUnit[] ret;
    foreach (TokenGrepResult grepResult ; greps){
        assert(grepResult.method == TokenGrepMethod.NameUnit);
        ret ~= grepResult.name;
    }
    return ret;
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
                    Token(TokenType.Filler), OPR('>'), OPR('>'), OPR('<'),
                    OPR('='),
                    Token(TokenType.Filler)
                ]),
            OperationPrecedenceEntry(OperationVariety.Assignment, [
                    Token(TokenType.Filler), OPR('='),
                    Token(TokenType.Filler)
                ])
        ])

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
        case TokenType.Equals:
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
        static if (layer.order == OperatorOrder.RightToLeft)
        {
            for (size_t index = nodes.length; index != -1; index--)
            {
                foreach (entry; layer.layer)
                {
                    if (entry.testAndJoin(nodes, index))
                    {
                        index++;
                        continue;
                    }
                }
            }
        }
    }
}
