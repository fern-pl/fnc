module fnc.treegen.utils;

import fnc.errors;
import fnc.treegen.ast_types;
import fnc.tokenizer.tokens;
import tern.typecons.common : Nullable, nullable;

NamedUnit genNamedUnit(Token[] tokens, ref size_t index)
{
    dchar[][] nameData = new dchar[][0];
    // NamedUnit ret = NamedUnit(new dchar[][]);

    bool hasLastPeriod = true;
    while (1)
    {
        Nullable!Token tokenNullable = tokens.nextNonWhiteToken(index);
        if (tokenNullable == null)
            return NamedUnit(nameData);
        Token token = tokenNullable;
        if (token.tokenVariety == TokenType.Period){
            hasLastPeriod = true;
            continue;
        }
        if (token.tokenVariety == TokenType.Letter)
        {
            if (!hasLastPeriod)
            {
                index--;
                return NamedUnit(nameData);
            }
            nameData ~= token.value;
            hasLastPeriod = false;
            continue;
        }
        index--;
        return NamedUnit(nameData);
    }
    
}
