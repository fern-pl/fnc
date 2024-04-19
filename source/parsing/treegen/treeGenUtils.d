module parsing.treegen.treeGenUtils;
import errors;
import parsing.treegen.astTypes;
import parsing.tokenizer.tokens;
import tern.typecons.common : Nullable, nullable;

NameUnit genNameUnit(Token[] tokens, ref size_t index)
{
    NameUnit ret;
    Nullable!Token tokenNullable = tokens.nextNonWhiteToken(index);
    index--;
    Token token;

    // An attempt to generate a name at an EOF
    if (tokenNullable.ptr == null)
        return ret;
    token = tokenNullable;

    while (token.tokenVariety == TokenType.Letter || token.tokenVariety == TokenType.Period)
    {
        
        if (token.tokenVariety == TokenType.Letter)
            ret.names ~= token.value;
        
        tokenNullable = tokens.nextToken(index);

        // We hit an EOF
        if (tokenNullable.ptr == null)
            return ret;

        token = tokenNullable;

    }
    return ret;

}

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

unittest
{
    import parsing.tokenizer.make_tokens;

    size_t s = 0;
    assert("int x = 4;".tokenizeText.genNameUnit(s).names == ["int".makeUnicodeString]);
    s = 0;
    assert("std.int x = 4;".tokenizeText.genNameUnit(s).names == [
        "std".makeUnicodeString,
        "int".makeUnicodeString
        ]);
}
