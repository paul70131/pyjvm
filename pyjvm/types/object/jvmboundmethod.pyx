from pyjvm.types.clazz.jvmclass cimport JvmClass
from pyjvm.jvm cimport Jvm
from pyjvm.types.clazz.jvmclass cimport JvmClassFromJclass, JvmObjectFromJobject

from pyjvm.c.jni cimport jfieldID, jint, jclass, jmethodID, jvalue, jboolean, jbyte, jchar, jshort, jint, jlong, jfloat, jdouble, jobject, JNIEnv, jarray
from pyjvm.c.jvmti cimport jvmtiEnv
from libc.stdlib cimport malloc, free

from pyjvm.types.converter.typeconverter cimport convert_to_java
from pyjvm.types.signature cimport JVM_SIG_VOID, JVM_SIG_BOOLEAN, JVM_SIG_BYTE, JVM_SIG_CHAR, JVM_SIG_DOUBLE, JVM_SIG_FLOAT, JVM_SIG_INT, JVM_SIG_LONG, JVM_SIG_SHORT, JVM_SIG_CLASS, JVM_SIG_ARRAY
from pyjvm.exceptions.exception cimport JvmExceptionPropagateIfThrown
from pyjvm.types.clazz.jvmmethod cimport JvmMethod, JvmMethodReference


from pyjvm.types.array.jvmarray cimport JvmArray, CreateJvmArray


cdef class JvmBoundMethod:
#    cdef JvmMethod method
#    cdef object obj

    @property
    def method_id(self):
        return self.method.method_id

    @property
    def name(self):
        return self.method.name

    @property
    def signature(self):
        return self.method.signature

    @property
    def obj(self):
        return self.obj

    @property
    def abstract(self):
        return self.method.abstract

    @property
    def final(self):
        return self.method.final

    @property
    def private(self):
        return self.method.private
    
    @property
    def protected(self):
        return self.method.protected
    
    @property
    def public(self):
        return self.method.public

    @property
    def static(self):
        return self.method.static

    cdef object call_void(self, JNIEnv* jni, jobject obj, jmethodID method_id, jvalue* args, Jvm jvm):
        jni[0].CallVoidMethodA(jni, obj, method_id, args)
        JvmExceptionPropagateIfThrown(jvm)
        return None

    cdef object call_boolean(self, JNIEnv* jni, jobject obj, jmethodID method_id, jvalue* args, Jvm jvm):
        cdef jboolean ret
        ret = jni[0].CallBooleanMethodA(jni, obj, method_id, args)
        JvmExceptionPropagateIfThrown(jvm)
        return ret != 0

    cdef object call_byte(self, JNIEnv* jni, jobject obj, jmethodID method_id, jvalue* args, Jvm jvm):
        cdef jbyte ret
        ret = jni[0].CallByteMethodA(jni, obj, method_id, args)
        JvmExceptionPropagateIfThrown(jvm)
        return <int>ret
    
    cdef object call_char(self, JNIEnv* jni, jobject obj, jmethodID method_id, jvalue* args, Jvm jvm):
        cdef jchar ret
        ret = jni[0].CallCharMethodA(jni, obj, method_id, args)
        JvmExceptionPropagateIfThrown(jvm)
        return chr(<int>ret)
    
    cdef object call_short(self, JNIEnv* jni, jobject obj, jmethodID method_id, jvalue* args, Jvm jvm):
        cdef jshort ret
        ret = jni[0].CallShortMethodA(jni, obj, method_id, args)
        JvmExceptionPropagateIfThrown(jvm)
        return <int>ret
    
    cdef object call_int(self, JNIEnv* jni, jobject obj, jmethodID method_id, jvalue* args, Jvm jvm):
        cdef jint ret
        ret = jni[0].CallIntMethodA(jni, obj, method_id, args)
        JvmExceptionPropagateIfThrown(jvm)
        return <int>ret

    cdef object call_long(self, JNIEnv* jni, jobject obj, jmethodID method_id, jvalue* args, Jvm jvm):
        cdef jlong ret
        ret = jni[0].CallLongMethodA(jni, obj, method_id, args)
        JvmExceptionPropagateIfThrown(jvm)
        return <int>ret

    cdef object call_float(self, JNIEnv* jni, jobject obj, jmethodID method_id, jvalue* args, Jvm jvm):
        cdef jfloat ret
        ret = jni[0].CallFloatMethodA(jni, obj, method_id, args)
        JvmExceptionPropagateIfThrown(jvm)
        return <float>ret
    
    cdef object call_double(self, JNIEnv* jni, jobject obj, jmethodID method_id, jvalue* args, Jvm jvm):
        cdef jdouble ret
        ret = jni[0].CallDoubleMethodA(jni, obj, method_id, args)
        JvmExceptionPropagateIfThrown(jvm)

        return <float>ret
    
    cdef object call_object(self, JNIEnv* jni, jobject obj, jmethodID method_id, jvalue* args, Jvm jvm):
        cdef jobject ret
        ret = jni[0].CallObjectMethodA(jni, obj, method_id, args)
        JvmExceptionPropagateIfThrown(jvm)
        
        return JvmObjectFromJobject(<unsigned long long> ret, jvm)

    cdef object call_array(self, JNIEnv* jni, jobject obj, jmethodID method_id, jvalue* args, Jvm jvm, char* signature):
        cdef jarray value
        value = jni[0].CallObjectMethodA(jni, obj, method_id, args)
        JvmExceptionPropagateIfThrown(jvm)
        return CreateJvmArray(jvm, value, signature)

    cdef object call(self, jmethodID mid,  jvalue* args, char* return_type):
        cdef Jvm jvm = self.obj.__class__.jvm
        cdef JNIEnv* env = jvm.getEnv()
        cdef jobject cid = <jobject><unsigned long long>self.obj._jobject
        cdef object value

        if return_type[0] == JVM_SIG_VOID:
            return self.call_void(env, cid, mid, args, jvm)
        if return_type[0] == JVM_SIG_BOOLEAN:
            return self.call_boolean(env, cid, mid, args, jvm)
        elif return_type[0] == JVM_SIG_BYTE:
            return self.call_byte(env, cid, mid, args, jvm)
        elif return_type[0] == JVM_SIG_CHAR:
            return self.call_char(env, cid, mid, args, jvm)
        elif return_type[0] == JVM_SIG_DOUBLE:
            return self.call_double(env, cid, mid, args, jvm)
        elif return_type[0] == JVM_SIG_FLOAT:
            return self.call_float(env, cid, mid, args, jvm)
        elif return_type[0] == JVM_SIG_INT:
            return self.call_int(env, cid, mid, args, jvm)
        elif return_type[0] == JVM_SIG_LONG:
            return self.call_long(env, cid, mid, args, jvm)
        elif return_type[0] == JVM_SIG_SHORT:
            return self.call_short(env, cid, mid, args, jvm)
        elif return_type[0] == JVM_SIG_CLASS:
            return self.call_object(env, cid, mid, args, jvm)
        elif return_type[0] == JVM_SIG_ARRAY:
            return self.call_array(env, cid, mid, args, jvm, return_type)
        
        raise TypeError("Unknown return type " + return_type)


    def __call__(self, *args):
        cdef jvalue* jargs = NULL
        cdef jmethodID mid
        cdef Jvm jvm = self.obj.__class__.jvm
        cdef JvmMethodReference overload

        for overload in self.method._overloads:

            jargs = overload.signature.convert(args, jvm)
            if jargs == NULL:
                continue

            overload.signature.parse() # ensure parsed

            mid = overload._method_id
            ret = self.call(mid, jargs, overload.signature.return_type)

            free(jargs)
        
            return ret

        raise TypeError("No overload found for method " + self.method.name + " with signature " + str(self.method.signature) + " and arguments " + str(args))
        

    def __repr__(self):
        return self.method.__repr__()
    
    def __init__(self, JvmMethod method, object obj):
        self.method = method
        self.obj = obj


