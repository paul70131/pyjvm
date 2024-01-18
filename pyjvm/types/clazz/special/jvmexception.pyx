from pyjvm.types.clazz.jvmclass cimport JvmClass


# this is just a proxy
class JvmException(BaseException):
    
    def __init__(self, throwable):
        self.throwable = throwable
    
    def __getattr__(self, name):
        return getattr(self.throwable, name)
    
    def __setattr__(self, name, value):
        if name == 'throwable':
            self.__dict__[name] = value
        else:
            setattr(self.throwable, name, value)
        
