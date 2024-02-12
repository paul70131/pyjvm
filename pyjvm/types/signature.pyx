
from enum import Enum

cdef char JVM_SIG_BOOLEAN = 0x5A # Z
cdef char JVM_SIG_BYTE = 0x42 # B
cdef char JVM_SIG_CHAR = 0x43 # C
cdef char JVM_SIG_SHORT = 0x53 # S
cdef char JVM_SIG_INT = 0x49 # I
cdef char JVM_SIG_LONG = 0x4A # J
cdef char JVM_SIG_FLOAT = 0x46 # F
cdef char JVM_SIG_DOUBLE = 0x44 # D
cdef char JVM_SIG_VOID = 0x56 # V
cdef char JVM_SIG_CLASS = 0x4C # L
cdef char JVM_SIG_ARRAY = 0x5B # [
cdef char JVM_SIG_END = 0x3b # ;
cdef char JVM_SIG_ARGS_START = 0x28 # (
cdef char JVM_SIG_ARGS_END = 0x29 # )

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

