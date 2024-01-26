

cdef class JvmBytecodeComponent():

    cdef int render(self, unsigned char* buffer) except -1

    cdef unsigned int size(self) except 0