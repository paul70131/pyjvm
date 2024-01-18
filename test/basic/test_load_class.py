from unittest import TestCase

from test.utils.java import compile_java

from pyjvm.jvm import Jvm


class TestAttachCreate(TestCase):

    def test_load_class(self):
        
        to_load = "test/java/TestLoadClass.java"
        class_file = compile_java(to_load)
        jvm = Jvm.aquire()

        with open(class_file, 'rb') as f:
            TestLoadClass = jvm.loadClass(f)

        self.assertEqual(TestLoadClass.__name__, "test.java.TestLoadClass")