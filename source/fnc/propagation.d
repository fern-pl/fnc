/// Propagation for CTFE to allow for working with symbols arbitrarily.
module fnc.propagation;

import fnc.symbols;
import fnc.emission;

public struct Engine
{
public:
final:
    Glob glob;

    Symbol interpret(Function func)
    {
        Function temp = func.ddup;
        foreach (instr; func.instructions)
        {
            with (OpCode) switch (instr.opcode)
            {
                case MOV:
                    Symbol lhs = glob.symbols[instr.operands[0]];
                    Symbol rhs = glob.symbols[instr.operands[1]];

                    if (lhs.isVariable)
                        (cast(Variable)lhs).data = (cast(Variable)rhs).data.dup;
                    else if (lhs.isAlias)
                        (cast(Alias)lhs).data = rhs;
                    break;
                default:
                    assert(0, "Unsupported CTFE instruction!");
            }
        }
        scope (exit) func = temp;
        return func.parameters[0];
    }
}