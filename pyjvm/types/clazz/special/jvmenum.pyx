from pyjvm.types.clazz.jvmclass cimport JvmClass
from pyjvm.jvm cimport Jvm

cdef class JvmEnum(JvmClass):
    pass

    # in the future, we might want to add some methods here to make it easier to work with enums in python

