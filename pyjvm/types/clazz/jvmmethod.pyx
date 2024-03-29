from pyjvm.types.clazz.jvmclass cimport JvmClass
from pyjvm.jvm cimport Jvm
from pyjvm.types.clazz.jvmclass cimport JvmClassFromJclass, JvmObjectFromJobject

from pyjvm.c.jni cimport jfieldID, jint, jclass, jmethodID, jvalue, jboolean, jbyte, jchar, jshort, jint, jlong, jfloat, jdouble, jobject, JNIEnv, jarray
from pyjvm.c.jvmti cimport jvmtiEnv
from libc.stdlib cimport malloc, free
from libc.string cimport strlen

from pyjvm.types.converter.typeconverter cimport convert_to_java
from pyjvm.types.signature cimport JVM_SIG_ARGS_END, JVM_SIG_ARGS_START, JVM_SIG_END, JVM_SIG_ARRAY, JVM_SIG_CLASS, JVM_SIG_VOID, JVM_SIG_BOOLEAN, JVM_SIG_BYTE, JVM_SIG_CHAR, JVM_SIG_DOUBLE, JVM_SIG_FLOAT, JVM_SIG_INT, JVM_SIG_LONG, JVM_SIG_SHORT
from pyjvm.exceptions.exception cimport JvmExceptionPropagateIfThrown

from pyjvm.types.array.jvmarray cimport JvmArray, CreateJvmArray

import traceback


cdef class JvmMethodSignature:
    #cdef char* _signature
    #cdef unsigned int _signature_length
    #cdef char* args
    #cdef char* return_type
    #cdef int nargs

    @property
    def signature(self):
        return self._signature.decode("utf-8")
    

    def __init__(self, bint independent = False):
        self._signature = NULL
        self.independent = independent
        self._signature_length = 0
        self._args = NULL
        self.nargs = -1
        self.return_type = NULL

    def __dealloc__(self):
        if self.independent:
            free(self._signature)

    def __str__(self):
        return self.signature

    @property
    def args(self):
        cdef list values = []
        cdef int i = 0
        cdef int next_arg_offset = 0
        cdef int arg_offset = 1

        self.parse()

        for i in range(self.nargs):
            next_arg_offset = self.next_arg(arg_offset)
            data = self._signature[arg_offset:arg_offset + next_arg_offset]
            values.append(data.decode("utf-8"))
            arg_offset += next_arg_offset

        return values
        

    @property
    def ret(self):
        self.parse()
        return self.return_type.decode("utf-8")

    cdef void parse(self) except *:
        cdef bint in_args = True
        cdef bint in_arg = False
        cdef int i

        if self.nargs != -1:
            return

        self._signature_length = strlen(self._signature)
        self.nargs = 0

        for i in range(self._signature_length):
            if self._signature[i] == JVM_SIG_ARGS_START:
                continue
            elif self._signature[i] == JVM_SIG_ARGS_END:
                in_args = False
                continue

            if in_args:
                if self._args == NULL:
                    self._args = self._signature + i
                if in_arg:
                    if self._signature[i] == JVM_SIG_END:
                        in_arg = False
                        self.nargs += 1
                    else:
                        continue
                elif self._signature[i] == JVM_SIG_CLASS or self._signature[i] == JVM_SIG_ARRAY:
                    in_arg = True
                else:
                    self.nargs += 1

            else:
                if self.return_type == NULL:
                    self.return_type = self._signature + i
        
    cdef inline int next_arg(self, int offset):
        # returns the length of the next arg
        cdef unsigned int next_offset = 0
        if self._signature[offset] == JVM_SIG_CLASS or self._signature[offset] == JVM_SIG_ARRAY:
            for i in range(self._signature_length - offset):
                next_offset += 1
                if self._signature[offset + next_offset] == JVM_SIG_END:
                    return next_offset + 1
        else:
            return 1
        

    cdef jvalue* convert(self, tuple args, Jvm jvm):
        cdef str f_ret
        cdef list f_args
        cdef jvalue* jargs
        cdef int sig_offset = 1 # (...

        self.parse()

        if self.nargs != len(args):
            return NULL
        
        jargs = <jvalue*>malloc(sizeof(jvalue) * len(args))
                
        if len(args) == 0:
            return jargs

        for i in range(len(args)):
            try:
                jargs[i] = convert_to_java(self._signature + sig_offset, args[i], jvm)
                sig_offset += self.next_arg(sig_offset)
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

    def __dealloc__(self):
        cdef JvmMethodSignature signature
        cdef JvmMethodReference overload
        cdef Jvm jvm = self._clazz.jvm
        cdef jvmtiEnv* jvmti = jvm.jvmti
        cdef jint err

        err = jvmti[0].Deallocate(jvmti, <unsigned char*>self._name)

        for overload in self._overloads:
            signature = overload.signature
            err = jvmti[0].Deallocate(jvmti, <unsigned char*>signature._signature)
            

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
        return self._name.decode("utf-8")

    @property
    def signature(self):
        cdef JvmMethodReference c
        for c in self._overloads:
            c.signature.parse()
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

    cdef object call_array(self, JNIEnv* jni, jclass clazz, jmethodID method_id, jvalue* args, Jvm jvm, char* signature):
        cdef jarray value
        value = jni[0].CallStaticObjectMethodA(jni, clazz, method_id, args)
        JvmExceptionPropagateIfThrown(jvm)
        return CreateJvmArray(jvm, value, signature)

    cdef object call(self, jmethodID mid, jvalue* args, char* return_type):
        cdef Jvm jvm = self.clazz.jvm
        cdef JNIEnv* env = jvm.getEnv()
        cdef jclass cid = <jclass><unsigned long long>self._clazz._jclass
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

            overload.signature.parse() # ensure parsed

            mid = overload._method_id
            ret = self.call(mid, jargs, overload.signature.return_type)

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
        name += self.signature + " " + self.name
        return name
    
    def __init__(self, int modifiers, object clazz):
        self._name = NULL
        self._overloads = []
        self._modifiers = modifiers
        self._clazz = clazz

    def add_overload(self, unsigned long long mid):
        cdef Jvm jvm = self._clazz.jvm
        cdef jvmtiEnv* jvmti = jvm.jvmti

        cdef jmethodID methodid = <jmethodID>mid
        cdef JvmMethodReference overload

        cdef const char* name
        cdef const char* signature

        error = jvmti[0].GetMethodName(jvmti, methodid, &name, &signature, NULL)
        if error != 0:
            raise Exception("Failed to get field name")

        error = jvmti[0].Deallocate(jvmti, <unsigned char*>name)
        if error != 0:
            raise Exception("Failed to deallocate field name")

        overload = JvmMethodReference()
        overload._method_id = methodid
        overload.signature = JvmMethodSignature()
        overload.signature._signature = signature

        self._overloads.append(overload)



cdef JvmMethodFromJmethodID(jmethodID mid, jclass cid, object clazz):
    cdef Jvm jvm = clazz.jvm
    cdef jvmtiEnv* jvmti = jvm.jvmti

    cdef char* name
    cdef char* signature

    cdef jint modifiers
    cdef jint error

    cdef JvmMethod method
    cdef JvmMethodReference overload

    error = jvmti[0].GetMethodName(jvmti, mid, &name, &signature, NULL)
    if error != 0:
        raise Exception("Failed to get field name")

    error = jvmti[0].GetMethodModifiers(jvmti, mid, &modifiers)
    if error != 0:
        raise Exception("Failed to get field modifiers")

    method = JvmMethod(modifiers, clazz)
    method._name = name
    overload = JvmMethodReference()
    overload._method_id = mid
    overload.signature = JvmMethodSignature()
    overload.signature._signature = signature

    method._overloads.append(overload)
    return method



