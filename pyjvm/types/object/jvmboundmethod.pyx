from pyjvm.types.clazz.jvmclass cimport JvmClass
from pyjvm.jvm cimport Jvm
from pyjvm.types.clazz.jvmclass cimport JvmClassFromJclass, JvmObjectFromJobject

from pyjvm.c.jni cimport jfieldID, jint, jclass, jmethodID, jvalue, jboolean, jbyte, jchar, jshort, jint, jlong, jfloat, jdouble, jobject, JNIEnv
from pyjvm.c.jvmti cimport jvmtiEnv
from libc.stdlib cimport malloc, free

from pyjvm.types.converter.typeconverter cimport convert_to_java
from pyjvm.types.signature import JvmSignature
from pyjvm.exceptions.exception cimport JvmExceptionPropagateIfThrown
from pyjvm.types.clazz.jvmmethod cimport JvmMethod, JvmMethodReference


cdef class JvmBoundMethod:
#    cdef JvmMethod method
#    cdef object obj

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
        return <bint>ret

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

    cdef object call(self, jmethodID mid,  jvalue* args, str return_type):
        cdef Jvm jvm = self.obj.__class__.jvm
        cdef JNIEnv* env = jvm.jni
        cdef jobject cid = <jobject><unsigned long long>self.obj._jobject
        cdef object value

        print("Calling", self.name, return_type, self.obj)

        if return_type == JvmSignature.VOID:
            return self.call_void(env, cid, mid, args, jvm)
        if return_type == JvmSignature.BOOLEAN:
            return self.call_boolean(env, cid, mid, args, jvm)
        elif return_type == JvmSignature.BYTE:
            return self.call_byte(env, cid, mid, args, jvm)
        elif return_type == JvmSignature.CHAR:
            return self.call_char(env, cid, mid, args, jvm)
        elif return_type == JvmSignature.DOUBLE:
            return self.call_double(env, cid, mid, args, jvm)
        elif return_type == JvmSignature.FLOAT:
            return self.call_float(env, cid, mid, args, jvm)
        elif return_type == JvmSignature.INT:
            return self.call_int(env, cid, mid, args, jvm)
        elif return_type == JvmSignature.LONG:
            return self.call_long(env, cid, mid, args, jvm)
        elif return_type == JvmSignature.SHORT:
            return self.call_short(env, cid, mid, args, jvm)
        else:
            return self.call_object(env, cid, mid, args, jvm)


    def __call__(self, *args):
        cdef jvalue* jargs = NULL
        cdef jmethodID mid
        cdef Jvm jvm = self.obj.__class__.jvm
        cdef JvmMethodReference overload

        for overload in self.method._overloads:

            jargs = overload.signature.convert(args)
            if jargs == NULL:
                continue

            _, ret_type = overload.signature.parse()

            mid = overload._method_id
            ret = self.call(mid, jargs, ret_type)

            free(jargs)
        
            return ret

        

    def __repr__(self):
        name = ""
        if self.public:
            name += "public "
        elif self.protected:
            name += "protected "
        elif self.private:
            name += "private "
        if self.static:
            name += "static "
        if self.final:
            name += "final "
        if self.abstract:
            name += "abstract "
        name += self.signature + " " + self._name
        return name
    
    def __init__(self, JvmMethod method, object obj):
        self.method = method
        self.obj = obj


