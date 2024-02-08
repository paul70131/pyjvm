package pyjvm.bridge.java;

import java.lang.ref.Cleaner;

public class PyjvmBridge {

    public static Cleaner cleaner = Cleaner.create();

    public static native Object call_override(Object ... args);
}
