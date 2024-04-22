module parsing.tokenizer.tokens;

import std.ascii : isASCII, isDigit, isAlpha, isAlphaNum, isWhite;
import std.algorithm : find, min;
import std.string : indexOf;

enum TokenType
{
    Number,
    Operator,
    OpenBraces,
    CloseBraces,
    Letter,
    Semicolon,
    Colon,
    Comma,
    Pipe,
    WhiteSpace,
    Equals,
    Unknown,
    Quotation,
    Comment,
    Period,
    Filler
}

const dchar[] validBraceVarieties = ['{', '}', '(', ')', '[', ']'];
const dchar[] validOpenBraceVarieties = ['{', '(', '['];
const dchar[] validCloseBraceVarieties = ['}', ')', ']'];
const dchar[dchar] braceOpenToBraceClose = [
    '{': '}',
    '(': ')',
    '[': ']'
];

const dchar[] validOperators = ['<', '>', '+', '-', '*', '/', '%', '~'];
const dchar[] validQuotation = ['\'', '"', '`'];

const dchar[][][] validMultiLineCommentStyles = [
    [['/', '*'], ['*', '/']],
    [['/', '+'], ['+', '/']],
    [['\\', '*'], ['*', '\\']],
    [['\\', '+'], ['+', '\\']]
];
const dchar[][] validSingleLineCommentStyles = [
    ['/', '/'],
    ['\\', '\\']
];

dchar[] makeUnicodeString(in string input)
{
    import std.algorithm : map;
    import std.array : array;

    return (cast(char[]) input).map!(x => cast(dchar) x).array();
}

const(dchar[]) testMultiLineStyle(dchar first, dchar secound)
{
    foreach (const(dchar[][]) style; validMultiLineCommentStyles)
    {
        if (style[0][0] == first && style[0][1] == secound)
            return style[1];
    }
    return [];
}

bool isSingleLineComment(dchar first, dchar secound)
{
    static foreach (const dchar[] style; validSingleLineCommentStyles)
    {
        if (style[0] == first && style[0] == secound)
            return true;
    }
    return false;
}

// 3 different styles of newline are used on different OSes:
// \n    -  Linux
// \r\n  -  Windows
// \r    -  Old MacOS versions (although this is not the ascii deffinition of carriage return)
size_t findFirstNewLine(in dchar[] input)
{
    size_t carriageReturn = input.indexOf('\r');
    size_t newline = input.indexOf('\n');

    if (carriageReturn == -1 && newline == -1)
        return -1;
    if (newline - 1 == carriageReturn)
        return carriageReturn;
    if (carriageReturn == -1)
        return newline;
    if (newline == -1)
        return carriageReturn;

    return min(carriageReturn, newline);
}

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
    case ',':
        return TokenType.Comma;
    default:
        break;
    }

    if (isDigit(symbol))
        return TokenType.Number;
    if (isAlpha(symbol) || symbol == '_')
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
    size_t startingIndex;
}

import tern.typecons.common : Nullable, nullable;

Nullable!Token nextToken(Token[] tokens, ref size_t index)
{
    Nullable!Token found = null;
    if (tokens.length <= index + 1)
        return found;

    found = tokens[++index];
    return found;
}

Nullable!Token nextNonWhiteToken(ref Token[] tokens, ref size_t index)
{
    Nullable!Token found;
    while (tokens.length > index)
    {
        Token token = tokens[index++];
        if (token.tokenVariety == TokenType.WhiteSpace || token.tokenVariety == TokenType.Comment)
            continue;
        found = token;
        break;
    }
    return found;
}
