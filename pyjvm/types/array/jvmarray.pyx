from pyjvm.c.jni cimport jarray, JNIEnv, jsize, jint, jboolean, jchar, jshort, jlong, jfloat, jdouble, jbyte, JNI_ABORT
from pyjvm.jvm cimport Jvm

from libc.stdlib cimport malloc, free 

from pyjvm.exceptions.exception cimport JvmExceptionPropagateIfThrown

from pyjvm.types.signature import JvmSignature

cdef object CreateJvmArray(Jvm jvm, jarray jarray, str signature):
    if signature[1] == JvmSignature.CLASS:
        return JvmObjectArray(<unsigned long long>jarray, signature, jvm)
    elif signature[1] == JvmSignature.ARRAY:
        raise NotImplementedError("Nested arrays not supported yet")
    elif signature[1] == JvmSignature.BYTE:
        return JvmByteArray(<unsigned long long>jarray, signature, jvm)
    else:
        return JvmPrimitiveArray(<unsigned long long>jarray, signature, jvm)

cdef class JvmArray:
    #cdef jarray _jarray
    #cdef str signature 
    #cdef Jvm jvm
    #cdef int current_index


    def __init__(self, unsigned long long arr, str signature, Jvm jvm):
        self._jarray = <jarray>arr
        self.signature = signature
        self.jvm = jvm
        self.current_index = 0


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

    
    def __iter__(self):
        self.current_index = 0
        return self
    
    def __next__(self):
        if self.current_index >= self.length():
            raise StopIteration
        else:
            self.current_index += 1
            return self[self.current_index - 1]

    
    def __getitem__(self, key):
        if isinstance(key, slice):
            start = key.start if key.start is not None else 0
            stop = key.stop if key.stop is not None else self.length()
            length = stop - start
            return list(self.get(start, length))
        
        if isinstance(key, int):
            return self.get(key, 1)[0]
        else:
            raise TypeError("Invalid key type for JvmPrimitiveArray: {}".format(type(key)))

    def to_list(self):
        return list(self.get(0, self.length()))
    

    def __eq__(self, other):
        if isinstance(other, JvmPrimitiveArray):
            return self.to_list() == other.to_list()
        elif isinstance(other, list):
            return self.to_list() == other
        else:
            return False
    
    
    cdef tuple get(self, int start, int length):
        raise NotImplementedError("Abstract method")

    

cdef class JvmObjectArray(JvmArray):
    pass


cdef class JvmPrimitiveArray(JvmArray):


    cdef tuple get(self, int start, int length):

        if self.signature[1] == JvmSignature.BOOLEAN:
            return self.get_bool(self.jvm.jni, self._jarray, start, length)
        elif self.signature[1] == JvmSignature.BYTE:
            return self.get_byte(self.jvm.jni, self._jarray, start, length)
        elif self.signature[1] == JvmSignature.CHAR:
            return self.get_char(self.jvm.jni, self._jarray, start, length)
        elif self.signature[1] == JvmSignature.SHORT:
            return self.get_short(self.jvm.jni, self._jarray, start, length)
        elif self.signature[1] == JvmSignature.INT:
            return self.get_int(self.jvm.jni, self._jarray, start, length)
        elif self.signature[1] == JvmSignature.LONG:
            return self.get_long(self.jvm.jni, self._jarray, start, length)
        elif self.signature[1] == JvmSignature.FLOAT:
            return self.get_float(self.jvm.jni, self._jarray, start, length)
        elif self.signature[1] == JvmSignature.DOUBLE:
            return self.get_double(self.jvm.jni, self._jarray, start, length)
        else:
            raise NotImplementedError("Primitive array type {} not supported".format(self._signature[1]))

            

    cdef tuple get_bool(self, JNIEnv* env, jarray array, jsize start, jsize length):
        cdef jboolean* data = <jboolean*>malloc(length * sizeof(jboolean))
        env[0].GetBooleanArrayRegion(env, array, start, length, data)
        JvmExceptionPropagateIfThrown(self.jvm)

        cdef tuple result = tuple(bool(data[i]) for i in range(length))
        free(data)
        return result

    cdef tuple get_byte(self, JNIEnv* env, jarray array, jsize start, jsize length):
        cdef jbyte* data = <jbyte*>malloc(length * sizeof(jbyte))
        env[0].GetByteArrayRegion(env, array, start, length, data)
        JvmExceptionPropagateIfThrown(self.jvm)

        cdef tuple result = tuple(<int>data[i] for i in range(length))
        free(data)
        return result
        

    cdef tuple get_char(self, JNIEnv* env, jarray array, jsize start, jsize length):
        cdef jchar* data = <jchar*>malloc(length * sizeof(jchar))
        env[0].GetCharArrayRegion(env, array, start, length, data)
        JvmExceptionPropagateIfThrown(self.jvm)

        cdef tuple result = tuple(chr(data[i]) for i in range(length))
        free(data)
        return result

    cdef tuple get_short(self, JNIEnv* env, jarray array, jsize start, jsize length):
        cdef jshort* data = <jshort*>malloc(length * sizeof(jshort))
        env[0].GetShortArrayRegion(env, array, start, length, data)
        JvmExceptionPropagateIfThrown(self.jvm)

        cdef tuple result = tuple(<int>data[i] for i in range(length))
        free(data)
        return result

    cdef tuple get_int(self, JNIEnv* env, jarray array, jsize start, jsize length):
        cdef jint* data = <jint*>malloc(length * sizeof(jint))
        env[0].GetIntArrayRegion(env, array, start, length, data)
        JvmExceptionPropagateIfThrown(self.jvm)
        
        cdef tuple result = tuple(<int>data[i] for i in range(length))
        free(data)
        return result

    cdef tuple get_long(self, JNIEnv* env, jarray array, jsize start, jsize length):
        cdef jlong* data = <jlong*>malloc(length * sizeof(jlong))
        env[0].GetLongArrayRegion(env, array, start, length, data)
        JvmExceptionPropagateIfThrown(self.jvm)

        cdef tuple result = tuple(<long>data[i] for i in range(length))
        free(data)
        return result

    cdef tuple get_float(self, JNIEnv* env, jarray array, jsize start, jsize length):
        cdef jfloat* data = <jfloat*>malloc(length * sizeof(jfloat))
        env[0].GetFloatArrayRegion(env, array, start, length, data)
        JvmExceptionPropagateIfThrown(self.jvm)

        cdef tuple result = tuple(<float>data[i] for i in range(length))
        free(data)
        return result


    cdef tuple get_double(self, JNIEnv* env, jarray array, jsize start, jsize length):
        cdef jdouble* data = <jdouble*>malloc(length * sizeof(jdouble))
        env[0].GetDoubleArrayRegion(env, array, start, length, data)
        JvmExceptionPropagateIfThrown(self.jvm)

        cdef tuple result = tuple(<double>data[i] for i in range(length))
        free(data)
        return result


cdef class JvmByteArray(JvmPrimitiveArray):
    
    def to_bytes(self):
        return bytes(self.get(0, self.length()))
    
    def __str__(self):
        return str(self.to_bytes())
    
    def __eq__(self, other):
        if isinstance(other, JvmByteArray):
            return self.to_bytes() == other.to_bytes()
        elif isinstance(other, bytes):
            return self.to_bytes() == other
        else:
            return False

    def __getitem__(self, index):
        if isinstance(index, slice):
            return bytes(self.get(index.start, index.stop - index.start))
        else:
            return self.get(index, 1)[0]


