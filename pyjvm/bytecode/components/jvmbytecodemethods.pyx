from pyjvm.jvm cimport Jvm
from pyjvm.bytecode.components.jvmbytecodeconstantpool cimport JvmBytecodeConstantPool, JvmBytecodeConstantPoolEntry
from pyjvm.types.clazz.jvmmethod cimport JvmMethod, JvmMethodSignature
from pyjvm.bytecode.components.jvmbytecodeattributes cimport JvmBytecodeAttributes, CodeAttribute
from pyjvm.c.jni cimport JNIEnv, jobject, jclass

from pyjvm.bytecode.components.base cimport JvmBytecodeComponent
from pyjvm.bytecode.jvmmethodlink cimport JvmMethodLink

from libc.stdlib cimport malloc, free



cdef class JvmBytecodeMethod:
    #cdef unsigned short access_flags
    #cdef unsigned short name_index
    #cdef unsigned short descriptor_index
    #cdef JvmBytecodeAttributes attributes

    def __init__(self, unsigned short access_flags, unsigned short name_index, unsigned short descriptor_index):
        self.access_flags = access_flags
        self.name_index = name_index
        self.descriptor_index = descriptor_index
        self.attributes = JvmBytecodeAttributes()

cdef class JvmBytecodeMethods(JvmBytecodeComponent):
    #cdef list[JvmBytecodeMethod] fields

    def __init__(self):
        self.methods = []

    cdef int render(self, unsigned char* buffer) except -1:
        cdef unsigned int offset = 0
        cdef JvmBytecodeMethod method

        buffer[0] = (len(self.methods) >> 8) & 0xFF
        buffer[1] = len(self.methods) & 0xFF

        offset += 2

        for method in self.methods:
            buffer[offset] = (method.access_flags >> 8) & 0xFF
            buffer[offset + 1] = method.access_flags & 0xFF
            buffer[offset + 2] = (method.name_index >> 8) & 0xFF
            buffer[offset + 3] = method.name_index & 0xFF
            buffer[offset + 4] = (method.descriptor_index >> 8) & 0xFF
            buffer[offset + 5] = method.descriptor_index & 0xFF

            offset += 6

            offset += method.attributes.render(buffer + offset)

        return offset


    cdef unsigned int size(self) except 0:
        cdef unsigned int size = 2
        cdef JvmBytecodeMethod method
        for method in self.methods:
            size += 6
            size += method.attributes.size()
        return size



    def add_new(self, JvmBytecodeConstantPool cp, int access_flags, str name, JvmMethodSignature descriptor, Jvm jvm, object method):
        cdef JvmBytecodeMethod bc_method
        cdef JvmBytecodeConstantPoolEntry cp_entry
        cdef JvmBytecodeConstantPoolEntry methodref
        cdef CodeAttribute code_attribute
        cdef unsigned short max_stack = 0
        cdef unsigned short max_locals = 0
        cdef int arg_count = 0
        cdef int override_id = 0
        cdef unsigned char* bc = <unsigned char*>malloc(1024) 
        cdef JvmMethodLink method_link
        # 1024 bytes should be enough for the bytecode with up to around 100 arguments

        cp_name = cp.find_string(name, True)
        cp_descriptor = cp.find_string(descriptor._signature, True)

        bc_method = JvmBytecodeMethod(access_flags, cp_name.offset, cp_descriptor.offset)

        args, return_type = descriptor.parse()

        args = ["I", "L...", *args] # Add "override id" and "this" pointer to the arguments

        max_locals = len(args) + 1 # +1 for the "this" pointer
        for arg in args:
            if arg == "J" or arg == "D":
                max_locals += 1
        
        max_stack = max_locals + 2 # TODO: This is not correct, but it's good enough for now

        arg_count = len(args)

        method_link = jvm.newMethodLink(method, descriptor)
        override_id = method_link.link_id

        # attributes

        # Create bytecode which calls the native method "pyjvm.interface.PyjvmBridge.call_override" with the overload id

        # Load argument length onto stack
        cp_entry = cp.find_integer(arg_count, True)
        arg_count_idx = cp_entry.offset

        bc[0] = 0x13 # ldc_w
        bc[1] = (arg_count_idx >> 8) & 0xFF
        bc[2] = arg_count_idx & 0xFF

        # Create array of arguments
        cp_entry = cp.find_class("java/lang/Object", True)
        object_class_idx = cp_entry.offset

        bc[3] = 0xbd # anewarray
        bc[4] = (object_class_idx >> 8) & 0xFF
        bc[5] = object_class_idx & 0xFF

        offset = 6
        local_variable_index = 1

        for i, arg in enumerate(args):
            # Duplicate array reference
            bc[offset] = 0x59 # dup

            # Load index onto stack
            cp_entry = cp.find_integer(i, True)
            idx = cp_entry.offset
            bc[offset + 1] = 0x13 # ldc_w
            bc[offset + 2] = (idx >> 8) & 0xFF
            bc[offset + 3] = idx & 0xFF

            offset += 4

            if arg in ["Z", "B", "C", "S", "I"]:
                if i == 0:
                    # Load override id onto stack
                    cp_entry = cp.find_integer(override_id, True)
                    override_id_idx = cp_entry.offset

                    bc[offset] = 0x13 # ldc_w
                    bc[offset + 1] = (override_id_idx >> 8) & 0xFF
                    bc[offset + 2] = override_id_idx & 0xFF

                    offset += 3
                else:
                    # Load argument onto stack
                    bc[offset] = 0xc4 # wide
                    bc[offset + 1] = 0x15 # iload
                    bc[offset + 2] = (local_variable_index >> 8) & 0xFF
                    bc[offset + 3] = local_variable_index & 0xFF
                    offset += 4

                    local_variable_index += 1

                if arg == "Z":
                    # invokestatic  #2                  // Method java/lang/Boolean.valueOf:(Z)Ljava/lang/Boolean;
                    cp_entry = cp.find_methodref("java/lang/Boolean", "valueOf", "(Z)Ljava/lang/Boolean;", True)
                    bc[offset] = 0xB8
                    bc[offset + 1] = (cp_entry.offset >> 8) & 0xFF
                    bc[offset + 2] = cp_entry.offset & 0xFF
                    offset += 3
                elif arg == "B":
                    # invokestatic  #2                  // Method java/lang/Byte.valueOf:(B)Ljava/lang/Byte;
                    cp_entry = cp.find_methodref("java/lang/Byte", "valueOf", "(B)Ljava/lang/Byte;", True)
                    bc[offset] = 0xB8
                    bc[offset + 1] = (cp_entry.offset >> 8) & 0xFF
                    bc[offset + 2] = cp_entry.offset & 0xFF
                    offset += 3
                elif arg == "C":
                    # invokestatic  #2                  // Method java/lang/Character.valueOf:(C)Ljava/lang/Character;
                    cp_entry = cp.find_methodref("java/lang/Character", "valueOf", "(C)Ljava/lang/Character;", True)
                    bc[offset] = 0xB8
                    bc[offset + 1] = (cp_entry.offset >> 8) & 0xFF
                    bc[offset + 2] = cp_entry.offset & 0xFF
                    offset += 3
                elif arg == "S":
                    # invokestatic  #2                  // Method java/lang/Short.valueOf:(S)Ljava/lang/Short;
                    cp_entry = cp.find_methodref("java/lang/Short", "valueOf", "(S)Ljava/lang/Short;", True)
                    bc[offset] = 0xB8
                    bc[offset + 1] = (cp_entry.offset >> 8) & 0xFF
                    bc[offset + 2] = cp_entry.offset & 0xFF
                    offset += 3
                elif arg == "I":
                    # invokestatic  #2                  // Method java/lang/Integer.valueOf:(I)Ljava/lang/Integer;
                    cp_entry = cp.find_methodref("java/lang/Integer", "valueOf", "(I)Ljava/lang/Integer;", True)
                    bc[offset] = 0xB8
                    bc[offset + 1] = (cp_entry.offset >> 8) & 0xFF
                    bc[offset + 2] = cp_entry.offset & 0xFF
                    offset += 3
            elif arg == "J":
                # Load argument onto stack
                bc[offset] = 0xc4 # wide
                bc[offset + 1] = 0x16 # lload
                bc[offset + 2] = (local_variable_index >> 8) & 0xFF
                bc[offset + 3] = local_variable_index & 0xFF

                local_variable_index += 2
                offset += 4

                # invokestatic  #2                  // Method java/lang/Long.valueOf:(J)Ljava/lang/Long;
                cp_entry = cp.find_methodref("java/lang/Long", "valueOf", "(J)Ljava/lang/Long;", True)
                bc[offset] = 0xB8
                bc[offset + 1] = (cp_entry.offset >> 8) & 0xFF
                bc[offset + 2] = cp_entry.offset & 0xFF
                offset += 3
            elif arg == "F":
                # Load argument onto stack
                bc[offset] = 0xc4 # wide
                bc[offset + 1] = 0x17 # fload
                bc[offset + 2] = (local_variable_index >> 8) & 0xFF
                bc[offset + 3] = local_variable_index & 0xFF

                local_variable_index += 1
                offset += 4

                # invokestatic  #2                  // Method java/lang/Float.valueOf:(F)Ljava/lang/Float;
                cp_entry = cp.find_methodref("java/lang/Float", "valueOf", "(F)Ljava/lang/Float;", True)
                bc[offset] = 0xB8
                bc[offset + 1] = (cp_entry.offset >> 8) & 0xFF
                bc[offset + 2] = cp_entry.offset & 0xFF
                offset += 3
            elif arg == "D":
                # Load argument onto stack
                bc[offset] = 0xc4 # wide
                bc[offset + 1] = 0x18 # dload
                bc[offset + 2] = (local_variable_index >> 8) & 0xFF
                bc[offset + 3] = local_variable_index & 0xFF

                local_variable_index += 2
                offset += 4

                # invokestatic  #2                  // Method java/lang/Double.valueOf:(D)Ljava/lang/
                cp_entry = cp.find_methodref("java/lang/Double", "valueOf", "(D)Ljava/lang/Double;", True)
                bc[offset] = 0xB8
                bc[offset + 1] = (cp_entry.offset >> 8) & 0xFF
                bc[offset + 2] = cp_entry.offset & 0xFF
                offset += 3
            elif arg[0] == "L" or arg[0] == "[":
                if i == 1:
                    # Load "this" pointer onto stack
                    bc[offset] = 0x2A # aload_0
                    offset += 1
                else:
                    # Load argument onto stack
                    bc[offset] = 0xc4 # wide
                    bc[offset + 1] = 0x19 # aload
                    bc[offset + 2] = (local_variable_index >> 8) & 0xFF
                    bc[offset + 3] = local_variable_index & 0xFF

                    local_variable_index += 1
                    offset += 4
            else:
                raise Exception("Unknown argument type: " + arg)
            
            # Store argument in array
            bc[offset] = 0x53 # aastore
            offset += 1

        #2: invokestatic  #2                  // Method call_override:(S)V
        methodref = cp.find_methodref("pyjvm/java/PyjvmBridge", "call_override", "([Ljava/lang/Object;)Ljava/lang/Object;", True)
        bc[offset] = 0xB8
        bc[offset + 1] = (methodref.offset >> 8) & 0xFF
        bc[offset + 2] = methodref.offset & 0xFF

        offset += 3

        # Now we need to convert the return value to the correct type and return it
        if return_type == "V":
            # pop
            bc[offset] = 0x57
            # return
            bc[offset + 1] = 0xB1
            offset += 2
        elif return_type == "Z":
            # checkcast  #3                  // class java/lang/Boolean
            cp_entry = cp.find_class("java/lang/Boolean", True)
            bc[offset] = 0xC0
            bc[offset + 1] = (cp_entry.offset >> 8) & 0xFF
            bc[offset + 2] = cp_entry.offset & 0xFF
            offset += 3

            # invokevirtual  #4                  // Method java/lang/Boolean.booleanValue:()Z
            cp_entry = cp.find_methodref("java/lang/Boolean", "booleanValue", "()Z", True)
            bc[offset] = 0xB6
            bc[offset + 1] = (cp_entry.offset >> 8) & 0xFF
            bc[offset + 2] = cp_entry.offset & 0xFF
            offset += 3

            # ireturn
            bc[offset] = 0xAC
            offset += 1
        elif return_type == "B":
            # checkcast  #3                  // class java/lang/Byte
            cp_entry = cp.find_class("java/lang/Byte", True)
            bc[offset] = 0xC0
            bc[offset + 1] = (cp_entry.offset >> 8) & 0xFF
            bc[offset + 2] = cp_entry.offset & 0xFF
            offset += 3

            # invokevirtual  #4                  // Method java/lang/Byte.byteValue:()B
            cp_entry = cp.find_methodref("java/lang/Byte", "byteValue", "()B", True)
            bc[offset] = 0xB6
            bc[offset + 1] = (cp_entry.offset >> 8) & 0xFF
            bc[offset + 2] = cp_entry.offset & 0xFF
            offset += 3

            # ireturn
            bc[offset] = 0xAC
            offset += 1
        elif return_type == "C":
            # checkcast  #3                  // class java/lang/Character
            cp_entry = cp.find_class("java/lang/Character", True)
            bc[offset] = 0xC0
            bc[offset + 1] = (cp_entry.offset >> 8) & 0xFF
            bc[offset + 2] = cp_entry.offset & 0xFF
            offset += 3

            # invokevirtual
            cp_entry = cp.find_methodref("java/lang/Character", "charValue", "()C", True)
            bc[offset] = 0xB6
            bc[offset + 1] = (cp_entry.offset >> 8) & 0xFF
            bc[offset + 2] = cp_entry.offset & 0xFF
            offset += 3

            # ireturn
            bc[offset] = 0xAC
            offset += 1
        elif return_type == "S":
            # checkcast  #3                  // class java/lang/Short
            cp_entry = cp.find_class("java/lang/Short", True)
            bc[offset] = 0xC0
            bc[offset + 1] = (cp_entry.offset >> 8) & 0xFF
            bc[offset + 2] = cp_entry.offset & 0xFF
            offset += 3

            # invokevirtual
            cp_entry = cp.find_methodref("java/lang/Short", "shortValue", "()S", True)
            bc[offset] = 0xB6
            bc[offset + 1] = (cp_entry.offset >> 8) & 0xFF
            bc[offset + 2] = cp_entry.offset & 0xFF
            offset += 3

            # ireturn
            bc[offset] = 0xAC
            offset += 1
        elif return_type == "I":
            # checkcast  #3                  // class java/lang/Integer
            cp_entry = cp.find_class("java/lang/Integer", True)
            bc[offset] = 0xC0
            bc[offset + 1] = (cp_entry.offset >> 8) & 0xFF
            bc[offset + 2] = cp_entry.offset & 0xFF
            offset += 3

            # invokevirtual
            cp_entry = cp.find_methodref("java/lang/Integer", "intValue", "()I", True)
            bc[offset] = 0xB6
            bc[offset + 1] = (cp_entry.offset >> 8) & 0xFF
            bc[offset + 2] = cp_entry.offset & 0xFF
            offset += 3

            # ireturn
            bc[offset] = 0xAC
            offset += 1
        elif return_type == "J":
            # checkcast  #3                  // class java/lang/Long
            cp_entry = cp.find_class("java/lang/Long", True)
            bc[offset] = 0xC0
            bc[offset + 1] = (cp_entry.offset >> 8) & 0xFF
            bc[offset + 2] = cp_entry.offset & 0xFF
            offset += 3

            # invokevirtual
            cp_entry = cp.find_methodref("java/lang/Long", "longValue", "()J", True)
            bc[offset] = 0xB
            bc[offset + 1] = (cp_entry.offset >> 8) & 0xFF
            bc[offset + 2] = cp_entry.offset & 0xFF
            offset += 3

            # lreturn
            bc[offset] = 0xAD
            offset += 1

        elif return_type == "F":
            # dup
            bc[offset] = 0x59
            # ifnull # TODO Implement StackMapTable attribute so we can jump
            bc[offset + 1] = 0xC6
            branch_offset = 10
            bc[offset + 2] = (branch_offset >> 8) & 0xFF
            bc[offset + 3] = branch_offset & 0xFF

            offset += 4


            # checkcast  #3                  // class java/lang/Float
            cp_entry = cp.find_class("java/lang/Float", True)
            bc[offset] = 0xC0
            bc[offset + 1] = (cp_entry.offset >> 8) & 0xFF
            bc[offset + 2] = cp_entry.offset & 0xFF
            offset += 3

            # invokevirtual
            cp_entry = cp.find_methodref("java/lang/Float", "floatValue", "()F", True)
            bc[offset] = 0xB6
            bc[offset + 1] = (cp_entry.offset >> 8) & 0xFF
            bc[offset + 2] = cp_entry.offset & 0xFF
            offset += 3

            # freturn
            bc[offset] = 0xAE
            offset += 1

            # ifnull branch
            bc[offset] = 0x57 # pop
            bc[offset + 1] = 0xb # fconst_0
            bc[offset + 2] = 0xae # freturn

            offset += 3

        elif return_type == "D":
            # checkcast  #3                  // class java/lang/Double
            cp_entry = cp.find_class("java/lang/Double", True)
            bc[offset] = 0xC0
            bc[offset + 1] = (cp_entry.offset >> 8) & 0xFF
            bc[offset + 2] = cp_entry.offset & 0xFF
            offset += 3

            # invokevirtual
            cp_entry = cp.find_methodref("java/lang/Double", "doubleValue", "()D", True)
            bc[offset] = 0xB6
            bc[offset + 1] = (cp_entry.offset >> 8) & 0xFF
            bc[offset + 2] = cp_entry.offset & 0xFF
            offset += 3

            # dreturn
            bc[offset] = 0xAF
            offset += 1
        elif return_type[0] == "L" or return_type[0] == "[":

            # areturn
            bc[offset] = 0xB0
            offset += 1
        else:
            raise Exception("Unknown return type: " + return_type)


        code_attribute = CodeAttribute(max_stack, max_locals, bc[:offset], offset, cp)
        bc_method.attributes.add(code_attribute)
    
        free(bc)

        self.add(bc_method)

    cdef void add(self, JvmBytecodeMethod method) except *:
        self.methods.append(method)
