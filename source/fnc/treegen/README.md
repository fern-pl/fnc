# Fnc Treegen Documentation

## AstNodes

Treegen is the step after tokenizing text, and converts it into ASTNodes with multiple different methods. The best way to understand you to read an ASTNode it to see the ```ASTNode.tree()``` function. 

## Scope Parsing

There also exists the ```scope_parser.d``` file, which is for more overall parsing of files, and is the main entrypoint if you wish to parse your own data. The ```scope_parser.d``` file is best understood through the lense of the ```ScopeData``` class, a container for all information about a unit of code. 

### Parsing the global scope:

```d
    import fnc.treegen.scope_parser : parseMultilineScope, ScopeData, tree;
    import fnc.treegen.relationships : GLOBAL_SCOPE_PARSE;

    ScopeData globalScope = parseMultilineScope(GLOBAL_SCOPE_PARSE, "
        public module foo.bar;
        int main(){
            return = 69;
            writeln(\"Hello World\");
        }
    ");
    globalScope.tree;
```
