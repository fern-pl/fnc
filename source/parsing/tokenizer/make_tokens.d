module parsing.tokenizer.make_tokens;

import std.algorithm : find;

import std.utf : decode;

import parsing.tokenizer.tokens;

import std.stdio;

Nullable!string handleMultilineCommentsAtIndex()
{
    
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

        }
        TokenType tokenType = getVarietyOfLetter(symbol);
        tokens ~= Token(tokenType, [symbol], index);
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
    foreach (Token token; tokens)
    {

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
        groupedTokens ~= token;
    }

    return groupedTokens;
}

Token[] tokenizeText(string input)
{
    // string strippedText = stripComments(input);
    // strippedText.writeln;
    Token[] protoTokens = protoTokenize(input);
    Token[] grouped = groupTokens(protoTokens);
    grouped.writeln;
    return grouped;
}
