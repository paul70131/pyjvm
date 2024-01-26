from pyjvm.jvm cimport Jvm
from pyjvm.bytecode.components.jvmbytecodeconstantpool cimport JvmBytecodeConstantPool, JvmBytecodeConstantPoolEntry
from pyjvm.types.clazz.jvmfield cimport JvmField
from pyjvm.bytecode.components.jvmbytecodeattributes cimport JvmBytecodeAttributes
from pyjvm.c.jni cimport JNIEnv, jobject, jclass

from pyjvm.bytecode.components.base cimport JvmBytecodeComponent




cdef class JvmBytecodeField:
    cdef unsigned short access_flags
    cdef unsigned short name_index
    cdef unsigned short descriptor_index
    cdef JvmBytecodeAttributes attributes

cdef class JvmBytecodeFields(JvmBytecodeComponent):
    cdef list[JvmBytecodeField] fields

    cdef void add(self, JvmBytecodeField bc_field) except *
    cdef JvmBytecodeField add_new(self, JvmBytecodeConstantPool cp, str name, str signature, bint static, bint public = ?, object default = ?) except *