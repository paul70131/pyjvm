from pyjvm.bytecode.adapter.transpiler.comptime.frame import Frame
from pyjvm.bytecode.adapter.transpiler.opcodes._base import PyOpcode
from pyjvm.bytecode.adapter.transpiler.comptime.types import ComptimeType, ComptimeNull, ComptimeBoolean, ComptimeDouble, ComptimeLong, ComptimeString, ComptimePyObject, ComptimeTuple
from pyjvm.bytecode.adapter.transpiler.comptime.stack import Stack

from dis import Instruction

from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes


class LOAD_CONST(PyOpcode):
    opcode = 100

    def verify(self, frame: Frame):
        if isinstance(self.value, int):
            frame.stack.push(ComptimeLong())
        elif isinstance(self.value, float):
            frame.stack.push(ComptimeDouble())
        elif isinstance(self.value, str):
            frame.stack.push(ComptimeString())
        elif isinstance(self.value, tuple):
            frame.stack.push(ComptimeTuple("java/lang/Object"))
        elif self.value == None:
            frame.stack.push(ComptimeNull())
        
        frame.pc += self.size


    def __init__(self, inst: Instruction = None, value = None):
        if not inst and not value:
            raise Exception("Either inst or value must be provided")
        if inst:
            self.value = inst.argval
        else:
            self.value = value

        # this is a bit more complicated since its "typed". There are 2 types of LOAD_ATTR:
        # 1. LOAD_ATTR (JvmType) simply does a "getfield" on the object
        # 2. LOAD_ATTR (PythonType) does a "invokevirtual" on the object. Therefore we need to jump accordingly

    def transpile(self, bc: BytecodeWriter, op_stack: Stack, locals: list, locals_offset: int, cp, m):
        if isinstance(self.value, int):
            entry = cp.find_long(self.value, True)
            bc.bc(Opcodes.LDC2_W)
            bc.u2(entry.offset)
            bc.bc(Opcodes.INVOKESTATIC)
            bc.u2(cp.find_methodref("java/lang/Long", "valueOf", "(J)Ljava/lang/Long;", True).offset)
            op_stack.push(ComptimeLong())

        elif isinstance(self.value, float):
            entry = cp.find_double(self.value, True)
            bc.bc(Opcodes.LDC2_W)
            bc.u2(entry.offset)
            bc.bc(Opcodes.INVOKESTATIC)
            bc.u2(cp.find_methodref("java/lang/Double", "valueOf", "(D)Ljava/lang/Double;", True).offset)
            op_stack.push(ComptimeDouble())

        elif isinstance(self.value, str):
            entry = cp.find_jstring(self.value, True)
            bc.bc(Opcodes.LDC_W)
            bc.u2(entry.offset)
            op_stack.push(ComptimeString())

        elif isinstance(self.value, tuple):
            # tuples are represented as arrays.
            l = len(self.value)
            bc.bc(Opcodes.BIPUSH)
            bc.u1(l)
            bc.bc(Opcodes.ANEWARRAY)
            bc.u2(cp.find_class("java/lang/Object", True).offset)

            for i, v in enumerate(self.value):
                bc.bc(Opcodes.DUP)
                opc = LOAD_CONST(value=v)
                opc.transpile(bc, op_stack, locals, locals_offset, cp, m) # this will push the value to the stack
                bc.bc(Opcodes.BIPUSH)
                bc.u1(i)
                bc.bc(Opcodes.SWAP)
                bc.bc(Opcodes.AASTORE)

                op_stack.pop()
            
            op_stack.push(ComptimeTuple("java/lang/Object"))

        elif self.value == None:
            bc.bc(Opcodes.ACONST_NULL)
            op_stack.push(ComptimeNull())
        else:
            raise Exception(f"Unknown constant type: {self.value}")
        
        

        



