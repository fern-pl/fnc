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
         int main(){
          int x = 4;
         }
        ".tokenizeText, index, nullable!ScopeData(null));
    newScope.writeln;
//       foreach (instruction; newScope.instructions)
//       {
//           instruction.tree;
//       }
//       "\n\nDeclared variables: ".writeln;
//       foreach (var; newScope.declaredVariables)
//       {
//           var.writeln;
//       }
}
