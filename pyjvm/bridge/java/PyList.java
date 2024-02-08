package pyjvm.bridge.java;

import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.ListIterator;

public class PyList extends PyObject implements java.util.List<Object> {
    public PyList(long ref) {
        super(ref);
    }

    @Override
    public native int size();

    @Override
    public boolean isEmpty() {
        return size() == 0;
    }

    @Override
    public native boolean contains(Object o);
    // return o in self

    @Override
    public Iterator<Object> iterator() {
        return null;
    }

    @Override
    public native Object[] toArray();
    // jni->newObjectArray -> InsertAll

    @Override
    public native <T> T[] toArray(T[] a);
    // InsertAll

    @Override
    public native boolean add(Object e);
    // append

    @Override
    public native boolean remove(Object o);
    // remove

    @Override
    public boolean containsAll(Collection<?> c) {
        for (Object o : c) {
            if (!contains(o)) {
                return false;
            }
        }
        return true;
    }

    @Override
    public boolean addAll(Collection<? extends Object> c) {
        return this.addAll(-1, c);
    }

    @Override
    public native boolean addAll(int index, Collection<? extends Object> c);
    // return this + c

    @Override
    public boolean removeAll(Collection<?> c) {
        boolean modified = false;
        for (Object o : c) {
            modified |= remove(o);
        }
        return modified;
    }

    @Override
    public boolean retainAll(Collection<?> c) {
        List<Object> toRemove = new java.util.ArrayList<Object>();
        for (Object o : this) {
            if (!c.contains(o)) {
                toRemove.add(o);
            }
        }
        return removeAll(toRemove);
    }

    @Override
    public native void clear();
    // clear

    @Override
    public native Object get(int index);
    // return self[index]

    @Override
    public native Object set(int index, Object element);
    // prev = self[index]
    // self[index] = element
    // return prev

    @Override
    public native void add(int index, Object element);
    // this.insert(index, element)
        

    @Override
    public native Object remove(int index);
    // prev = self[index]
    // index = self.remove(self[index])
    // return prev

    @Override
    public native int indexOf(Object o);
    // return self.index(o)

    @Override
    public native int lastIndexOf(Object o);
    // return self.rindex(o)

    @Override
    public ListIterator<Object> listIterator() {
        // TODO Auto-generated method stub
        throw new UnsupportedOperationException("Unimplemented method 'listIterator'");
    }

    @Override
    public ListIterator<Object> listIterator(int index) {
        // TODO Auto-generated method stub
        throw new UnsupportedOperationException("Unimplemented method 'listIterator'");
    }

    @Override
    public native List<Object> subList(int fromIndex, int toIndex);
    // return self[fromIndex:toIndex]

}