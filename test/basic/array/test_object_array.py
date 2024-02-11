from unittest import TestCase

from test.utils.java import compile_java

from pyjvm.jvm import Jvm


class TestPrimitiveArray(TestCase):

    def get_test_class(self, jvm):
        try:
            return jvm.findClass("test/java/TestStaticFields")
        except:
            to_load = "test/java/TestStaticFields.java"
            class_file = compile_java(to_load)

            with open(class_file, 'rb') as f:
                return jvm.loadClass(f.read())
            

    def test_string_array(self):
        jvm = Jvm.acquire()

        test_class = self.get_test_class(jvm)

        self.assertEqual(test_class.string_array_field, ["Hello", "World", "!"])
        self.assertEqual(test_class.string_array_field[0], "Hello")
        self.assertEqual(test_class.string_array_field[0:2], ["Hello", "World"])
        self.assertEqual(list(test_class.string_array_field), ["Hello", "World", "!"])

    def test_object_array(self):
        print(1, "Jvm.acquire()")
        jvm = Jvm.acquire()
        print(2, "test_class = self.get_test_class(jvm)")
        test_class = self.get_test_class(jvm)

        print(3, "jlo = jvm.findClass('java/lang/Object')")
        jlo = jvm.findClass("java/lang/Object")
        print(4, "obj = test_class(3)")
        obj = test_class(3)

        print(5, "String = jvm.findClass('java/lang/String')")
        self.assertEqual(test_class.object_array_field, [obj, obj, obj])
        self.assertEqual(test_class.object_array_field[0].number, 1)
        self.assertEqual(test_class.object_array_field[1].number, 2)
        self.assertEqual(test_class.object_array_field[0:2], [obj, obj])
        self.assertEqual(list(test_class.object_array_field), [obj, obj, obj])

        test_class.object_array_field[1] = obj

        self.assertEqual(test_class.object_array_field[1].number, 3)

        test_class.object_array_field[1] = test_class(2)

