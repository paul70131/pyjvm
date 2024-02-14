from pyjvm.bytecode.adapter.transpiler.opcodes._base import PyOpcode

from dis import Instruction, Bytecode

from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes

import dis

class ROT_TWO(PyOpcode):
    opcode = 2
    
    def __init__(self, inst: Instruction):
        pass

    def transpile(self, bytecode: BytecodeWriter, pystack_offset: int, pystack_index: int, pylocals_index: int, cp, m) -> int:
        bytecode.bc(Opcodes.ALOAD)
        bytecode.u1(pystack_index)
        bytecode.bc(Opcodes.DUP)
        # stack: [..., pystack, pystack, pystack]
        bytecode.bc(Opcodes.BIPUSH)
        bytecode.u1(pystack_offset + 1)

        bytecode.bc(Opcodes.AALOAD)
        # stack: [..., pystack, pystack, pystack[pystack_offset]]
        bytecode.bc(Opcodes.SWAP)
        # stack: [..., pystack[pystack_offset], pystack]
        bytecode.bc(Opcodes.BIPUSH)
        bytecode.u1(pystack_offset - 1)
        bytecode.bc(Opcodes.AALOAD)
        # stack: [..., pystack[pystack_offset], pystack[pystack_offset - 1]]
        bytecode.bc(Opcodes.SWAP)
        # stack: [..., pystack[pystack_offset - 1], pystack[pystack_offset]]

        bytecode.bc(Opcodes.ALOAD)
        bytecode.u1(pystack_index)
        bytecode.bc(Opcodes.SWAP)
        bytecode.bc(Opcodes.BIPUSH)
        bytecode.u1(pystack_offset)
        bytecode.bc(Opcodes.SWAP)
        bytecode.bc(Opcodes.AASTORE)

        bytecode.bc(Opcodes.ALOAD)
        bytecode.u1(pystack_index)
        bytecode.bc(Opcodes.SWAP)
        bytecode.bc(Opcodes.BIPUSH)
        bytecode.u1(pystack_offset)
        bytecode.bc(Opcodes.SWAP)
        bytecode.bc(Opcodes.AASTORE)

        return pystack_offset
