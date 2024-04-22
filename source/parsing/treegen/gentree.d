module parsing.treegen.gentree;
import parsing.tokenizer.tokens;
import parsing.tokenizer.make_tokens : tokenizeText;
import errors;
import std.stdio;

import tern.typecons.common : Nullable, nullable;

void generateGlobalScopeForCompilationUnit(Token[] tokens)
{
    size_t index = 0;
    Nullable!Token firstTokenNullable = tokens.nextNonWhiteToken(index);

    if (firstTokenNullable.ptr == null)
        throw new RequirementFailed("Empty source file detected!");
    Token firstToken = firstTokenNullable;

}
