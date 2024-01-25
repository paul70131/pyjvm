from pyjvm.jvm cimport Jvm
from pyjvm.bytecode.components.jvmbytecodeconstantpool cimport JvmBytecodeConstantPool
from pyjvm.types.clazz.jvmmethod cimport JvmMethod
from pyjvm.bytecode.components.jvmbytecodeattributes cimport JvmBytecodeAttributes
from pyjvm.c.jni cimport JNIEnv, jobject, jclass

from pyjvm.bytecode.components.base cimport JvmBytecodeComponent




cdef class JvmBytecodeMethod:
    #cdef unsigned short access_flags
    #cdef unsigned short name_index
    #cdef unsigned short descriptor_index
    #cdef JvmBytecodeAttributes attributes

    def __init__(self, unsigned short access_flags, unsigned short name_index, unsigned short descriptor_index) except *:
        self.access_flags = access_flags
        self.name_index = name_index
        self.descriptor_index = descriptor_index
        self.attributes = JvmBytecodeAttributes()

cdef class JvmBytecodeMethods(JvmBytecodeComponent):
    #cdef list[JvmBytecodeMethod] fields

    def __init__(self) except *:
        self.methods = []

    cdef void add(self, JvmMethod method, object klass, Jvm jvm, JvmBytecodeConstantPool cp) except *:
        cdef JvmBytecodeMethod bc_method

        bc_method = JvmBytecodeMethod(method.modifiers, cp.get_index(method.name), cp.get_index(method.descriptor))


        # attributes

        # TODO: Code
        # jvmti->GetBytecodes

        # TODO: Exceptions
        # reflection->getExceptionTypes

        # TODO: Synthetic
        # jvmti->IsMethodSynthetic

        # TODO: Deprecated
        # ?

        # TODO: Signature
        # method.signature

        # TODO: RuntimeVisibleAnnotations
        # reflection->getDeclaredAnnotations

        # TODO: RuntimeVisibleParameterAnnotations
        # reflection->getParameterAnnotations

        # TODO: RuntimeInvisibleAnnotations
        # ?

        # TODO: RuntimeInvisibleParameterAnnotations
        # ?

        # TODO: AnnotationDefault
        # reflection->getDefaultValue
