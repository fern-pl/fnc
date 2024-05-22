module fnc.tokenizer.tokens;

import std.ascii : isASCII, isDigit, isAlpha, isAlphaNum, isWhite, toLower;
import std.algorithm : find, min;
import std.string : indexOf;

enum TokenType {
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
    ExclamationMark,
    QuestionMark,
    Period,

    // NOT USED IN TOKENIZER, see fnc/treegen/relationships.d
    Filler,
    _ArrayStyleAssignment
}

const dchar[] validBraceVarieties = ['{', '}', '(', ')', '[', ']'];
const dchar[] validOpenBraceVarieties = ['{', '(', '['];
const dchar[] validCloseBraceVarieties = ['}', ')', ']'];
const dchar[dchar] braceOpenToBraceClose = [
    '{' : '}',
    '(' : ')',
    '[' : ']'
];

const dchar[] validOperators = ['<', '>', '+', '-', '*', '/', '%', '~', '&'];
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

dchar[] makeUnicodeString(in string input) {
    import std.algorithm : map;
    import std.array : array;

    return (cast(char[]) input).map!(x => cast(dchar) x).array();
}

const(dchar[]) testMultiLineStyle(dchar first, dchar secound) {
    foreach (const(dchar[][]) style; validMultiLineCommentStyles) {
        if (style[0][0] == first && style[0][1] == secound)
            return style[1];
    }
    return [];
}

bool isSingleLineComment(dchar first, dchar secound) {
    static foreach (const dchar[] style; validSingleLineCommentStyles) {
        if (style[0] == first && style[0] == secound)
            return true;
    }
    return false;
}

// 3 different styles of newline are used on different OSes:
// \n    -  Linux
// \r\n  -  Windows
// \r    -  Old MacOS versions (although this is not the ascii deffinition of carriage return)
size_t findFirstNewLine(in dchar[] input) {
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

TokenType getVarietyOfLetter(dchar symbol) {
    // We do not (yet) support unicode source code. 
    // But using dchar to allow for easy integration
    if (!isASCII(symbol))
        return TokenType.Unknown;

    switch (symbol) {
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
        case '!':
            return TokenType.ExclamationMark;
        case '?':
            return TokenType.QuestionMark;
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

enum SpecialNumberBase{
    None,
    Decimal,
    Binary,
    Hex,
    Octal
}
SpecialNumberBase getCustomBase(dchar magicLetter) {
    switch (magicLetter) {
        case 'o': // Octal
        case 'O':
            return SpecialNumberBase.Octal;
        case 'b': // Binary
        case 'B':
            return SpecialNumberBase.Binary;
        case 'x': // Hex
        case 'X':
            return SpecialNumberBase.Hex;

        default:
            assert(0, "Invalid custom base");
    }
}


struct Token {
    TokenType tokenVariety;
    dchar[] value;
    size_t startingIndex;
    SpecialNumberBase base = SpecialNumberBase.None;
}

import tern.typecons.common : Nullable, nullable;

Nullable!Token nextToken(Token[] tokens, ref size_t index) {
    Nullable!Token found = null;
    if (tokens.length <= index + 1)
        return found;

    found = tokens[++index];
    return found;
}

bool isWhite(Token token) => token.tokenVariety == TokenType.WhiteSpace || token
    .tokenVariety == TokenType.Comment;
bool isLikeOpr(Token token) => token.tokenVariety == TokenType.Operator 
        || token.tokenVariety == TokenType.Equals
        || token.tokenVariety == TokenType.ExclamationMark
        || token.tokenVariety == TokenType.QuestionMark;
Nullable!Token nextNonWhiteToken(ref Token[] tokens, ref size_t index) {
    Nullable!Token found;
    while (tokens.length > index) {
        Token token = tokens[index++];
        if (token.isWhite)
            continue;
        found = token;
        break;
    }
    return found;
}


bool isHexDigit(dchar symbol){
    if (isDigit(symbol)) return true;
    symbol = toLower(symbol);
    if (symbol >= 'a' && symbol <= 'f') return true;
    return false;
    
}