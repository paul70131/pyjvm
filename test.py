from pyjvm.jvm import Jvm


from pyjvm.bytecode.annotations import Int, StaticInt, StaticFloat, Object, StaticObject, StaticBoolean, StaticChar, StaticLong, StaticFloat, StaticDouble, Override, Method



jvm = Jvm.acquire()
TestStaticFields = jvm.findClass("test/java/TestStaticFields")

jlo = jvm.findClass("java/lang/Object")
obj = TestStaticFields(3)
String = jvm.findClass("java/lang/String")

print(obj)


class TestInherit(TestStaticFields):
    package = "test.java"

    new_static_int: StaticInt = 42
    new_int: Int
    new_string: Object(String)
    new_static_string: StaticObject(String) = "Hello World! 2"

    new_static_boolean: StaticBoolean = True
    new_static_char: StaticChar = 'a'
    new_static_long: StaticLong = 42
    new_static_float: StaticFloat = 42.01
    new_static_double: StaticDouble = 42.01

    @Override
    def test_override_noargs(self):
        print("OVERRIDE NO ARGS")
        return 2
    
    @Override
    def test_override_args(self, a: int, b: float, c: int, d: bool, e: str): 
        return a + b
    
    @Method
    def method(self) -> int:
        return 42
    
    @Method
    def __init__(self, a: int):
        self.new_int = a
        self.new_string = "Hello World!"
            

nobj = TestInherit(3)

print(nobj)
print(nobj.new_int)
print(nobj.new_string)
try:
    print(nobj.test_override_args(1, 2.0, 3, True, "Hello"))
except BaseException as e:
    e.printStackTrace()