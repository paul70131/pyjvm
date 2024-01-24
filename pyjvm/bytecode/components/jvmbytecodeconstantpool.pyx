from libc.stdlib cimport malloc, free, realloc
from libc.string cimport memcpy, strncmp

from pyjvm.bytecode.components.base cimport JvmBytecodeComponent

cdef class JvmBytecodeConstantPool(JvmBytecodeComponent):
    #cdef list[JvmBytecodeConstantPoolEntry] constant_pool = []

    cdef unsigned char* render(self) except *:
        cdef unsigned short constant_pool_count = <unsigned short>len(self.constant_pool)
        cdef unsigned int buffer_size = 2

        self.buffer = <unsigned char*>malloc(sizeof(unsigned short))

        self.buffer[0] = constant_pool_count >> 8
        self.buffer[1] = constant_pool_count & 0xFF

        for entry in self.constant_pool:
            self.buffer = <unsigned char*>realloc(self.buffer, buffer_size + entry.size())



    def __init__(self):
        self.constant_pool = []

    cdef void add(self, JvmBytecodeConstantPoolEntry entry) except *:
        self.constant_pool.append(entry)

    cdef int size(self):
        return len(self.constant_pool) + 1

    cdef JvmBytecodeConstantPoolEntry find_class(self, str py_class) except *:
        cdef JvmBytecodeConstantPoolEntry entry
        cdef JvmBytecodeConstantPoolEntry name_entry

        name_entry = self.find_string(py_class.replace(".", "/"))

        for entry in self.constant_pool:
            if entry.tag == 7:
                class_entry = <JBCPE_Class>entry

                if class_entry.name_index == name_entry.offset:
                    return entry

        raise Exception("Class not found in constant pool: %s" % py_class)

        

    cdef JvmBytecodeConstantPoolEntry find_string(self, str py_string) except *:
        cdef JvmBytecodeConstantPoolEntry entry
        cdef JBCPE_Utf8 utf8_entry
        cdef char* string

        py_byte_string = py_string.encode("utf-8")
        string = py_byte_string

        for entry in self.constant_pool:
            if entry.tag == 1:
                utf8_entry = <JBCPE_Utf8>entry

                if strncmp(<const char*>utf8_entry.bytes, string, utf8_entry.length) == 0:
                    return entry

        raise Exception("String not found in constant pool: %s" % string)

    cdef void parse(self, unsigned char* constant_pool, unsigned short constant_pool_count) except *:
        cdef int b_offset = 0

        skip_next = False

        for i in range(constant_pool_count - 1):
            if skip_next:
                skip_next = False
                continue
            
            e = get_entry(constant_pool[b_offset])
            e.parse(&constant_pool[b_offset])
            b_offset += e.size()

            e.set_offset(i + 1)

            if e.skip_next():
                skip_next = True

            self.constant_pool.append(e)



cdef JvmBytecodeConstantPoolEntry get_entry(unsigned char tag):
    if tag == 1:
        return JBCPE_Utf8()
    elif tag == 3:
        return JBCPE_Integer()
    elif tag == 4:
        return JBCPE_Float()
    elif tag == 5:
        return JBCPE_Long()
    elif tag == 6:
        return JBCPE_Double()
    elif tag == 7:
        return JBCPE_Class()
    elif tag == 8:
        return JBCPE_String()
    elif tag == 9:
        return JBCPE_Fieldref()
    elif tag == 10:
        return JBCPE_Methodref()
    elif tag == 11:
        return JBCPE_InterfaceMethodref()
    elif tag == 12:
        return JBCPE_NameAndType()
    elif tag == 15:
        return JBCPE_MethodHandle()
    elif tag == 16:
        return JBCPE_MethodType()
    elif tag == 18:
        return JBCPE_InvokeDynamic()
    else:
        return JBCPE_Placeholder()


cdef class JvmBytecodeConstantPoolEntry:
#   cdef unsigned byte tag
#   cdef unsigned short offset

    cdef void set_offset(self, unsigned short offset):
        self.offset = offset

    cdef bint skip_next(self):
        return False

    cdef int size(self):
        raise NotImplementedError()

    cdef void render(self, unsigned char* buffer) except *:
        raise NotImplementedError()

    cdef void parse(self, unsigned char* buffer) except *:
        raise NotImplementedError()
    
cdef class JBCPE_Class(JvmBytecodeConstantPoolEntry):
    cdef unsigned short name_index

    def __init__(self):
        self.tag = 7

    cpdef int size(self):
        return 3

    cdef void render(self, unsigned char* buffer) except *:
        buffer[0] = self.tag
        buffer[1] = self.name_index >> 8
        buffer[2] = self.name_index & 0xFF

    cdef void parse(self, unsigned char* buffer) except *:
        self.name_index = (buffer[1] << 8 | buffer[2])
    
cdef class JBCPE_Fieldref(JvmBytecodeConstantPoolEntry):
    cdef unsigned short class_index
    cdef unsigned short name_and_type_index

    def __init__(self):
        self.tag = 9

    cpdef int size(self):
        return 5

    cdef void render(self, unsigned char* buffer) except *:
        buffer[0] = self.tag
        buffer[1] = self.class_index >> 8
        buffer[2] = self.class_index & 0xFF
        buffer[3] = self.name_and_type_index >> 8
        buffer[4] = self.name_and_type_index & 0xFF
    
    cdef void parse(self, unsigned char* buffer) except *:
        self.class_index = (buffer[1] << 8 | buffer[2])
        self.name_and_type_index = (buffer[3] << 8 | buffer[4])
    
cdef class JBCPE_Methodref(JvmBytecodeConstantPoolEntry):
    cdef unsigned short class_index
    cdef unsigned short name_and_type_index

    def __init__(self):
        self.tag = 10

    cpdef int size(self):
        return 5

    cdef void render(self, unsigned char* buffer) except *:
        buffer[0] = self.tag
        buffer[1] = self.class_index >> 8
        buffer[2] = self.class_index & 0xFF
        buffer[3] = self.name_and_type_index >> 8
        buffer[4] = self.name_and_type_index & 0xFF

    cdef void parse(self, unsigned char* buffer) except *:
        self.class_index = (buffer[1] << 8 | buffer[2])
        self.name_and_type_index = (buffer[3] << 8 | buffer[4])

    
cdef class JBCPE_InterfaceMethodref(JvmBytecodeConstantPoolEntry):
    cdef unsigned short class_index
    cdef unsigned short name_and_type_index

    def __init__(self):
        self.tag = 11
    
    cpdef int size(self):
        return 5
    
    cdef void render(self, unsigned char* buffer) except *:
        buffer[0] = self.tag
        buffer[1] = self.class_index >> 8
        buffer[2] = self.class_index & 0xFF
        buffer[3] = self.name_and_type_index >> 8
        buffer[4] = self.name_and_type_index & 0xFF

    cdef void parse(self, unsigned char* buffer) except *:
        self.class_index = (buffer[1] << 8 | buffer[2])
        self.name_and_type_index = (buffer[3] << 8 | buffer[4])

cdef class JBCPE_String(JvmBytecodeConstantPoolEntry):
    cdef unsigned short string_index

    def __init__(self):
        self.tag = 8

    cpdef int size(self):
        return 3

    cdef void render(self, unsigned char* buffer) except *:
        buffer[0] = self.tag
        buffer[1] = self.string_index >> 8
        buffer[2] = self.string_index & 0xFF
    
    cdef void parse(self, unsigned char* buffer) except *:
        self.string_index = (buffer[1] << 8 | buffer[2])

cdef class JBCPE_Integer(JvmBytecodeConstantPoolEntry):
    cdef int bytes

    def __init__(self):
        self.tag = 3

    cpdef int size(self):
        return 5

    cdef void render(self, unsigned char* buffer) except *:
        buffer[0] = self.tag
        buffer[1] = self.bytes >> 24
        buffer[2] = (self.bytes >> 16) & 0xFF
        buffer[3] = (self.bytes >> 8) & 0xFF
        buffer[4] = self.bytes & 0xFF
    
    cdef void parse(self, unsigned char* buffer) except *:
        memcpy(&self.bytes, &buffer[1], 4)
    
cdef class JBCPE_Float(JvmBytecodeConstantPoolEntry):
    cdef float bytes

    def __init__(self):
        self.tag = 4

    cpdef int size(self):
        return 5

    cdef void render(self, unsigned char* buffer) except *:
        buffer[0] = self.tag
        memcpy(&buffer[1], &self.bytes, 4)
    
    cdef void parse(self, unsigned char* buffer) except *:
        memcpy(&self.bytes, &buffer[1], 4)
    
cdef class JBCPE_Long(JvmBytecodeConstantPoolEntry):
    cdef long bytes

    def __init__(self):
        self.tag = 5

    cdef bint skip_next(self):
        return True

    cpdef int size(self):
        return 9

    cdef void render(self, unsigned char* buffer) except *:
        buffer[0] = self.tag
        memcpy(&buffer[1], &self.bytes, 8)
    
    cdef void parse(self, unsigned char* buffer) except *:
        memcpy(&self.bytes, &buffer[1], 8)
    
cdef class JBCPE_Double(JvmBytecodeConstantPoolEntry):
    cdef double bytes

    def __init__(self):
        self.tag = 6

    cdef bint skip_next(self):
        return True

    cpdef int size(self):
        return 9

    cdef void render(self, unsigned char* buffer) except *:
        buffer[0] = self.tag
        memcpy(&buffer[1], &self.bytes, 8)
    
    cdef void parse(self, unsigned char* buffer) except *:
        memcpy(&self.bytes, &buffer[1], 8)

cdef class JBCPE_Placeholder(JvmBytecodeConstantPoolEntry):
    def __init__(self):
        self.tag = 0

    cpdef int size(self):
        return 0

    cdef void render(self, unsigned char* buffer) except *:
        pass

    cdef void parse(self, unsigned char* buffer) except *:
        pass
    
cdef class JBCPE_NameAndType(JvmBytecodeConstantPoolEntry):
    cdef unsigned short name_index
    cdef unsigned short descriptor_index

    def __init__(self):
        self.tag = 12

    cpdef int size(self):
        return 5

    cdef void render(self, unsigned char* buffer) except *:
        buffer[0] = self.tag
        buffer[1] = self.name_index >> 8
        buffer[2] = self.name_index & 0xFF
        buffer[3] = self.descriptor_index >> 8
        buffer[4] = self.descriptor_index & 0xFF
    
    cdef void parse(self, unsigned char* buffer) except *:
        self.name_index = (buffer[1] << 8 | buffer[2])
        self.descriptor_index = (buffer[3] << 8 | buffer[4])

cdef class JBCPE_Utf8(JvmBytecodeConstantPoolEntry):
    cdef unsigned short length
    cdef unsigned char* bytes

    def __init__(self):
        self.tag = 1

    cpdef int size(self):
        return 3 + self.length

    cdef void render(self, unsigned char* buffer) except *:
        buffer[0] = self.tag
        buffer[1] = self.length >> 8
        buffer[2] = self.length & 0xFF
        memcpy(&buffer[3], self.bytes, self.length)
    
    cdef void parse(self, unsigned char* buffer) except *:
        self.length = buffer[1] << 8 | buffer[2]
        self.bytes = <unsigned char*>malloc(self.length)
        memcpy(self.bytes, &buffer[3], self.length)

    def __dealloc__(self):
        free(self.bytes)
    
cdef class JBCPE_MethodHandle(JvmBytecodeConstantPoolEntry):
    cdef unsigned char reference_kind
    cdef unsigned short reference_index

    def __init__(self):
        self.tag = 15

    cpdef int size(self):
        return 4

    cdef void render(self, unsigned char* buffer) except *:
        buffer[0] = self.tag
        buffer[1] = self.reference_kind
        buffer[2] = self.reference_index >> 8
        buffer[3] = self.reference_index & 0xFF

    cdef void parse(self, unsigned char* buffer) except *:
        self.reference_kind = buffer[1]
        memcpy(&self.reference_index, &buffer[2], 2)
    
cdef class JBCPE_MethodType(JvmBytecodeConstantPoolEntry):
    cdef unsigned short descriptor_index

    def __init__(self):
        self.tag = 16

    cpdef int size(self):
        return 3

    cdef void render(self, unsigned char* buffer) except *:
        buffer[0] = self.tag
        buffer[1] = self.descriptor_index >> 8
        buffer[2] = self.descriptor_index & 0xFF

    cdef void parse(self, unsigned char* buffer) except *:
        memcpy(&self.descriptor_index, &buffer[1], 2)
    
cdef class JBCPE_InvokeDynamic(JvmBytecodeConstantPoolEntry):
    cdef unsigned short bootstrap_method_attr_index
    cdef unsigned short name_and_type_index

    def __init__(self):
        self.tag = 18

    cpdef int size(self):
        return 5

    cdef void render(self, unsigned char* buffer) except *:
        buffer[0] = self.tag
        buffer[1] = self.bootstrap_method_attr_index >> 8
        buffer[2] = self.bootstrap_method_attr_index & 0xFF
        buffer[3] = self.name_and_type_index >> 8
        buffer[4] = self.name_and_type_index & 0xFF

    cdef void parse(self, unsigned char* buffer) except *:
        memcpy(&self.bootstrap_method_attr_index, &buffer[1], 2)
        memcpy(&self.name_and_type_index, &buffer[3], 2)


