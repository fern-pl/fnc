module fnc.treegen.keywords;

import fnc.tokenizer.tokens;
import std.string : indexOf;
import fnc.errors;

const dchar[][] FUNC_STYLE_KEYWORD = [
    "align".makeUnicodeString
];
const dchar[] PARTIAL_KEYWORD = "partial".makeUnicodeString;

const dchar[][] KEYWORDS = [
    "delete".makeUnicodeString,
    "alias".makeUnicodeString,
    "pure".makeUnicodeString,
    "public".makeUnicodeString,
    "private".makeUnicodeString,
    "static".makeUnicodeString,
    "abstract".makeUnicodeString,
    PARTIAL_KEYWORD,
    "unsafe".makeUnicodeString,
    "@tapped".makeUnicodeString,
    "inline".makeUnicodeString,
    "const".makeUnicodeString,
    "ref".makeUnicodeString,
    "mustuse".makeUnicodeString,
    "mixin".makeUnicodeString,
] ~ FUNC_STYLE_KEYWORD;

bool scontains(const(dchar[][]) list, const(dchar[]) str)
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
    while (tokens[index].isWhite && index < tokens.length)
        index++;

    dchar[][] keywords;
    while (index < tokens.length)
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
                throw new SyntaxError("Keyword must have arguments", tokens[index]);

            dchar[] keyword = new dchar[data.length];
            keyword[0 .. $] = data;
            while (++index < tokens.length && tokens[index].tokenVariety != TokenType.CloseBraces)
            {
                keyword ~= tokens[index].value;
            }
            if (index >= tokens.length)
                throw new SyntaxError("Keyword apears to have open parenthesis", tokens[index]);
            keyword ~= tokens[index].value;
            keywords ~= keyword;
        }
        tokens.nextNonWhiteToken(index);
        index++;
    }
    return keywords;
}
