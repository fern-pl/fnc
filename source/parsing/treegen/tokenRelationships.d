module parsing.treegen.tokenRelationships;
import parsing.tokenizer.tokens;
import parsing.treegen.astTypes;

enum OperatorOrder{
    LeftToRight,
    RightToLeft
}
struct OperatorPrecedenceLayer
{
    OperatorOrder              order;
    OperationPrecedenceEntry[] layer;
}

struct OperationPrecedenceEntry{
    OperationVariety operation;

    // These tokens are just the template used for
    // determining what is parsed in what order.
    
    // TokenType of Operator is the operator to match to.
    // TokenType of Filler is an expression (or equivelent)
    const(Token[]) tokens;
}
private Token OPR(dchar o){
    return Token(TokenType.Operator, [o]);
}

// https://en.cppreference.com/w/c/language/operator_precedence
// Order of operations in the language. This is broken up
// into layers, the layers are what is done first. And inside
// of each layer they are read left to right, or right to left.

const OperatorPrecedenceLayer[] operatorPrecedence = [
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
        OperationPrecedenceEntry(OperationVariety.PreIncrement, [OPR('+'), OPR('+'), Token(TokenType.Filler)]),
        OperationPrecedenceEntry(OperationVariety.PreDecrement, [OPR('-'), OPR('-'), Token(TokenType.Filler)]),
        OperationPrecedenceEntry(OperationVariety.PostIncrement, [Token(TokenType.Filler), OPR('+'), OPR('+')]),
        OperationPrecedenceEntry(OperationVariety.PostDecrement, [Token(TokenType.Filler), OPR('-'), OPR('-')]),

        OperationPrecedenceEntry(OperationVariety.LogicalNot, [OPR('!'), Token(TokenType.Filler)]),
        OperationPrecedenceEntry(OperationVariety.BitwiseNot, [OPR('~'), Token(TokenType.Filler)]),
    ]),
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
        OperationPrecedenceEntry(OperationVariety.Multiply,[Token(TokenType.Filler), OPR('*'), Token(TokenType.Filler)]),
        OperationPrecedenceEntry(OperationVariety.Divide, [Token(TokenType.Filler), OPR('/'), Token(TokenType.Filler)]),
        OperationPrecedenceEntry(OperationVariety.Mod, [Token(TokenType.Filler), OPR('%'), Token(TokenType.Filler)]),
    ]),
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
        OperationPrecedenceEntry(OperationVariety.Add, [Token(TokenType.Filler), OPR('+'), Token(TokenType.Filler)]),
        OperationPrecedenceEntry(OperationVariety.Substract, [Token(TokenType.Filler), OPR('-'), Token(TokenType.Filler)]),
    ]),
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
        OperationPrecedenceEntry(OperationVariety.BitshiftLeftSigned, [Token(TokenType.Filler), OPR('<'), OPR('<'), Token(TokenType.Filler)]),
        OperationPrecedenceEntry(OperationVariety.BitshiftRightSigned, [Token(TokenType.Filler), OPR('>'), OPR('>'), Token(TokenType.Filler)]),
    ]),
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
        OperationPrecedenceEntry(OperationVariety.LessThanEq, [Token(TokenType.Filler), OPR('<'), OPR('='), Token(TokenType.Filler)]),
        OperationPrecedenceEntry(OperationVariety.GreaterThanEq, [Token(TokenType.Filler), OPR('>'), OPR('='), Token(TokenType.Filler)]),
        OperationPrecedenceEntry(OperationVariety.LessThan, [Token(TokenType.Filler), OPR('<'), Token(TokenType.Filler)]),
        OperationPrecedenceEntry(OperationVariety.GreaterThan, [Token(TokenType.Filler), OPR('>'), Token(TokenType.Filler)]),
    ]),
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
        OperationPrecedenceEntry(OperationVariety.NotEqualTo, [Token(TokenType.Filler), OPR('!'), OPR('='), Token(TokenType.Filler)]),
        OperationPrecedenceEntry(OperationVariety.EqualTo ,[Token(TokenType.Filler), OPR('='), OPR('='), Token(TokenType.Filler)]),
    ]),
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
        OperationPrecedenceEntry(OperationVariety.BitwiseAnd, [Token(TokenType.Filler), OPR('&'), Token(TokenType.Filler)]),
    ]),
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
        OperationPrecedenceEntry(OperationVariety.BitwiseXor, [Token(TokenType.Filler), OPR('^'), Token(TokenType.Filler)]),
    ]),
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
        OperationPrecedenceEntry(OperationVariety.BitwiseOr, [Token(TokenType.Filler), OPR('|'), Token(TokenType.Filler)]),
    ]),
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
        OperationPrecedenceEntry(OperationVariety.LogicalAnd, [Token(TokenType.Filler), OPR('&'), OPR('&'), Token(TokenType.Filler)]),
    ]),
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
        OperationPrecedenceEntry(OperationVariety.LogicalOr, [Token(TokenType.Filler), OPR('|'), OPR('|'), Token(TokenType.Filler)]), 
    ]),
    OperatorPrecedenceLayer(OperatorOrder.RightToLeft, [
        OperationPrecedenceEntry(OperationVariety.Assignment, [Token(TokenType.Filler), OPR('='), Token(TokenType.Filler)]), // asignment
        OperationPrecedenceEntry(OperationVariety.AddEq, [Token(TokenType.Filler), OPR('+'), OPR('='), Token(TokenType.Filler)]),
        OperationPrecedenceEntry(OperationVariety.SubstractEq, [Token(TokenType.Filler), OPR('-'), OPR('='), Token(TokenType.Filler)]),
        OperationPrecedenceEntry(OperationVariety.MultiplyEq, [Token(TokenType.Filler), OPR('*'), OPR('='), Token(TokenType.Filler)]),
        OperationPrecedenceEntry(OperationVariety.DivideEq, [Token(TokenType.Filler), OPR('/'), OPR('='), Token(TokenType.Filler)]),
        OperationPrecedenceEntry(OperationVariety.ModEq, [Token(TokenType.Filler), OPR('%'), OPR('='), Token(TokenType.Filler)]),

        OperationPrecedenceEntry(OperationVariety.BitwiseAndEq, [Token(TokenType.Filler), OPR('&'), OPR('='), Token(TokenType.Filler)]),
        OperationPrecedenceEntry(OperationVariety.BitwiseXorEq, [Token(TokenType.Filler), OPR('^'), OPR('='), Token(TokenType.Filler)]),
        OperationPrecedenceEntry(OperationVariety.BitwiseOrEq, [Token(TokenType.Filler), OPR('|'), OPR('='), Token(TokenType.Filler)]),
        OperationPrecedenceEntry(OperationVariety.BitwiseNotEq, [Token(TokenType.Filler), OPR('~'), OPR('='), Token(TokenType.Filler)]),
    ])
    

];