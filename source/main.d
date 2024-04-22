module main;

import parsing.tokenizer.tokens;
import parsing.tokenizer.make_tokens;

void main()
{
    Token[] tokens = tokenizeText("
    int x, y;
    x = 5;
    y = 1;
    x = 3;
    void x, y;
    int tv = x++ + y;
    float floaty = tv / 2;
    int xx;
    int xxx;
		");
    import tern.typecons.common : Nullable, nullable;
    import parsing.treegen.scopeParser;
    import parsing.tokenizer.make_tokens;
    size_t index = 0;
    auto scope_ = tokens.parseMultilineScope(index, nullable!ScopeData(null));
    import std.stdio;
    scope_.declaredVariables.writeln;
}
