from unittest import TestCase

from test.utils.java import compile_java

from pyjvm.jvm import Jvm

import os


class TestAttachCreate(TestCase):

    def test_inherit(self):
        
        jvm = Jvm.aquire()

        javaLangObject = jvm.findClass("java/lang/Object")

        class TestInherit(javaLangObject):
            package = "test.java"
        
            
        testJavaTestInherit = jvm.findClass("test/java/TestInherit")

