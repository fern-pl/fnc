module parsing.treegen.astTypes;
import parsing.tokenizer.tokens : Token;
import tern.typecons.common : Nullable, nullable;

struct NameUnit
{
    dchar[][] names;
}

enum AstAction
{
    Keyword, // Standalong keywords Ex: import std.std.io;
    Scope,
    DefineFunction,
    DefineVariable,
    AssignVariable,

    NamedUnit,
    LiteralUnit
}

struct KeywordNodeData
{
    dchar[] keywordName;
    NameUnit[] keywardArgs;
}

struct DefineFunctionNodeData
{
    dchar[][] precedingKeywords;
    dchar[][] suffixKeywords;
    NameUnit returnType;
    AstNode* functionScope;
}

struct DefineVariableNodeData
{
    dchar[][] precedingKeywords;
    NameUnit returnType;
    AstNode[] functionScope;
}
struct AssignVariableNodeData
{
    NameUnit[] name; // Name of variable(s) to assign Ex: x = y = z = 5;
    AstNode* value;
}

struct AstNode
{
    AstAction action;
    union
    {
        KeywordNodeData        keywordNodeData;        // Keyword
        AstNode[]              scopeContents;          // Scope
        DefineFunctionNodeData defineFunctionNodeData; // DefineFunction
        DefineVariableNodeData defineVariableNodeData; // DefineVariable
        AssignVariableNodeData assignVariableNodeData; // AssignVariable
        NameUnit               namedUnit;             // NamedUnit
        Token[]                literalUnitCompenents;  // LiteralUnit

    }
}
