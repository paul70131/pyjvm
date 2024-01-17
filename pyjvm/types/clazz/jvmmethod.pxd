from pyjvm.types.clazz.jvmclass cimport JvmClass
from pyjvm.c.jni cimport jmethodID, jclass

cdef class JvmMethod:
    cdef str _name
    cdef str _signature
    cdef int _modifiers
    cdef object _clazz

cdef JvmMethodFromJmethodID(jmethodID fid, jclass cid, object clazz)