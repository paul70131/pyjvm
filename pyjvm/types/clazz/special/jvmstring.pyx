from pyjvm.jvm cimport Jvm
from pyjvm.c.jni cimport JNIEnv, jobject, jsize, jstring

from pyjvm.exceptions.exception cimport JvmExceptionPropagateIfThrown

from collections import UserString
from pyjvm.types.clazz.jvmclass cimport JvmClass, JvmObjectFromJobject



cdef class JvmString(JvmClass):

    @staticmethod
    cdef JvmString from_py(Jvm jvm, str s):
        cdef JNIEnv* jni = jvm.jni
        cdef jstring jstr = jni[0].NewStringUTF(jni, s.encode("utf-8"))
        JvmExceptionPropagateIfThrown(jvm)
        return JvmObjectFromJobject(<unsigned long long>jstr, jvm)

    

    def __init__(self, data):
        if isinstance(data, int):
            # From jobject
            super().__init__(data)
    

    def __len__(self):
        cdef Jvm jvm = self.__class__.jvm
        cdef JNIEnv* jni = jvm.jni
        cdef jobject obj = <jobject><unsigned long long>self._jobject

        cdef jsize length = jni[0].GetStringUTFLength(jni, obj)
        JvmExceptionPropagateIfThrown(jvm)
        return <long long>length

    def __str__(self):
        return self.__get_data()

    def __repr__(self):
        return f"J'{self.__str__()}'"

    def __eq__(self, other):
        if isinstance(other, JvmString):
            return self.equals(other)
        elif isinstance(other, str):
            return self.__get_data() == other
        else:
            return False
    
    cdef str __get_data(self):
        cdef Jvm jvm = self.__class__.jvm
        cdef JNIEnv* jni = jvm.jni
        cdef jobject obj = <jobject><unsigned long long>self._jobject

        cdef char* utf8 = jni[0].GetStringUTFChars(jni, obj, NULL)
        cdef str utf8_str = utf8.decode("utf-8")

        jni[0].ReleaseStringUTFChars(jni, obj, utf8)
        JvmExceptionPropagateIfThrown(jvm)

        return utf8_str