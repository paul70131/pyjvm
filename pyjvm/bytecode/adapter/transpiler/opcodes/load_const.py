from pyjvm.bytecode.adapter.transpiler.opcodes._base import PyOpcode

from dis import Instruction

from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes

class LOAD_CONST(PyOpcode):
    opcode = 100

    def __init__(self, inst: Instruction):
        self.value = inst.argval

        # this is a bit more complicated since its "typed". There are 2 types of LOAD_ATTR:
        # 1. LOAD_ATTR (JvmType) simply does a "getfield" on the object
        # 2. LOAD_ATTR (PythonType) does a "invokevirtual" on the object. Therefore we need to jump accordingly

    def transpile(self, bytecode: BytecodeWriter, pystack_offset: int, pystack_index: int, pylocals_index: int, cp, m) -> int:
        bytecode.bc(Opcodes.ALOAD)
        bytecode.u1(pystack_index)
        # stack: [..., pystack]
        if isinstance(self.value, int):
            entry = cp.find_long(self.value, True)
        elif isinstance(self.value, float):
            entry = cp.find_double(self.value, True)
        elif isinstance(self.value, str):
            entry = cp.find_jstring(self.value, True)
        elif self.value == None:
            entry = None
        else:
            raise Exception(f"Unknown constant type: {self.value}")

        pystack_offset += 1

        bytecode.bc(Opcodes.BIPUSH)
        bytecode.u1(pystack_offset)

        if self.value is None:
            bytecode.bc(Opcodes.ACONST_NULL)
        else:
            if isinstance(self.value, int) or isinstance(self.value, float):
                bytecode.bc(Opcodes.LDC2_W)
            else:
                bytecode.bc(Opcodes.LDC_W)
            bytecode.u2(entry.offset)


        if isinstance(self.value, int):
            entry = cp.find_methodref("java/lang/Long", "valueOf", "(J)Ljava/lang/Long;", True)
            bytecode.bc(Opcodes.INVOKESTATIC)
            bytecode.u2(entry.offset)
        if isinstance(self.value, float):
            entry = cp.find_methodref("java/lang/Double", "valueOf", "(D)Ljava/lang/Double;", True)
            bytecode.bc(Opcodes.INVOKESTATIC)
            bytecode.u2(entry.offset)
        
        bytecode.bc(Opcodes.AASTORE)



        return pystack_offset



