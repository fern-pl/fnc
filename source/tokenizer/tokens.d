module tokenizer.tokens;

import std.ascii : isASCII, isDigit, isAlpha, isAlphaNum, isWhite;
import std.algorithm : find;

enum TokenType
{
    Number,
    Operator,
    OpenBraces,
    CloseBraces,
    Letter,
    Semicolon,
    Colon,
    Pipe,
    WhiteSpace,
    Equals,
    Unknown,
    Quotation
}

const dchar[] validBraceVarieties = ['{', '}', '(', ')', '[', ']'];
const dchar[] validOpenBraceVarieties = ['{', '(', '['];
const dchar[] validCloseBraceVarieties = ['}', ')', ']'];
const dchar[] validOperators = ['<', '>', '+', '-', '*', '/', '%', '~'];
const dchar[] validQuotation = ['\'', '"', '`'];


TokenType getVarietyOfLetter(dchar symbol)
{
    // We do not (yet) support unicode source code. 
    // But using dchar to allow for easy integration
    if (!isASCII(symbol))
        return TokenType.Unknown;
    if (isDigit(symbol))
        return TokenType.Number;
    if (isAlpha(symbol))
        return TokenType.Letter;
    if (isWhite(symbol))
        return TokenType.WhiteSpace;
    if (validOpenBraceVarieties.find(symbol).length)
        return TokenType.OpenBraces;
    if (validCloseBraceVarieties.find(symbol).length)
        return TokenType.CloseBraces;
    if (validOperators.find(symbol).length)
        return TokenType.Operator;
    if (validQuotation.find(symbol).length)
        return TokenType.Quotation;
    if (symbol == '=')
        return TokenType.Equals;
    if (symbol == ';')
        return TokenType.Semicolon;
    if (symbol == ':')
        return TokenType.Colon;
    if (symbol == '|')
        return TokenType.Pipe;
    return TokenType.Unknown;
}

struct Token
{
    TokenType tokenVariety;
    string value;
}
