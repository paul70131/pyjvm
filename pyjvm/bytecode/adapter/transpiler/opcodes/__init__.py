from .load_fast import LOAD_FAST
from .dup_top import DUP_TOP
from .load_const import LOAD_CONST
from .add import INPLACE_ADD, BINARY_ADD
from .store_fast import STORE_FAST
from .return_value import RETURN_VALUE
from .load_method import LOAD_METHOD
from .call_method import CALL_METHOD
from .pop_top import POP_TOP
from .subtract import INPLACE_SUBTRACT, BINARY_SUBTRACT
from .multiply import INPLACE_MULTIPLY, BINARY_MULTIPLY
from .divide import INPLACE_TRUE_DIVIDE, BINARY_TRUE_DIVIDE
from .load_attr import LOAD_ATTR
from .rot_two import ROT_TWO
from .store_attr import STORE_ATTR

from dis import Instruction


from ._base import PyOpcode

def get_opcode(opcode: int, inst: Instruction):
    if opcode not in PyOpcode.opcodes:
        print(f"Unknown opcode: {opcode}", inst)
        return None
    return PyOpcode.opcodes[opcode](inst)