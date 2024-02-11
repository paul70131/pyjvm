from pyjvm.c.jni cimport JNI_GetCreatedJavaVMs_t, JNI_CreateJavaVM_t, jint, jsize, JavaVMInitArgs, JNI_VERSION_1_2, JavaVMOption
from pyjvm.c.jni cimport jsize, jbyte, jclass, jobject, jvalue, jmethodID, JNINativeMethod, jarray, jlong, jstring, jboolean, jchar, jshort, jfloat, jdouble
from pyjvm.c.windows cimport HMODULE, GetModuleHandleA, GetProcAddress, LoadLibraryA
from pyjvm.c.jvmti cimport JVMTI_VERSION_1_2, jvmtiError, jvmtiEnv, jvmtiPhase, JVMTI_PHASE_DEAD, JVMTI_PHASE_ONLOAD, JVMTI_PHASE_PRIMORDIAL, jvmtiCapabilities

from pyjvm.exceptions.exception import JniException, JvmtiException
from pyjvm.exceptions.exception cimport JvmExceptionPropagateIfThrown

from pyjvm.types.clazz.special.jvmexception import JvmException
from pyjvm.types.clazz.jvmclass cimport JvmClassFromJclass, JvmClass, JvmObjectFromJobject
from pyjvm.types.array.jvmarray cimport CreateJvmArray
from libc.string cimport memset
from cpython.ref cimport PyObject, Py_INCREF, Py_DECREF
from pyjvm.types.converter.typeconverter cimport convert_to_object

from libc.stdlib cimport malloc, free


import os
import sys
import time
import threading
import faulthandler




cdef Jvm __instance = None

cdef jobject __invoke_override(Jvm jvm, int override_id, object args):

    cdef JvmMethodLink link = jvm.links[override_id]
    
    return link.invoke(jvm, args)

cdef extern jobject PyjvmBridge__call_override(JNIEnv* jni, jclass cls, jarray args) nogil:
    with gil:
        jvm = Jvm.acquire()
        array = CreateJvmArray(jvm, args, b"[Ljava/lang/Object;")
        override_id = array[0].intValue()
        return __invoke_override(jvm, override_id, array)

cdef extern void PyjvmPyRefHolder__incref(JNIEnv* jni, jobject this, jlong ptr) nogil:
    with gil:
        Py_INCREF(<object><PyObject*>ptr)

cdef extern void PyjvmPyRefHolder__decref(JNIEnv* jni, jobject this, jlong ptr) nogil:
    with gil:
        Py_DECREF(<object><PyObject*>ptr)

cdef extern jobject PyjvmPyObject__getAttr(JNIEnv* jni, jobject this, jstring name) nogil:
    cdef void* ref = NULL
    cdef jobject obj_ref = NULL

    with gil:
        jvm = Jvm.acquire()
        j_this = JvmObjectFromJobject(<unsigned long long>this, jvm)
        ref = <void*><unsigned long long>j_this._ref

        self = <object>ref

        j_name = JvmObjectFromJobject(<unsigned long long>name, jvm)
        py_name = str(j_name)
        PyObject = jvm.findClass('pyjvm/bridge/java/PyObject')
        py_attr = getattr(self, py_name)
        jobj = PyObject(<unsigned long long><void*>py_attr)
        obj_ref = <jobject><unsigned long long>jobj._jobject
        obj_ref = jni[0].NewLocalRef(jni, obj_ref)
        _ = py_attr # keep a reference to the object
        _ = jobj
        return obj_ref

cdef extern jint PyjvmPyObject__toInt(JNIEnv* jni, jobject this) nogil:
    cdef void* ref = NULL

    with gil:
        jvm = Jvm.acquire()
        j_this = JvmObjectFromJobject(<unsigned long long>this, jvm)
        ref = <void*><unsigned long long>j_this._ref

        self = <object>ref
        return <int>self

cdef extern jlong PyjvmPyObject__toLong(JNIEnv* jni, jobject this) nogil:
    cdef void* ref = NULL

    with gil:
        jvm = Jvm.acquire()
        j_this = JvmObjectFromJobject(<unsigned long long>this, jvm)
        ref = <void*><unsigned long long>j_this._ref

        self = <object>ref
        return <long long>self

cdef extern jdouble PyjvmPyObject__toDouble(JNIEnv* jni, jobject this) nogil:
    cdef void* ref = NULL

    with gil:
        jvm = Jvm.acquire()
        j_this = JvmObjectFromJobject(<unsigned long long>this, jvm)
        ref = <void*><unsigned long long>j_this._ref

        self = <object>ref
        return <double>self

cdef extern jboolean PyjvmPyObject__toBoolean(JNIEnv* jni, jobject this) nogil:
    cdef void* ref = NULL

    with gil:
        jvm = Jvm.acquire()
        j_this = JvmObjectFromJobject(<unsigned long long>this, jvm)
        ref = <void*><unsigned long long>j_this._ref

        self = <object>ref
        return bool(self)

cdef extern jfloat PyjvmPyObject__toFloat(JNIEnv* jni, jobject this) nogil:
    cdef void* ref = NULL

    with gil:
        jvm = Jvm.acquire()
        j_this = JvmObjectFromJobject(<unsigned long long>this, jvm)
        ref = <void*><unsigned long long>j_this._ref

        self = <object>ref
        return <float>self

cdef extern jshort PyjvmPyObject__toShort(JNIEnv* jni, jobject this) nogil:
    cdef void* ref = NULL

    with gil:
        jvm = Jvm.acquire()
        j_this = JvmObjectFromJobject(<unsigned long long>this, jvm)
        ref = <void*><unsigned long long>j_this._ref

        self = <object>ref
        return <short>self

cdef extern jbyte PyjvmPyObject__toByte(JNIEnv* jni, jobject this) nogil:
    cdef void* ref = NULL

    with gil:
        jvm = Jvm.acquire()
        j_this = JvmObjectFromJobject(<unsigned long long>this, jvm)
        ref = <void*><unsigned long long>j_this._ref

        self = <object>ref
        return <unsigned char>self

cdef extern jchar PyjvmPyObject__toChar(JNIEnv* jni, jobject this) nogil:
    cdef void* ref = NULL

    with gil:
        jvm = Jvm.acquire()
        j_this = JvmObjectFromJobject(<unsigned long long>this, jvm)
        ref = <void*><unsigned long long>j_this._ref

        self = <object>ref
        return ord(self)

cdef extern jstring PyjvmPyObject__toString(JNIEnv* jni, jobject this) nogil:
    cdef void* ref = NULL
    cdef jobject obj_ref = NULL

    with gil:
        jvm = Jvm.acquire()
        j_this = JvmObjectFromJobject(<unsigned long long>this, jvm)
        ref = <void*><unsigned long long>j_this._ref

        self = <object>ref
        javaLangString = jvm.findClass("java/lang/String")
        string = javaLangString(str(self))
        obj_ref = <jobject><unsigned long long>string._jobject
        obj_ref = jni[0].NewLocalRef(jni, obj_ref)
        return obj_ref

cdef class Jvm:
    #cdef JavaVM* jvm
    #cdef JNIEnv* jni
    #cdef jvmtiEnv* jvmti
    #cdef public dict __classes
    #cdef list[JvmMethodLink] links
    #cdef dict[int, unsigned long long] envs


    cpdef JvmMethodLink newMethodLink(self, object method, JvmMethodSignature signature):
        cdef JvmMethodLink link = JvmMethodLink(len(self.links), method, signature)
        self.links.append(link)
        return link

    cdef JNIEnv* getEnv(self) except NULL:
        tid = threading.get_native_id()
        if tid in self.envs:
            return <JNIEnv*><unsigned long long>self.envs[tid]
        else:
            return self.initNewEnv()
    
    cdef JNIEnv* initNewEnv(self) except NULL:
        cdef JNIEnv* jni
        cdef jint err
        cdef JavaVM* jvm = self.jvm
        cdef jint version = JNI_VERSION_1_2
        cdef JNIEnv* env = NULL

        err = jvm[0].AttachCurrentThread(jvm, <void**>&env, NULL)
        if err != 0:
            raise JniException(err, "Could not attach to Java VM")

        self.envs[threading.get_native_id()] = <unsigned long long>env
        return env


    def __cinit__(self):
        global __instance
        __instance = self
        self.jvm = NULL
        self.jvmti = NULL
        self.__classes = {}
        self.bridge_loaded = False
        self.links = []
        self._export_generated_classes = False
        self.envs = {}

    @staticmethod
    def acquire() -> Jvm:
        cdef Jvm jvm = None
        global __instance
        if __instance == None:
            try:
                jvm = Jvm.attach()
                return jvm

            except Exception as e:
                jvm = Jvm.create()
                jvm.ensure_started()
                return jvm
        else:
            return __instance

    def ensure_started(self):
        cdef jvmtiPhase phase
        cdef jvmtiError err


        err = self.jvmti[0].GetPhase(self.jvmti, &phase)
        if err != 0:
            raise JniException(err, "Could not get JVMTI phase")

        if phase == JVMTI_PHASE_DEAD:
            raise JniException(0, "JVM is dead")
        
        while phase == JVMTI_PHASE_ONLOAD or phase == JVMTI_PHASE_PRIMORDIAL:
            time.sleep(0)
            err = self.jvmti[0].GetPhase(self.jvmti, &phase)

            if err != 0:
                raise JniException(err, "Could not get JVMTI phase")

        return

    cpdef void raiseException(self, object jvmObject):
        cdef JNIEnv* jni = self.getEnv()
        cdef jobject jobj = <jobject><unsigned long long>jvmObject._jobject
        cdef jobject new_ref = jni[0].NewLocalRef(jni, jobj)
        _ = jobj
        jni[0].Throw(jni, new_ref)

    @staticmethod
    def create(**kwargs) -> Jvm:
        cdef Jvm result = None
        cdef JavaVM* jvm
        cdef JNIEnv* jni
        cdef jvmtiEnv* jvmti
        cdef jint err = 0
        cdef jsize nVMs = 0
        cdef JavaVMInitArgs args
        cdef JavaVMOption* options = <JavaVMOption*>malloc(sizeof(JavaVMOption) * len(kwargs))
        opts = []

        for i, (key, value) in enumerate(kwargs.items()):
            if not value:
                opt = f"-{key}".encode("utf-8")
            else:
                opt = f"-D{key}={value}".encode("utf-8")
            opts.append(JavaVMOption())

            options[i].optionString = <char*>opt
            options[i].extraInfo = NULL

        args.version = JNI_VERSION_1_2
        args.nOptions = len(kwargs)
        args.options = options
        args.ignoreUnrecognized = 0
        
        err = _JNI_GetCreatedJavaVMs(&jvm, 1, &nVMs)
        if err != 0:
            free(options)
            raise JniException(err, "Could not get created Java VMs")
        if nVMs != 0:
            free(options)
            raise JniException(0, "Java VM already exists, use attach() instead")

        err = _JNI_CreateJavaVM(&jvm, &jni, &args)
        free(options)
        _ = opts # keep a reference to the options

        if err != 0:
            raise JniException(err, "Could not create Java VM")

        err = jvm[0].GetEnv(jvm, <void**>&jvmti, JVMTI_VERSION_1_2)

        if err != 0:
            raise JniException(err, "Could not get JVMTI environment")

        result = Jvm()
        result.jvm = jvm
        result.envs[threading.get_native_id()] = <unsigned long long>jni
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
        result.envs[threading.get_native_id()] = <unsigned long long>jni
        result.jvmti = jvmti

        __instance = result

        return result

    cdef void ensureBridgeLoaded(self) except *:
        cdef JNINativeMethod methods[1]
        cdef JNINativeMethod methods_pyRefHolder[2]
        cdef JNINativeMethod methods_pyObject[10]
        cdef jclass bridge_jclass
        cdef jint result
        cdef JNIEnv* jni = self.getEnv()


        if not self.bridge_loaded:
            self.bridge_loaded = True
            # first we load all the classes
            classes = [
                "pyjvm/bridge/java/PyjvmBridge",
                "pyjvm/bridge/java/reference/PyRefHolder",
                "pyjvm/bridge/java/reference/PyRefQueue",
                "pyjvm/bridge/java/PyObject",
                "pyjvm/bridge/java/PyDict",
                "pyjvm/bridge/java/PyList",
                "pyjvm/bridge/java/PySet",
                "pyjvm/bridge/java/PyException",
            ]
            System = self.findClass("java/lang/System")
            cl = System.getClassLoader()
            for cls in classes:
                try:
                    bridge = self.findClass(cls)
                except:
                    import pyjvm
                    base = os.path.dirname(pyjvm.__file__)

                    parts = cls.split("/")
                    name = parts[-1]
                    parts = parts[1:-1]

                    bridgePath = os.path.join(base, *parts, name + ".class")
                    
                    with open(bridgePath, "rb") as f:
                        bytecode = f.read()
                        bridge = self.loadClass(bytecode, cl)
                
            methods[0].name = "call_override"
            methods[0].signature = "([Ljava/lang/Object;)Ljava/lang/Object;"
            methods[0].fnPtr = <void*>PyjvmBridge__call_override

            bridge = self.findClass("pyjvm/bridge/java/PyjvmBridge")
            bridge_jclass = <jclass><unsigned long long>bridge._jclass
        
            result = jni[0].RegisterNatives(jni, bridge_jclass, methods, 1)
            JvmExceptionPropagateIfThrown(self)
            if result != 0:
                raise Exception("Could not register native methods", result)

            methods_pyRefHolder[0].name = "_incref"
            methods_pyRefHolder[0].signature = "(J)V"
            methods_pyRefHolder[0].fnPtr = <void*>PyjvmPyRefHolder__incref
            methods_pyRefHolder[1].name = "_decref"
            methods_pyRefHolder[1].signature = "(J)V"
            methods_pyRefHolder[1].fnPtr = <void*>PyjvmPyRefHolder__decref

            bridge = self.findClass("pyjvm/bridge/java/reference/PyRefHolder")
            bridge_jclass = <jclass><unsigned long long>bridge._jclass

            result = jni[0].RegisterNatives(jni, bridge_jclass, methods_pyRefHolder, 2)
            JvmExceptionPropagateIfThrown(self)
            if result != 0:
                raise Exception("Could not register native methods", result)

            methods_pyObject[0].name = "getAttr"
            methods_pyObject[0].signature = "(Ljava/lang/String;)Lpyjvm/bridge/java/PyObject;"
            methods_pyObject[0].fnPtr = <void*>PyjvmPyObject__getAttr
            methods_pyObject[1].name = "toInt"
            methods_pyObject[1].signature = "()I"
            methods_pyObject[1].fnPtr = <void*>PyjvmPyObject__toInt
            methods_pyObject[2].name = "toLong"
            methods_pyObject[2].signature = "()J"
            methods_pyObject[2].fnPtr = <void*>PyjvmPyObject__toLong
            methods_pyObject[3].name = "toDouble"
            methods_pyObject[3].signature = "()D"
            methods_pyObject[3].fnPtr = <void*>PyjvmPyObject__toDouble
            methods_pyObject[4].name = "toBoolean"
            methods_pyObject[4].signature = "()Z"
            methods_pyObject[4].fnPtr = <void*>PyjvmPyObject__toBoolean
            methods_pyObject[5].name = "toFloat"
            methods_pyObject[5].signature = "()F"
            methods_pyObject[5].fnPtr = <void*>PyjvmPyObject__toFloat
            methods_pyObject[6].name = "toShort"
            methods_pyObject[6].signature = "()S"
            methods_pyObject[6].fnPtr = <void*>PyjvmPyObject__toShort
            methods_pyObject[7].name = "toByte"
            methods_pyObject[7].signature = "()B"
            methods_pyObject[7].fnPtr = <void*>PyjvmPyObject__toByte
            methods_pyObject[8].name = "toChar"
            methods_pyObject[8].signature = "()C"
            methods_pyObject[8].fnPtr = <void*>PyjvmPyObject__toChar
            methods_pyObject[9].name = "toString"
            methods_pyObject[9].signature = "()Ljava/lang/String;"
            methods_pyObject[9].fnPtr = <void*>PyjvmPyObject__toString

            bridge = self.findClass("pyjvm/bridge/java/PyObject")
            bridge_jclass = <jclass><unsigned long long>bridge._jclass


            result = jni[0].RegisterNatives(jni, bridge_jclass, methods_pyObject, 10)

            JvmExceptionPropagateIfThrown(self)
            if result != 0:
                raise Exception("Could not register native methods", result)
            



    cpdef object findClass(self, str name):
        cdef JNIEnv* jni = self.getEnv()

        if name in self.__classes:
            return self.__classes[name]
        

    
        cdef jclass cls = jni[0].FindClass(jni, name.encode("utf-8"))
        JvmExceptionPropagateIfThrown(self)

        return JvmClassFromJclass(<unsigned long long>cls, self)


    def destroy(self):
        self.jvm[0].DestroyJavaVM(self.jvm)

    def loadClass(self, bytes bytecode, object loader=None, bint resolve=True):
        # classfile is a file-like object opened in binary mode
        cdef jsize length = len(bytecode)
        cdef jvmtiError err
        cdef jint status = 0
        cdef jobject jloader = NULL
        cdef jobject junsafe = NULL
        cdef jmethodID ensureClassInitialized = NULL
        cdef jvalue args[1]
        cdef JNIEnv* jni = self.getEnv()

        if loader != None:
            jloader = <jobject><unsigned long long>loader._jobject

        cdef jclass cls = jni[0].DefineClass(jni, NULL, jloader, <const jbyte*>bytecode, length)
        JvmExceptionPropagateIfThrown(self)

        if cls == NULL:
            raise JniException(<unsigned long long>cls, "Failed to DefineClass")

        err = self.jvmti[0].GetClassStatus(self.jvmti, cls, &status)
        if err != 0:
            raise JniException(err, "Could not get class status")

        if status < 2:
            unsafe = self.findClass("sun/misc/Unsafe")
            theUnsafe = unsafe.theUnsafe
            ensureClassInitialized = <jmethodID><unsigned long long>theUnsafe.ensureClassInitialized.method_id

            junsafe = <jobject><unsigned long long>theUnsafe._jobject

            args[0].l = cls
            jni[0].CallObjectMethodA(jni, junsafe, ensureClassInitialized, args)
            JvmExceptionPropagateIfThrown(self)

        if resolve:
            return JvmClassFromJclass(<unsigned long long>cls, self)
        else:
            return <unsigned long long>cls

    cpdef void ensure_capability(self, str capability) except *:
        cdef jvmtiCapabilities capas
        cdef jvmtiError error

        memset(&capas, 0, sizeof(jvmtiCapabilities))

        if capability == "can_tag_objects":
            capas.can_tag_objects = 1
        elif capability == "can_generate_field_modification_events":
            capas.can_generate_field_modification_events = 1
        elif capability == "can_generate_field_access_events" :
            capas.can_generate_field_access_events = 1
        elif capability == "can_get_bytecodes":
            capas.can_get_bytecodes = 1
        elif capability == "can_get_synthetic_attribute":
            capas.can_get_synthetic_attribute = 1
        elif capability == "can_get_owned_monitor_info":
            capas.can_get_owned_monitor_info = 1
        elif capability == "can_get_current_contended_monitor":
            capas.can_get_current_contended_monitor = 1
        elif capability == "can_get_monitor_info":
            capas.can_get_monitor_info = 1
        elif capability == "can_pop_frame":
            capas.can_pop_frame = 1
        elif capability == "can_redefine_classes":
            capas.can_redefine_classes = 1
        elif capability == "can_signal_thread":
            capas.can_signal_thread = 1
        elif capability == "can_get_source_file_name":
            capas.can_get_source_file_name = 1
        elif capability == "can_get_line_numbers":
            capas.can_get_line_numbers = 1
        elif capability == "can_get_source_debug_extension":
            capas.can_get_source_debug_extension = 1
        elif capability == "can_access_local_variables":
            capas.can_access_local_variables = 1
        elif capability == "can_maintain_original_method_order":
            capas.can_maintain_original_method_order = 1
        elif capability == "can_generate_single_step_events":
            capas.can_generate_single_step_events = 1
        elif capability == "can_generate_exception_events":
            capas.can_generate_exception_events = 1
        elif capability == "can_generate_frame_pop_events":
            capas.can_generate_frame_pop_events = 1
        elif capability == "can_generate_breakpoint_events":
            capas.can_generate_breakpoint_events = 1
        elif capability == "can_suspend":
            capas.can_suspend = 1
        elif capability == "can_redefine_any_class":
            capas.can_redefine_any_class = 1
        elif capability == "can_get_current_thread_cpu_time":
            capas.can_get_current_thread_cpu_time = 1
        elif capability == "can_get_thread_cpu_time":
            capas.can_get_thread_cpu_time = 1
        elif capability == "can_generate_method_entry_events":
            capas.can_generate_method_entry_events = 1
        elif capability == "can_generate_method_exit_events":
            capas.can_generate_method_exit_events = 1
        elif capability == "can_generate_all_class_hook_events":
            capas.can_generate_all_class_hook_events = 1
        elif capability == "can_generate_compiled_method_load_events":
            capas.can_generate_compiled_method_load_events = 1
        elif capability == "can_generate_monitor_events":
            capas.can_generate_monitor_events = 1
        elif capability == "can_generate_vm_object_alloc_events":
            capas.can_generate_vm_object_alloc_events = 1
        elif capability == "can_generate_native_method_bind_events":
            capas.can_generate_native_method_bind_events = 1
        elif capability == "can_generate_garbage_collection_events":
            capas.can_generate_garbage_collection_events = 1
        elif capability == "can_generate_object_free_events":
            capas.can_generate_object_free_events = 1
        elif capability == "can_force_early_return":
            capas.can_force_early_return = 1
        elif capability == "can_get_owned_monitor_stack_depth_info":
            capas.can_get_owned_monitor_stack_depth_info = 1
        elif capability == "can_get_constant_pool":
            capas.can_get_constant_pool = 1
        elif capability == "can_set_native_method_prefix":
            capas.can_set_native_method_prefix = 1
        elif capability == "can_retransform_classes":
            capas.can_retransform_classes = 1
        elif capability == "can_retransform_any_class":
            capas.can_retransform_any_class = 1
        elif capability == "can_generate_resource_exhaustion_heap_events":
            capas.can_generate_resource_exhaustion_heap_events = 1
        elif capability == "can_generate_resource_exhaustion_threads_events":
            capas.can_generate_resource_exhaustion_threads_events = 1
        else:
            raise Exception("Unknown capability: " + capability)
        
        error = self.jvmti[0].AddCapabilities(self.jvmti, &capas)
        if error != 0:
            raise JvmtiException(error, "Could not add capability")

    






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