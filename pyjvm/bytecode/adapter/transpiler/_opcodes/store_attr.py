from pyjvm.bytecode.adapter.transpiler.opcodes._base import PyOpcode

from dis import Instruction

from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes

class STORE_ATTR(PyOpcode):
    opcode = 95

    def __init__(self, inst: Instruction):
        self.index = inst.argval

    def transpile(self, bytecode: BytecodeWriter, pystack_offset: int, pystack_index: int, pylocals_index: int, cp, m) -> int:
        pystack_offset

        bytecode.bc(Opcodes.ALOAD)
        bytecode.u1(pystack_index)

        bytecode.bc(Opcodes.DUP)

        # stack: [..., pystack]
        bytecode.bc(Opcodes.BIPUSH)
        bytecode.u1(pystack_offset)
        bytecode.bc(Opcodes.AALOAD)
        # stack: [..., pystack[pystack_offset]]
        bytecode.bc(Opcodes.LDC_W)
        bytecode.u2(cp.find_jstring(self.index, True).offset)

        bytecode.bc(Opcodes.SWAP)

        bytecode.bc(Opcodes.ALOAD)
        bytecode.u1(pystack_index)

        bytecode.bc(Opcodes.BIPUSH)
        bytecode.u1(pystack_offset + 1)

        bytecode.bc(Opcodes.AALOAD)

        bytecode.bc(Opcodes.INVOKESTATIC)
        bytecode.u2(cp.find_methodref("pyjvm/bridge/java/PyjvmBridge", "setField", "(Ljava/lang/String;Ljava/lang/Object;Ljava/lang/Object;)V", True).offset)

        return pystack_offset - 2



