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
// Group Parenthesis and indexing into AstNode.Expression s to be parsed speratly
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
            if (token.value == "(" || token.value == "{")
                newExpression.action = AstAction.Expression;
            else if (token.value == "[")
                newExpression.action = AstAction.ArrayGrouping;
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
                throw new SyntaxError("Group token(" ~ cast(
                        char) token.value[0] ~ ") closed but never opened", token);

            AstNode node = parenthesisStack[$ - 1];

            if (node.expressionNodeData.closer != token.value[0])
                throw new SyntaxError("Group token(" ~ cast(
                        char) token.value[0] ~ ") not closed with correct token", token);

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
            tokenToBeParsedLater.namedUnit = tokens.genNamedUnit(index);
            if (old_index != index)
                index--;
        }
        else if (token.tokenVariety == TokenType.Number || token.tokenVariety == TokenType
            .Quotation)
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

private AstNode[][] splitNodesAtComma(AstNode[] inputNodes)
{
    AstNode[][] nodes;
    AstNode[] current;
    foreach (AstNode node; inputNodes)
    {
        if (node.action == AstAction.TokenHolder
            && node.tokenBeingHeld.tokenVariety == TokenType.Comma)
        {
            nodes ~= current;
            current = new AstNode[0];
            continue;
        }
        current ~= node;
    }
    nodes ~= current;
    return nodes;
}
// Handle function calls and operators
public void phaseTwo(ref Array!AstNode nodes)
{
    AstNode[] nonWhiteStack;

    Array!AstNode newNodesArray;

    scope (exit)
        nodes = newNodesArray;

    for (size_t index = 0; index < nodes.length; index++)
    {
        AstNode node = nodes[index];

        if (node.action == AstAction.Expression
            && nonWhiteStack.length
            && nonWhiteStack[$ - 1].action.isCallable
            )
        {
            AstNode functionCall = new AstNode();
            scope (exit)
                newNodesArray[$ - 1] = functionCall;
            scope (exit)
                nonWhiteStack ~= functionCall;

            functionCall.action = AstAction.Call;

            CallNodeData callNodeData;

            scope (exit)
                functionCall.callNodeData = callNodeData;

            callNodeData.func = nonWhiteStack[$ - 1];
            callNodeData.args = new FunctionCallArgument[0];

            Array!AstNode components;
            foreach (AstNode[] argumentNodeBatch; splitNodesAtComma(
                    node.expressionNodeData.components))
            {
                components.clear();
                components ~= argumentNodeBatch;
                Token firstToken = components[0].tokenBeingHeld;
                phaseTwo(components);
                scanAndMergeOperators(components);
                components.removeAllWhitespace();

                if (components.length != 1 && components.length != 3)
                    throw new SyntaxError("Function argument parsing error (node reduction)", firstToken);
                FunctionCallArgument component;
                
                scope (exit) callNodeData.args ~= component;
                
                if (components.length == 1)
                {
                    component.source = components[0];
                    continue;
                }
                components.writeln;
                if (components[1].action != AstAction.TokenHolder)
                    throw new SyntaxError("Function argument parsing error (Must include colon for named arguments)", firstToken);
                if (components[1].tokenBeingHeld.tokenVariety != TokenType.Colon)
                    throw new SyntaxError("Function argument parsing error (Must include colon for named arguments)", components[1]
                            .tokenBeingHeld);
                if (components[0].action != AstAction.NamedUnit)
                    throw new SyntaxError("Function argument parsing error (Named argument name can't be determined)", firstToken);
                component.specifiedName = Nullable!(dchar[])(components[0].namedUnit.names[0]);
                component.source = components[2];
            }

        }
        else
        {
            newNodesArray ~= node;
            nonWhiteStack ~= node;
        }

        //     if (node.action == AstAction.Expression && lastNonWhite != null )
        //     {
        //         AstNode functionCall = new AstNode();
        //         AstNode args = nodes[index + 1];

        //         Array!AstNode components;
        //         components ~= args.expressionNodeData.components;
        // phaseTwo(components);
        // scanAndMergeOperators(components);
        //         args.expressionNodeData.components.length = components.data.length;
        //         args.expressionNodeData.components[0 .. $] = components.data[0 .. $];

        //         functionCall.action = AstAction.Call;
        //         functionCall.callNodeData = CallNodeData(
        //             node.namedUnit,
        //             args
        //         );
        //         nodes[index] = functionCall;
        //         nodes.linearRemove(nodes[index + 1 .. index + 2]);
        //     }
        //     else if (node.action.isExpressionLike)
        //     {
        //         Array!AstNode components;
        //         components ~= node.expressionNodeData.components;
        //         phaseTwo(components);
        //         scanAndMergeOperators(components);
        //         node.expressionNodeData.components.length = components.data.length;
        //         node.expressionNodeData.components[0 .. $] = components.data[0 .. $];
        //     }
    }
}

void trimAstNodes(ref Array!AstNode nodes)
{
    // Remove starting whitespace
    while (nodes.length && nodes[0].isWhite)
        nodes.linearRemove(nodes[0 .. 1]);

    // Remove ending whitespace
    while (nodes.length && nodes[$ - 1].isWhite)
        nodes.linearRemove(nodes[$ - 1 .. $]);
}

void removeAllWhitespace(ref Array!AstNode nodes)
{
    Array!AstNode newNodes;
    scope (exit)
        nodes = newNodes;
    foreach (AstNode node; nodes)
    {
        if (!node.isWhite)
            newNodes ~= node;
    }
}

Array!AstNode expressionNodeFromTokens(Token[] tokens)
{
    AstNode[] phaseOneNodes = phaseOne(tokens);
    Array!AstNode nodes;
    nodes ~= phaseOneNodes;
    phaseTwo(nodes);
    scanAndMergeOperators(nodes);
    nodes.trimAstNodes();
    return nodes;
}

size_t findNearestSemiColon(Token[] tokens, size_t index)
{
    int parCount = 0;
    while (index < tokens.length)
    {
        Token token = tokens[index];
        if (token.tokenVariety == TokenType.OpenBraces)
            parCount++;
        if (token.tokenVariety == TokenType.CloseBraces)
            parCount--;
        if (token.tokenVariety == TokenType.Semicolon && parCount == 0)
            return index;
        index++;
    }
    return -1;
}
