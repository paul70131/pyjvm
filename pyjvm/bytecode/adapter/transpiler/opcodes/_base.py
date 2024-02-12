from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter

class PyOpcode:
    opcodes: dict[int, "PyOpcode"] = {}

    opcode: int

    def __init_subclass__(cls) -> None:
        PyOpcode.opcodes[cls.opcode] = cls

    def transpile(bytecode: BytecodeWriter, pystack_offset: int, pystack_index: int, cp) -> int:
        raise NotImplementedError