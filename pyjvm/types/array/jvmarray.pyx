from pyjvm.c.jni cimport jarray, JNIEnv, jsize, jint
from pyjvm.jvm cimport Jvm

from libc.stdlib cimport malloc, free 

from pyjvm.exceptions.exception cimport JvmExceptionPropagateIfThrown

from pyjvm.types.signature import JvmSignature

cdef object CreateJvmArray(Jvm jvm, jarray jarray, str signature):
    if signature[1] == JvmSignature.CLASS:
        return JvmObjectArray(<unsigned long long>jarray, signature, jvm)
    elif signature[1] == JvmSignature.ARRAY:
        raise NotImplementedError("Nested arrays not supported yet")
    else:
        return JvmPrimitiveArray(<unsigned long long>jarray, signature, jvm)

cdef class JvmArray:
    #cdef jarray _jarray
    #cdef str signature

    def __init__(self, unsigned long long arr, str signature, Jvm jvm):
        self._jarray = <jarray>arr
        self.signature = signature
        self.jvm = jvm

    cdef length(self):
        cdef JNIEnv* jni = self.jvm.jni
        cdef jsize length = jni[0].GetArrayLength(jni, self._jarray)
        JvmExceptionPropagateIfThrown(self.jvm)
        return <int>length

    @property
    def signature(self):
        return self.signature
    
    def __len__(self):
        return self.length()
    

cdef class JvmObjectArray(JvmArray):
    pass

cdef class JvmPrimitiveArray(JvmArray):
    
    def __getitem__(self, key):
        if isinstance(key, slice):
            raise NotImplementedError("Slicing of JvmPrimiteArray not supported yet")
        
        if isinstance(key, int):
            return self.get(key, 1)
        else:
            raise TypeError("Invalid key type for JvmPrimitiveArray: {}".format(type(key)))


    cdef object get(self, int start, int length):

        if self.signature[1] == JvmSignature.INT:
            return self.get_int(self.jvm.jni, self._jarray, start, length)[0]
        else:
            raise NotImplementedError("Primitive array type {} not supported yet".format(self._signature[1]))
       
        return <int>length

            

    cdef tuple get_bool(self, JNIEnv* env, jarray array, jsize start, jsize length):
        pass
        
    cdef tuple get_byte(self, JNIEnv* env, jarray array, jsize start, jsize length):
        pass

    cdef tuple get_char(self, JNIEnv* env, jarray array, jsize start, jsize length):
        pass

    cdef tuple get_short(self, JNIEnv* env, jarray array, jsize start, jsize length):
        pass

    cdef tuple get_int(self, JNIEnv* env, jarray array, jsize start, jsize length):
        cdef jint* data = <jint*>malloc(length * sizeof(jint))
        env[0].GetIntArrayRegion(env, array, start, length, data)
        JvmExceptionPropagateIfThrown(self.jvm)
        
        cdef tuple result = tuple(<int>data[i] for i in range(length))
        free(data)
        return result

    cdef tuple get_long(self, JNIEnv* env, jarray array, jsize start, jsize length):
        pass

    cdef tuple get_float(self, JNIEnv* env, jarray array, jsize start, jsize length):
        pass

    cdef tuple get_double(self, JNIEnv* env, jarray array, jsize start, jsize length):
        pass

    def __setitem__(self, key, value):
        pass

    def __iter__(self):
        pass

    def __contains__(self, item):
        pass