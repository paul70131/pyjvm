from libc.stdlib cimport malloc, free, realloc
from libc.string cimport memcpy, strncmp

from pyjvm.c.jni cimport jfloat, jdouble

from pyjvm.bytecode.components.base cimport JvmBytecodeComponent

cdef class JvmBytecodeConstantPool(JvmBytecodeComponent):
    #cdef list[JvmBytecodeConstantPoolEntry] constant_pool = []

    cdef int render(self, unsigned char* buffer) except -1:
        # we assume that the buffer is large enough since it was allocated by us using size()
        cdef unsigned short constant_pool_count = <unsigned short>len(self.constant_pool) + 1
        cdef unsigned int buffer_offset = 2
        cdef JvmBytecodeConstantPoolEntry entry

        buffer[0] = constant_pool_count >> 8
        buffer[1] = constant_pool_count & 0xFF

        for entry in self.constant_pool:
            entry.render(&buffer[buffer_offset])
            buffer_offset += entry.size()

        return buffer_offset

    cdef unsigned int size(self) except 0:
        cdef unsigned int size = 2
        for entry in self.constant_pool:
            size += entry.size()
        return size



    def __init__(self):
        self.constant_pool = []

    def get(self, index):
        return self.constant_pool[index]

    cdef unsigned short add(self, JvmBytecodeConstantPoolEntry entry) except *:
        if isinstance(entry, JBCPE_Long) or isinstance(entry, JBCPE_Double):
            self.constant_pool.append(entry)
            self.constant_pool.append(JBCPE_Placeholder())
            entry.set_offset(len(self.constant_pool) - 1)
            return len(self.constant_pool) - 1

        self.constant_pool.append(entry)
        entry.set_offset(len(self.constant_pool))
        return len(self.constant_pool)

    

    cpdef JvmBytecodeConstantPoolEntry find_class(self, str py_class, bint put=False) except *:
        cdef JvmBytecodeConstantPoolEntry entry
        cdef JvmBytecodeConstantPoolEntry name_entry

        name_entry = self.find_string(py_class.replace(".", "/"), put)

        for entry in self.constant_pool:
            if entry.tag == 7:
                class_entry = <JBCPE_Class>entry

                if class_entry.name_index == name_entry.offset:
                    return entry
        

        if put:
            entry = JBCPE_Class(name_entry.offset)
            self.add(entry)
            return entry

        raise Exception("Class not found in constant pool: %s" % py_class)

    cpdef JvmBytecodeConstantPoolEntry find_jstring(self, str py_string, bint put=False) except *:
        cdef JvmBytecodeConstantPoolEntry entry
        cdef JvmBytecodeConstantPoolEntry value_entry

        value_entry = self.find_string(py_string, put)

        for entry in self.constant_pool:
            if entry.tag == 9:
                str_entry = <JBCPE_String>entry

                if str_entry.string_index == value_entry.offset:
                    return str_entry
        
        if put:
            entry = JBCPE_String(value_entry.offset)
            self.add(entry)
            return entry
        
        raise Exception("String not found in constant pool: %s" % py_string)



    cpdef JvmBytecodeConstantPoolEntry find_long(self, long py_long, bint put=False) except *:
        cdef JvmBytecodeConstantPoolEntry entry
        cdef JBCPE_Long long_entry

        for entry in self.constant_pool:
            if entry.tag == 5:
                long_entry = <JBCPE_Long>entry

                if long == py_long:
                    return entry
        
        if put:
            entry = JBCPE_Long(py_long)
            self.add(entry)
            return entry

        raise Exception()

    cpdef JvmBytecodeConstantPoolEntry find_float(self, float py_float, bint put=False) except *:
        cdef JvmBytecodeConstantPoolEntry entry
        cdef JBCPE_Float float_entry

        for entry in self.constant_pool:
            if entry.tag == 4:
                float_entry = <JBCPE_Float>entry

                if float_entry.bytes == py_float:
                    return entry

        if put:
            entry = JBCPE_Float(py_float)
            self.add(entry)
            return entry

        raise Exception()

    cpdef JvmBytecodeConstantPoolEntry find_double(self, double py_double, bint put=False) except *:
        cdef JvmBytecodeConstantPoolEntry entry
        cdef JBCPE_Double double_entry

        for entry in self.constant_pool:
            if entry.tag == 6:
                double_entry = <JBCPE_Double>entry

                if double_entry.bytes == py_double:
                    return entry
        
        if put:
            entry = JBCPE_Double(py_double)
            self.add(entry)
            return entry

        raise Exception()

    cpdef JvmBytecodeConstantPoolEntry find_integer(self, int py_integer, bint put=False) except *:
        cdef JvmBytecodeConstantPoolEntry entry
        cdef JBCPE_Integer integer_entry

        for entry in self.constant_pool:
            if entry.tag == 3:
                integer_entry = <JBCPE_Integer>entry

                if integer_entry.bytes == py_integer:
                    return entry

        if put:
            entry = JBCPE_Integer(py_integer)
            self.add(entry)
            return entry

        raise Exception()
        

    cpdef JvmBytecodeConstantPoolEntry find_string(self, str py_string, bint put=False) except *:
        cdef JvmBytecodeConstantPoolEntry entry
        cdef JBCPE_Utf8 utf8_entry
        cdef char* string

        py_byte_string = py_string.encode("utf-8")
        string = py_byte_string

        for entry in self.constant_pool:
            if entry.tag == 1:
                utf8_entry = <JBCPE_Utf8>entry

                if len(py_string) == utf8_entry.length and strncmp(<const char*>utf8_entry.bytes, string, utf8_entry.length) == 0:
                    return entry
        
        if put:
            utf8_entry = JBCPE_Utf8(py_string)
            self.add(utf8_entry)
            return utf8_entry

        raise Exception("String not found in constant pool: %s" % string)

    cpdef JvmBytecodeConstantPoolEntry find_name_and_type(self, str name, str type_, bint put=False) except *:
        cdef JvmBytecodeConstantPoolEntry entry
        cdef JvmBytecodeConstantPoolEntry name_entry
        cdef JvmBytecodeConstantPoolEntry type_entry

        name_entry = self.find_string(name, put)
        type_entry = self.find_string(type_, put)

        for entry in self.constant_pool:
            if entry.tag == 12:
                nt_entry = <JBCPE_NameAndType>entry

                if nt_entry.name_index == name_entry.offset and nt_entry.descriptor_index == type_entry.offset:
                    return entry

        
        if put:
            entry = JBCPE_NameAndType(name_entry.offset, type_entry.offset)
            self.add(entry)
            return entry

        raise Exception(f"NameAndType not found in CP: {name} {type}")

    cpdef JvmBytecodeConstantPoolEntry find_interface_methodref(self, str classname, str methodname, str methodtype, bint put=False) except *:
        cdef JvmBytecodeConstantPoolEntry entry
        cdef JvmBytecodeConstantPoolEntry class_entry
        cdef JvmBytecodeConstantPoolEntry nt_entry

        class_entry = self.find_class(classname, put)
        nt_entry = self.find_name_and_type(methodname, methodtype, put)

        for entry in self.constant_pool:
            if entry.tag == 11:
                methodref_entry = <JBCPE_InterfaceMethodref>entry

                if methodref_entry.class_index == class_entry.offset and methodref_entry.name_and_type_index == nt_entry.offset:
                    return entry
        
        if put:
            entry = JBCPE_InterfaceMethodref(class_entry.offset, nt_entry.offset)
            self.add(entry)
            return entry
        
        raise Exception(f"MethodRef not found in CP: {classname} {methodname} {methodtype}")

    cpdef JvmBytecodeConstantPoolEntry find_methodref(self, str classname, str methodname, str methodtype, bint put=False) except *:
        cdef JvmBytecodeConstantPoolEntry entry
        cdef JvmBytecodeConstantPoolEntry class_entry
        cdef JvmBytecodeConstantPoolEntry nt_entry

        class_entry = self.find_class(classname, put)
        nt_entry = self.find_name_and_type(methodname, methodtype, put)

        for entry in self.constant_pool:
            if entry.tag == 10:
                methodref_entry = <JBCPE_Methodref>entry

                if methodref_entry.class_index == class_entry.offset and methodref_entry.name_and_type_index == nt_entry.offset:
                    return entry
        
        if put:
            entry = JBCPE_Methodref(class_entry.offset, nt_entry.offset)
            self.add(entry)
            return entry
        
        raise Exception(f"MethodRef not found in CP: {classname} {methodname} {methodtype}")


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

    @property
    def offset(self):
        return self.offset

    cdef void set_offset(self, unsigned short offset):
        self.offset = offset

    cdef bint skip_next(self):
        return False

    cdef int size(self):
        raise NotImplementedError()

    cdef int render(self, unsigned char* buffer) except -1:
        raise NotImplementedError()

    cdef void parse(self, unsigned char* buffer) except *:
        raise NotImplementedError()
    
cdef class JBCPE_Class(JvmBytecodeConstantPoolEntry):
    cdef unsigned short name_index

    @property
    def name_index(self):
        return self.name_index

    def __init__(self, unsigned short name_idx):
        self.tag = 7
        if name_idx:
            self.name_index = name_idx

    cpdef int size(self):
        return 3

    cdef int render(self, unsigned char* buffer) except -1:
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

    cdef int render(self, unsigned char* buffer) except -1:
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

    def __init__(self, unsigned short class_idx = 0, unsigned short name_and_type_idx = 0):
        self.tag = 10
        if class_idx:
            self.class_index = class_idx
        if name_and_type_idx:
            self.name_and_type_index = name_and_type_idx

    cpdef int size(self):
        return 5

    def signature(self, cp):
        cdef JBCPE_NameAndType nt = <JBCPE_NameAndType>cp.get(self.name_and_type_index - 1)
        cdef JBCPE_Utf8 name = <JBCPE_Utf8>cp.get(nt.name_index - 1)
        cdef JBCPE_Utf8 sig = <JBCPE_Utf8>cp.get(nt.descriptor_index - 1)

        return (name, sig)

    cdef int render(self, unsigned char* buffer) except -1:
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

    def __init__(self, unsigned short class_idx = 0, unsigned short name_and_type_idx = 0):
        self.tag = 11
        if class_idx:
            self.class_index = class_idx
        if name_and_type_idx:
            self.name_and_type_index = name_and_type_idx

    def signature(self, cp):
        cdef JBCPE_NameAndType nt = <JBCPE_NameAndType>cp.get(self.name_and_type_index - 1)
        cdef JBCPE_Utf8 name = <JBCPE_Utf8>cp.get(nt.name_index - 1)
        cdef JBCPE_Utf8 sig = <JBCPE_Utf8>cp.get(nt.descriptor_index - 1)

        return (name, sig)
    
    cpdef int size(self):
        return 5
    
    cdef int render(self, unsigned char* buffer) except -1:
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

    def __init__(self, unsigned short string_idx = 0):
        self.tag = 8
        if string_idx:
            self.string_index = string_idx

    cpdef int size(self):
        return 3

    cdef int render(self, unsigned char* buffer) except -1:
        buffer[0] = self.tag
        buffer[1] = self.string_index >> 8
        buffer[2] = self.string_index & 0xFF
    
    cdef void parse(self, unsigned char* buffer) except *:
        self.string_index = (buffer[1] << 8 | buffer[2])

cdef class JBCPE_Integer(JvmBytecodeConstantPoolEntry):
    cdef int bytes

    def __init__(self, object py_int = None):
        self.tag = 3
        if py_int != None:
            self.bytes =<int> py_int

    cpdef int size(self):
        return 5

    cdef int render(self, unsigned char* buffer) except -1:
        buffer[0] = self.tag
        buffer[1] = self.bytes >> 24
        buffer[2] = (self.bytes >> 16) & 0xFF
        buffer[3] = (self.bytes >> 8) & 0xFF
        buffer[4] = self.bytes & 0xFF
    
    cdef void parse(self, unsigned char* buffer) except *:
        memcpy(&self.bytes, &buffer[1], 4)
    
cdef class JBCPE_Float(JvmBytecodeConstantPoolEntry):
    cdef float bytes

    def __init__(self, object py_float = None):
        self.tag = 4
        if py_float != None:
            self.bytes =<float> py_float

    cpdef int size(self):
        return 5

    cdef int render(self, unsigned char* buffer) except -1:
        cdef jfloat jfloat_bytes = self.bytes
        buffer[0] = self.tag
        buffer[1] = (<unsigned char*>(&jfloat_bytes))[3]
        buffer[2] = (<unsigned char*>(&jfloat_bytes))[2]
        buffer[3] = (<unsigned char*>(&jfloat_bytes))[1]
        buffer[4] = (<unsigned char*>(&jfloat_bytes))[0]
    
    
    
    cdef void parse(self, unsigned char* buffer) except *:
        buffer[0] = self.tag
        memcpy(&buffer[1], &self.bytes, 4)
    
cdef class JBCPE_Long(JvmBytecodeConstantPoolEntry):
    cdef long bytes

    def __init__(self, object py_long = None):
        self.tag = 5
        if py_long != None:
            self.bytes =<long> py_long

    cdef bint skip_next(self):
        return True

    cpdef int size(self):
        return 9

    cdef int render(self, unsigned char* buffer) except -1:
        buffer[0] = self.tag
        buffer[1] = (self.bytes >> 56) & 0xFF
        buffer[2] = (self.bytes >> 48) & 0xFF
        buffer[3] = (self.bytes >> 40) & 0xFF
        buffer[4] = (self.bytes >> 32) & 0xFF
        buffer[5] = (self.bytes >> 24) & 0xFF
        buffer[6] = (self.bytes >> 16) & 0xFF
        buffer[7] = (self.bytes >> 8) & 0xFF
        buffer[8] = self.bytes & 0xFF
    
    cdef void parse(self, unsigned char* buffer) except *:
        memcpy(&self.bytes, &buffer[1], 8)
    
cdef class JBCPE_Double(JvmBytecodeConstantPoolEntry):
    cdef double bytes

    def __init__(self, object py_double = None):
        self.tag = 6
        if py_double != None:
            self.bytes = <double>py_double

    cdef bint skip_next(self):
        return True

    cpdef int size(self):
        return 9

    cdef int render(self, unsigned char* buffer) except -1:
        cdef jdouble joduble_bytes = self.bytes
        buffer[0] = self.tag

        buffer[1] = (<unsigned char*>(&joduble_bytes))[7]
        buffer[2] = (<unsigned char*>(&joduble_bytes))[6]
        buffer[3] = (<unsigned char*>(&joduble_bytes))[5]
        buffer[4] = (<unsigned char*>(&joduble_bytes))[4]
        buffer[5] = (<unsigned char*>(&joduble_bytes))[3]
        buffer[6] = (<unsigned char*>(&joduble_bytes))[2]
        buffer[7] = (<unsigned char*>(&joduble_bytes))[1]
        buffer[8] = (<unsigned char*>(&joduble_bytes))[0]
    
    cdef void parse(self, unsigned char* buffer) except *:
        memcpy(&self.bytes, &buffer[1], 8)

cdef class JBCPE_Placeholder(JvmBytecodeConstantPoolEntry):
    def __init__(self):
        self.tag = 0

    cpdef int size(self):
        return 0

    cdef int render(self, unsigned char* buffer) except -1:
        pass

    cdef void parse(self, unsigned char* buffer) except *:
        pass
    
cdef class JBCPE_NameAndType(JvmBytecodeConstantPoolEntry):
    cdef unsigned short name_index
    cdef unsigned short descriptor_index

    def __init__(self, name_idx = 0, descriptor_idx = 0):
        self.tag = 12
        if name_idx:
            self.name_index = name_idx
        if descriptor_idx:
            self.descriptor_index = descriptor_idx

    cpdef int size(self):
        return 5

    cdef int render(self, unsigned char* buffer) except -1:
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

    def __str__(self):
        return self.bytes.decode("utf-8")

    def __init__(self, str py_string = None):
        cdef unsigned char* cb
        self.tag = 1
        if py_string:
            utf8 = py_string.encode("utf-8")
            cb = utf8
            self.bytes = <unsigned char*>malloc(len(cb) + 1)
            memcpy(self.bytes, cb, len(cb))
            self.bytes[len(cb)] = 0
            self.length = len(self.bytes)
        else:
            self.bytes = NULL
            self.length = 0

    cpdef int size(self):
        return 3 + self.length

    cdef int render(self, unsigned char* buffer) except -1:
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

    cdef int render(self, unsigned char* buffer) except -1:
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

    cdef int render(self, unsigned char* buffer) except -1:
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

    cdef int render(self, unsigned char* buffer) except -1:
        buffer[0] = self.tag
        buffer[1] = self.bootstrap_method_attr_index >> 8
        buffer[2] = self.bootstrap_method_attr_index & 0xFF
        buffer[3] = self.name_and_type_index >> 8
        buffer[4] = self.name_and_type_index & 0xFF

    cdef void parse(self, unsigned char* buffer) except *:
        memcpy(&self.bootstrap_method_attr_index, &buffer[1], 2)
        memcpy(&self.name_and_type_index, &buffer[3], 2)


