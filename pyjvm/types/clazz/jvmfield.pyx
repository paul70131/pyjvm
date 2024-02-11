from pyjvm.types.clazz.jvmclass cimport JvmClass
from pyjvm.jvm cimport Jvm
from pyjvm.types.clazz.jvmclass cimport JvmClassFromJclass, JvmObjectFromJobject

from pyjvm.c.jni cimport jfieldID, jint, jclass, jboolean, jbyte, jchar, jdouble, jfloat, jint, jlong, jshort, jstring, jobject, JNIEnv, jarray
from pyjvm.c.jvmti cimport jvmtiEnv
from pyjvm.types.converter.typeconverter cimport convert_to_bool, convert_to_byte, convert_to_char, convert_to_int, convert_to_short, convert_to_long, convert_to_float, convert_to_double, convert_to_object

from pyjvm.exceptions.exception cimport JvmExceptionPropagateIfThrown

from pyjvm.types.signature cimport JVM_SIG_ARRAY, JVM_SIG_CLASS, JVM_SIG_BOOLEAN, JVM_SIG_BYTE, JVM_SIG_CHAR, JVM_SIG_DOUBLE, JVM_SIG_FLOAT, JVM_SIG_INT, JVM_SIG_LONG, JVM_SIG_SHORT
from pyjvm.types.array.jvmarray cimport JvmArray, CreateJvmArray

cdef class JvmField:
#    cdef jfieldID _fid
#    cdef str _name
#    cdef str _signature
#    cdef int _modifiers
#    cdef object _clazz

    def __dealloc__(self):
        cdef Jvm jvm = self._clazz.jvm
        cdef jvmtiEnv* jvmti = jvm.jvmti
        error = jvmti[0].Deallocate(jvmti, <unsigned char*>self._name)
        if error != 0:
            raise Exception("Failed to deallocate field name")
        
        error = jvmti[0].Deallocate(jvmti, <unsigned char*>self._signature)
        if error != 0:
            raise Exception("Failed to deallocate field signature")


    @property
    def name(self):
        return self._name

    @property
    def signature(self):
        return self._signature.decode("utf-8")

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

    cdef object get_boolean(self, JNIEnv* env, jclass cid, jfieldID fid, Jvm jvm):
        cdef jboolean value
        value = env[0].GetStaticBooleanField(env, cid, fid)
        JvmExceptionPropagateIfThrown(jvm)
        return value != 0
    
    cdef object get_byte(self, JNIEnv* env, jclass cid, jfieldID fid, Jvm jvm):
        cdef jbyte value
        value = env[0].GetStaticByteField(env, cid, fid)
        JvmExceptionPropagateIfThrown(jvm)
        return <int>value

    cdef object get_char(self, JNIEnv* env, jclass cid, jfieldID fid, Jvm jvm):
        cdef jchar value
        value = env[0].GetStaticCharField(env, cid, fid)
        JvmExceptionPropagateIfThrown(jvm)
        return chr(<int>value)

    cdef object get_double(self, JNIEnv* env, jclass cid, jfieldID fid, Jvm jvm):
        cdef jdouble value
        value = env[0].GetStaticDoubleField(env, cid, fid)
        JvmExceptionPropagateIfThrown(jvm)
        return <double>value
    
    cdef object get_float(self, JNIEnv* env, jclass cid, jfieldID fid, Jvm jvm):
        cdef jfloat value
        value = env[0].GetStaticFloatField(env, cid, fid)
        JvmExceptionPropagateIfThrown(jvm)
        return <float>value
    
    cdef object get_int(self, JNIEnv* env, jclass cid, jfieldID fid, Jvm jvm):
        cdef jint value
        value = env[0].GetStaticIntField(env, cid, fid)
        JvmExceptionPropagateIfThrown(jvm)
        return <int>value

    cdef object get_long(self, JNIEnv* env, jclass cid, jfieldID fid, Jvm jvm):
        cdef jlong value
        value = env[0].GetStaticLongField(env, cid, fid)
        JvmExceptionPropagateIfThrown(jvm)
        return <long>value
    
    cdef object get_short(self, JNIEnv* env, jclass cid, jfieldID fid, Jvm jvm):
        cdef jshort value
        value = env[0].GetStaticShortField(env, cid, fid)
        JvmExceptionPropagateIfThrown(jvm)
        return <int>value

    cdef object get_object(self, JNIEnv* env, jclass cid, jfieldID fid, Jvm jvm):
        cdef jobject value
        value = env[0].GetStaticObjectField(env, cid, fid)
        JvmExceptionPropagateIfThrown(jvm)
        #return <unsigned long long>value
        return JvmObjectFromJobject(<unsigned long long>value, jvm)
    
    cdef object get_array(self, JNIEnv* env, jclass cid, jfieldID fid, char* signature, Jvm jvm):
        cdef jarray value
        value = env[0].GetStaticObjectField(env, cid, fid)
        JvmExceptionPropagateIfThrown(jvm)
        return CreateJvmArray(jvm, value, signature)
    
    cpdef object get(self, object clazz):
        cdef Jvm jvm = clazz.jvm
        cdef JNIEnv* env = jvm.getEnv()
        cdef jclass cid = <jclass><unsigned long long>self._clazz._jclass
        cdef jfieldID fid = self._fid

        cdef object value

        if self._signature[0] == JVM_SIG_BOOLEAN:
            return self.get_boolean(env, cid, fid, jvm)
        elif self._signature[0] == JVM_SIG_BYTE:
            return self.get_byte(env, cid, fid, jvm)
        elif self._signature[0] == JVM_SIG_CHAR:
            return self.get_char(env, cid, fid, jvm)
        elif self._signature[0] == JVM_SIG_DOUBLE:
            return self.get_double(env, cid, fid, jvm)
        elif self._signature[0] == JVM_SIG_FLOAT:
            return self.get_float(env, cid, fid, jvm)
        elif self._signature[0] == JVM_SIG_INT:
            return self.get_int(env, cid, fid, jvm)
        elif self._signature[0] == JVM_SIG_LONG:
            return self.get_long(env, cid, fid, jvm)
        elif self._signature[0] == JVM_SIG_SHORT:
            return self.get_short(env, cid, fid, jvm)
        elif self._signature[0] == JVM_SIG_ARRAY:
            return self.get_array(env, cid, fid, self._signature, jvm)
        elif self._signature[0] == JVM_SIG_CLASS:
            return self.get_object(env, cid, fid, jvm)
        else:
            raise NotImplementedError

    cpdef void set(self, object clazz, object value) except *:
        cdef Jvm jvm = clazz.jvm
        cdef JNIEnv* env = jvm.getEnv()
        cdef jclass cid = <jclass><unsigned long long>self._clazz._jclass
        cdef jfieldID fid = self._fid

        # do type conversion here

        if self._signature[0] == JVM_SIG_BOOLEAN:
            self.set_boolean(env, cid, fid, value, jvm)
        elif self._signature[0] == JVM_SIG_BYTE:
            self.set_byte(env, cid, fid, value, jvm)
        elif self._signature[0] == JVM_SIG_CHAR:
            self.set_char(env, cid, fid, value, jvm)
        elif self._signature[0] == JVM_SIG_DOUBLE:
            self.set_double(env, cid, fid, value, jvm)
        elif self._signature[0] == JVM_SIG_FLOAT:
            self.set_float(env, cid, fid, value, jvm)
        elif self._signature[0] == JVM_SIG_INT:
            self.set_int(env, cid, fid, value, jvm)
        elif self._signature[0] == JVM_SIG_LONG:
            self.set_long(env, cid, fid, value, jvm)
        elif self._signature[0] == JVM_SIG_SHORT:
            self.set_short(env, cid, fid, value, jvm)
        elif self._signature[0] == JVM_SIG_ARRAY:
            self.set_array(env, cid, fid, value, jvm)
        elif self._signature[0] == JVM_SIG_CLASS:
            self.set_object(env, cid, fid, value, jvm)
        else:
            raise NotImplementedError

    cdef void set_boolean(self, JNIEnv* env, jclass clazz, jfieldID fid, object value, Jvm jvm) except *:
        cdef jboolean v = convert_to_bool(value)
        env[0].SetStaticBooleanField(env, clazz, fid, v)
        JvmExceptionPropagateIfThrown(jvm)

    cdef void set_byte(self, JNIEnv* env, jclass clazz, jfieldID fid, object value, Jvm jvm) except *:
        cdef jbyte v = convert_to_byte(value)
        env[0].SetStaticByteField(env, clazz, fid, v)
        JvmExceptionPropagateIfThrown(jvm)

    cdef void set_char(self, JNIEnv* env, jclass clazz, jfieldID fid, object value, Jvm jvm) except *:
        cdef jchar v = convert_to_char(value)
        env[0].SetStaticCharField(env, clazz, fid, v)
        JvmExceptionPropagateIfThrown(jvm)

    cdef void set_short(self, JNIEnv* env, jclass clazz, jfieldID fid, object value, Jvm jvm) except *:
        cdef jshort v = convert_to_short(value)
        env[0].SetStaticShortField(env, clazz, fid, v)
        JvmExceptionPropagateIfThrown(jvm)

    cdef void set_int(self, JNIEnv* env, jclass clazz, jfieldID fid, object value, Jvm jvm) except *:
        cdef jint v = convert_to_int(value)
        env[0].SetStaticIntField(env, clazz, fid, v)
        JvmExceptionPropagateIfThrown(jvm)

    cdef void set_long(self, JNIEnv* env, jclass clazz, jfieldID fid, object value, Jvm jvm) except *:
        cdef jlong v = convert_to_long(value)
        env[0].SetStaticLongField(env, clazz, fid, v)
        JvmExceptionPropagateIfThrown(jvm)

    cdef void set_float(self, JNIEnv* env, jclass clazz, jfieldID fid, object value, Jvm jvm) except *:
        cdef jfloat v = convert_to_float(value)
        env[0].SetStaticFloatField(env, clazz, fid, v)
        JvmExceptionPropagateIfThrown(jvm)

    cdef void set_double(self, JNIEnv* env, jclass clazz, jfieldID fid, object value, Jvm jvm) except *:
        cdef jdouble v = convert_to_double(value)
        env[0].SetStaticDoubleField(env, clazz, fid, v)
        JvmExceptionPropagateIfThrown(jvm)

    cdef void set_object(self, JNIEnv* env, jclass clazz, jfieldID fid, object value, Jvm jvm) except *:
        cdef jobject v = convert_to_object(value, jvm)
        env[0].SetStaticObjectField(env, clazz, fid, v)
        
        JvmExceptionPropagateIfThrown(jvm)

    cdef void set_array(self, JNIEnv* env, jclass clazz, jfieldID fid, object value, Jvm jvm) except *:
        raise NotImplementedError

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
        name += self._signature.decode("utf-8") + " " + self._name.decode("utf-8")
        return name
    
    def __init__(self, char* name, char* signature, int modifiers, object clazz):
        self._name = name
        self._signature = signature
        self._modifiers = modifiers
        self._clazz = clazz

cdef JvmFieldFromJfieldID(jfieldID fid, jclass cid, object clazz):
    cdef Jvm jvm = clazz.jvm
    cdef jvmtiEnv* jvmti = jvm.jvmti

    cdef char* name
    cdef char* signature

    cdef jint modifiers
    cdef jint error

    error = jvmti[0].GetFieldName(jvmti, cid, fid, &name, &signature, NULL)
    if error != 0:
        raise Exception("Failed to get field name")

    error = jvmti[0].GetFieldModifiers(jvmti, cid, fid, &modifiers)
    if error != 0:
        raise Exception("Failed to get field modifiers")


    f = JvmField(name, signature, modifiers, clazz)
    f._fid = fid
    return f




