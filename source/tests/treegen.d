module tests.parser;

import std.container.array;
import parsing.tokenizer.tokens;
import parsing.treegen.astTypes;
import parsing.treegen.expressionParser;
import parsing.treegen.treeGenUtils;

import parsing.treegen.tokenRelationships;

unittest
{
    import parsing.tokenizer.make_tokens;

    AstNode[] phaseOneNodes = phaseOne("math.sqrt(3 * 5 + 6 * 7 / 2)*(x+3)/2+4".tokenizeText);
    Array!AstNode nodes;
    nodes ~= phaseOneNodes;
    phaseTwo(nodes);
    scanAndMergeOperators(nodes);
    assert(nodes.length == 1);
    assert(nodes[0].action == AstAction.DoubleArgumentOperation);
    assert(nodes[0].doubleArgumentOperationNodeData.operationVariety == OperationVariety.Add);
    assert(nodes[0].doubleArgumentOperationNodeData.right.action == AstAction.LiteralUnit);
    assert(nodes[0].doubleArgumentOperationNodeData.right.literalUnitCompenents == [
            Token(TokenType.Number, ['4'], 37)
        ]);

}

unittest
{
    import parsing.tokenizer.make_tokens;

    size_t s = 0;
    assert("int x = 4;".tokenizeText.genNameUnit(s).names == [
            "int".makeUnicodeString
        ]);
    s = 0;
    assert("std.int x = 4;".tokenizeText.genNameUnit(s)
            .names == [
                "std".makeUnicodeString,
                "int".makeUnicodeString
            ]);
}

unittest
{
    import parsing.tokenizer.make_tokens;

    assert(DeclarationLine.matchesToken(
            tokenizeText("mod.type.submod x,r,q,a, A_variable  \n\r\t ;")
    ));
    assert(DeclarationLine.matchesToken(tokenizeText("mod.type.submod x, a, e ,y;")));
    assert(!DeclarationLine.matchesToken(tokenizeText(";mod.type x;")));
    assert(!DeclarationLine.matchesToken(tokenizeText("123 mod.type x;")));
    assert(!DeclarationLine.matchesToken(tokenizeText("mod.type x = 5;")));
    assert(DeclarationAndAssignment.matchesToken(
            tokenizeText("mod.type x, y, z  , o = someFunc();")
    ));
    assert(!DeclarationAndAssignment.matchesToken(tokenizeText("someFunc();")));
    assert(!DeclarationLine.matchesToken(tokenizeText("someFunc();")));
    assert(IfStatementWithoutScope.matchesToken(tokenizeText("if (hello) testText;")));
    assert(IfStatementWithoutScope.matchesToken(tokenizeText("if (hello) v = ()=>print(1235);")));
    assert(IfStatementWithScope.matchesToken(tokenizeText("if (hello){}")));
    assert(IfStatementWithScope.matchesToken(tokenizeText("if (hello world){}")));
    assert(IfStatementWithScope.matchesToken(
            tokenizeText(
            "if (hello world){\n\n\r if(Some possible nested code) still works;}")
    ));
    assert(
        DeclarationAndAssignment.matchesToken(tokenizeText("int x = 4;"))
    );
}

unittest
{
    import parsing.tokenizer.make_tokens;
    import parsing.treegen.keywords;

    Token[] tokens = tokenizeText("align(an invalid alignment) abstract pure int x();");

    size_t index = 0;
    assert(
        [
        "align(an invalid alignment)".makeUnicodeString,
        "abstract".makeUnicodeString, "pure".makeUnicodeString
    ] == skipAndExtractKeywords(tokens, index));
    assert(tokens[index].value == "int".makeUnicodeString);
}

unittest
{
    import parsing.tokenizer.make_tokens;

    auto nodes = expressionNodeFromTokens("(p[t++]<<<=1) + 10 / x[9]++".tokenizeText);
    assert(nodes.length == 1);
    assert(nodes[0].action == AstAction.DoubleArgumentOperation);
    assert(nodes[0].doubleArgumentOperationNodeData.operationVariety == OperationVariety.Add);
    // nodes[0].tree(-1);
}
