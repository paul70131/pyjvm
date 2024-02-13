from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes

from .opcodes import get_opcode

import dis

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

    def __init__(self, cp, method_name: str, method: Callable, line_number_table, descriptor):
        self.cp = cp
        self.method_name = method_name
        self.method = method
        self.bytecode = BytecodeWriter(line_number_table)

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
            elif const is None:
                pass
            else:
                raise Exception(f"Unsupported constant type: {type(const)}")
            
    def write_bytecode(self):
        code = self.method.__code__
        locals_offset = code.co_argcount # +1 for self

        # generate init bytecode
        # create pyStack array with size of co_stacksize
        #javaLangObject = CP_Class.insert(self.class_file.constant_pool, "java/lang/Object")
        javaLangObject = self.cp.find_class("java/lang/Object", True)

        # bipush co_stacksize
        self.bytecode.bc(Opcodes.BIPUSH)
        if code.co_stacksize > 0xff:
            raise Exception("Stacksize too large")
        self.bytecode.u1(code.co_stacksize + 1) # 

        # newarray java/lang/Object
        self.bytecode.bc(Opcodes.ANEWARRAY)
        self.bytecode.u2(javaLangObject.offset)

        if locals_offset + 1 > 0xff:
            raise Exception("Locals too large")

        # astore locals_offset + 1
        self.bytecode.bc(Opcodes.ASTORE)
        self.bytecode.u1(locals_offset)
    
        pystack_index = locals_offset
        pystack_offset = -1

        # bipush co_locals
        self.bytecode.bc(Opcodes.BIPUSH)
        self.bytecode.u1(code.co_nlocals)

        # newarray java/lang/Object
        self.bytecode.bc(Opcodes.ANEWARRAY)
        self.bytecode.u2(javaLangObject.offset)

        # stack types are: java/lang/Object, java/lang/Double, java/lang/Long, pyjvm/bridge/java/PyObject
        # these types need seperate handling for certain opcodes. Currently we dont asume any types and are 100% dynamic.
        # to increase performance we could think about adding type information to the stack and locals array during bytecode generation.

        # astore locals_offset + 2
        self.bytecode.bc(Opcodes.ASTORE)
        self.bytecode.u1(locals_offset + 1)
        pylocals_index = locals_offset + 1

        # copy all arguments to the pylocals array
        self.do_arg_conversion(pylocals_index, code)

        self.bytecode.bc(Opcodes.NOP)
        self.bytecode.nextLine()
        
        for bc in dis.get_instructions(self.method):
            opc = get_opcode(bc.opcode, bc)
            if opc:
                self.bytecode.bc(Opcodes.NOP) # for debugging to see where the bytecode ends
                pystack_offset = opc.transpile(self.bytecode, pystack_offset, pystack_index, pylocals_index, self.cp, self)
    

        self.bytecode.nextLine()

    def do_arg_conversion(self, pylocals_index: int, code):
        for i in range(code.co_argcount):
            self.bytecode.bc(Opcodes.ALOAD)
            self.bytecode.u1(pylocals_index)
            self.bytecode.bc(Opcodes.BIPUSH)
            self.bytecode.u1(i)
            # load pyLocals
            if i == 0:
                sig = "L..." # self / this
            else:
                sig = self.args[i - 1]
            
            if sig[0] == "L":
                self.bytecode.bc(Opcodes.ALOAD)
                self.bytecode.u1(i)
                self.bytecode.bc(Opcodes.AASTORE)
            elif sig == "I" or sig == "Z" or sig == "B" or sig == "C" or sig == "S":
                self.bytecode.bc(Opcodes.ILOAD)
                self.bytecode.u1(i)
                self.bytecode.bc(Opcodes.I2L)
                self.bytecode.bc(Opcodes.INVOKESTATIC)
                self.bytecode.u2(self.cp.find_methodref("java/lang/Long", "valueOf", "(J)Ljava/lang/Long;", True).offset)
                self.bytecode.bc(Opcodes.AASTORE)
            elif sig == "L":
                self.bytecode.bc(Opcodes.LLOAD)
                self.bytecode.u1(i)
                self.bytecode.bc(Opcodes.INVOKESTATIC)
                self.bytecode.u2(self.cp.find_methodref("java/lang/Long", "valueOf", "(J)Ljava/lang/Long;", True).offset)
                self.bytecode.bc(Opcodes.AASTORE)
            elif sig == "F":
                self.bytecode.bc(Opcodes.FLOAD)
                self.bytecode.u1(i)
                self.bytecode.bc(Opcodes.F2D)
                self.bytecode.bc(Opcodes.INVOKESTATIC)
                self.bytecode.u2(self.cp.find_methodref("java/lang/Double", "valueOf", "(D)Ljava/lang/Double;", True).offset)
                self.bytecode.bc(Opcodes.AASTORE)
            elif sig == "D":
                self.bytecode.bc(Opcodes.DLOAD)
                self.bytecode.u1(i)
                self.bytecode.bc(Opcodes.INVOKESTATIC)
                self.bytecode.u2(self.cp.find_methodref("java/lang/Double", "valueOf", "(D)Ljava/lang/Double;", True).offset)
                self.bytecode.bc(Opcodes.AASTORE)
            else:
                raise Exception(f"Unsupported type: {sig}")








