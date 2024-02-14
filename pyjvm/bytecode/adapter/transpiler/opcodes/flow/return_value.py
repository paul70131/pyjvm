from pyjvm.bytecode.adapter.transpiler.comptime.frame import Frame
from pyjvm.bytecode.adapter.transpiler.opcodes._base import PyOpcode
from pyjvm.bytecode.adapter.transpiler.comptime.types import ComptimeType, ComptimeBoolean, ComptimeDouble, ComptimeLong, ComptimeString, ComptimePyObject, ComptimeObject
from pyjvm.bytecode.adapter.transpiler.comptime.stack import Stack

from dis import Instruction

from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes


class RETURN_VALUE(PyOpcode):
    opcode = 83

    def __init__(self, inst: Instruction):
        self.value = inst.arg

    def verify(self, stack: Frame):
        if self.return_type != "V":
            stack.stack.pop()
        
        stack.pc += self.size
        stack.returned = True


    def transpile(self, bc: BytecodeWriter, op_stack: Stack, locals: list, locals_offset: int, cp, m):
        self.return_type = m.return_type
        # we need to pop the value from the stack and store it in the locals
        if m.return_type == "V":
            bc.bc(Opcodes.RETURN)

        value = op_stack.pop()

        if m.return_type[0] == "L":
            bc.bc(Opcodes.ARETURN)
        
        if m.return_type in ["Z", "B", "C", "S", "I"]:
            if isinstance(value, ComptimeObject):
                raise f"Cannot return object from a non-object method {m.return_type}"

            if isinstance(value, ComptimeDouble):
                value.convert_to(ComptimeLong, bc, cp)
            
            if isinstance(value, ComptimeLong):
                value.convert_to(m.return_type, bc, cp)
            
            bc.bc(Opcodes.IRETURN)

        if m.return_type == "F" or m.return_type == "D":
            if isinstance(value, ComptimeObject):
                raise f"Cannot return object from a non-object method {m.return_type}"

            if isinstance(value, ComptimeLong):
                value.convert_to(ComptimeDouble, bc, cp)

            if isinstance(value, ComptimeDouble):
                value.convert_to(m.return_type, bc, cp)
            
            bc.bc(Opcodes.FRETURN if m.return_type == "F" else Opcodes.DRETURN)

        if m.return_type == "J":
            if isinstance(value, ComptimeObject):
                raise f"Cannot return object from a non-object method {m.return_type}"

            if isinstance(value, ComptimeDouble):
                value.convert_to(ComptimeLong, bc, cp)
            
            if isinstance(value, ComptimeLong):
                value.convert_to(m.return_type, bc, cp)
            
            bc.bc(Opcodes.LRETURN)

        

        



