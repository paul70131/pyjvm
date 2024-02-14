from pyjvm.bytecode.adapter.transpiler.comptime.frame import Frame
from pyjvm.bytecode.adapter.transpiler.opcodes._base import PyOpcode
from pyjvm.bytecode.adapter.transpiler.comptime.types import ComptimeType, ComptimeBoolean, ComptimeDouble, ComptimeLong, ComptimeString, ComptimePyObject
from pyjvm.bytecode.adapter.transpiler.comptime.stack import Stack

from dis import Instruction

from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes


class LOAD_FAST(PyOpcode):
    opcode = 124

    def __init__(self, inst: Instruction):
        self.value = inst.arg

        # this is a bit more complicated since its "typed". There are 2 types of LOAD_ATTR:
        # 1. LOAD_ATTR (JvmType) simply does a "getfield" on the object
        # 2. LOAD_ATTR (PythonType) does a "invokevirtual" on the object. Therefore we need to jump accordingly

    def verify(self, frame: Frame):
        frame.stack.push(frame.locals[self.value])
        frame.pc += self.size

    def transpile(self, bc: BytecodeWriter, op_stack: Stack, locals: list, locals_offset: int, cp, m):
        bc.bc(Opcodes.ALOAD)
        bc.u1(locals_offset + self.value)
        op_stack.push(locals[self.value])

