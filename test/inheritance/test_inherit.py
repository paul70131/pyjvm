from unittest import TestCase

from test.utils.java import compile_java

from pyjvm.jvm import Jvm

import os


class TestAttachCreate(TestCase):

    def test_inherit(self):
        
        jvm = Jvm.aquire()

        TestStaticFields = jvm.findClass("test/java/TestStaticFields")

        class TestInherit(TestStaticFields):
            package = "test.java"
        
            
        testJavaTestInherit = jvm.findClass("test/java/TestInherit")

