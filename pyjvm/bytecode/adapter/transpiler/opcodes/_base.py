from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.transpiler.comptime.stack import Stack
from pyjvm.bytecode.adapter.transpiler.comptime.frame import Frame

class PyOpcode:
    opcodes: dict[int, "PyOpcode"] = {}
    verified: bool
    opcode: int

    def __init_subclass__(cls) -> None:
        PyOpcode.opcodes[cls.opcode] = cls

    def transpile(bytecode: BytecodeWriter, pystack_offset: int, pystack_index: int, pylocals_index: int, cp, m) -> int:
        raise NotImplementedError
    
    def verify(self, stack: Frame):
        raise NotImplementedError
    
    def _verify(self, stack: Frame):
        print("Verifying", self.__class__.__name__)
        self.verify(stack)
        self.verified = True