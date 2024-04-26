module main;

import parsing.tokenizer.tokens;
import parsing.tokenizer.make_tokens;
import tern.typecons.common : Nullable, nullable;
import parsing.treegen.scopeParser;
import parsing.treegen.tokenRelationships;
import std.stdio;

void main()
{
    size_t index = 0;

        import parsing.tokenizer.make_tokens;
    
    auto t = "if (222) x.writeln;".tokenizeText;
    auto r = IfStatementWithoutScope.matchesToken(t);
    r.ptr.writeln;
}
