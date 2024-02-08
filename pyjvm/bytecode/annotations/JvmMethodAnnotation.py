from inspect import signature
import dis



def __arg_to_jvm_type(arg, rtype = False):
    from pyjvm.types.clazz.jvmclass import JvmClassMeta

    if isinstance(arg, JvmClassMeta):
        return arg.signature

    if rtype:
        if arg is None:
            return "V"
    
    if arg == int:
        return "J" # since python ints can be indefinitely large, we use longs
    elif arg == float:
        return "D" # since python floats are doubles
    elif arg == str:
        return "Ljava/lang/String;"
    elif arg == bool:
        return "Z"
    else:
        return "Lpyjvm/bridge/java/PyObject;"
    

def __parse_signature(func):
    args = []
    rtype = "V"

    sig = signature(func)
    sig.return_annotation

    if func.__defaults__:
        raise TypeError("Cannot use default values in method definition")

    for parameter, type in sig.parameters.items():

        if parameter == "self":
            continue

        if type.annotation == type.empty:
            raise TypeError("Missing type annotation for parameter", parameter)
    
        args.append(__arg_to_jvm_type(type.annotation))

    if not sig.return_annotation == sig.empty:
        rtype = __arg_to_jvm_type(sig.return_annotation, True)

    jsignature = "(" + "".join(args) + ")" + rtype
    return jsignature


def Method(func):
    func.__jsignature = __parse_signature(func)
    return func

def Override(func):
    func.__joverride = True
    return Method(func)