from pyjvm.bytecode.adapter.transpiler.opcodes._base import PyOpcode

from dis import Instruction

from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes

class INPLACE_ADD(PyOpcode):
    opcode = 55

    def __init__(self, inst: Instruction):
        pass

    def transpile(self, bytecode: BytecodeWriter, pystack_offset: int, pystack_index: int, cp) -> int:

        bytecode.bc(Opcodes.ALOAD)
        bytecode.u1(pystack_index)
        bytecode.bc(Opcodes.DUP)
        # stack: [..., pystack]
        bytecode.bc(Opcodes.BIPUSH)
        bytecode.u1(pystack_offset)
        # stack: [..., pystack, pystack_offset]

        bytecode.bc(Opcodes.AALOAD)
        # stack: [..., pystack[pystack_offset]]

        bytecode.bc(Opcodes.CHECKCAST)
        bytecode.u2(cp.find_class("java/lang/Integer", True).offset)
        bytecode.bc(Opcodes.INVOKEVIRTUAL)
        bytecode.u2(cp.find_methodref("java/lang/Integer", "intValue", "()I", True).offset)

        pystack_offset -= 1

        bytecode.bc(Opcodes.ALOAD)
        bytecode.u1(pystack_index)
        # stack: [..., pystack[pystack_offset], pystack]


        bytecode.bc(Opcodes.BIPUSH)
        bytecode.u1(pystack_offset)
        bytecode.bc(Opcodes.AALOAD)
        # stack: [..., pystack[pystack_offset], pystack[pystack_offset]]

        bytecode.bc(Opcodes.CHECKCAST)
        bytecode.u2(cp.find_class("java/lang/Integer", True).offset)
        bytecode.bc(Opcodes.INVOKEVIRTUAL)
        bytecode.u2(cp.find_methodref("java/lang/Integer", "intValue", "()I", True).offset)

        bytecode.bc(Opcodes.IADD)

        bytecode.bc(Opcodes.INVOKESTATIC)
        bytecode.u2(cp.find_methodref("java/lang/Integer", "valueOf", "(I)Ljava/lang/Integer;", True).offset)

        bytecode.bc(Opcodes.BIPUSH)
        bytecode.u1(pystack_offset)

        bytecode.bc(Opcodes.SWAP)

        bytecode.bc(Opcodes.AASTORE)

        return pystack_offset
