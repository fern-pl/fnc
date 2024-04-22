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

LineVarietyAndLength getLineVarietyAndLength(Token[] tokens, size_t index)
{
    size_t temp_index = index;

    static foreach (i, func; [
            IfStatementWithScope,
            IfStatementWithoutScope,
            DeclarationLine,
            DeclarationAndAssignment
        ])
    {
        if (func.matchesToken(tokens, temp_index))
            return LineVarietyAndLength(
                [
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
void parseLine(Token[] tokens, ref size_t index)
{
    LineVarietyAndLength lineVariety = tokens.getLineVarietyAndLength(index);
}

