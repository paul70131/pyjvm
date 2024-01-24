

cdef class JvmBytecodeComponent():
    cdef unsigned char* buffer

    cdef unsigned char* render(self) except *