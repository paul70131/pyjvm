from pyjvm.bytecode.adapter.transpiler.opcodes._base import PyOpcode
from pyjvm.bytecode.adapter.transpiler.comptime.types import ComptimeType, ComptimeObject, ComptimeBoolean, ComptimeList, ComptimeDouble, ComptimeLong, ComptimeString, ComptimePyObject
from pyjvm.bytecode.adapter.transpiler.comptime.stack import Stack
from pyjvm.bytecode.adapter.transpiler.comptime.frame import Frame

from dis import Instruction

from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes


class CALL_METHOD(PyOpcode):
    opcode = 161

    def __init__(self, inst: Instruction):
        self.value = inst.arg

    def verify(self, frame: Frame):
        args = []
        for i in range(self.value):
            args.append(frame.stack.pop())
        obj = frame.stack.pop()
        method = frame.stack.pop()
        frame.stack.push(ComptimeObject("java/lang/Object"))

        frame.pc += self.size

    def transpile(self, bc: BytecodeWriter, op_stack: Stack, locals: list, locals_offset: int, cp, m):

        # we create a array with the arguments
        bc.bc(Opcodes.BIPUSH)
        bc.u1(self.value)
        bc.bc(Opcodes.ANEWARRAY)
        bc.u2(cp.find_class("java/lang/Object", True).offset)

        # stack: [..., method, obj, arg1, arg2, args]

        # we need to store the arguments in the array

        args = []

        for i in range(self.value):
            bc.bc(Opcodes.DUP_X1)
            bc.bc(Opcodes.SWAP)
            bc.bc(Opcodes.BIPUSH)
            bc.u1(i)
            bc.bc(Opcodes.SWAP)
            bc.bc(Opcodes.AASTORE)
            args.append(op_stack.pop())
        
        # stack: [..., method, obj, args]
        bc.bc(Opcodes.SWAP)
        # stack: [..., method, args, obj]
        bc.bc(Opcodes.DUP_X2)
        # stack: [..., obj, method, args, obj]
        bc.bc(Opcodes.POP)

        op_stack.pop() # Method
        op_stack.pop() # Object

        bc.bc(Opcodes.DUP2)
        bc.bc(Opcodes.INVOKESTATIC)
        bc.u2(cp.find_methodref("pyjvm/bridge/java/PyjvmBridge", "tryAdapt", "(Ljava/lang/reflect/Method;[Ljava/lang/Object;)V", True).offset)

        # stack: [..., obj, method, args]
        bc.bc(Opcodes.SWAP)
        bc.bc(Opcodes.DUP_X2)
        bc.bc(Opcodes.POP)
        # stack: [..., obj, args, method]	
        bc.bc(Opcodes.INVOKEVIRTUAL)
        bc.u2(cp.find_methodref("java/lang/reflect/Method", "invoke", "(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;", True).offset)

        # stack: [..., result]
        op_stack.push(ComptimeObject("java/lang/Object"))
