from unittest import TestCase

from test.utils.java import compile_java

from pyjvm.jvm import Jvm

import os


class TestAttachCreate(TestCase):

    def test_load_class(self):
        
        jvm = Jvm.acquire()

        with self.assertRaises(Exception):
            TestLoadClass = jvm.findClass("test/java/TestLoadClass")


        to_load = "test/java/TestLoadClass.java"
        class_file = compile_java(to_load)

        TestLoadClass = jvm.findClass("test/java/TestLoadClass")

        os.unlink(class_file)