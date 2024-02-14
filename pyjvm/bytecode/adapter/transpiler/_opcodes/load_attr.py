from pyjvm.bytecode.adapter.transpiler.opcodes._base import PyOpcode

from dis import Instruction

from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes

class LOAD_ATTR(PyOpcode):
    opcode = 106

    def __init__(self, inst: Instruction):
        self.index = inst.argval

        # this is a bit more complicated since its "typed". There are 2 types of LOAD_ATTR:
        # 1. LOAD_ATTR (JvmType) simply does a "getfield" on the object
        # 2. LOAD_ATTR (PythonType) does a "invokevirtual" on the object. Therefore we need to jump accordingly

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

        bytecode.bc(Opcodes.INVOKESTATIC)
        bytecode.u2(cp.find_methodref("pyjvm/bridge/java/PyjvmBridge", "getField", "(Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/Object;", True).offset)

        bytecode.bc(Opcodes.BIPUSH)
        bytecode.u1(pystack_offset)

        bytecode.bc(Opcodes.SWAP)

        bytecode.bc(Opcodes.AASTORE)

        return pystack_offset



