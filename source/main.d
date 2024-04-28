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
    auto newScope = parseMultilineScope(GLOBAL_SCOPE_PARSE, "
        import std.stdio : writeln, write;
        import std.math;

        public static int main(){
            int x = 5;
            int y = x++ - 5;
            if (x > y)
                writeln(`hello world`);
            int yy = y + y;
            return yy;
         }");
    newScope.tree();
}
