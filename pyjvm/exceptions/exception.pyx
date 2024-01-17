from pyjvm.c.jni cimport jthrowable, JNIEnv


cdef void JvmExceptionPropagateIfThrown(JNIEnv* jni) except *:
    cdef jthrowable throwable = jni[0].ExceptionOccurred(jni)
    if throwable is not NULL:
        jni[0].ExceptionClear(jni)
        raise Exception("Exception occurred in JVM, cant be propagated to Python yet")

