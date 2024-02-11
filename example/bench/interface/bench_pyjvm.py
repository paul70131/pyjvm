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
    for _ in range(10000):
        obj = MyClass()
    
    for _ in range(10000):
        obj = System.getenv()

    # End the timer
    end_time = time.time()

    # Calculate the elapsed time
    elapsed_time = end_time - start_time

    print(f"Time taken to create 1000000 Java objects: {elapsed_time} seconds")

if __name__ == "__main__":
    cProfile.runctx("benchmark_pyjvm()", globals(), locals(), "Profile.prof")
    import pstats
    p = pstats.Stats("Profile.prof")
    p.sort_stats("time").print_stats()
