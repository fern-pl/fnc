module fnc.treegen.type_parser;

import fnc.tokenizer.tokens;
import fnc.treegen.ast_types;

import tern.typecons.common : Nullable, nullable;
import fnc.errors;

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
            newNode.isIntegerLiteral = false;
            foreach (i, subArray; splitNodesAtCommas(node.expressionNodeData.components))
            {
                newNode.commaSeperatedNodes ~= genTypeTree(subArray);
                if (i != 0)
                    newNode.isIntegerLiteral = false;
                else if (i == 0 && subArray.length && subArray[0].action == AstAction.LiteralUnit)
                    newNode.isIntegerLiteral = true;
            }
            return nullable!AstNode(newNode);
        case AstAction.TokenHolder:
            if (node.tokenBeingHeld.tokenVariety == TokenType.WhiteSpace)
                return nullable!AstNode(null);
            switch (node.tokenBeingHeld.tokenVariety)
            {
                case TokenType.QuestionMark:
                    if (previouslyParsedNodes.length == 0)
                        throw new SyntaxError(
                            "Can't determine voidable and it's connection to a type", node);
                    
                    AstNode newNode = new AstNode;
                    newNode.action = AstAction.TypeVoidable;
                    newNode.voidableType = previouslyParsedNodes[$-1];
                    previouslyParsedNodes[$-1] = newNode;
                    return nullable!AstNode(null);

                case TokenType.ExclamationMark:
                    if (previouslyParsedNodes.length == 0)
                        throw new SyntaxError(
                            "Can't determine template and it's connection to a type", node);
                    AstNode newNode = new AstNode;
                    newNode.action = AstAction.TypeGeneric;
                    AstNode[] followingNodes = genTypeTree(protoNodes[index + 1 .. $]);
                    if (followingNodes.length == 0)
                        throw new SyntaxError(
                            "Generic has no nodes", node);
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

                    newNode.expressionNodeData = ExpressionNodeData(node.tokenBeingHeld.value[0], 0, followingNodes);
                    if (newNode.expressionNodeData.opener == '*')
                        newNode.action = AstAction.TypePointer;
                    else if (newNode.expressionNodeData.opener == '&')
                        newNode.action = AstAction.TypeReference;
                    else
                        return nullable!AstNode(null);
                        // throw new SyntaxError(
                        //     "Unknown type operator", node.tokenBeingHeld);


                    index = protoNodes.length;
                    return nullable!AstNode(newNode);
                case TokenType.Semicolon:
                    return nullable!AstNode(null);
                default:
                    node.tokenBeingHeld.writeln;
                    assert(0);
            }
            node.tokenBeingHeld.writeln;
            return nullable!AstNode(null);

        case AstAction.LiteralUnit:
        case AstAction.NamedUnit:
            return nullable!AstNode(node);
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
            case TokenType.QuestionMark:
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
    import fnc.treegen.expression_parser : phaseOne;

    size_t length = tokens.prematureTypeLength(index);
    if (length == 0)
        return nullable!AstNode(null);

    // Groups parenthesis and brackets into expression groups
    AstNode[] protoNodes = phaseOne(tokens[index .. index += length]);
    Nullable!(AstNode[]) maybeArray = genTypeTree(protoNodes);
    if (maybeArray == null)
        return nullable!AstNode(null);
    AstNode[] array = maybeArray;
    if (array.length == 0)
        return nullable!AstNode(null);
    if (array.length != 1)
        return nullable!AstNode(null);

    return nullable!AstNode(array[0]);
}
