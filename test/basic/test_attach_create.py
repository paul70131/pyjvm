from unittest import TestCase

from faulthandler import enable

from pyjvm.jvm import Jvm


class TestAttachCreate(TestCase):

    def test_attach(self):
        self.assertRaises(Exception, Jvm.attach)

    def test_create(self):
        jvm = Jvm.create()

        jvm = Jvm.attach()

    def test_find_class(self):
        enable()

        jvm = Jvm.attach()

        javaLangSystem = jvm.FindClass("java/lang/System")

        print(javaLangSystem.getFields())
        somestr = javaLangSystem.lineSeparator
        print("field", somestr)

        print(somestr.charAt)

        someobj = javaLangSystem.props
        print(someobj)
        print("defaults", someobj.defaults)

        print(javaLangSystem.allowSecurityManager)
        javaLangSystem.allowSecurityManager = 1
        print(javaLangSystem.allowSecurityManager)


        self.assertIsNotNone(javaLangSystem)
        self.assertEqual(javaLangSystem.__bases__[0].__name__, "java.lang.Object")
