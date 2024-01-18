package test.java;


public class TestStaticMethods {
/*    public static boolean bool_field = true;
    public static byte byte_field = 1;
    public static char char_field = 'a';
    public static short short_field = 2;
    public static int int_field = 3;
    public static long long_field = 4;
    public static float float_field = 5.0f;
    public static double double_field = 6.0;
    public static Object object_field = new Object();
    public static String string_field = "Hello World!";
    public static int[] int_array_field = {1, 2, 3};
    public static Object[] object_array_field = {new Object(), new Object(), new Object()};*/

    public TestStaticMethods() {
        return;
    }

    public static void void_method() {
        return;
    }

    public static boolean bool_method() {
        return true;
    }

    public static byte byte_method() {
        return 1;
    }

    public static char char_method() {
        return 'a';
    }

    public static short short_method() {
        return 2;
    }

    public static int int_method() {
        return 3;
    }

    public static long long_method() {
        return 4;
    }

    public static float float_method() {
        return 5.0f;
    }

    public static double double_method() {
        return 6.0;
    }

    public static Object object_method() {
        return new TestStaticMethods();
    }

    public static String string_method() {
        return "Hello World!";
    }

    public static int[] int_array_method() {
        return new int[]{1, 2, 3};
    }

    public static Object[] object_array_method() {
        return new Object[]{new Object(), new Object(), new Object()};
    }

    public static void throws_method() throws Exception {
        throw new Exception();
    }

}