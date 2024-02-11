
from enum import Enum

cdef char JVM_SIG_BOOLEAN = 0x5A
cdef char JVM_SIG_BYTE = 0x42
cdef char JVM_SIG_CHAR = 0x43
cdef char JVM_SIG_SHORT = 0x53
cdef char JVM_SIG_INT = 0x49
cdef char JVM_SIG_LONG = 0x4A
cdef char JVM_SIG_FLOAT = 0x46
cdef char JVM_SIG_DOUBLE = 0x44
cdef char JVM_SIG_VOID = 0x56
cdef char JVM_SIG_CLASS = 0x4C
cdef char JVM_SIG_ARRAY = 0x5B

class JvmSignature(Enum):
    BOOLEAN = "Z"
    BYTE = "B"
    CHAR = "C"
    SHORT = "S"
    INT = "I"
    LONG = "J"
    FLOAT = "F"
    DOUBLE = "D"
    VOID = "V"
    CLASS = "L"
    ARRAY = "["

    def __eq__(self, other):
        if isinstance(other, JvmSignature):
            return self.value == other.value
        elif isinstance(other, str):
            return self.value == other
        else:
            return False

