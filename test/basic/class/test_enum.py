from unittest import TestCase

from test.utils.java import compile_java

from pyjvm.jvm import Jvm


class TestEnum(TestCase):

    def get_test_class(self, jvm):
        try:
            return jvm.findClass("test/java/TestEnum")
        except:
            to_load = "test/java/TestEnum.java"
            class_file = compile_java(to_load)
            jvm = Jvm.aquire()

            with open(class_file, 'rb') as f:
                return jvm.loadClass(f)
            
    def test_string(self):
        jvm = Jvm.aquire()

        test_class = self.get_test_class(jvm)

        one = test_class.ONE
        self.assertEqual(one.name, "ONE")
        self.assertEqual(one.ordinal, 0)

        self.assertEqual(test_class.ONE, one)
