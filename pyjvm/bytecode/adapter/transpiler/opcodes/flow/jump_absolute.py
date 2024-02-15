from pyjvm.bytecode.adapter.transpiler.comptime.frame import Frame
from pyjvm.bytecode.adapter.transpiler.opcodes._base import PyOpcode
from pyjvm.bytecode.adapter.transpiler.comptime.types import ComptimeType, ComptimeBoolean, ComptimeDouble, ComptimeLong, ComptimeString, ComptimePyObject, ComptimeObject
from pyjvm.bytecode.adapter.transpiler.comptime.stack import Stack

from dis import Instruction

from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes


class JUMP_ABSOLUTE(PyOpcode):
    opcode = 113

    def __init__(self, inst: Instruction):
        self.value = inst.argval

    def transpile(self, bc: BytecodeWriter, op_stack: Stack, locals: list, locals_offset: int, cp, m):
        # we need to pop the value from the stack and store it in the locals
        
        self.target = m.create_label(self.value, 2)
        bc.bc(Opcodes.GOTO)
        bc.s2(self.target)

    def verify(self, stack: Frame):
        stack2 = stack.copy(self.target.offset)
        
        stack.pc += self.size
        return [stack2,]

