from pyjvm.bytecode.adapter.transpiler.comptime.frame import Frame
from pyjvm.bytecode.adapter.transpiler.opcodes._base import PyOpcode
from pyjvm.bytecode.adapter.transpiler.comptime.types import ComptimeType, ComptimeBoolean, ComptimeDouble, ComptimeLong, ComptimeString, ComptimePyObject, ComptimeMethod
from pyjvm.bytecode.adapter.transpiler.comptime.stack import Stack

from dis import Instruction

from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes


class LOAD_METHOD(PyOpcode):
    opcode = 160

    def __init__(self, inst: Instruction):
        self.value = inst.argval

    def verify(self, frame: Frame):
        # we need to push a ComptimeMethod object on the stack
        v1  = frame.stack.pop()
        frame.stack.push(ComptimeMethod())
        frame.stack.push(v1)
        frame.pc += self.size

    def transpile(self, bc: BytecodeWriter, op_stack: Stack, locals: list, locals_offset: int, cp, m):
        # there are multiple paths to this:
        # 1. type is known at compile time. We can use "sTop.getClass().getMethod("name", "signature")"
        # 2. type is not known at compile time. We need to use "sTop.getClass().getMethods()" and iterate over them, for this we use
        # pyjvm.bridge.java.PyjvmBridge.getMethod. A problem may occur if we have multiple methods with the same name but different
        # signatures. We need to handle this case

        # for now only the slow path is implemented. We also need to handle "type adapters".
        # those should map python method name, for ex. list.append to java method name, for ex. add

        obj = op_stack.pop()
        # TODO: implement the fast path


        # slow path

        bc.bc(Opcodes.LDC_W)
        bc.u2(cp.find_jstring(self.value, True).offset)

        bc.bc(Opcodes.SWAP)
        bc.bc(Opcodes.DUP_X1)

        bc.bc(Opcodes.INVOKESTATIC)
        bc.u2(cp.find_methodref("pyjvm/bridge/java/PyjvmBridge", "getMethod", "(Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/reflect/Method;", True).offset)

        op_stack.push(ComptimeMethod())
        op_stack.push(obj)

        bc.bc(Opcodes.SWAP)







