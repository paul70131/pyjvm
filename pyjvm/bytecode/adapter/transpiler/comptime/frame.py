from pyjvm.bytecode.adapter.transpiler.comptime.stack import Stack
from pyjvm.bytecode.adapter.transpiler.comptime.types import ComptimeType


class Frame:
    stack: Stack
    pc: int
    locals: list[ComptimeType]
    returned: bool

    initial_stack: Stack
    initial_locals: list[ComptimeType]
    start_pc: int

    def __init__(self, locals: list[ComptimeType], pc):
        self.stack = Stack()
        self.locals = locals
        self.pc = pc
        self.returned = False

        self.initial_stack = self.stack.copy()
        self.initial_locals = self.locals.copy()
        self.start_pc = pc

    def copy(self, pc: int):
        f = Frame(self.locals.copy(), self.pc + pc)
        f.stack = self.stack.copy()

        return f
    
    def __repr__(self):
        return f'Frame(start_pc={self.start_pc}, initial_locals={self.initial_locals}, initial_stack={self.initial_stack}, pc={self.pc}, locals={self.locals}, stack={self.stack}, returned={self.returned})'

