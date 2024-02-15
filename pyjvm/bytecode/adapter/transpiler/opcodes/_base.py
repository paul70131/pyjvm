from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.transpiler.comptime.stack import Stack
#from pyjvm.bytecode.adapter.transpiler.comptime.frame import Frame

class PyOpcode:
    opcodes: dict[int, "PyOpcode"] = {}
    verified: bool
    opcode: int

    def __init_subclass__(cls) -> None:
        PyOpcode.opcodes[cls.opcode] = cls

    def transpile(bytecode: BytecodeWriter, pystack_offset: int, pystack_index: int, pylocals_index: int, cp, m) -> int:
        raise NotImplementedError
    
    def _transpile(self, bytecode: BytecodeWriter, *args, **kwargs):
        bytecode.start_instruction()
        self.transpile(bytecode, *args, **kwargs)
    
    def verify(self, stack: "Frame"):
        raise NotImplementedError
    
    def _verify(self, frame: "Frame"):
        before = frame.pc
        self.stack_depth = frame.stack.depth
        more = self.verify(frame)

        if frame.pc - before != self.size:
            raise ValueError(f"Instruction {self.__class__.__name__} did not update the program counter correctly")

        self.verified = True
        return more