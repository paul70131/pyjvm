from unittest import TestCase

from test.utils.java import compile_java

from pyjvm.jvm import Jvm


class TestStaticMethods(TestCase):

    def get_test_class(self, jvm):
        try:
            return jvm.findClass("test/java/TestStaticMethods")
        except:
            to_load = "test/java/TestStaticMethods.java"
            class_file = compile_java(to_load)
            jvm = Jvm.aquire()

            with open(class_file, 'rb') as f:
                return jvm.loadClass(f)
            

    def test_ret_void(self):
        jvm = Jvm.aquire()
        test_class = self.get_test_class(jvm)
        r = test_class.void_method()
        self.assertEqual(r, None)

    def test_ret_bool(self):
        jvm = Jvm.aquire()
        test_class = self.get_test_class(jvm)
        r = test_class.bool_method()
        self.assertEqual(r, True)

    def test_ret_byte(self):
        jvm = Jvm.aquire()
        test_class = self.get_test_class(jvm)
        r = test_class.byte_method()
        self.assertEqual(r, 1)
    
    def test_ret_char(self):
        jvm = Jvm.aquire()
        test_class = self.get_test_class(jvm)
        r = test_class.char_method()
        self.assertEqual(r, 'a')

    def test_ret_short(self):
        jvm = Jvm.aquire()
        test_class = self.get_test_class(jvm)
        r = test_class.short_method()
        self.assertEqual(r, 2)
    
    def test_ret_int(self):
        jvm = Jvm.aquire()
        test_class = self.get_test_class(jvm)
        r = test_class.int_method()
        self.assertEqual(r, 3)
    
    def test_ret_long(self):
        jvm = Jvm.aquire()
        test_class = self.get_test_class(jvm)
        r = test_class.long_method()
        self.assertEqual(r, 4)

    def test_ret_float(self):
        jvm = Jvm.aquire()
        test_class = self.get_test_class(jvm)
        r = test_class.float_method()
        self.assertEqual(r, 5.0)
    
    def test_ret_doulbe(self):
        jvm = Jvm.aquire()
        test_class = self.get_test_class(jvm)
        r = test_class.double_method()
        self.assertEqual(r, 6.0)

    def test_ret_string(self):
        jvm = Jvm.aquire()
        test_class = self.get_test_class(jvm)
        r = test_class.string_method()
        self.assertEqual(r, "Hello World!")
    
    def test_ret_obj(self):
        jvm = Jvm.aquire()
        test_class = self.get_test_class(jvm)
        r = test_class.object_method()
        self.assertEqual(r.__class__.__name__, "test.java.TestStaticMethods")

    def test_throws(self):
        jvm = Jvm.aquire()
        test_class = self.get_test_class(jvm)

        with self.assertRaises(Exception):
            test_class.throws_method()