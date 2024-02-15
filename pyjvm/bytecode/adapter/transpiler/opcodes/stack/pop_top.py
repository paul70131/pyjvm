from pyjvm.bytecode.adapter.transpiler.opcodes._base import PyOpcode
from pyjvm.bytecode.adapter.transpiler.comptime.types import ComptimeType, ComptimeObject, ComptimeBoolean, ComptimeList, ComptimeDouble, ComptimeLong, ComptimeString, ComptimePyObject
from pyjvm.bytecode.adapter.transpiler.comptime.stack import Stack

from dis import Instruction

from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes

from pyjvm.bytecode.adapter.transpiler.comptime.frame import Frame


class POP_TOP(PyOpcode):
    opcode = 1

    def __init__(self, inst: Instruction):
        self.value = inst.arg


    def verify(self, stack: Frame):
        stack.stack.pop()
        stack.pc += 1

    def transpile(self, bc: BytecodeWriter, op_stack: Stack, locals: list, locals_offset: int, cp, m):
        op_stack.pop()
        bc.bc(Opcodes.POP)