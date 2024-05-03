module main;

import parsing.tokenizer.tokens;
import parsing.tokenizer.make_tokens;
import tern.typecons.common : Nullable, nullable;
import parsing.treegen.scopeParser;
import parsing.treegen.tokenRelationships;
import parsing.treegen.typeParser;

import std.stdio;

void main()
{
    size_t index = 0;
    // typeFromTokens("".tokenizeText, index);

    // auto x = DeclarationAndAssignment.matchesToken("int x = 4;".tokenizeText);
    // (x == null).writeln;
    auto newScope = parseMultilineScope(GLOBAL_SCOPE_PARSE, "int[4] main(){}");
    newScope.tree();
}
