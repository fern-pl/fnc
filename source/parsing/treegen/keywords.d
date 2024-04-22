module parsing.treegen.keywords;
import parsing.tokenizer.tokens;
import std.string : indexOf;
import errors;

const dchar[][] FUNC_STYLE_KEYWORD = [
    "align".makeUnicodeString
];

const dchar[][] KEYWORDS = [
    "delete".makeUnicodeString,
    "import".makeUnicodeString,
    "alias".makeUnicodeString,
    "module".makeUnicodeString,
    "pure".makeUnicodeString,
    "public".makeUnicodeString,
    "private".makeUnicodeString,
    "static".makeUnicodeString,
    "abstract".makeUnicodeString,
    "partial".makeUnicodeString,
    "unsafe".makeUnicodeString,
    "@tapped".makeUnicodeString,
    "inline".makeUnicodeString,
    "const".makeUnicodeString,
    "mustuse".makeUnicodeString,
    "mixin".makeUnicodeString,
] ~ FUNC_STYLE_KEYWORD;

private bool scontains(const(dchar[][]) list, const(dchar[]) str)
{
    foreach (const(dchar[]) list_item; list)
    {
        if (list_item == str)
            return true;
    }
    return false;
}

import std.stdio;

// Keywords break many other parts of parsing, so best to get them out of the way first
dchar[][] skipAndExtractKeywords(ref Token[] tokens, ref size_t index)
{
    dchar[][] keywords;
    while (index < tokens.length && tokens[index].tokenVariety == TokenType.Letter)
    {
        dchar[] data = tokens[index].value;

        bool isKeyword = KEYWORDS.scontains(data);
        if (!isKeyword)
            break;
        bool isFucKeyword = FUNC_STYLE_KEYWORD.scontains(data);
        if (!isFucKeyword)
            keywords ~= data;
        else
        {

            if (index + 1 >= tokens.length || tokens[index + 1].tokenVariety != TokenType
                .OpenBraces)
                throw new SyntaxError("Keyword must have arguments");

            dchar[] keyword = new dchar[data.length];
            keyword[0 .. $] = data;
            while (++index < tokens.length && tokens[index].tokenVariety != TokenType.CloseBraces)
            {
                keyword ~= tokens[index].value;
            }
            if (index >= tokens.length)
                throw new SyntaxError("Keyword apears to have open parenthesis");
            keyword ~= tokens[index].value;
            keywords ~= keyword;
        }
        tokens.nextNonWhiteToken(index);
        index++;
    }
    return keywords;
}

