from pyjvm.types.clazz.jvmmethod cimport JvmMethodSignature

cdef class JvmMethodLink:
    #cdef int link_id
    #cdef object method
    #cdef JvmMethodSignature signature

    cdef list _convert_args(self, list arg_types, object args):
        cdef list py_args = [None] * (len(arg_types))
        cdef int i = 0

        if len(args) - 2 != len(arg_types):
            raise Exception("Invalid number of arguments")
        
        for i, arg_type in enumerate(arg_types):
            arg = args[i + 2]
            if arg_type == 'I':
                py_args[i] = <int>arg.intValue()
            elif arg_type == 'J':
                py_args[i] = <long long>arg.longValue()
            elif arg_type == 'F':
                py_args[i] = <float>arg.floatValue()
            elif arg_type == 'D':
                py_args[i] = <double>arg.doubleValue()
            elif arg_type[0] == 'L' or arg_type[0] == '[':
                py_args[i] = arg
            elif arg_type == 'Z':
                py_args[i] = <bint>arg.booleanValue()
            elif arg_type == 'B':
                py_args[i] = <char>arg.byteValue()
            elif arg_type == 'C':
                py_args[i] = <char>arg.charValue()
            elif arg_type == 'S':
                py_args[i] = <short>arg.shortValue()
            else:
                raise Exception("Invalid argument type: " + arg_type)
        
        return py_args


    cdef jobject invoke(self, Jvm jvm, object args):
        cdef list py_args
        cdef jobject return_jobj
        arg_types, ret_type = self.signature.parse()

        py_args = self._convert_args(arg_types, args)
        obj = args[1]

        r = self.method(obj, *py_args)

        r_obj = None

        if ret_type == 'V':
            return <jobject><unsigned long long>0
        if ret_type == 'I':
            javaLangInteger = jvm.findClass('java/lang/Integer')
            r_obj = javaLangInteger.valueOf(r)
        elif ret_type == 'J':
            javaLangLong = jvm.findClass('java/lang/Long')
            r_obj = javaLangLong.valueOf(r)
        elif ret_type == 'F':
            javaLangFloat = jvm.findClass('java/lang/Float')
            r_obj = javaLangFloat.valueOf(r)
        elif ret_type == 'D':
            javaLangDouble = jvm.findClass('java/lang/Double')
            r_obj = javaLangDouble.valueOf(r)
        elif ret_type == 'L' or ret_type == '[':
            r_obj = r
        elif ret_type == 'Z':
            javaLangBoolean = jvm.findClass('java/lang/Boolean')
            r_obj = javaLangBoolean.valueOf(r)
        elif ret_type == 'B':
            javaLangByte = jvm.findClass('java/lang/Byte')
            r_obj = javaLangByte.valueOf(r)
        elif ret_type == 'C':
            javaLangCharacter = jvm.findClass('java/lang/Character')
            r_obj = javaLangCharacter.valueOf(r)
        elif ret_type == 'S':
            javaLangShort = jvm.findClass('java/lang/Short')
            r_obj = javaLangShort.valueOf(r)
        else:
            raise Exception("Invalid return type: " + ret_type)

        if not r_obj:
            return <jobject><unsigned long long>0

        return_jobj = <jobject><unsigned long long>r_obj._jobject
        return_jobj = jvm.jni[0].NewLocalRef(jvm.jni, return_jobj)
        return return_jobj

    def __init__(self, int link_id, object method, JvmMethodSignature signature):
        self.link_id = link_id
        self.method = method
        self.signature = signature