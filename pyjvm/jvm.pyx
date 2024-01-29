from pyjvm.c.jni cimport JNI_GetCreatedJavaVMs_t, JNI_CreateJavaVM_t, jint, jsize, JavaVMInitArgs, JNI_VERSION_1_2, JavaVMOption
from pyjvm.c.jni cimport jsize, jbyte, jclass, jobject, jvalue, jmethodID, JNINativeMethod, jarray
from pyjvm.c.windows cimport HMODULE, GetModuleHandleA, GetProcAddress, LoadLibraryA
from pyjvm.c.jvmti cimport JVMTI_VERSION_1_2, jvmtiError, jvmtiEnv, jvmtiPhase, JVMTI_PHASE_DEAD, JVMTI_PHASE_ONLOAD, JVMTI_PHASE_PRIMORDIAL, jvmtiCapabilities

from pyjvm.exceptions.exception import JniException, JvmtiException
from pyjvm.exceptions.exception cimport JvmExceptionPropagateIfThrown

from pyjvm.types.clazz.jvmclass cimport JvmClassFromJclass, JvmClass
from pyjvm.types.array.jvmarray cimport CreateJvmArray
from libc.string cimport memset

import os
import time
import faulthandler

cdef Jvm __instance = None

cdef jobject __invoke_override(Jvm jvm, int override_id, object args):

    cdef JvmMethodLink link = jvm.links[override_id]
    
    return link.invoke(jvm, args)

cdef extern jobject PyjvmBridge__call_override(JNIEnv* jni, jclass cls, jarray args) nogil:
    with gil:
        jvm = Jvm.acquire()
        array = CreateJvmArray(jvm, args, "[Ljava/lang/Object;")
        override_id = array[0].intValue()
        return __invoke_override(jvm, override_id, array)


cdef class Jvm:
    #cdef JavaVM* jvm
    #cdef JNIEnv* jni
    #cdef jvmtiEnv* jvmti
    #cdef public dict __classes
    #cdef list[JvmMethodLink] links


    cdef JvmMethodLink newMethodLink(self, object method, JvmMethodSignature signature):
        cdef JvmMethodLink link = JvmMethodLink(len(self.links), method, signature)
        self.links.append(link)
        return link

    def __cinit__(self):
        global __instance
        __instance = self
        self.jvm = NULL
        self.jni = NULL
        self.jvmti = NULL
        self.__classes = {}
        self.bridge_loaded = False
        self.links = []
        self._export_generated_classes = False

    @staticmethod
    def acquire() -> Jvm:
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

    cdef void ensureBridgeLoaded(self) except *:
        cdef JNINativeMethod methods[1]
        cdef jclass bridge_jclass

        if not self.bridge_loaded:
            try:
                bridge = self.findClass("pyjvm/java/PyjvmBridge")
            except:
                import pyjvm
                base = os.path.dirname(pyjvm.__file__)
                bridgePath = os.path.join(base, "java", "PyjvmBridge.class")
                with open(bridgePath, "rb") as f:
                    bytecode = f.read()
                    bridge = self.loadClass(bytecode, None)
                
            methods[0].name = "call_override"
            methods[0].signature = "([Ljava/lang/Object;)Ljava/lang/Object;"
            methods[0].fnPtr = <void*>PyjvmBridge__call_override

            bridge_jclass = <jclass><unsigned long long>bridge._jclass
        
            self.jni[0].RegisterNatives(self.jni, bridge_jclass, methods, 1)
            JvmExceptionPropagateIfThrown(self)
            self.bridge_loaded = True
            



    cpdef object findClass(self, str name):
        if name in self.__classes:
            return self.__classes[name]

        cdef jclass cls = self.jni[0].FindClass(self.jni, name.encode("utf-8"))
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

        if loader != None:
            jloader = <jobject><unsigned long long>loader._jobject

        cdef jclass cls = self.jni[0].DefineClass(self.jni, NULL, jloader, <const jbyte*>bytecode, length)
        JvmExceptionPropagateIfThrown(self)

        err = self.jvmti[0].GetClassStatus(self.jvmti, cls, &status)
        if err != 0:
            raise JniException(err, "Could not get class status")

        if status < 2:
            unsafe = self.findClass("sun/misc/Unsafe")
            theUnsafe = unsafe.theUnsafe
            ensureClassInitialized = <jmethodID><unsigned long long>theUnsafe.ensureClassInitialized.method_id

            junsafe = <jobject><unsigned long long>theUnsafe._jobject

            args[0].l = cls
            self.jni[0].CallObjectMethodA(self.jni, junsafe, ensureClassInitialized, args)
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