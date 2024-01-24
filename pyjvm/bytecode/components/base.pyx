from libc.stdlib cimport malloc, free

cdef class JvmBytecodeComponent():

    cdef unsigned char* render(self) except *:
        raise NotImplementedError()

    def __dealloc__(self):
        if self.buffer != NULL:
            free(self.buffer)