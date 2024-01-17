from pyjvm.c.jni cimport jvalue, jboolean, jbyte, jchar, jshort, jint, jlong, jfloat, jdouble, jobject

cdef jvalue convert_to_java(str jsignature, object pyobj) except *

cdef jboolean convert_to_bool(object pyobj) except *

cdef jbyte convert_to_byte(object pyobj) except *

cdef jchar convert_to_char(object pyobj) except *
    
cdef jshort convert_to_short(object pyobj) except *

cdef jint convert_to_int(object pyobj) except *

cdef jlong convert_to_long(object pyobj) except *

cdef jfloat convert_to_float(object pyobj) except *

cdef jdouble convert_to_double(object pyobj) except *

cdef jobject convert_to_object(object pyobj) except *