module tokenizer.tokens;

import std.ascii : isASCII, isDigit, isAlpha, isAlphaNum;
import std.algorithm : find;

enum TokenType
{
    Number,
    Operator,
    Braces,
    Letter,
    Semicolon,
    Pipe,
    Unknown
}

const dchar[] validBraceVarieties = ['{', '}', '(', ')', '[', ']'];
const dchar[] validOperators = ['<', '>', '+', '-', '*', '/', '%', '~'];

TokenType getVarietyOfLetter(dchar letter)
{
    // We do not (yet) support unicode source code. 
    // But using dchar to allow for easy integration
    if (!isASCII(letter))
        return TokenType.Unknown;
    if (isDigit(letter))
        return TokenType.Number;
    if (isAlpha(letter))
        return TokenType.Letter;
    if (validBraceVarieties.find(letter))
        return TokenType.Braces;
    if (validOperators.find(letter))
        return TokenType.Operator;
    if (letter == '|')
        return TokenType.Pipe;
    return TokenType.Unknown;
}

struct Token
{
    TokenType tokenVariety;
    string value;
}
