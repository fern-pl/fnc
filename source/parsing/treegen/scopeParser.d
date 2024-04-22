module parsing.treegen.scopeParser;
import parsing.tokenizer.tokens;
import parsing.treegen.astTypes;
import parsing.treegen.expressionParser;
import parsing.treegen.treeGenUtils;
import parsing.treegen.tokenRelationships;
import parsing.treegen.keywords;

import tern.typecons.common : Nullable, nullable;
import std.container.array;
import errors;

struct ImportStatement
{
    dchar[][] keywordExtras;
    NameUnit nameUnit;
    NameUnit[] importSelection; // empty for importing everything
}
struct DeclaredVariable{
    NameUnit name;
    NameUnit type;
}

class ScopeData
{
    Nullable!ScopeData parent; // Could be the global scope

    bool isPartialModule = false;
    Nullable!NameUnit moduleName;
    ImportStatement[] imports;

    DeclaredVariable[] declaredVariables;
    Array!AstNode instructions;
}

enum LineVariety
{
    TotalImport,
    SelectiveImport,
    ModuleDeclaration,

    SimpleExpression,
    IfStatementWithScope,
    IfStatementWithoutScope,
    DeclarationLine,
    DeclarationAndAssignment,
}

struct LineVarietyAndLength
{
    LineVariety lineVariety;
    size_t length;
}

LineVarietyAndLength getLineVarietyAndLength(Token[] tokens, size_t index)
{
    size_t temp_index = index;

    static foreach (i, func; [
            TotalImport,
            SelectiveImport,
            ModuleDeclaration,

            IfStatementWithScope,
            IfStatementWithoutScope,
            DeclarationLine,
            DeclarationAndAssignment
        ])
    {
        if (func.matchesToken(tokens, temp_index))
            return LineVarietyAndLength(
                [
                LineVariety.TotalImport,
                LineVariety.SelectiveImport,
                LineVariety.ModuleDeclaration,
                LineVariety.IfStatementWithScope,
                LineVariety.IfStatementWithoutScope,
                LineVariety.DeclarationLine,
                LineVariety.DeclarationAndAssignment
            ][i], temp_index - index
            );
        temp_index = index;
    }

    return LineVarietyAndLength(LineVariety.SimpleExpression, -1);
}

NameUnit[] commaSeperatedNameUnits(Token[] tokens, ref size_t index)
{
    NameUnit[] units;
    while (true)
    {
        NameUnit name = tokens.genNameUnit(index);
        if (name.names.length == 0)
            break;
        units ~= name;
        Nullable!Token mightBeACommaN = tokens.nextNonWhiteToken(index);
        if (mightBeACommaN.ptr == null)
        {
            index--;
            break;
        }
        Token mightBeAComma = mightBeACommaN;
        if (mightBeAComma.tokenVariety != TokenType.Comma)
        {
            index--;
            break;
        }
    }
    return units;
}

import std.stdio;

void parseLine(Token[] tokens, ref size_t index, ScopeData parent)
{
    dchar[][] keywords = tokens.skipAndExtractKeywords(index);

    LineVarietyAndLength lineVariety = tokens.getLineVarietyAndLength(index);
    switch (lineVariety.lineVariety)
    {
    case LineVariety.ModuleDeclaration:
        tokens.nextNonWhiteToken(index); // Skip 'module' keyword
        parent.moduleName = tokens.genNameUnit(index);

        parent.isPartialModule = keywords.scontains(PARTIAL_KEYWORD);

        tokens.nextNonWhiteToken(index); // Skip semicolon

        break;
    case LineVariety.TotalImport:
        tokens.nextNonWhiteToken(index); // Skip 'import' keyword
        parent.imports ~= ImportStatement(
            keywords,
            tokens.genNameUnit(index),
            []
        );
        tokens.nextNonWhiteToken(index); // Skip semicolon
        break;
    case LineVariety.SelectiveImport:
        tokens.nextNonWhiteToken(index); // Skip 'import' keyword

        auto statement = ImportStatement(
            keywords,
            tokens.genNameUnit(index),
            []
        );

        Token shouldBeAColon = tokens.nextNonWhiteToken(index);
        assert(shouldBeAColon.tokenVariety == TokenType.Colon);
        statement.importSelection ~= tokens.commaSeperatedNameUnits(index);
        parent.imports ~= statement;
        break;
    case LineVariety.DeclarationLine:
    case LineVariety.DeclarationAndAssignment:
        auto squishedTokens = tokens[index .. index + lineVariety.length];
        NameUnit declarationType = squishedTokens.genNameUnit(index);
        NameUnit[] declarationNames = squishedTokens.commaSeperatedNameUnits(index);
        
        foreach(NameUnit name; declarationNames)
            parent.declaredVariables ~= DeclaredVariable(name, declarationType);
        

        Nullable!Token couldBeEquals = squishedTokens.nextNonWhiteToken(index);
        if (couldBeEquals.ptr == null)
            break;

        if (couldBeEquals.value.tokenVariety != TokenType.Equals) break;
        
        auto nodes = expressionNodeFromTokens(squishedTokens[index..$-1]);
        if (nodes.length != 1)
            throw new SyntaxError("Expression node tree could not be parsed properly (Not reducable into single node)");
        AstNode result = nodes[0];
        AstNode assignment = new AstNode;
        assignment.action = AstAction.AssignVariable;
        assignment.assignVariableNodeData.name = declarationNames;
        assignment.assignVariableNodeData.value = result;
        assignment.tree(-1);
        parent.instructions~=assignment;
        
        break;
    default:
        import std.conv;

        assert(0, "Not yet implemented: " ~ lineVariety.lineVariety.to!string);

    }

}

unittest
{
    import parsing.tokenizer.make_tokens;
    import parsing.treegen.scopeParser;

    size_t index = 0;
    auto scopeData = new ScopeData;
    parseLine("int x, y,z,p = foo(bar)*8+1-3%5/8; foo(bar)".tokenizeText, index, scopeData);
}
