module parsing.treegen.expressionParser;

import parsing.treegen.astTypes;
import parsing.tokenizer.tokens;
import parsing.tokenizer.make_tokens;
import errors;

AstNode parseExpression(Token[] tokens)
{
    AstNode[] nodes = parenthesisExtract(tokens);
    nodes.writeln;
    
    AstNode a;
    a.action = AstAction.Scope;
    return a;
}

import std.stdio;

unittest
{
    // AstNode[] asts = parenthesisExtract(tokenizeText("int x = 2\nint b = x++ + 4; int c = x++ + b++")); // 4, 7, 8
    parseExpression(tokenizeText("int x = abs(12)+(8*pop.open()();")); // 4, 7, 8

    // asts.writeln;
    // asts[1].expressionComponents.writeln;
}
