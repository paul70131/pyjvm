

class JvmTypeAnnotation:
    signature: str # e.g. "Ljava/lang/String;", "I", "F", ...
    static: bool

    def __init__(self, signature: str, static: bool):
        self.signature = signature
        self.static = static


StaticBoolean = JvmTypeAnnotation("Z", True)
StaticByte = JvmTypeAnnotation("B", True)
StaticChar = JvmTypeAnnotation("C", True)
StaticShort = JvmTypeAnnotation("S", True)
StaticInt = JvmTypeAnnotation("I", True)
StaticLong = JvmTypeAnnotation("J", True)
StaticFloat = JvmTypeAnnotation("F", True)
StaticDouble = JvmTypeAnnotation("D", True)
StaticVoid = JvmTypeAnnotation("V", True)

Boolean = JvmTypeAnnotation("Z", False)
Byte = JvmTypeAnnotation("B", False)
Char = JvmTypeAnnotation("C", False)
Short = JvmTypeAnnotation("S", False)
Int = JvmTypeAnnotation("I", False)
Long = JvmTypeAnnotation("J", False)
Float = JvmTypeAnnotation("F", False)
Double = JvmTypeAnnotation("D", False)
Void = JvmTypeAnnotation("V", False)