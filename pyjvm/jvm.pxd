from pyjvm.c.jni cimport JavaVM, JNIEnv, jclass
from pyjvm.c.jvmti cimport jvmtiEnv

from pyjvm.types.clazz.jvmclass cimport JvmClass

cdef class Jvm:
    cdef JavaVM* jvm
    cdef JNIEnv* jni
    cdef jvmtiEnv* jvmti
    cdef public dict __classes
    
    cpdef void ensure_capability(self, str capability) except *

    cpdef object findClass(self, str name)