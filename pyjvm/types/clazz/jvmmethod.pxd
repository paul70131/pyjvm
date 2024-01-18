from pyjvm.types.clazz.jvmclass cimport JvmClass
from pyjvm.c.jni cimport jmethodID, jclass, jvalue, JNIEnv
from pyjvm.jvm cimport Jvm

cdef class JvmMethodSignature:
    cdef str _signature

    cdef tuple parse(self)
    cdef jvalue* convert(self, tuple args)

cdef class JvmMethodReference:
    cdef jmethodID _method_id
    cdef JvmMethodSignature signature

cdef class JvmMethod:
    cdef str _name
    cdef list[JvmMethodReference] _overloads
    cdef int _modifiers
    cdef object _clazz

    cdef object call(self, jmethodID mid, jvalue* args, str return_type)

    cdef object call_void(self, JNIEnv* jni, jclass clazz, jmethodID method_id, jvalue* args, Jvm jvm)
    cdef object call_boolean(self, JNIEnv* jni, jclass clazz, jmethodID method_id, jvalue* args, Jvm jvm)
    cdef object call_byte(self, JNIEnv* jni, jclass clazz, jmethodID method_id, jvalue* args, Jvm jvm)
    cdef object call_char(self, JNIEnv* jni, jclass clazz, jmethodID method_id, jvalue* args, Jvm jvm)
    cdef object call_short(self, JNIEnv* jni, jclass clazz, jmethodID method_id, jvalue* args, Jvm jvm)
    cdef object call_int(self, JNIEnv* jni, jclass clazz, jmethodID method_id, jvalue* args, Jvm jvm)
    cdef object call_long(self, JNIEnv* jni, jclass clazz, jmethodID method_id, jvalue* args, Jvm jvm)
    cdef object call_float(self, JNIEnv* jni, jclass clazz, jmethodID method_id, jvalue* args, Jvm jvm)
    cdef object call_double(self, JNIEnv* jni, jclass clazz, jmethodID method_id, jvalue* args, Jvm jvm)
    cdef object call_object(self, JNIEnv* jni, jclass clazz, jmethodID method_id, jvalue* args, Jvm jvm)

cdef JvmMethodFromJmethodID(jmethodID fid, jclass cid, object clazz)