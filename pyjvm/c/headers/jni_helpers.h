typedef jint (*JNI_CreateJavaVM_t)(JavaVM **pvm, void **penv, void *args);
typedef jint (*JNI_GetCreatedJavaVMs_t)(JavaVM **pvm, jsize bufLen, jsize *nVMs);
typedef jint (*JNI_DestroyJavaVM_t)(JavaVM *vm);



enum JVM_SIGNATURE {
    JVM_SIGNATURE_BOOLEAN = 'Z',
    JVM_SIGNATURE_BYTE = 'B',
    JVM_SIGNATURE_CHAR = 'C',
    JVM_SIGNATURE_SHORT = 'S',
    JVM_SIGNATURE_INT = 'I',
    JVM_SIGNATURE_LONG = 'J',
    JVM_SIGNATURE_FLOAT = 'F',
    JVM_SIGNATURE_DOUBLE = 'D',
    JVM_SIGNATURE_VOID = 'V',
    JVM_SIGNATURE_CLASS = 'L',
    JVM_SIGNATURE_ARRAY = '[',
    JVM_SIGNATURE_ENDCLASS = ';',
    JVM_SIGNATURE_FUNC = '(',
    JVM_SIGNATURE_ENDFUNC = ')',
};