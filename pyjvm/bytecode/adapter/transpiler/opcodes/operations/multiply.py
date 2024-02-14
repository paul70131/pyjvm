from pyjvm.bytecode.adapter.transpiler.comptime.frame import Frame
from pyjvm.bytecode.adapter.transpiler.opcodes._base import PyOpcode
from pyjvm.bytecode.adapter.transpiler.comptime.types import ComptimeType, ComptimeObject, ComptimeBoolean, ComptimeDouble, ComptimeLong, ComptimeString, ComptimePyObject
from pyjvm.bytecode.adapter.transpiler.comptime.stack import Stack

from dis import Instruction

from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes


class BINARY_MULTIPLY(PyOpcode):
    opcode = 20

    def __init__(self, inst: Instruction):
        self.value = inst.arg

    def verify(self, stack: Frame):
        v1 = stack.pop()
        v2 = stack.pop()

        if isinstance(v1, ComptimeString) or isinstance(v2, ComptimeString):
            stack.push(ComptimeString())

        elif isinstance(v1, ComptimeLong) and isinstance(v2, ComptimeLong):
            stack.push(ComptimeLong())

        elif isinstance(v1, ComptimeDouble) or isinstance(v2, ComptimeDouble):
            stack.push(ComptimeDouble())

        else:
            stack.push(ComptimeObject("java/lang/Object"))

        stack.pc += self.size

    def transpile(self, bc: BytecodeWriter, op_stack: Stack, locals: list, locals_offset: int, cp, m):
        v1 = op_stack.pop()
        v2 = op_stack.pop()

        if isinstance(v1, ComptimeString) or isinstance(v2, ComptimeString):
            if not isinstance(v1, ComptimeString):
                v1.convert_to("I", bc, cp)
                bc.bc(Opcodes.SWAP)

            elif not isinstance(v2, ComptimeString):
                v2.convert_to("I", bc, cp)


            
            bc.bc(Opcodes.SWAP)
            bc.bc(Opcodes.INVOKEVIRTUAL)
            bc.u2(cp.find_methodref("java/lang/String", "repeat", "(I)Ljava/lang/String;", True).offset)

            op_stack.push(ComptimeString())
            return

        if isinstance(v1, ComptimeLong) and isinstance(v2, ComptimeLong):
            v1.convert_to("J", bc, cp)
            bc.bc(Opcodes.DUP2_X1)
            bc.bc(Opcodes.POP2)
            v2.convert_to("J", bc, cp)
            bc.bc(Opcodes.LMUL)
            bc.bc(Opcodes.INVOKESTATIC)
            bc.u2(cp.find_methodref("java/lang/Long", "valueOf", "(J)Ljava/lang/Long;", True).offset)
            op_stack.push(ComptimeLong())

        elif isinstance(v1, ComptimeDouble) or isinstance(v2, ComptimeDouble):
            v1.convert_to("D", bc, cp)
            bc.bc(Opcodes.DUP2_X1)
            bc.bc(Opcodes.POP2)
            v2.convert_to("D", bc, cp)
        
            bc.bc(Opcodes.DMUL)
            bc.bc(Opcodes.INVOKESTATIC)
            bc.u2(cp.find_methodref("java/lang/Double", "valueOf", "(D)Ljava/lang/Double;", True).offset)
            op_stack.push(ComptimeDouble())
        elif isinstance(v1, ComptimeObject) or isinstance(v2, ComptimeObject):
            # this is the non optimized version. 
            bc.bc(Opcodes.INVOKESTATIC)
            bc.u2(cp.find_methodref("pyjvm/bridge/java/PyjvmBridge", "__mul__", "(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;", True).offset)
            op_stack.push(ComptimeObject())

        else:
            raise Exception(f"Unsupported operation multiply: {v1} * {v2}")



class INPLACE_MULTIPLY(BINARY_MULTIPLY):
    opcode = 57