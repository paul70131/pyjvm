
from pyjvm.bytecode.components.base cimport JvmBytecodeComponent


cdef class JvmBytecodeInterfaces(JvmBytecodeComponent):
    cdef list[JvmBytecodeInterface] interfaces
    cdef list[int] interface_ids

    