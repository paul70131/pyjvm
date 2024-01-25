from pyjvm.c.jni cimport JNIEnv, jobject, jclass
from pyjvm.types.clazz.jvmclass cimport JvmObjectFromJobject
from pyjvm.bytecode.components.jvmbytecodeattributes cimport JvmBytecodeAttributes, ConstantValueAttribute

import time


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

    cdef void add(self, JvmField field, object klass, Jvm jvm, JvmBytecodeConstantPool cp) except *:
        cdef jobject field_ref
        cdef jclass cid = <jclass><unsigned long long>klass._jclass
        cdef JvmBytecodeField bc_field

        name_index = cp.find_string(field._name).offset
        descriptor_index = cp.find_string(field._signature).offset


        bc_field = JvmBytecodeField(field._modifiers, name_index, descriptor_index)
        self.fields.append(bc_field)

        
        field_ref = jvm.jni[0].ToReflectedField(jvm.jni, cid, field._fid, <bint>field.static)
        obj = JvmObjectFromJobject(<unsigned long long>field_ref, jvm)

        # now handle the attributes, since we do not have direct access to them, we need to figure 
        
        if field.static and getattr(klass, field.name) and field.signature in ConstantValueAttribute.signatures:
            cv = ConstantValueAttribute(field, getattr(klass, field.name), cp)
            bc_field.attributes.add(cv)
            
        # TODO: this may not be the inital value?

        # TODO: Synthetic ?

        # TODO: Deprecated ? (doesnt seem important)

        # TODO: RuntimeVisibleAnnotations ?

        annotations = obj.getDeclaredAnnotations()
        for annotation in annotations:
            pass


