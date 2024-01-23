from unittest import TestCase

from test.utils.java import compile_java

from pyjvm.jvm import Jvm


class TestStaticFields(TestCase):

    def get_test_class(self, jvm):
        try:
            return jvm.findClass("test/java/TestStaticFields")
        except:
            to_load = "test/java/TestStaticFields.java"
            class_file = compile_java(to_load)

            with open(class_file, 'rb') as f:
                return jvm.loadClass(f)
            

    def test_bool(self):
        
        jvm = Jvm.aquire()
        test_class = self.get_test_class(jvm)

        self.assertEqual(test_class.bool_field, True)
        test_class.bool_field = False
        self.assertEqual(test_class.bool_field, False)

    def test_byte(self):
        jvm = Jvm.aquire()
        test_class = self.get_test_class(jvm)

        self.assertEqual(test_class.byte_field, 1)
        test_class.byte_field = 2
        self.assertEqual(test_class.byte_field, 2)

    def test_char(self):
        jvm = Jvm.aquire()
        test_class = self.get_test_class(jvm)

        self.assertEqual(test_class.char_field, 'a')
        test_class.char_field = 'b'
        self.assertEqual(test_class.char_field, 'b')
        test_class.char_field = 0x42
        self.assertEqual(test_class.char_field, 'B')

    def test_short(self):
        jvm = Jvm.aquire()
        test_class = self.get_test_class(jvm)

        self.assertEqual(test_class.short_field, 2)
        test_class.short_field = 3
        self.assertEqual(test_class.short_field, 3)

    def test_int(self):
        jvm = Jvm.aquire()
        test_class = self.get_test_class(jvm)

        self.assertEqual(test_class.int_field, 3)
        test_class.int_field = 4
        self.assertEqual(test_class.int_field, 4)

    def test_long(self):
        jvm = Jvm.aquire()
        test_class = self.get_test_class(jvm)

        self.assertEqual(test_class.long_field, 4)
        test_class.long_field = 5
        self.assertEqual(test_class.long_field, 5)

    def test_float(self):
        jvm = Jvm.aquire()
        test_class = self.get_test_class(jvm)

        self.assertEqual(test_class.float_field, 5.0)
        test_class.float_field = 6.25
        self.assertEqual(test_class.float_field, 6.25)

    def test_double(self):
        jvm = Jvm.aquire()
        test_class = self.get_test_class(jvm)

        self.assertEqual(test_class.double_field, 6.0)
        test_class.double_field = 7.25
        self.assertEqual(test_class.double_field, 7.25)

    def test_object(self):
        jvm = Jvm.aquire()
        test_class = self.get_test_class(jvm)

        obj = test_class.object_field
        self.assertEqual(obj.__class__.__name__, "java.lang.Object")

        test_class.object_field = None
        self.assertEqual(test_class.object_field, None)

        test_class.object_field = obj
        self.assertEqual(test_class.object_field, obj)

        # TODO: test setting object field

    def test_string(self):
        jvm = Jvm.aquire()
        test_class = self.get_test_class(jvm)

        self.assertEqual(test_class.string_field, "Hello World!")
        test_class.string_field = "Bye World!"
        self.assertEqual(test_class.string_field, "Bye World!")

        test_class.string_field = "Hello World!"

    def test_int_array(self):
        jvm = Jvm.aquire()
        test_class = self.get_test_class(jvm)

        self.assertEqual(len(test_class.int_array_field), 3)
        self.assertEqual(test_class.int_array_field.signature, "[I")
        self.assertEqual(test_class.int_array_field[0], 1)