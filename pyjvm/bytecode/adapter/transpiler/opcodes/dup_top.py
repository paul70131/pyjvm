from pyjvm.bytecode.adapter.transpiler.opcodes._base import PyOpcode

from dis import Instruction

from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes

class DUP_TOP(PyOpcode):
    opcode = 4

    def __init__(self, inst: Instruction):
        pass

    def transpile(self, bytecode: BytecodeWriter, pystack_offset: int, pystack_index: int, cp) -> int:
        bytecode.u1(Opcodes.ALOAD)
        bytecode.u1(pystack_index)
        # stack: [..., pystack]
        bytecode.u1(Opcodes.BIPUSH)
        bytecode.u1(pystack_offset)
        # stack: [..., pystack, pystack_offset]

        bytecode.u1(Opcodes.ALOAD)
        bytecode.u1(pystack_index)
        # stack: [..., pystack, pystack_offset, pystack]

        bytecode.u1(Opcodes.BIPUSH)
        bytecode.u1(0)
        # stack: [..., pystack, pystack_offset, pystack, 0]

        bytecode.u1(Opcodes.AALOAD)
        # stack: [..., pystack, pystack_offset, pystack[pystack_offset]]

        bytecode.u1(Opcodes.AASTORE)

        return pystack_offset + 1

