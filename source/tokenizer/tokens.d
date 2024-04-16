module tokenizer.tokens;

enum TokenType
{
    Number,
    Operator,
    Braces,
    LetterCluster
}

struct Token
{
    TokenType tokenVariety;
    string value;
}
