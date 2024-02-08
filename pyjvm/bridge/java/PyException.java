package pyjvm.bridge.java;


class PyException extends Throwable {
    private PyObject pyObject;

    public PyException(PyObject pyObject) {
        this.pyObject = pyObject;
    }
}