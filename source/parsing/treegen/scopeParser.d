module parsing.treegen.scopeParser;
import parsing.tokenizer.tokens;
import parsing.treegen.tokenRelationships;

enum LineVariety
{
    SimpleExpression,
    IfStatementWithScope,
    IfStatementWithoutScope,
    DeclarationLine,
    DeclarationAndAssignment
}

struct LineVarietyAndLength
{
    LineVariety lineVariety;
    size_t length;
}

LineVarietyAndLength getLineVarietyAndLength(Token[] tokens)
{
    size_t length;

    static foreach (i, func; [
            IfStatementWithScope,
            IfStatementWithoutScope,
            DeclarationLine,
            DeclarationAndAssignment
        ])
    {
        if (func.matchesToken(tokens, length))
            return LineVarietyAndLength(
                [
                LineVariety.IfStatementWithScope,
                LineVariety.IfStatementWithoutScope,
                LineVariety.DeclarationLine,
                LineVariety.DeclarationAndAssignment
            ][i], length
            );
        length = 0;
    }

    return LineVarietyAndLength(LineVariety.SimpleExpression, -1);
}

void parseLine(Token[] tokens)
{

}

unittest
{
    import std.stdio;
    import parsing.tokenizer.make_tokens;

    // assert(LineVariety.IfStatementWithoutScope == getLineVariety("if (hello) world;".tokenizeText));
    // assert(LineVariety.IfStatementWithScope == getLineVariety("if (hello) {wo\n rl\nd};".tokenizeText));
    getLineVarietyAndLength("int x = 4;".tokenizeText).writeln;
    // DeclarationLine.matchesToken()

}
