
from libc.stdlib cimport malloc, free

cdef class JvmBytecodeInterface:
    cdef unsigned short interface_index

cdef class JvmBytecodeInterfaces(JvmBytecodeComponent):

    def __init__(self):
        self.interfaces = []

    cdef int render(self, unsigned char* buffer) except -1:
        buffer[0] = 0
        buffer[1] = 0
        return 2

    cdef unsigned int size(self) except 0:
        return 2



