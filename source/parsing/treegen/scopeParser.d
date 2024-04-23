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

struct DeclaredVariable
{
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

struct LineVarietyTestResult
{
    LineVariety lineVariety;
    size_t length;
    TokenGrepResult[] tokenMatches;
}

LineVarietyTestResult getLineVarietyTestResult(Token[] tokens, size_t index)
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
    {{
        Nullable!(TokenGrepResult[]) grepResults = func.matchesToken(tokens, temp_index);
        if (null != grepResults)
            return LineVarietyTestResult(
                [
                LineVariety.TotalImport,
                LineVariety.SelectiveImport,
                LineVariety.ModuleDeclaration,
                LineVariety.IfStatementWithScope,
                LineVariety.IfStatementWithoutScope,
                LineVariety.DeclarationLine,
                LineVariety.DeclarationAndAssignment
            ][i], temp_index - index, grepResults.value
            );
        temp_index = index;
    }}

    return LineVarietyTestResult(LineVariety.SimpleExpression, -1);
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

LineVarietyTestResult parseLine(Token[] tokens, ref size_t index, ScopeData parent)
{
    dchar[][] keywords = tokens.skipAndExtractKeywords(index);

    LineVarietyTestResult lineVariety = tokens.getLineVarietyTestResult(index);
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
        size_t endingIndex = index + lineVariety.length;
        scope (exit) index = endingIndex;

        auto statement = ImportStatement(
            keywords,
            lineVariety.tokenMatches[IMPORT_PACKAGE_NAME].name,
            []
        );

        statement.importSelection ~= lineVariety.tokenMatches[SELECTIVE_IMPORT_SELECTIONS]
                                                .commaSeperated
                                                .collectNameUnits();

        parent.imports ~= statement;
        break;
    case LineVariety.DeclarationLine:
    case LineVariety.DeclarationAndAssignment:
        size_t endingIndex = index + lineVariety.length;
        scope (exit) index = endingIndex;

        NameUnit declarationType = lineVariety.tokenMatches[DECLARATION_TYPE].name;
        NameUnit[] declarationNames = lineVariety.tokenMatches[DECLARATION_VARS].commaSeperated.collectNameUnits();
        
        foreach (NameUnit name; declarationNames)
            parent.declaredVariables ~= DeclaredVariable(name, declarationType);
        
        if (lineVariety.lineVariety == LineVariety.DeclarationLine) break;
        
        auto nodes = lineVariety.tokenMatches[DECLARATION_EXPRESSION].tokens.expressionNodeFromTokens();
        
        // nodes.data.writeln;
        if (nodes.length != 1)
            throw new SyntaxError(
                "Expression node tree could not be parsed properly (Not reducable into single node)");
        AstNode result = nodes[0];
        AstNode assignment = new AstNode;
        assignment.action = AstAction.AssignVariable;
        assignment.assignVariableNodeData.name = declarationNames;
        assignment.assignVariableNodeData.value = result;
        
        parent.instructions ~= assignment;
        
        break;
    case LineVariety.SimpleExpression:
        size_t expression_end = tokens.findNearestSemiColon(index);
        if (expression_end == -1)
            throw new SyntaxError("Semicolon not found!");
        auto nodes = expressionNodeFromTokens(tokens[index .. expression_end]);
        // tokens[index .. expression_end].writeln;
        if (nodes.length != 1)
            throw new SyntaxError(
                "Expression node tree could not be parsed properly (Not reducable into single node)");
        parent.instructions ~= nodes[0];
        index = expression_end + 1;
        
        break;
    default:
        import std.conv;

        assert(0, "Not yet implemented: " ~ lineVariety.lineVariety.to!string);

    }
    return lineVariety;
}

ScopeData parseMultilineScope(Token[] tokens, ref size_t index, Nullable!ScopeData parent)
{
    ScopeData scopeData = new ScopeData;
    scopeData.parent = parent;
    parseLine(tokens, index, scopeData).lineVariety.writeln;
    parseLine(tokens, index, scopeData).lineVariety.writeln;
    parseLine(tokens, index, scopeData).lineVariety.writeln;
    parseLine(tokens, index, scopeData).lineVariety.writeln;
    parseLine(tokens, index, scopeData).lineVariety.writeln;
    parseLine(tokens, index, scopeData).lineVariety.writeln;
    // parseLine(tokens, index, scopeData).lineVariety.writeln;
    // parseLine(tokens, index, scopeData).lineVariety.writeln;

    return scopeData;
}

// unittest
// {
//     import parsing.tokenizer.make_tokens;
//     import parsing.treegen.scopeParser;

//     size_t index = 0;
//     auto newScope = parseMultilineScope("
            // int x, y;
            // x = 5;
            // y = 1;
            // x = 3;
            // int tv = x++ + y;
            // float floaty = tv / 2;
            // int xx;
            // int xxx;
//         ".tokenizeText(), index, nullable!ScopeData(null));
//     newScope.declaredVariables.writeln;

//     foreach (x ; newScope.instructions)
//         x.tree(-1);
// }