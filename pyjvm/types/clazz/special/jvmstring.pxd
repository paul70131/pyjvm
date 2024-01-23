from pyjvm.types.clazz.jvmclass cimport JvmClass
from pyjvm.jvm cimport Jvm

cdef class JvmString(JvmClass):
    pass

    cdef str __get_data(self)