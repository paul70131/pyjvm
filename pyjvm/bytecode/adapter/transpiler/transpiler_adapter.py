from pyjvm.bytecode.adapter._base import MethodAdapter
from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes

from pyjvm.bytecode.adapter.transpiler.transpiler import TranspiledMethod

from pyjvm.bytecode.components.jvmbytecodemethods import JvmBytecodeMethod
from pyjvm.bytecode.components.jvmbytecodeattributes import CodeAttribute, LineNumberTableAttribute, StackMapTableAttribute

import os
import io
import struct

class TranspilerAdapter(MethodAdapter):


    def adapt(self, cp, access_flags, name, descriptor, jvm, method, super):
        #return super().adapt(access_flags, name, descriptor, jvm, method)
        # here we have to do the following:

        r_args = descriptor.args
        ret = descriptor.ret

        cp_name = cp.find_string(name, True)
        cp_descriptor = cp.find_string(descriptor.signature, True)
        bc_method = JvmBytecodeMethod(access_flags, cp_name.offset, cp_descriptor.offset)

        line_number_table = LineNumberTableAttribute(cp)
        stack_map_table = StackMapTableAttribute(cp)

        tp = TranspiledMethod(cp, name, method, line_number_table, stack_map_table, descriptor)
        tp.transpile()

        max_stack = 10 # TODO calculate
        max_locals = 10 # TODO calculate

        code_attribute = CodeAttribute(max_stack, max_locals, tp.bytecode.bytes(), tp.bytecode.size(), cp)
        code_attribute.attributes.add(line_number_table)
        code_attribute.attributes.add(stack_map_table)

        bc_method.attributes.add(code_attribute)

        return bc_method
        
