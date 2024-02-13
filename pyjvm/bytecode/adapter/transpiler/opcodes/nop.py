from pyjvm.bytecode.adapter.transpiler.opcodes._base import PyOpcode

from dis import Instruction, Bytecode

from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes

import dis

class NOP(PyOpcode):
    opcode = dis.opmap["NOP"]
    
    def __init__(self, inst: Instruction):
        pass

    def transpile(self, bytecode: BytecodeWriter, pystack_offset: int, pystack_index: int, pylocals_index: int, cp, m) -> int:
        return pystack_offset
