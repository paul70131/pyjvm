from pyjvm.bytecode.adapter.util.bytecode_writer import BytecodeWriter
from pyjvm.bytecode.adapter.util.opcodes import Opcodes

from typing import Union

class ComptimeType:
    primitive: str
    java_type: str
    implements_primitive: list

    converters_to = {} # to primitive types or other comptime types

    @classmethod
    def convert_to(cls, to: Union["ComptimeType", str], bw: BytecodeWriter, cp):
        if cls == to:
            return

        if to in cls.converters_to:
            cls.converters_to[to](bw, cp)
        else:
            raise NotImplementedError(f"Conversion from {cls} to {to} is not implemented")
        
    @classmethod
    def register_converter(cls, to: "ComptimeType", converter: callable):
        cls.converters_to[to] = converter

    def __repr__(self):
        return f"{self.__class__.__name__}"

class ComptimeUninitialized(ComptimeType):
    primitive = None
    java_type = None
    implements_primitive = []
    stackMapType = "uninitialized"

class ComptimeObject(ComptimeType):
    primitive = None
    java_type = "java/lang/Object"
    implements_primitive = []

    @property
    def stackMapType(self):
        return f"L{self.java_type};"

    def __init__(self, java_type):
        self.java_type = java_type


class ComptimeActualInt(ComptimeType):
    primitive = "I"
    java_type = "I"
    stackMapType = "int"

class ComptimeActualLong(ComptimeType):
    primitive = "J"
    java_type = "J"
    stackMapType = "long"

class ComptimeActualDouble(ComptimeType):
    primitive = "D"
    java_type = "D"
    stackMapType = "double"

class ComptimeActualFloat(ComptimeType):
    primitive = "F"
    java_type = "F"
    stackMapType = "float"

class ComptimeThis(ComptimeObject):
    stackMapType = "Ljava/lang/Object;"
    
    def __init__(self):
        super().__init__("java/lang/Object")

class ComptimeNull(ComptimeObject):
    primitive = None
    java_type = "java/lang/Object"
    implements_primitive = []

    stackMapType = "null"

    def __init__(self):
        super().__init__("java/lang/Object")

class ComptimeTuple(ComptimeObject):
    primitive = None
    java_type = "[Ljava/lang/Object;"
    implements_primitive = []

    def __init__(self, subtype):
        self.subtype = subtype

class ComptimeList(ComptimeObject):
    primitive = None
    java_type = "java/util/List"
    implements_primitive = []
    implementation = "java/util/ArrayList"

    def __init__(self, subtype):
        self.subtype = subtype

class ComptimePyObject(ComptimeObject):
    primitive = None
    java_type = "pyjvm/bridge/java/PyObject"
    implements_primitive = []

class ComptimeString(ComptimeObject):
    primitive = None
    java_type = "java/lang/String"
    implements_primitive = []

    def __init__(self):
        super().__init__("java/lang/String")

class ComptimeLong(ComptimeType):
    primitive = "J"
    java_type = "java/lang/Long"
    implements_primitive = ["J", "I", "S", "B", "C"]
    stackMapType = "Ljava/lang/Long;"

class ComptimeDouble(ComptimeType):
    primitive = "D"
    java_type = "java/lang/Double"
    implements_primitive = ["D", "F"]
    stackMapType = "Ljava/lang/Double;"

class ComptimeBoolean(ComptimeType):
    primitive = "Z"
    java_type = "java/lang/Boolean"
    implements_primitive = ["Z"]
    stackMapType = "Ljava/lang/Boolean;"

class ComptimeMethod(ComptimeObject):
    primitive = None
    java_type = "java/lang/reflect/Method"
    implements_primitive = []


# def example_converter(bw: BytecodeWriter, cp):
#     bw.bc(Opcodes.INVOKESTATIC, cp.find_method("java/lang/Long", "valueOf", "(J)Ljava/lang/Long;"))
#     bw.bc(Opcodes.CHECKCAST, cp.find_class("java/lang/Long"))
    
# ComptimeLong.register_converter(ComptimeDouble, example_converter)
    
def long_to_J(bw: BytecodeWriter, cp):
    bw.bc(Opcodes.INVOKEVIRTUAL)
    bw.u2(cp.find_methodref("java/lang/Long", "longValue", "()J", True).offset)

ComptimeLong.register_converter("J", long_to_J)

def long_to_I(bw: BytecodeWriter, cp):
    bw.bc(Opcodes.INVOKEVIRTUAL)
    bw.u2(cp.find_methodref("java/lang/Long", "intValue", "()I", True).offset)

ComptimeLong.register_converter("I", long_to_I)

def long_to_S(bw: BytecodeWriter, cp):
    bw.bc(Opcodes.INVOKEVIRTUAL)
    bw.u2(cp.find_methodref("java/lang/Long", "shortValue", "()S", True).offset)

ComptimeLong.register_converter("S", long_to_S)

def long_to_B(bw: BytecodeWriter, cp):
    bw.bc(Opcodes.INVOKEVIRTUAL)
    bw.u2(cp.find_methodref("java/lang/Long", "byteValue", "()B", True).offset)

ComptimeLong.register_converter("B", long_to_B)

def long_to_D(bw: BytecodeWriter, cp):
    bw.bc(Opcodes.INVOKEVIRTUAL)
    bw.u2(cp.find_methodref("java/lang/Long", "doubleValue", "()D", True).offset)

ComptimeLong.register_converter("D", long_to_D)

def long_to_F(bw: BytecodeWriter, cp):
    bw.bc(Opcodes.INVOKEVIRTUAL)
    bw.u2(cp.find_methodref("java/lang/Long", "floatValue", "()F", True).offset)

ComptimeLong.register_converter("F", long_to_F)

def long_to_double(bw: BytecodeWriter, cp):
    bw.bc(Opcodes.INVOKEVIRTUAL)
    bw.u2(cp.find_methodref("java/lang/Long", "doubleValue", "()D", True).offset)
    bw.bc(Opcodes.INVOKESTATIC)
    bw.u2(cp.find_methodref("java/lang/Double", "valueOf", "(D)Ljava/lang/Double;", True).offset)

ComptimeLong.register_converter(ComptimeDouble, long_to_double)


def double_to_D(bw: BytecodeWriter, cp):
    bw.bc(Opcodes.INVOKEVIRTUAL)
    bw.u2(cp.find_methodref("java/lang/Double", "doubleValue", "()D", True).offset)

ComptimeDouble.register_converter("D", double_to_D)

def double_to_F(bw: BytecodeWriter, cp):
    bw.bc(Opcodes.INVOKEVIRTUAL)
    bw.u2(cp.find_methodref("java/lang/Double", "floatValue", "()F", True).offset)

ComptimeDouble.register_converter("F", double_to_F)

def double_to_long(bw: BytecodeWriter, cp):
    bw.bc(Opcodes.INVOKEVIRTUAL)
    bw.u2(cp.find_methodref("java/lang/Double", "longValue", "()J", True).offset)

ComptimeDouble.register_converter(ComptimeLong, double_to_long)


def boolean_to_Z(bw: BytecodeWriter, cp):
    bw.bc(Opcodes.INVOKEVIRTUAL)
    bw.u2(cp.find_methodref("java/lang/Boolean", "booleanValue", "()Z", True).offset)

ComptimeBoolean.register_converter("Z", boolean_to_Z)


def tuple_to_list(bw: BytecodeWriter, cp):
    bw.bc(Opcodes.DUP)
    bw.bc(Opcodes.ARRAYLENGTH)
    bw.bc(Opcodes.INVOKESTATIC)
    bw.u2(cp.find_methodref("java/util/Arrays", "copyOf", "([Ljava/lang/Object;I)[Ljava/lang/Object;", True).offset)

    bw.bc(Opcodes.INVOKESTATIC)
    bw.u2(cp.find_methodref("java/util/Arrays", "asList", "([Ljava/lang/Object;)Ljava/util/List;", True).offset)

ComptimeTuple.register_converter(ComptimeList, tuple_to_list)


    