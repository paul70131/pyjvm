from pyjvm.jvm cimport Jvm
from pyjvm.bytecode.components.jvmbytecodeconstantpool cimport JvmBytecodeConstantPool, JvmBytecodeConstantPoolEntry
from pyjvm.types.clazz.jvmfield cimport JvmField
from pyjvm.bytecode.components.jvmbytecodeattributes cimport JvmBytecodeAttributes
from pyjvm.c.jni cimport JNIEnv, jobject, jclass

from pyjvm.bytecode.components.base cimport JvmBytecodeComponent

from libc.string cimport memcpy
from libc.stdlib cimport free, malloc



cdef class JvmBytecodeAttribute:
    
    cdef unsigned int render(self, unsigned char* buffer) except 0:
        raise NotImplementedError()

    cdef unsigned int size(self) except *:
        raise NotImplementedError()

cdef class JvmBytecodeAttributes(JvmBytecodeComponent):
#    cdef list[JvmBytecodeAttribute] attributes

    def __init__(self):
        self.attributes = []
        
    cdef add(self, JvmBytecodeAttribute field):
        self.attributes.append(field)

    cdef int render(self, unsigned char* buffer) except -1:
        cdef unsigned short length = len(self.attributes)
        cdef unsigned short i = 0
        cdef JvmBytecodeAttribute attribute
        
        buffer[0] = (length >> 8) & 0xFF
        buffer[1] = length & 0xFF

        for attribute in self.attributes:
            attribute.render(buffer + 2 + i)
            i += attribute.size()
        
        return 2 + i

    cdef unsigned int size(self) except 0:
        cdef unsigned int size = 2
        cdef JvmBytecodeAttribute attribute
        
        for attribute in self.attributes:
            size += attribute.size()
        
        return size



cdef class SyntheticAttribute(JvmBytecodeAttribute):
#    cdef unsigned short attribute_name_index
#    cdef unsigned int attribute_length

    def __init__(self, JvmBytecodeConstantPool cp):
        self.attribute_name_index = cp.find_string("Synthetic").offset
        self.attribute_length = 0


cdef class CodeAttributeExcetionTable:
#    no functionality yet

    def __init__(self):
        pass

    cdef unsigned int size(self) except 0:
        return 2

    cdef unsigned int render(self, unsigned char* buffer) except 0:
        buffer[0] = 0
        buffer[1] = 0
        return 2

cdef class CodeAttribute(JvmBytecodeAttribute):
#    cdef unsigned short attribute_name_index
#    cdef unsigned int attribute_length
#    cdef unsigned short max_stack
#    cdef unsigned short max_locals
#    cdef unsigned int code_length
#    cdef unsigned char* code
#    cdef CodeAttributeExcetionTable exception_table
#    cdef JvmBytecodeAttributes attributes

    def __init__(self, unsigned short max_stack, unsigned short max_locals, unsigned char* code, unsigned int code_length, JvmBytecodeConstantPool cp):
        self.attribute_name_index = cp.find_string("Code", True).offset
        self.max_stack = max_stack
        self.max_locals = max_locals

        self.code_length = code_length
        self.code = <unsigned char*> malloc( <int>code_length)
        memcpy(self.code, code, <int>code_length)

        self.exception_table = CodeAttributeExcetionTable()
        self.attributes = JvmBytecodeAttributes()

    def __dealloc__(self):
        free(self.code)


    cdef unsigned int render(self, unsigned char* buffer) except 0:
        cdef unsigned int attribute_length = self.size() - 6
        cdef unsigned int offset = 0

        buffer[0] = (self.attribute_name_index >> 8) & 0xFF
        buffer[1] = self.attribute_name_index & 0xFF
        buffer[2] = (attribute_length >> 24) & 0xFF
        buffer[3] = (attribute_length >> 16) & 0xFF
        buffer[4] = (attribute_length >> 8) & 0xFF
        buffer[5] = attribute_length & 0xFF
        offset += 6

        buffer[offset] = (self.max_stack >> 8) & 0xFF
        buffer[offset + 1] = self.max_stack & 0xFF

        buffer[offset + 2] = (self.max_locals >> 8) & 0xFF
        buffer[offset + 3] = self.max_locals & 0xFF

        buffer[offset + 4] = (self.code_length >> 24) & 0xFF
        buffer[offset + 5] = (self.code_length >> 16) & 0xFF
        buffer[offset + 6] = (self.code_length >> 8) & 0xFF
        buffer[offset + 7] = self.code_length & 0xFF

        memcpy(buffer + offset + 8, self.code, self.code_length)

        offset += 8 + self.code_length

        offset += self.exception_table.render(buffer + offset)
        offset += self.attributes.render(buffer + offset)

        return offset

    cdef unsigned int size(self) except *:
        return 6 + 8 + self.code_length + self.exception_table.size() + self.attributes.size()


cdef class ConstantValueAttribute(JvmBytecodeAttribute):
#    cdef unsigned short attribute_name_index
#    cdef unsigned int attribute_length
#    cdef unsigned short constant_value_index

    signatures = ["Ljava/lang/String;", "J", "D", "F", "I", "Z", "S", "B", "C"]

    cdef unsigned int render(self, unsigned char* buffer) except 0:
        buffer[0] = (self.attribute_name_index >> 8) & 0xFF
        buffer[1] = self.attribute_name_index & 0xFF
        buffer[2] = (self.attribute_length >> 24) & 0xFF
        buffer[3] = (self.attribute_length >> 16) & 0xFF
        buffer[4] = (self.attribute_length >> 8) & 0xFF
        buffer[5] = self.attribute_length & 0xFF
        buffer[6] = (self.constant_value_index >> 8) & 0xFF
        buffer[7] = self.constant_value_index & 0xFF
        return 8

    cdef unsigned int size(self) except *:
        return 8

    def __init__(self, str signature, object value, JvmBytecodeConstantPool cp):
        self.attribute_name_index = cp.find_string("ConstantValue", True).offset
        self.attribute_length = 2

        if signature == "Ljava/lang/String;":
            if not isinstance(value, str):
                value = str(value)
            self.constant_value_index = cp.find_jstring(value, True).offset
        elif signature == "J":
            self.constant_value_index = cp.find_long(value, True).offset
        elif signature == "D":
            self.constant_value_index = cp.find_double(value, True).offset
        elif signature == "F":
            self.constant_value_index = cp.find_float(value, True).offset
        elif signature in ["I", "S", "B"]:
            self.constant_value_index = cp.find_integer(value, True).offset
        elif signature == "C":
            self.constant_value_index = cp.find_integer(ord(value), True).offset
        elif signature == "Z":
            self.constant_value_index = cp.find_integer(1 if value else 0, True).offset
        else:
            raise Exception("Unknown field type: " + signature)
        

        
cdef class StackMapFrame:
#    cdef unsigned char frame_type
    cdef unsigned int size(self) except 0:
        raise NotImplementedError()

    cdef unsigned int render(self, unsigned char* buffer) except 0:
        raise NotImplementedError()

cdef class VerificationTypeInfo:
#    cdef unsigned char tag
#    cdef unsigned short cpool_index

    def __init__(self, str signature, JvmBytecodeConstantPool cp):
        if signature == "this":
            self.tag = 0
        elif signature == "int":
            self.tag = 1
        elif signature == "float":
            self.tag = 2
        elif signature == "long":
            self.tag = 4
        elif signature == "double":
            self.tag = 3
        elif signature == "null":
            self.tag = 5
        elif signature == "uninitializedThis":
            self.tag = 6
        elif signature.startswith("uninitialized"):
            self.tag = 8
            self.cpool_index = cp.find_class(signature[13:-1], True).offset
        elif signature.startswith("L"):
            self.tag = 7
            self.cpool_index = cp.find_class(signature[1:-1], True).offset
        else:
            raise Exception("Unknown signature: " + signature)
    
    cdef unsigned int size(self) except 0:
        if self.tag in [0, 1, 2, 3, 4, 5, 6]:
            return 1
        elif self.tag in [7, 8]:
            return 3
        else:
            raise Exception("Unknown tag: " + str(self.tag))
    
    cdef unsigned int render(self, unsigned char* buffer) except 0:
        buffer[0] = self.tag
        if self.tag in [7, 8]:
            buffer[1] = (self.cpool_index >> 8) & 0xFF
            buffer[2] = self.cpool_index & 0xFF
        return self.size()

cdef class AppendFrame(StackMapFrame):
#    cdef unsigned short offset_delta
#    cdef list[VerificationTypeInfo] locals

    def __init__(self, unsigned short offset_delta, list[str] locals, JvmBytecodeConstantPool cp):
        if len(locals) > 4:
            raise Exception("Too many locals for append frame, use full frame instead")
        if len(locals) == 0:
            raise Exception("No locals for append frame")

        self.offset_delta = offset_delta
        self.frame_type = 251 + len(locals)
        self.locals = []
        for local in locals:
            self.locals.append(VerificationTypeInfo(local, cp))

    cdef unsigned int size(self) except 0:
        cdef unsigned int size = 3
        cdef VerificationTypeInfo local
        
        for local in self.locals:
            size += local.size()
        
        return size

    cdef unsigned int render(self, unsigned char* buffer) except 0:
        cdef unsigned short i = 3
        cdef VerificationTypeInfo local
        
        buffer[0] = self.frame_type
        buffer[1] = (self.offset_delta >> 8) & 0xFF
        buffer[2] = self.offset_delta & 0xFF

        for local in self.locals:
            local.render(buffer + i)
            i += local.size()
        
        return 3 + i

cdef class StackMapTableAttribute(JvmBytecodeAttribute):
#    cdef list[StackMapFrame] frames

    def __init__(self, JvmBytecodeConstantPool cp):
        cdef JvmBytecodeConstantPoolEntry entry = cp.find_string("StackMapTable", True)
        self.attribute_name_index = entry.offset
        self.attribute_length = 0
        self.frames = []


    cdef unsigned int size(self) except 0:
        cdef unsigned int size = 8
        cdef StackMapFrame frame
        
        for frame in self.frames:
            size += frame.size()
        
        return size

    def append(self, unsigned short offset_delta, list[str] locals, JvmBytecodeConstantPool cp):
        self.frames.append(AppendFrame(offset_delta, locals, cp))

    cdef unsigned int render(self, unsigned char* buffer) except 0:
        cdef unsigned int length = self.size() - 6
        cdef unsigned short entry_count = len(self.frames)
        cdef unsigned short i = 0
        cdef StackMapFrame frame
        
        buffer[0] = (self.attribute_name_index >> 8) & 0xFF
        buffer[1] = self.attribute_name_index & 0xFF
        buffer[2] = (length >> 24) & 0xFF
        buffer[3] = (length >> 16) & 0xFF
        buffer[4] = (length >> 8) & 0xFF
        buffer[5] = length & 0xFF
        buffer[6] = (entry_count >> 8) & 0xFF
        buffer[7] = entry_count & 0xFF

        for frame in self.frames:
            frame.render(buffer + 8 + i)
            i += frame.size()
        
        return 8 + i