package pyjvm.bridge.java.reference;

import java.lang.ref.ReferenceQueue;

public class PyRefQueue extends ReferenceQueue<PyRefHolder> {
    private static PyRefQueue instance = null;

    public static PyRefQueue getInstance() {
        if (instance == null) {
            instance = new PyRefQueue();
        }
        return instance;
    }
}
