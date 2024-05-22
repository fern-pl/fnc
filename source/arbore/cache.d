module arbore.cache;

import fnc.symbols;
import std.stdio;

public:
void store()
{
    dstring[Module] caches;
    foreach (symbol; glob.symbols.byValue)
    {
        if (!symbol.evaluated)
            continue;

        if (symbol._module !in caches)
            caches[symbol._module] = null;

        if (!symbol.isAliasSeq)
            caches[symbol._module] ~= "alias "d~symbol.identifier~" = "d~(cast(Alias)symbol).single.identifier~";"d;
        else
        {
            caches[symbol._module] ~= "alias[] "d~symbol.identifier~" = ["d;
            foreach (sym; (cast(Alias)symbol).many)
                caches[symbol._module] ~= sym.identifier~", "d;
            caches[symbol._module] = caches[symbol._module][0..$-2]~"];"d;
        }
    }
}