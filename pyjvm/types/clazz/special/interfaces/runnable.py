from pyjvm.types.clazz.special.interfaces.interface import JvmSpecialInterface


class JvmRunnable(JvmSpecialInterface):
    __jname__ = 'java/lang/Runnable'

#    def __call__(self):
#        self.run()