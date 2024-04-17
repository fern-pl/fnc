module parsing.treegen.expressionParser;

import parsing.treegen.astTypes;
import parsing.tokenizer.tokens;
import parsing.tokenizer.make_tokens;
import errors;

// First step of the AST gen process. Puts the tokens into
// AstNode objects and extracts parenthesis into deeper
// levels of nesting so that later they can be recursivly parsed
AstNode[] parenthesisExtract(Token[] tokens)
{
    AstNode[] ret;
    AstNode[] parenthesisStack;
    foreach (Token token; tokens)
    {
        if (token.tokenVariety == TokenType.OpenBraces)
        {
            AstNode newExpression;
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

        AstNode tokenToBeParsedLater;
        tokenToBeParsedLater.action = AstAction.TokenHolder;
        tokenToBeParsedLater.tokenBeingHeld = token;
        if (parenthesisStack.length == 0)
            ret ~= tokenToBeParsedLater;
        else
            parenthesisStack[$ - 1].expressionNodeData.components ~= tokenToBeParsedLater;
    }
    return ret;
}

AstNode parseExpression(Token[] tokens)
{
    AstNode[] nodes = parenthesisExtract(tokens);
    assert(0);
}

import std.stdio;

unittest
{
    AstNode[] asts = parenthesisExtract(tokenizeText("int x = 2\nint b = x++ + 4; int c = x++ + b++")); // 4, 7, 8

    asts.writeln;
    // asts[1].expressionComponents.writeln;
}
