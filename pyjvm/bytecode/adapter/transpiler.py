from pyjvmbc import ClassFile
from pyjvmbc.klass.constant_pool import CP_Long, CP_Double, CP_String, CP_Class

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
    class_file: ClassFile
    method_name: str
    method: str

    def __init__(self, class_file: ClassFile, method_name: str, method: Callable):
        self.class_file = class_file
        self.method_name = method_name
        self.method = method

    
    def transpile(self):
        self.generate_signature()
        self.save_constants()
        bc = self.write_bytecode()

    def generate_signature(self):
        # generate signature
        
        javaLangObject = "Ljava/lang/Object;"

        self.signature = f"({javaLangObject * (self.method.__code__.co_argcount)}){javaLangObject}"

    def save_constants(self):
        # save co_consts to the constant_pool
        j_constants = []
        for const in self.method.__code__.co_consts:
            if isinstance(const, int):
                cp = CP_Long.insert(self.class_file.constant_pool, const)
                j_constants.append(cp)
            elif isinstance(const, float):
                cp = CP_Double.insert(self.class_file.constant_pool, const)
                j_constants.append(cp)
            elif isinstance(const, str):
                cp = CP_String.insert(self.class_file.constant_pool, const)
                j_constants.append(cp)
            elif const is None:
                pass
            else:
                raise Exception(f"Unsupported constant type: {type(const)}")
            
    def write_bytecode(self):
        bytecode = []

        code = self.method.__code__
        locals_offset = code.co_argcount + 1 # +1 for self

        # generate init bytecode
        # create pyStack array with size of co_stacksize
        javaLangObject = CP_Class.insert(self.class_file.constant_pool, "java/lang/Object")

        # bipush co_stacksize
        bytecode.append(0x10)
        if code.co_stacksize > 0xff:
            raise Exception("Stacksize too large")
        
        bytecode.append(code.co_stacksize & 0xff)

        # newarray java/lang/Object
        bytecode.append(0xbd)
        bytecode.append(javaLangObject.index >> 8)
        bytecode.append(javaLangObject.index & 0xff)

        if locals_offset + 1 > 0xff:
            raise Exception("Locals too large")

        # astore locals_offset + 1
        bytecode.append(0x3a)
        bytecode.append((locals_offset + 1) & 0xff)
        pystack_index = locals_offset + 1

        # fill array with arguments
        for i in range(locals_offset):
            # aload i + 1 # +1 for this
            bytecode.append(0x19)
            bytecode.append((i + 1) & 0xff)

            # bipush
            bytecode.append(0x10)
            bytecode.append(i & 0xff)

            # aload pystack_index
            bytecode.append(0x19)
            bytecode.append(pystack_index & 0xff)

            # aastore
            bytecode.append(0x53)
        
        for bc in dis.get_instructions(self.method):
            print(bc)
        
        return bytecode






