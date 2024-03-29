from pyjvm.c.jni cimport JavaVM, JNIEnv, jclass
from pyjvm.c.jvmti cimport jvmtiEnv

from pyjvm.types.clazz.jvmclass cimport JvmClass
from pyjvm.bytecode.jvmmethodlink cimport JvmMethodLink
from pyjvm.types.clazz.jvmmethod cimport JvmMethodSignature

cdef class Jvm:
    cdef JavaVM* jvm
    cdef jvmtiEnv* jvmti
    cdef bint bridge_loaded
    cdef public dict __classes
    cdef list[JvmMethodLink] links
    cdef public object _export_generated_classes
    cdef dict[int, unsigned long long] envs

    cdef JNIEnv* getEnv(self) except NULL
    cdef JNIEnv* initNewEnv(self) except NULL

    cpdef JvmMethodLink newMethodLink(self, object method, JvmMethodSignature signature)
    cpdef void ensure_capability(self, str capability) except *
    cpdef void raiseException(self, object jvmObject)

    cpdef object findClass(self, str name)

    cdef void ensureBridgeLoaded(self) except *