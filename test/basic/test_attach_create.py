from unittest import TestCase

from pyjvm.jvm import Jvm


class TestAttachCreate(TestCase):

    def test_aquire(self):
        jvm = Jvm.aquire()