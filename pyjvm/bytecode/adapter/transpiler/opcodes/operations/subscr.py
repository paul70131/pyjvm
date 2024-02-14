from pyjvm.bytecode.adapter.transpiler.comptime.frame import Frame
from pyjvm.bytecode.adapter.transpiler.opcodes._base import PyOpcode
from pyjvm.bytecode.adapter.transpiler.comptime.types import ComptimeType, ComptimeObject, ComptimeBoolean, ComptimeTuple, ComptimeList, ComptimeDouble, ComptimeLong, ComptimeString, ComptimePyObject
from pyjvm.bytecode.adapter.transpiler.comptime.stack import Stack

from dis import Instruction

from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes


class BINARY_SUBSCR(PyOpcode):
    opcode = 25

    def __init__(self, inst: Instruction):
        self.value = inst.arg

    def verify(self, frame: Frame):
        v1 = frame.stack.pop()
        v2 = frame.stack.pop()
        
        frame.pc += self.size

        if isinstance(v1, ComptimeLong) and isinstance(v2, ComptimeList):
            frame.stack.push(ComptimeObject(v2.subtype))
            return
        
        if isinstance(v1, ComptimeLong) and isinstance(v2, ComptimeTuple):
            frame.stack.push(ComptimeObject(v2.subtype))
            return
        
        raise Exception(f"Unsupported operation subscript: {v1} - {v2}")

    def transpile(self, bc: BytecodeWriter, op_stack: Stack, locals: list, locals_offset: int, cp, m):
        v1 = op_stack.pop()
        v2 = op_stack.pop()

        if isinstance(v1, ComptimeLong) and isinstance(v2, ComptimeList):
            v2.convert_to("I", bc, cp)
            #bc.bc(Opcodes.SWAP)
            bc.bc(Opcodes.INVOKEINTERFACE)
            bc.u2(cp.find_interface_methodref(ComptimeList.java_type, "get", "(I)Ljava/lang/Object;", True).offset)
            bc.u1(2)
            bc.u1(0)
            op_stack.push(ComptimeObject(v2.subtype))
            return
        
        if isinstance(v1, ComptimeLong) and isinstance(v2, ComptimeTuple):
            v2.convert_to("I", bc, cp)
            bc.bc(Opcodes.AALOAD)

            op_stack.push(ComptimeObject(v2.subtype))
            return

        raise Exception(f"Unsupported operation subscript: {v1} - {v2}")
    

class STORE_SUBSCR(BINARY_SUBSCR):
    opcode = 60