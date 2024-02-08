package pyjvm.bridge.java;

import java.util.Collection;
import java.util.Map;
import java.util.Set;

public class PyDict extends PyObject implements Map {
    public PyDict(long ref) {
        super(ref);
    }

    @Override
    public native int size();
    // return len(self)

    @Override
    public boolean isEmpty() {
        return size() == 0;
    }

    @Override
    public native boolean containsKey(Object key);
    // return key in self

    @Override
    public native boolean containsValue(Object value);
    // return value in self.values()

    @Override
    public native Object get(Object key);
    // return self[key]

    @Override
    public native Object put(Object key, Object value);
    // self[key] = value

    @Override
    public native Object remove(Object key);
    // del self[key]

    @Override
    public native void putAll(Map m);

    @Override
    public native void clear();

    @Override
    public native Set keySet();

    @Override
    public native Collection values();

    @Override
    public native Set entrySet();

}