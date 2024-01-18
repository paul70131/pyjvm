from unittest import TestCase

from test.utils.java import compile_java

from pyjvm.jvm import Jvm


class TestString(TestCase):

    def get_test_class(self, jvm):
        try:
            return jvm.findClass("test/java/TestStaticFields")
        except:
            to_load = "test/java/TestStaticFields.java"
            class_file = compile_java(to_load)
            jvm = Jvm.aquire()

            with open(class_file, 'rb') as f:
                return jvm.loadClass(f)
        
    def test_string(self):
        jvm = Jvm.aquire()
        test_class = self.get_test_class(jvm)
        self.assertEqual(len(test_class.string_field), 12)
        self.assertEqual(test_class.string_field, "Hello World!")
            
