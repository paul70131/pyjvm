// Type your code here, or load an example.

import java.lang.reflect.Method;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Field;


class Test {

    public void test() throws NoSuchMethodException, InvocationTargetException, IllegalAccessException {
        Method m  = this.getClass().getMethod("test");
        m.invoke(this, new Object[0]);
    }
}