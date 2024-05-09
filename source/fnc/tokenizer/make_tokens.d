module fnc.tokenizer.make_tokens;

import std.algorithm : find, min;
import std.string : indexOf;

import std.utf : decode;
import tern.typecons.common : Nullable, nullable;

import fnc.tokenizer.tokens;

dchar[] handleMultilineCommentsAtIndex(dchar[] input, ref size_t index)
{
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

dchar[] handleSinglelineCommentsAtIndex(dchar[] input, ref size_t index)
{
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

private Token[] protoTokenize(string input)
{
    Token[] tokens;
    dchar[] chars;

    size_t index = 0;

    while (index < input.length)
    {
        chars ~= input.decode(index);
    }
    for (index = 0; index < chars.length; index++)
    {
        dchar symbol = chars[index];
        // Two char special tokens (comments)
        if (index + 1 < chars.length)
        {
            size_t startingIndex = index;
            dchar[] comment = handleMultilineCommentsAtIndex(chars, index);
            if (comment.length != 0)
            {
                index--;
                tokens ~= Token(TokenType.Comment, comment, startingIndex);
                continue;
            }
            comment = handleSinglelineCommentsAtIndex(chars, index);
            if (comment.length != 0)
            {
                tokens ~= Token(TokenType.Comment, comment, startingIndex);
                continue;
            }

        }
        TokenType tokenType = getVarietyOfLetter(symbol);
        Token token = Token(tokenType, [symbol], index);
        if (tokenType == TokenType.Quotation)
        {
            dchar last = symbol;
            index++;
            while (index < chars.length)
            {
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

private Token[] groupTokens(Token[] tokens)
{
    Token[] groupedTokens;
    foreach (index, Token token; tokens)
    {
        // Handles numbers with decimals
        if (token.tokenVariety == TokenType.Period
            && groupedTokens.length
            && groupedTokens[$ - 1].tokenVariety == TokenType.Number
            && !( // Don't confuse ranges with numbers
                index+1 < tokens.length
                &&
                tokens[index+1].tokenVariety == TokenType.Period
            ))
        {
            groupedTokens[$ - 1].value ~= token.value;
            continue;
        }

        if (!groupedTokens.length)
        {
            groupedTokens ~= token;
            continue;
        }

        if (groupedTokens[$ - 1].tokenVariety == token.tokenVariety && groupableTokens.find(
                token.tokenVariety).length)
        {
            groupedTokens[$ - 1].value ~= token.value;
            continue;
        }
        if (groupedTokens[$ - 1].tokenVariety == TokenType.Letter && token.tokenVariety == TokenType
            .Number)
        {
            groupedTokens[$ - 1].value ~= token.value;
            continue;
        }
        if (groupedTokens[$ - 1].tokenVariety == TokenType.Period && token.tokenVariety == TokenType.Period){
            groupedTokens[$ - 1].value ~= token.value;
            continue;
        }
        groupedTokens ~= token;
    }

    return groupedTokens;
}

Token[] tokenizeText(string input)
{
    Token[] protoTokens = protoTokenize(input);
    Token[] grouped = groupTokens(protoTokens);
    return grouped;
}
