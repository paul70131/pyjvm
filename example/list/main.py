


from pyjvm.jvm import Jvm

from pyjvm.bytecode.annotations import Method, Object



jvm = Jvm.acquire()

ArrayList = jvm.findClass("java/util/ArrayList")
Integer = jvm.findClass("java/lang/Integer")


class MyList(ArrayList):

    @Method
    def has3(self) -> bool:
        return self.size == 3
    



mylist = MyList()
mylist.add(Integer.valueOf(1))
mylist.add(Integer.valueOf(2))
mylist.add(Integer.valueOf(3))

print(mylist.has3()) # True

mylist.add(Integer.valueOf(4))

print(mylist.has3()) # False
