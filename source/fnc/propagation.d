/// Propagation for CTFE to allow for working with symbols arbitrarily.
module fnc.propagation;

import fnc.symbols;
import fnc.emission;
import std.typecons;
import tern.object : qdup;

public struct Engine
{
public:
final:
    Glob glob;

    Symbol interpret(Function func)
    {
        Variable[] state;
        foreach (var; func.locals)
            state ~= var.qdup;
        
        foreach (instr; func.instructions)
        {
            with (OpCode) switch (instr.opcode)
            {
                case MOV:
                    if (instr.operands[0].isVariable)
                        (cast(Variable)instr.operands[0]).data = (cast(Variable)instr.operands[1]).data.dup;
                    else if (instr.operands[0].isAlias)
                        (cast(Alias)instr.operands[0]).data = instr.operands[1];
                    break;
                default:
                    assert(0, "Unsupported CTFE instruction!");
            }
        }

        scope (exit) func.locals = state;
        return func.parameters[0];
    }
}