from pyjvm.c.jni cimport jclass, jint, JNIEnv, jmethodID, jfieldID, jobject, jvalue
from pyjvm.jvm cimport Jvm
from pyjvm.c.jvmti cimport JVMTI_ERROR_NONE, jvmtiEnv, jvmtiError

from pyjvm.types.clazz.jvmfield cimport JvmFieldFromJfieldID, JvmField
from pyjvm.types.clazz.jvmmethod cimport JvmMethodFromJmethodID, JvmMethod
from pyjvm.types.object.jvmboundfield cimport JvmBoundField
from pyjvm.types.object.jvmboundmethod cimport JvmBoundMethod

from pyjvm.types.clazz.special.jvmstring cimport JvmString
from pyjvm.types.clazz.special.jvmenum cimport JvmEnum
from pyjvm.types.clazz.special.jvmexception import JvmException

from pyjvm.exceptions.exception cimport JvmExceptionPropagateIfThrown
from pyjvm.types.clazz.jvmmethod cimport JvmMethodReference
from pyjvm.bytecode.jvmbytecodeclass cimport JvmBytecodeClass

from libc.stdlib cimport free

cdef class JvmClass:

    @staticmethod
    def is_java():
        return False

    @property
    def _jobject(self):
        return <unsigned long long>self._jobject

    def from_cid(self, unsigned long long cid):
        cdef jclass jcid = <jclass>cid
        cdef Jvm jvm = <Jvm>self.__class__.jvm
        cdef JNIEnv* jni = jvm.jni

        self._jobject = jni[0].NewGlobalRef(jni, jcid)
        jni[0].DeleteLocalRef(jni, jcid)

    def __init__(self, *args, unsigned long long cid = 0):
        cdef jobject ret
        cdef Jvm jvm = <Jvm>self.__class__.jvm
        cdef JNIEnv* jni = jvm.jni
        cdef jclass class_id = <jclass><unsigned long long>self.__class__._jclass
        cdef JvmMethod constructor
        cdef jvalue* jargs
        cdef jmethodID mid
        cdef JvmMethodReference overload

        if cid != 0:
            self.from_cid(cid)
            return
        
        constructor = getattr(self, "<init>", None)

        for overload in constructor._overloads:
            jargs = overload.signature.convert(args, jvm)
            if jargs == NULL:
                continue

            _, ret_type = overload.signature.parse()

            mid = overload._method_id

            ret = jni[0].NewObjectA(jni, class_id, mid, jargs)
            JvmExceptionPropagateIfThrown(jvm)
            self.from_cid(<unsigned long long>ret)

            free(jargs)

            return
        

        raise TypeError(f"no constructor found for {self.__class__.__name__} with args {args}", constructor)



    def __del__(self):
        cdef Jvm jvm = <Jvm>self.__class__.jvm
        cdef JNIEnv* jni = jvm.jni

        if self._jobject != NULL:
            jni[0].DeleteGlobalRef(jni, self._jobject)

    def __str__(self):
        return str(self.toString())
    
    def __repr__(self):
        return repr(self.toString())

    def __eq__(self, other):
        if isinstance(other, JvmClass):
            return self.equals(other)
        return False

    def __dir__(self):
        if not self.__class__._loaded:
            self.__class__.load()
        members = {**self.__class__._fields, **self.__class__._methods}
        return [m.name for m in members.values() if not m.static]

    def __getattr__(self, name):
        cls = self.__class__
        attr = None
        while cls and not attr:
            if not cls._loaded:
                cls.load()
            attr = cls._fields.get(name, None)
            if not attr or attr.static:
                attr = cls._methods.get(name, None)
            
            if attr and attr.static:
                attr = None

            cls = cls.__base__ if isinstance(cls.__base__, JvmClassMeta) else None

        if not attr or attr.static:
            raise AttributeError(f"{'t'} has no attribute {name}")
        
        if isinstance(attr, JvmField):
            return JvmBoundField(attr, self).get()
        
        if isinstance(attr, JvmMethod):
            if attr.name == "<init>":
                return attr
            return JvmBoundMethod(attr, self)

        return attr


class JvmClassMeta(type):
    members = ["_jclass", "signature", "jvm", "_fields", "_methods", "_loaded", "_interfaces"]
    _special_ancestors = {
        "java.lang.String": JvmString,
        "java.lang.Enum": JvmEnum,
    }

    def __del__(self):
        cdef Jvm jvm = <Jvm>self.jvm
        cdef JNIEnv* jni = jvm.jni
        jni[0].DeleteGlobalRef(jni, <jobject><unsigned long long>self._jclass)

    def __new__(cls, name, bases, attrs):
        if '_jclass' not in attrs:
            attrs["__skip__init__"] = True
            return cls.__inherit(name, bases, attrs)
        return super().__new__(cls, name, bases, attrs)

    def is_java(cls):
        return True

    def getClassLoader(self):
        cdef Jvm jvm = <Jvm>self.jvm
        cdef jvmtiEnv* jvmti = jvm.jvmti
        cdef jclass class_id = <jclass><unsigned long long>self._jclass
        cdef jobject loader
        cdef jvmtiError err = jvmti[0].GetClassLoader(jvmti, class_id, &loader)
        if err != JVMTI_ERROR_NONE:
            raise Exception("error getting class loader", <int>err)

        return JvmObjectFromJobject(<unsigned long long>loader, jvm)

    def __inherit(name, bases, attrs):
        if not isinstance(bases[0], JvmClassMeta):
            raise TypeError("cannot inherit from non-JvmClass")
        
        package = attrs.get("package", None)
        fullname = f"{package}.{name}" if package else name

        
        
        bytecodeClass = JvmBytecodeClass.inherit(bases[0], fullname, attrs)
        return bytecodeClass.insert(bases[0].jvm, bases[0].getClassLoader(), fullname)


    def __dir__(cls):
        if not cls._loaded:
            cls.load()
        members = {**cls._fields, **cls._methods}
        return [m.name for m in members.values() if m.static]

    
    def __init__(cls, name, bases, attrs):
        if attrs.get("__skip__init__", False):
            return
        cls._jclass = attrs['_jclass']
        cls.signature = attrs['signature']
        cls.jvm = attrs['jvm']
        cls._fields = {}
        cls._methods = {}
        cls._interfaces = attrs['interfaces']
        cls._loaded = False

        super().__init__(name, bases, {})

    def __setattr__(self, name, value):
        if name in self.members:
            super().__setattr__(name, value)
            return
        
        if not self._loaded:
            self.load()

        attr = self._fields.get(name, None)
        if not attr or not attr.static:
            raise AttributeError(f"{self.__name__} has no attribute {name}")

        if attr and isinstance(attr, JvmField): # always true
            attr.set(self, value)
        
        return



    def __getattr__(cls, name):
        if not cls._loaded:
            cls.load()

        attr = None

        attr = cls._fields.get(name, None)
        if not attr:
            attr = cls._methods.get(name, None)

        if not attr:
            attr = getattr(super(), name, None)

        if not attr or not attr.static:
            raise AttributeError(f"{cls.__name__} has no attribute {name}")
        
        
        if isinstance(attr, JvmField):
            return attr.get(cls)
            
        return attr

    def getMethods(cls, inherited=True):
        if not inherited:
            if not cls._loaded:
                cls.load()
            return cls._methods.copy()
        else:
            methods = {}
            for base in cls.__bases__:
                if isinstance(base, JvmClassMeta):
                    methods.update(base.getMethods(inherited=True))
            methods.update(cls.getMethods(inherited=False))
            return methods

    def getFields(cls, inherited=True):
        if not inherited:
            if not cls._loaded:
                cls.load()
            return cls._fields.copy()
        else:
            fields = {}
            for base in cls.__bases__:
                if isinstance(base, JvmClassMeta):
                    fields.update(base.getFields(inherited=True))
            fields.update(cls.getFields(inherited=False))
            return fields

    def load(cls):
        cdef Jvm jvm = <Jvm>cls.jvm
        cdef jvmtiEnv* jvmti = jvm.jvmti
        cdef JNIEnv* jni = jvm.jni
        cdef jint error
        cdef jclass cid = <jclass><unsigned long long>cls._jclass

        cdef jfieldID* field_ids
        cdef jmethodID* method_ids
        cdef jint count
        
        cls._fields = {}

        error = jvmti[0].GetClassFields(jvmti, cid, &count, &field_ids)
        if error != JVMTI_ERROR_NONE:
            raise Exception("error getting class fields", <int>error)

        for i in range(count):
            field = JvmFieldFromJfieldID(field_ids[i], cid, cls)
            cls._fields[field.name] = field

        error = jvmti[0].GetClassMethods(jvmti, cid, &count, &method_ids)
        if error != JVMTI_ERROR_NONE:
            raise Exception("error getting class methods", <int>error)

        for i in range(count):
            
            method = JvmMethodFromJmethodID(method_ids[i], cid, cls)
            if method.name in cls._methods:
                cls._methods[method.name].add_overload(<unsigned long long>method_ids[i])
            else:
                cls._methods[method.name] = method

        error = jvmti[0].Deallocate(jvmti, <unsigned char*>field_ids)
        if error != JVMTI_ERROR_NONE:
            raise Exception("error deallocating class fields", <int>error)

        cls._loaded = True
    
    def __call__(cls, *args, **kwargs):
        return super().__call__(*args, **kwargs)


cdef object JvmObjectFromJobject(unsigned long long jobj, Jvm jvm):
    cdef jclass cid
    cdef JNIEnv* jni = jvm.jni

    if jobj == 0:
        return None

    cid = jni[0].GetObjectClass(jni, <jobject>jobj)

    return JvmClassFromJclass(<unsigned long long>cid, jvm)(cid=jobj)

cdef object JvmClassFromJclass(unsigned long long cid, Jvm jvm, object top_base=JvmClass):
    cdef char* name
    cdef jvmtiEnv* jvmti = jvm.jvmti
    cdef JNIEnv* jni = jvm.jni
    cdef jint error
    cdef jclass superclass
    cdef jclass new_cid

    cdef jclass* interfaces
    cdef jint count
    
    py_interfaces = []


    #if cid in jvm.__classes:
    #    jni[0].DeleteLocalRef(jni, <jobject>cid)
    #    return jvm.__classes[cid]

    error = jvmti[0].GetClassSignature(jvmti, <jclass>cid, &name, NULL)
    if error != JVMTI_ERROR_NONE:
        raise Exception("error getting class signature", <int>error)

    py_signature = name.decode('utf-8')
    py_name = py_signature[1:-1].replace('/', '.')

    error = jvmti[0].Deallocate(jvmti, <unsigned char*>name)
    if error != JVMTI_ERROR_NONE:
        raise Exception("error deallocating class signature", <int>error)

    if py_name in jvm.__classes:
        jni[0].DeleteLocalRef(jni, <jobject>cid)
        return jvm.__classes[py_name]


    new_cid = jni[0].NewGlobalRef(jni, <jobject>cid)
    jni[0].DeleteLocalRef(jni, <jobject>cid)
    cid = <unsigned long long>new_cid


    error = jvmti[0].GetImplementedInterfaces(jvmti, new_cid, &count, &interfaces)
    if error != JVMTI_ERROR_NONE:
        raise Exception("error getting class interfaces", <int>error)

    
    for i in range(count):
        interface = JvmClassFromJclass(<unsigned long long>interfaces[i], jvm)
        py_interfaces.append(interface) 

    error = jvmti[0].Deallocate(jvmti, <unsigned char*>interfaces)
    if error != JVMTI_ERROR_NONE:
        raise Exception("error deallocating class interfaces", <int>error)
    

    superclass = jni[0].GetSuperclass(jni, new_cid)
    bases = (top_base,)
    if superclass != NULL:
        top_base = JvmClassMeta._special_ancestors.get(py_name, JvmClass)
        base = JvmClassFromJclass(<unsigned long long>superclass, jvm, top_base=top_base)
        bases = (base,)
    

    c = JvmClassMeta(py_name, bases, {'_jclass':cid, 'signature': py_signature, 'jvm': jvm, 'interfaces' : py_interfaces})
    jvm.__classes[cid] = c



    return c


# class JvmClass(metaclass=JvmClassMeta):