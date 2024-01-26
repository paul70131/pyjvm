from pyjvm.c.jni cimport JNIEnv, jobject, jclass
from pyjvm.types.clazz.jvmclass cimport JvmObjectFromJobject
from pyjvm.bytecode.components.jvmbytecodeattributes cimport JvmBytecodeAttributes, ConstantValueAttribute

import time


cdef class JvmBytecodeField:

    def __init__(self, unsigned short access_flags, unsigned short name_index, unsigned short descriptor_index):
        self.access_flags = access_flags
        self.name_index = name_index
        self.descriptor_index = descriptor_index
        self.attributes = JvmBytecodeAttributes()

cdef class JvmBytecodeFields(JvmBytecodeComponent):
#    cdef list[JvmBytecodeField] fields

    def __init__(self):
        self.fields = []

    cdef int render(self, unsigned char* buffer) except -1:
        cdef unsigned int offset = 0
        cdef unsigned int fields_count = len(self.fields)
        cdef JvmBytecodeField field

        buffer[offset] = (fields_count >> 8) & 0xFF
        buffer[offset + 1] = fields_count & 0xFF
        offset += 2

        for field in self.fields:
            buffer[offset] = (field.access_flags >> 8) & 0xFF
            buffer[offset + 1] = field.access_flags & 0xFF
            buffer[offset + 2] = (field.name_index >> 8) & 0xFF
            buffer[offset + 3] = field.name_index & 0xFF
            buffer[offset + 4] = (field.descriptor_index >> 8) & 0xFF
            buffer[offset + 5] = field.descriptor_index & 0xFF
            offset += 6

            offset += field.attributes.render(buffer + offset)

        return offset

    cdef unsigned int size(self) except 0:
        cdef unsigned int size = 2 # fields_count
        cdef JvmBytecodeField field

        for field in self.fields:
            size += 2  # access_flags
            size += 2  # name_index
            size += 2  # descriptor_index
            size += field.attributes.size()

        return size

    cdef JvmBytecodeField add_new(self, JvmBytecodeConstantPool cp, str name, str signature, bint static, bint public = True, object default = None) except *:
        cdef unsigned short access_flags = 0
        cdef JvmBytecodeConstantPoolEntry name_entry
        cdef JvmBytecodeConstantPoolEntry descriptor_entry
        cdef JvmBytecodeField field

        if public:
            access_flags |= 0x0001  # Set the public flag

        if static:
            access_flags |= 0x0008  # Set the static flag

        name_entry = cp.find_string(name, True)
        descriptor_entry = cp.find_string(signature, True)

        field = JvmBytecodeField(access_flags, name_entry.offset, descriptor_entry.offset)
        self.add(field)

        if default:
            attr = ConstantValueAttribute(signature, default, cp)
            field.attributes.add(attr)
    
        

    cdef void add(self, JvmBytecodeField bc_field) except *:
        self.fields.append(bc_field)    



