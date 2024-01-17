# for method calls we always use the jvalue* array as arguments
# va_list is not supported, neither is the ... syntax

cdef extern from "jni.h":

    cdef int JNI_VERSION_1_2 = 0x00010002

    ctypedef unsigned char  jboolean
    ctypedef unsigned short jchar
    ctypedef short          jshort
    ctypedef float          jfloat
    ctypedef double         jdouble
    ctypedef long           jint
    ctypedef long long      jlong
    ctypedef signed char    jbyte

    ctypedef jint           jsize


    struct _jobject:
        pass

    ctypedef _jobject* jobject
    ctypedef jobject jclass
    ctypedef jobject jthrowable
    ctypedef jobject jstring
    ctypedef jobject jarray

    ctypedef jarray jbooleanArray
    ctypedef jarray jbyteArray
    ctypedef jarray jcharArray
    ctypedef jarray jshortArray
    ctypedef jarray jintArray
    ctypedef jarray jlongArray
    ctypedef jarray jfloatArray
    ctypedef jarray jdoubleArray
    ctypedef jarray jobjectArray

    ctypedef jobject jweak

    ctypedef union jvalue:
        jboolean z
        jbyte    b
        jchar    c
        jshort   s
        jint     i
        jlong    j
        jfloat   f
        jdouble  d
        jobject  l

    ctypedef struct JNIEnv

    struct _jfieldID:
        pass
    ctypedef _jfieldID* jfieldID

    struct _jmethodID:
        pass
    ctypedef _jmethodID* jmethodID

    ctypedef enum _jobjectType:
        JNIInvalidRefType       = 0
        JNILocalRefType         = 1
        JNIGlobalRefType        = 2
        JNIWeakGlobalRefType    = 3
    ctypedef _jobjectType jobjectType

    ctypedef struct JNINativeMethod:
        char* name
        char* signature
        void* fnPtr

    ctypedef JNIInvokeInterface_ JavaVM


    ctypedef struct JNIInvokeInterface_:
        void* reserved0
        void* reserved1
        void* reserved2

        jint (*DestroyJavaVM)(JavaVM*)
        jint (*AttachCurrentThread)(JavaVM*, void**, void*)
        jint (*DetachCurrentThread)(JavaVM*)
        jint (*GetEnv)(JavaVM*, void**, jint)
        jint (*AttachCurrentThreadAsDaemon)(JavaVM*, void**, void*)


    struct JNINativeInterface_:
        void* reserved0
        void* reserved1
        void* reserved2
        void* reserved3

        jint (*GetVersion)(JNIEnv*)
        jclass (*FindClass)(JNIEnv*, const char*)

        jmethodID (*FromReflectedMethod)(JNIEnv*, jobject)
        jfieldID (*FromReflectedField)(JNIEnv*, jobject)
        jobject (*ToReflectedMethod)(JNIEnv*, jclass, jmethodID, jboolean)
        jobject (*ToReflectedField)(JNIEnv*, jclass, jfieldID, jboolean)

        jclass (*GetSuperclass)(JNIEnv*, jclass)
        jboolean (*IsAssignableFrom)(JNIEnv*, jclass, jclass)
        
        jint (*Throw)(JNIEnv*, jthrowable)
        jint (*ThrowNew)(JNIEnv*, jclass, const char*)
        jthrowable (*ExceptionOccurred)(JNIEnv*)
        void (*ExceptionDescribe)(JNIEnv*)
        void (*ExceptionClear)(JNIEnv*)
        void (*FatalError)(JNIEnv*, const char*)

        jint (*PushLocalFrame)(JNIEnv*, jint)
        jobject (*PopLocalFrame)(JNIEnv*, jobject)

        jobject (*NewGlobalRef)(JNIEnv*, jobject)
        void (*DeleteGlobalRef)(JNIEnv*, jobject)
        jobject (*NewLocalRef)(JNIEnv*, jobject)
        void (*DeleteLocalRef)(JNIEnv*, jobject)
        jboolean (*IsSameObject)(JNIEnv*, jobject, jobject)
        jint (*EnsureLocalCapacity)(JNIEnv*, jint)

        jobject (*AllocObject)(JNIEnv*, jclass)
        jobject (*NewObjectA)(JNIEnv*, jclass, jmethodID, jvalue*)

        jobject (*GetObjectClass)(JNIEnv*, jobject)
        jboolean (*IsInstanceOf)(JNIEnv*, jobject, jclass)

        jmethodID (*GetMethodID)(JNIEnv*, jclass, const char* name, const char* sig)

        jobject (*CallObjectMethodA)(JNIEnv*, jobject, jmethodID, jvalue*)
        jboolean (*CallBooleanMethodA)(JNIEnv*, jobject, jmethodID, jvalue*)
        jbyte (*CallByteMethodA)(JNIEnv*, jobject, jmethodID, jvalue*)
        jchar (*CallCharMethodA)(JNIEnv*, jobject, jmethodID, jvalue*)
        jshort (*CallShortMethodA)(JNIEnv*, jobject, jmethodID, jvalue*)
        jint (*CallIntMethodA)(JNIEnv*, jobject, jmethodID, jvalue*)
        jlong (*CallLongMethodA)(JNIEnv*, jobject, jmethodID, jvalue*)
        jfloat (*CallFloatMethodA)(JNIEnv*, jobject, jmethodID, jvalue*)
        jdouble (*CallDoubleMethodA)(JNIEnv*, jobject, jmethodID, jvalue*)
        void (*CallVoidMethodA)(JNIEnv*, jobject, jmethodID, jvalue*)

        jobject (*CallNonvirtualObjectMethodA)(JNIEnv*, jobject, jclass, jmethodID, jvalue*)
        jboolean (*CallNonvirtualBooleanMethodA)(JNIEnv*, jobject, jclass, jmethodID, jvalue*)
        jbyte (*CallNonvirtualByteMethodA)(JNIEnv*, jobject, jclass, jmethodID, jvalue*)
        jchar (*CallNonvirtualCharMethodA)(JNIEnv*, jobject, jclass, jmethodID, jvalue*)
        jshort (*CallNonvirtualShortMethodA)(JNIEnv*, jobject, jclass, jmethodID, jvalue*)
        jint (*CallNonvirtualIntMethodA)(JNIEnv*, jobject, jclass, jmethodID, jvalue*)
        jlong (*CallNonvirtualLongMethodA)(JNIEnv*, jobject, jclass, jmethodID, jvalue*)
        jfloat (*CallNonvirtualFloatMethodA)(JNIEnv*, jobject, jclass, jmethodID, jvalue*)
        jdouble (*CallNonvirtualDoubleMethodA)(JNIEnv*, jobject, jclass, jmethodID, jvalue*)
        void (*CallNonvirtualVoidMethodA)(JNIEnv*, jobject, jclass, jmethodID, jvalue*)

        jfieldID (*GetFieldID)(JNIEnv*, jclass, const char* name, const char* sig)

        jobject (*GetObjectField)(JNIEnv*, jobject, jfieldID)
        jboolean (*GetBooleanField)(JNIEnv*, jobject, jfieldID)
        jbyte (*GetByteField)(JNIEnv*, jobject, jfieldID)
        jchar (*GetCharField)(JNIEnv*, jobject, jfieldID)
        jshort (*GetShortField)(JNIEnv*, jobject, jfieldID)
        jint (*GetIntField)(JNIEnv*, jobject, jfieldID)
        jlong (*GetLongField)(JNIEnv*, jobject, jfieldID)
        jfloat (*GetFloatField)(JNIEnv*, jobject, jfieldID)
        jdouble (*GetDoubleField)(JNIEnv*, jobject, jfieldID)

        void (*SetObjectField)(JNIEnv*, jobject, jfieldID, jobject)
        void (*SetBooleanField)(JNIEnv*, jobject, jfieldID, jboolean)
        void (*SetByteField)(JNIEnv*, jobject, jfieldID, jbyte)
        void (*SetCharField)(JNIEnv*, jobject, jfieldID, jchar)
        void (*SetShortField)(JNIEnv*, jobject, jfieldID, jshort)
        void (*SetIntField)(JNIEnv*, jobject, jfieldID, jint)
        void (*SetLongField)(JNIEnv*, jobject, jfieldID, jlong)
        void (*SetFloatField)(JNIEnv*, jobject, jfieldID, jfloat)
        void (*SetDoubleField)(JNIEnv*, jobject, jfieldID, jdouble)

        jmethodID (*GetStaticMethodID)(JNIEnv*, jclass, const char* name, const char* sig)

        jobject (*CallStaticObjectMethodA)(JNIEnv*, jclass, jmethodID, jvalue*)
        jboolean (*CallStaticBooleanMethodA)(JNIEnv*, jclass, jmethodID, jvalue*)
        jbyte (*CallStaticByteMethodA)(JNIEnv*, jclass, jmethodID, jvalue*)
        jchar (*CallStaticCharMethodA)(JNIEnv*, jclass, jmethodID, jvalue*)
        jshort (*CallStaticShortMethodA)(JNIEnv*, jclass, jmethodID, jvalue*)
        jint (*CallStaticIntMethodA)(JNIEnv*, jclass, jmethodID, jvalue*)
        jlong (*CallStaticLongMethodA)(JNIEnv*, jclass, jmethodID, jvalue*)
        jfloat (*CallStaticFloatMethodA)(JNIEnv*, jclass, jmethodID, jvalue*)
        jdouble (*CallStaticDoubleMethodA)(JNIEnv*, jclass, jmethodID, jvalue*)
        void (*CallStaticVoidMethodA)(JNIEnv*, jclass, jmethodID, jvalue*)

        jfieldID (*GetStaticFieldID)(JNIEnv*, jclass, const char* name, const char* sig)

        jobject (*GetStaticObjectField)(JNIEnv*, jclass, jfieldID)
        jboolean (*GetStaticBooleanField)(JNIEnv*, jclass, jfieldID)
        jbyte (*GetStaticByteField)(JNIEnv*, jclass, jfieldID)
        jchar (*GetStaticCharField)(JNIEnv*, jclass, jfieldID)
        jshort (*GetStaticShortField)(JNIEnv*, jclass, jfieldID)
        jint (*GetStaticIntField)(JNIEnv*, jclass, jfieldID)
        jlong (*GetStaticLongField)(JNIEnv*, jclass, jfieldID)
        jfloat (*GetStaticFloatField)(JNIEnv*, jclass, jfieldID)
        jdouble (*GetStaticDoubleField)(JNIEnv*, jclass, jfieldID)

        void (*SetStaticObjectField)(JNIEnv*, jclass, jfieldID, jobject)
        void (*SetStaticBooleanField)(JNIEnv*, jclass, jfieldID, jboolean)
        void (*SetStaticByteField)(JNIEnv*, jclass, jfieldID, jbyte)
        void (*SetStaticCharField)(JNIEnv*, jclass, jfieldID, jchar)
        void (*SetStaticShortField)(JNIEnv*, jclass, jfieldID, jshort)
        void (*SetStaticIntField)(JNIEnv*, jclass, jfieldID, jint)
        void (*SetStaticLongField)(JNIEnv*, jclass, jfieldID, jlong)
        void (*SetStaticFloatField)(JNIEnv*, jclass, jfieldID, jfloat)
        void (*SetStaticDoubleField)(JNIEnv*, jclass, jfieldID, jdouble)

        jstring (*NewString)(JNIEnv*, const jchar* unicode, jsize len)
        jsize (*GetStringLength)(JNIEnv*, jstring)
        const jchar* (*GetStringChars)(JNIEnv*, jstring, jboolean* isCopy)
        void (*ReleaseStringChars)(JNIEnv*, jstring, const jchar* chars)

        jstring (*NewStringUTF)(JNIEnv*, const char* utf)
        jsize (*GetStringUTFLength)(JNIEnv*, jstring)
        const char* (*GetStringUTFChars)(JNIEnv*, jstring, jboolean* isCopy)
        void (*ReleaseStringUTFChars)(JNIEnv*, jstring, const char* chars)

        jsize (*GetArrayLength)(JNIEnv*, jarray)

        jobjectArray (*NewObjectArray)(JNIEnv*, jsize len, jclass, jobject)
        jobject (*GetObjectArrayElement)(JNIEnv*, jobjectArray, jsize index)
        void (*SetObjectArrayElement)(JNIEnv*, jobjectArray, jsize index, jobject)

        jbooleanArray (*NewBooleanArray)(JNIEnv*, jsize len)
        jbyteArray (*NewByteArray)(JNIEnv*, jsize len)
        jcharArray (*NewCharArray)(JNIEnv*, jsize len)
        jshortArray (*NewShortArray)(JNIEnv*, jsize len)
        jintArray (*NewIntArray)(JNIEnv*, jsize len)
        jlongArray (*NewLongArray)(JNIEnv*, jsize len)
        jfloatArray (*NewFloatArray)(JNIEnv*, jsize len)
        jdoubleArray (*NewDoubleArray)(JNIEnv*, jsize len)

        jboolean* (*GetBooleanArrayElements)(JNIEnv*, jbooleanArray, jboolean* isCopy)
        jbyte* (*GetByteArrayElements)(JNIEnv*, jbyteArray, jboolean* isCopy)
        jchar* (*GetCharArrayElements)(JNIEnv*, jcharArray, jboolean* isCopy)
        jshort* (*GetShortArrayElements)(JNIEnv*, jshortArray, jboolean* isCopy)
        jint* (*GetIntArrayElements)(JNIEnv*, jintArray, jboolean* isCopy)
        jlong* (*GetLongArrayElements)(JNIEnv*, jlongArray, jboolean* isCopy)
        jfloat* (*GetFloatArrayElements)(JNIEnv*, jfloatArray, jboolean* isCopy)
        jdouble* (*GetDoubleArrayElements)(JNIEnv*, jdoubleArray, jboolean* isCopy)

        void (*ReleaseBooleanArrayElements)(JNIEnv*, jbooleanArray, jboolean* elems, jint mode)
        void (*ReleaseByteArrayElements)(JNIEnv*, jbyteArray, jbyte* elems, jint mode)
        void (*ReleaseCharArrayElements)(JNIEnv*, jcharArray, jchar* elems, jint mode)
        void (*ReleaseShortArrayElements)(JNIEnv*, jshortArray, jshort* elems, jint mode)
        void (*ReleaseIntArrayElements)(JNIEnv*, jintArray, jint* elems, jint mode)
        void (*ReleaseLongArrayElements)(JNIEnv*, jlongArray, jlong* elems, jint mode)
        void (*ReleaseFloatArrayElements)(JNIEnv*, jfloatArray, jfloat* elems, jint mode)
        void (*ReleaseDoubleArrayElements)(JNIEnv*, jdoubleArray, jdouble* elems, jint mode)

        void (*GetBooleanArrayRegion)(JNIEnv*, jbooleanArray, jsize start, jsize len, jboolean* buf)
        void (*GetByteArrayRegion)(JNIEnv*, jbyteArray, jsize start, jsize len, jbyte* buf)
        void (*GetCharArrayRegion)(JNIEnv*, jcharArray, jsize start, jsize len, jchar* buf)
        void (*GetShortArrayRegion)(JNIEnv*, jshortArray, jsize start, jsize len, jshort* buf)
        void (*GetIntArrayRegion)(JNIEnv*, jintArray, jsize start, jsize len, jint* buf)
        void (*GetLongArrayRegion)(JNIEnv*, jlongArray, jsize start, jsize len, jlong* buf) 
        void (*GetFloatArrayRegion)(JNIEnv*, jfloatArray, jsize start, jsize len, jfloat* buf)
        void (*GetDoubleArrayRegion)(JNIEnv*, jdoubleArray, jsize start, jsize len, jdouble* buf)

        void (*SetBooleanArrayRegion)(JNIEnv*, jbooleanArray, jsize start, jsize len, jboolean* buf)
        void (*SetByteArrayRegion)(JNIEnv*, jbyteArray, jsize start, jsize len, jbyte* buf)
        void (*SetCharArrayRegion)(JNIEnv*, jcharArray, jsize start, jsize len, jchar* buf)
        void (*SetShortArrayRegion)(JNIEnv*, jshortArray, jsize start, jsize len, jshort* buf)
        void (*SetIntArrayRegion)(JNIEnv*, jintArray, jsize start, jsize len, jint* buf)
        void (*SetLongArrayRegion)(JNIEnv*, jlongArray, jsize start, jsize len, jlong* buf)
        void (*SetFloatArrayRegion)(JNIEnv*, jfloatArray, jsize start, jsize len, jfloat* buf)
        void (*SetDoubleArrayRegion)(JNIEnv*, jdoubleArray, jsize start, jsize len, jdouble* buf)

        jint (*RegisterNatives)(JNIEnv*, jclass, const JNINativeMethod* methods, jint nMethods)
        jint (*UnregisterNatives)(JNIEnv*, jclass)

        jint (*MonitorEnter)(JNIEnv*, jobject)
        jint (*MonitorExit)(JNIEnv*, jobject)

        jint (*GetJavaVM)(JNIEnv*, JavaVM**)

        void (*GetStringRegion)(JNIEnv*, jstring, jsize start, jsize len, jchar* buf)
        void (*GetStringUTFRegion)(JNIEnv*, jstring, jsize start, jsize len, char* buf)

        void* (*GetPrimitiveArrayCritical)(JNIEnv*, jarray, jboolean* isCopy)
        void (*ReleasePrimitiveArrayCritical)(JNIEnv*, jarray, void* carray, jint mode)

        const jchar* (*GetStringCritical)(JNIEnv*, jstring, jboolean* isCopy)
        void (*ReleaseStringCritical)(JNIEnv*, jstring, const jchar* carray)

        jweak (*NewWeakGlobalRef)(JNIEnv*, jobject)
        void (*DeleteWeakGlobalRef)(JNIEnv*, jweak)

        jboolean (*ExceptionCheck)(JNIEnv*)

        jobject (*NewDirectByteBuffer)(JNIEnv*, void* address, jlong capacity)
        void* (*GetDirectBufferAddress)(JNIEnv*, jobject)
        jlong (*GetDirectBufferCapacity)(JNIEnv*, jobject)
        

    struct JNIEnv_:
        JNINativeInterface_* functions

    ctypedef struct JavaVMOption:
        char* optionString
        void* extraInfo

    ctypedef struct JavaVMInitArgs:
        jint version
        jint nOptions
        JavaVMOption* options
        jboolean ignoreUnrecognized

    ctypedef struct JavaVMAttachArgs:
        jint version
        char* name
        jobject group


    ctypedef const JNIInvokeInterface_ *JavaVM
    ctypedef JNINativeInterface_ *JNIEnv
    

  #  void* JNI_GetDefaultJavaVMInitArgs(void* args)
  #  jint JNI_CreateJavaVM(JavaVM** pvm, JNIEnv** env, void* args)
  #  jint JNI_CreateJavaVM(JavaVM** pvm, JNIEnv** env, void*)
  #  jint JNI_GetCreatedJavaVMs(JavaVM** vms, jsize bufLen, jsize* nVMs)

cdef extern from "jni_helpers.h":
    ctypedef jint (*JNI_CreateJavaVM_t)(JavaVM** pvm, JNIEnv** env, void* args)
    ctypedef jint (*JNI_GetCreatedJavaVMs_t)(JavaVM** vms, jsize bufLen, jsize* nVMs)

    ctypedef enum JVM_SIGNATURE:
            JVM_SIGNATURE_BOOLEAN
            JVM_SIGNATURE_BYTE
            JVM_SIGNATURE_CHAR
            JVM_SIGNATURE_SHORT
            JVM_SIGNATURE_INT
            JVM_SIGNATURE_LONG
            JVM_SIGNATURE_FLOAT
            JVM_SIGNATURE_DOUBLE
            JVM_SIGNATURE_VOID
            JVM_SIGNATURE_CLASS
            JVM_SIGNATURE_ARRAY
            JVM_SIGNATURE_ENDCLASS
            JVM_SIGNATURE_FUNC
            JVM_SIGNATURE_ENDFUNC