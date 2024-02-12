from pyjvm.types.clazz.jvmmethod cimport JvmMethodSignature

from pyjvm.c.jni cimport jobject, JNIEnv
from pyjvm.jvm cimport Jvm

cdef class JvmMethodLink:
    cdef int link_id
    cdef object method
    cdef JvmMethodSignature signature

    cdef list _convert_args(self, object args)
    cdef jobject invoke(self, Jvm jvm, object args)