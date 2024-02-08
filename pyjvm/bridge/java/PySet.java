package pyjvm.bridge.java;

import java.util.Collection;
import java.util.Iterator;
import java.util.Set;

public class PySet extends PyObject implements Set {
    public PySet(long ref) {
        super(ref);
    }
    @Override
    public native void clear();

    @Override
    public native boolean contains(Object o);

    @Override
    public native boolean isEmpty();

    @Override
    public native int size();

    @Override
    public native Object[] toArray();

    @Override
    public native Object[] toArray(Object[] a);
    

    @Override
    public native boolean add(Object o);

    @Override
    public native boolean remove(Object o);

    @Override
    public native Iterator iterator();

    @Override
    public native boolean containsAll(Collection c);

    @Override
    public native boolean addAll(Collection c);

    @Override
    public native boolean retainAll(Collection c);

    @Override
    public native boolean removeAll(Collection c);

}