/// Propagation for CTFE to allow for working with symbols arbitrarily.
module fern.propagation;

import fern.symbols;

public struct Engine
{
public:
final:
    Glob glob;

    Symbol interpret(Function func)
    {
        return null;
    }
}