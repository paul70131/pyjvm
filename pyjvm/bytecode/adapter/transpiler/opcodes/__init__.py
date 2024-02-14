from dis import Instruction
from ._base import PyOpcode

from .load import *
from .store import *
from .flow import *
from .operations import *
from .list import *
from .stack import *
from .iter import *


def get_opcode(opcode: int, inst: Instruction):
    if opcode not in PyOpcode.opcodes:
        print(f"Unknown opcode: {opcode}", inst)
        return None
    return PyOpcode.opcodes[opcode](inst)