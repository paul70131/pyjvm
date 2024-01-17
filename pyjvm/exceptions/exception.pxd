from pyjvm.c.jni cimport jthrowable, JNIEnv


cdef void JvmExceptionPropagateIfThrown(JNIEnv* jni) except *