module parsing.treegen.scopeParser;
import parsing.tokenizer.tokens;
import parsing.treegen.astTypes;
import parsing.treegen.treeGenUtils;
import parsing.treegen.tokenRelationships;
import parsing.treegen.keywords;

import tern.typecons.common : Nullable, nullable;

struct ImportStatement
{
    dchar[][] keywordExtras;
    NameUnit nameUnit;
    NameUnit[] importSelection; // empty for importing everything
}

class ScopeData
{
    Nullable!ScopeData parent; // Could be the global scope

    bool isPartialModule = false;
    Nullable!NameUnit moduleName;
    ImportStatement[] imports;
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

import std.stdio;

void parseLine(Token[] tokens, ref size_t index, ScopeData parent)
{
    dchar[][] keywords = tokens.skipAndExtractKeywords(index);

    LineVarietyAndLength lineVariety = tokens.getLineVarietyAndLength(index);
    switch (lineVariety.lineVariety){
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
            while (true){
                NameUnit toImport = tokens.genNameUnit(index);
                if (toImport.names.length == 0) break;
                statement.importSelection ~= toImport;
                Nullable!Token mightBeACommaN = tokens.nextNonWhiteToken(index);
                if (mightBeACommaN.ptr == null) break;
                Token mightBeAComma = mightBeACommaN;
                if (mightBeAComma.tokenVariety != TokenType.Comma) break;
            }
            statement.importSelection.writeln;

            break;
        default:
            import std.conv;
            assert(0, "Not yet implemented: " ~ lineVariety.lineVariety.to!string);

    }

}

unittest
{
    import parsing.tokenizer.make_tokens;

    size_t index = 0;
    ScopeData testScope = new ScopeData;
    parseLine("partial public import cat.dog.hybrid : cat, mat, r8t;".tokenizeText, index, testScope);
}
