module errors;
import std.exception;
import parsing.tokenizer.tokens : Token;

public static string GLOBAL_ERROR_STATE = null;

class SyntaxError : Error
{

    this(string msg, Token problemToken, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
    {
        import std.conv : to;

        bool foundLine = false;
        size_t lineCount = 0;
        size_t afterLineStart = 0;
        size_t startOfLine = 0;
        size_t testIndex = 0;

        if (GLOBAL_ERROR_STATE != null && problemToken.startingIndex < GLOBAL_ERROR_STATE.length)
        {
            while (GLOBAL_ERROR_STATE.length > testIndex)
            {
                if (GLOBAL_ERROR_STATE[testIndex] == '\n')
                {
                    if (foundLine)
                        break;
                    lineCount++;
                    afterLineStart = 0;
                    startOfLine = testIndex;
                }
                else if (!foundLine)
                    afterLineStart++;
                if (testIndex == problemToken.startingIndex)
                    foundLine = true;
                testIndex++;
            }
        }
        import tern.string;

        string errorString = msg;
        errorString ~= "\n Line: " ~ lineCount.to!string;
        errorString ~= "\n Col: " ~ afterLineStart.to!string;

        errorString ~= GLOBAL_ERROR_STATE[startOfLine .. problemToken.startingIndex];

        errorString ~= AnsiColor.BackgroundRed;
        size_t endOfProblem = problemToken.startingIndex + problemToken.value.length;
        
        errorString ~= GLOBAL_ERROR_STATE[problemToken.startingIndex .. endOfProblem];
        errorString ~= AnsiColor.Reset;
        errorString ~= GLOBAL_ERROR_STATE[endOfProblem .. testIndex];

        super(errorString, file, line, next);
    }

    protected this(string msg, string file, size_t line, Throwable next = null) @nogc nothrow pure @safe
    {
        super(msg, file, line, next);
    }
}

// static class EofError : Exception
// {
//     mixin basicExceptionCtors;
// }

static class RequirementFailed : Exception
{
    mixin basicExceptionCtors;
}
