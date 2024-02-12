from pyjvm.types.clazz.jvmclass cimport JvmClass, JvmObjectFromJobject
from pyjvm.c.jni cimport jfieldID, jobject, JNIEnv
from pyjvm.types.clazz.jvmfield cimport JvmField
from pyjvm.jvm cimport Jvm

from pyjvm.c.jni cimport jfieldID, jint, jclass, jboolean, jbyte, jchar, jdouble, jfloat, jint, jlong, jshort, jstring, jobject, JNIEnv
from pyjvm.c.jvmti cimport jvmtiEnv

from pyjvm.types.converter.typeconverter cimport convert_to_bool, convert_to_byte, convert_to_char, convert_to_double, convert_to_float, convert_to_int, convert_to_long, convert_to_short, convert_to_object

from pyjvm.exceptions.exception cimport JvmExceptionPropagateIfThrown

from pyjvm.types.signature cimport JVM_SIG_BOOLEAN, JVM_SIG_BYTE, JVM_SIG_CHAR, JVM_SIG_SHORT, JVM_SIG_INT, JVM_SIG_LONG, JVM_SIG_FLOAT, JVM_SIG_DOUBLE, JVM_SIG_ARRAY, JVM_SIG_CLASS


cdef class JvmBoundField:
#    cdef JvmField _field
#    cdef object _object

    def __init__(self, JvmField field, object obj):
        self._field = field
        self._object = obj


    cdef void set(self, object value) except *:
        cdef Jvm jvm = self._object.__class__.jvm
        cdef JNIEnv* env = jvm.getEnv()
        cdef jobject cid = <jobject><unsigned long long>self._object._jobject
        cdef jfieldID fid = self._field._fid
        cdef char* signature = self._field._signature

        if signature[0] == JVM_SIG_BOOLEAN:
            self.set_boolean(env, cid, fid, value, jvm)
        elif signature[0] == JVM_SIG_BYTE:
            self.set_byte(env, cid, fid, value, jvm)
        elif signature[0] == JVM_SIG_CHAR:
            self.set_char(env, cid, fid, value, jvm)
        elif signature[0] == JVM_SIG_DOUBLE:
            self.set_double(env, cid, fid, value, jvm)
        elif signature[0] == JVM_SIG_FLOAT:
            self.set_float(env, cid, fid, value, jvm)
        elif signature[0] == JVM_SIG_INT:
            self.set_int(env, cid, fid, value, jvm)
        elif signature[0] == JVM_SIG_LONG:
            self.set_long(env, cid, fid, value, jvm)
        elif signature[0] == JVM_SIG_SHORT:
            self.set_short(env, cid, fid, value, jvm)
        else:
            self.set_object(env, cid, fid, value, jvm)

    cdef void set_boolean(self, JNIEnv* env, jobject object, jfieldID fid, object value, Jvm jvm) except *:
        cdef jboolean jvalue = convert_to_bool(value)
        env[0].SetBooleanField(env, object, fid, jvalue)
        JvmExceptionPropagateIfThrown(jvm)

    cdef void set_byte(self, JNIEnv* env, jobject object, jfieldID fid, object value, Jvm jvm) except *:
        cdef jbyte jvalue = convert_to_byte(value)
        env[0].SetByteField(env, object, fid, jvalue)
        JvmExceptionPropagateIfThrown(jvm)

    cdef void set_char(self, JNIEnv* env, jobject object, jfieldID fid, object value, Jvm jvm) except *:
        cdef jchar jvalue = convert_to_char(value)
        env[0].SetCharField(env, object, fid, jvalue)
        JvmExceptionPropagateIfThrown(jvm)

    cdef void set_short(self, JNIEnv* env, jobject object, jfieldID fid, object value, Jvm jvm) except *:
        cdef jshort jvalue = convert_to_short(value)
        env[0].SetShortField(env, object, fid, jvalue)
        JvmExceptionPropagateIfThrown(jvm)

    cdef void set_int(self, JNIEnv* env, jobject object, jfieldID fid, object value, Jvm jvm) except *:
        cdef jint jvalue = convert_to_int(value)
        env[0].SetIntField(env, object, fid, jvalue)
        JvmExceptionPropagateIfThrown(jvm)

    cdef void set_long(self, JNIEnv* env, jobject object, jfieldID fid, object value, Jvm jvm) except *:
        cdef jlong jvalue = convert_to_long(value)
        env[0].SetLongField(env, object, fid, jvalue)
        JvmExceptionPropagateIfThrown(jvm)

    cdef void set_float(self, JNIEnv* env, jobject object, jfieldID fid, object value, Jvm jvm) except *:
        cdef jfloat jvalue = convert_to_float(value)
        env[0].SetFloatField(env, object, fid, jvalue)
        JvmExceptionPropagateIfThrown(jvm)

    cdef void set_double(self, JNIEnv* env, jobject object, jfieldID fid, object value, Jvm jvm) except *:
        cdef jdouble jvalue = convert_to_double(value)
        env[0].SetDoubleField(env, object, fid, jvalue)
        JvmExceptionPropagateIfThrown(jvm)

    cdef void set_object(self, JNIEnv* env, jobject object, jfieldID fid, object value, Jvm jvm) except *:
        cdef jobject jvalue = convert_to_object(value, jvm)
        env[0].SetObjectField(env, object, fid, jvalue)
        JvmExceptionPropagateIfThrown(jvm)

    cpdef object get(self):
        cdef Jvm jvm = self._object.__class__.jvm
        cdef JNIEnv* env = jvm.getEnv()
       # cdef jclass cid = <jclass><unsigned long long>self._object.__class__._jclass
        cdef jobject cid = <jobject><unsigned long long>self._object._jobject
        cdef jfieldID fid = self._field._fid
        cdef char* signature = self._field._signature

        cdef jint error
        cdef object value

        if signature[0] == JVM_SIG_BOOLEAN:
            return self.get_boolean(env, cid, fid, jvm)
        elif signature[0] == JVM_SIG_BYTE:
            return self.get_byte(env, cid, fid, jvm)
        elif signature[0] == JVM_SIG_CHAR:
            return self.get_char(env, cid, fid, jvm)
        elif signature[0] == JVM_SIG_DOUBLE:
            return self.get_double(env, cid, fid, jvm)
        elif signature[0] == JVM_SIG_FLOAT:
            return self.get_float(env, cid, fid, jvm)
        elif signature[0] == JVM_SIG_INT:
            return self.get_int(env, cid, fid, jvm)
        elif signature[0] == JVM_SIG_LONG:
            return self.get_long(env, cid, fid, jvm)
        elif signature[0] == JVM_SIG_SHORT:
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