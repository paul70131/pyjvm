from pyjvm.bytecode.components.base cimport JvmBytecodeComponent


cdef class JvmBytecodeConstantPool(JvmBytecodeComponent):
    cdef list[JvmBytecodeConstantPoolEntry] constant_pool

    cdef unsigned char* render(self) except *

    cdef void add(self, JvmBytecodeConstantPoolEntry entry) except *
    cdef void parse(self, unsigned char* constant_pool, unsigned short constant_pool_count) except *

    cdef int size(self)


    cdef JvmBytecodeConstantPoolEntry find_string(self, str py_string) except *
    cdef JvmBytecodeConstantPoolEntry find_class(self, str py_class) except *
    cdef JvmBytecodeConstantPoolEntry find_long(self, long py_long) except *
    cdef JvmBytecodeConstantPoolEntry find_float(self, float py_float) except *
    cdef JvmBytecodeConstantPoolEntry find_double(self, double py_double) except *
    cdef JvmBytecodeConstantPoolEntry find_integer(self, int py_integer) except *
    
    

cdef class JvmBytecodeConstantPoolEntry:
    cdef unsigned char tag
    cdef unsigned short offset
    
    cdef int size(self)

    cdef void render(self, unsigned char* buffer) except *
    cdef void parse(self, unsigned char* buffer) except *
    cdef bint skip_next(self)
    cdef void set_offset(self, unsigned short offset)