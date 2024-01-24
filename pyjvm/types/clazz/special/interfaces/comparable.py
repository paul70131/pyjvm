from pyjvm.types.clazz.special.interfaces.interface import JvmSpecialInterface


class JvmComparable(JvmSpecialInterface):
    __jname__ = 'java/lang/Comparable'

    def __lt__(self, other):
        return self.compareTo(other) < 0

    def __le__(self, other):
        return self.compareTo(other) <= 0

    def __eq__(self, other):
        return self.compareTo(other) == 0
    
    def __ne__(self, other):
        return self.compareTo(other) != 0
    
    def __gt__(self, other):
        return self.compareTo(other) > 0
    
    def __ge__(self, other):
        return self.compareTo(other) >= 0
    