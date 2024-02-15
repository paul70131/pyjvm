from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter, BytecodeLabel
from pyjvm.bytecode.adapter.util.opcodes import Opcodes

from pyjvm.bytecode.adapter.transpiler.comptime.types import ComptimeType, ComptimeActualDouble, ComptimeActualInt, ComptimeActualLong, ComptimeThis, ComptimeNull, ComptimeLong, ComptimeDouble, ComptimeBoolean, ComptimeString, ComptimePyObject, ComptimeObject
from pyjvm.bytecode.adapter.transpiler.comptime.stack import Stack
from pyjvm.bytecode.adapter.transpiler.comptime.frame import Frame, FrameRecord

from .opcodes import get_opcode
from queue import LifoQueue

import dis
from dis import Instruction

from typing import Callable

# all supported types are:

# int -> java/lang/Long
# float -> java/lang/Double
# bool -> java/lang/Boolean
# str -> java/lang/String                            

# object -> pyjvm/bridge/PyObject | java/lang/Object    # needs seperate bytecode ex: getfield | .getfield()

# list -> pyjvm/bridge/PyList | java/util/List          # can be used interchangeably
# dict -> pyjvm/bridge/PyMap | java/util/Map            # can be used interchangeably
# set -> pyjvm/bridge/PySet | java/util/Set             # can be used interchangeably

class TranspiledMethod:
    cp: object # constant pool
    method_name: str
    method: str
    bytecode: BytecodeWriter

    return_type: str

    def __init__(self, cp, method_name: str, method: Callable, line_number_table, stack_map_table, descriptor):
        self.cp = cp
        self.method_name = method_name
        self.method = method

        self.bytecode = BytecodeWriter(line_number_table, stack_map_table)

        self.signature = descriptor.signature
        self.return_type = descriptor.ret
        self.args = descriptor.args
    
    def transpile(self):
        self.save_constants()
        self.write_bytecode()

    def save_constants(self):
        # save co_consts to the constant_pool
        j_constants = []
        for const in self.method.__code__.co_consts:
            if isinstance(const, int):
                #cp = CP_Long.insert(self.class_file.constant_pool, const)
                cp = self.cp.find_long(const, True)
                j_constants.append(cp)
            elif isinstance(const, float):
                #cp = CP_Double.insert(self.class_file.constant_pool, const)
                cp = self.cp.find_double(const, True)
                j_constants.append(cp)
            elif isinstance(const, str):
                #cp = CP_String.insert(self.class_file.constant_pool, const)
                cp = self.cp.find_jstring(const, True)
                j_constants.append(cp)
            elif isinstance(const, tuple):
                # this is more complicated since java doesn't have a tuple type and can only have primitives in the constant pool.
                # the loading of this constant will be done in the "LOAD_CONST" opcode
                # in that opcode it will also be saved to the constant pool
                # this is just here to register the tuple type
                pass
            elif const is None:
                pass
            else:
                raise Exception(f"Unsupported constant type: {type(const)}")
            
    def write_bytecode(self):
        code = self.method.__code__
        # generate init bytecode
        # create pyStack array with size of co_stacksize
        #javaLangObject = CP_Class.insert(self.class_file.constant_pool, "java/lang/Object")
        javaLangObject = self.cp.find_class("java/lang/Object", True)

        op_stack = Stack()
        locals = [None] * code.co_nlocals 
        locals_offset = code.co_argcount
        self.code = code
        self.locals_offset = locals_offset

        self.do_arg_conversion(locals_offset, locals, code)
        startlocals = locals.copy()

        bcmap = {}

        instructions = list(dis.get_instructions(self.method))
        for bc in instructions:
            opc = get_opcode(bc.opcode, bc)
            if opc:
                before = self.bytecode.size()
                opc._transpile(self.bytecode, op_stack, locals, locals_offset, self.cp, self)
                opc.size = self.bytecode.size() - before
                opc.verified = False
                opc.py_loc = bc.offset
                bcmap[before] = opc

        self.fill_labels(instructions, bcmap)

        self.bytecode.nextLine()
        vframe = Frame(startlocals, 0)
        frames = self.verify(vframe, bcmap)

        records: list[FrameRecord] = list(vframe.stackMapTable.values())
        records.sort(key=lambda x: x.pc)

        for frame in frames:
            frame: Frame
            frame.reset()
            frame.execute(self.bytecode.bytes(), self.cp)


    def fill_labels(self, instructions: list[Instruction], bcmap: dict):
        labels = self.bytecode._labels
        for label in labels:
            label: BytecodeLabel
            for loc, bc in bcmap.items():
                if bc.py_loc == label.target:
                    label.resolve(loc)
                    break
            
            else:
                raise Exception(f"Could not find label target: {label.target}")
            
        self.bytecode.save_labels()

    def verify(self, frame: Frame, bcmap: dict):
        frames = []

        if frame.initial:
            self.verifyArgConversion(frame)
            frames.append(frame)

        while not frame.returned:
            bc = bcmap[frame.pc]
            if bc.verified:
                if bc.stack_depth != frame.stack.depth:
                    raise Exception(f"Stack depth mismatch: {bc} - {frame.stack} : {bc.stack_depth} - {frame.stack.depth}, {frame.pc}")
                break
            newframes = bc._verify(frame)
            if newframes:
                for newframe in newframes:
                    frames.append(newframe)
                    self.verify(newframe, bcmap)
        return frames
        
    
    def create_label(self, py_loc, size):
        return BytecodeLabel(py_loc, size)

    def verifyArgConversion(self, frame: Frame):
        for i in range(self.code.co_argcount):
            if i == 0:
                sig = "L..."
            else:
                sig = self.args[i - 1]
            
            if sig[0] == "L":
                if sig == "L...":
                    frame.stack.push(ComptimeObject("java/lang/Object"))
                else:
                    frame.stack.push(ComptimeObject(sig[1:]))
                frame.pc += 2 # aload
        
                frame.locals[self.locals_offset + i] = frame.stack.pop()
                frame.pc += 2 # astore
            
            elif sig == "I" or sig == "B" or sig == "C" or sig == "S":
                # aload
                frame.stack.push(ComptimeActualInt())
                frame.pc += 2
                frame.stack.pop()
                frame.stack.push(ComptimeActualLong())
                frame.pc += 1
                frame.stack.pop()
                frame.stack.push(ComptimeLong())
                frame.pc += 3 # invokestatic
                frame.locals[self.locals_offset + i] = frame.stack.pop()
                frame.pc += 2 # astore
            

                

            


    def do_arg_conversion(self, offset: int, locals, code):

        for i in range(code.co_argcount):
            # load pyLocals
            if i == 0:
                sig = "L..." # self / this
            else:
                sig = self.args[i - 1]
            
            if sig[0] == "L":
                self.bytecode.bc(Opcodes.ALOAD)
                self.bytecode.u1(i)
                self.bytecode.bc(Opcodes.ASTORE)
                self.bytecode.u1(offset + i)

                if sig == "L...":
                    locals[i] = ComptimeThis()
                else:
                    locals[i] = ComptimeObject(sig[1:])
                
            elif sig == "I" or sig == "B" or sig == "C" or sig == "S":
                self.bytecode.bc(Opcodes.ILOAD)
                self.bytecode.u1(i)
                self.bytecode.bc(Opcodes.I2L)
                self.bytecode.bc(Opcodes.INVOKESTATIC)
                self.bytecode.u2(self.cp.find_methodref("java/lang/Long", "valueOf", "(J)Ljava/lang/Long;", True).offset)
                self.bytecode.bc(Opcodes.ASTORE)
                self.bytecode.u1(offset + i)

                locals[i] = ComptimeLong()

            elif sig == "L":
                self.bytecode.bc(Opcodes.LLOAD)
                self.bytecode.u1(i)
                self.bytecode.bc(Opcodes.INVOKESTATIC)
                self.bytecode.u2(self.cp.find_methodref("java/lang/Long", "valueOf", "(J)Ljava/lang/Long;", True).offset)
                self.bytecode.bc(Opcodes.ASTORE)
                self.bytecode.u1(offset + i)

                locals[i] = ComptimeLong()

            elif sig == "F":
                self.bytecode.bc(Opcodes.FLOAD)
                self.bytecode.u1(i)
                self.bytecode.bc(Opcodes.F2D)
                self.bytecode.bc(Opcodes.INVOKESTATIC)
                self.bytecode.u2(self.cp.find_methodref("java/lang/Double", "valueOf", "(D)Ljava/lang/Double;", True).offset)
                self.bytecode.bc(Opcodes.ASTORE)
                self.bytecode.u1(offset + i)

                locals[i] = ComptimeDouble()
            elif sig == "D":
                self.bytecode.bc(Opcodes.DLOAD)
                self.bytecode.u1(i)
                self.bytecode.bc(Opcodes.INVOKESTATIC)
                self.bytecode.u2(self.cp.find_methodref("java/lang/Double", "valueOf", "(D)Ljava/lang/Double;", True).offset)
                self.bytecode.bc(Opcodes.ASTORE)
                self.bytecode.u1(offset + i)

                locals[i] = ComptimeDouble()
            else:
                raise Exception(f"Unsupported type: {sig}")








