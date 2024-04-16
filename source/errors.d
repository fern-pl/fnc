module errors;
import std.exception;

static class SyntaxError : Exception
{
    mixin basicExceptionCtors;
}
