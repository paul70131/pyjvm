from pyjvm.jvm cimport Jvm
from pyjvm.bytecode.components.jvmbytecodeconstantpool cimport JvmBytecodeConstantPool
from pyjvm.types.clazz.jvmfield cimport JvmField
from pyjvm.bytecode.components.jvmbytecodeattributes cimport JvmBytecodeAttributes
from pyjvm.c.jni cimport JNIEnv, jobject, jclass

from pyjvm.bytecode.components.base cimport JvmBytecodeComponent




cdef class JvmBytecodeAttribute:
    pass

cdef class JvmBytecodeAttributes(JvmBytecodeComponent):
    cdef list[JvmBytecodeAttribute] fields

        
    cdef add(self, JvmBytecodeAttribute field)

    
cdef class ConstantValueAttribute(JvmBytecodeAttribute):
    cdef unsigned short attribute_name_index
    cdef unsigned int attribute_length
    cdef unsigned short constant_value_index

