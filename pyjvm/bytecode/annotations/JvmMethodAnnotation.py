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
    elif arg == object:
        return "Ljava/lang/Object;"
    else:
        raise TypeError("Unknown type", arg)
    
def __parse_super_call(func):
    bc = dis.get_instructions(func)
    codes = [code for code in bc]
    print(codes, len(codes))

    if len(codes) < 5:
        return False
    
    if codes[0].opname == "LOAD_GLOBAL" and codes[0].argval == "super":
        if codes[1].opname == "CALL_FUNCTION":
            if codes[2].opname == "LOAD_METHOD" and codes[2].argval == "__init__":
                if codes[3].opname == "CALL_METHOD":
                    if codes[4].opname == "POP_TOP":
                        return True
                    else:
                        return TypeError("Cannot use the return value of super().__init__()")
                    
        raise TypeError("Super call must be to __init__ and be like super().__init__()")
    
    for code in bc:
        if code.opname == "LOAD_GLOBAL" and code.argval == "super":
            raise TypeError("Cannot use super() in jvm methods")
    
    return False

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
    func.__jcall_super = __parse_super_call(func)
    print(func, func.__jcall_super)
    return func

def Override(func):
    func.__joverride = True
    return Method(func)