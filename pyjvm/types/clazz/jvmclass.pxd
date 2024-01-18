from pyjvm.c.jni cimport jclass, jobject
from pyjvm.jvm cimport Jvm

# for now this is just a placeholder. in the future we will use this to override jvm class methods with python methods


cdef class JvmClass:
    cdef jobject _jobject
    cdef object _class

cdef object JvmClassFromJclass(unsigned long long cid, Jvm jvm, object top_base = *)
cdef object JvmObjectFromJobject(unsigned long long jobj, Jvm jvm)



#class JvmClass(_JvmClass, metaclass=JvmClassMeta):
