from pyjvm.bytecode.adapter.transpiler.opcodes._base import PyOpcode

from dis import Instruction

from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes

class CALL_METHOD(PyOpcode):
    opcode = 161

    def __init__(self, inst: Instruction):
        self.argcount = inst.argval
        
    def transpile(self, bytecode: BytecodeWriter, pystack_offset: int, pystack_index: int, pylocals_index: int, cp, m) -> int:
        bytecode.bc(Opcodes.ALOAD)
        bytecode.u1(pystack_index)
        bytecode.bc(Opcodes.DUP)

        bytecode.bc(Opcodes.BIPUSH)
        bytecode.u1(self.argcount)
        bytecode.bc(Opcodes.ANEWARRAY)
        bytecode.u2(cp.find_class("java/lang/Object", True).offset)
        bytecode.bc(Opcodes.ASTORE)
        bytecode.u1(pylocals_index + 1)

        bytecode.bc(Opcodes.ALOAD)
        bytecode.u1(pystack_index)

        bytecode.bc(Opcodes.BIPUSH)
        bytecode.u1(pystack_offset - self.argcount + 1)

        bytecode.bc(Opcodes.ALOAD)
        bytecode.u1(pylocals_index + 1)

        bytecode.u1(Opcodes.ICONST_0)

        bytecode.bc(Opcodes.BIPUSH)
        bytecode.u1(self.argcount)

        bytecode.bc(Opcodes.INVOKESTATIC)
        bytecode.u2(cp.find_methodref("java/lang/System", "arraycopy", "(Ljava/lang/Object;ILjava/lang/Object;II)V", True).offset)

        # stack: [..., pystack]
        pystack_offset -= self.argcount

        bytecode.bc(Opcodes.BIPUSH)
        bytecode.u1(pystack_offset)

        bytecode.bc(Opcodes.AALOAD)
        # stack: [..., methodname]
        bytecode.bc(Opcodes.CHECKCAST)
        bytecode.u2(cp.find_class("java/lang/String", True).offset)

        bytecode.bc(Opcodes.ALOAD_0)
        # stack: [..., pystack, this]

        bytecode.bc(Opcodes.INVOKESTATIC)
        bytecode.u2(cp.find_methodref("pyjvm/bridge/java/PyjvmBridge", "getMethod", "(Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/reflect/Method;", True).offset)
        # stack: [..., method]

        bytecode.bc(Opcodes.ALOAD)
        bytecode.u1(pylocals_index + 1)
        # stack: [..., method, args]
        bytecode.bc(Opcodes.DUP2)
        # stack: [..., method, args, method, args]
        bytecode.bc(Opcodes.INVOKESTATIC)
        bytecode.u2(cp.find_methodref("pyjvm/bridge/java/PyjvmBridge", "tryAdapt", "(Ljava/lang/reflect/Method;[Ljava/lang/Object;)V", True).offset)

        bytecode.bc(Opcodes.ALOAD_0)
        bytecode.bc(Opcodes.SWAP)


        bytecode.bc(Opcodes.INVOKEVIRTUAL)
        bytecode.u2(cp.find_methodref("java/lang/reflect/Method", "invoke", "(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;", True).offset)
        # stack: [..., pystack, result]

        bytecode.bc(Opcodes.BIPUSH)
        bytecode.u1(pystack_offset)

        bytecode.bc(Opcodes.SWAP)

        bytecode.bc(Opcodes.AASTORE)

        return pystack_offset 