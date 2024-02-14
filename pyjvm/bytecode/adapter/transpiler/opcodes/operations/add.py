from pyjvm.bytecode.adapter.transpiler.opcodes._base import PyOpcode
from pyjvm.bytecode.adapter.transpiler.comptime.types import ComptimeType, ComptimeObject, ComptimeBoolean, ComptimeList, ComptimeDouble, ComptimeLong, ComptimeString, ComptimePyObject
from pyjvm.bytecode.adapter.transpiler.comptime.stack import Stack
from pyjvm.bytecode.adapter.transpiler.comptime.frame import Frame

from dis import Instruction

from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes


class BINARY_ADD(PyOpcode):
    opcode = 23

    def __init__(self, inst: Instruction):
        self.value = inst.arg

    def verify(self, frame: Frame):
        v1 = frame.stack.pop()
        v2 = frame.stack.pop()

        if isinstance(v1, ComptimeString) or isinstance(v2, ComptimeString):
            frame.stack.push(ComptimeString())
            return
    
        if isinstance(v1, ComptimeList) and isinstance(v2, ComptimeList):
            frame.stack.push(ComptimeList(v1.subtype))
            return
        
        if isinstance(v1, ComptimeLong) and isinstance(v2, ComptimeLong):
            frame.stack.push(ComptimeLong())
            return
        
        if isinstance(v1, ComptimeDouble) or isinstance(v2, ComptimeDouble):
            frame.stack.push(ComptimeDouble())
            return
        
        if isinstance(v1, ComptimeObject) or isinstance(v2, ComptimeObject):
            frame.stack.push(ComptimeObject("java/lang/Object"))
            return
        
        frame.pc += self.size




    def transpile(self, bc: BytecodeWriter, op_stack: Stack, locals: list, locals_offset: int, cp, m):
        v1 = op_stack.pop()
        v2 = op_stack.pop()

        before = bc.size()

        if isinstance(v1, ComptimeString) or isinstance(v2, ComptimeString):
            if not isinstance(v1, ComptimeString):
                bc.bc(Opcodes.INVOKEVIRTUAL)
                bc.u2(cp.find_methodref("java/lang/Object", "toString", "()Ljava/lang/String;", True).offset)

            if not isinstance(v2, ComptimeString):
                bc.bc(Opcodes.INVOKEVIRTUAL)
                bc.u2(cp.find_methodref("java/lang/Object", "toString", "()Ljava/lang/String;", True).offset)

            bc.bc(Opcodes.SWAP)
            bc.bc(Opcodes.INVOKEVIRTUAL)
            bc.u2(cp.find_methodref("java/lang/String", "concat", "(Ljava/lang/String;)Ljava/lang/String;", True).offset)

            op_stack.push(ComptimeString())
            return
    
        if isinstance(v1, ComptimeList) and isinstance(v2, ComptimeList):
            bc.bc(Opcodes.DUP_X1)
            bc.bc(Opcodes.INVOKEINTERFACE)
            bc.u2(cp.find_interface_methodref("java/util/List", "addAll", "(Ljava/util/Collection;)Z", True).offset)
            bc.u1(2)
            bc.u1(0)
            bc.bc(Opcodes.POP)

            op_stack.push(ComptimeList(v1.subtype))
            return

        if isinstance(v1, ComptimeLong) and isinstance(v2, ComptimeLong):
            v1.convert_to("J", bc, cp)
            bc.bc(Opcodes.DUP2_X1)
            bc.bc(Opcodes.POP2)
            v2.convert_to("J", bc, cp)
            bc.bc(Opcodes.LADD)
            bc.bc(Opcodes.INVOKESTATIC)
            bc.u2(cp.find_methodref("java/lang/Long", "valueOf", "(J)Ljava/lang/Long;", True).offset)
            op_stack.push(ComptimeLong())

        elif isinstance(v1, ComptimeDouble) or isinstance(v2, ComptimeDouble):
            v1.convert_to("D", bc, cp)
            bc.bc(Opcodes.DUP2_X1)
            bc.bc(Opcodes.POP2)
            v2.convert_to("D", bc, cp)
        
            bc.bc(Opcodes.DADD)
            bc.bc(Opcodes.INVOKESTATIC)
            bc.u2(cp.find_methodref("java/lang/Double", "valueOf", "(D)Ljava/lang/Double;", True).offset)
            op_stack.push(ComptimeDouble())
        elif isinstance(v1, ComptimeObject) or isinstance(v2, ComptimeObject):
            # this is the non optimized version. 
            bc.bc(Opcodes.INVOKESTATIC)
            bc.u2(cp.find_methodref("pyjvm/bridge/java/PyjvmBridge", "__add__", "(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;", True).offset)
            op_stack.push(ComptimeObject("java/lang/Object"))
        else:
            raise Exception(f"Unsupported operation add: {v1} + {v2}")
    
        




class INPLACE_ADD(BINARY_ADD):
    opcode = 55