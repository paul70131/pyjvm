from pyjvm.bytecode.adapter.transpiler.comptime.frame import Frame
from pyjvm.bytecode.adapter.transpiler.opcodes._base import PyOpcode
from pyjvm.bytecode.adapter.transpiler.comptime.types import ComptimeType, ComptimeObject, ComptimeBoolean, ComptimeList, ComptimeDouble, ComptimeLong, ComptimeString, ComptimePyObject
from pyjvm.bytecode.adapter.transpiler.comptime.stack import Stack

from dis import Instruction

from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes


class ROT_THREE(PyOpcode):
    opcode = 3

    def __init__(self, inst: Instruction):
        self.value = inst.arg

    def verify(self, frame: Frame):
        a1 = frame.stack.pop()
        a2 = frame.stack.pop()
        a3 = frame.stack.pop()

        frame.stack.push(a1)
        frame.stack.push(a3)
        frame.stack.push(a2)

        frame.pc += self.size

    def transpile(self, bc: BytecodeWriter, op_stack: Stack, locals: list, locals_offset: int, cp, m):
        a1 = op_stack.pop()
        a2 = op_stack.pop()
        a3 = op_stack.pop()

        op_stack.push(a1)
        op_stack.push(a3)
        op_stack.push(a2)

        bc.bc(Opcodes.DUP_X2)
        bc.bc(Opcodes.POP)