from pyjvm.types.clazz.jvmclass cimport JvmClass, JvmObjectFromJobject
from pyjvm.c.jni cimport jfieldID, jobject, JNIEnv
from pyjvm.types.clazz.jvmfield cimport JvmField
from pyjvm.jvm cimport Jvm

from pyjvm.c.jni cimport jfieldID, jint, jclass, jboolean, jbyte, jchar, jdouble, jfloat, jint, jlong, jshort, jstring, jobject, JNIEnv
from pyjvm.c.jvmti cimport jvmtiEnv

from pyjvm.exceptions.exception cimport JvmExceptionPropagateIfThrown

from pyjvm.types.signature import JvmSignature


cdef class JvmBoundField:
#    cdef JvmField _field
#    cdef object _object

    def __init__(self, JvmField field, object obj):
        self._field = field
        self._object = obj

    cpdef object get(self):
        cdef Jvm jvm = self._object.__class__.jvm
        cdef JNIEnv* env = jvm.jni
        cdef jclass cid = <jclass><unsigned long long>self._object.__class__._jclass
        cdef jfieldID fid = self._field._fid
        cdef str signature = self._field._signature

        cdef jint error
        cdef object value

        if signature == JvmSignature.BOOLEAN:
            return self.get_boolean(env, cid, fid, jvm)
        elif signature == JvmSignature.BYTE:
            return self.get_byte(env, cid, fid, jvm)
        elif signature == JvmSignature.CHAR:
            return self.get_char(env, cid, fid, jvm)
        elif signature == JvmSignature.DOUBLE:
            return self.get_double(env, cid, fid, jvm)
        elif signature == JvmSignature.FLOAT:
            return self.get_float(env, cid, fid, jvm)
        elif signature == JvmSignature.INT:
            return self.get_int(env, cid, fid, jvm)
        elif signature == JvmSignature.LONG:
            return self.get_long(env, cid, fid, jvm)
        elif signature == JvmSignature.SHORT:
            return self.get_short(env, cid, fid, jvm)
        else:
            return self.get_object(env, cid, fid, jvm)

    cdef object get_boolean(self, JNIEnv* env, jobject object, jfieldID fid, Jvm jvm):
        cdef jboolean value
        value = env[0].GetBooleanField(env, object, fid)
        JvmExceptionPropagateIfThrown(jvm)
        return value != 0

    cdef object get_byte(self, JNIEnv* env, jobject object, jfieldID fid, Jvm jvm):
        cdef jbyte value
        value = env[0].GetByteField(env, object, fid)
        JvmExceptionPropagateIfThrown(jvm)
        return <int>value

    cdef object get_char(self, JNIEnv* env, jobject object, jfieldID fid, Jvm jvm):
        cdef jchar value
        value = env[0].GetCharField(env, object, fid)
        JvmExceptionPropagateIfThrown(jvm)
        return chr(value)

    cdef object get_short(self, JNIEnv* env, jobject object, jfieldID fid, Jvm jvm):
        cdef jshort value
        value = env[0].GetShortField(env, object, fid)
        JvmExceptionPropagateIfThrown(jvm)
        return <int>value

    cdef object get_int(self, JNIEnv* env, jobject object, jfieldID fid, Jvm jvm):
        cdef jint value
        value = env[0].GetIntField(env, object, fid)
        JvmExceptionPropagateIfThrown(jvm)
        return <long>value

    cdef object get_long(self, JNIEnv* env, jobject object, jfieldID fid, Jvm jvm):
        cdef jlong value
        value = env[0].GetLongField(env, object, fid)
        JvmExceptionPropagateIfThrown(jvm)
        return <long long>value

    cdef object get_float(self, JNIEnv* env, jobject object, jfieldID fid, Jvm jvm):
        cdef jfloat value
        value = env[0].GetFloatField(env, object, fid)
        JvmExceptionPropagateIfThrown(jvm)
        return <float>value

    cdef object get_double(self, JNIEnv* env, jobject object, jfieldID fid, Jvm jvm):
        cdef jdouble value
        value = env[0].GetDoubleField(env, object, fid)
        JvmExceptionPropagateIfThrown(jvm)
        return <double>value

    cdef object get_object(self, JNIEnv* env, jobject object, jfieldID fid, Jvm jvm):
        cdef jobject value
        value = env[0].GetObjectField(env, object, fid)
        JvmExceptionPropagateIfThrown(jvm)

        return JvmObjectFromJobject(<unsigned long long>value, jvm)