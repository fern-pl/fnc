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

private Nullable!AstNode handleNodeTreegen(AstNode node, AstNode[] previouslyParsedNodes, AstNode[] protoNodes, ref size_t index)
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
            AstNode[] followingNodes = genTypeTree(protoNodes[index+1 .. $]);
            if (followingNodes.length == 0)
                throw new SyntaxError(
                    "Generic has no nodes", node.tokenBeingHeld);
            if (followingNodes.length != 1)
                throw new SyntaxError(
                    "Generic can't reduce into one node", node.tokenBeingHeld);
            newNode.typeGenericNodeData = TypeGenericNodeData(
                previouslyParsedNodes[$ - 1],
                followingNodes[0]
            );

            index = protoNodes.length;
            previouslyParsedNodes[$ - 1] = newNode;
            return nullable!AstNode(null);
        case TokenType.Operator:
            AstNode newNode = new AstNode;
            AstNode[] followingNodes = genTypeTree(protoNodes[index+1 .. $]);
            // protoNodes[index+1 .. $].writeln;
            newNode.expressionNodeData = ExpressionNodeData(node.tokenBeingHeld.value[0], 0, followingNodes);
            if (newNode.expressionNodeData.opener == '*'){
                newNode.action = AstAction.TypePointer;
            }else if (newNode.expressionNodeData.opener == '&'){
                newNode.action = AstAction.TypeReference;
            }else{
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
        if (maybeNode == null) continue;
        AstNode node = maybeNode;
        if (node.action == AstAction.TypeArray && nodes.length){
            "before:".write;
            nodes.writeln;
            node.firstNodeOperand = nodes[$-1];
            nodes[$-1] = node;
            "after:".write;
            nodes.writeln;
            continue;
        }
        nodes ~= node; 
    }
    // if (nodes.length == 0){
    //     protoNodes.writeln;
    //     assert(0);
    // }
    return nullable!(AstNode[])(nodes);
}

Nullable!AstNode typeFromTokens(Token[] tokens, ref size_t index)
{
    import parsing.treegen.expressionParser : phaseOne;

    // Groups parenthesis and brackets into expression groups
    AstNode[] protoNodes = phaseOne(tokens);
    Nullable!(AstNode[]) maybeArray = genTypeTree(protoNodes);
    AstNode[] array = maybeArray;
    array[0].tree();

    return nullable!AstNode(null);
}

unittest
{
    import parsing.tokenizer.make_tokens;

    size_t index = 0;
    GLOBAL_ERROR_STATE = "custom.thing!( customInts.int[2], ********************float[][][][] ,struct, [asd] )";
    typeFromTokens(GLOBAL_ERROR_STATE.tokenizeText, index);
}
