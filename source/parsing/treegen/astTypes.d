module parsing.treegen.astTypes;
import parsing.tokenizer.tokens : Token;
import tern.typecons.common : Nullable, nullable;

struct NamedUnit
{
    dchar[][] names;
}

enum AstAction
{
    // Typical code actions:

    Keyword, // Standalong keywords Ex: import std.std.io;
    Scope,

    IfStatement,
    ElseIfStatement,
    ElseStatement,
    ReturnStatement,

    WhileLoop,

    AssignVariable, // Ex: x = 5;
    ArrayGrouping, // X[...]

    SingleArgumentOperation, // Ex: x++, ++x
    DoubleArgumentOperation, // Ex: 9+10 

    Call, // Ex: foo(bar);

    // Misc tokens: 

    Expression, // Ex: (4+5*9)
    NamedUnit, // Ex: std.io
    LiteralUnit, // Ex: 6, 6L, "Hello world"

    TokenHolder, // A temporary Node that is yet to be parsed 

    // Type tokens
    TypeTuple,  // [int, float]
    TypeArray,  // int[3] OR int[]
    TypeCall,   // const(int) Note: const is ALSO a keyword
    TypePointer, // *int
    TypeReference, // &int
    TypeGeneric,    // Result!(int, string)

}

bool isExpressionLike(AstAction action)
{
    return action == AstAction.Expression
        || action == AstAction.ArrayGrouping;
}

struct KeywordNodeData
{
    dchar[] keywordName;
    dchar[][] possibleExtras;
    Token[] keywardArgs;
}

struct AssignVariableNodeData
{
    AstNode[] name; // Name of variable(s) to assign Ex: x = y = z = 5;
    AstNode value;
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
    NotEqualTo,

    Period // foo.bar
}

import parsing.treegen.scopeParser : ScopeData;

struct ConditionNodeData
{
    dchar[][] precedingKeywords;
    bool isScope;
    AstNode condition;
    union
    {
        ScopeData conditionScope;
        AstNode conditionResultNode;
    }
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
    NamedUnit func;
    AstNode args;
}
struct TypeGenericNodeData
{
    AstNode left;
    AstNode right;
}

class AstNode
{
    AstAction action;
    union
    {
        KeywordNodeData keywordNodeData; // Keyword
        AssignVariableNodeData assignVariableNodeData; // AssignVariable

        ConditionNodeData conditionNodeData;

        SingleArgumentOperationNodeData singleArgumentOperationNodeData; // SingleArgumentOperation
        DoubleArgumentOperationNodeData doubleArgumentOperationNodeData; // DoubleArgumentOperation
        CallNodeData callNodeData; // Call
        ExpressionNodeData expressionNodeData; // Expression
        NamedUnit namedUnit; // NamedUnit
        Token[] literalUnitCompenents; // LiteralUnit
        Token tokenBeingHeld; // TokenHolder

        AstNode nodeToReturn; // ReturnStatement
        
        struct{ // TypeArray
            AstNode firstNodeOperand; // This might be the thing being indexed
            bool isIntegerLiteral;
            AstNode[][] commaSeperatedNodes; // Declaring arrays, array types, typles, etc
        }
        TypeGenericNodeData typeGenericNodeData; // TypeGeneric
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
        case AstAction.TypeArray:
            bool hasFirstOperand = (cast(void*)firstNodeOperand) != null;
            if (hasFirstOperand){
                sink("Array of: ");
                sink(firstNodeOperand.to!string);
                sink(" ");
            }
            if (isIntegerLiteral){
                sink("with ");
                sink(commaSeperatedNodes[0][0].to!string);
                sink(" elements");
            }else
                foreach (const(AstNode[]) containingReductions ; commaSeperatedNodes){
                    sink(commaSeperatedNodes.to!string);
                }
            
            break;
        default:
            break;
        }
        sink("}");
    }

    void tree() => tree(-1);

    void tree(size_t tabCount)
    {
        import std.stdio;
        import std.conv;

        alias printTabs() = {
            if (tabCount != -1)
            {
                foreach (i; 0 .. tabCount)
                    write("|  ");
                write("┼ ");
            }
        };
        printTabs();

        switch (action)
        {
        case AstAction.TypeGeneric:
            write(action);
            writeln(":");
            typeGenericNodeData.left.tree(tabCount + 1);
            typeGenericNodeData.right.tree(tabCount + 1);
            break;
        case AstAction.TypePointer:
        case AstAction.TypeReference:
            write(action);
            writeln(":");
            foreach (subnode; expressionNodeData.components)
            {
                subnode.tree(tabCount + 1);
            }
            break;
        case AstAction.TypeArray:
            bool hasFirstOperand = (cast(void*)firstNodeOperand) != null;
            if (hasFirstOperand && commaSeperatedNodes.length)
                writeln("List of N indexed with X");
            else
                writeln("List of X");
            if (firstNodeOperand)
            firstNodeOperand.tree(tabCount + 1);
            foreach (AstNode[] possibleReducedNodes; commaSeperatedNodes)
            {
                if(possibleReducedNodes.length > 0)
                    possibleReducedNodes[0].tree(tabCount + 1);

            }
            break;
        case AstAction.TypeTuple:
            write(action);
            writeln(":");
            foreach (AstNode[] possibleReducedNodes; commaSeperatedNodes)
            {
                if(possibleReducedNodes.length > 0)
                    possibleReducedNodes[0].tree(tabCount + 1);

            }
            break;
        case AstAction.Call:
            writeln("Call " ~ callNodeData.func.to!string ~ ":");
            callNodeData.args.tree(tabCount + 1);
            break;
        case AstAction.DoubleArgumentOperation:
            write("opr ");
            writeln(doubleArgumentOperationNodeData.operationVariety.to!string ~ ":");
            doubleArgumentOperationNodeData.left.tree(tabCount + 1);
            doubleArgumentOperationNodeData.right.tree(tabCount + 1);
            break;
        case AstAction.SingleArgumentOperation:
            writeln(singleArgumentOperationNodeData.operationVariety.to!string ~ ":");
            singleArgumentOperationNodeData.value.tree(tabCount + 1);
            break;
        case AstAction.ArrayGrouping:
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
        case AstAction.ReturnStatement:
            writeln(action);
            nodeToReturn.tree(tabCount + 1);
            break;
        case AstAction.AssignVariable:
            write("Assigning variable(s): ");
            foreach (AstNode nameNode; assignVariableNodeData.name)
                write(nameNode.namedUnit.names.to!string ~ ", ");
            writeln(": ");
            assignVariableNodeData.value.tree(tabCount + 1);
            break;
        case AstAction.IfStatement:
            write(action);
            writeln(" hasScope = " ~ conditionNodeData.isScope.to!string ~ " keywords = " ~ conditionNodeData
                    .precedingKeywords.to!string);
            conditionNodeData.condition.tree(tabCount + 1);
            if (conditionNodeData.isScope)
            {
                import parsing.treegen.scopeParser : tree;

                conditionNodeData.conditionScope.tree(tabCount + 1);
            }
            else
            {
                conditionNodeData.conditionResultNode.tree(tabCount + 1);
            }
            // printTabs();
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
