from pyjvm.bytecode.adapter.transpiler.opcodes._base import PyOpcode
from pyjvm.bytecode.adapter.transpiler.comptime.types import ComptimeType, ComptimeBoolean, ComptimeDouble, ComptimeLong, ComptimeString, ComptimePyObject
from pyjvm.bytecode.adapter.transpiler.comptime.stack import Stack

from dis import Instruction

from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes


from pyjvm.bytecode.adapter.transpiler.comptime.frame import Frame

class STORE_FAST(PyOpcode):
    opcode = 125

    def __init__(self, inst: Instruction):
        self.value = inst.arg

    def verify(self, frame: Frame):
        frame.locals[self.value] = frame.stack.pop()
        frame.pc += self.size

    def transpile(self, bc: BytecodeWriter, op_stack: Stack, locals: list, locals_offset: int, cp, m):
        # we need to pop the value from the stack and store it in the locals
        value = op_stack.pop()

        bc.bc(Opcodes.ASTORE)
        bc.u1(locals_offset + self.value)

        locals[self.value] = value
        
        

        



