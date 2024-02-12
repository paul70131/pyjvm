from distutils.command.build import build
from distutils.command.build_ext import build_ext
import warnings
from setuptools import setup, Extension, find_packages

from Cython.Build import cythonize
import Cython.Compiler.Options

import platform
import os
import shutil
import subprocess

extensions = [
    Extension(
        'pyjvm.jvm',
        ['pyjvm/jvm.pyx',],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ), 
    Extension(
        'pyjvm.types.clazz.jvmclass',
        ['pyjvm/types/clazz/jvmclass.pyx',],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.types.clazz.jvmfield',
        ['pyjvm/types/clazz/jvmfield.pyx',],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.types.clazz.jvmmethod',
        ['pyjvm/types/clazz/jvmmethod.pyx',],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.types.signature',
        ['pyjvm/types/signature.pyx',],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.exceptions.exception',
        ['pyjvm/exceptions/exception.pyx',],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.types.object.jvmboundfield',
        ['pyjvm/types/object/jvmboundfield.pyx'],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.types.object.jvmboundmethod',
        ['pyjvm/types/object/jvmboundmethod.pyx'],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.types.converter.typeconverter',
        ['pyjvm/types/converter/typeconverter.pyx'],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.types.clazz.special.jvmstring',
        ['pyjvm/types/clazz/special/jvmstring.pyx'],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.types.clazz.special.jvmenum',
        ['pyjvm/types/clazz/special/jvmenum.pyx'],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.types.clazz.special.jvmexception',
        ['pyjvm/types/clazz/special/jvmexception.pyx'],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.types.array.jvmarray',
        ['pyjvm/types/array/jvmarray.pyx'],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.bytecode.jvmbytecodeclass',
        ['pyjvm/bytecode/jvmbytecodeclass.pyx'],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.bytecode.components.jvmbytecodefields',
        ['pyjvm/bytecode/components/jvmbytecodefields.pyx'],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.bytecode.components.jvmbytecodemethods',
        ['pyjvm/bytecode/components/jvmbytecodemethods.pyx'],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.bytecode.components.jvmbytecodeattributes',
        ['pyjvm/bytecode/components/jvmbytecodeattributes.pyx'],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.bytecode.components.jvmbytecodeconstantpool',
        ['pyjvm/bytecode/components/jvmbytecodeconstantpool.pyx'],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.bytecode.components.jvmbytecodeinterfaces',
        ['pyjvm/bytecode/components/jvmbytecodeinterfaces.pyx'],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.bytecode.components.base',
        ['pyjvm/bytecode/components/base.pyx'],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
    Extension(
        'pyjvm.bytecode.jvmmethodlink',
        ['pyjvm/bytecode/jvmmethodlink.pyx'],
        include_dirs=["./pyjvm", "./pyjvm/c/headers"],
    ),
]

JAVA_HOME = os.environ.get("JAVA_HOME", None)

# Compile java files

Cython.Compiler.Options.annotate = True
Cython.Compiler.Options._directive_defaults['profile'] = True

j_classes = []
for f in os.walk("pyjvm/bridge/java"):
    for file in f[2]:
        if file.endswith(".java"):
            j_classes.append(f"{f[0]}/{file}")

r = subprocess.run(["javac", *j_classes], capture_output=True)
err = r.stderr.decode("utf-8")
if err:
    print(err)
    raise Exception("Failed to compile java files", err)
            
for f in os.walk("pyjvm/bridge/scala"):
    for file in f[2]:
        if file.endswith(".scala"):
            r = subprocess.run(["scalac", "-d", "pyjvm/bridge/scala", f"{f[0]}/{file}"], capture_output=True)
            err = r.stderr.decode("utf-8")
            if err:
                print(err)
                raise Exception("Failed to compile scala files", err)

setup(
    name='pyjvm',
    description="Python Bindings for the JVM (jni & jvmti)",
    ext_modules=cythonize(extensions, language_level=3, build_dir="build/c", annotate=True, compiler_directives={'profile': True, 'linetrace': True, 'embedsignature': True}),
    packages=find_packages(".") + ["pyjvm.bridge"],
    package_dir={'pyjvm': 'pyjvm'},
    #b
    include_dirs=[
        JAVA_HOME + "/include",
        JAVA_HOME + "/include/win32",
    ],
    package_data={
        "pyjvm.bridge": ["**/*.class"],
    },
    zip_safe=False,
    version='0.1.0',
    author="Paul K."
)