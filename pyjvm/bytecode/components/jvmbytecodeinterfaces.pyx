
from libc.stdlib cimport malloc, free
from pyjvm.bytecode.components.jvmbytecodeconstantpool cimport JvmBytecodeConstantPool

cdef class JvmBytecodeInterface:
    cdef unsigned short interface_index

cdef class JvmBytecodeInterfaces(JvmBytecodeComponent):

    def __init__(self, list interfaces, JvmBytecodeConstantPool cp):
        self.interfaces = interfaces
        self.interface_ids = []
        for i in self.interfaces:
            self.interface_ids.append(cp.find_class(i.__name__, True).offset)

    cdef int render(self, unsigned char* buffer) except -1:
        cdef unsigned short i = len(self.interfaces)
        buffer[0] = i >> 8
        buffer[1] = i & 0xFF

        buffer += 2

        for i in self.interface_ids:
            buffer[0] = i >> 8
            buffer[1] = i & 0xFF
            buffer += 2

        return 2 + len(self.interfaces) * 2

    cdef unsigned int size(self) except 0:
        return 2 + len(self.interfaces) * 2



