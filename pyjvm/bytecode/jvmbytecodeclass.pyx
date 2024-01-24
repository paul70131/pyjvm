#from pyjvm.types.clazz.jvmclass cimport JvmClass
from pyjvm.c.jni cimport jclass, JNIEnv, jint
from pyjvm.c.jvmti cimport jvmtiEnv, jvmtiError
from pyjvm.jvm cimport Jvm

from pyjvm.exceptions.exception import JvmtiException

cdef class JvmBytecodeClass:
    #cdef object klass

    def __init__(self, object klass):
        self.klass = klass

        self.parse_version()
        self.parse_cp()
        self.parse_version()
        self.parse_this_super()
        # interfaces are not supported yet
        self.parse_interfaces()
        self.parse_fields()


    def parse_fields(self):
        cdef jclass cls = <jclass><unsigned long long>self.klass._jclass

        self.fields = JvmBytecodeFields()
        for field in self.klass.getFields(inherited=False).values():
            self.fields.add(field, self.klass.jvm, jclass, self.constant_pool)

    def parse_methods(self):
        self.methods = JvmBytecodeMethods()
    
    def parse_interfaces(self):
        self.interfaces = JvmBytecodeInterfaces()
        
    
    def parse_this_super(self):
        this = self.constant_pool.find_class(self.klass.__name__)
        super_ = None
        if self.klass.__base__.is_java():
            super_ = self.constant_pool.find_class(self.klass.__base__.__name__)
        
        self.this_class = this.offset
        self.super_class = super_.offset if super_ is not None else 0
        

    def parse_version(self):
        cdef Jvm jvm = self.klass.jvm
        cdef JNIEnv* env = jvm.jni
        cdef jvmtiEnv* jvmti = jvm.jvmti
        cdef jclass cls = <jclass><unsigned long long>self.klass._jclass

        cdef jvmtiError err
        cdef jint flags

        err = jvmti[0].GetClassModifiers(jvmti, cls, &flags)

        if err != 0:
            raise JvmtiException(err, "Failed to get class modifiers")

        self.access_flags = flags
    

    def parse_version(self):
        cdef Jvm jvm = self.klass.jvm
        cdef JNIEnv* env = jvm.jni
        cdef jvmtiEnv* jvmti = jvm.jvmti
        cdef jclass cls = <jclass><unsigned long long>self.klass._jclass

        cdef jvmtiError err

        cdef jint major_version
        cdef jint minor_version

        err = jvmti[0].GetClassVersionNumbers(jvmti, cls, &major_version, &minor_version)
        if err != 0:
            raise JvmtiException(err, "Failed to get version numbers")
        
        self.major_version = major_version
        self.minor_version = minor_version

    def parse_cp(self):
        cdef Jvm jvm = self.klass.jvm
        cdef JNIEnv* env = jvm.jni
        cdef jvmtiEnv* jvmti = jvm.jvmti
        cdef jclass cls = <jclass><unsigned long long>self.klass._jclass

        cdef jvmtiError err
        cdef jint cp_count
        cdef jint cp_byte_count
        cdef unsigned char* cp_bytes

        jvm.ensure_capability("can_get_constant_pool")

        err = jvmti[0].GetConstantPool(jvmti, cls, &cp_count, &cp_byte_count, &cp_bytes)
        if err != 0:
            raise JvmtiException(err, "Failed to get constant pool")
        
        self.constant_pool = JvmBytecodeConstantPool()
        self.constant_pool.parse(cp_bytes, cp_count)

        err = jvmti[0].Deallocate(jvmti, cp_bytes)
        if err != 0:
            raise JvmtiException(err, "Failed to deallocate constant pool")



