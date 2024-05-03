module parsing.treegen.typeParser;

import parsing.tokenizer.tokens;
import parsing.treegen.astTypes;

import tern.typecons.common : Nullable, nullable;
import errors;

import std.array;
import std.stdio;

AstNode[][] splitNodesAtCommas(AstNode[] protoNodes)
{
    AstNode[][] ret;
    AstNode[] current;
    foreach (AstNode node; protoNodes)
    {
        if (node.action == AstAction.TokenHolder && node.tokenBeingHeld.tokenVariety == TokenType
            .Comma)
        {
            ret ~= current;
            current = new AstNode[0];
            continue;
        }
        current ~= node;
    }
    ret ~= current;
    return ret;
}

import std.container.array;

private Nullable!AstNode handleNodeTreegen(AstNode node, ref AstNode[] previouslyParsedNodes, AstNode[] protoNodes, ref size_t index)
{
    switch (node.action)
    {
    case AstAction.Expression:
    case AstAction.ArrayGrouping:
        AstNode newNode = new AstNode;
        newNode.action = node.action == AstAction.Expression ? AstAction.TypeTuple
            : AstAction.TypeArray;
        newNode.commaSeperatedNodes = new AstNode[][0];
        newNode.firstNodeOperand = null;
        foreach (subArray; splitNodesAtCommas(node.expressionNodeData.components))
            newNode.commaSeperatedNodes ~= genTypeTree(subArray);
        return nullable!AstNode(newNode);
    case AstAction.TokenHolder:
        if (node.tokenBeingHeld.tokenVariety == TokenType.WhiteSpace)
            return nullable!AstNode(null);
        switch (node.tokenBeingHeld.tokenVariety)
        {
        case TokenType.ExclamationMark:
            if (previouslyParsedNodes.length == 0)
                throw new SyntaxError(
                    "Can't result template and it's connection to a type", node.tokenBeingHeld);
            AstNode newNode = new AstNode;
            newNode.action = AstAction.TypeGeneric;
            AstNode[] followingNodes = genTypeTree(protoNodes[index + 1 .. $]);
            if (followingNodes.length == 0)
                throw new SyntaxError(
                    "Generic has no nodes", node.tokenBeingHeld);
            newNode.typeGenericNodeData = TypeGenericNodeData(
                previouslyParsedNodes[$ - 1],
                followingNodes[0]
            );

            index = protoNodes.length;
            previouslyParsedNodes[$ - 1] = newNode;

            if (followingNodes.length != 1)
                previouslyParsedNodes ~= followingNodes[1 .. $];

            return nullable!AstNode(null);
        case TokenType.Operator:
            AstNode newNode = new AstNode;
            AstNode[] followingNodes = genTypeTree(protoNodes[index + 1 .. $]);
            // protoNodes[index+1 .. $].writeln;
            newNode.expressionNodeData = ExpressionNodeData(node.tokenBeingHeld.value[0], 0, followingNodes);
            if (newNode.expressionNodeData.opener == '*')
            {
                newNode.action = AstAction.TypePointer;
            }
            else if (newNode.expressionNodeData.opener == '&')
            {
                newNode.action = AstAction.TypeReference;
            }
            else
            {
                throw new SyntaxError(
                    "Unknown type operator", node.tokenBeingHeld);
            }

            index = protoNodes.length;
            return nullable!AstNode(newNode);
        default:
            node.tokenBeingHeld.writeln;
            assert(0);
        }
        node.tokenBeingHeld.writeln;
        return nullable!AstNode(null);

    case AstAction.LiteralUnit:
    // case AstAction.NamedUnit:
    //     return nullable!AstNode(node);
    default:
        node.action.writeln;
        assert(0);
    }
}

Nullable!(AstNode[]) genTypeTree(AstNode[] protoNodes)
{
    AstNode[] nodes;
    for (size_t index = 0; index < protoNodes.length; index++)
    {
        Nullable!AstNode maybeNode = handleNodeTreegen(protoNodes[index], nodes, protoNodes, index);
        if (maybeNode == null)
            continue;
        AstNode node = maybeNode;
        if (node.action == AstAction.TypeArray && nodes.length)
        {
            node.firstNodeOperand = nodes[$ - 1];
            nodes[$ - 1] = node;
            continue;
        }
        nodes ~= node;
    }
    return nullable!(AstNode[])(nodes);
}

size_t prematureTypeLength(Token[] tokens, size_t index)
{
    size_t originalIndex = index;
    int braceCount = 0;
    bool wasLastFinalToken = false;
    while (1)
    {
        Nullable!Token ntoken = tokens.nextNonWhiteToken(index);
        if (ntoken == null)
            break;
        Token token = ntoken;
        if (token.tokenVariety == TokenType.OpenBraces)
        {
            wasLastFinalToken = true;
            braceCount++;
            continue;
        }
        else if (token.tokenVariety == TokenType.CloseBraces)
        {
            braceCount--;
            if (braceCount == -1)
                break;
            continue;
        }

        if (braceCount > 0)
            continue;

        switch (token.tokenVariety)
        {
        case TokenType.Operator:
        case TokenType.Comment:
        case TokenType.WhiteSpace:
            break;
        case TokenType.Period:
        case TokenType.ExclamationMark:
            wasLastFinalToken = false;
            break;
        default:
            if (wasLastFinalToken)
                return index - originalIndex - 1;
            wasLastFinalToken = true;
            break;
        }

    }
    return index - originalIndex - 1;
}

Nullable!AstNode typeFromTokens(Token[] tokens, ref size_t index)
{
    import parsing.treegen.expressionParser : phaseOne;

    size_t length = tokens.prematureTypeLength(index);
    if (length == 0)
        return nullable!AstNode(null);
    

    // Groups parenthesis and brackets into expression groups
    Token firstToken = tokens[index];
    AstNode[] protoNodes = phaseOne(tokens[index..index+=length]);
    Nullable!(AstNode[]) maybeArray = genTypeTree(protoNodes);
    if (maybeArray == null)
        return nullable!AstNode(null);
    AstNode[] array = maybeArray;
    if (array.length == 0)
        return nullable!AstNode(null);
    if (array.length != 1)
        throw new SyntaxError("Can't reduce type into a single AST node", firstToken);

    return nullable!AstNode(array[0]);
}
