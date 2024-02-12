import time
from pyjvm.jvm import Jvm

import cProfile

def benchmark_pyjvm():
    # Start the timer

    start_time = time.time()

    jvm = Jvm.acquire()

    # Load a Java class
    MyClass = jvm.findClass('java/lang/Object')
    System = jvm.findClass('java/lang/System')

    # Create Java objects from Python
    for _ in range(100000):
        obj = MyClass()
    
    for _ in range(100000):
        obj = System.getenv()
        obj.toString()

    # End the timer
    end_time = time.time()

    # Calculate the elapsed time
    elapsed_time = end_time - start_time

    print(f"Time taken to create 1000000 Java objects: {elapsed_time} seconds")

if __name__ == "__main__":
    benchmark_pyjvm()