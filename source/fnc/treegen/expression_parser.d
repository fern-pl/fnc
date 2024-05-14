module fnc.treegen.expression_parser;

import tern.typecons.common : Nullable, nullable;
import fnc.treegen.ast_types;
import fnc.tokenizer.tokens;
import fnc.treegen.relationships;
import fnc.treegen.utils;
import fnc.errors;
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
// Handle function calls, arrays, Generics, and operators
public void phaseTwo(ref Array!AstNode nodes)
{
    size_t[] nonWhiteIndexStack;

    Array!AstNode newNodesArray;

    AstNode lastNonWhite;
    alias popNonWhiteNode() = {
        size_t lindex = nonWhiteIndexStack[$ - 1];
        nonWhiteIndexStack.length--;

        lastNonWhite = newNodesArray[lindex];
        newNodesArray.linearRemove(newNodesArray[lindex .. $]);
    };
    scanAndMergeAttrOp(nodes);
    // TODO: FIX THIS SHIT
    for (size_t index = 0; index < nodes.length; index++)
    {
        AstNode node = nodes[index];
        if (node.action != AstAction.TokenHolder
            || node.tokenBeingHeld.tokenVariety != TokenType.ExclamationMark)
        {
            GENRIC_ADD:
            newNodesArray ~= node;
            if (!node.isWhite)
                nonWhiteIndexStack ~= newNodesArray.length - 1;
            continue;
        }
        if (!nonWhiteIndexStack.length)
            throw new SyntaxError("Can't result thing generic of.", node.tokenBeingHeld);
        popNonWhiteNode();
        index++;
        Nullable!AstNode maybeNode = nodes.nextNonWhiteNode(index);
        index--;
        if (maybeNode == null)
            throw new SyntaxError("Trailing exclamation mark is an invalid generic.", node.tokenBeingHeld);
        AstNode generic = new AstNode;
        generic.action = AstAction.GenericOf;
        generic.genericNodeData.symbolUsedAsGeneric = lastNonWhite;
        generic.genericNodeData.genericData = maybeNode;
        node = generic;
        goto GENRIC_ADD;
    }
    nodes = newNodesArray;
    Array!AstNode temp;
    newNodesArray = temp;
    nonWhiteIndexStack = new size_t[0];
    // Handle functions, arrays, and indexing
    for (size_t index = 0; index < nodes.length; index++)
    {
        AstNode node = nodes[index];
        if (node.action == AstAction.Expression
            && nonWhiteIndexStack.length
            && newNodesArray[nonWhiteIndexStack[$ - 1]].action.isCallable
            )
        {

            popNonWhiteNode();
            AstNode functionCall = new AstNode();
            functionCall.action = AstAction.Call;

            CallNodeData callNodeData;

            scope (exit)
                functionCall.callNodeData = callNodeData;

            callNodeData.func = lastNonWhite;
            callNodeData.args = new FunctionCallArgument[0];

            Array!AstNode components;
            foreach (AstNode[] argumentNodeBatch; splitNodesAtComma(
                    node.expressionNodeData.components))
            {
                if (!argumentNodeBatch.length)
                    continue;
                components.clear();
                components ~= argumentNodeBatch;
                Token firstToken = components[0].tokenBeingHeld;
                phaseTwo(components);
                scanAndMergeOperators(components);
                components.removeAllWhitespace();

                if (components.length != 1 && components.length != 3)
                    throw new SyntaxError("Function argument parsing error (node reduction)", firstToken);
                FunctionCallArgument component;

                scope (exit)
                    callNodeData.args ~= component;

                if (components.length == 1)
                {
                    component.source = components[0];
                    continue;
                }
                // components.writeln;
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
            newNodesArray ~= functionCall;
            nonWhiteIndexStack ~= newNodesArray.length - 1;

        }
        else if (node.action == AstAction.ArrayGrouping
            && nonWhiteIndexStack.length)
        {
            popNonWhiteNode();
            AstNode indexNode = new AstNode;

            indexNode.action = AstAction.IndexInto;
            indexNode.indexIntoNodeData.indexInto = lastNonWhite;

            Array!AstNode components;
            components ~= node.expressionNodeData.components;
            phaseTwo(components);
            scanAndMergeOperators(components);
            components.trimAstNodes();

            assert(components.length == 1, "Can't have empty [] while indexing");

            indexNode.indexIntoNodeData.index = components[0];

            newNodesArray ~= indexNode;
            nonWhiteIndexStack ~= newNodesArray.length - 1;

        }
        else if (node.action.isExpressionLike)
        {
            Array!AstNode components;
            components ~= node.expressionNodeData.components;
            phaseTwo(components);
            scanAndMergeOperators(components);
            assert(components.length == 1, "Expression is invalid");
            node = components[0];

            goto ADD_NODE;
        }
        else
        {
        ADD_NODE:
            newNodesArray ~= node;
            if (!node.isWhite)
                nonWhiteIndexStack ~= newNodesArray.length - 1;

        }
    }
    nodes = newNodesArray;
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

size_t findNearestSemiColon(Token[] tokens, size_t index, TokenType stopToken = TokenType.Semicolon)
{
    int parCount = 0;
    while (index < tokens.length)
    {
        Token token = tokens[index];
        if (token.tokenVariety == TokenType.OpenBraces)
            parCount++;
        if (token.tokenVariety == TokenType.CloseBraces)
            parCount--;
        if (token.tokenVariety == stopToken && parCount == 0)
            return index;
        index++;
    }
    return -1;
}

// Gets the length of a single "group" of tokens, that can be parsed into a single ASTnode
size_t prematureSingleTokenGroupLength(Token[] tokens, size_t index)
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
            case TokenType.Comment:
            case TokenType.WhiteSpace:
                break;
            case TokenType.Operator:
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