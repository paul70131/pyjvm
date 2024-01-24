package test.java;

import java.lang.annotation.*;


public class TestStaticFields {
    public int number;
    
    @Retention(RetentionPolicy.RUNTIME)
    public static boolean bool_field = true;

    public static byte byte_field = 1;
    public static char char_field = 'a';
    public static short short_field = 2;
    public static int int_field = 3;
    public static long long_field = 4;
    public static float float_field = 5.0f;
    public static double double_field = 6.0;
    public static Object object_field = new Object();
    public static String string_field = "Hello World!";
    public static String string_field2 = "Bye World!";

    public static boolean[] bool_array_field = {true, false, true};
    public static byte[] byte_array_field = {1, 2, 3};
    public static char[] char_array_field = {'a', 'b', 'c'};
    public static short[] short_array_field = {1, 2, 3};
    public static int[] int_array_field = {1, 2, 3};
    public static long[] long_array_field = {1, 2, 3};
    public static float[] float_array_field = {1.0f, 2.0f, 3.0f};
    public static double[] double_array_field = {1.0, 2.0, 3.0};
    
    public static String[] string_array_field = {"Hello", "World", "!"};
    public static TestStaticFields[] object_array_field = {new TestStaticFields(1), new TestStaticFields(2), new TestStaticFields(3)};

    @Override
    public boolean equals(Object o) {
        return true;
    }

    public TestStaticFields(int number) {
        this.number = number;
    }


    public static int with_object_arg(TestStaticFields o) {
        return o.number;
    }

}