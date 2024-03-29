from pyjvm.c.jni cimport jthrowable, JNIEnv
from pyjvm.c.jvmti cimport jint
from pyjvm.types.clazz.jvmclass cimport JvmObjectFromJobject

from enum import Enum

import traceback

class JvmException(Exception):
    pass


class JvmtiException(JvmException):
    
    def __init__(self, jint error_code, str message):
        self.error_code = error_code
        self.message = message

    def __str__(self):
        return f"JVMTI error code {self.error_code}: {self.message}"

class JniErrorCodes(Enum):
    JNI_OK = 0
    JNI_ERR = -1
    JNI_EDETACHED = -2
    JNI_EVERSION = -3
    JNI_ENOMEM = -4
    JNI_EEXIST = -5
    JNI_EINVAL = -6

class JniException(JvmException):
    
    def __init__(self, jint error_code, str message):
        self.error_code = JniErrorCodes(error_code)
        self.message = message

    def __str__(self):
        return f"JNI error code {self.error_code}: {self.message}"

    


class JavaRuntimeException(JvmException):
    pass


from pyjvm.types.clazz.special.jvmexception import JvmException

cdef void JvmExceptionPropagateIfThrown(Jvm jvm) except *:
    cdef JNIEnv* jni = jvm.getEnv()
    cdef jthrowable throwable = jni[0].ExceptionOccurred(jni)

    jvm.ensureBridgeLoaded()

    if throwable is not NULL:
        jni[0].ExceptionClear(jni)
        obj = JvmObjectFromJobject(<unsigned long long> throwable, jvm)

        if obj.__class__.__name__ == "pyjvm.bridge.java.PyException":
            jvmPyObject = obj.pyObject
            pyException = <object><void*><unsigned long long> jvmPyObject._ref
            raise pyException


        raise JvmException(obj)
        #raise Exception("Exception occurred in JVM, cant be propagated to Python yet")


