

class JvmSpecialInterface:
    interfaces = {}
    __jname__ = 'java/lang/Interface'


    def __init_subclass__(cls) -> None:
        cls.interfaces[cls.__jname__] = cls

    @classmethod
    def get(cls, name):
        return cls.interfaces.get(name, None)

# just adds specific magic methods to the object which translate to java methods