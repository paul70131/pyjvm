from pyjvm.types.clazz.jvmclass cimport JvmClass
from pyjvm.c.jni cimport jfieldID, jobject, JNIEnv
from pyjvm.types.clazz.jvmfield cimport JvmField
from pyjvm.jvm cimport Jvm

# JvmField is always static, for instance fields, use JvmBoundField which uses JvmField in the background
cdef class JvmBoundField:
    cdef JvmField _field
    cdef object _object

    cpdef object get(self)

    cdef object get_boolean(self, JNIEnv* env, jobject object, jfieldID fid, Jvm jvm)
    cdef object get_byte(self, JNIEnv* env, jobject object, jfieldID fid, Jvm jvm)
    cdef object get_char(self, JNIEnv* env, jobject object, jfieldID fid, Jvm jvm)
    cdef object get_short(self, JNIEnv* env, jobject object, jfieldID fid, Jvm jvm)
    cdef object get_int(self, JNIEnv* env, jobject object, jfieldID fid, Jvm jvm)
    cdef object get_long(self, JNIEnv* env, jobject object, jfieldID fid, Jvm jvm)
    cdef object get_float(self, JNIEnv* env, jobject object, jfieldID fid, Jvm jvm)
    cdef object get_double(self, JNIEnv* env, jobject object, jfieldID fid, Jvm jvm)
    cdef object get_object(self, JNIEnv* env, jobject object, jfieldID fid, Jvm jvm)

    cdef void set(self, object value) except *

    cdef void set_boolean(self, JNIEnv* env, jobject object, jfieldID fid, object value, Jvm jvm) except *
    cdef void set_byte(self, JNIEnv* env, jobject object, jfieldID fid, object value, Jvm jvm) except *
    cdef void set_char(self, JNIEnv* env, jobject object, jfieldID fid, object value, Jvm jvm) except *
    cdef void set_short(self, JNIEnv* env, jobject object, jfieldID fid, object value, Jvm jvm) except *
    cdef void set_int(self, JNIEnv* env, jobject object, jfieldID fid, object value, Jvm jvm) except *
    cdef void set_long(self, JNIEnv* env, jobject object, jfieldID fid, object value, Jvm jvm) except * 
    cdef void set_float(self, JNIEnv* env, jobject object, jfieldID fid, object value, Jvm jvm) except *
    cdef void set_double(self, JNIEnv* env, jobject object, jfieldID fid, object value, Jvm jvm) except *
    cdef void set_object(self, JNIEnv* env, jobject object, jfieldID fid, object value, Jvm jvm) except *