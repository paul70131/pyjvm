from unittest import TestCase

from test.utils.java import compile_java

from pyjvm.bytecode.annotations import Int, StaticInt, StaticFloat

from pyjvm.jvm import Jvm

import os


class TestAttachCreate(TestCase):

    def test_inherit(self):
        
        jvm = Jvm.aquire()

        TestStaticFields = jvm.findClass("test/java/TestStaticFields")

        class TestInherit(TestStaticFields):
            package = "test.java"

            new_static_int: StaticInt = 42
            new_int: Int 
        
        _TestInherit = jvm.findClass("test/java/TestInherit")

        self.assertEqual(_TestInherit.new_static_int, 42)
        _TestInherit.new_static_int = 43
        self.assertEqual(_TestInherit.new_static_int, 43)



