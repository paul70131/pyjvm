from pyjvm.bytecode.adapter.transpiler.opcodes._base import PyOpcode

from dis import Instruction

from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes

class INPLACE_TRUE_DIVIDE(PyOpcode):
    opcode = 29

    def __init__(self, inst: Instruction):
        pass

    def transpile(self, bytecode: BytecodeWriter, pystack_offset: int, pystack_index: int, pylocals_index: int, cp, m) -> int:


        bytecode.bc(Opcodes.ALOAD)
        bytecode.u1(pystack_index)
        bytecode.bc(Opcodes.DUP)
        # stack: [..., pystack]
        bytecode.bc(Opcodes.BIPUSH)
        bytecode.u1(pystack_offset - 1)
        # stack: [..., pystack, pystack_offset]

        bytecode.bc(Opcodes.AALOAD)
        # stack: [..., pystack[pystack_offset]]

        bytecode.bc(Opcodes.ALOAD)
        bytecode.u1(pystack_index)
        # stack: [..., pystack[pystack_offset], pystack]


        bytecode.bc(Opcodes.BIPUSH)
        bytecode.u1(pystack_offset)
        bytecode.bc(Opcodes.AALOAD)
        # stack: [..., pystack[pystack_offset], pystack[pystack_offset]]

        bytecode.bc(Opcodes.INVOKESTATIC)
        bytecode.u2(cp.find_methodref("pyjvm/bridge/java/PyjvmBridge", "__div__", "(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;", True).offset)

        bytecode.bc(Opcodes.BIPUSH)
        bytecode.u1(pystack_offset)

        bytecode.bc(Opcodes.SWAP)

        bytecode.bc(Opcodes.AASTORE)

        return pystack_offset - 1



class BINARY_TRUE_DIVIDE(INPLACE_TRUE_DIVIDE):
    opcode = 27