module tokenizer.make_tokens;

import std.utf : decode;

import tokenizer.tokens;

import std.stdio;

private Token[] protoTokenize(string input)
{
    Token[] tokens = new Token[0];
    size_t index = 0;

    while (index < input.length)
    {
        dchar symbol = input.decode(index);
        TokenType tokenType = getVarietyOfLetter(symbol);
        writeln(tokenType," \"", symbol, "\" ");
    }

    return tokens;
}

Token[] tokenizeText(string input)
{
    protoTokenize(input).writeln;
    assert(false);
}
