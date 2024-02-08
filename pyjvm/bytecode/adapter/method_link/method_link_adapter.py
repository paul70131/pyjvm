from pyjvm.bytecode.adapter._base import MethodAdapter
from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes

from pyjvm.bytecode.components.jvmbytecodemethods import JvmBytecodeMethod
from pyjvm.bytecode.components.jvmbytecodeattributes import CodeAttribute

import os
import io
import struct

class MethodLinkAdapter(MethodAdapter):


    def adapt(self, cp, access_flags, name, descriptor, jvm, method, super):
        #return super().adapt(access_flags, name, descriptor, jvm, method)
        # here we have to do the following:

        r_args = descriptor.args
        ret = descriptor.ret

        args = ["L..."] + r_args

        print(f"MethodLinkAdapter.adapt: {name} {args} -> {ret}")
        link = jvm.newMethodLink(method, descriptor)

        cp_name = cp.find_string(name, True)
        cp_descriptor = cp.find_string(descriptor.signature, True)
        bc_method = JvmBytecodeMethod(access_flags, cp_name.offset, cp_descriptor.offset)


        # now start writing the bytecode
        buffer = BytecodeWriter()

        # write the bytecode to the buffer
        if name == "<init>":
            buffer.u1(Opcodes.ALOAD_0)
            if super.__name__ != "java/lang/Object":
                for i, arg in enumerate(r_args):
                    if arg == "L" or arg == "[":
                        buffer.u1(Opcodes.ALOAD)
                        buffer.u1(i + 1)
                    elif arg == "J":
                        buffer.u1(Opcodes.LLOAD)
                        buffer.u1(i + 1)
                    elif arg in ("I", "B", "C", "Z", "S"):
                        buffer.u1(Opcodes.ILOAD)
                        buffer.u1(i + 1)
                    elif arg == "F":
                        buffer.u1(Opcodes.FLOAD)
                        buffer.u1(i + 1)
                    elif arg == "D":
                        buffer.u1(Opcodes.DLOAD)
                        buffer.u1(i + 1)
                    else:
                        raise NotImplementedError(f"MethodLinkAdapter.adapt: unsupported arg type: {arg}")
            cpv = cp.find_methodref(super.__name__, "<init>", "(" + "".join(r_args) + ")V", True)
            buffer.u1(Opcodes.INVOKESPECIAL)
            buffer.u2(cpv.offset)

        # write bytecode for putting the args in a list

        # let r = new Object[arg_count + 1]
        obj = cp.find_class("java/lang/Object", True)
        buffer.u1(Opcodes.BIPUSH)
        buffer.u1(len(args) + 1) # arg_count + 1
        buffer.u1(Opcodes.ANEWARRAY)
        buffer.u2(obj.offset)

        buffer.u1(Opcodes.DUP) # array, array

        cpv = cp.find_methodref("java/lang/Integer", "valueOf", "(I)Ljava/lang/Integer;", True)
        
        buffer.u1(Opcodes.ICONST_0)
        buffer.u1(Opcodes.SIPUSH)
        buffer.u2(link.link_id)
        buffer.u1(Opcodes.INVOKESTATIC)
        buffer.u2(cpv.offset)
        buffer.u1(Opcodes.AASTORE)

        # store the args in the array
        v_offset = 0
        a_offset = 1
        for arg in args:
            buffer.u1(Opcodes.DUP) # array, array
            buffer.u1(Opcodes.BIPUSH) # array, array, index, arg
            buffer.u1(a_offset)

            if arg[0] in ("L", "["):
                buffer.u1(Opcodes.ALOAD) # array, array, index, arg
                buffer.u1(v_offset) # array, array, index, arg

                buffer.u1(Opcodes.AASTORE) # array
            elif arg == "J":
                buffer.u1(Opcodes.LLOAD)
                buffer.u1(v_offset)

                cpv = cp.find_methodref("java/lang/Long", "valueOf", "(J)Ljava/lang/Long;", True)
                buffer.u1(Opcodes.INVOKESTATIC)
                buffer.u2(cpv.offset)
                buffer.u1(Opcodes.AASTORE)
            elif arg == "I":
                buffer.u1(Opcodes.ILOAD)
                buffer.u1(v_offset)

                cpv = cp.find_methodref("java/lang/Integer", "valueOf", "(I)Ljava/lang/Integer;", True)
                buffer.u1(Opcodes.INVOKESTATIC)
                buffer.u2(cpv.offset)
                buffer.u1(Opcodes.AASTORE)
            elif arg == "F":
                buffer.u1(Opcodes.FLOAD)
                buffer.u1(v_offset)

                cpv = cp.find_methodref("java/lang/Float", "valueOf", "(F)Ljava/lang/Float;", True)
                buffer.u1(Opcodes.INVOKESTATIC)
                buffer.u2(cpv.offset)
                buffer.u1(Opcodes.AASTORE)
            elif arg == "D":
                buffer.u1(Opcodes.DLOAD)
                buffer.u1(v_offset)

                cpv = cp.find_methodref("java/lang/Double", "valueOf", "(D)Ljava/lang/Double;", True)
                buffer.u1(Opcodes.INVOKESTATIC)
                buffer.u2(cpv.offset)
                buffer.u1(Opcodes.AASTORE)
            elif arg == "S":
                buffer.u1(Opcodes.ILOAD)
                buffer.u1(v_offset)

                cpv = cp.find_methodref("java/lang/Short", "valueOf", "(S)Ljava/lang/Short;", True)
                buffer.u1(Opcodes.INVOKESTATIC)
                buffer.u2(cpv.offset)
                buffer.u1(Opcodes.AASTORE)
            elif arg == "B":
                buffer.u1(Opcodes.ILOAD)
                buffer.u1(v_offset)

                cpv = cp.find_methodref("java/lang/Byte", "valueOf", "(B)Ljava/lang/Byte;", True)
                buffer.u1(Opcodes.INVOKESTATIC)
                buffer.u2(cpv.offset)
                buffer.u1(Opcodes.AASTORE)
            elif arg == "C":
                buffer.u1(Opcodes.ILOAD)
                buffer.u1(v_offset)

                cpv = cp.find_methodref("java/lang/Character", "valueOf", "(C)Ljava/lang/Character;", True)
                buffer.u1(Opcodes.INVOKESTATIC)
                buffer.u2(cpv.offset)
                buffer.u1(Opcodes.AASTORE)
            elif arg == "Z":
                buffer.u1(Opcodes.ILOAD)
                buffer.u1(v_offset)

                cpv = cp.find_methodref("java/lang/Boolean", "valueOf", "(Z)Ljava/lang/Boolean;", True)
                buffer.u1(Opcodes.INVOKESTATIC)
                buffer.u2(cpv.offset)
                buffer.u1(Opcodes.AASTORE)
            else:
                raise NotImplementedError(f"MethodLinkAdapter.adapt: unsupported arg type: {arg}")


            if arg == "J" or arg == "D":
                v_offset += 2
            else:
                v_offset += 1
            a_offset += 1

        # stack: array
        methodref = cp.find_methodref("pyjvm/bridge/java/PyjvmBridge", "call_override", "([Ljava/lang/Object;)Ljava/lang/Object;", True)
        buffer.u1(Opcodes.INVOKESTATIC)
        buffer.u2(methodref.offset)

        if ret[0] in ("L", "["):
            buffer.u1(Opcodes.ARETURN)

        elif ret == "J":
            cpv = cp.find_class("java/lang/Long", True)
            buffer.u1(Opcodes.CHECKCAST)
            buffer.u2(cpv.offset)
            cpv = cp.find_methodref("java/lang/Long", "longValue", "()J", True)
            buffer.u1(Opcodes.INVOKEVIRTUAL)
            buffer.u2(cpv.offset)
            buffer.u1(Opcodes.LRETURN)
        elif ret == "I":
            cpv = cp.find_class("java/lang/Integer", True)
            buffer.u1(Opcodes.CHECKCAST)
            buffer.u2(cpv.offset)
            cpv = cp.find_methodref("java/lang/Integer", "intValue", "()I", True)
            buffer.u1(Opcodes.INVOKEVIRTUAL)
            buffer.u2(cpv.offset)
            buffer.u1(Opcodes.IRETURN)
        elif ret == "F":
            cpv = cp.find_class("java/lang/Float", True)
            buffer.u1(Opcodes.CHECKCAST)
            buffer.u2(cpv.offset)
            cpv = cp.find_methodref("java/lang/Float", "floatValue", "()F", True)
            buffer.u1(Opcodes.INVOKEVIRTUAL)
            buffer.u2(cpv.offset)
            buffer.u1(Opcodes.FRETURN)
        elif ret == "D":
            cpv = cp.find_class("java/lang/Double", True)
            buffer.u1(Opcodes.CHECKCAST)
            buffer.u2(cpv.offset)
            cpv = cp.find_methodref("java/lang/Double", "doubleValue", "()D", True)
            buffer.u1(Opcodes.INVOKEVIRTUAL)
            buffer.u2(cpv.offset)
            buffer.u1(Opcodes.DRETURN)
        elif ret == "S":
            cpv = cp.find_class("java/lang/Short", True)
            buffer.u1(Opcodes.CHECKCAST)
            buffer.u2(cpv.offset)
            cpv = cp.find_methodref("java/lang/Short", "shortValue", "()S", True)
            buffer.u1(Opcodes.INVOKEVIRTUAL)
            buffer.u2(cpv.offset)
            buffer.u1(Opcodes.IRETURN)
        elif ret == "B":
            cpv = cp.find_class("java/lang/Byte", True)
            buffer.u1(Opcodes.CHECKCAST)
            buffer.u2(cpv.offset)
            cpv = cp.find_methodref("java/lang/Byte", "byteValue", "()B", True)
            buffer.u1(Opcodes.INVOKEVIRTUAL)
            buffer.u2(cpv.offset)
            buffer.u1(Opcodes.IRETURN)
        elif ret == "C":
            cpv = cp.find_class("java/lang/Character", True)
            buffer.u1(Opcodes.CHECKCAST)
            buffer.u2(cpv.offset)
            cpv = cp.find_methodref("java/lang/Character", "charValue", "()C", True)
            buffer.u1(Opcodes.INVOKEVIRTUAL)
            buffer.u2(cpv.offset)
            buffer.u1(Opcodes.IRETURN)
        elif ret == "Z":
            cpv = cp.find_class("java/lang/Boolean", True)
            buffer.u1(Opcodes.CHECKCAST)
            buffer.u2(cpv.offset)
            cpv = cp.find_methodref("java/lang/Boolean", "booleanValue", "()Z", True)
            buffer.u1(Opcodes.INVOKEVIRTUAL)
            buffer.u2(cpv.offset)
            buffer.u1(Opcodes.IRETURN)
        elif ret == "V":
            buffer.u1(Opcodes.POP)
            buffer.u1(Opcodes.RETURN)
        else:
            raise NotImplementedError(f"MethodLinkAdapter.adapt: unsupported ret type: {ret}")

        max_stack = 10 # TODO calculate
        max_locals = 10 # TODO calculate

        code_attribute = CodeAttribute(max_stack, max_locals, buffer.bytes(), buffer.size(), cp)
        bc_method.attributes.add(code_attribute)

        return bc_method
        
