from pyjvm.types.clazz.jvmclass cimport JvmClass
from pyjvm.c.jni cimport jmethodID, jclass, jvalue, JNIEnv, jobject
from pyjvm.jvm cimport Jvm

from pyjvm.types.clazz.jvmmethod cimport JvmMethod

cdef class JvmBoundMethod:
    cdef JvmMethod method
    cdef object obj

    cdef object call(self, jmethodID mid, jvalue* args, str return_type)

    cdef object call_void(self, JNIEnv* jni, jobject obj, jmethodID method_id, jvalue* args, Jvm jvm)
    cdef object call_boolean(self, JNIEnv* jni, jobject obj, jmethodID method_id, jvalue* args, Jvm jvm)
    cdef object call_byte(self, JNIEnv* jni, jobject obj, jmethodID method_id, jvalue* args, Jvm jvm)
    cdef object call_char(self, JNIEnv* jni, jobject obj, jmethodID method_id, jvalue* args, Jvm jvm)
    cdef object call_short(self, JNIEnv* jni, jobject obj, jmethodID method_id, jvalue* args, Jvm jvm)
    cdef object call_int(self, JNIEnv* jni, jobject obj, jmethodID method_id, jvalue* args, Jvm jvm)
    cdef object call_long(self, JNIEnv* jni, jobject obj, jmethodID method_id, jvalue* args, Jvm jvm)
    cdef object call_float(self, JNIEnv* jni, jobject obj, jmethodID method_id, jvalue* args, Jvm jvm)
    cdef object call_double(self, JNIEnv* jni, jobject obj, jmethodID method_id, jvalue* args, Jvm jvm)
    cdef object call_object(self, JNIEnv* jni, jobject obj, jmethodID method_id, jvalue* args, Jvm jvm)
    cdef object call_array(self, JNIEnv* jni, jobject obj, jmethodID method_id, jvalue* args, Jvm jvm, str signature)
