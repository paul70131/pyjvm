from pyjvm.jvm import Jvm

import time

def benchmark_jvm():

    jvm = Jvm.acquire()

    start_time = time.time()

    with open("jvm/Test.class", "rb") as f:
        Test = jvm.loadClass(f.read())

    print(Test)

    count = 1_000_000

    test  = Test()

    Test.runTest(count, test)

        # End the timer
    end_time = time.time()

    # Calculate the elapsed time
    elapsed_time = end_time - start_time

    print(f"Time taken to create 1000000 Java objects: {elapsed_time} seconds")



if __name__ == "__main__":
    benchmark_jvm()