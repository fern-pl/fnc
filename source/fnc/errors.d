module fnc.errors;

import std.exception;
import fnc.tokenizer.tokens : Token;
import fnc.treegen.ast_types : AstNode, getMinMax;

public static string GLOBAL_ERROR_STATE = null;

private struct ErrLineData
{
    size_t startOfLine = 0;
    size_t endOfProblemLine = 0;
    size_t lineCount = 0;
    size_t afterLineStart = 0;
}

ErrLineData getErrOfLine(size_t start)
{
    bool foundLine = false;
    size_t lineCount = 0;
    size_t afterLineStart = 0;
    size_t startOfLine = 0;
    size_t testIndex = 0;

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
        if (testIndex == start)
            foundLine = true;
        testIndex++;
    }

    return ErrLineData(startOfLine, testIndex, lineCount, afterLineStart);
}

class SyntaxError : Error
{
    this(string msg, AstNode node, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
    {
        import std.algorithm : min;
        size_t minI = -1;
        size_t maxI = 0;

        getMinMax(node, minI, maxI);

        maxI = min(maxI, GLOBAL_ERROR_STATE.length);
        
        ErrLineData data = getErrOfLine(minI);
        super(genErr(msg, data, minI, maxI), file, line, next);
    }
    this(string msg, AstNode[] nodes, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
    {
        import std.algorithm : min;
        size_t minI = -1;
        size_t maxI = 0;

        foreach (node; nodes)
        {
           getMinMax(node, minI, maxI); 
        }
        

        maxI = min(maxI, GLOBAL_ERROR_STATE.length);
        
        ErrLineData data = getErrOfLine(minI);
        super(genErr(msg, data, minI, maxI), file, line, next);
    }
    this(string msg, Token problemToken, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
    {
        ErrLineData data = getErrOfLine(problemToken.startingIndex);
        super(genErr(msg, data, problemToken.startingIndex, problemToken.startingIndex + problemToken
                .value.length), file, line, next);
    }
    // this(string msg, Token[] problemTokens, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
    // {
    //     ErrLineData data = getErrOfLine(problemToken.startingIndex);
    //     super(genErr(msg, data, problemToken.startingIndex, problemToken.startingIndex + problemToken
    //             .value.length), file, line, next);
    // }

    private static string genErr(string msg, ErrLineData errData, size_t start, size_t end)
    {
        import std.conv : to;

        string errorString = msg;

        import tern.string : AnsiColor;
        import core.exception;
        try{
            errorString ~= "\n Line: " ~ errData.lineCount.to!string;
            errorString ~= "\n Col: " ~ errData.afterLineStart.to!string;
            errorString ~= "\n\t";


            errorString ~= GLOBAL_ERROR_STATE[errData.startOfLine .. start];

            errorString ~= AnsiColor.BackgroundRed;

            errorString ~= GLOBAL_ERROR_STATE[start .. end];
            errorString ~= AnsiColor.Reset;
            import std.algorithm : max;
            // TODO: Make this better. 
            errorString ~= GLOBAL_ERROR_STATE[end .. max(errData.endOfProblemLine, end)];

            return errorString;
        }catch(ArraySliceError e){
            return msg ~ " (line and col can't be resolved. Please report this as a github issue with code samples)";
        }
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
