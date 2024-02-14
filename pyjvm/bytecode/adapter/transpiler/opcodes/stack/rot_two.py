from pyjvm.bytecode.adapter.transpiler.opcodes._base import PyOpcode
from pyjvm.bytecode.adapter.transpiler.comptime.types import ComptimeType, ComptimeObject, ComptimeBoolean, ComptimeList, ComptimeDouble, ComptimeLong, ComptimeString, ComptimePyObject
from pyjvm.bytecode.adapter.transpiler.comptime.stack import Stack
from pyjvm.bytecode.adapter.transpiler.comptime.frame import Frame

from dis import Instruction

from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes


class ROT_TWO(PyOpcode):
    opcode = 2

    def __init__(self, inst: Instruction):
        self.value = inst.arg

    def verify(self, frame: Frame):
        v1 = frame.stack.pop()
        v2 = frame.stack.pop()

        frame.stack.push(v1)
        frame.stack.push(v2)

        frame.pc += 2

    def transpile(self, bc: BytecodeWriter, op_stack: Stack, locals: list, locals_offset: int, cp, m):
        v1 = op_stack.pop()
        v2 = op_stack.pop()
        op_stack.push(v1)
        op_stack.push(v2)

        bc.bc(Opcodes.SWAP)