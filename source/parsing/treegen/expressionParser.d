module parsing.treegen.expressionParser;

import parsing.treegen.astTypes;
import parsing.tokenizer.tokens;
import parsing.treegen.tokenRelationships;
import errors;
import std.stdio;

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
void parseExpression(AstNode[] nodes){
    for(size_t index = 0; index < nodes.length; index++){
        AstNode node = nodes[index];
        if (index != 0 && node.action == AstAction.Expression && node.expressionNodeData.opener == '('
                && nodes[index-1].action == AstAction.TokenHolder 
                && nodes[index-1].tokenBeingHeld.tokenVariety == TokenType.Letter){
            AstNode functionCall;
            functionCall.action = AstAction.Call;
        }
    }
}

void parseExpression(Token[] tokens)
{
    parseExpression(parenthesisExtract(tokens));
    // tokens[0].tokenVariety


}


unittest
{
    
    import parsing.tokenizer.make_tokens;
    parseExpression("sqrt(8*9+5*2 / (6+10*2))".tokenizeText);
}