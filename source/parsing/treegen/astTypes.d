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
    DefineVariable, // Ex: int x;
    AssignVariable, // Ex: x = 5;

    SingleArgumentOperation, // Ex: x++, ++x, |x|, ||x||, -8
    DoubleArgumentOperation, // Ex: 9+10 

    Call, // Ex: foo(bar);

    Expression, // Ex: (4+5*9)
    NamedUnit, // Ex: std.io
    LiteralUnit, // Ex: 6, 6L, "Hello world"

    TokenHolder // A temporary Node that is yet to be parsed 
}

struct KeywordNodeData
{
    dchar[] keywordName;
    Token[] keywardArgs;
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

enum OperationVariety
{
    PreIncrement,
    PostIncrement,
    PreDecrement,
    PostDecrement,
    AbsuluteValue,
    Magnitude,

    Add,
    Substract,
    Multiply,
    Divide,
    Mod,

    AddEq,
    SubstractEq,
    MultiplyEq,
    DivideEq,
    ModEq,

    Pipe,
    Assignment,

    BitwiseNot,
    BitwiseOr,
    BitwiseXor,
    BitwiseAnd,

    BitwiseNotEq,
    BitwiseOrEq,
    BitwiseXorEq,
    BitwiseAndEq,

    BitshiftLeftSigned,
    BitshiftRightSigned,
    BitshiftLeftUnSigned,
    BitshiftRightUnSigned,

    LogicalOr,
    LogicalAnd,
    LogicalNot,

    GreaterThan, // >
    GreaterThanEq,
    LessThan, // <
    LessThanEq,
    EqualTo,
    NotEqualTo
}

struct SingleArgumentOperationNodeData
{
    OperationVariety pperationVariety;
    AstNode* value;
}

struct DoubleArgumentOperationNodeData
{
    OperationVariety pperationVariety;
    AstNode* left;
    AstNode* right;
}

struct ExpressionNodeData
{
    dchar opener;
    dchar closer;
    AstNode[] components;
}

struct CallNodeData
{
    NameUnit func;
    AstNode* args;
}

struct AstNode
{
    AstAction action;
    union
    {
        KeywordNodeData keywordNodeData; // Keyword
        AstNode[] scopeContents; // Scope
        DefineFunctionNodeData defineFunctionNodeData; // DefineFunction
        DefineVariableNodeData defineVariableNodeData; // DefineVariable
        AssignVariableNodeData assignVariableNodeData; // AssignVariable

        SingleArgumentOperationNodeData singleArgumentOperationNodeData; // SingleArgumentOperation
        DoubleArgumentOperationNodeData doubleArgumentOperationNodeData; // DoubleArgumentOperation
        CallNodeData callNodeData; // Call
        ExpressionNodeData expressionNodeData; // Expression
        NameUnit namedUnit; // NamedUnit
        Token[] literalUnitCompenents; // LiteralUnit
        Token tokenBeingHeld; // TokenHolder
    }

    void toString(scope void delegate(const(char)[]) sink) const
    {
        import std.conv;

        sink(action.to!string);
        sink("{");
        switch (action)
        {
            case AstAction.Keyword:
                sink(keywordNodeData.to!string);
                break;
            case AstAction.TokenHolder:
                sink(tokenBeingHeld.to!string);
                break;
            case AstAction.Expression:
                sink(expressionNodeData.components.to!string);
                break;
            default: break;
        }
        sink("}");
    }
}

struct ScopeParsingMode{
    bool allowDefiningObjects;
    bool allowDefiningFunctions;
}