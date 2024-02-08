from pyjvm.types.signature import JvmSignature
from pyjvm.c.jni cimport jvalue, jboolean, jbyte, jchar, jshort, jint, jlong, jfloat, jdouble, jobject, JNIEnv, jclass
from pyjvm.types.clazz.special.jvmstring cimport JvmString
from pyjvm.types.clazz.jvmclass cimport JvmClass

from cpython.ref cimport Py_INCREF, Py_DECREF

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

cdef jobject convert_to_object(object pyobj, Jvm jvm, str parent=None) except *:
    cdef jobject result
    cdef JNIEnv* jni = jvm.jni
    cdef jboolean isInstance = 0
    cdef jclass parent_class_id
    if pyobj is None:
        return NULL

    if isinstance(pyobj, str):
        javaLangString = jvm.findClass('java/lang/String')
        pyobj = javaLangString(pyobj)

        result = <jobject><unsigned long long>pyobj._jobject
        return jni[0].NewLocalRef(jni, result)
    
    elif isinstance(pyobj, JvmClass):
        result = <jobject><unsigned long long>pyobj._jobject

        if parent:
            parent_class = jvm.findClass(parent)
            parent_class_id = <jclass><unsigned long long>parent_class._jclass

            isInstance = jni[0].IsInstanceOf(jni, result, parent_class_id)
            if not isInstance:
                raise ValueError


        return jni[0].NewLocalRef(jni, result)

    else:
        if pyobj is None:
            return NULL

        #print('convert_to_object', pyobj)

        jvm.ensureBridgeLoaded()

        #print('convert_to_object',"loaded bridge")

        # Convert to PyObject
        PyObject = jvm.findClass('pyjvm/bridge/java/PyObject')

        #print('convert_to_object', PyObject)


        jobj = PyObject(<long long><void*>pyobj)

        #print('convert_to_object', jobj)

        result = <jobject><unsigned long long>jobj._jobject

        return jni[0].NewLocalRef(jni, result)
    
    



cdef jvalue convert_to_java(str jsignature, object pyobj, Jvm jvm) except *:
    if jsignature == JvmSignature.BOOLEAN:
        return jvalue(z=convert_to_bool(pyobj))
    elif jsignature == JvmSignature.BYTE:
        return jvalue(b=convert_to_byte(pyobj))
    elif jsignature == JvmSignature.CHAR:
        return jvalue(c=convert_to_char(pyobj))
    elif jsignature == JvmSignature.SHORT:
        return jvalue(s=convert_to_short(pyobj))
    elif jsignature == JvmSignature.INT:
        return jvalue(i=convert_to_int(pyobj))
    elif jsignature == JvmSignature.LONG:
        return jvalue(j=convert_to_long(pyobj))
    elif jsignature == JvmSignature.FLOAT:
        return jvalue(f=convert_to_float(pyobj))
    elif jsignature == JvmSignature.DOUBLE:
        return jvalue(d=convert_to_double(pyobj))
    elif jsignature[0] == JvmSignature.CLASS:
        return jvalue(l=convert_to_object(pyobj, jvm, jsignature[1:]))
    else:
        raise ValueError
    


