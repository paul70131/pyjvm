package pyjvm.bridge.java.reference;

// TODO: In the future "finalize" will be removed.
// java.lang.ref.Cleaner only works with Java 9 and later.
// we may have to use 2 different implementations for Java 8 and Java 9+.
// for now we will use finalize.



public class PyRefHolder {
    /* this just holds a reference to a Python Object */
    private long _ref;

    private native void _decref(long ref);
    private native void _incref(long ref);

    public PyRefHolder(long ref) {
        this._ref = ref;
        _incref(_ref);
    }

    // deinit will be done with jvmti,
    // we will tag all PyRefHolder instances with the reference to the Python object
    // then we will wait for JVMTI ObjectFree event to be triggered
    // and then we will call _decref(ref) to release the reference to the Python object
}