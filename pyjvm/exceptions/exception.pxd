from pyjvm.c.jni cimport jthrowable, JNIEnv
from pyjvm.jvm cimport Jvm

cdef void JvmExceptionPropagateIfThrown(Jvm jvm) except *



