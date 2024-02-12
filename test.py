import time
from pyjvm.jvm import Jvm

import cProfile


start_time = time.time()

jvm = Jvm.acquire()

    # Load a Java class
MyClass = jvm.findClass('java/lang/Object')
System = jvm.findClass('java/lang/System')

version = System.getProperty("java.version")
print(version)