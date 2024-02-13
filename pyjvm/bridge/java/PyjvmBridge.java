package pyjvm.bridge.java;

import java.lang.reflect.Method;
import java.lang.reflect.Field;

public class PyjvmBridge {

    public static native Object call_override(Object ... args);

    public static Method getMethod(String methodName, Object obj) {
        Method[] methods = obj.getClass().getMethods();
        for (Method method : methods) {
            if (method.getName().equals(methodName)) {
                return method;
            }
        }
        return null;
    }

    public static void setField(String fieldName, Object obj, Object value) throws IllegalArgumentException, IllegalAccessException {
        Field[] fields = obj.getClass().getFields();
        Field field = null;
        for (Field f : fields) {
            if (f.getName().equals(fieldName)) {
                field = f;
                break;
            }
        }
        if (field != null) {
            Class t = field.getType();
            value = PyjvmBridge.convertValue(value, t);
            field.set(obj, value);
        } else {
            throw new IllegalArgumentException("Field not found");
        }
    }

    public static Object convertValue(Object value, Class t) {
        if (t == int.class) {
            if (value instanceof Long) {
                return ((Long)value).intValue();
            } else if (value instanceof Double) {
                return ((Double)value).intValue();
            }
        } else if (t == long.class) {
            if (value instanceof Long) {
                return value;
            } else if (value instanceof Double) {
                return ((Double)value).longValue();
            }
        } else if (t == double.class) {
            if (value instanceof Long) {
                return ((Long)value).doubleValue();
            } else if (value instanceof Double) {
                return value;
            }
        } else if (t == float.class) {
            if (value instanceof Long) {
                return ((Long)value).floatValue();
            } else if (value instanceof Double) {
                return ((Double)value).floatValue();
            }
        } else if (t == short.class) {
            if (value instanceof Long) {
                return ((Long)value).shortValue();
            } else if (value instanceof Double) {
                return ((Double)value).shortValue();
            }
        } else if (t == byte.class) {
            if (value instanceof Long) {
                return ((Long)value).byteValue();
            } else if (value instanceof Double) {
                return ((Double)value).byteValue();
            }
        } else if (t == char.class) {
            if (value instanceof Long) {
                return (char)((long)value);
            } else if (value instanceof Double) {
                return (char)((double)value);
            }
        } else if (t == boolean.class) {
            if (value instanceof Long) {
                return ((Long)value) != 0;
            } else if (value instanceof Double) {
                return ((Double)value) != 0;
            }
        } else if (t == String.class) {
            if (value instanceof Long) {
                return value.toString();
            } else if (value instanceof Double) {
                return value.toString();
            }
        }

        return null;
    }

    public static Object getField(String fieldName, Object obj) throws IllegalArgumentException, IllegalAccessException {
        Field[] fields = obj.getClass().getFields();
        Field field = null;
        for (Field f : fields) {
            if (f.getName().equals(fieldName)) {
                field = f;
                break;
            }
        }
        if (field != null) {
            Object value = field.get(obj);
            if (value instanceof Long) {
                return (Long)value;
            } else if (value instanceof Double) {
                return (Double)value;
            } else if (value instanceof Boolean) {
                return value;
            } else if (value instanceof Character) {
                return value;
            } else if (value instanceof Byte) {
                return ((Byte)value).longValue();
            } else if (value instanceof Short) {
                return ((Short)value).longValue();
            } else if (value instanceof Float) {
                return ((Float)value).doubleValue();
            } else if (value instanceof Integer) {
                return ((Integer)value).longValue();
            }
            return value;
        }
        return null;
    }

    public static void tryAdapt(Method method, java.lang.Object[] args) {
        Class<?>[] parameterTypes = method.getParameterTypes();
        if (parameterTypes.length != args.length) {
            throw new RuntimeException("Invalid number of arguments");
        }
        for (int i = 0; i < parameterTypes.length; i++) {
            if (parameterTypes[i] == long.class) {
                if (args[i] instanceof Double) {
                    args[i] = ((Double)args[i]).longValue();
                }
            } else if (parameterTypes[i] == double.class) {
                if (args[i] instanceof Long) {
                    args[i] = ((Long)args[i]).doubleValue();
                }
            } else if (parameterTypes[i] == String.class) {
                if (args[i] instanceof Long || args[i] instanceof Double) {
                    args[i] = args[i].toString();
                }
            } else if (parameterTypes[i] == boolean.class) {
                if (args[i] instanceof Long) {
                    args[i] = ((Long)args[i]) != 0;
                } else if (args[i] instanceof Double) {
                    args[i] = ((Double)args[i]) != 0;
                }
            } else if (parameterTypes[i] == char.class) {
                if (args[i] instanceof Long) {
                    args[i] = (char)((long)args[i]);
                } else if (args[i] instanceof Double) {
                    args[i] = (char)((double)args[i]);
                }
            } else if (parameterTypes[i] == byte.class) {
                if (args[i] instanceof Long) {
                    args[i] = ((Long)args[i]).byteValue();
                } else if (args[i] instanceof Double) {
                    args[i] = ((Double)args[i]).byteValue();
                }
            } else if (parameterTypes[i] == short.class) {
                if (args[i] instanceof Long) {
                    args[i] = ((Long)args[i]).shortValue();
                } else if (args[i] instanceof Double) {
                    args[i] = ((Double)args[i]).shortValue();
                }
            } else if (parameterTypes[i] == float.class) {
                if (args[i] instanceof Long) {
                    args[i] = ((Long)args[i]).floatValue();
                } else if (args[i] instanceof Double) {
                    args[i] = ((Double)args[i]).floatValue();
                }
            } else if (parameterTypes[i] == int.class) {
                if (args[i] instanceof Long) {
                    args[i] = ((Long)args[i]).intValue();
                } else if (args[i] instanceof Double) {
                    args[i] = ((Double)args[i]).intValue();
                }
            }
        }
    }

    public static Object __sub__(Object obj, Object other) {
        if (obj instanceof Long && other instanceof Long) {
            return (Long)((long)obj - (long)other);
        } else if (obj instanceof Double && other instanceof Double) {
            return (Double)((double)obj - (double)other);
        } else if (obj instanceof Long && other instanceof Double) {
            return (Double)((long)obj - (double)other);
        } else if (obj instanceof Double && other instanceof Long) {
            return (Double)((double)obj - (long)other);
        }
        return null;
    }

    public static Object __mul__(Object obj, Object other) {
        if (obj instanceof Long && other instanceof Long) {
            return (Long)((long)obj * (long)other);
        } else if (obj instanceof Double && other instanceof Double) {
            return (Double)((double)obj * (double)other);
        } else if (obj instanceof Long && other instanceof Double) {
            return (Double)((long)obj * (double)other);
        } else if (obj instanceof Double && other instanceof Long) {
            return (Double)((double)obj * (long)other);
        }
        return null;
    }

    public static Object __div__(Object obj, Object other) {
        if (obj instanceof Long && other instanceof Long) {
            return (Long)((long)obj / (long)other);
        } else if (obj instanceof Double && other instanceof Double) {
            return (Double)((double)obj / (double)other);
        } else if (obj instanceof Long && other instanceof Double) {
            return (Double)((long)obj / (double)other);
        } else if (obj instanceof Double && other instanceof Long) {
            return (Double)((double)obj / (long)other);
        }
        return null;
    }

    public static Object __add__(Object obj, Object other) {
        if (obj instanceof Long && other instanceof Long) {
            return (Long)((long)obj + (long)other);
        } else if (obj instanceof Double && other instanceof Double) {
            return (Double)((double)obj + (double)other);
        } else if (obj instanceof Long && other instanceof Double) {
            return (Double)((long)obj + (double)other);
        } else if (obj instanceof Double && other instanceof Long) {
            return (Double)((double)obj + (long)other);
        } else if (obj instanceof String && other instanceof String) {
            return (String)obj + (String)other;
        }
        return null;
    }
}
