module fnc.tokenizer.make_tokens;

import std.algorithm : find, min;
import std.string : indexOf;

import std.utf : decode;
import tern.typecons.common : Nullable, nullable;

import fnc.tokenizer.tokens;

bool isZeroStyleSpecialNumber(dchar magicLetter) {
    switch (magicLetter) {
        case 'o': // Octal
        case 'O':

        case 'b': // Binary
        case 'B':

        case 'x': // Hex
        case 'X':
            return true;

        default:
            return false;
    }
}

dchar[] handleMultilineCommentsAtIndex(dchar[] input, ref size_t index) {
    if (index + 1 >= input.length)
        return [];
    const(dchar[]) endingSymbols = testMultiLineStyle(input[index], input[index + 1]);

    if (0 == endingSymbols.length)
        return [];

    size_t ending = input[index .. $].indexOf(endingSymbols);
    if (ending == -1)
        ending = input.length - index;

    dchar[] comment = input[index + 2 .. index + ending];
    index = min(index + ending + 2, input.length);

    return comment;
}

dchar[] handleSinglelineCommentsAtIndex(dchar[] input, ref size_t index) {
    if (index + 1 >= input.length)
        return [];
    bool isSingleLineComment = isSingleLineComment(input[index], input[index + 1]);
    if (!isSingleLineComment)
        return [];

    size_t ending = input[index .. $].findFirstNewLine();
    if (ending == -1)
        ending = input.length - index;
    dchar[] comment = input[index + 3 .. index + ending];

    index = min(index + ending, input.length);

    return comment;
}

private Token[] protoTokenize(string input) {
    Token[] tokens;
    dchar[] chars;

    size_t index = 0;

    while (index < input.length) {
        chars ~= input.decode(index);
    }
    for (index = 0; index < chars.length; index++) {
        dchar symbol = chars[index];
        // Two char special tokens (comments)
        if (index + 1 < chars.length) {
            size_t startingIndex = index;
            dchar[] comment = handleMultilineCommentsAtIndex(chars, index);
            if (comment.length != 0) {
                index--;
                tokens ~= Token(TokenType.Comment, comment, startingIndex);
                continue;
            }
            comment = handleSinglelineCommentsAtIndex(chars, index);
            if (comment.length != 0) {
                tokens ~= Token(TokenType.Comment, comment, startingIndex);
                continue;
            }

        }
        if (symbol == '_' && tokens[$ - 1].tokenVariety == TokenType.Number)
            continue;

        TokenType tokenType = getVarietyOfLetter(symbol);
        Token token = Token(tokenType, [symbol], index);
        if (tokenType == TokenType.Number)
            token.base = SpecialNumberBase.Decimal;
        if (tokenType == TokenType.Quotation) {
            dchar last = symbol;
            index++;
            while (index < chars.length) {
                dchar symbol2 = chars[index];
                token.value ~= symbol2;
                if (symbol2 == symbol && last != '\\')
                    break;
                last = symbol2;
                index++;
            }
        }
        tokens ~= token;
    }
    return tokens;
}

const TokenType[] groupableTokens = [
    TokenType.Number,
    TokenType.Letter,
    TokenType.Semicolon,
    TokenType.WhiteSpace,
    TokenType.Equals
];

private Token[] groupTokens(Token[] tokens) {
    Token[] groupedTokens;
    foreach (index, Token token; tokens) {
        // Handles numbers with decimals
        if (token.tokenVariety == TokenType.Period
            && groupedTokens.length
            && groupedTokens[$ - 1].tokenVariety == TokenType.Number
            && !( // Don't confuse ranges with numbers
                index + 1 < tokens.length
                &&
                tokens[index + 1].tokenVariety == TokenType.Period
            )) {
            groupedTokens[$ - 1].value ~= token.value;
            continue;
        }

        if (!groupedTokens.length) {
            groupedTokens ~= token;
            continue;
        }

        if (groupedTokens[$ - 1].tokenVariety == token.tokenVariety
            && groupableTokens.find(token.tokenVariety).length) {

            groupedTokens[$ - 1].value ~= token.value;
            continue;
        }
        bool numberAfterLetter = groupedTokens[$ - 1].tokenVariety == TokenType.Number && token.tokenVariety == TokenType
            .Letter;
        if (numberAfterLetter
            && groupedTokens[$ - 1].value == "0".makeUnicodeString
            && token.value.length == 1 && token.value[0].isZeroStyleSpecialNumber) {
            groupedTokens[$ - 1].base = getCustomBase(token.value[0]);
            groupedTokens[$ - 1].value ~= token.value;

            continue;
        }
        else if (numberAfterLetter) {

            foreach (i, sym; token.value) {
                if (sym.isHexDigit)
                    groupedTokens[$ - 1].value ~= sym;
                else {
                    groupedTokens ~= Token(TokenType.Letter,
                        token.value[i .. $], i + token.startingIndex);
                    break;
                }
            }

            continue;
        }
        if (groupedTokens[$ - 1].tokenVariety == TokenType.Letter && token.tokenVariety == TokenType
            .Number) {
            groupedTokens[$ - 1].value ~= token.value;
            continue;
        }
        if (groupedTokens[$ - 1].tokenVariety == TokenType.Period && token.tokenVariety == TokenType
            .Period) {
            groupedTokens[$ - 1].value ~= token.value;
            continue;
        }
        groupedTokens ~= token;
    }

    return groupedTokens;
}

Token[] tokenizeText(string input) {
    Token[] protoTokens = protoTokenize(input);
    Token[] grouped = groupTokens(protoTokens);
    return grouped;
}
