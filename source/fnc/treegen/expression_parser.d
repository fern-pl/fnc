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
public AstNode[] phaseOne(Token[] tokens) {
    AstNode[] ret;
    AstNode[] parenthesisStack;
    bool isLastTokenWhite = false;
    for (size_t index = 0; index < tokens.length; index++) {
        Token token = tokens[index];
        if (token.tokenVariety == TokenType.OpenBraces) {
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
        if (token.tokenVariety == TokenType.CloseBraces) {

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
        if (token.tokenVariety == TokenType.Letter) {
            tokenToBeParsedLater.action = AstAction.NamedUnit;
            size_t old_index = index;
            tokenToBeParsedLater.namedUnit = tokens.genNamedUnit(index);
            if (old_index != index)
                index--;
        }
        else if (token.tokenVariety == TokenType.Number || token.tokenVariety == TokenType
            .Quotation) {
            tokenToBeParsedLater.action = AstAction.LiteralUnit;
            tokenToBeParsedLater.literalUnitCompenents = [token];
        }
        else if (token.tokenVariety != TokenType.Comment) {
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

private AstNode[][] splitNodesAtComma(AstNode[] inputNodes) {
    AstNode[][] nodes;
    AstNode[] current;
    foreach (AstNode node; inputNodes) {
        if (node.action == AstAction.TokenHolder
            && node.tokenBeingHeld.tokenVariety == TokenType.Comma) {
            nodes ~= current;
            current = new AstNode[0];
            continue;
        }
        current ~= node;
    }
    nodes ~= current;
    return nodes;
}

import std.conv : to;

NameValuePair[] genCommaSeperatedContents(AstNode expressionLike) {
    NameValuePair[] ret;
    foreach (i, argumentNodeBatch; splitNodesAtComma(
            expressionLike.expressionNodeData.components)) {
        if (!argumentNodeBatch.length)
            continue;

        Array!AstNode components;
        components ~= argumentNodeBatch;
        Token firstToken = components[0].tokenBeingHeld;
        phaseTwo(components);
        scanAndMergeOperators(components);
        components.removeAllWhitespace();
        // components.length.writeln;
        // components.writeln;

        if (components.length != 1 && components.length != 3)
            throw new SyntaxError("Invalid item (argument index:" ~ i.to!string ~ ")", expressionLike);

        NameValuePair pair;
        scope (exit)
            ret ~= pair;

        if (components.length == 1) {
            pair.value = components[0];
            continue;
        }
        if (components[1].action != AstAction.TokenHolder)
            throw new SyntaxError("Must include colon for named arguments", firstToken);
        if (components[1].tokenBeingHeld.tokenVariety != TokenType.Colon)
            throw new SyntaxError("Must include colon for named arguments", components[1]
                    .tokenBeingHeld);

        pair.name = components[0];
        pair.value = components[2];
    }
    return ret;
}

private bool testAndJoinConversionPipe(ref Array!AstNode nodes, size_t nodeIndex) {
    size_t startingIndex = nodeIndex;
    Nullable!AstNode itemToConvert = nodes.nextNonWhiteNode(nodeIndex);
    Nullable!AstNode op1 = nodes.nextNonWhiteNode(nodeIndex);
    Nullable!AstNode op2 = nodes.nextNonWhiteNode(nodeIndex);

    if (op1 == null || op2 == null || itemToConvert == null)
        return false;
    handleSingleNodeExpressionTest(itemToConvert.value);
    if (op1.value.action != AstAction.TokenHolder || op2.value.action != AstAction.TokenHolder)
        return false;
    if (op1.value.tokenBeingHeld.tokenVariety != TokenType.Pipe || op2.value
        .tokenBeingHeld.value != ">".makeUnicodeString)
        return false;

    Nullable!AstNode typeToBeConverted = nodes.nextNonWhiteNode(nodeIndex);
    if (typeToBeConverted == null)
        return false;
    // We must split up this named unit
    if (typeToBeConverted.value.action == AstAction.NamedUnit && typeToBeConverted.value.namedUnit.names.length > 1){
        AstNode node = typeToBeConverted.value;
        NamedUnit realType = NamedUnit([node.namedUnit.names[0]]);
        NamedUnit afterType = NamedUnit(node.namedUnit.names[1..$]);
        AstNode period = new AstNode;
        AstNode afterTypeNode = new AstNode;
        AstNode realTypeNode = new AstNode;
        period.action = AstAction.TokenHolder;
        period.tokenBeingHeld = Token(TokenType.Period, ".".makeUnicodeString);

        afterTypeNode.action = AstAction.NamedUnit;
        afterTypeNode.namedUnit = afterType;

        realTypeNode.action = AstAction.NamedUnit;
        realTypeNode.namedUnit = realType;
        nodes.insertBefore(nodes[nodeIndex..$], afterTypeNode);
        nodes.insertBefore(nodes[nodeIndex..$], period);
        typeToBeConverted.value = realTypeNode;
    }
    Nullable!AstNode potentialCall = nodes.nextNonWhiteNode(nodeIndex);
    bool hasCall = potentialCall != null && potentialCall.value.action == AstAction.Expression;
    AstNode typeToConvertTo = typeToBeConverted.value;
    if (potentialCall != null && potentialCall.value.action != AstAction.Expression)
        nodeIndex--;
    if (hasCall) {
        AstNode callingWith = new AstNode;
        callingWith.action = AstAction.Call;
        callingWith.callNodeData.func = typeToBeConverted.value;
        callingWith.callNodeData.args = genCommaSeperatedContents(potentialCall.value);
        typeToConvertTo = callingWith;
    }
    AstNode protoConversion = new AstNode;
    protoConversion.action = AstAction.ConversionPipe;
    protoConversion.conversionPipeNodeData = ConversionPipeNodeData(itemToConvert.value, typeToConvertTo);
    nodes[startingIndex] = protoConversion;
    nodes.linearRemove(nodes[startingIndex + 1 .. nodeIndex]);
    return true;
}

private bool testAndJoinGeneric(ref Array!AstNode nodes, size_t nodeIndex) {
    size_t startingIndex = nodeIndex;
    Nullable!AstNode thingToBeMadeAGenericOf = nodes.nextNonWhiteNode(nodeIndex);
    if (thingToBeMadeAGenericOf == null)
        return false;
    Nullable!AstNode possibleExclamationMark = nodes.nextNonWhiteNode(nodeIndex);
    if (possibleExclamationMark == null
        || possibleExclamationMark.value.action != AstAction.TokenHolder
        || possibleExclamationMark.value.tokenBeingHeld.tokenVariety != TokenType.ExclamationMark)
        return false;
    Nullable!AstNode genericOprands = nodes.nextNonWhiteNode(nodeIndex);
    if (genericOprands == null)
        return false;

    AstNode genericNode = new AstNode;
    genericNode.action = AstAction.GenericOf;
    genericNode.genericNodeData.symbolUsedAsGeneric = thingToBeMadeAGenericOf.value;
    genericNode.genericNodeData.genericData = genericOprands.value;

    nodes[startingIndex] = genericNode;
    nodes.linearRemove(nodes[startingIndex + 1 .. nodeIndex]);
    return true;
}

private bool testAndJoinCall(ref Array!AstNode nodes, size_t nodeIndex) {
    size_t startingIndex = nodeIndex;
    Nullable!AstNode thingBeingCalled = nodes.nextNonWhiteNode(nodeIndex);
    Nullable!AstNode arguments = nodes.nextNonWhiteNode(nodeIndex);
    if (thingBeingCalled == null || arguments == null)
        return false;

    if (!thingBeingCalled.value.action.isCallable)
        return false;
    if (arguments.value.action != AstAction.Expression)
        return false;
    AstNode functionCall = new AstNode;
    functionCall.action = AstAction.Call;

    CallNodeData callNodeData;

    callNodeData.func = thingBeingCalled;
    callNodeData.args = genCommaSeperatedContents(arguments.value);

    functionCall.callNodeData = callNodeData;

    nodes[startingIndex] = functionCall;

    nodes.linearRemove(nodes[startingIndex + 1 .. nodeIndex]);
    return true;
}

private bool testAndJoinIndexingInto(ref Array!AstNode nodes, size_t nodeIndex) {
    size_t startingIndex = nodeIndex;
    Nullable!AstNode thingBeingIndexed = nodes.nextNonWhiteNode(nodeIndex);
    Nullable!AstNode index = nodes.nextNonWhiteNode(nodeIndex);
    if (thingBeingIndexed == null || index == null)
        return false;

    if (index.value.action != AstAction.ArrayGrouping)
        return false;

    AstNode indexingInto = new AstNode;
    indexingInto.action = AstAction.IndexInto;

    NameValuePair[] pairs = genCommaSeperatedContents(index.value);

    if (pairs.length > 1)
        return false;

    indexingInto.arrayOrIndexingNodeData = ArrayOrIndexingNodeData(
        thingBeingIndexed.value,
        pairs.length ? pairs[0].value : null
    );

    nodes[startingIndex] = indexingInto;

    nodes.linearRemove(nodes[startingIndex + 1 .. nodeIndex]);
    return true;
}
private void handleSingleNodeExpressionTest(ref AstNode node){
    if (node.action == AstAction.Expression) {
        Array!AstNode components;
        components ~= node.expressionNodeData.components;
        phaseTwo(components);
        scanAndMergeOperators(components);
        assert(components.length == 1, "Expression is invalid");
        node = components[0];
    }
    else if (node.action == AstAction.ArrayGrouping) {
        node.arrayNodeData = genCommaSeperatedContents(node);
        node.action = AstAction.Array;
    }
}
// Handle function calls, arrays, and Generics
void phaseTwo(ref Array!AstNode nodes) {
    for (size_t index = 0; index < nodes.length; index++) {
    TOP:
        static foreach (sepMethod; SEPERATION_LAYER_WITH_VOIDABLE.layer) {
            if (testAndJoin(sepMethod, nodes, index))
                goto TOP;
        }

        if (testAndJoinConversionPipe(nodes, index))
            goto TOP;
        if (testAndJoinGeneric(nodes, index))
            goto TOP;
        if (testAndJoinCall(nodes, index))
            goto TOP;
        if (testAndJoinIndexingInto(nodes, index))
            goto TOP;
        handleSingleNodeExpressionTest(nodes[index]);

    }
}

void trimAstNodes(ref Array!AstNode nodes) {
    // Remove starting whitespace
    while (nodes.length && nodes[0].isWhite)
        nodes.linearRemove(nodes[0 .. 1]);

    // Remove ending whitespace
    while (nodes.length && nodes[$ - 1].isWhite)
        nodes.linearRemove(nodes[$ - 1 .. $]);
}

void removeAllWhitespace(ref Array!AstNode nodes) {
    Array!AstNode newNodes;
    scope (exit)
        nodes = newNodes;
    foreach (AstNode node; nodes) {
        if (!node.isWhite)
            newNodes ~= node;
    }
}

Array!AstNode expressionNodeFromTokens(Token[] tokens) {
    AstNode[] phaseOneNodes = phaseOne(tokens);
    Array!AstNode nodes;
    nodes ~= phaseOneNodes;
    phaseTwo(nodes);
    scanAndMergeOperators(nodes);
    nodes.trimAstNodes();
    return nodes;
}

size_t findNearestSemiColon(Token[] tokens, size_t index, TokenType stopToken = TokenType.Semicolon) {
    int parCount = 0;
    while (index < tokens.length) {
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
size_t prematureSingleTokenGroupLength(Token[] tokens, size_t index) {
    size_t originalIndex = index;
    int braceCount = 0;
    bool wasLastFinalToken = false;
    while (1) {
        Nullable!Token ntoken = tokens.nextNonWhiteToken(index);
        if (ntoken == null)
            break;
        Token token = ntoken;
        if (token.tokenVariety == TokenType.OpenBraces) {
            wasLastFinalToken = true;
            braceCount++;
            continue;
        }
        else if (token.tokenVariety == TokenType.CloseBraces) {
            braceCount--;
            if (braceCount == -1)
                break;
            continue;
        }

        if (braceCount > 0)
            continue;

        switch (token.tokenVariety) {
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
