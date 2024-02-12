from pyjvm.types.clazz.jvmclass cimport JvmClass
from pyjvm.c.jni cimport jmethodID, jclass, jvalue, JNIEnv
from pyjvm.jvm cimport Jvm

cdef class JvmMethodSignature:
    cdef const char* _signature
    cdef unsigned int _signature_length

    cdef char* _args
    cdef char* return_type

    cdef int nargs
    cdef bint independent # independet singnatures will be free'd in __dealloc__, for others, the method handles free

    cdef void parse(self) except *
    cdef jvalue* convert(self, tuple args, Jvm jvm)
    cdef inline int next_arg(self, int offset)

cdef class JvmMethodReference:
    cdef jmethodID _method_id
    cdef JvmMethodSignature signature

cdef class JvmMethod:
    cdef char* _name
    cdef list[JvmMethodReference] _overloads
    cdef int _modifiers
    cdef object _clazz

    cdef object call(self, jmethodID mid, jvalue* args, char* return_type)

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
    cdef object call_array(self, JNIEnv* jni, jclass clazz, jmethodID method_id, jvalue* args, Jvm jvm, char* signature)
    

cdef JvmMethodFromJmethodID(jmethodID fid, jclass cid, object clazz)