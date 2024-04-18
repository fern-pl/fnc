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

OperatorPrecedenceLayer[] operatorPrecedence = [
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
        OperationPrecedenceEntry([OPR('+'), OPR('+'), Token(TokenType.Filler)]),
        OperationPrecedenceEntry([OPR('-'), OPR('-'), Token(TokenType.Filler)]),
        OperationPrecedenceEntry([Token(TokenType.Filler), OPR('+'), OPR('+')]),
        OperationPrecedenceEntry([Token(TokenType.Filler), OPR('-'), OPR('-')]),

        OperationPrecedenceEntry([OPR('!'), Token(TokenType.Filler)]), // Logical not
        OperationPrecedenceEntry([OPR('~'), Token(TokenType.Filler)]), // bitwise NOT
    ]),
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
        OperationPrecedenceEntry([Token(TokenType.Filler), OPR('*'), Token(TokenType.Filler)]),
        OperationPrecedenceEntry([Token(TokenType.Filler), OPR('/'), Token(TokenType.Filler)]),
        OperationPrecedenceEntry([Token(TokenType.Filler), OPR('%'), Token(TokenType.Filler)]),
    ]),
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
        OperationPrecedenceEntry([Token(TokenType.Filler), OPR('+'), Token(TokenType.Filler)]),
        OperationPrecedenceEntry([Token(TokenType.Filler), OPR('-'), Token(TokenType.Filler)]),
    ]),
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
        OperationPrecedenceEntry([Token(TokenType.Filler), OPR('<'), OPR('<'), Token(TokenType.Filler)]),
        OperationPrecedenceEntry([Token(TokenType.Filler), OPR('>'), OPR('>'), Token(TokenType.Filler)]),
    ]),
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
        OperationPrecedenceEntry([Token(TokenType.Filler), OPR('<'), OPR('='), Token(TokenType.Filler)]),
        OperationPrecedenceEntry([Token(TokenType.Filler), OPR('>'), OPR('='), Token(TokenType.Filler)]),
        OperationPrecedenceEntry([Token(TokenType.Filler), OPR('<'), Token(TokenType.Filler)]),
        OperationPrecedenceEntry([Token(TokenType.Filler), OPR('>'), Token(TokenType.Filler)]),
    ]),
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
        OperationPrecedenceEntry([Token(TokenType.Filler), OPR('!'), OPR('='), Token(TokenType.Filler)]),
        OperationPrecedenceEntry([Token(TokenType.Filler), OPR('='), OPR('='), Token(TokenType.Filler)]),
    ]),
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
        OperationPrecedenceEntry([Token(TokenType.Filler), OPR('&'), Token(TokenType.Filler)]), // Bitwise AND
    ]),
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
        OperationPrecedenceEntry([Token(TokenType.Filler), OPR('^'), Token(TokenType.Filler)]), // Bitwise XOR
    ]),
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
        OperationPrecedenceEntry([Token(TokenType.Filler), OPR('|'), Token(TokenType.Filler)]), // Bitwise OR
    ]),
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
        OperationPrecedenceEntry([Token(TokenType.Filler), OPR('&'), OPR('&'), Token(TokenType.Filler)]), // Logical and
    ]),
    OperatorPrecedenceLayer(OperatorOrder.LeftToRight, [
        OperationPrecedenceEntry([Token(TokenType.Filler), OPR('|'), OPR('|'), Token(TokenType.Filler)]), // Logical or
    ]),
    OperatorPrecedenceLayer(OperatorOrder.RightToLeft, [
        OperationPrecedenceEntry([Token(TokenType.Filler), OPR('='), Token(TokenType.Filler)]), // asignment
        OperationPrecedenceEntry([Token(TokenType.Filler), OPR('+'), OPR('='), Token(TokenType.Filler)]),
        OperationPrecedenceEntry([Token(TokenType.Filler), OPR('-'), OPR('='), Token(TokenType.Filler)]),
        OperationPrecedenceEntry([Token(TokenType.Filler), OPR('*'), OPR('='), Token(TokenType.Filler)]),
        OperationPrecedenceEntry([Token(TokenType.Filler), OPR('/'), OPR('='), Token(TokenType.Filler)]),
        OperationPrecedenceEntry([Token(TokenType.Filler), OPR('%'), OPR('='), Token(TokenType.Filler)]),

        OperationPrecedenceEntry([Token(TokenType.Filler), OPR('&'), OPR('='), Token(TokenType.Filler)]),
        OperationPrecedenceEntry([Token(TokenType.Filler), OPR('^'), OPR('='), Token(TokenType.Filler)]),
        OperationPrecedenceEntry([Token(TokenType.Filler), OPR('|'), OPR('='), Token(TokenType.Filler)]),
        OperationPrecedenceEntry([Token(TokenType.Filler), OPR('/'), OPR('='), Token(TokenType.Filler)]),
    ])
    

];