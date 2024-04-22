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
    IndexInto, // X[...]

    SingleArgumentOperation, // Ex: x++, ++x, |x|, ||x||, -8
    DoubleArgumentOperation, // Ex: 9+10 

    Call, // Ex: foo(bar);

    Expression, // Ex: (4+5*9)
    NamedUnit, // Ex: std.io
    LiteralUnit, // Ex: 6, 6L, "Hello world"

    TokenHolder // A temporary Node that is yet to be parsed 
}

bool isExpressionLike(AstAction action)
{
    return action == AstAction.Expression
        || action == AstAction.IndexInto;
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
    // AbsuluteValue,
    // Magnitude,

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

    BitshiftLeftSignedEq,
    BitshiftRightSignedEq,
    BitshiftLeftUnSignedEq,
    BitshiftRightUnSignedEq,

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
    OperationVariety operationVariety;
    AstNode value;
}

struct DoubleArgumentOperationNodeData
{
    OperationVariety operationVariety;
    AstNode left;
    AstNode right;
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
    AstNode args;
}

class AstNode
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
        case AstAction.NamedUnit:
            sink(namedUnit.names.to!string);
            break;
        case AstAction.Call:
            sink(callNodeData.func.names.to!string);
            sink("(\n");
            sink(callNodeData.args.to!string);
            sink("\n)");
            break;
        case AstAction.LiteralUnit:
            sink(literalUnitCompenents.to!string);
            break;
        case AstAction.DoubleArgumentOperation:
            sink(doubleArgumentOperationNodeData.operationVariety.to!string);
            sink(", ");
            sink(doubleArgumentOperationNodeData.left.to!string);
            sink(", ");
            sink(doubleArgumentOperationNodeData.right.to!string);
            break;
        default:
            break;
        }
        sink("}");
    }

    void tree(size_t tabCount)
    {
        import std.stdio;
        import std.conv;

        if (tabCount != -1)
        {
            foreach (i; 0 .. tabCount)
                write("|  ");
            write("┼ ");
        }

        switch (action)
        {
        case AstAction.Call:
            writeln(callNodeData.func.to!string ~ ":");
            callNodeData.args.tree(tabCount + 1);
            break;
        case AstAction.DoubleArgumentOperation:
            writeln(doubleArgumentOperationNodeData.operationVariety.to!string ~ ":");
            doubleArgumentOperationNodeData.left.tree(tabCount + 1);
            doubleArgumentOperationNodeData.right.tree(tabCount + 1);
            break;
        case AstAction.SingleArgumentOperation:
            writeln(singleArgumentOperationNodeData.operationVariety.to!string ~ ":");
            singleArgumentOperationNodeData.value.tree(tabCount + 1);
            break;
        case AstAction.IndexInto:
            writeln("Indexing into with result of:");
            foreach (subnode; expressionNodeData.components)
            {
                subnode.tree(tabCount + 1);
            }
            break;
        case AstAction.Expression:
            writeln(
                "Result of expression with " ~ expressionNodeData.components.length.to!string ~ " components:");
            foreach (subnode; expressionNodeData.components)
            {
                subnode.tree(tabCount + 1);
            }
            break;
        default:
            writeln(this.to!string);
            break;
        }
    }
}

// struct ScopeParsingMode{
//     bool allowDefiningObjects;
//     bool allowDefiningFunctions;
//     bool allowVariableDefinitions;
//     bool allowInlineVariableAssignments;
//     bool hasProperties;
//     bool isCommaSeperated;
// }
import std.container.array;

Nullable!AstNode nextNonWhiteNode(Array!AstNode nodes, ref size_t index)
{
    Nullable!AstNode found;
    while (nodes.length > index)
    {
        import parsing.tokenizer.tokens;

        AstNode node = nodes[index++];
        if (node.action == AstAction.TokenHolder &&
            (node.tokenBeingHeld.tokenVariety == TokenType.WhiteSpace
                || node.tokenBeingHeld.tokenVariety == TokenType.Comment))
            continue;
        found = node;
        break;
    }
    return found;
}

Nullable!AstNode nextNonWhiteNode(AstNode[] nodes, ref size_t index)
{
    Nullable!AstNode found;
    while (nodes.length > index)
    {
        import parsing.tokenizer.tokens;

        AstNode node = nodes[index++];
        if (node.action == AstAction.TokenHolder &&
            (node.tokenBeingHeld.tokenVariety == TokenType.WhiteSpace
                || node.tokenBeingHeld.tokenVariety == TokenType.Comment))
            continue;
        found = node;
        break;
    }
    return found;
}
