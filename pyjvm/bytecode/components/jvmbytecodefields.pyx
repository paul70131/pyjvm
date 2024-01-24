from pyjvm.c.jni cimport JNIEnv
from pyjvm.types.clazz.jvmclass cimport JvmObjectFromJobject


cdef class JvmBytecodeField:

    def __init__(self, unsigned short access_flags, unsigned short name_index, unsigned short descriptor_index):
        self.access_flags = access_flags
        self.name_index = name_index
        self.descriptor_index = descriptor_index
        self.attributes = JvmBytecodeAttributes()

cdef class JvmBytecodeFields(JvmBytecodeComponent):
#    cdef list[JvmBytecodeField] fields

    def __init__(self):
        self.fields = []

    cdef void add(self, JvmField field, jclass cid, Jvm jvm, JvmBytecodeConstantPool cp) except *:
        cdef jobject field_ref

        name_index = cp.find_string(field._name).offset
        descriptor_index = cp.find_string(field._signature).offset

        self.fields.append(JvmBytecodeField(field._modifiers, name_index, descriptor_index))

        
        field_ref = jvm.jni[0].ToReflectedField(jvm.jni, cid, field._fid, <bint>field.static)
        obj = JvmObjectFromJobject(<unsigned long long>field_ref, jvm)

        # now handle the attributes, since we do not have direct access to them, we need to figure

        # TODO: ConstantValue ?

        # TODO: Synthetic ?

        # TODO: Deprecated ? (doesnt seem important)

        # TODO: RuntimeVisibleAnnotations ?

        annotations = obj.getDeclaredAnnotations()
        print(annotations)

