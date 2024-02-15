from pyjvm.bytecode.adapter.transpiler.comptime.stack import Stack
from pyjvm.bytecode.adapter.transpiler.comptime.types import ComptimeType
from pyjvm.bytecode.adapter.transpiler.comptime.locals import Locals

class FrameRecord:
    def __init__(self, stack, locals, pc):
        self.stack = stack
        self.locals = locals
        self.pc = pc

    def __repr__(self):
        return f'FrameRecord(stack={self.stack}, locals={self.locals}, pc={self.pc})'

class Frame:
    stack: Stack
    pc: int
    locals: Locals[ComptimeType]
    returned: bool
    initial: bool

    initial_stack: Stack
    initial_locals: list[ComptimeType]
    start_pc: int
    end_pc: int

    tracking = False

    stackMapTable: dict[int, FrameRecord]

    def execute(self, bytecode: bytes, cp):
        from pyjvm.bytecode.adapter.transpiler.opcodes.java.bc import BC

        if self.pc == self.end_pc:
            self.returned = True

        visited = set()
        
        while not self.returned:
            op = BC.from_opcode(bytecode[self.pc])
            op.do_execute(self, bytecode[self.pc + 1:self.pc + op.width], cp)

            if self.pc in visited:
                break
            visited.add(self.pc)

    def reset(self):
        self.stack = self.initial_stack.copy()
        self.locals = self.initial_locals.copy(self)
        self.end_pc = self.pc
        self.pc = self.start_pc
        self.returned = False

    def __init__(self, locals: list[ComptimeType], pc, stackMapTable: dict[int, FrameRecord] = {}):
        self.stack = Stack(self)
        if isinstance(locals, Locals):
            self.locals = locals
        else:
            self.locals = Locals(self, locals)
        self.pc = pc
        self.returned = False

        self.stackMapTable = stackMapTable

        self.initial_stack = self.stack.copy()
        self.initial_locals = self.locals.copy(self)
        self.start_pc = pc
        self.initial = True

    def copy(self, pc: int):
        f = Frame([], self.pc + pc)
        f.stack = self.stack.copy()
        f.locals = self.locals.copy(f)
        f.stackMapTable = self.stackMapTable
        f.initial = False

        return f
    
    def localChanged(self, key, value):
        if not self.tracking:
            return
        record = FrameRecord(
            self.stack.copy(),
            self.locals.copy(),
            self.pc
        )
        if self.pc in self.stackMapTable:
            self.stackMapTable[self.pc].locals = self.locals.copy()
        self.stackMapTable[self.pc] = record

    def stackChanged(self, size, value=None):
        if not self.tracking:
            return
        record = FrameRecord(
            self.stack.copy(),
            self.locals.copy(),
            self.pc
        )
        if self.pc in self.stackMapTable:
            self.stackMapTable[self.pc].stack = self.stack.copy()
        self.stackMapTable[self.pc] = record
    
    def __repr__(self):
        return f'Frame(start_pc={self.start_pc}, initial_locals={self.initial_locals}, initial_stack={self.initial_stack}, pc={self.pc}, locals={self.locals}, stack={self.stack}, returned={self.returned})'

