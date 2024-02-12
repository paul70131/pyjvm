import time
from jnius import autoclass

def benchmark_pyjnius():
    # Start the timer
    start_time = time.time()

    # Load a Java class
    MyClass = autoclass('java.lang.Object')
    System = autoclass('java.lang.System')

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
    benchmark_pyjnius()