module parsing.treegen.expressionParser;

import parsing.treegen.astTypes;
import parsing.tokenizer.tokens;
import parsing.tokenizer.make_tokens;
import tern.typecons.common : Nullable;
import errors;


// Line types;
///// 1. Variable declairation. 
/////     NameUnit followed by NameUnit

enum LineType{
    Declaration,
    Expression
}


import std.stdio;
void parseLine(Token[] tokens, ScopeParsingMode mode)
{
    size_t index = 0;
    Nullable!Token firstToken = tokens.nextNonWhiteToken(index);
    if (firstToken.ptr == null)
        throw new SyntaxError("Expected a statement");
    // Nullable!LineType;
    // Determine line type
    if (mode.allowVariableDefinitions){
        
    }


}


unittest
{
    parseLine(tokenizeText("int x = 4;"), ScopeParsingMode(
        false,
        false,
        true,
        true,
        false,
        false
    ));
}