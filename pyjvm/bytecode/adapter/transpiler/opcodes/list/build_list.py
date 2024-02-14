from pyjvm.bytecode.adapter.transpiler.comptime.frame import Frame
from pyjvm.bytecode.adapter.transpiler.opcodes._base import PyOpcode
from pyjvm.bytecode.adapter.transpiler.comptime.types import ComptimeType, ComptimeList, ComptimeBoolean, ComptimeDouble, ComptimeLong, ComptimeString, ComptimePyObject, ComptimeObject
from pyjvm.bytecode.adapter.transpiler.comptime.stack import Stack


from dis import Instruction

from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes


class BUILD_LIST(PyOpcode):
    opcode = 103

    def __init__(self, inst: Instruction):
        self.value = inst.arg

    def verify(self, frame: Frame):
        for i in range(self.value):
            frame.stack.pop()
        frame.stack.push(ComptimeList("java/lang/Object"))

        frame.pc += self.size
    

    def transpile(self, bc: BytecodeWriter, op_stack: Stack, locals: list, locals_offset: int, cp, m):
        # we need to pop the value from the stack and store it in the locals
        bc.bc(Opcodes.NEW)
        bc.u2(cp.find_class(ComptimeList.implementation, True).offset)
        bc.bc(Opcodes.DUP)
        bc.bc(Opcodes.INVOKESPECIAL)
        bc.u2(cp.find_methodref(ComptimeList.implementation, "<init>", "()V", True).offset)

        for i in range(self.value):
            bc.bc(Opcodes.DUP_X1)
            bc.bc(Opcodes.SWAP)
            bc.bc(Opcodes.INVOKEVIRTUAL)
            bc.u2(cp.find_methodref(ComptimeList.implementation, "add", "(Ljava/lang/Object;)Z", True).offset)
            bc.bc(Opcodes.POP)
            op_stack.pop()

        op_stack.push(ComptimeList("java/lang/Object"))
        

        

        



