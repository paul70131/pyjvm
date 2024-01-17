from pyjvm.types.clazz.jvmclass cimport JvmClass
from pyjvm.jvm cimport Jvm
from pyjvm.types.clazz.jvmclass cimport JvmClassFromJclass

from pyjvm.c.jni cimport jfieldID, jint, jclass, jmethodID
from pyjvm.c.jvmti cimport jvmtiEnv

cdef class JvmMethod:
#    cdef str _name
#    cdef str _signature
#    cdef int _modifiers

    @property
    def name(self):
        return self._name

    @property
    def signature(self):
        return self._signature

    @property
    def clazz(self):
        return self._clazz

    @property
    def abstract(self):
        return self._modifiers & 0x0400 != 0

    @property
    def final(self):
        return self._modifiers & 0x0010 != 0

    @property
    def private(self):
        return self._modifiers & 0x0002 != 0
    
    @property
    def protected(self):
        return self._modifiers & 0x0004 != 0
    
    @property
    def public(self):
        return self._modifiers & 0x0001 != 0

    @property
    def static(self):
        return self._modifiers & 0x0008 != 0

    def __call__(self, object instance, *args, **kwargs):
        if args or kwargs:
            raise NotImplementedError("Method invocation with arguments is not yet implemented")
        
        cdef Jvm jvm = self._clazz.jvm
        

    def __repr__(self):
        name = ""
        if self.public:
            name += "public "
        elif self.protected:
            name += "protected "
        elif self.private:
            name += "private "
        if self.static:
            name += "static "
        if self.final:
            name += "final "
        if self.abstract:
            name += "abstract "
        name += self._signature + " " + self._name
        return name
    
    def __init__(self, str name, str signature, int modifiers, object clazz):
        self._name = name
        self._signature = signature
        self._modifiers = modifiers
        self._clazz = clazz

cdef JvmMethodFromJmethodID(jmethodID mid, jclass cid, object clazz):
    cdef Jvm jvm = clazz.jvm
    cdef jvmtiEnv* jvmti = jvm.jvmti

    cdef char* name
    cdef char* signature

    cdef jint modifiers
    cdef jint error

    error = jvmti[0].GetMethodName(jvmti, mid, &name, &signature, NULL)
    if error != 0:
        raise Exception("Failed to get field name")

    error = jvmti[0].GetMethodModifiers(jvmti, mid, &modifiers)
    if error != 0:
        raise Exception("Failed to get field modifiers")

    
    py_name = name.decode("utf-8")
    py_signature = signature.decode("utf-8")
    
    error = jvmti[0].Deallocate(jvmti, <unsigned char*>name)
    if error != 0:
        raise Exception("Failed to deallocate field name")
    
    error = jvmti[0].Deallocate(jvmti, <unsigned char*>signature)
    if error != 0:
        raise Exception("Failed to deallocate field signature")

    return JvmMethod(py_name, py_signature, modifiers, clazz)




