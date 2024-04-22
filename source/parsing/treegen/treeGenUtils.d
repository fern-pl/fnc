module parsing.treegen.treeGenUtils;
import errors;
import parsing.treegen.astTypes;
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
    index--;
    token = tokenNullable;

    while (token.tokenVariety == TokenType.Letter || token.tokenVariety == TokenType.Number || token.tokenVariety == TokenType.Period)
    {
        
        if (token.tokenVariety != TokenType.Period)
            ret.names ~= token.value;
        
        Nullable!Token tokenNullable2 = tokens.nextToken(index);
    
        // We hit an EOF
        if (!tokenNullable2.ptr)
            return ret;
        token = tokenNullable2;
        

        
    }
    return ret;

}