from pyjvm.jvm cimport Jvm
from pyjvm.bytecode.components.jvmbytecodeconstantpool cimport JvmBytecodeConstantPool
from pyjvm.types.clazz.jvmfield cimport JvmField
from pyjvm.bytecode.components.jvmbytecodeattributes cimport JvmBytecodeAttributes
from pyjvm.c.jni cimport JNIEnv, jobject, jclass

from pyjvm.bytecode.components.base cimport JvmBytecodeComponent




cdef class JvmBytecodeAttribute:
    cdef unsigned short attribute_name_index
    cdef unsigned int attribute_length

    cdef unsigned int render(self, unsigned char* buffer) except 0
    cdef unsigned int size(self) except *

cdef class JvmBytecodeAttributes(JvmBytecodeComponent):
    cdef list[JvmBytecodeAttribute] attributes

        
    cpdef add(self, JvmBytecodeAttribute field)

    
cdef class ConstantValueAttribute(JvmBytecodeAttribute):
    cdef unsigned short constant_value_index

cdef class CodeAttributeExcetionTableEntry:
    cdef unsigned short start_pc
    cdef unsigned short end_pc
    cdef unsigned short handler_pc
    cdef unsigned short catch_type

cdef class CodeAttributeExcetionTable:
    cdef list[CodeAttributeExcetionTableEntry] entries

    cdef unsigned int size(self) except 0

    cdef unsigned int render(self, unsigned char* buffer) except 0


cdef class CodeAttribute(JvmBytecodeAttribute):
    cdef unsigned short max_stack
    cdef unsigned short max_locals
    cdef unsigned int code_length
    cdef unsigned char* code
    cdef CodeAttributeExcetionTable exception_table
    cdef JvmBytecodeAttributes attributes

    cdef unsigned int render(self, unsigned char* buffer) except 0
    cdef unsigned int size(self) except *

cdef class StackMapFrame:
    cdef unsigned char frame_type

    cdef unsigned int render(self, unsigned char* buffer) except 0
    cdef unsigned int size(self) except 0

cdef class VerificationTypeInfo:
    cdef unsigned char tag
    cdef unsigned short cpool_index

    cdef unsigned int render(self, unsigned char* buffer) except 0
    cdef unsigned int size(self) except 0

cdef class AppendFrame(StackMapFrame):
    cdef unsigned short offset_delta
    cdef list[VerificationTypeInfo] locals

    cdef unsigned int render(self, unsigned char* buffer) except 0
    cdef unsigned int size(self) except 0

cdef class StackMapTableAttribute(JvmBytecodeAttribute):
    cdef list[StackMapFrame] frames

    cdef unsigned int size(self) except 0
    cdef unsigned int render(self, unsigned char* buffer) except 0

cdef class LineNumberTableAttributeEntry:
    cdef unsigned short start_pc
    cdef unsigned short line_number

cdef class LineNumberTableAttribute(JvmBytecodeAttribute):
    cdef list[LineNumberTableAttributeEntry] entries

cdef class LocalVariableTableAttributeEntry:
    cdef unsigned short start_pc
    cdef unsigned short length
    cdef unsigned short name_index
    cdef unsigned short descriptor_index
    cdef unsigned short index

cdef class LocalVariableTableAttribute(JvmBytecodeAttribute):
    cdef list[LocalVariableTableAttributeEntry] entries

cdef class LocalVariableTypeTableAttributeEntry:
    cdef unsigned short start_pc
    cdef unsigned short length
    cdef unsigned short name_index
    cdef unsigned short signature_index
    cdef unsigned short index

cdef class LocalVariableTypeTableAttribute(JvmBytecodeAttribute):
    cdef list[LocalVariableTypeTableAttributeEntry] entries


# TODO StackMapTableAttribute
