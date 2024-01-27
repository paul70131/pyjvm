package pyjvm.java;

public class PyjvmBridge {

    public boolean example_bool_override() {
        call_override((short) 42);
        return false;
    }

    public long example_long_override() {
        call_override((short) 42);
        return 0;
    }

    public Object example_call_override(long t, int u) {
        call_override((short) 42, t, u);
        return null;
    }
    
    public static native Object call_override(Object ... args);
}
