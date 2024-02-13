from pyjvm.bytecode.adapter.transpiler.opcodes._base import PyOpcode

from dis import Instruction

from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes

class LOAD_METHOD(PyOpcode):
    opcode = 160

    def __init__(self, inst: Instruction):
        self.methodname = inst.argval
        
    def transpile(self, bytecode: BytecodeWriter, pystack_offset: int, pystack_index: int, pylocals_index: int, cp, m) -> int:
        pystack_offset += 1

        # for now this just puts a String with the method name on the pyStack. Further action is done by the CALL_METHOD opcode

        bytecode.bc(Opcodes.ALOAD)
        bytecode.u1(pystack_index)
        bytecode.bc(Opcodes.BIPUSH)
        bytecode.u1(pystack_offset)

        bytecode.bc(Opcodes.LDC_W)
        bytecode.u2(cp.find_jstring(self.methodname, True).offset)

        bytecode.bc(Opcodes.AASTORE)

        return pystack_offset