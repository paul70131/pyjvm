from pyjvm.jvm cimport Jvm
from pyjvm.bytecode.components.jvmbytecodeconstantpool cimport JvmBytecodeConstantPool, JvmBytecodeConstantPoolEntry
from pyjvm.types.clazz.jvmmethod cimport JvmMethod, JvmMethodSignature
from pyjvm.bytecode.components.jvmbytecodeattributes cimport JvmBytecodeAttributes, CodeAttribute, StackMapTableAttribute
from pyjvm.c.jni cimport JNIEnv, jobject, jclass

from pyjvm.bytecode.components.base cimport JvmBytecodeComponent
from pyjvm.bytecode.jvmmethodlink cimport JvmMethodLink

from libc.stdlib cimport malloc, free

import sys



cdef class JvmBytecodeMethod:
    #cdef unsigned short access_flags
    #cdef unsigned short name_index
    #cdef unsigned short descriptor_index
    #cdef JvmBytecodeAttributes attributes

    def __init__(self, unsigned short access_flags, unsigned short name_index, unsigned short descriptor_index):
        self.access_flags = access_flags
        self.name_index = name_index
        self.descriptor_index = descriptor_index
        self.attributes = JvmBytecodeAttributes()

    @property
    def attributes(self):
        return self.attributes

cdef class JvmBytecodeMethods(JvmBytecodeComponent):
    #cdef list[JvmBytecodeMethod] fields

    def __init__(self):
        self.methods = []

    cdef int render(self, unsigned char* buffer) except -1:
        cdef unsigned int offset = 0
        cdef JvmBytecodeMethod method

        buffer[0] = (len(self.methods) >> 8) & 0xFF
        buffer[1] = len(self.methods) & 0xFF

        offset += 2

        for method in self.methods:
            buffer[offset] = (method.access_flags >> 8) & 0xFF
            buffer[offset + 1] = method.access_flags & 0xFF
            buffer[offset + 2] = (method.name_index >> 8) & 0xFF
            buffer[offset + 3] = method.name_index & 0xFF
            buffer[offset + 4] = (method.descriptor_index >> 8) & 0xFF
            buffer[offset + 5] = method.descriptor_index & 0xFF

            offset += 6

            offset += method.attributes.render(buffer + offset)

        return offset


    cdef unsigned int size(self) except 0:
        cdef unsigned int size = 2
        cdef JvmBytecodeMethod method
        for method in self.methods:
            size += 6
            size += method.attributes.size()
        return size



    def add_new(self, JvmBytecodeConstantPool cp, int access_flags, str name, JvmMethodSignature descriptor, Jvm jvm, object method, object super_class):
        cdef JvmBytecodeMethod adapted = None

        from pyjvm.bytecode.adapter import adapters

        errs = []

        for adapter in adapters:
            try:
                adapted = adapter.adapt(cp, access_flags, name, descriptor, jvm, method, super_class)
            except Exception as e:
                errs.append(e)

        if adapted is None:
            raise Exception("Could not adapt method") from errs[0] if len(errs) > 0 else None

        self.add(adapted)

    cdef void add(self, JvmBytecodeMethod method) except *:
        self.methods.append(method)
