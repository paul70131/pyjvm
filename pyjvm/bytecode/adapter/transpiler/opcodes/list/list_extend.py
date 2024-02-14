from pyjvm.bytecode.adapter.transpiler.opcodes._base import PyOpcode
from pyjvm.bytecode.adapter.transpiler.comptime.types import ComptimeType, ComptimeList, ComptimeTuple, ComptimeBoolean, ComptimeDouble, ComptimeLong, ComptimeString, ComptimePyObject, ComptimeObject
from pyjvm.bytecode.adapter.transpiler.comptime.stack import Stack

from dis import Instruction

from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes


class LIST_EXTEND(PyOpcode):
    opcode = 162

    def __init__(self, inst: Instruction):
        self.value = inst.arg
        if self.value != 1:
            raise f"Invalid argument for LIST_EXTEND: {self.value}, not compatible with JVM"
        
    def verify(self, frame):
        tos = frame.stack.pop()
        to_extend = frame.stack.pop()
        
        if not isinstance(to_extend, ComptimeList):
            raise Exception(f"Cannot extend non-list object {to_extend}")
        
        if isinstance(tos, ComptimeTuple):
            frame.stack.push(ComptimeList(tos.subtype))
        else:
            frame.stack.push(tos)
        
        frame.pc += self.size
    

    def transpile(self, bc: BytecodeWriter, op_stack: Stack, locals: list, locals_offset: int, cp, m):
        
        tos = op_stack.pop()
        to_extend = op_stack.pop()

        
        if not isinstance(to_extend, ComptimeList):
            raise Exception(f"Cannot extend non-list object {to_extend}")
        
        if isinstance(tos, ComptimeTuple):
            tos.convert_to(ComptimeList, bc, cp)
            
        
        bc.bc(Opcodes.DUP_X1)

        bc.bc(Opcodes.INVOKEINTERFACE)
        bc.u2(cp.find_interface_methodref(ComptimeList.java_type, "addAll", "(Ljava/util/Collection;)Z", True).offset)
        bc.u1(2)
        bc.u1(0)

        bc.bc(Opcodes.POP)

        op_stack.push(to_extend)



        

        



