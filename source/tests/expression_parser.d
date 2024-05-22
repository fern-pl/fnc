module tests.expression_parser;
import fnc.treegen.ast_types;
import fnc.treegen.relationships;
import fnc.treegen.expression_parser;
import fnc.treegen.scope_parser;
import fnc.tokenizer.tokens;
import fnc.tokenizer.make_tokens;
import std.container.array;
import tern.typecons.common : Nullable, nullable;

import std.stdio;

unittest {
    AstNode[] phaseOneNodes = phaseOne("x []= a".tokenizeText);
    Array!AstNode nodes;
    nodes ~= phaseOneNodes;
    phaseTwo(nodes);

    assert(nodes.length == 4);
    assert(nodes[0].action == AstAction.NamedUnit);
    assert(nodes[1].action == AstAction.ProtoArrayEq);
    assert(nodes[2].isWhite);
    assert(nodes[3].action == AstAction.NamedUnit);

    scanAndMergeOperators(nodes);
    nodes.trimAstNodes();

    assert(nodes.length == 1);
    AstNode arrayAssignment = nodes[0];
    assert(arrayAssignment.action == AstAction.NArgumentOperation);
    assert(arrayAssignment.nArgumentOperationNodeData.operationVariety == OperationVariety
            .ArrayStyleAssignment);

    auto oprs = arrayAssignment.nArgumentOperationNodeData.operands;
    assert(oprs.length == 3);

    assert(oprs[0].action == AstAction.NamedUnit);
    assert(oprs[1].action == AstAction.NamedUnit);

    assert(oprs[0].namedUnit.names == ["x".makeUnicodeString]);
    assert(oprs[1].namedUnit.names == ["a".makeUnicodeString]);
}

unittest {
    assert(8 == "1 2 3 4 ; 6 7".tokenizeText.findNearestSemiColon(0));
    auto toks = "int 2 = 2 + 5".tokenizeText;
    assert(2 == toks.prematureSingleTokenGroupLength(0));
    assert(8 == toks.prematureSingleTokenGroupLength(2));
}