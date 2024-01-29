from unittest import TestCase

from pyjvm.jvm import Jvm


class TestAttachCreate(TestCase):

    def test_acquire(self):
        jvm = Jvm.acquire()