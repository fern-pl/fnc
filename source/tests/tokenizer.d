module tests.tokenizer;
import parsing.tokenizer.tokens;
import parsing.tokenizer.make_tokens;
import std.stdio;

unittest
{
    static foreach (example; [
        ["/*An example of a comment*/", "An example of a comment", ""],
        ["/*An example of a comment", "An example of a comment", ""],
        ["/*An example of a comment*/Some test text", "An example of a comment", "Some test text"],
        ["Text without a comment", "", "Text without a comment"]
    ])
    {{
        dchar[] stringWithComment = makeUnicodeString(example[0]);
        dchar[] commentFromString = makeUnicodeString(example[1]);
        dchar[] afterComment = makeUnicodeString(example[2]);

        size_t index = 0;
        dchar[] output = handleMultilineCommentsAtIndex(stringWithComment, index);

        assert(output == commentFromString);
        assert(stringWithComment[index..$] == afterComment);

    }}
}
