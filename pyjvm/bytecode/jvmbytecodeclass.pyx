#from pyjvm.types.clazz.jvmclass cimport JvmClass
from pyjvm.c.jni cimport jclass, JNIEnv, jint
from pyjvm.c.jvmti cimport jvmtiEnv, jvmtiError
from pyjvm.jvm cimport Jvm
from libc.stdlib cimport free, malloc

from pyjvm.exceptions.exception import JvmtiException
from pyjvm.bytecode.annotations import JvmFieldAnnotation
from pyjvm.bytecode.components.jvmbytecodeattributes cimport ConstantValueAttribute
from pyjvm.types.clazz.jvmmethod cimport JvmMethod, JvmMethodSignature

cdef class JvmBytecodeClass:
    #cdef object klass

    def __init__(self):
        pass
        #self.klass = klass

        #self.parse_version()
        #self.parse_cp()
        #self.parse_version()
        #self.parse_this_super()
        # interfaces are not supported yet
        #self.parse_interfaces()
        #self.parse_fields()

        #self.parse_methods()
        #self.parse_attributes()

    @staticmethod
    def inherit(object klass, str name, attrs):

        cf = JvmBytecodeClass()

        cf.inherit_version(klass)
        cf.inherit_cp(klass)
        cf.inherit_access_flags(klass)
        cf.inherit_this_super(klass, name)
        cf.inherit_interfaces(klass)

        cf.inherit_fields(klass, attrs)
        cf.inherit_methods(klass, attrs)
        cf.inherit_attributes(klass)

        return cf

    
    def inherit_attributes(self, object klass):
        self.attributes = JvmBytecodeAttributes()

        # InnerClasses - NOT SUPPORTED
        # EnclosingMethod - NOT SUPPORTED
        # Synthetic - NOT SUPPORTED
        # Signature - NOT SUPPORTED (maybe in the future to support generics)
        # SourceFile - NOT SUPPORTED (maybe in the future)
        # SourceDebugExtension - NOT SUPPORTED
        # Deprecated - NOT SUPPORTED (maybe in the future)
        # RuntimeVisibleAnnotations - NOT SUPPORTED
        # RuntimeInvisibleAnnotations - NOT SUPPORTED
        # BootstrapMethods - NOT SUPPORTED


    def add_method(self, object func, object klass, bint override, Jvm jvm):
        cdef JvmMethodSignature descriptor
        cdef JvmMethod to_override
        cdef bint call_super = False
        if not override:
            descriptor = JvmMethodSignature(getattr(func, "__jsignature"))
            access_flags = 0x0001
            name = func.__name__
            if name == "__init__":
                name = "<init>"

            self.methods.add_new(self.constant_pool, access_flags, name, descriptor, jvm, func, klass)

            return


        if override:
            methods = klass.getMethods()
            if not func.__name__ in methods:
                raise TypeError(f"Method {func.__name__} not found in {klass}")

            to_override = methods[func.__name__]
            if len(to_override._overloads) != 1:
                raise TypeError(f"Cannot override overloaded methods yet")

            access_flags = to_override._modifiers
            name = to_override._name
            descriptor = to_override._overloads[0].signature

            self.methods.add_new(self.constant_pool, access_flags, name, descriptor, jvm, func, klass)


            return

        raise NotImplementedError("Can only override ATM")


    def inherit_methods(self, object klass, attrs):
        cdef Jvm jvm = klass.jvm
        self.methods = JvmBytecodeMethods()

        # TODO: inherit methods, this will be a bit more complicated since we need to check for overrides, create bytecode, call natives, etc.
        # this will be quite a bit of work, but it will be worth it since it will allow us to create classes from python code which are fully functional

        funcs = [func for func in attrs.values() if callable(func)]

        if len(funcs) != 0:
            jvm.ensureBridgeLoaded()

        for func in funcs:
            self.add_method(func, klass, hasattr(func, '__joverride'), jvm)

    

    def add_field(self, str name, str signature, bint static, object default):
        if not static and default:
            raise TypeError("Non static field cannot have default value")
        
        if default and signature not in ConstantValueAttribute.signatures:
            raise TypeError(f"Signature of Fields with default value must be one of {ConstantValueAttribute.signatures} - {signature}")

        
        self.fields.add_new(self.constant_pool, name, signature, static, True, default)

    
    def inherit_fields(self, object klass, attrs):
        self.fields = JvmBytecodeFields()

        if "__annotations__" not in attrs:
            return

        for name, anno in attrs['__annotations__'].items():
            if isinstance(anno, JvmFieldAnnotation):
                self.add_field(name, anno.signature, anno.static, attrs.get(name, None))
            



    def inherit_interfaces(self, object klass):
        self.interfaces = JvmBytecodeInterfaces()
    
    def inherit_version(self, object klass):
        cdef Jvm jvm = klass.jvm
        cdef JNIEnv* env = jvm.jni
        cdef jvmtiEnv* jvmti = jvm.jvmti
        cdef jclass cls = <jclass><unsigned long long>klass._jclass

        cdef jvmtiError err

        cdef jint major_version
        cdef jint minor_version

        err = jvmti[0].GetClassVersionNumbers(jvmti, cls, &major_version, &minor_version)
        if err != 0:
            raise JvmtiException(err, "Failed to get version numbers")
        
        self.major_version = major_version
        self.minor_version = minor_version

    def inherit_cp(self, object klass):
        self.constant_pool = JvmBytecodeConstantPool()
        
    def inherit_access_flags(self, object klass):
        cdef Jvm jvm = klass.jvm
        cdef JNIEnv* env = jvm.jni
        cdef jvmtiEnv* jvmti = jvm.jvmti
        cdef jclass cls = <jclass><unsigned long long>klass._jclass

        cdef jvmtiError err
        cdef jint flags

        err = jvmti[0].GetClassModifiers(jvmti, cls, &flags)

        if err != 0:
            raise JvmtiException(err, "Failed to get class modifiers")

        self.access_flags = flags
    
        
    def inherit_this_super(self, object klass, str name):
        this = self.constant_pool.find_class(name, True)
        super_ = self.constant_pool.find_class(klass.__name__, True)
        
        self.this_class = this.offset
        self.super_class = super_.offset if super_ is not None else 0

    cdef unsigned int size(self):
        return 8 + self.constant_pool.size() + 6 + self.interfaces.size() + self.fields.size() + self.methods.size() + self.attributes.size()

    
    def insert(self, Jvm jvm, object loader=None, name=None):
        cdef unsigned char* bytecode = self.generate()

        if not name:
            name = "jvmclass-" + id(self).__str__()

        if getattr(jvm, "_export_generated_classes", False):

            path = getattr(jvm, "_export_generated_classes", ".")
            if not isinstance(path, str):
                path = "."
            path = path + "/"
            with open(f"{path}{name}.class", "wb") as f:
                f.write(bytecode[:self.size()])

        c = jvm.loadClass(bytecode[:self.size()], loader)

        free(bytecode)

        return c
    

    cdef unsigned char* generate(self) except NULL:
        cdef unsigned int offset = 0
        cdef unsigned int size = self.size()
        cdef unsigned char* bytecode# = <unsigned char*>malloc(8)

        bytecode = <unsigned char*>malloc(size)
        if bytecode == NULL:
            raise MemoryError("Failed to allocate memory for bytecode")

        try:

            bytecode[0] = 0xCA
            bytecode[1] = 0xFE
            bytecode[2] = 0xBA
            bytecode[3] = 0xBE

            bytecode[4] = (self.major_version >> 8) & 0xFF
            bytecode[5] = self.major_version & 0xFF

            bytecode[6] = (self.minor_version >> 8) & 0xFF
            bytecode[7] = self.minor_version & 0xFF

            offset += 8

            offset += self.constant_pool.render(bytecode + offset)

            bytecode[offset] = (self.access_flags >> 8) & 0xFF
            bytecode[offset + 1] = self.access_flags & 0xFF

            bytecode[offset + 2] = (self.this_class >> 8) & 0xFF
            bytecode[offset + 3] = self.this_class & 0xFF

            bytecode[offset + 4] = (self.super_class >> 8) & 0xFF
            bytecode[offset + 5] = self.super_class & 0xFF

            offset += 6

            offset += self.interfaces.render(bytecode + offset)
            offset += self.fields.render(bytecode + offset)
            offset += self.methods.render(bytecode + offset)
            offset += self.attributes.render(bytecode + offset)

            if offset != size:
                raise RuntimeError("Bytecode size mismatch", offset, size)

            

        except:
            free(bytecode)
            raise
        
        return bytecode
        