from pyjvm.bytecode.adapter.transpiler.comptime.stack import Stack
from pyjvm.bytecode.adapter.transpiler.comptime.types import ComptimeType


class Frame:
    stack: Stack
    pc: int
    locals: list[ComptimeType]
    returned: bool

    def __init__(self, locals: list[ComptimeType], pc):
        self.stack = Stack()
        self.locals = locals
        self.pc = pc
        self.returned = False

    def copy(self, pc: int):
        f = Frame(self.locals.copy())
        f.stack = self.stack.copy()
        f.pc = pc

        return f
