module parsing.treegen.treeGenUtils;
import errors;
import parsing.treegen.astTypes;
import parsing.tokenizer.tokens;
import tern.typecons.common : Nullable, nullable;

NameUnit genNameUnit(Token[] tokens, ref size_t index)
{
    dchar[][] nameData = new dchar[][0];
    // NameUnit ret = NameUnit(new dchar[][]);
    Nullable!Token tokenNullable = tokens.nextNonWhiteToken(index);

    Token token;

    // An attempt to generate a name at an EOF
    if (tokenNullable.ptr == null)
        return NameUnit(nameData);
    index--;
    token = tokenNullable;

    while (token.tokenVariety == TokenType.Letter || token.tokenVariety == TokenType.Number || token.tokenVariety == TokenType
        .Period)
    {

        if (token.tokenVariety != TokenType.Period)
        {
            nameData ~= token.value;
        }

        Nullable!Token tokenNullable2 = tokens.nextToken(index);

        // We hit an EOF
        if (!tokenNullable2.ptr)
            return NameUnit(nameData);
        token = tokenNullable2;

    }
    return NameUnit(nameData);

}
