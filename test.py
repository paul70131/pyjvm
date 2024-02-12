import time
from pyjvm.jvm import Jvm
from pyjvm.bytecode.annotations import Override, Int

import cProfile

jvm = Jvm.acquire()
jvm._export_generated_classes = True

start_time = time.time()

with open("example/bench/adapter/jvm/Test.class", "rb") as f:
    Test = jvm.loadClass(f.read())

class PyjvmMethodlinkTest(Test):
    i: Int = 0
    @Override
    def test(self):
        self.i += 1

count = 1_000

test  = PyjvmMethodlinkTest()

Test.runTest(count, test)

    # End the timer
end_time = time.time()

# Calculate the elapsed time
elapsed_time = end_time - start_time

print(f"Time taken to create 1000000 Java objects: {elapsed_time} seconds")

