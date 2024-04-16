module errors;
import std.exception;

static class SyntaxError : Exception
{
    mixin basicExceptionCtors;
}

static class EofError : Exception
{
    mixin basicExceptionCtors;
}

static class RequirementFailed : Exception
{
    mixin basicExceptionCtors;
}
