from pyjvm.bytecode.adapter.transpiler.comptime.frame import Frame
from pyjvm.bytecode.adapter.transpiler.opcodes._base import PyOpcode
from pyjvm.bytecode.adapter.transpiler.comptime.types import ComptimeType, ComptimeList, ComptimeBoolean, ComptimeDouble, ComptimeLong, ComptimeString, ComptimePyObject, ComptimeObject
from pyjvm.bytecode.adapter.transpiler.comptime.stack import Stack

from dis import Instruction

from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes


class FOR_ITER(PyOpcode):
    opcode = 93

    def __init__(self, inst: Instruction):
        self.value = inst.argval # resolved pc of python bytecode instruction

    def verify(self, stack: Frame):
        # we need to pop the value from the stack and store it in the locals
        tos = stack.stack.pop()
        stack.stack.push(ComptimeObject("java/lang/Object"))

        stack.pc += self.size



    def transpile(self, bc: BytecodeWriter, op_stack: Stack, locals: list, locals_offset: int, cp, m):
        # we need to pop the value from the stack and store it in the locals
        tos = op_stack.pop()
        
        bc.bc(Opcodes.CHECKCAST)
        bc.u2(cp.find_class('java/util/Iterator', True).offset)
        
        bc.bc(Opcodes.DUP)
        bc.bc(Opcodes.INVOKEINTERFACE)
        bc.u2(cp.find_interface_methodref('java/util/Iterator', 'hasNext', '()Z', True).offset)
        bc.u1(1)
        bc.u1(0)

        self.target = m.create_label(self.value, 2)
        bc.bc(Opcodes.IFEQ)
        bc.s2(self.target)

        bc.bc(Opcodes.DUP)
        bc.bc(Opcodes.INVOKEINTERFACE)
        bc.u2(cp.find_interface_methodref('java/util/Iterator', 'next', '()Ljava/lang/Object;', True).offset)
        bc.u1(1)
        bc.u1(0)

        # technically iterator is also pushed but that can only be checked when the bytecode is generated
        op_stack.push(ComptimeObject("java/lang/Object"))


        

        

        



