from pyjvm.types.clazz.jvmclass cimport JvmClass
from pyjvm.c.jni cimport jfieldID, jclass, JNIEnv, jvalue
from pyjvm.jvm cimport Jvm

# JvmField is always static, for instance fields, use JvmBoundField which uses JvmField in the background
cdef class JvmField:
    cdef jfieldID _fid
    cdef str _name
    cdef str _signature
    cdef int _modifiers
    cdef object _clazz

    cpdef object get(self, object clazz)

    cdef object get_boolean(self, JNIEnv* env, jclass clazz, jfieldID fid, Jvm jvm)
    cdef object get_byte(self, JNIEnv* env, jclass clazz, jfieldID fid, Jvm jvm)
    cdef object get_char(self, JNIEnv* env, jclass clazz, jfieldID fid, Jvm jvm)
    cdef object get_short(self, JNIEnv* env, jclass clazz, jfieldID fid, Jvm jvm)
    cdef object get_int(self, JNIEnv* env, jclass clazz, jfieldID fid, Jvm jvm)
    cdef object get_long(self, JNIEnv* env, jclass clazz, jfieldID fid, Jvm jvm)
    cdef object get_float(self, JNIEnv* env, jclass clazz, jfieldID fid, Jvm jvm)
    cdef object get_double(self, JNIEnv* env, jclass clazz, jfieldID fid, Jvm jvm)
    cdef object get_object(self, JNIEnv* env, jclass clazz, jfieldID fid, Jvm jvm)
    cdef object get_array(self, JNIEnv* env, jclass clazz, jfieldID fid, str signature, Jvm jvm)

    cpdef void set(self, object clazz, object value) except *

    cdef void set_boolean(self, JNIEnv* env, jclass clazz, jfieldID fid, object value, Jvm jvm) except *
    cdef void set_byte(self, JNIEnv* env, jclass clazz, jfieldID fid, object value, Jvm jvm) except *
    cdef void set_char(self, JNIEnv* env, jclass clazz, jfieldID fid, object value, Jvm jvm) except *
    cdef void set_short(self, JNIEnv* env, jclass clazz, jfieldID fid, object value, Jvm jvm) except *
    cdef void set_int(self, JNIEnv* env, jclass clazz, jfieldID fid, object value, Jvm jvm) except *
    cdef void set_long(self, JNIEnv* env, jclass clazz, jfieldID fid, object value, Jvm jvm) except *
    cdef void set_float(self, JNIEnv* env, jclass clazz, jfieldID fid, object value, Jvm jvm) except *
    cdef void set_double(self, JNIEnv* env, jclass clazz, jfieldID fid, object value, Jvm jvm) except *
    cdef void set_object(self, JNIEnv* env, jclass clazz, jfieldID fid, object value, Jvm jvm) except *
    cdef void set_array(self, JNIEnv* env, jclass clazz, jfieldID fid, object value, Jvm jvm) except *



cdef JvmFieldFromJfieldID(jfieldID fid, jclass cid, object clazz)