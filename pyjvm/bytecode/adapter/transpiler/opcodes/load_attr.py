from pyjvm.bytecode.adapter.transpiler.opcodes._base import PyOpcode

from dis import Instruction

from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes

class LOAD_ATTR(PyOpcode):
    opcode = 124

    def __init__(self, inst: Instruction):
        self.index = inst.arg

        # this is a bit more complicated since its "typed". There are 2 types of LOAD_ATTR:
        # 1. LOAD_ATTR (JvmType) simply does a "getfield" on the object
        # 2. LOAD_ATTR (PythonType) does a "invokevirtual" on the object. Therefore we need to jump accordingly

    def transpile(self, bytecode: BytecodeWriter, pystack_offset: int, pystack_index: int, cp) -> int:
        bytecode.bc(Opcodes.ALOAD)
        bytecode.u1(pystack_index)
        # stack: [..., pystack]
        bytecode.bc(Opcodes.ICONST_0)
        bytecode.bc(Opcodes.AALOAD)
        # stack: [..., pystack[pystack_offset]]
        bytecode.bc(Opcodes.DUP) 
        # stack: [...pystack[pystack_offset], pystack[pystack_offset]]
        pyobj = cp.find_class("pyjvm/bridge/java/PyObject")
        bytecode.bc(Opcodes.INSTANCEOF)
        bytecode.u2(pyobj)
        # stack: [...pystack[pystack_offset],  isinstance]
        bytecode.bc(Opcodes.IFEQ)
        bytecode.u2(bytecode.bc_offset + 3)


