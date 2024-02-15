from pyjvm.bytecode.adapter.transpiler.comptime.frame import Frame
from pyjvm.bytecode.adapter.transpiler.opcodes._base import PyOpcode
from pyjvm.bytecode.adapter.transpiler.comptime.types import ComptimeType, ComptimeObject, ComptimeBoolean, ComptimeDouble, ComptimeLong, ComptimeString, ComptimePyObject
from pyjvm.bytecode.adapter.transpiler.comptime.stack import Stack

from dis import Instruction

from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes


class BINARY_TRUE_DIVIDE(PyOpcode):
    opcode = 27

    def __init__(self, inst: Instruction):
        self.value = inst.arg

    def verify(self, frame: Frame):
        v1 = frame.stack.pop()
        v2 = frame.stack.pop()

        if isinstance(v1, ComptimeLong) and isinstance(v2, ComptimeLong):
            frame.stack.push(ComptimeLong())
            frame.pc += self.size
            return

        if isinstance(v1, ComptimeDouble) or isinstance(v2, ComptimeDouble):
            frame.stack.push(ComptimeDouble())
            frame.pc += self.size
            return

        if isinstance(v1, ComptimeObject) or isinstance(v2, ComptimeObject):
            frame.stack.push(ComptimeObject("java/lang/Object"))
            frame.pc += self.size
            return

        frame.pc += self.size

    def transpile(self, bc: BytecodeWriter, op_stack: Stack, locals: list, locals_offset: int, cp, m):
        v1 = op_stack.pop()
        v2 = op_stack.pop()

        if isinstance(v1, ComptimeLong) and isinstance(v2, ComptimeLong):
            v1.convert_to("J", bc, cp)
            bc.bc(Opcodes.DUP2_X1)
            bc.bc(Opcodes.POP2)

            v2.convert_to("J", bc, cp)
            bc.bc(Opcodes.DUP2_X2)
            bc.bc(Opcodes.POP2)

            bc.bc(Opcodes.LDIV)
            bc.bc(Opcodes.INVOKESTATIC)
            bc.u2(cp.find_methodref("java/lang/Long", "valueOf", "(J)Ljava/lang/Long;", True).offset)
            op_stack.push(ComptimeLong())

        elif isinstance(v1, ComptimeDouble) or isinstance(v2, ComptimeDouble):
            v1.convert_to("D", bc, cp)
            bc.bc(Opcodes.DUP2_X1)
            bc.bc(Opcodes.POP2)
            v2.convert_to("D", bc, cp)
        
            bc.bc(Opcodes.DDIV)
            bc.bc(Opcodes.INVOKESTATIC)
            bc.u2(cp.find_methodref("java/lang/Double", "valueOf", "(D)Ljava/lang/Double;", True).offset)
            op_stack.push(ComptimeDouble())
        elif isinstance(v1, ComptimeObject) or isinstance(v2, ComptimeObject):
            # this is the non optimized version. 
            bc.bc(Opcodes.INVOKESTATIC)
            bc.u2(cp.find_methodref("pyjvm/bridge/java/PyjvmBridge", "__div__", "(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;", True).offset)
            op_stack.push(ComptimeObject())

        else:
            raise Exception(f"Unsupported operation subtract: {v1} - {v2}")



class INPLACE_TRUE_DIVIDE(BINARY_TRUE_DIVIDE):
    opcode = 29