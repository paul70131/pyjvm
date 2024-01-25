from pyjvm.bytecode.components.jvmbytecodeattributes cimport JvmBytecodeAttributes
from pyjvm.bytecode.components.jvmbytecodeconstantpool cimport JvmBytecodeConstantPool
from pyjvm.bytecode.components.jvmbytecodefields cimport JvmBytecodeFields, JvmBytecodeField
from pyjvm.bytecode.components.jvmbytecodeinterfaces cimport JvmBytecodeInterfaces
from pyjvm.bytecode.components.jvmbytecodemethods cimport JvmBytecodeMethods


cdef class JvmBytecodeClass:
    cdef object klass

    cdef unsigned short minor_version
    cdef unsigned short major_version
    cdef JvmBytecodeConstantPool constant_pool

    cdef unsigned short access_flags
    cdef unsigned short this_class
    cdef unsigned short super_class
    
    cdef JvmBytecodeInterfaces interfaces
    cdef JvmBytecodeFields fields
    cdef JvmBytecodeMethods methods
    cdef JvmBytecodeAttributes attributes


