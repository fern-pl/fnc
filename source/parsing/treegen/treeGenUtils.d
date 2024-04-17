module parsing.treegen.treeGenUtils;
import parsing.treegen.astTypes : NameUnit;
import parsing.tokenizer.tokens;
import tern.typecons.common : Nullable, nullable;


NameUnit genNameUnit(Token[] tokens, ref size_t index)
{
    NameUnit ret;
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