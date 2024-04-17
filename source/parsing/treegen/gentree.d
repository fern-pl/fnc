module parsing.treegen.gentree;
import parsing.tokenizer.tokens;
import parsing.tokenizer.make_tokens : tokenizeText;
import errors;
import std.stdio;

import tern.typecons.common : Nullable, nullable;

private struct PossibleNameUnit
{
    dchar[][] names;
}

PossibleNameUnit genNameUnit(Token[] tokens, ref size_t index)
{
    PossibleNameUnit ret;
    Nullable!Token tokenNullable = tokens.nextNonWhiteToken(index);
    Token token;

    // An attempt to generate a name at an EOF
    if (tokenNullable.ptr == null)
        return ret;
    token = tokenNullable;

    while (token.tokenVariety == TokenType.Letter || token.tokenVariety == TokenType.Period)
    {

        if (token.tokenVariety == TokenType.Period)
            continue;

        ret.names ~= token.value;
        tokenNullable = tokens.nextToken(index);

        // We hit an EOF
        if (tokenNullable.ptr == null)
            return ret;
        token = tokenNullable;
    }
    return ret;

}

void generateGlobalScopeForCompilationUnit(Token[] tokens)
{
    size_t index = 0;
    Nullable!Token firstTokenNullable = tokens.nextNonWhiteToken(index);

    if (firstTokenNullable.ptr == null)
        throw new RequirementFailed("Empty source file detected!");
    Token firstToken = firstTokenNullable;

    PossibleNameUnit nameUnit = tokens.genNameUnit(index);
    nameUnit.writeln();
}
