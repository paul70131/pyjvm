
from enum import Enum

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

    def __eq__(self, other):
        if isinstance(other, JvmSignature):
            return self.value == other.value
        elif isinstance(other, str):
            return self.value == other
        else:
            return False

