from pyjvm.jvm import Jvm
from pyjvm.bytecode.annotations import Override

import time

def benchmark_pyjvm_methodlink():

    jvm = Jvm.acquire()
    jvm._export_generated_classes = True

    start_time = time.time()

    with open("jvm/Test.class", "rb") as f:
        Test = jvm.loadClass(f.read())

    class PyjvmMethodlinkTest(Test):
        @Override
        def test(self):
            return

    count = 1_000_0

    test  = PyjvmMethodlinkTest()

    Test.runTest(count, test)

        # End the timer
    end_time = time.time()

    # Calculate the elapsed time
    elapsed_time = end_time - start_time

    print(f"Time taken to create 1000000 Java objects: {elapsed_time} seconds")



if __name__ == "__main__":
    benchmark_pyjvm_methodlink()