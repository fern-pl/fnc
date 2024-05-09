module tests.scopeParser;

import parsing.treegen.astTypes;
import parsing.treegen.tokenRelationships;
import parsing.treegen.scopeParser;
import parsing.tokenizer.tokens;
import tern.typecons.common : Nullable, nullable;

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

    assert(newScope.instructions[3].assignVariableNodeData.value.action == AstAction.LiteralUnit);
    assert(newScope.instructions[3].assignVariableNodeData.value.literalUnitCompenents[0] == Token(
            TokenType.Quotation, "`Hello world`".makeUnicodeString, 109));

    assert(
        newScope.instructions[4].assignVariableNodeData.name[0].namedUnit.names == [
            "tv".makeUnicodeString
        ]);
    assert(newScope.instructions[5].assignVariableNodeData.name[0].namedUnit.names == [
            "floaty".makeUnicodeString
        ]);
}

unittest
{
    import parsing.tokenizer.make_tokens;

    size_t index;
    auto t = "let x = 4/*asdadasd*/;".tokenizeText;
    auto r = getLineVarietyTestResult(FUNCTION_SCOPE_PARSE, t, index);
    assert(r.lineVariety == LineVariety.DeclarationAndAssignment);
}
