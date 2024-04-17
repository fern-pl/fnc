module parsing.treegen.expressionParser;

import parsing.treegen.astTypes;
import parsing.tokenizer.tokens;
import parsing.tokenizer.make_tokens;
import errors;

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
            newExpression.expressionComponents = [];
            parenthesisStack ~= newExpression;
            continue;
        }
        if (token.tokenVariety == TokenType.CloseBraces)
        {
            if (parenthesisStack.length == 0)
                throw new SyntaxError("Parenthesis closed but never opened");

            AstNode node = parenthesisStack[$ - 1];
            parenthesisStack.length--;

            if (parenthesisStack.length == 0)
                ret ~= node;
            else
                parenthesisStack[$ - 1].expressionComponents ~= node;
            continue;
        }
        
        AstNode tokenToBeParsedLater;
        tokenToBeParsedLater.action = AstAction.TokenHolder;
        tokenToBeParsedLater.tokenBeingHeld = token;
        if (parenthesisStack.length == 0)
            ret ~= tokenToBeParsedLater;
        else
            parenthesisStack[$ - 1].expressionComponents ~= tokenToBeParsedLater;
    }
    return ret;
}

AstNode parseExpression(Token[] tokens)
{
    assert(0);
}
import std.stdio;
unittest
{
    AstNode[] asts = parenthesisExtract(tokenizeText("hello(world(that(is(recursive))))"));
    // asts[1].expressionComponents.writeln;
}
