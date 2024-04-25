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

struct DeclaredFunction
{
    dchar[][] precedingKeywords;
    dchar[][] suffixKeywords;
    NameUnit returnType;
    NameUnit name;
    // TODO: Args
    ScopeData functionScope;
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

    DeclaredFunction[] declaredFunctions;
    DeclaredVariable[] declaredVariables;
    Array!AstNode instructions;

    void toString(scope void delegate(const(char)[]) sink) const {
        import std.conv;
        sink("ScopeData{isPartialModule = ");
        sink(isPartialModule.to!string);
        sink(", moduleName = ");
        if (moduleName == null)
            sink("null");
        else
            sink(moduleName.value.to!string);
        sink(", imports = ");
        sink(imports.to!string);
        sink(", declaredVariables = ");
        sink(declaredVariables.to!string);

        sink(", declaredFunctions = ");
        sink(declaredFunctions.to!string);
        sink(", instructions = ");
        sink(instructions.to!string);
        sink("}");
    }
}

struct LineVarietyTestResult
{
    LineVariety lineVariety;
    size_t length;
    TokenGrepResult[] tokenMatches;
}

LineVarietyTestResult getLineVarietyTestResult(
    const(VarietyTestPair[]) scopeParseMethod, Token[] tokens, size_t index)
{
    size_t temp_index = index;

    foreach (method; scopeParseMethod)
    {
        Nullable!(TokenGrepResult[]) grepResults = method.test.matchesToken(tokens, temp_index);
        if (null != grepResults)
        {
            return LineVarietyTestResult(
                method.variety, temp_index - index, grepResults.value
            );
        }
        temp_index = index;
    }

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

LineVarietyTestResult parseLine(const(VarietyTestPair[]) scopeParseMethod, Token[] tokens, ref size_t index, ScopeData parent)
{
    dchar[][] keywords = tokens.skipAndExtractKeywords(index);

    LineVarietyTestResult lineVariety = getLineVarietyTestResult(scopeParseMethod, tokens, index);
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
        scope (exit)
            index = endingIndex;

        auto statement = ImportStatement(
            keywords,
            lineVariety.tokenMatches[IMPORT_PACKAGE_NAME].assertAs(TokenGrepMethod.NameUnit)
                .name,
                []
        );

        statement.importSelection ~= lineVariety
            .tokenMatches[SELECTIVE_IMPORT_SELECTIONS]
            .assertAs(TokenGrepMethod.PossibleCommaSeperated)
            .commaSeperated
            .collectNameUnits();

        parent.imports ~= statement;
        break;
    case LineVariety.DeclarationLine:
    case LineVariety.DeclarationAndAssignment:
        size_t endingIndex = index + lineVariety.length;
        scope (exit)
            index = endingIndex;

        NameUnit declarationType = lineVariety.tokenMatches[DECLARATION_TYPE].assertAs(
            TokenGrepMethod.NameUnit).name;
        NameUnit[] declarationNames = lineVariety.tokenMatches[DECLARATION_VARS]
            .assertAs(TokenGrepMethod.PossibleCommaSeperated)
            .commaSeperated.collectNameUnits();
        AstNode[] nameNodes;
        foreach (NameUnit name; declarationNames)
        {
            parent.declaredVariables ~= DeclaredVariable(name, declarationType);
            AstNode nameNode = new AstNode();
            nameNode.action = AstAction.NamedUnit;
            nameNode.namedUnit = name;
            nameNodes ~= nameNode;
        }

        if (lineVariety.lineVariety == LineVariety.DeclarationLine)
            break;

        auto nodes = lineVariety.tokenMatches[DECLARATION_EXPRESSION]
            .assertAs(TokenGrepMethod.Glob)
            .tokens.expressionNodeFromTokens();

        if (nodes.length != 1)
            throw new SyntaxError(
                "Expression node tree could not be parsed properly (Not reducable into single node)");
        AstNode result = nodes[0];
        AstNode assignment = new AstNode;
        assignment.action = AstAction.AssignVariable;
        assignment.assignVariableNodeData.name = nameNodes;
        assignment.assignVariableNodeData.value = result;

        parent.instructions ~= assignment;

        break;
    case LineVariety.FunctionDeclaration:
        size_t endingIndex = index + lineVariety.length;
        scope (exit)
            index = endingIndex;
        size_t temp;
        parent.declaredFunctions ~= DeclaredFunction(
            keywords,
            [],
            lineVariety.tokenMatches[FUNCTION_NAME].assertAs(TokenGrepMethod.NameUnit)
                .name,
                lineVariety.tokenMatches[FUNCTION_RETURN_TYPE].assertAs(TokenGrepMethod.NameUnit)
                .name,
                parseMultilineScope(
                    FUNCTION_SCOPE_PARSE,
                    lineVariety.tokenMatches[FUNCTION_SCOPE].assertAs(TokenGrepMethod.Glob)
                    .tokens,
                    temp,
                    nullable!ScopeData(parent)
                )
        );

        // assert(0);
        break;
    case LineVariety.SimpleExpression:
        size_t expression_end = tokens.findNearestSemiColon(index);
        if (expression_end == -1)
            throw new SyntaxError("Semicolon not found!");
        auto nodes = expressionNodeFromTokens(tokens[index .. expression_end]);
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

ScopeData parseMultilineScope(const(VarietyTestPair[]) scopeParseMethod, Token[] tokens, ref size_t index, Nullable!ScopeData parent)
{
    ScopeData scopeData = new ScopeData;
    scopeData.parent = parent;
    while (index < tokens.length)
    {
        LineVarietyTestResult lineData = parseLine(scopeParseMethod, tokens, index, scopeData);
        Nullable!Token testToken = tokens.nextNonWhiteToken(index);
        if (testToken == null)
            break;
        index--;

    }

    return scopeData;
}

unittest
{
    import parsing.tokenizer.make_tokens;
    import parsing.treegen.scopeParser;

    size_t index = 0;
    auto newScope = parseMultilineScope(FUNCTION_SCOPE_PARSE, "
            int x, y;
            x = 5;
            y = 1;
            x = 3;
            string axolotl = `Hello world`;
            int tv = x++ + y;
            float floaty = tv / 2;
        ".tokenizeText(), index, nullable!ScopeData(null));
    assert(
        newScope.declaredVariables
            ==
            [
                DeclaredVariable(NameUnit(["x".makeUnicodeString]), NameUnit([
                        "int".makeUnicodeString
                    ])),
                DeclaredVariable(NameUnit(["y".makeUnicodeString]), NameUnit([
                        "int".makeUnicodeString
                    ])),
                DeclaredVariable(NameUnit(["axolotl".makeUnicodeString]), NameUnit(
                    ["string".makeUnicodeString])),
                DeclaredVariable(NameUnit(["tv".makeUnicodeString]), NameUnit([
                        "int".makeUnicodeString
                    ])),
                DeclaredVariable(NameUnit(["floaty".makeUnicodeString]), NameUnit(
                    ["float".makeUnicodeString]))
            ]
    );
    assert(newScope.instructions[0].action == AstAction.AssignVariable);
    assert(newScope.instructions[1].action == AstAction.AssignVariable);
    assert(newScope.instructions[2].action == AstAction.AssignVariable);
    assert(newScope.instructions[3].action == AstAction.AssignVariable);

    assert(newScope.instructions[0].assignVariableNodeData.name.length == 1);
    assert(
        newScope.instructions[0].assignVariableNodeData.name[0].namedUnit.names == [
            [cast(dchar) 'x']
        ]);
    assert(
        newScope.instructions[1].assignVariableNodeData.name[0].namedUnit.names == [
            [cast(dchar) 'y']
        ]);
    assert(
        newScope.instructions[2].assignVariableNodeData.name[0].namedUnit.names == [
            [cast(dchar) 'x']
        ]);
    assert(newScope.instructions[3].assignVariableNodeData.name[0].namedUnit.names == [
            "axolotl".makeUnicodeString
        ]);
    assert(newScope.instructions[3].assignVariableNodeData.value.action == AstAction.TokenHolder);
    assert(newScope.instructions[3].assignVariableNodeData.value.tokenBeingHeld == Token(
            TokenType.Quotation, "`Hello world`".makeUnicodeString, 109));

    assert(
        newScope.instructions[4].assignVariableNodeData.name[0].namedUnit.names == [
            "tv".makeUnicodeString
        ]);
    assert(newScope.instructions[5].assignVariableNodeData.name[0].namedUnit.names == [
            "floaty".makeUnicodeString
        ]);
}
