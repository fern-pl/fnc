module parsing.tokenizer.tokens;

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
    Quotation,
    Period
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

    switch (symbol)
    {
    case '=':
        return TokenType.Equals;
    case ';':
        return TokenType.Semicolon;
    case ':':
        return TokenType.Colon;
    case '|':
        return TokenType.Pipe;
    case '.':
        return TokenType.Period;
    default:
        break;
    }

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
    return TokenType.Unknown;

}

struct Token
{
    TokenType tokenVariety;
    dchar[] value;
}

import tern.typecons.common : Nullable;

Nullable!Token nextToken(Token[] tokens, ref size_t index)
{
    Nullable!Token found;
    if (tokens.length >= index)
        return found;
    found = tokens[index++];
    return found;
}

Nullable!Token nextNonWhiteToken(ref Token[] tokens, ref size_t index)
{
    Nullable!Token found;
    while (tokens.length > index)
    {
        Token token = tokens[index++];
        if (token.tokenVariety == TokenType.WhiteSpace)
            continue;
        found = token;
        break;
    }
    return found;
}
