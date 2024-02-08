package pyjvm.bridge.java;

import java.lang.ref.Cleaner;

public class PyjvmBridge {

    public static Cleaner cleaner = Cleaner.create();

    public boolean example_bool_override() {
        call_override((short) 42);
        return false;
    }

    public long example_long_override() {
        call_override((short) 42);
        return 0;
    }

    public long example_call_override(long t, int u) {
        final Object co = call_override((short) 42, t, u);
        if (co != null) {
            return (long)co;
        }
        return 0;
    }

    public PyjvmBridge() {
        call_override((short) 42, "TEST");
    }
    
    public static native Object call_override(Object ... args);
}
