from .load_fast import LOAD_FAST
from .dup_top import DUP_TOP
from .load_const import LOAD_CONST
from .inplace_add import INPLACE_ADD

from dis import Instruction


from ._base import PyOpcode

def get_opcode(opcode: int, inst: Instruction):
    if opcode not in PyOpcode.opcodes:
        print(f"Unknown opcode: {opcode}", inst)
        return None
    return PyOpcode.opcodes[opcode](inst)