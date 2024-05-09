/// Propagation for CTFE to allow for working with symbols arbitrarily.
module fnc.propagation;

import fnc.symbols;
import fnc.emission;
import tern.object : ddup;

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
                    if (instr.operands[0].isVariable)
                        glob.variables[instr.operands[0].identifier].data = (cast(Variable)instr.operands[1]).data;
                    else if (instr.operands[0].isAlias)
                        glob.aliases[instr.operands[0].identifier].data = instr.operands[1];
                    break;
                default:
                    assert(0, "Unsupported CTFE instruction!");
            }
        }
        scope (exit) func = temp;
        return func.parameters[0];
    }
}