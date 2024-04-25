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

    auto newScope = parseMultilineScope(FUNCTION_SCOPE_PARSE, "



            string axolotl, frog = `Hello world` * 2  + 1;
            int constant = 69  /* nice!!! */ ; 
        ".tokenizeText(), index, nullable!ScopeData(null));
      foreach (instruction; newScope.instructions)
      {
          instruction.tree;
      }
      "\n\nDeclared variables: ".writeln;
      foreach (var; newScope.declaredVariables)
      {
          var.writeln;
      }
}
