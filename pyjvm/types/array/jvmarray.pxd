from pyjvm.c.jni cimport jarray, jsize, JNIEnv
from pyjvm.jvm cimport Jvm


from pyjvm.exceptions.exception cimport JvmExceptionPropagateIfThrown

cdef class JvmArray:
    cdef jarray _jarray
    cdef const char* _signature
    cdef Jvm jvm
    cdef int current_index

    cdef length(self)

    cdef tuple get(self, int start, int length)
    cdef void set(self, int offset, object value) except *

cdef class JvmObjectArray(JvmArray):
    
    cdef tuple get(self, int start, int length)
    cdef void set(self, int offset, object value) except *

cdef class JvmPrimitiveArray(JvmArray):
    pass

    cdef tuple get(self, int start, int length)

    cdef tuple get_bool(self, JNIEnv* env, jarray array, jsize start, jsize length)
    cdef tuple get_byte(self, JNIEnv* env, jarray array, jsize start, jsize length)
    cdef tuple get_char(self, JNIEnv* env, jarray array, jsize start, jsize length)
    cdef tuple get_short(self, JNIEnv* env, jarray array, jsize start, jsize length)
    cdef tuple get_int(self, JNIEnv* env, jarray array, jsize start, jsize length)
    cdef tuple get_long(self, JNIEnv* env, jarray array, jsize start, jsize length)
    cdef tuple get_float(self, JNIEnv* env, jarray array, jsize start, jsize length)
    cdef tuple get_double(self, JNIEnv* env, jarray array, jsize start, jsize length)


    
    cdef void set(self, int offset, object value) except *

    cdef void set_bool(self, JNIEnv* env, jarray array, int index, object value, Jvm jvm) except *
    cdef void set_byte(self, JNIEnv* env, jarray array, int index,object value, Jvm jvm) except *
    cdef void set_char(self, JNIEnv* env, jarray array, int index,object value, Jvm jvm) except *
    cdef void set_short(self, JNIEnv* env, jarray array, int index,object value, Jvm jvm) except *
    cdef void set_int(self, JNIEnv* env, jarray array, int index,object value, Jvm jvm) except *
    cdef void set_long(self, JNIEnv* env, jarray array, int index,object value, Jvm jvm) except *
    cdef void set_float(self, JNIEnv* env, jarray array, int index,object value, Jvm jvm) except *
    cdef void set_double(self, JNIEnv* env, jarray array, int index,object value, Jvm jvm) except *



cdef class JvmByteArray(JvmPrimitiveArray):
    pass

cdef object CreateJvmArray(Jvm jvm, jarray jarray, const char* signature)

