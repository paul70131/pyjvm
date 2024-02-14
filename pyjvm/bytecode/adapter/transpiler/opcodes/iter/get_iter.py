from pyjvm.bytecode.adapter.transpiler.comptime.frame import Frame
from pyjvm.bytecode.adapter.transpiler.opcodes._base import PyOpcode
from pyjvm.bytecode.adapter.transpiler.comptime.types import ComptimeType, ComptimeList, ComptimeBoolean, ComptimeDouble, ComptimeLong, ComptimeString, ComptimePyObject, ComptimeObject
from pyjvm.bytecode.adapter.transpiler.comptime.stack import Stack

from dis import Instruction

from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes


class GET_ITER(PyOpcode):
    opcode = 68

    def __init__(self, inst: Instruction):
        self.value = inst.argval

    def verify(self, stack: Frame):
        # we need to pop the value from the stack and store it in the locals
        stack.stack.pop()
        stack.stack.push(ComptimeObject("java/util/Iterator"))
        stack.pc += self.size
    

    def transpile(self, bc: BytecodeWriter, op_stack: Stack, locals: list, locals_offset: int, cp, m):
        # we need to pop the value from the stack and store it in the locals
        tos = op_stack.pop()
        bc.bc(Opcodes.CHECKCAST)
        bc.u2(cp.find_class('java/lang/Iterable', True).offset)
        bc.bc(Opcodes.INVOKEINTERFACE)
        bc.u2(cp.find_interface_methodref('java/lang/Iterable', 'iterator', '()Ljava/util/Iterator;', True).offset)
        bc.u1(1)
        bc.u1(0)

        op_stack.push(ComptimeObject("java/util/Iterator"))
        


        

        

        



