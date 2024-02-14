from pyjvm.bytecode.adapter.transpiler.opcodes._base import PyOpcode

from dis import Instruction

from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes

class STORE_FAST(PyOpcode):
    opcode = 125

    def __init__(self, inst: Instruction):
        self.index = inst.arg

    def transpile(self, bytecode: BytecodeWriter, pystack_offset: int, pystack_index: int, pylocals_index: int, cp, m) -> int:
        pystack_offset -= 1

        bytecode.bc(Opcodes.ALOAD)
        bytecode.u1(pylocals_index)

        bytecode.bc(Opcodes.BIPUSH)
        bytecode.u1(self.index)

        bytecode.bc(Opcodes.ALOAD)
        bytecode.u1(pystack_index)
        bytecode.bc(Opcodes.BIPUSH)
        bytecode.u1(pystack_offset + 1)
        bytecode.bc(Opcodes.AALOAD)

        bytecode.bc(Opcodes.AASTORE)

        return pystack_offset
