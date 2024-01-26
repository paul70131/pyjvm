from pyjvm.jvm cimport Jvm
from pyjvm.bytecode.components.jvmbytecodeconstantpool cimport JvmBytecodeConstantPool
from pyjvm.types.clazz.jvmfield cimport JvmField
from pyjvm.bytecode.components.jvmbytecodeattributes cimport JvmBytecodeAttributes
from pyjvm.c.jni cimport JNIEnv, jobject, jclass

from pyjvm.bytecode.components.base cimport JvmBytecodeComponent




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
            self.constant_value_index = cp.find_string(value, True).offset
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
        