from pyjvm.c.jni cimport JNI_GetCreatedJavaVMs_t, JNI_CreateJavaVM_t, jint, jsize, JavaVMInitArgs, JNI_VERSION_1_2, JavaVMOption
from pyjvm.c.jni cimport jsize, jbyte, jclass
from pyjvm.c.windows cimport HMODULE, GetModuleHandleA, GetProcAddress, LoadLibraryA
from pyjvm.c.jvmti cimport JVMTI_VERSION_1_2

from pyjvm.exceptions.exception import JniException
from pyjvm.exceptions.exception cimport JvmExceptionPropagateIfThrown

from pyjvm.types.clazz.jvmclass cimport JvmClassFromJclass, JvmClass

import os
import faulthandler

cdef Jvm __instance = None

cdef class Jvm:
    #cdef JavaVM* jvm
    #cdef JNIEnv* jni
    #cdef jvmtiEnv* jvmti
    #cdef public dict __classes

    def __cinit__(self):
        self.jvm = NULL
        self.jni = NULL
        self.jvmti = NULL
        self.__classes = {}

    @staticmethod
    def aquire() -> Jvm:
        if __instance == None:
            try:
                return Jvm.attach()
            except Exception as e:
                return Jvm.create()
        else:
            return __instance

    @staticmethod
    def create() -> Jvm:
        cdef Jvm result = None
        cdef JavaVM* jvm
        cdef JNIEnv* jni
        cdef jvmtiEnv* jvmti
        cdef jint err = 0
        cdef jsize nVMs = 0
        cdef JavaVMInitArgs args
        cdef JavaVMOption options[1]

        options[0].optionString = "-Xcheck:jni"
        options[0].extraInfo = NULL

        args.version = JNI_VERSION_1_2
        args.nOptions = 1
        args.options = options
        args.ignoreUnrecognized = 0
        
        err = _JNI_GetCreatedJavaVMs(&jvm, 1, &nVMs)
        if err != 0:
            raise JniException(err, "Could not get created Java VMs")
        if nVMs != 0:
            raise JniException(0, "Java VM already exists, use attach() instead")

        err = _JNI_CreateJavaVM(&jvm, &jni, &args)

        if err != 0:
            raise JniException(err, "Could not create Java VM")

        err = jvm[0].GetEnv(jvm, <void**>&jvmti, JVMTI_VERSION_1_2)

        if err != 0:
            raise JniException(err, "Could not get JVMTI environment")

        result = Jvm()
        result.jvm = jvm
        result.jni = jni
        result.jvmti = jvmti

        __instance = result

        return result

    
    @staticmethod
    def attach() -> Jvm:
        cdef Jvm result
        cdef JavaVM* jvm
        cdef JNIEnv* jni
        cdef jvmtiEnv* jvmti
        cdef jint err = 0
        cdef jsize nVMs = 0


        err = _JNI_GetCreatedJavaVMs(&jvm, 1, &nVMs)

        if err != 0:
            raise Exception("Could not get created Java VMs", err)
        if nVMs != 1:
            raise Exception("No Java VMs created")
        
        err = jvm[0].AttachCurrentThread(jvm, <void**>&jni, NULL)

        if err != 0:
            raise Exception("Could not attach to Java VM", err)

        err = jvm[0].GetEnv(jvm, <void**>&jvmti, JVMTI_VERSION_1_2)

        if err != 0:
            raise Exception("Could not get JVMTI environment", err)

        result = Jvm()
        result.jvm = jvm
        result.jni = jni
        result.jvmti = jvmti

        __instance = result

        return result

    cpdef object findClass(self, str name):
        cdef jclass cls = self.jni[0].FindClass(self.jni, name.encode("utf-8"))
        JvmExceptionPropagateIfThrown(self)

        return JvmClassFromJclass(<unsigned long long>cls, self)


    def destroy(self):
        self.jvm[0].DestroyJavaVM(self.jvm)

    def loadClass(self, object classfile):
        # classfile is a file-like object opened in binary mode
        cdef bytes bytecode = classfile.read()
        cdef jsize length = len(bytecode)

        cdef jclass cls = self.jni[0].DefineClass(self.jni, NULL, NULL, <const jbyte*>bytecode, length)
        JvmExceptionPropagateIfThrown(self)

        return JvmClassFromJclass(<unsigned long long>cls, self)





cdef HMODULE _jvmlib = NULL
cdef JNI_GetCreatedJavaVMs_t _JNI_GetCreatedJavaVMs = NULL
cdef JNI_CreateJavaVM_t _JNI_CreateJavaVM = NULL


_jvmlib = GetModuleHandleA("jvm.dll")
if _jvmlib == NULL:
    JAVA_HOME = os.environ.get("JAVA_HOME")
    jvmLibPath = os.path.join(JAVA_HOME, "bin", "server", "jvm.dll")
    jvmLibPathBytes = jvmLibPath.encode("utf-8")

    _jvmlib = LoadLibraryA(jvmLibPathBytes)
    if _jvmlib == NULL:
        raise RuntimeError("Could not load jvm.dll")
    
_JNI_GetCreatedJavaVMs = <JNI_GetCreatedJavaVMs_t>GetProcAddress(_jvmlib, "JNI_GetCreatedJavaVMs")
_JNI_CreateJavaVM = <JNI_CreateJavaVM_t>GetProcAddress(_jvmlib, "JNI_CreateJavaVM")

if _JNI_GetCreatedJavaVMs == NULL or _JNI_CreateJavaVM == NULL:
    raise RuntimeError("Could not load JNI_GetCreatedJavaVMs or JNI_CreateJavaVM")