from unittest import TestCase

from test.utils.java import compile_java

from pyjvm.bytecode.annotations import Int, StaticInt, StaticFloat, Object, StaticObject, StaticBoolean, StaticChar, StaticLong, StaticFloat, StaticDouble, Override, Method

from pyjvm.jvm import Jvm

import os


class TestAttachCreate(TestCase):

    def test_inherit(self):
        
        jvm = Jvm.acquire()

        jvm._export_generated_classes = True

        TestStaticFields = jvm.findClass("test/java/TestStaticFields")
        String = jvm.findClass("java/lang/String")

        

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
                return 2
            
            @Override
            def test_override_args(self, a: int, b: float, c: int, d: bool, e: str): 
                return a + b
            
            @Method
            def method(self) -> int:
                return 42
            
            @Method
            def __init__(self, a: int):
                super().__init__()
                self.new_int = a
            

        
        _TestInherit = jvm.findClass("test/java/TestInherit")

        self.assertEqual(_TestInherit.new_static_int, 42)
        _TestInherit.new_static_int = 43
        self.assertEqual(_TestInherit.new_static_int, 43)
        self.assertEqual(TestInherit.new_static_int, 43)

        self.assertEqual(TestInherit.new_static_string, "Hello World! 2")
        self.assertEqual(TestInherit.new_static_boolean, True)
        self.assertEqual(TestInherit.new_static_char, 'a')
        self.assertEqual(TestInherit.new_static_long, 42)
        self.assertAlmostEqual(TestInherit.new_static_float, 42.01, places=2)
        self.assertEqual(TestInherit.new_static_double, 42.01)

        obj = TestInherit(3)

        self.assertEqual(obj.test_override_noargs(), 2)
        self.assertEqual(obj.test_override_args(1, 2.0, 3, True, "Hello World!"), 3.0)

        self.assertEqual(obj.method(), 42)
        self.assertEqual(obj.method2(1, 2.0, "Hello World!", True), 42)
        self.assertEqual(obj.method2(1, 2.0, "Hello World!", False), -42)

        
