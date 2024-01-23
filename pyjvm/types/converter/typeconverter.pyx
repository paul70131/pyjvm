from pyjvm.types.signature import JvmSignature
from pyjvm.c.jni cimport jvalue, jboolean, jbyte, jchar, jshort, jint, jlong, jfloat, jdouble, jobject
from pyjvm.types.clazz.special.jvmstring cimport JvmString
from pyjvm.types.clazz.jvmclass cimport JvmClass

cdef jboolean convert_to_bool(object pyobj) except *:
    return <jboolean><int>bool(pyobj)

cdef jbyte convert_to_byte(object pyobj) except *:
    return <jbyte><int>pyobj

cdef jchar convert_to_char(object pyobj) except *:
    if isinstance(pyobj, str) and len(pyobj) == 1:
        return <jchar>ord(pyobj[0])
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

cdef jobject convert_to_object(object pyobj, Jvm jvm) except *:
    if pyobj is None:
        return NULL

    if isinstance(pyobj, str):
        javaLangString = jvm.findClass('java/lang/String')
        return <jobject><unsigned long long>javaLangString(pyobj)._jobject
    
    if isinstance(pyobj, JvmClass):
        return <jobject><unsigned long long>pyobj._jobject
    
    else:
        raise NotImplementedError



cdef jvalue convert_to_java(str jsignature, object pyobj) except *:
    raise NotImplementedError
    


