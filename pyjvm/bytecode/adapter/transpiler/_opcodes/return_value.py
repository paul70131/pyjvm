from pyjvm.bytecode.adapter.transpiler.opcodes._base import PyOpcode

from dis import Instruction

from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes

class RETURN_VALUE(PyOpcode):
    opcode = 83

    def __init__(self, inst: Instruction):
        pass

    def transpile(self, bytecode: BytecodeWriter, pystack_offset: int, pystack_index: int, pylocals_index: int, cp, m) -> int:

        if m.return_type == "V":
            bytecode.bc(Opcodes.RETURN)

        elif m.return_type[0] == "L" or m.return_type[0] == "[":
            bytecode.bc(Opcodes.ALOAD)
            bytecode.u1(pystack_index)
            bytecode.bc(Opcodes.BIPUSH)
            bytecode.u1(pystack_offset)
            bytecode.bc(Opcodes.AALOAD)
            bytecode.bc(Opcodes.ARETURN)

        elif m.return_type == "I":
            bytecode.bc(Opcodes.ALOAD)
            bytecode.u1(pystack_index)
            bytecode.bc(Opcodes.BIPUSH)
            bytecode.u1(pystack_offset)
            bytecode.bc(Opcodes.AALOAD)
            bytecode.bc(Opcodes.CHECKCAST)
            bytecode.u2(cp.find_class("java/lang/Long", True).offset)
            bytecode.bc(Opcodes.INVOKEVIRTUAL)
            bytecode.u2(cp.find_methodref("java/lang/Long", "intValue", "()I", True).offset)
            bytecode.bc(Opcodes.IRETURN)
        else:
            raise NotImplementedError(f"Return type {m.return_type} not implemented")

        return pystack_offset - 1
