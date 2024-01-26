from pyjvm.bytecode.components.base cimport JvmBytecodeComponent


cdef class JvmBytecodeConstantPool(JvmBytecodeComponent):
    cdef list[JvmBytecodeConstantPoolEntry] constant_pool

    cdef unsigned short add(self, JvmBytecodeConstantPoolEntry entry) except *
    cdef void parse(self, unsigned char* constant_pool, unsigned short constant_pool_count) except *

    cdef int render(self, unsigned char* buffer) except -1
    cdef unsigned int size(self) except 0


    cdef JvmBytecodeConstantPoolEntry find_string(self, str py_string, bint put=?) except *
    cdef JvmBytecodeConstantPoolEntry find_class(self, str py_class, bint put=?) except *
    cdef JvmBytecodeConstantPoolEntry find_long(self, long py_long, bint put=?) except *
    cdef JvmBytecodeConstantPoolEntry find_float(self, float py_float, bint put=?) except *
    cdef JvmBytecodeConstantPoolEntry find_double(self, double py_double, bint put=?) except *
    cdef JvmBytecodeConstantPoolEntry find_integer(self, int py_integer, bint put=?) except *
    
    

cdef class JvmBytecodeConstantPoolEntry:
    cdef unsigned char tag
    cdef unsigned short offset
    
    cdef int size(self)

    cdef int render(self, unsigned char* buffer) except -1
    cdef void parse(self, unsigned char* buffer) except *
    cdef bint skip_next(self)
    cdef void set_offset(self, unsigned short offset)