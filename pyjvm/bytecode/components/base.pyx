from libc.stdlib cimport malloc, free

cdef class JvmBytecodeComponent():

    cdef int render(self, unsigned char* buffer) except -1:
        raise NotImplementedError()

    cdef unsigned int size(self) except 0:
        raise NotImplementedError()
