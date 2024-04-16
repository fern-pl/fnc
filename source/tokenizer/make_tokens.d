module tokenizer.make_tokens;

import std.algorithm : find;

import std.utf : decode;

import tokenizer.tokens;

import std.stdio;

private Token[] protoTokenize(string input)
{
    Token[] tokens;
    size_t index = 0;

    while (index < input.length)
    {
        dchar symbol = input.decode(index);
        TokenType tokenType = getVarietyOfLetter(symbol);
        tokens ~= Token(tokenType, [symbol]);
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
        if (groupedTokens[$ - 1].tokenVariety == token.tokenVariety && groupableTokens.find(token.tokenVariety).length)
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
    Token[] protoTokens = protoTokenize(input);
    return groupTokens(protoTokens);
}
