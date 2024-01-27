

class JvmFieldAnnotation:
    signature: str # e.g. "Ljava/lang/String;", "I", "F", ...
    static: bool

    def __init__(self, signature: str, static: bool):
        self.signature = signature
        self.static = static

class Object(JvmFieldAnnotation):
    def __init__(self, type: "JvmClassMeta"):
        from pyjvm.types.clazz.jvmclass import JvmClassMeta
        if not isinstance(type, JvmClassMeta):
            raise TypeError("Object annotation requires a JvmClassMeta type")
        super().__init__(type.signature, False)

Boolean = JvmFieldAnnotation("Z", False)
Byte = JvmFieldAnnotation("B", False)
Char = JvmFieldAnnotation("C", False)
Short = JvmFieldAnnotation("S", False)
Int = JvmFieldAnnotation("I", False)
Long = JvmFieldAnnotation("J", False)
Float = JvmFieldAnnotation("F", False)
Double = JvmFieldAnnotation("D", False)
Void = JvmFieldAnnotation("V", False)

class StaticObject(JvmFieldAnnotation):
    def __init__(self, type: "JvmClassMeta"):
        from pyjvm.types.clazz.jvmclass import JvmClassMeta
        if not isinstance(type, JvmClassMeta):
            raise TypeError("Object annotation requires a JvmClassMeta type")
        super().__init__(type.signature, True)

StaticBoolean = JvmFieldAnnotation("Z", True)
StaticByte = JvmFieldAnnotation("B", True)
StaticChar = JvmFieldAnnotation("C", True)
StaticShort = JvmFieldAnnotation("S", True)
StaticInt = JvmFieldAnnotation("I", True)
StaticLong = JvmFieldAnnotation("J", True)
StaticFloat = JvmFieldAnnotation("F", True)
StaticDouble = JvmFieldAnnotation("D", True)
StaticVoid = JvmFieldAnnotation("V", True)
