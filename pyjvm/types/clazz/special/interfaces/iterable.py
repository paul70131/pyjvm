from pyjvm.types.clazz.special.interfaces.interface import JvmSpecialInterface


class JvmIterable(JvmSpecialInterface):
    __jname__ = 'java/lang/Iterable'

    def __iter__(self):
        return self.iterator()