from unittest import TestCase

from test.utils.java import compile_java

import faulthandler

from pyjvm.jvm import Jvm

class TestPrimitiveArray(TestCase):

    def get_test_class(self, jvm):
        try:
            return jvm.findClass("test/java/TestStaticFields")
        except:
            to_load = "test/java/TestStaticFields.java"
            class_file = compile_java(to_load)

            with open(class_file, 'rb') as f:
                return jvm.loadClass(f)
            

    def test_bool_array(self):
        jvm = Jvm.acquire()
        test_class = self.get_test_class(jvm)

        self.assertEqual(test_class.bool_array_field, [True, False, True])
        self.assertEqual(test_class.bool_array_field[0], True)
        self.assertEqual(test_class.bool_array_field[0:2], [True, False])
        self.assertEqual(list(test_class.bool_array_field), [True, False, True])

        test_class.bool_array_field[0] = False

        self.assertEqual(test_class.bool_array_field, [False, False, True])

        test_class.bool_array_field[0] = True


    def test_byte_array(self):
        jvm = Jvm.acquire()
        test_class = self.get_test_class(jvm)

        self.assertEqual(test_class.byte_array_field, b"\x01\x02\x03")
        self.assertEqual(test_class.byte_array_field[0], 1)
        self.assertEqual(test_class.byte_array_field[0:2], b"\x01\x02")
        self.assertEqual(list(test_class.byte_array_field), [1, 2, 3])

        test_class.byte_array_field[0] = 2

        self.assertEqual(test_class.byte_array_field, b"\x02\x02\x03")

        test_class.byte_array_field[0] = 1


    def test_char_array(self):
        jvm = Jvm.acquire()
        test_class = self.get_test_class(jvm)

        self.assertEqual(test_class.char_array_field, ['a', 'b', 'c'])
        self.assertEqual(test_class.char_array_field[0], 'a')
        self.assertEqual(test_class.char_array_field[0:2], ['a', 'b'])
        self.assertEqual(list(test_class.char_array_field), ['a', 'b', 'c'])

        test_class.char_array_field[0] = 'b'
        self.assertEqual(test_class.char_array_field, ['b', 'b', 'c'])

        test_class.char_array_field[0] = 'a'

    def test_short_array(self):
        jvm = Jvm.acquire()
        test_class = self.get_test_class(jvm)

        self.assertEqual(test_class.short_array_field, [1, 2, 3])
        self.assertEqual(test_class.short_array_field[0], 1)
        self.assertEqual(test_class.short_array_field[1:3], [2, 3])
        self.assertEqual(list(test_class.short_array_field), [1, 2, 3])

        test_class.short_array_field[0] = 2
        self.assertEqual(test_class.short_array_field, [2, 2, 3])

        test_class.short_array_field[0] = 1

    def test_int_array(self):
        jvm = Jvm.acquire()
        test_class = self.get_test_class(jvm)

        self.assertEqual(test_class.int_array_field, [1, 2, 3])
        self.assertEqual(test_class.int_array_field[0], 1)
        self.assertEqual(test_class.int_array_field[0:2], [1, 2])
        self.assertEqual(list(test_class.int_array_field), [1, 2, 3])

        test_class.int_array_field[0] = 2
        self.assertEqual(test_class.int_array_field, [2, 2, 3])

        test_class.int_array_field[0] = 1

    def test_long_array(self):
        jvm = Jvm.acquire()
        test_class = self.get_test_class(jvm)

        self.assertEqual(test_class.long_array_field, [1, 2, 3])
        self.assertEqual(test_class.long_array_field[0], 1)
        self.assertEqual(test_class.long_array_field[0:2], [1, 2])
        self.assertEqual(list(test_class.long_array_field), [1, 2, 3])

        test_class.long_array_field[0] = 2
        self.assertEqual(test_class.long_array_field, [2, 2, 3])

        test_class.long_array_field[0] = 1

    def test_float_array(self):
        jvm = Jvm.acquire()
        test_class = self.get_test_class(jvm)

        self.assertEqual(test_class.float_array_field, [1.0, 2.0, 3.0])
        self.assertEqual(test_class.float_array_field[0], 1.0)
        self.assertEqual(test_class.float_array_field[0:2], [1.0, 2.0])
        self.assertEqual(list(test_class.float_array_field), [1.0, 2.0, 3.0])

        test_class.float_array_field[0] = 2.0
        self.assertEqual(test_class.float_array_field, [2.0, 2.0, 3.0])

        test_class.float_array_field[0] = 1.0


    def test_double_array(self):
        jvm = Jvm.acquire()
        test_class = self.get_test_class(jvm)

        self.assertEqual(test_class.double_array_field, [1.0, 2.0, 3.0])
        self.assertEqual(test_class.double_array_field[0], 1.0)
        self.assertEqual(test_class.double_array_field[0:2], [1.0, 2.0])
        self.assertEqual(list(test_class.double_array_field), [1.0, 2.0, 3.0])

        test_class.double_array_field[0] = 2.0
        self.assertEqual(test_class.double_array_field, [2.0, 2.0, 3.0])

        test_class.double_array_field[0] = 1.0
