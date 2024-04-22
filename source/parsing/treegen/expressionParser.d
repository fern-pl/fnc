module parsing.treegen.expressionParser;

import tern.typecons.common : Nullable, nullable;
import parsing.treegen.astTypes;
import parsing.tokenizer.tokens;
import parsing.treegen.tokenRelationships;
import parsing.treegen.treeGenUtils;
import errors;
import std.stdio;
import std.container.array;

// Group letters.letters.letters into NamedUnit s
// Group Parenthesis into AstNode.Expression s to be parsed speratly
public AstNode[] phaseOne(Token[] tokens)
{
    AstNode[] ret;
    AstNode[] parenthesisStack;
    bool isLastTokenWhite = false;
    for (size_t index = 0; index < tokens.length; index++)
    {
        Token token = tokens[index];
        if (token.tokenVariety == TokenType.OpenBraces)
        {
            AstNode newExpression = new AstNode();
            newExpression.action = AstAction.Expression;
            newExpression.expressionNodeData = ExpressionNodeData(
                token.value[0],
                braceOpenToBraceClose[token.value[0]],
                []
            );
            parenthesisStack ~= newExpression;
            continue;
        }
        if (token.tokenVariety == TokenType.CloseBraces)
        {

            if (parenthesisStack.length == 0)
                throw new SyntaxError("Parenthesis closed but never opened");

            AstNode node = parenthesisStack[$ - 1];

            if (node.expressionNodeData.closer != token.value[0])
                throw new SyntaxError("Parenthesis not closed with correct token");

            parenthesisStack.length--;

            if (parenthesisStack.length == 0)
                ret ~= node;
            else
                parenthesisStack[$ - 1].expressionNodeData.components ~= node;
            continue;
        }
        AstNode tokenToBeParsedLater = new AstNode();
        if (token.tokenVariety == TokenType.Letter)
        {
            tokenToBeParsedLater.action = AstAction.NamedUnit;
            size_t old_index = index;
            tokenToBeParsedLater.namedUnit = tokens.genNameUnit(index);
            if (old_index != index)
                index--;
        }
        else if (token.tokenVariety == TokenType.Number)
        {
            tokenToBeParsedLater.action = AstAction.LiteralUnit;
            tokenToBeParsedLater.literalUnitCompenents = [token];
        }
        else if (token.tokenVariety != TokenType.Comment)
        {
            bool isWhite = token.tokenVariety == TokenType.WhiteSpace;
            if (isWhite && isLastTokenWhite)
                continue;
            isLastTokenWhite = isWhite;

            tokenToBeParsedLater.action = AstAction.TokenHolder;
            tokenToBeParsedLater.tokenBeingHeld = token;
        }

        if (parenthesisStack.length == 0)
            ret ~= tokenToBeParsedLater;
        else
            parenthesisStack[$ - 1].expressionNodeData.components ~= tokenToBeParsedLater;
    }
    return ret;
}

// Handle function calls and operators
public void phaseTwo(Array!AstNode nodes)
{
    for (size_t index = 0; index < nodes.length; index++)
    {
        AstNode node = nodes[index];
        if (node.action == AstAction.NamedUnit && index + 1 < nodes.length && nodes[index + 1].action == AstAction
            .Expression)
        {
            AstNode functionCall = new AstNode();
            AstNode args = nodes[index + 1];

            Array!AstNode components;
            components ~= args.expressionNodeData.components;
            phaseTwo(components);
            scanAndMergeOperators(components);
            args.expressionNodeData.components.length = components.data.length;
            args.expressionNodeData.components[0 .. $] = components.data[0 .. $];

            functionCall.action = AstAction.Call;
            functionCall.callNodeData = CallNodeData(
                node.namedUnit,
                args
            );
            nodes[index] = functionCall;
            nodes.linearRemove(nodes[index + 1 .. index + 2]);
        }
        else if (node.action == AstAction.Expression)
        {
            Array!AstNode components;
            components ~= node.expressionNodeData.components;
            phaseTwo(components);
            scanAndMergeOperators(components);
            node.expressionNodeData.components.length = components.data.length;
            node.expressionNodeData.components[0 .. $] = components.data[0 .. $];
        }
    }
}

Array!AstNode expressionNodeFromTokens(Token[] tokens)
{
    AstNode[] phaseOneNodes = phaseOne(tokens);
    Array!AstNode nodes;
    nodes ~= phaseOneNodes;
    phaseTwo(nodes);
    scanAndMergeOperators(nodes);
    return nodes;
}
