from pyjvm.c.jvmti cimport jvmtiEventCallbacks
from pyjvm.jvm cimport Jvm

cdef class JvmtiEventManager:
    cdef Jvm jvm
    cdef jvmtiEventCallbacks callbacks