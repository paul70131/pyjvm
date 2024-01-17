from pyjvm.types.signature import JvmSignature
from pyjvm.c.jni cimport jvalue, jboolean, jbyte, jchar, jshort, jint, jlong, jfloat, jdouble, jobject


cdef jboolean convert_to_bool(object pyobj) except *:
    return <jboolean><int>bool(pyobj)

cdef jbyte convert_to_byte(object pyobj) except *:
    return <jbyte><int>pyobj

cdef jchar convert_to_char(object pyobj) except *:
    if isinstance(pyobj, str) and len(pyobj) == 1:
        return <jchar>pyobj[0]
    else:
        return <jchar><int>pyobj
    
cdef jshort convert_to_short(object pyobj) except *:
    return <jshort><int>pyobj

cdef jint convert_to_int(object pyobj) except *:
    return <jint><int>pyobj

cdef jlong convert_to_long(object pyobj) except *:
    return <jlong><long long>pyobj

cdef jfloat convert_to_float(object pyobj) except *:
    return <jfloat><float>pyobj

cdef jdouble convert_to_double(object pyobj) except *:
    return <jdouble><double>pyobj

cdef jobject convert_to_object(object pyobj) except *:
    raise NotImplementedError



cdef jvalue convert_to_java(str jsignature, object pyobj) except *:
    raise NotImplementedError
    


