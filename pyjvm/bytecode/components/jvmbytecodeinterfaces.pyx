
from libc.stdlib cimport malloc, free

cdef class JvmBytecodeInterface:
    cdef unsigned short interface_index

cdef class JvmBytecodeInterfaces(JvmBytecodeComponent):

    def __init__(self):
        self.interfaces = []

    cdef unsigned char* render(self) except *:
        self.buffer = <unsigned char*>malloc(sizeof(unsigned char) * 2)
        self.buffer[0] = 0
        self.buffer[1] = 0

        return self.buffer


    



