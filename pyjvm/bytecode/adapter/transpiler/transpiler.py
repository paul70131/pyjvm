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

    def __init__(self, cp, method_name: str, method: Callable):
        self.cp = cp
        self.method_name = method_name
        self.method = method
        self.bytecode = BytecodeWriter()

    
    def transpile(self):
        self.generate_signature()
        self.save_constants()
        self.write_bytecode()

    def generate_signature(self):
        # generate signature
        
        javaLangObject = "Ljava/lang/Object;"

        self.signature = f"({javaLangObject * (self.method.__code__.co_argcount)}){javaLangObject}"

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
        pystack_offset = 0

        self.bytecode.bc(Opcodes.NOP)
        
        for bc in dis.get_instructions(self.method):
            print(bc)
            opc = get_opcode(bc.opcode, bc)
            if opc:
                pystack_offset = opc.transpile(self.bytecode, pystack_offset, pystack_index, self.cp)
                self.bytecode.bc(Opcodes.NOP) # for debugging to see where the bytecode ends

        
        self.bytecode.bc(Opcodes.RETURN)







