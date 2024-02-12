package example.bench.adapter.jvm;

public class Test {
    
    public static void runTest(long count, Test test) {
        for (long i = 0; i < count; i++) {
            test.test();
        }
    }

    public void test() {
        
    }
}
