from pyjvm.types.clazz.jvmclass cimport JvmClass
from pyjvm.jvm cimport Jvm
from pyjvm.types.clazz.jvmclass cimport JvmClassFromJclass, JvmObjectFromJobject

from pyjvm.c.jni cimport jfieldID, jint, jclass, jmethodID, jvalue, jboolean, jbyte, jchar, jshort, jint, jlong, jfloat, jdouble, jobject, JNIEnv, jarray
from pyjvm.c.jvmti cimport jvmtiEnv
from libc.stdlib cimport malloc, free

from pyjvm.types.converter.typeconverter cimport convert_to_java
from pyjvm.types.signature import JvmSignature
from pyjvm.exceptions.exception cimport JvmExceptionPropagateIfThrown

from pyjvm.types.array.jvmarray cimport JvmArray, CreateJvmArray


cdef class JvmMethodSignature:
 #   cdef str _signature

    @property
    def signature(self):
        return self._signature

    def __init__(self, str signature):
        self._signature = signature

    def __str__(self):
        return self._signature

    @property
    def args(self):
        return self.parse()[0]

    @property
    def ret(self):
        return self.parse()[1]

    cdef tuple parse(self):
        cdef list args = []
        cdef str ret = ""
        cdef bint in_args = True
        cdef str arg = ""

        for c in self._signature:
            if c == '(':
                continue
            elif c == ')':
                in_args = False
                continue

            if in_args:
                if arg != "":
                    if c == ';':
                        args.append(arg)
                        arg = ""
                    else:
                        arg += c
                else:
                    if c == 'L':
                        arg += c
                    else:
                        args += c
            else:
                ret += c
        
        return (args, ret)

    cdef jvalue* convert(self, tuple args, Jvm jvm):
        cdef str f_ret
        cdef list f_args
        cdef jvalue* jargs

        f_args, f_ret = self.parse()

        if len(f_args) != len(args):
            return NULL
        
        jargs = <jvalue*>malloc(sizeof(jvalue) * len(args))
                
        if len(args) == 0:
            return jargs

        for i in range(len(args)):
            try:
                jargs[i] = convert_to_java(f_args[i], args[i], jvm)
            except ValueError as e:
                free(jargs)
                return NULL
        
        return jargs


cdef class JvmMethodReference:
#    cdef jmethodID _method_id
#    cdef JvmMethodSignature signature

    @property
    def method_id(self):
        return <unsigned long long>self._method_id

    @property
    def signature(self):
        return self.signature

cdef class JvmMethod:
#    cdef str _name
#    cdef str _signature
#    cdef int _modifiers

    def hasDescriptor(self, str descriptor):
        for overload in self._overloads:
            if overload.signature.signature == descriptor:
                return True
        return False


    @property
    def method_id(self):
        if len(self._overloads) != 1:
            raise Exception("Cannot get jmethodID for overloaded method")
        
        return self._overloads[0].method_id

    @property
    def name(self):
        return self._name

    @property
    def signature(self):
        return str([str(c.signature) for c in self._overloads])

    @property
    def clazz(self):
        return self._clazz

    @property
    def abstract(self):
        return self._modifiers & 0x0400 != 0

    @property
    def final(self):
        return self._modifiers & 0x0010 != 0

    @property
    def private(self):
        return self._modifiers & 0x0002 != 0
    
    @property
    def protected(self):
        return self._modifiers & 0x0004 != 0
    
    @property
    def public(self):
        return self._modifiers & 0x0001 != 0

    @property
    def static(self):
        return self._modifiers & 0x0008 != 0

    cdef object call_void(self, JNIEnv* jni, jclass clazz, jmethodID method_id, jvalue* args, Jvm jvm):
        jni[0].CallStaticVoidMethodA(jni, clazz, method_id, args)
        JvmExceptionPropagateIfThrown(jvm)
        return None

    cdef object call_boolean(self, JNIEnv* jni, jclass clazz, jmethodID method_id, jvalue* args, Jvm jvm):
        cdef jboolean ret
        ret = jni[0].CallStaticBooleanMethodA(jni, clazz, method_id, args)
        JvmExceptionPropagateIfThrown(jvm)
        return ret != 0
    
    cdef object call_byte(self, JNIEnv* jni, jclass clazz, jmethodID method_id, jvalue* args, Jvm jvm):
        cdef jbyte ret
        ret = jni[0].CallStaticByteMethodA(jni, clazz, method_id, args)
        JvmExceptionPropagateIfThrown(jvm)
        return <int>ret
    
    cdef object call_char(self, JNIEnv* jni, jclass clazz, jmethodID method_id, jvalue* args, Jvm jvm):
        cdef jchar ret
        ret = jni[0].CallStaticCharMethodA(jni, clazz, method_id, args)
        JvmExceptionPropagateIfThrown(jvm)
        return chr(<int>ret)
    
    cdef object call_short(self, JNIEnv* jni, jclass clazz, jmethodID method_id, jvalue* args, Jvm jvm):
        cdef jshort ret
        ret = jni[0].CallStaticShortMethodA(jni, clazz, method_id, args)
        JvmExceptionPropagateIfThrown(jvm)
        return <int>ret
    
    cdef object call_int(self, JNIEnv* jni, jclass clazz, jmethodID method_id, jvalue* args, Jvm jvm):
        cdef jint ret
        ret = jni[0].CallStaticIntMethodA(jni, clazz, method_id, args)
        JvmExceptionPropagateIfThrown(jvm)
        return <int>ret

    cdef object call_long(self, JNIEnv* jni, jclass clazz, jmethodID method_id, jvalue* args, Jvm jvm):
        cdef jlong ret
        ret = jni[0].CallStaticLongMethodA(jni, clazz, method_id, args)
        JvmExceptionPropagateIfThrown(jvm)
        return <int>ret

    cdef object call_float(self, JNIEnv* jni, jclass clazz, jmethodID method_id, jvalue* args, Jvm jvm):
        cdef jfloat ret
        ret = jni[0].CallStaticFloatMethodA(jni, clazz, method_id, args)
        JvmExceptionPropagateIfThrown(jvm)
        return <float>ret
    
    cdef object call_double(self, JNIEnv* jni, jclass clazz, jmethodID method_id, jvalue* args, Jvm jvm):
        cdef jdouble ret
        ret = jni[0].CallStaticDoubleMethodA(jni, clazz, method_id, args)
        JvmExceptionPropagateIfThrown(jvm)
        return <float>ret
    
    cdef object call_object(self, JNIEnv* jni, jclass clazz, jmethodID method_id, jvalue* args, Jvm jvm):
        cdef jobject ret
        ret = jni[0].CallStaticObjectMethodA(jni, clazz, method_id, args)
        JvmExceptionPropagateIfThrown(jvm)
        
        return JvmObjectFromJobject(<unsigned long long> ret, jvm)

    cdef object call_array(self, JNIEnv* jni, jclass clazz, jmethodID method_id, jvalue* args, Jvm jvm, str signature):
        cdef jarray value
        value = jni[0].CallStaticObjectMethodA(jni, clazz, method_id, args)
        JvmExceptionPropagateIfThrown(jvm)
        return CreateJvmArray(jvm, value, signature)

    cdef object call(self, jmethodID mid,  jvalue* args, str return_type):
        cdef Jvm jvm = self.clazz.jvm
        cdef JNIEnv* env = jvm.jni
        cdef jclass cid = <jclass><unsigned long long>self._clazz._jclass
        cdef object value

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
        elif return_type[0] == JvmSignature.CLASS:
            return self.call_object(env, cid, mid, args, jvm)
        elif return_type[0] == JvmSignature.ARRAY:
            return self.call_array(env, cid, mid, args, jvm, return_type)
        
        raise Exception("Invalid return type " + return_type)


    def __call__(self, *args):
        cdef jvalue* jargs = NULL
        cdef jmethodID mid
        cdef Jvm jvm = self._clazz.jvm
        cdef JvmMethodReference overload

        for overload in self._overloads:

            jargs = overload.signature.convert(args, jvm)
            if jargs == NULL:
                continue

            _, ret_type = overload.signature.parse()

            mid = overload._method_id
            ret = self.call(mid, jargs, ret_type)

            free(jargs)
        
            return ret

        raise TypeError("No overload found for method " + self.name + " with signature " + str(self.signature) + " and arguments " + str(args))
        


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
    
    def __init__(self, str name, int modifiers, object clazz):
        self._name = name
        self._overloads = []
        self._modifiers = modifiers
        self._clazz = clazz

    def add_overload(self, unsigned long long mid):
        cdef Jvm jvm = self._clazz.jvm
        cdef jvmtiEnv* jvmti = jvm.jvmti

        cdef jmethodID methodid = <jmethodID>mid

        cdef char* name
        cdef char* signature

        error = jvmti[0].GetMethodName(jvmti, methodid, &name, &signature, NULL)
        if error != 0:
            raise Exception("Failed to get field name")
        
        py_signature = signature.decode("utf-8")

        error = jvmti[0].Deallocate(jvmti, <unsigned char*>name)
        if error != 0:
            raise Exception("Failed to deallocate field name")
        
        error = jvmti[0].Deallocate(jvmti, <unsigned char*>signature)
        if error != 0:
            raise Exception("Failed to deallocate field signature")
        

        overload = JvmMethodReference()
        overload._method_id = methodid
        overload.signature = JvmMethodSignature(py_signature)

        self._overloads.append(overload)



cdef JvmMethodFromJmethodID(jmethodID mid, jclass cid, object clazz):
    cdef Jvm jvm = clazz.jvm
    cdef jvmtiEnv* jvmti = jvm.jvmti

    cdef char* name
    cdef char* signature

    cdef jint modifiers
    cdef jint error

    error = jvmti[0].GetMethodName(jvmti, mid, &name, &signature, NULL)
    if error != 0:
        raise Exception("Failed to get field name")

    error = jvmti[0].GetMethodModifiers(jvmti, mid, &modifiers)
    if error != 0:
        raise Exception("Failed to get field modifiers")

    
    py_name = name.decode("utf-8")
    py_signature = signature.decode("utf-8")
    
    error = jvmti[0].Deallocate(jvmti, <unsigned char*>name)
    if error != 0:
        raise Exception("Failed to deallocate field name")
    
    error = jvmti[0].Deallocate(jvmti, <unsigned char*>signature)
    if error != 0:
        raise Exception("Failed to deallocate field signature")

    method = JvmMethod(py_name, modifiers, clazz)
    overload = JvmMethodReference()
    overload._method_id = mid
    overload.signature = JvmMethodSignature(py_signature)

    method._overloads.append(overload)
    return method



