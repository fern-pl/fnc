module parsing.treegen.treeGenUtils;
import errors;
import parsing.treegen.astTypes;
import parsing.tokenizer.tokens;
import tern.typecons.common : Nullable, nullable;

NameUnit genNameUnit(Token[] tokens, ref size_t index)
{
    NameUnit ret;
    Nullable!Token tokenNullable = tokens.nextNonWhiteToken(index);
    index--;
    Token token;

    // An attempt to generate a name at an EOF
    if (tokenNullable.ptr == null)
        return ret;
    token = tokenNullable;

    while (token.tokenVariety == TokenType.Letter || token.tokenVariety == TokenType.Number || token.tokenVariety == TokenType.Period)
    {
        
        if (token.tokenVariety != TokenType.Period)
            ret.names ~= token.value;
        
        tokenNullable = tokens.nextToken(index);

        // We hit an EOF
        if (tokenNullable.ptr == null)
            return ret;

        token = tokenNullable;

    }
    return ret;

}

unittest
{
    import parsing.tokenizer.make_tokens;

    size_t s = 0;
    assert("int x = 4;".tokenizeText.genNameUnit(s).names == ["int".makeUnicodeString]);
    s = 0;
    assert("std.int x = 4;".tokenizeText.genNameUnit(s).names == [
        "std".makeUnicodeString,
        "int".makeUnicodeString
        ]);
}
