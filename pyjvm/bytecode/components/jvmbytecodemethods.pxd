from pyjvm.jvm cimport Jvm
from pyjvm.bytecode.components.jvmbytecodeconstantpool cimport JvmBytecodeConstantPool
from pyjvm.types.clazz.jvmmethod cimport JvmMethod
from pyjvm.bytecode.components.jvmbytecodeattributes cimport JvmBytecodeAttributes
from pyjvm.c.jni cimport JNIEnv, jobject, jclass

from pyjvm.bytecode.components.base cimport JvmBytecodeComponent




cdef class JvmBytecodeMethod:
    cdef unsigned short access_flags
    cdef unsigned short name_index
    cdef unsigned short descriptor_index
    cdef JvmBytecodeAttributes attributes

cdef class JvmBytecodeMethods(JvmBytecodeComponent):
    cdef list[JvmBytecodeMethod] methods

    cdef void add(self, JvmMethod field, object klass, Jvm jvm, JvmBytecodeConstantPool cp) except *
