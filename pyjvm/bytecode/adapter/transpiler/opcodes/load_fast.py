from pyjvm.bytecode.adapter.transpiler.opcodes._base import PyOpcode

from dis import Instruction

from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes

class LOAD_FAST(PyOpcode):
    opcode = 124

    def __init__(self, inst: Instruction):
        self.index = inst.arg

    def transpile(self, bytecode: BytecodeWriter, pystack_offset: int, pystack_index: int, cp) -> int:
        bytecode.bc(Opcodes.ALOAD)
        bytecode.u1(pystack_index)
        bytecode.bc(Opcodes.BIPUSH)
        bytecode.u1(self.index)
        bytecode.bc(Opcodes.ALOAD)
        bytecode.u1(self.index)
        bytecode.bc(Opcodes.AASTORE)
        return pystack_offset + 1
