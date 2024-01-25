from pyjvm.jvm cimport Jvm
from pyjvm.bytecode.components.jvmbytecodeconstantpool cimport JvmBytecodeConstantPool
from pyjvm.types.clazz.jvmfield cimport JvmField
from pyjvm.bytecode.components.jvmbytecodeattributes cimport JvmBytecodeAttributes
from pyjvm.c.jni cimport JNIEnv, jobject, jclass

from pyjvm.bytecode.components.base cimport JvmBytecodeComponent




cdef class JvmBytecodeAttribute:
    pass

cdef class JvmBytecodeAttributes(JvmBytecodeComponent):
#    cdef list[JvmBytecodeAttribute] fields

    def __init__(self):
        self.fields = []
        
    cdef add(self, JvmBytecodeAttribute field):
        self.fields.append(field)

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

    def __init__(self, JvmField field, object value, JvmBytecodeConstantPool cp):
        self.attribute_name_index = cp.find_string("ConstantValue").offset
        self.attribute_length = 2

        if field.signature == "Ljava/lang/String;":
            if not isinstance(value, str):
                value = str(value)
            self.constant_value_index = cp.find_string(value).offset
        elif field.signature == "J":
            self.constant_value_index = cp.find_long(value).offset
        elif field.signature == "D":
            self.constant_value_index = cp.find_double(value).offset
        elif field.signature == "F":
            self.constant_value_index = cp.find_float(value).offset
        elif field.signature in ["I", "S", "B"]:
            self.constant_value_index = cp.find_integer(value).offset
        elif field.signature == "C":
            self.constant_value_index = cp.find_integer(ord(value)).offset
        elif field.signature == "Z":
            self.constant_value_index = cp.find_integer(1 if value else 0).offset
        else:
            raise Exception("Unknown field type: " + field.signature)
        