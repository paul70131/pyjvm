from pyjvm.c.jni cimport jclass, jint, JNIEnv, jmethodID, jfieldID, jobject
from pyjvm.jvm cimport Jvm
from pyjvm.c.jvmti cimport JVMTI_ERROR_NONE, jvmtiEnv

from pyjvm.types.clazz.jvmfield cimport JvmFieldFromJfieldID, JvmField
from pyjvm.types.clazz.jvmmethod cimport JvmMethodFromJmethodID
from pyjvm.types.object.jvmboundfield cimport JvmBoundField

cdef class JvmClass:
#    cdef jobject _jobject
#    cdef object _class

    def __init__(self, unsigned long long _jobject):
        self._jobject = <jobject>_jobject

    def __getattr__(self, name):
        cls = self.__class__
        if not cls._loaded:
            cls.load()
        
        attr = cls._fields.get(name, None)
        if not attr:
            attr = cls._methods.get(name, None)

        if not attr:
            attr = super().__getattribute__(name)
        
        if not attr or attr.static:
            raise AttributeError(f"{cls.__name__} has no attribute {name}")
        
        if isinstance(attr, JvmField):
            return JvmBoundField(attr, self).get()

        return attr

    

class JvmClassMeta(type):
    members = ["_jclass", "signature", "jvm", "_fields", "_methods", "_loaded"]
    def __new__(cls, name, bases, attrs):
        return super().__new__(cls, name, bases, attrs)
    
    def __init__(cls, name, bases, attrs):
        cls._jclass = attrs['_jclass']
        cls.signature = attrs['signature']
        cls.jvm = attrs['jvm']
        cls._fields = {}
        cls._methods = {}
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
            attr = super().__getattribute__(name)

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
                cls._methods[method.name].append(method)
            else:
                cls._methods[method.name] = [method,]

        error = jvmti[0].Deallocate(jvmti, <unsigned char*>field_ids)
        if error != JVMTI_ERROR_NONE:
            raise Exception("error deallocating class fields", <int>error)

        cls._loaded = True
    
    def __call__(cls, *args, **kwargs):
        return super().__call__(*args, **kwargs)


    

cdef object JvmClassFromJclass(unsigned long long cid, Jvm jvm):
    cdef char* name
    cdef jvmtiEnv* jvmti = jvm.jvmti
    cdef JNIEnv* jni = jvm.jni
    cdef jint error
    cdef jclass superclass

    error = jvmti[0].GetClassSignature(jvmti, <jclass>cid, &name, NULL)
    if error != JVMTI_ERROR_NONE:
        raise Exception("error getting class signature", <int>error)

    py_signature = name.decode('utf-8')
    py_name = py_signature[1:-1].replace('/', '.')

    superclass = jni[0].GetSuperclass(jni, <jclass>cid)
    bases = (JvmClass,)
    if superclass != NULL:
        base = JvmClassFromJclass(<unsigned long long>superclass, jvm)
        bases = (base,)

    error = jvmti[0].Deallocate(jvmti, <unsigned char*>name)
    if error != JVMTI_ERROR_NONE:
        raise Exception("error deallocating class signature", <int>error)

    return JvmClassMeta(py_name, bases, {'_jclass': <unsigned long long>cid, 'signature': py_signature, 'jvm': jvm})


# class JvmClass(metaclass=JvmClassMeta):