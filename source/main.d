module main;

import parsing.tokenizer.tokens;
import parsing.tokenizer.make_tokens;

void main()
{
    // Token[] tokens = tokenizeText("
    // int x, y;
    // x = 5;
    // y = 1;
    // x = 3;
    // void x, y;
    // int tv = x++ + y;
    // float floaty = tv / 2;
    // int xx;
    // int xxx;
		// ");
    // import tern.typecons.common : Nullable, nullable;
    // import parsing.treegen.scopeParser;
    // import parsing.tokenizer.make_tokens;
    // size_t index = 0;
    // auto scope_ = tokens.parseMultilineScope(index, nullable!ScopeData(null));
    // import std.stdio;
    // scope_.declaredVariables.writeln;
        import parsing.tokenizer.make_tokens;
    import parsing.treegen.scopeParser;
    import std.stdio;

    size_t index = 0;
    auto scopeData = new ScopeData;
    parseLine("int x, y, z = 4*5+2;".tokenizeText, index, scopeData);
    
    "PTR:".writeln;
    dchar[] name = scopeData.declaredVariables[0].name.names[0];
    (cast(size_t)name.ptr).writeln;
    (cast(size_t)name.ptr == 1).writeln;
}
