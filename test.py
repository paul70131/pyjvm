import time
from pyjvm.jvm import Jvm
from pyjvm.bytecode.annotations import Override, Int, Method

import cProfile

jvm = Jvm.acquire()
jvm._export_generated_classes = True

start_time = time.time()

with open("example/bench/adapter/jvm/Test.class", "rb") as f:
    Test = jvm.loadClass(f.read())

class PyjvmMethodlinkTest(Test):
    i: Int = 0

    """  @Override
    def test(self):
        i = 0
        i += self.test2(i)
        self.test3()
        #self.test4()
        
    @Method
    def test2(self, i: Int) -> Int:
        i = i + 1
        i += 12
        return i
    
    @Method
    def test3(self):
        i = 32
        i += 1
        i -= 1
        i *= 1
        i /= 1
        i = i + i
        i = i - i
        i = i * i
        i = i / 1 """

    @Method
    def test4(self):
        v = [1, 2,]
        v2 = ["1", "2", "3", "4", "5", 6, "im a opbject", 8, 9, 10, 11]

        v3 = v + v2
        i = v2[0] + v3[0]

        sum = 0
        for value in v3:
            sum += value

    #@Method
    #def test4(self):
    #    self.i += 1
    

count = 1_000_000

test  = PyjvmMethodlinkTest()

try:
    Test.runTest(count, test)
except Exception as e:
    e.printStackTrace()

    # End the timer
end_time = time.time()

print(test.test2(32), test.i)
test.test4()


# Calculate the elapsed time
elapsed_time = end_time - start_time

print(f"Time taken to create 1000000 Java objects: {elapsed_time} seconds")

