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

    Symbol interpret(Function func, Symbol[] parameters)
    {
        // TODO: Restore all parameters? 
        Symbol[] state = func.locals;
        // ?? ungggg
        foreach (i, var; func.locals)
        {
            if ((var.attr & SymAttr.STATIC) == 0 && (var.attr & SymAttr.REF) == 0 && var.isVariable)
                state[i] = cast(Symbol)var.freeze();
        }

        if (parameters.length > 0)
            func.locals[parameters.length..$] = cast(Variable[])parameters;
        
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
                case CALL:
                    if (instr.operands[0].name == "rt.cast")
                        (cast(Variable)instr.operands[1]).data = (cast(Variable)instr.operands[2]).data.dup;
                    else
                    {
                        Symbol[] params = (cast(Function)instr.operands[0]).parameters;
                        foreach (i, operand; instr.operands[1..$])
                        {
                            if ((operand.attr & SymAttr.REF) == 0 && (operand.attr & SymAttr.CONST) != 0 && operand.isVariable)
                                params[i] = cast(Symbol)operand.freeze();
                        }
                        interpret(cast(Function)instr.operands[0], params);
                    }
                    break;
                default:
                    assert(0, "Unsupported CTFE instruction!");
            }
        }

        scope (exit)
        {
            func.locals = state;
            func.parameters[parameters.length..$] = state;
        }
        // Maybe?
        return func.locals[0].freeze();
    }
}