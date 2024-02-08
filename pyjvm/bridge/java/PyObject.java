package pyjvm.bridge.java;

import pyjvm.bridge.java.reference.PyRefHolder;


public class PyObject extends PyRefHolder {

    public PyObject(long ref) {
        super(ref);
    }

    public native PyObject getAttr(String name);

    public native PyObject setAttr(String name, PyObject value);
    public native PyObject setAttr(String name, long value);
    public native PyObject setAttr(String name, double value);
    public native PyObject setAttr(String name, boolean value);
    public native PyObject setAttr(String name, String value);

    @Override
    public native int hashCode();

    @Override
    public native boolean equals(Object obj);

    public native int toInt();
    public native long toLong();
    public native double toDouble();
    public native boolean toBoolean();
    public native float toFloat();
    public native short toShort();
    public native byte toByte();
    public native char toChar();

    @Override
    public native String toString();
}